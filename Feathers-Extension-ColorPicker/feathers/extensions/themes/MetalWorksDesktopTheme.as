/*
Copyright 2018 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.extensions.themes
{
	import feathers.controls.Button;
	import feathers.controls.ToggleButton;
	import feathers.themes.MetalWorksDesktopTheme;
	import flash.system.ApplicationDomain;
	import flash.utils.getDefinitionByName;
	import starling.display.Image;
	import starling.textures.Texture;
 
	public class MetalWorksDesktopTheme extends feathers.themes.MetalWorksDesktopTheme
	{
		private var classes:Vector.<String> = new <String>[
			"feathers.extensions.dataGrid.DataGridToggleButton",
			"feathers.extensions.borderContainer.BorderContainer",
			"feathers.extensions.borderContainer.BorderScrollContainer",
			"feathers.extensions.color.components.SliderButton"
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
						this.getStyleProviderForClass( getDefinitionByName( classes[i] ) as Class ).setFunctionForStyleName("toggleButton-arrow", this.setToggleButtonArrowStyles);
					}
					else if( i == 1 )
					{
						this.getStyleProviderForClass( getDefinitionByName( classes[i] ) as Class ).defaultStyleFunction = this.setBorderContainerStyles;
					}
					else if( i == 2 )
					{
						this.getStyleProviderForClass( getDefinitionByName( classes[i] ) as Class ).defaultStyleFunction = this.setBorderScrollContainerStyles;
					}
					else if( i == 3 )
					{
						this.getStyleProviderForClass( getDefinitionByName( classes[i] ) as Class ).defaultStyleFunction = this.setSliderButtonStyles;
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
		protected function setBorderScrollContainerStyles(borderScrollContainer:Object):void
		{
			var backgroundSkin:Image = new Image(this.backgroundPopUpSkinTexture);
			backgroundSkin.scale9Grid = SIMPLE_SCALE9_GRID;
			borderScrollContainer.backgroundSkin = backgroundSkin;
		}
		
		/**
		 * @private 
		 */
		protected function setToggleButtonArrowStyles(toggleButton:Object):void
		{
			this.setTabStyles(toggleButton as ToggleButton);
			toggleButton.toggleArrowBottom = this.atlas.getTexture("callout-arrow-bottom-skin0000"); 
			toggleButton.toggleArrowUp = this.atlas.getTexture("callout-arrow-top-skin0000");
		}
		
		/**
		 * @private 
		 */
		protected function setSliderButtonStyles(button:Object):void
		{
			this.setButtonStyles(button as Button);
			//button.defaultIcon = new Image( texture );
			var texture:Texture = this.atlas.getTexture("danger-callout-arrow-left-skin0000")
			button.disabledSkin = new Image( texture );
			button.defaultSkin = new Image( texture );
			button.downSkin = new Image( texture );
		}
	}
}