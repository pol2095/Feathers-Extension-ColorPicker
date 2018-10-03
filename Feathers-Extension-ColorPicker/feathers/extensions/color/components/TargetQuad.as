/*
Copyright 2018 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.extensions.color.components
{
	import feathers.core.FeathersControl;
	import starling.display.Quad;
	
	public class TargetQuad extends FeathersControl
	{
		public function TargetQuad()
		{
			super();
			this.width = this.height = 11;
			var color:uint = 0x000000;
			var quad1:Quad = new Quad( 1, 4, color );
			quad1.x = 5;
			this.addChild( quad1 );
			var quad2:Quad = new Quad( 1, 4, color );
			quad2.x = 5;
			quad2.y = 7;
			this.addChild( quad2 );
			var quad3:Quad = new Quad( 4, 1, color );
			quad3.y = 5;
			this.addChild( quad3 );
			var quad4:Quad = new Quad( 4, 1, color );
			quad4.x = 7;
			quad4.y = 5;
			this.addChild( quad4 );
			this.pivotX = this.pivotY = 6;
		}
	}
}