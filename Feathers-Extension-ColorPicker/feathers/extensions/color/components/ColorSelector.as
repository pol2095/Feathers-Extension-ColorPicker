/*
Copyright 2018 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.extensions.color.components
{
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
		private var slider:Slider = new Slider();
		private var dispatchSliderChange:Boolean;
		
		public function ColorSelector( owner:ColorPicker )
		{
			this.owner = owner;
			var horizontalLayout:HorizontalLayout = new HorizontalLayout();
			horizontalLayout.gap = 5;
			horizontalLayout.paddingTop = 5;
			horizontalLayout.paddingBottom = 5;
			horizontalLayout.paddingLeft = 5;
			horizontalLayout.paddingRight = 5;
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
			colorSpectrum.scale = 0.9;
			colorSpectrum.source = Texture.fromBitmap( new ColorSpectrum() as Bitmap );
			colorSpectrum.addEventListener(TouchEvent.TOUCH, onColorTouchEvent);
			gradient.addEventListener(TouchEvent.TOUCH, onGradientTouchEvent);
			colorSpectrum.validate();
			gradient.height = colorSpectrum.height;
			slider.height = colorSpectrum.height;
			dispatchSliderChange = false;
			slider.value = 50;
			slider.addEventListener(Event.CHANGE, sliderChangeHandler);
			createGradient( owner.color );
			
			var shape:Shape = new Shape();
			shape.graphics.beginFill(owner.backgroundBorderColor);
			shape.graphics.drawRect(0, 0, 100, 100);
			shape.graphics.endFill();
			shape.graphics.beginFill(owner.backgroundColor);
			shape.graphics.drawRect(1, 1, 98, 98);
			shape.graphics.endFill();
			var bitmapData:BitmapData = new BitmapData( shape.width, shape.height );
			bitmapData.draw( shape );
			var skin:Image = new Image( Texture.fromBitmap( new Bitmap( bitmapData ) ) );
			skin.scale = 0.1;
			skin.scale9Grid = new Rectangle( 1, 1, 98, 98 );
			this.backgroundSkin = skin;
			//bitmapData.dispose();
		}
		
		public function enterFrameHandler(event:Event):void
		{
			this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			stage.addEventListener(TouchEvent.TOUCH, stage_touchHandler);
		}
		
		private function onColorTouchEvent(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch( colorSpectrum );
			if( ! touch ) return;
			/*var target:Object = touch.target as Object;
			if( ! target ) return;*/
			var rect:Rectangle = colorSpectrum.getBounds( colorSpectrum );
			var point:Point = touch.getLocation( colorSpectrum );
			if( ! rect.containsPoint( point ) ) return;
			var _point:Point = touch.getLocation( this );
			if(touch.phase == TouchPhase.BEGAN)
			{
				onColorTouch( point, _point );
			}
			if(touch.phase == TouchPhase.MOVED)
			{
				onColorTouch( point, _point );
			}
		}
		
		private function onColorTouch(point:Point, _point:Point):void
		{
			targetQuad.x = _point.x;
			targetQuad.y = _point.y;
			var bitmapData:BitmapData = colorSpectrum.drawToBitmapData();
			var color:uint = bitmapData.getPixel( point.x * colorSpectrum.scale * owner.scaleFactor, point.y * colorSpectrum.scale * owner.scaleFactor );
			owner.dispatchInputChange = false;
			owner.colorText.text = color.toString(16).toUpperCase();
			//owner.colorQuad.color = color;
			createGradient(color);
			//bitmapData.dispose();
		}
		
		public function createGradient(color:uint):void
		{
			var shape:Shape = new Shape(); 
			var gradientBoxMatrix:Matrix = new Matrix(); 
			gradientBoxMatrix.createGradientBox(20, 200, Math.PI/2, 0, 0); 
			shape.graphics.beginGradientFill(GradientType.LINEAR, [0xFFFFFF, color, 0x000000], [1, 1, 1], [0, 128, 255], gradientBoxMatrix); 
			shape.graphics.drawRect(0, 0, 20, 200); 
			shape.graphics.endFill();
			var bitmapData:BitmapData = new BitmapData( shape.width, shape.height );
			bitmapData.draw( shape );
			gradient.source = Texture.fromBitmap( new Bitmap( bitmapData ) );
			dispatchSliderChange = false;
			slider.value=50;
			//bitmapData.dispose();
		}
		
		private function onGradientTouchEvent(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch( gradient );
			if(!touch) return;
			var rect:Rectangle = gradient.getBounds( gradient );
			var point:Point = touch.getLocation( gradient );
			if( ! rect.containsPoint( point ) ) return;
			if (touch.phase == TouchPhase.BEGAN)
			{
				onGradientTouch( point );
			}
			if(touch.phase == TouchPhase.MOVED)
			{
				onGradientTouch( point );
			}
		}
		
		private function onGradientTouch(point:Point):void
		{
			var bitmapData:BitmapData = gradient.drawToBitmapData();
			var color:uint = bitmapData.getPixel( point.x * gradient.scale * owner.scaleFactor, point.y * gradient.scale * owner.scaleFactor );
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
			var y:uint = (slider.maximum - slider.value) * ( gradient.height * gradient.scaleY * owner.scaleFactor ) / slider.maximum;
			var point:Point = new Point( 0, y );
			var bitmapData:BitmapData = gradient.drawToBitmapData();
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
			if (touch.phase == TouchPhase.BEGAN)
			{
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
		
		override public function dispose():void
		{
			colorSpectrum.removeEventListener(TouchEvent.TOUCH, onColorTouchEvent);
			gradient.removeEventListener(TouchEvent.TOUCH, onGradientTouchEvent);
			slider.removeEventListener(Event.CHANGE, sliderChangeHandler);
			if( owner.isOpen )
			{
				stage.removeEventListener(TouchEvent.TOUCH, stage_touchHandler);
				stage.removeEventListener(Event.RESIZE, owner.positionRelative);
			}
		 
			super.dispose();
		}
	}
}