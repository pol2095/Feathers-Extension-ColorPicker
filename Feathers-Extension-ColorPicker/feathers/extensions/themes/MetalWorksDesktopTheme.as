/*
Copyright 2018 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.extensions.themes
{
	import feathers.controls.ToggleButton;
	import feathers.themes.MetalWorksDesktopTheme;
	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;
	import starling.display.Image;
 
	public class MetalWorksDesktopTheme extends feathers.themes.MetalWorksDesktopTheme
	{
		private var classes:Vector.<String> = new <String>[
			"feathers.extensions.borderContainer.BorderContainer",
			"feathers.controls.ToggleButton"
		];
		
		public function MetalWorksDesktopTheme()
		{
			super();
		}
		
		/**
		 * @private 
		 */
		override protected function initializeStyleProviders():void
		{
			super.initializeStyleProviders();
			var length:int = classes.length;
            for( var i:int = length - 1; i >= 0; i-- )
			{
				if( ApplicationDomain.currentDomain.hasDefinition( classes[i] ) )
				{
					if( i == 0 )
					{
						this.getStyleProviderForClass( getDefinitionByName( classes[i] ) as Class ).defaultStyleFunction = this.setBorderContainerStyles;
					}
					else if( i == 1 )
					{
						this.getStyleProviderForClass( getDefinitionByName( classes[i] ) as Class ).setFunctionForStyleName("toggleButton-arrow", this.setToggleButtonArrowtyles);
					}
				}
			}
		}
		
		/**
		 * @private 
		 */
		protected function setBorderContainerStyles(borderContainer:Object):void
		{
			var backgroundSkin:Image = new Image(this.backgroundPopUpSkinTexture);
			backgroundSkin.scale9Grid = SIMPLE_SCALE9_GRID;
			borderContainer.backgroundSkin = backgroundSkin;
		}
		
		/**
		 * @private 
		 */
		protected function setToggleButtonArrowtyles(toggleButton:Object):void
		{
			this.setTabStyles(toggleButton as ToggleButton);
			toggleButton.toggleArrowBottom = this.atlas.getTexture("callout-arrow-bottom-skin0000"); 
			toggleButton.toggleArrowUp = this.atlas.getTexture("callout-arrow-top-skin0000");
		}
	}
}