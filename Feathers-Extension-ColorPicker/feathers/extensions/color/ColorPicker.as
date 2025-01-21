/*
Copyright 2018 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.extensions.color
{
	import feathers.controls.Label;
	import feathers.controls.Slider;
	import feathers.controls.TextInput;
	import feathers.core.PopUpManager;
	import feathers.extensions.color.components.ColorQuad;
	import feathers.extensions.color.components.ColorSelector;
	import feathers.extensions.color.components.Spacer;
	import feathers.extensions.color.utils.Tween;
	import feathers.extensions.borderContainer.BorderContainer;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalAlign;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	//import flash.text.StageTextClearButtonMode;
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	/**
	 * The skin of the pop-up gradient slider.
	 *
	 * <p>In the following example,the skin of the pop-up gradient slider is an arrow:</p>
	 *
	 * <p><listing version="3.0">
	 * colorPicker.sliderSkin = ColorPicker.SLIDER_ARROW;</listing></p>
	 *
	 * @default sliderNormal
	 *
	 * @see feathers.extensions.color.ColorPicker#SLIDER_NORMAL
	 * @see feathers.extensions.color.ColorPicker#SLIDER_ARROW
	 */
	[Style(name="sliderSkin",type="String")]
	
	/**
	 *  The ColorPicker control provides a way for a user to choose a color from a spectrum.
	 *  The default mode of the component shows a single swatch in a square button.
	 *  When the user clicks the swatch button, the swatch panel appears and
	 *  displays the entire color spectrum.
	 */
	public class ColorPicker extends BorderContainer
	{
		/**
		 * The skin of the pop-up gradient slider is a classic Feathers Slider.
		 */
		public static const SLIDER_NORMAL:String = "sliderNormal";
		
		/**
		 * The skin of the pop-up gradient slider is an arrow.
		 */
		public static const SLIDER_ARROW:String = "sliderArrow";
		
		/**
		 * @private
		 */
		protected var _sliderSkin:String;
		
		[Inspectable(type="String",enumeration="sliderNormal,sliderArrow")]
		/**
		 * @private
		 */
		public function get sliderSkin():String
		{
			return this._sliderSkin;
		}

		/**
		 * @private
		 */
		public function set sliderSkin(value:String):void
		{
			this._sliderSkin = value;
		}
		
		/**
		 * @private
		 */
		public var colorQuad:ColorQuad = new ColorQuad();
		/**
		 * @private
		 */
		public var colorText:TextInput = new TextInput();
		/**
		 * @private
		 */
		protected var colorSelector:ColorSelector;
		/**
		 * @private
		 */
		public var dispatchInputChange:Boolean = true;
		/**
		 * Determines if the color spectrum is open.
		 */
		public var isOpen:Boolean;
		
		/*private var _backgroundBorderColor:uint = 0x000000;
		/**
		 * The color of the background border.
		 *
		 * @default 0x000000
		 * /
		public function get backgroundBorderColor():uint
		{
			return this._backgroundBorderColor;
		}
		public function set backgroundBorderColor(value:uint):void
		{
			this._backgroundBorderColor = value;
		}*/
		
		/*private var _backgroundColor:uint = 0x393430;
		/**
		 * The color of the background.
		 *
		 * @default 0x393430
		 * /
		public function get backgroundColor():uint
		{
			return this._backgroundColor;
		}
		public function set backgroundColor(value:uint):void
		{
			this._backgroundColor = value;
		}*/
		
		private var _marginPopUpLeft:Number = 0;
		/**
		 * The margin left of the pop-up color.
		 *
		 * @default 0
		 */
		public function get marginPopUpLeft():Number
		{
			return this._marginPopUpLeft;
		}
		public function set marginPopUpLeft(value:Number):void
		{
			this._marginPopUpLeft = value;
		}
		
		private var _marginPopUpRight:Number = 0;
		/**
		 * The margin right of the pop-up color.
		 *
		 * @default 0
		 */
		public function get marginPopUpRight():Number
		{
			return this._marginPopUpRight;
		}
		public function set marginPopUpRight(value:Number):void
		{
			this._marginPopUpRight = value;
		}
		
		private var _marginPopUpTop:Number = 0;
		/**
		 * The margin top of the pop-up color.
		 *
		 * @default 0
		 */
		public function get marginPopUpTop():Number
		{
			return this._marginPopUpTop;
		}
		public function set marginPopUpTop(value:Number):void
		{
			this._marginPopUpTop = value;
		}
		
		private var _marginPopUpBottom:Number = 0;
		/**
		 * The margin bottom of the pop-up color.
		 *
		 * @default 0
		 */
		public function get marginPopUpBottom():Number
		{
			return this._marginPopUpBottom;
		}
		public function set marginPopUpBottom(value:Number):void
		{
			this._marginPopUpBottom = value;
		}
		
		private var _color:uint = 0xFF0000;
		/**
		 * The value of the currently color selection.
		 *
		 * @default 0xFF0000
		 */
		public function get color():uint
		{
			return this._color;
		}
		public function set color(value:uint):void
		{
			this._color = value;
			if( this.isCreated )
			{
				dispatchInputChange = false;
				colorText.text = value.toString(16).toUpperCase();
				colorText.dispatchEvent( new Event ( Event.CHANGE ) );
			}
		}
		
		/**
		 * The text input to display the hexadecimal color value.
		 */
		public function get textInput():TextInput
		{
			return this.colorText;
		}
		
		/**
		 * The pop-up gradient slider.
		 */
		public function get slider():Slider
		{
			return this.colorSelector.slider;
		}
		
		private var tween:Tween;
		
		private var _useTransition:Boolean = true;
		/**
		 * Use transition when color spectrum is opened or closed.
		 *
		 * @default true
		 */
		public function get useTransition():Boolean
		{
			return this._useTransition;
		}
		public function set useTransition(value:Boolean):void
		{
			this._useTransition = value;
		}
		
		/**
		 * The string value of the current color selection.
		 */
		public function set hexValue(value:String):void
		{
			//if( value.substring(0, 1) == "#" ) value = value.substring(1);
			if( value.substring(0, 2).toLowerCase() == "0x" ) value = value.substring(2);
			var pattern:RegExp = /[^a-f^A-F^0-9]/g;
			value = value.replace(pattern, "");
			if( value.length > 6 ) value = value.substring(0, 6);
			var length:int = value.length;
			for(var i:int = 0; i < 6 - length; i++)
			{
				value = "0" + value;
			}
			colorText.text = value;
		}
		public function get hexValue():String
		{
			return colorText.text;
		}
		
		public function ColorPicker()
		{
			super();
			colorSelector = new ColorSelector( this );
			var horizontalLayout:HorizontalLayout = new HorizontalLayout();
			horizontalLayout.verticalAlign = VerticalAlign.MIDDLE;
			horizontalLayout.gap = 1;
			horizontalLayout.paddingTop = 3;
			horizontalLayout.paddingBottom = 3;
			horizontalLayout.paddingLeft = 5;
			horizontalLayout.paddingRight = 5;
			this.layout = horizontalLayout;
			
			colorQuad.addEventListener(TouchEvent.TOUCH, onColorQuadTouchEvent);
			this.addChild( colorQuad );
			
			var spacer:Spacer = new Spacer();
			spacer.width = 4;
			this.addChild( spacer );
			
			var label:Label = new Label();
			label.text = "#";
			this.addChild( label );
			
			colorText.addEventListener(Event.CHANGE, onInputChange);
			colorText.restrict = "0-9a-fA-F";
			colorText.maxChars = 6;
			colorText.typicalText = "DDDDDD";
			if( isIOS ) colorText.textEditorProperties.clearButtonMode = "never"; // StageTextClearButtonMode.NEVER;
			this.addChild( colorText );
		}
		
		/**
		 * @private
		 */
		override protected function initialize():void
		{
			super.initialize();
			
			colorText.validate();
			colorText.width = colorText.minWidth;
			colorQuad.size = colorText.height;
			dispatchInputChange = false;
			colorText.text = this.color.toString(16).toUpperCase();
			colorText.dispatchEvent( new Event ( Event.CHANGE ) );
			//colorQuad.color = this.color;
			
			/*if( ! this.backgroundSkin )
			{
				var shape:Shape = new Shape();
				shape.graphics.beginFill(backgroundBorderColor);
				shape.graphics.drawRect(0, 0, 10, 10);
				shape.graphics.endFill();
				shape.graphics.beginFill(backgroundColor);
				shape.graphics.drawRect(1, 1, 8, 8);
				shape.graphics.endFill();
				var bitmapData:BitmapData = new BitmapData( shape.width, shape.height );
				bitmapData.draw( shape );
				var skin:Image = new Image( Texture.fromBitmap( new Bitmap( bitmapData ) ) );
				skin.scale9Grid = new Rectangle( 3, 3, 4, 4 );
				this.backgroundSkin = skin;
				//bitmapData.dispose();
			}*/
			
			if( useTransition )
			{
				colorSelector.alpha = 0;
				tween = new Tween(colorSelector, 0.4, Transitions.EASE_OUT);
				tween.addEventListener( Event.COMPLETE, onTweenComplete );
				tween.fadeTo(1);
			}
		}
		
		private function onInputChange(event:Event):void
		{
			if( colorText.text == "" ) return;
			if( ! dispatchInputChange )
			{
				for(var i:int = 0; i < 6 - colorText.text.length; i++)
				{
					colorText.text = "0" + colorText.text;
					return;
				}
			}
			this._color = uint( "0x" + colorText.text );
			colorQuad.color = this._color;
			if( ! dispatchInputChange )
			{
				dispatchInputChange = true;
				return;
			}
			var red:uint = (this._color & 0xFF0000) >> 16;
			var green:uint = (this._color & 0x00FF00) >> 8;
			var blue:uint = this._color & 0x0000FF;
			var HSL:Object = rgbToHsl( red, green, blue );
			if( colorSelector.colorSpectrum.width == 0 ) colorSelector.validate();
			colorSelector.targetQuad.x = HSL.h * colorSelector.colorSpectrum.width / 360 + (colorSelector.layout as HorizontalLayout).paddingLeft;
			colorSelector.targetQuad.y = ( 100 - HSL.l ) * colorSelector.colorSpectrum.height / 100 + (colorSelector.layout as HorizontalLayout).paddingTop;
			colorSelector.createGradient(this._color);
		}
		
		private function rgbToHsl(r:Number, g:Number, b:Number):Object
		{
			r /= 255, g /= 255, b /= 255;
			var max:Number = Math.max(r, g, b), min:Number = Math.min(r, g, b);
			var h:Number, s:Number, l:Number = (max + min) / 2;
			
			if(max == min){
				h = s = 0; // achromatic
			}else{
				var d:Number = max - min;
				s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
				switch(max){
					case r: h = (g - b) / d + (g < b ? 6 : 0); break;
					case g: h = (b - r) / d + 2; break;
					case b: h = (r - g) / d + 4; break;
				}
				h /= 6;
			}
			
			return { h:Math.floor(h * 360), s:Math.floor(s * 100), l:Math.floor(l * 100)};
		}
		
		private function onColorQuadTouchEvent(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch( colorQuad );
			if(!touch) return;
			if(touch.phase == TouchPhase.BEGAN)
			{
				colorSelector.isDispatchedColorQuadTouchBegan = true;
				open();
				/*if( ! isOpen )
				{
					PopUpManager.addPopUp( colorSelector, false, false );
					positionRelative();
					isOpen = true;
					colorSelector.addEventListener(Event.ENTER_FRAME, colorSelector.enterFrameHandler);
					stage.addEventListener(Event.RESIZE, positionRelative);*/
					/*event.stopPropagation();
					open();
				}*/
				/*else
				{
					PopUpManager.removePopUp( colorSelector );
					isOpen = false;
				}*/
			}
		}
		
		/**
		 * Open the color spectrum.
		 */
		public function open():void
		{
			if( useTransition && tween )
			{
				if( ! tween.isPlaying && ! tween.isTweenEndAtEnd )
				{
					openPopUp();
				}
				tween.start();
			}
			else if( ! isOpen )
			{
				openPopUp();
			}
			else
			{
				close();
			}
		}
		
		private function openPopUp():void
		{
			PopUpManager.addPopUp( colorSelector, false, false );
			positionRelative();
			isOpen = true;
			stage.addEventListener(TouchEvent.TOUCH, colorSelector.stage_touchHandler);
			stage.addEventListener(Event.RESIZE, positionRelative);
		}
		
		/**
		 * Close the color spectrum.
		 */
		public function close():void
		{
			if( useTransition && tween )
			{
				if( ! tween.isPlaying && tween.isTweenEndAtEnd )
				{
					tween.start();
				}
				else if( tween.isPlaying && ! tween.isTweenEndAtEnd )
				{
					tween.start();
				}
			}
			else if( isOpen )
			{
				closePopUp();
			}
		}
		
		private function closePopUp():void
		{
			stage.removeEventListener(TouchEvent.TOUCH, colorSelector.stage_touchHandler);
			stage.removeEventListener(Event.RESIZE, positionRelative);
			isOpen = false;
			PopUpManager.removePopUp( colorSelector );
		}
		
		private function onTweenComplete(event:Event):void
		{
			if( ! event.data.isTweenEndAtEnd )
			{
				closePopUp();
			}
		}
		
		/**
		 * @private
		 */
		public function positionRelative(event:Event = null):void
		{
			var gap:Number = 3;
			var isCentered:Boolean;
			var pos:Point = new Point();
			var rect:Rectangle = new Rectangle( marginPopUpLeft, marginPopUpTop, stage.stageWidth - marginPopUpRight, stage.stageHeight - marginPopUpBottom );
			var picRect:Rectangle = this.getBounds( stage );
			if( colorSelector.height == 0 ) colorSelector.validate();
			var selRect:Rectangle = colorSelector.getBounds( stage );
			if( picRect.y + picRect.height + gap + selRect.height + rect.y <= rect.height)
			{
				pos.x = picRect.x < rect.x ? rect.x : picRect.x;
				pos.y = picRect.y + picRect.height + gap + rect.y;
				if( pos.x + selRect.width > rect.width)
				{
					pos.x = rect.width - selRect.width;
				}
				if( pos.x < rect.x ) isCentered = true;
			}
			else if( picRect.y - gap - selRect.height >= rect.y)
			{
				pos.x = picRect.x < rect.x ? rect.x : picRect.x;
				pos.y = picRect.y - gap - selRect.height - rect.y;
				if( picRect.x + selRect.width > rect.width)
				{
					pos.x = rect.width - selRect.width;
				}
				if( pos.x < rect.x ) isCentered = true;
			}
			else if( picRect.x + picRect.width + gap + selRect.width + rect.x <= rect.width)
			{
				pos.x = picRect.x + picRect.width + gap + rect.x;
				pos.y = picRect.y < rect.y ? rect.y : picRect.y ;
				if( pos.y + selRect.height > rect.height)
				{
					pos.y = rect.height - selRect.height;
				}
				if( pos.y < rect.y ) isCentered = true;
			}
			else if( picRect.x - gap - selRect.width >= rect.x)
			{
				pos.x = picRect.x - gap - selRect.width - rect.x;
				pos.y = picRect.y < rect.y ? rect.y : picRect.y;
				if( pos.y + selRect.height > rect.height)
				{
					pos.y = rect.height - selRect.height;
				}
				if( pos.y < rect.y ) isCentered = true;
			}
			else
			{
				isCentered = true;
			}
			
			if( ! isCentered )
			{
				colorSelector.x = pos.x;
				colorSelector.y = pos.y;
			}
			else
			{
				PopUpManager.centerPopUp( colorSelector );
			}
		}
		
		/**
		 * @private
		 */
		override public function set backgroundSkin(value:DisplayObject):void
		{
			super.backgroundSkin = value;
			var image:Image = value as Image;
			var skin:Image = new Image( image.texture );
			skin.scale9Grid = image.scale9Grid;
			colorSelector.backgroundSkin = skin;
		}
		
		private function get isIOS():Boolean
		{
			return Capabilities.os.indexOf("iPhone") >= 0 || Capabilities.os.indexOf("iPad") >= 0;
		}
		
		/**
		 * @private
		 */
		override public function dispose():void
		{
			colorQuad.removeEventListener(TouchEvent.TOUCH, onColorQuadTouchEvent);
			colorSelector.dispose();
			
			super.dispose();
		}
	}
}