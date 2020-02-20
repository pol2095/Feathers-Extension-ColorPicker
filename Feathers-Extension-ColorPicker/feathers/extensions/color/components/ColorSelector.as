/*
Copyright 2018 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.extensions.color.components
{
	import feathers.controls.Button;
	import feathers.controls.ImageLoader;
	import feathers.controls.LayoutGroup;
	import feathers.controls.Slider;
	import feathers.controls.TextInput;
	import feathers.core.PopUpManager;
	import feathers.extensions.color.ColorPicker;
	import feathers.layout.Direction;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalAlign;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import feathers.events.FeathersEventType;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	
	public class ColorSelector extends LayoutGroup
	{
		[Embed(source='../assets/ColorSpectrum.jpg')]
		private var ColorSpectrum:Class;
		
		private var owner:ColorPicker;
		
		public var colorSpectrum:ImageLoader = new ImageLoader();
		public var targetQuad:TargetQuad = new TargetQuad();
		private var gradient:ImageLoader = new ImageLoader();
		public var slider:Slider = new Slider();
		private var dispatchSliderChange:Boolean;
		private var spectrumBitmapData:BitmapData;
		private var gradientBitmapData:BitmapData;
		public var isDispatchedColorQuadTouchBegan:Boolean; //Determines for touch began if an interactive DisplayObject is over colorQuad.
		private var thumbs:Button;
		
		public function ColorSelector( owner:ColorPicker )
		{
			this.owner = owner;
			var horizontalLayout:HorizontalLayout = new HorizontalLayout();
			horizontalLayout.gap = 5;
			horizontalLayout.paddingTop = 5;
			horizontalLayout.paddingBottom = 5;
			horizontalLayout.paddingLeft = 5;
			horizontalLayout.paddingRight = 5;
			//horizontalLayout.verticalAlign = VerticalAlign.MIDDLE;
			this.layout = horizontalLayout;
			
			this.addChild( colorSpectrum );
			
			targetQuad.includeInLayout = false;
			this.addChild( targetQuad );
			
			var spacer:Spacer = new Spacer();
			this.addChild( spacer );
			
			this.addChild( gradient );
			
			slider.minimum = 0;
			slider.maximum = 100;
			slider.direction = Direction.VERTICAL;
			this.addChild( slider );
		}
		
		/**
		 * @private
		 */
		override protected function initialize():void
		{
			super.initialize();
			colorSpectrum.scale = 0.9;
			var bitmap:Bitmap = new ColorSpectrum() as Bitmap;
			colorSpectrum.source = Texture.fromBitmap( bitmap );
			spectrumBitmapData = bitmap.bitmapData;
			colorSpectrum.addEventListener(TouchEvent.TOUCH, onSpectrumTouchEvent);
			gradient.addEventListener(TouchEvent.TOUCH, onGradientTouchEvent);
			colorSpectrum.validate();
			slider.addEventListener(Event.CHANGE, sliderChangeHandler);
			createGradient( owner.color );
			gradient.validate();
			gradient.scale = colorSpectrum.height / gradient.height;
			slider.height = colorSpectrum.height;
			/*dispatchSliderChange = false;
			slider.value = 50;*/
			
			
			/*var shape:Shape = new Shape();
			shape.graphics.beginFill(owner.backgroundBorderColor);
			shape.graphics.drawRect(0, 0, 10, 10);
			shape.graphics.endFill();
			shape.graphics.beginFill(owner.backgroundColor);
			shape.graphics.drawRect(1, 1, 8, 8);
			shape.graphics.endFill();
			var bitmapData:BitmapData = new BitmapData( shape.width, shape.height );
			bitmapData.draw( shape );
			var skin:Image = new Image( Texture.fromBitmap( new Bitmap( bitmapData ) ) );
			skin.scale9Grid = new Rectangle( 3, 3, 4, 4 );
			this.backgroundSkin = skin;*/
			//bitmapData.dispose();
			if( owner.sliderSkin == "sliderArrow" )
			{
				(this.layout as HorizontalLayout).verticalAlign = VerticalAlign.MIDDLE;
				//slider.showThumb = false;
				slider.thumbFactory = function():Button
				{
					var button:SliderButton = new SliderButton();
					thumbs = button;
					return button;
				}
				slider.minimumTrackFactory = function():Button
				{
					var track:Button = new Button();
					//track.alpha = 0;
					track.visible = false;
					return track;
				}
				slider.maximumTrackFactory = function():Button
				{
					var track:Button = new Button();
					track.visible = false;
					return track;
				}
				/*slider.customMinimumTrackStyleName = null;
				slider.customMaximumTrackStyleName = null;
				slider.focusIndicatorSkin = null;*/
				slider.addEventListener( FeathersEventType.CREATION_COMPLETE, sliderCreationCompleteHandler );
			}
		}
		
		private function sliderCreationCompleteHandler():void
		{
			slider.removeEventListener( FeathersEventType.CREATION_COMPLETE, sliderCreationCompleteHandler );
			slider.height += thumbs.height;
		}
		
		private function onSpectrumTouchEvent(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch( colorSpectrum );
			if( ! touch ) return;
			/*var target:Object = touch.target as Object;
			if( ! target ) return;*/
			var rect:Rectangle = colorSpectrum.getBounds( colorSpectrum );
			var point:Point = touch.getLocation( colorSpectrum );
			//if( ! rect.containsPoint( point ) ) return;
			var _point:Point = touch.getLocation( this );
			if(touch.phase == TouchPhase.BEGAN)
			{
				onSpectrumTouch( point, _point, true );
			}
			if(touch.phase == TouchPhase.MOVED)
			{
				var touchIn:Boolean = rect.containsPoint( point );
				onSpectrumTouch( point, _point, touchIn );
			}
		}
		
		private function onSpectrumTouch(point:Point, _point:Point, touchIn:Boolean):void
		{
			targetQuad.x = _point.x;
			targetQuad.y = _point.y;
			point = touchLimitSpectrum( point, touchIn );
			var bitmapData:BitmapData = spectrumBitmapData; //colorSpectrum.drawToBitmapData();
			var color:uint = bitmapData.getPixel( point.x, point.y );
			owner.dispatchInputChange = false;
			owner.colorText.text = color.toString(16).toUpperCase();
			//owner.colorQuad.color = color;
			createGradient(color);
			//bitmapData.dispose();
		}
		
		public function createGradient(color:uint):void
		{
			if(gradient.source) Texture(gradient.source).dispose();
			if(gradientBitmapData) gradientBitmapData.dispose();
			
			var shape:Shape = new Shape();
			var gradientBoxMatrix:Matrix = new Matrix();
			gradientBoxMatrix.createGradientBox(20, 200, Math.PI/2, 0, 0);
			shape.graphics.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, color, 0x000000], [1, 1, 1], [0, 128, 255], gradientBoxMatrix);
			shape.graphics.drawRect(0, 0, 20, 200);
			shape.graphics.endFill();
			gradientBitmapData = new BitmapData( shape.width, shape.height );
			gradientBitmapData.draw( shape );
			gradient.source = Texture.fromBitmap( new Bitmap( gradientBitmapData ) );
			dispatchSliderChange = false;
			slider.value=50;
			//bitmapData.dispose();
		}
		
		private function onGradientTouchEvent(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch( gradient );
			if(!touch) return;
			//var rect:Rectangle = gradient.getBounds( gradient );
			var point:Point = touch.getLocation( gradient );
			//if( ! rect.containsPoint( point ) ) return;
			if(touch.phase == TouchPhase.BEGAN)
			{
				onGradientTouch( point );
			}
			if(touch.phase == TouchPhase.MOVED)
			{
				var rect:Rectangle = gradient.getBounds( gradient );
				if( ! rect.containsPoint( point ) ) point = touchLimitGradient( point, rect );
				onGradientTouch( point );
			}
		}
		
		private function onGradientTouch(point:Point):void
		{
			var bitmapData:BitmapData = gradientBitmapData; //gradient.drawToBitmapData();
			var color:uint = bitmapData.getPixel( point.x, point.y );
			owner.dispatchInputChange = false;
			owner.colorText.text = color.toString(16).toUpperCase();
			//owner.colorQuad.color = color;
			dispatchSliderChange = false;
			slider.value = 100 - ( point.y * gradient.scale * 100 / gradient.height );
			//bitmapData.dispose();
		}
		
		private function sliderChangeHandler(event:Event):void
		{
			if( ! dispatchSliderChange )
			{
				dispatchSliderChange = true;
				return;
			}
			var slider:Slider = Slider( event.currentTarget );
			var y:uint = (slider.maximum - slider.value) * ( gradient.height / gradient.scaleY ) / slider.maximum;
			var point:Point = new Point( 0, y );
			var bitmapData:BitmapData = gradientBitmapData; //gradient.drawToBitmapData();
			var color:uint = bitmapData.getPixel( point.x, point.y );
			owner.dispatchInputChange = false;
			owner.colorText.text = color.toString(16).toUpperCase();
			//owner.colorQuad.color = color;
			//bitmapData.dispose();
		}
		
		public function stage_touchHandler(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch( stage );
			if(!touch) return;
			if(touch.phase == TouchPhase.BEGAN)
			{
				var point:Point = touch.getLocation( stage );
				var rect:Rectangle = owner.colorQuad.getBounds( stage );
				if( rect.containsPoint( point ) )
				{
					if( ! isDispatchedColorQuadTouchBegan )
					{
						owner.open();
					}
					else
					{
						isDispatchedColorQuadTouchBegan = false;
					}
					return;
				}
				
				var target:DisplayObject = DisplayObject(event.target);
				if(this.contains(target))
				{
					//touched inside the callout, so don't close it
					return;
				}
				if(PopUpManager.isPopUp(this) && !PopUpManager.isTopLevelPopUp(this))
				{
					//another modal pop-up is above the callout, and we shouldn't close
					//the callout until other popup gets closed first
					return;
				}
				//touched outside the callout, so we can close it
				/*stage.removeEventListener(TouchEvent.TOUCH, stage_touchHandler);
				stage.removeEventListener(Event.RESIZE, owner.positionRelative);
				owner.isOpen = false;
				PopUpManager.removePopUp( this );*/
				owner.close();
			}
		}
		
		private function touchLimitSpectrum(point:Point, touchIn:Boolean):Point
		{
			if( touchIn ) return point;
			if( targetQuad.x < colorSpectrum.x )
			{
				targetQuad.x = colorSpectrum.x;
				point.x = targetQuad.x - (this.layout as HorizontalLayout).paddingLeft;
			}
			else if( targetQuad.x > colorSpectrum.x + colorSpectrum.width )
			{
				targetQuad.x = colorSpectrum.x + colorSpectrum.width;
				point.x = ( targetQuad.x - (this.layout as HorizontalLayout).paddingLeft ) / colorSpectrum.scale - 1;
			}
			if( targetQuad.y < colorSpectrum.y )
			{
				targetQuad.y = colorSpectrum.y;
				point.y = targetQuad.y - (this.layout as HorizontalLayout).paddingTop;;
			}
			else if( targetQuad.y > colorSpectrum.y + colorSpectrum.height )
			{
				targetQuad.y = colorSpectrum.y + colorSpectrum.height;
				point.y = ( targetQuad.y - (this.layout as HorizontalLayout).paddingTop ) / colorSpectrum.scale;
			}
			return point;
		}
		
		private function touchLimitGradient(point:Point, rect:Rectangle):Point
		{
			if( point.x < rect.x )
			{
				point.x = rect.x;
			}
			else if( point.x > rect.x + rect.width )
			{
				point.x = rect.x + rect.width - 1;
			}
			if( point.y < rect.y )
			{
				point.y = rect.y;
			}
			else if( point.y > rect.y + rect.height )
			{
				point.x = rect.y + rect.height;
			}
			return point;
		}
		
		override public function dispose():void
		{
			colorSpectrum.removeEventListener(TouchEvent.TOUCH, onSpectrumTouchEvent);
			gradient.removeEventListener(TouchEvent.TOUCH, onGradientTouchEvent);
			slider.removeEventListener(Event.CHANGE, sliderChangeHandler);
			if(colorSpectrum.source) Texture(colorSpectrum.source).dispose();
			if(spectrumBitmapData) spectrumBitmapData.dispose();
			if(gradient.source) Texture(gradient.source).dispose();
			if(gradientBitmapData) gradientBitmapData.dispose();
			if( owner.isOpen )
			{
				stage.removeEventListener(TouchEvent.TOUCH, stage_touchHandler);
				stage.removeEventListener(Event.RESIZE, owner.positionRelative);
			}
		 
			super.dispose();
		}
	}
}