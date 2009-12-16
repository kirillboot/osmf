/*****************************************************
*  
*  Copyright 2009 Adobe Systems Incorporated.  All Rights Reserved.
*  
*****************************************************
*  The contents of this file are subject to the Mozilla Public License
*  Version 1.1 (the "License"); you may not use this file except in
*  compliance with the License. You may obtain a copy of the License at
*  http://www.mozilla.org/MPL/
*   
*  Software distributed under the License is distributed on an "AS IS"
*  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
*  License for the specific language governing rights and limitations
*  under the License.
*   
*  
*  The Initial Developer of the Original Code is Adobe Systems Incorporated.
*  Portions created by Adobe Systems Incorporated are Copyright (C) 2009 Adobe Systems 
*  Incorporated. All Rights Reserved. 
*  
*****************************************************/
package org.osmf.composition
{
	import flash.utils.Dictionary;
	
	import org.osmf.events.GatewayChangeEvent;
	import org.osmf.layout.MediaElementLayoutTarget;
	import org.osmf.media.IMediaGateway;
	import org.osmf.media.MediaElement;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.ViewTrait;

	/**
	 * The view property of the composite trait of a parallel composition refers to a
	 * DisplayObjectContainer implementing instance, that holds each of the composition's
	 * view children's DisplayObject.
	 * 
	 * The bounds of the container determine the size of the composition.
	 */	
	internal class ParallelViewTrait extends CompositeViewTrait
	{
		/**
		 * Constructor
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function ParallelViewTrait(traitAggregator:TraitAggregator, owner:MediaElement)
		{
			this.owner = owner as CompositeElement;
			
			super(traitAggregator, owner);
			traitAggregationHelper = new TraitAggregationHelper
				( traitType
				, traitAggregator
				, processAggregatedChild
				, processUnaggregatedChild
				);

			// Add all of our children to the layout renderer:
			for (var i:int = 0; i < this.owner.numChildren; i++)
			{
				var child:MediaElement = this.owner.getChildAt(i);
				
				var target:MediaElementLayoutTarget = MediaElementLayoutTarget.getInstance(child);
				target.addEventListener
					( GatewayChangeEvent.GATEWAY_CHANGE
					, onLayoutTargetGatewayChange
					);
				
				mediaElementLayoutTargets[child] = target;
				
				setupLayoutTarget(target);
			}
		}
		
		// Internals
		//

		private function processAggregatedChild(trait:MediaTraitBase):void
		{
			var child:MediaElement
				= getMediaElementFromViewTrait(trait as ViewTrait);
			
			if (child != null)
			{
				var layoutTarget:MediaElementLayoutTarget = mediaElementLayoutTargets[child];
				
				if (layoutTarget == null)
				{
					var target:MediaElementLayoutTarget = MediaElementLayoutTarget.getInstance(child);
					
					child.addEventListener
						( GatewayChangeEvent.GATEWAY_CHANGE
						, onLayoutTargetGatewayChange
						);
					
					mediaElementLayoutTargets[child] = target;
					
					setupLayoutTarget(target);
				}	
			}
		}
		
		private function processUnaggregatedChild(trait:MediaTraitBase):void
		{
			var child:MediaElement
				= getMediaElementFromViewTrait(trait as ViewTrait);
			
			if (child)
			{
				var target:MediaElementLayoutTarget = mediaElementLayoutTargets[child];
				
				child.removeEventListener
					( GatewayChangeEvent.GATEWAY_CHANGE
					, onLayoutTargetGatewayChange
					);
				
				if (layoutRenderer.targets(target))
				{
					layoutRenderer.removeTarget(target);
				}
				
				delete mediaElementLayoutTargets[child];	
			}
		}
		
		private function getMediaElementFromViewTrait(viewTrait:ViewTrait):MediaElement
		{
			var result:MediaElement;
			
			if (viewTrait != null)
			{
				// Resolve the media-element that this view trait belongs to:
				for (var i:int = 0; i < owner.numChildren; i++)
				{
					result = owner.getChildAt(i);
					if (result.getTrait(MediaTraitType.VIEW) == viewTrait)
					{
						break;
					}
					else
					{
						result = null;
					}
				}
			}
			
			return result;
		}
		
		private function setupLayoutTarget(target:MediaElementLayoutTarget):void
		{
			var gateway:IMediaGateway = target.mediaElement.gateway; 
			var mediaElement:MediaElement = target.mediaElement;
			
			if (gateway && gateway != owner.gateway)
			{
				if (layoutRenderer.targets(target))
				{
					layoutRenderer.removeTarget(target);
				}
			}
			else
			{
				if (layoutRenderer.targets(target) == false)
				{
					layoutRenderer.addTarget(target);
				}
			}
		}
		
		private function onLayoutTargetGatewayChange(event:GatewayChangeEvent):void
		{
			var mediaElement:MediaElement = event.target as MediaElement;
			
			setupLayoutTarget(mediaElementLayoutTargets[event.target]);
		}
		
		private var traitAggregationHelper:TraitAggregationHelper;
		private var mediaElementLayoutTargets:Dictionary = new Dictionary();
		private var owner:CompositeElement;
	}
}