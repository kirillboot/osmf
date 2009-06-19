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
package org.openvideoplayer.traits
{
	import org.openvideoplayer.events.MutedChangeEvent;
	import org.openvideoplayer.events.PanChangeEvent;
	import org.openvideoplayer.events.VolumeChangeEvent;
	
	/**
	 * Dispatched when the trait's <code>volume</code> property has changed.
	 * 
	 * @eventType org.openvideoplayer.events.VolumeChangeEvent.VOLUME_CHANGE
	 */	
	[Event(name="volumeChange",type="org.openvideoplayer.events.VolumeChangeEvent")]
	
	/**
  	 * Dispatched when the trait's <code>muted</code> property has changed.
  	 * 
  	 * @eventType org.openvideoplayer.events.MutedChangeEvent.MUTED_CHANGE
	 */	
	[Event(name="mutedChange",type="org.openvideoplayer.events.MutedChangeEvent")]
	
	/**
 	 * Dispatched when the trait's <code>pan</code> property has changed.
 	 * 
 	 * @eventType org.openvideoplayer.events.PanChangeEvent.PAN_CHANGE 
	 */	
	[Event(name="panChange",type="org.openvideoplayer.events.PanChangeEvent")]
	
	/**
	 * The AudibleTrait class provides a base IAudible implementation.
	 * It can be used as the base class for a more specific audible trait
	 * subclass or as is by a media element that listens for and handles
	 * its change events.
	 * 
	 */	
	public class AudibleTrait extends MediaTraitBase implements IAudible
	{
		// IAudible
		//
		
		/**
		 * @inheritDoc
		 */		
		public function get volume():Number
		{
			return _volume;
		}
		
		/**
		 * @inheritDoc
		 */		
		final public function set volume(value:Number):void
		{
			// Coerce the value into our range:
			if (isNaN(value))
			{
				value = 0;
			}
			else if (value > 1)
			{
				value = 1;
			}
			else if (value < 0)
			{
				value = 0;
			}
			
			if (value != _volume)
			{
				if (canProcessVolumeChange(value))
				{
					processVolumeChange(value);
					
					var oldVolume:Number = _volume;
					_volume = value;
					
					postProcessVolumeChange(oldVolume);
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */		
		public function get muted():Boolean
		{
			return _muted;
		}
		
		/**
		 * Indicates whether the AudibleTrait is muted or sounding.
		 */
		final public function set muted(value:Boolean):void
		{
			if (_muted != value)
			{
				if (canProcessMutedChange(value))
				{
					processMutedChange(value);
					
					_muted = value;
					
					postProcessMutedChange(!_muted);
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function get pan():Number
		{
			return _pan;
		}
		
		/**
		 * @inheritDoc
		 */
		final public function set pan(value:Number):void
		{
			// Coerce the value into our range:
			if (isNaN(value))
			{
				value = 0;
			}
			else if (value > 1)
			{
				value = 1;
			}
			else if (value < -1)
			{
				value = -1;
			}
			
			if (_pan != value)
			{
				if (canProcessPanChange(value))
				{
					processPanChange(value);
					
					var oldPan:Number = _pan;
					_pan = value;
					
					postProcessPanChange(oldPan);
				}
			}
		}
	
		// Internals
		//
		
		private var _volume:Number = 1;
		private var _muted:Boolean = false;
		private var _pan:Number = 0;
		
		/**
		 * Called before the <code>volume</code> property is changed.
		 * @param newVolume Proposed new <code>volume</code> value.
		 * @return Returns <code>true</code> by default. Subclasses that override this method
		 * can return <code>false</code> to abort the change.
		 * 
		 */		
		protected function canProcessVolumeChange(newVolume:Number):Boolean
		{
			return true;
		}
		
		/**
		 * Called immediately before the <code>volume</code> value is changed.
		 * <p>Subclasses implement this method to communicate the change to the media.</p>
		 * @param newVolume New <code>volume</code> value.
		 * 
		 */
		protected function processVolumeChange(newVolume:Number):void
		{
		} 
		
		/**
		 * Called just after the <code>volume</code> value has changed.
		 * Dispatches the change event.
		 * <p>Subclasses that override should call this method 
		 * to dispatch the volumeChange event.</p> 
		 * @param oldVolume Previous <code>volume</code> value.
		 * 
		 */		
		protected function postProcessVolumeChange(oldVolume:Number):void
		{
			dispatchEvent(new VolumeChangeEvent(oldVolume,_volume));
		}
		
		/**
		 * Called before the <code>muted</code> property is toggled.
		 * @param newMuted Proposed new <code>muted</code> value.
		 * @return Returns <code>true</code> by default. Subclasses that override this method
		 * can return <code>false</code> to abort the change.
		 * 
		 */		
		protected function canProcessMutedChange(newMuted:Boolean):Boolean
		{
			return true;
		}
		
		/**
		 * Called immediately before the <code>muted</code> value is toggled. 
		 * <p>Subclasses implement this method to communicate the change to the media.</p>
		 * @param newMuted New <code>muted</code> value.
		 */		
		protected function processMutedChange(newMuted:Boolean):void
		{
		}
		
		/**
		 * Called just after the <code>muted</code> property has been toggled.
		 * Dispatches the change event.
		 * <p>Subclasses that override should call this method 
		 * to dispatch the mutedChange event.</p>
		 * @param oldMuted Previous <code>muted</code> value.
		 * 
		 */		
		protected function postProcessMutedChange(oldMuted:Boolean):void
		{
			dispatchEvent(new MutedChangeEvent(_muted));
		}
		
		/**
		 * Called before the <code>pan</code> property is changed.
		 * @param newPan Proposed new <code>pan</code> value.
		 * @return Returns <code>true</code> by default. Subclasses that override this method
		 * can return <code>false</code> in order to abort the change.
		 * 
		 */		
		protected function canProcessPanChange(newPan:Number):Boolean
		{
			return true;
		}
		
		/**
		 * Called immediately before the <code>pan</code> value is changed.
		 * <p>Subclasses implement this method to communicate the change to the media.</p>
		 * @param newPan New <code>pan</code> value.
		 */		
		protected function processPanChange(newPan:Number):void
		{	
		}
		
		/**
		 * Called just after the <code>pan</code> value has changed.
		 * Dispatches the change event.
		 * <p>Subclasses that override should call this method 
		 * to dispatch the panChange event.</p>
		 * @param oldPan Previous <code>pan</code> value.
		 * 
		 */		
		protected function postProcessPanChange(oldPan:Number):void
		{
			dispatchEvent(new PanChangeEvent(oldPan,_pan));
		}
	}
}