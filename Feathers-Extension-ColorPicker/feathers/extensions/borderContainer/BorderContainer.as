/*
Copyright 2018 pol2095. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package feathers.extensions.borderContainer
{
	import feathers.controls.LayoutGroup;
	import feathers.skins.IStyleProvider;

	public class BorderContainer extends LayoutGroup
	{
		/**
		 * The default <code>IStyleProvider</code> for all <code>BorderContainer</code>
		 * components.
		 *
		 * @default null
		 * @see feathers.core.FeathersControl#styleProvider
		 */
		public static var globalStyleProvider:IStyleProvider;

		/**
		 * Constructor.
		 */
		public function BorderContainer()
		{
			super();
		}

		/**
		 * @private
		 */
		override protected function get defaultStyleProvider():IStyleProvider
		{
			return BorderContainer.globalStyleProvider;
		}
	}
}
