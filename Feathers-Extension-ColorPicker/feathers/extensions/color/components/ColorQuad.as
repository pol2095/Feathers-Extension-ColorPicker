/*
Copyright 2018 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.extensions.color.components
{
	import feathers.core.FeathersControl;
	import starling.display.Quad;
	
	public class ColorQuad extends FeathersControl
	{
		public function ColorQuad()
		{
			super();
		}
		
		private var _color:uint = 0xffffff;
		
		public function get color():uint
		{
			return _color;
		}
		
		public function set color(color:uint):void
		{
			this._color = color;
			this.width = this.height = size;
			var quad:Quad = new Quad( size, size, color );
			this.addChild( quad );
		}
		
		public var size:Number = 0;
	}
}