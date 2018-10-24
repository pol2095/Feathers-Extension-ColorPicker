/*
Copyright 2017 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.extensions.color.components
{
	import feathers.controls.Button;
	//import feathers.layout.RelativePosition;
	import feathers.skins.IStyleProvider;
	
    public class SliderButton extends Button
    {
		/**
		 * The default <code>IStyleProvider</code> for all <code>BorderContainer</code>
		 * components.
		 *
		 * @default null
		 * @see feathers.core.FeathersControl#styleProvider
		 */
		public static var globalStyleProvider:IStyleProvider;
		
		public function SliderButton()
        {
			super();
        }
		
		//if(this.label != "") this.iconPosition = RelativePosition.RIGHT;
		
		/**
		 * @private
		 */
		override protected function get defaultStyleProvider():IStyleProvider
		{
			return SliderButton.globalStyleProvider;
		}
    }
}