/*************************************************************************
* 
*  Copyright (c) 2009, openvideoplayer.org
*  All rights reserved.
*  
*  Redistribution and use in source and binary forms, with or without 
*  modification, are permitted provided that the following conditions are 
*  met:
*  
*     * Redistributions of source code must retain the above copyright 
*  		notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above 
*  		copyright notice, this list of conditions and the following 
*  		disclaimer in the documentation and/or other materials provided 
*  		with the distribution.
*     * Neither the name of the openvideoplayer.org nor the names of its 
*  		contributors may be used to endorse or promote products derived 
*  		from this software without specific prior written permission.
*  
*  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
*  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
*  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
*  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
*  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
*  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
*  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
*  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
*  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
*  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
*  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**************************************************************************/
package org.openvideoplayer.media
{
	import org.openvideoplayer.events.TraitsChangeEvent;
	import org.openvideoplayer.traits.MediaTraitType;
	import org.openvideoplayer.utils.MediaFrameworkStrings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	import flash.utils.Dictionary;

	/**
	 * Dispatched when an IMediaTrait is added to the media element.
	 *
	 * @eventType org.openvideoplayer.events.MediaTraitEvent.TRAIT_ADD
	 **/
	[Event(name="traitAdd",type="org.openvideoplayer.events.TraitsChangeEvent")]
	
	/**
	 * Dispatched when an IMediaTrait is removed from the media element.
	 *
	 * @eventType org.openvideoplayer.events.MediaTraitEvent.TRAIT_REMOVE
	 **/
	[Event(name="traitRemove",type="org.openvideoplayer.events.TraitsChangeEvent")]
		
	/**
     * A MediaElement represents a unified media experience.
     * It may consist of a simple media item, such as a video or a sound.
     * Different instances (or subclasses) can represent different types of media.
     * A MediaElement may also represent a complex media experience composed of 
     * multiple items, such as videos, ad banners, SWF overlays, background page branding, etc.
	 * 
     * <p>Programmatically, a media element encapsulates a set of media traits and
     * a state space.
	 * The media traits
	 * represent the capabilities of the media element and are dynamic in
	 * nature.  At one moment in time a media element might be
	 * seekable, at another moment it might not be. For example, this could occur 
     * if the media element is a video sequence containing unskippable ads.</p>
	 * <p>A media element operates on a media resource.  For example, if the
	 * media element represents a video player, the media resource might
	 * encapsulate a URL to a video stream.
     * If the media element represents a complex media composition, 
     * the media resource URL might be a document that references
     * the multiple resources used in the media composition.</p>
     * @see IMediaTrait
     * @see IMediaResource
	 */
	public class MediaElement extends EventDispatcher
	{
		// Public interface
		//
		
		/**
		 * Constructor.
		 **/
		public function MediaElement()
		{			
			setupTraits();
		}
	
		/**
		 * An array of MediaTraitTypes representing the trait types on this
		 * media element.
		 **/
		public function get traitTypes():Array
		{
			// Return a copy of our types array:
			return _traitTypes.concat();
		}
		
		/**
		 * Determines whether this media element has a media trait of the
		 * specified type.
		 * 
         * @param type The Class of the media trait to check for.
		 * 
		 * @throws ArgumentError If the parameter is <code>null</code>.
		 * @return <code>true</code> if this media element has a media
		 * trait of the specified class, <code>false</code> otherwise.
		 **/
		public function hasTrait(type:MediaTraitType):Boolean
		{
			if (type == null)
			{
				throw new ArgumentError(MediaFrameworkStrings.INVALID_PARAM);
			}
			
			return _traits[type] != null;
		}
		
		/**
		 * Returns the media trait of the specified type.
		 * 
         * @param type The Class of the media trait to return.
		 * 
         * @throws ArgumentError If the parameter is <code>null</code>.
         * @return The retrieved trait or <code>null</code> if no such trait exists on this
		 * media element.
		 **/
		public function getTrait(type:MediaTraitType):IMediaTrait
		{
			if (type == null)
			{
				throw new ArgumentError(MediaFrameworkStrings.INVALID_PARAM);
			}

			return _traits[type];
		}
		
		/**
         * Initializes this media element with the specified arguments.  The
		 * arguments are of type Object.  Each media element subclass has an
		 * implicit contract as to the number of arguments and the specific
		 * type of each argument. 
		 * 
		 * <p>This method allows for the creation of a MediaElement by a
		 * factory class.  Typically, a factory constructs an instance of
		 * the MediaElement (using the default constructor) and then calls
		 * this method with the parameters that would normally be passed to
		 * the constructor.</p>
		 * 
		 * <p>Dynamic instantiation of this nature can be useful when the code
		 * that creates an instance of a class has no <i>a priori</i> knowledge
		 * of the constructor arguments and types.  For example, suppose class
         * Foo extends MediaElement and has the following constructor:</p>
         * <listing>
         * public function Foo(arg1:String,arg2:Number):void
         * {
         *     //...
         * }
         * </listing>
		 * 
         * A factory class could create an instance of Foo like this:
         * <listing>
         * // This method retrieves the Class to instantiate from an
         * // external source.  Let's assume it returns class Foo.
         * var classType():Class = getClassFromDescriptor();
         * 
         * // This method retrieves the arguments from an external source.
         * // Let's assume it returns ["some text",3.14].
         * var args:Array = getArgsFromDescriptor();
         * 
         * var mediaElement:MediaElement = new classType();
         * mediaElement.initialize(args);
         * </listing>
		 * @param args An array of initialization arguments.  Each implementing
		 * class has an implicit contract as to the number of arguments
		 * and the specific type of each argument. 
		 * 
		 * @throws ArgumentError The wrong number of arguments or the wrong
		 * argument types were passed in.
		 * 
		 * TODO: Make this internal?
		 **/
		public function initialize(value:Array):void
		{
			// Subclasses can override to do their own initialization.
			if (value.length > 0)
			{
				throw new ArgumentError(MediaFrameworkStrings.INVALID_INITIALIZATION_ARGS);
			}
		}
		
		/**
		 * The media resource that this media element operates on.
		 **/
		public function get resource():IMediaResource
		{
			return _resource;
		}
		
		public function set resource(value:IMediaResource):void
		{
			_resource = value;
		}
				
		// Protected
		//
		
		/**
		 * Adds a new media trait to this media element.  If successful,
		 * dispatches a MediaTraitEvent.
		 * 
         * @param type The type of media trait to add.
		 * @param trait The media trait to add.
		 * 
         * @throws ArgumentError If either parameter is <code>null</code>, or
		 * if the specified type and the type of the media trait don't match,
		 * or if a different instance of the specific trait class has already
		 * been added.
		 **/
		protected function addTrait(type:MediaTraitType, instance:IMediaTrait):void
		{
			if (type == null || instance == null || !(instance is type.traitInterface))
			{
				throw new ArgumentError(MediaFrameworkStrings.INVALID_PARAM);
			}
			
			var result:IMediaTrait = _traits[type];
			
			if (result == null)
			{
				_traits[type] = result = instance;
				_traitTypes.push(type);
				
				// Signal addition:
				dispatchEvent(new TraitsChangeEvent(TraitsChangeEvent.TRAIT_ADD, type));
			}
			else if (result != instance)
			{
				throw new ArgumentError(MediaFrameworkStrings.TRAIT_INSTANCE_ALREADY_ADDED);
			}
		}
		
		/**
		 * Removes a media trait from this media element.  If successful,
		 * dispatches a MediaTraitEvent.
		 * 
         * @param type The Class of the media trait to remove.
		 * 
         * @throws ArgumentError If the parameter is <code>null</code>.
         * @return The removed trait or <code>null</code> if no trait was
         * removed.
		 **/
		protected function removeTrait(type:MediaTraitType):IMediaTrait
		{
			if (type == null)
			{
				throw new ArgumentError(MediaFrameworkStrings.INVALID_PARAM);
			}

			var result:IMediaTrait = _traits[type];
			
			if (result != null)
			{
				// Signal removal is about to occur:
				dispatchEvent(new TraitsChangeEvent(TraitsChangeEvent.TRAIT_REMOVE, type));
				
				_traitTypes.splice(_traitTypes.indexOf(type),1);
				delete _traits[type];
			}
			
			return result;
		}
		
		/**
		 * Sets up the traits for this media element.  Occurs during
		 * construction.  Subclasses should override this method and call
		 * addTrait for each trait of their own.
		 **/
		protected function setupTraits():void
		{
		}		

		// Internals
		//

		private var _traitTypes:Array = [];
		private var _traits:Dictionary = new Dictionary();
		private var _resource:IMediaResource;
	}
}