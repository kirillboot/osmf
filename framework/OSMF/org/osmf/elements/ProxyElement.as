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
package org.osmf.elements
{
	import __AS3__.vec.Vector;
	
	import org.osmf.events.ContainerChangeEvent;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaResourceBase;
	import org.osmf.metadata.Metadata;
	import org.osmf.traits.MediaTraitBase;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.utils.OSMFStrings;
	
	/**
	 * A ProxyElement acts as a wrapper for another MediaElement.
	 * Its purpose is to control access to the wrapped element.
	 * <p>ProxyElement is not instantiated directly but rather used
	 * as the base class for creating wrappers for specific purposes. 
	 * ProxyElement can be subclassed for any trait type or set of trait types.
	 * The subclass controls access to the wrapped element either by overriding
	 * one or more of the wrapped element's traits or by blocking them.</p>
	 * <p>To override any of the wrapped element's traits, 
	 * the subclass creates its own trait instances,
	 * which it substitutes for the wrapped element's traits that it wishes to override.
	 * It uses the ProxyElement's <code>setupOverriddenTraits()</code> method to arrange for
	 * the wrapped element's traits to be overridden.</p>
	 * <p>To block traits, the subclass prevents the traits of
	 * the wrapped element from being exposed by setting the ProxyElement's
	 * <code>blockedTraits</code> property for the trait
	 * types that it wants to block.
	 * This causes the wrapped element's <code>hasTrait()</code>
	 * method to return <code>false</code> and its
	 * <code>getTrait()</code> method to return <code>null</code>
	 * for the blocked trait types.</p>
	 * <p>A ProxyElement normally dispatches the wrapped element's
	 * MediaElementEvents, unless its the trait's type is among those that
	 * are blocked by the ProxyElement.</p>
	 * <p>ProxyElement subclasses are useful for modifying the behavior of a
	 * MediaElement in a non-invasive way.  
	 * An example would be adding
	 * temporal capabilities to a set of ImageElements to present them in a slide show
	 * in which the images are displayed for a specified duration.
	 * The ProxyElement subclass would wrap the non-temporal ImageElements
	 * and override the wrapped element's TimeTrait to return a custom
	 * instance of that trait.
	 * A similar approach can be applied to other traits, either to provide an 
	 * alternate implementation of some of the wrapped element's underlying traits,
	 * to provide an implementation when a needed underlying trait does not exist,
	 * or to prevent an underlying trait from being exposed at all.</p>
	 * @see DurationElement
	 * @see org.osmf.events.MediaElementEvent
	 * @see org.osmf.traits
	 *  
	 *  @langversion 3.0
	 *  @playerversion Flash 10
	 *  @playerversion AIR 1.5
	 *  @productversion OSMF 1.0
	 */
	public class ProxyElement extends MediaElement
	{
		/**
		 * Constructor.
		 * 
		 * @param proxiedElement MediaElement to proxy.  Changes to the proxied
		 * element are reflected in the proxy element's properties and events,
		 * with the exception of those changes for which an override takes
		 * precedence.  If the param is null, then it must be set (via the
		 * proxiedElement setter) immediately after this constructor call, and
		 * before any other methods on this ProxyElement are called, or an
		 * IllegalOperationError will be thrown.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function ProxyElement(proxiedElement:MediaElement=null)
		{
			super();
			
			this.proxiedElement = proxiedElement;
		}
		
		/**
		 * The MediaElement for which this ProxyElement serves as a proxy,
		 * or wrapper.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		public function set proxiedElement(value:MediaElement):void
		{
			var traitType:String;
			
			if (value != _proxiedElement)
			{
				if (_proxiedElement != null)
				{
					// Clear the listeners for the old wrapped element.
					toggleMediaElementListeners(_proxiedElement, false);

					// The wrapped element is changing, signal trait removal
					// for all traits.
					for each (traitType in _proxiedElement.traitTypes)
					{
						super.dispatchEvent(new MediaElementEvent(MediaElementEvent.TRAIT_REMOVE, false, false, traitType));
					}
					
					// All traits that were overridden on the proxy must be
					// removed.
					removeOverriddenTraits();
				}
				
				_proxiedElement = value;
				
				if (_proxiedElement != null)
				{
					// Add listeners for the new wrapped element, so that
					// events from the wrapped element are also dispatched by
					// the proxy.
					toggleMediaElementListeners(_proxiedElement, true);
					
					// Set up the traits for the proxy, now that we're prepared
					// to respond to change events.  (Note that this class's
					// setupTraits prevents a call to the base class.)
					setupOverriddenTraits();
					
					// The wrapped element has changed, signal trait addition
					// for all traits.
					for each (traitType in _proxiedElement.traitTypes)
					{
						super.dispatchEvent(new MediaElementEvent(MediaElementEvent.TRAIT_ADD, false, false, traitType));
					}
				}
			}
		}
		
		public function get proxiedElement():MediaElement
		{
			return _proxiedElement;
		}
		
		/**
		 * @private
		 */
		override public function get traitTypes():Vector.<String>
		{
			var results:Vector.<String> = new Vector.<String>();
			
			// Only return the traits reflected by the proxy. 
			for each (var traitType:String in MediaTraitType.ALL_TYPES)
			{
				if (hasTrait(traitType))
				{
					results.push(traitType);
				}
			}
			
			return results;
		}

		/**
		 * @private
		 */
		override public function hasTrait(type:String):Boolean
		{
			if (type == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}
			
			return getTrait(type) != null;
		}
		
		/**
		 * @private
		 */
		override public function getTrait(type:String):MediaTraitBase
		{
			if (type == null)
			{
				throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
			}

			var trait:MediaTraitBase = null;
			
			// Don't return the trait if it's blocked.
			if (blocksTrait(type) == false)
			{				
				// Give precedence to a trait on the proxy.
				trait = super.getTrait(type) ||	(proxiedElement != null ? proxiedElement.getTrait(type) : null);
			}
			
			return trait;
		}
		
		/**
		 * @private
		 */
		override public function get resource():MediaResourceBase
		{		
			return proxiedElement ? proxiedElement.resource : null;
		}
		
		/**
		 * @private
		 */		
		override public function set resource(value:MediaResourceBase):void
		{	
			if (proxiedElement != null)
			{
				proxiedElement.resource = value;
			}
		}
		
		override protected function addTrait(type:String, instance:MediaTraitBase):void
		{
			// If we're adding a trait that already exists on the proxied
			// element (and isn't blocked), then we need to signal removal
			// of the base trait first.
			if (	blocksTrait(type) == false
				&&	proxiedElement != null
				&& 	proxiedElement.hasTrait(type) == true
			   )
			{
				super.dispatchEvent(new MediaElementEvent(MediaElementEvent.TRAIT_REMOVE, false, false, type));
			}
			
			super.addTrait(type, instance);
		}

		override protected function removeTrait(type:String):MediaTraitBase
		{
			var result:MediaTraitBase = super.removeTrait(type);
			
			// If we're removing a trait that also exists on the proxied
			// element (and isn't blocked), then we need to signal addition
			// of the base trait immediately after the removal.
			if (	blocksTrait(type) == false
				&&	proxiedElement != null
				&& 	proxiedElement.hasTrait(type) == true
			   )
			{
				super.dispatchEvent(new MediaElementEvent(MediaElementEvent.TRAIT_ADD, false, false, type));
			}
			
			return result;
		}
		
		/**
		 * @private
		 */
		override public function get metadata():Metadata
		{
			return proxiedElement ? proxiedElement.metadata : null;
		}
		
		/**
		 * @private
		 * 
		 * Don't create any metadata, since we will be using the wrapped element's data only.
		 */
		override protected function createMetadata():Metadata
		{
			return null;
		}

		/**
		 * @private
		 * 
		 * Sets up overridden traits and finalizes them to ensure a consistent initialization
		 * process.  Clients should subclass <code>setupOverriddenTraits()</code>
		 * instead of this method.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		final override protected function setupTraits():void
		{
		}
		
		/**
		 * @private
		 * 
		 * TODO: Figure out if we can do away with this in some other way.
		 * Temporarily marked as private.
		 * 
		 * Sets up the traits for this proxy.  The proxy's traits will always
		 * override (i.e. take precedence over) the traits of the wrapped
		 * element.
		 * 
		 * Subclasses can override this method to set up their own traits.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 */
		protected function setupOverriddenTraits():void
		{
			super.setupTraits();
		}
		
		/**
		 * The set of MediaTraitTypes that this ProxyElement will block.  When a trait
		 * is blocked, the ProxyElement will prevent that trait from being exposed when
		 * the proxied element contains the trait and the proxy does not.
		 * 
		 * Subclasses can call this to selectively block access to the traits of the
		 * proxied element on a per-type basis.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion OSMF 1.0
		 **/
		protected final function get blockedTraits():Vector.<String>
		{
			if (_blockedTraits == null)
			{
				_blockedTraits = new Vector.<String>();
			}
			
			return _blockedTraits;
		}
		
		protected final function set blockedTraits(value:Vector.<String>):void
		{
			if (value == _blockedTraits) return;
			
			var newlyBlockedTraitTypes:Array = [];
			var previouslyBlockedTraitTypes:Array = [];
			var traitType:String;
			
			// If we already have a proxied element, then setting a new
			// set of blocked traits might unblock certain traits or block
			// others.  So we need to determine which traits are now being
			// blocked or unblocked.
			if (_proxiedElement != null)
			{
				for each (traitType in MediaTraitType.ALL_TYPES)
				{
					// If it's in the list of new traits...
					if (value.indexOf(traitType) != -1)
					{
						// ... and not in the list of old traits...
						if (_blockedTraits == null || _blockedTraits.indexOf(traitType) == -1)
						{
							// ... add to our list of newly blocked traits.
							newlyBlockedTraitTypes.push(traitType);
						}
					}
					else
					{
						// It's not in the list of new traits.
						//
						
						// If it's in the list of old traits...
						if (_blockedTraits != null && _blockedTraits.indexOf(traitType) != -1)
						{
							// ... add to our list of previously blocked traits.
							previouslyBlockedTraitTypes.push(traitType);
						}
					}
				}
			}
			
			_blockedTraits = value;
			
			if (_proxiedElement != null)
			{
				// For each newly blocked trait that the proxied element is currently
				// exposing, signal removal of the old trait.
				for each (traitType in newlyBlockedTraitTypes)
				{
					if (proxiedElement.hasTrait(traitType) || super.hasTrait(traitType))
					{
						super.dispatchEvent(new MediaElementEvent(MediaElementEvent.TRAIT_REMOVE, false, false, traitType));
					}
				}

				// For each previously blocked trait that the proxied element is
				// currently exposing, signal addition of the new trait.
				for each (traitType in previouslyBlockedTraitTypes)
				{
					if (proxiedElement.hasTrait(traitType) || super.hasTrait(traitType))
					{
						super.dispatchEvent(new MediaElementEvent(MediaElementEvent.TRAIT_ADD, false, false, traitType));
					}
				}
			}
		}
		
		// Internals
		//
		
		private function removeOverriddenTraits():void
		{				
			var overriddenTraitTypes:Vector.<String> = super.traitTypes;
			for each (var traitType:String in overriddenTraitTypes)
			{
				removeTrait(traitType);
			}
		}
		
		private function toggleMediaElementListeners(mediaElement:MediaElement, add:Boolean):void
		{
			if (add)
			{
				_proxiedElement.addEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);
				_proxiedElement.addEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
				_proxiedElement.addEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
				_proxiedElement.addEventListener(MediaElementEvent.METADATA_ADD, onMetadataEvent);
				_proxiedElement.addEventListener(MediaElementEvent.METADATA_REMOVE, onMetadataEvent);
				_proxiedElement.addEventListener(ContainerChangeEvent.CONTAINER_CHANGE, onContainerChange);
			}
			else
			{
				_proxiedElement.removeEventListener(MediaErrorEvent.MEDIA_ERROR, onMediaError);
				_proxiedElement.removeEventListener(MediaElementEvent.TRAIT_ADD, onTraitAdd);
				_proxiedElement.removeEventListener(MediaElementEvent.TRAIT_REMOVE, onTraitRemove);
				_proxiedElement.removeEventListener(MediaElementEvent.METADATA_ADD, onMetadataEvent);
				_proxiedElement.removeEventListener(MediaElementEvent.METADATA_REMOVE, onMetadataEvent);
				_proxiedElement.removeEventListener(ContainerChangeEvent.CONTAINER_CHANGE, onContainerChange);
			}
		}
		
		private function onMediaError(event:MediaErrorEvent):void
		{
			dispatchEvent(event.clone());
		}
		
		private function onTraitAdd(event:MediaElementEvent):void
		{
			processTraitsChangeEvent(event);
		}

		private function onTraitRemove(event:MediaElementEvent):void
		{
			processTraitsChangeEvent(event);
		}

		private function onMetadataEvent(event:MediaElementEvent):void
		{
			dispatchEvent(event.clone());
		}
		
		private function onContainerChange(event:ContainerChangeEvent):void
		{
			dispatchEvent(event.clone());
		}
		
		private function processTraitsChangeEvent(event:MediaElementEvent):void
		{
			// We only redispatch the event if the change is for a non-blocked,
			// non-overridden trait.
			if	(	blocksTrait(event.traitType) == false
				&&	super.hasTrait(event.traitType) == false
				)
			{
				super.dispatchEvent(event.clone());
			}
		}
		
		private function blocksTrait(traitType:String):Boolean
		{
			return _blockedTraits && _blockedTraits.indexOf(traitType) != -1;
		}
		
		private var _proxiedElement:MediaElement;
		private var _blockedTraits:Vector.<String>;
	}
}