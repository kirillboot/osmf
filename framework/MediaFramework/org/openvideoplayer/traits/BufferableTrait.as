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
	import org.openvideoplayer.events.BufferTimeChangeEvent;
	import org.openvideoplayer.events.BufferingChangeEvent;

	/**
	 * Dispatched when the trait's <code>buffering</code> property has changed.
	 * 
	 * @eventType org.openvideoplayer.events.BufferingChangeEvent.BUFFERING_CHANGE
	 */
	[Event(name="bufferingChange",type="org.openvideoplayer.events.BufferingChangeEvent")]
	
	/**
	 * Dispatched when the trait's <code>bufferTime</code> property has changed.
	 * 
	 * @eventType org.openvideoplayer.events.BufferingChangeEvent.BUFFER_TIME_CHANGE
	 */
	[Event(name="bufferTimeChange",type="org.openvideoplayer.events.BufferTimeChangeEvent")]

	/**
	 * The BufferableTrait class provides a base IBufferable implementation. 
	 * It can be used as the base class for a more specific bufferable trait
	 * subclass or as is by a media element that listens for and handles
	 * its change events.
	 */	
	public class BufferableTrait extends MediaTraitBase implements IBufferable
	{
		// Public interface
		//
		
		/**
		 * Defines the  value of the bufferLength property.
		 * 
		 * <p>This method fires a BufferLengthChangeEvent if the value's
		 * change persists.</p>
		 * 
		 * @see canProcessBufferLengthChange
		 * @see processBufferLengthChange
		 * @see postProcessBufferLengthChange
		 */		
		final public function set bufferLength(value:Number):void
		{
			if (value != _bufferLength)
			{
				if (canProcessBufferLengthChange(value))
				{
					processBufferLengthChange(value);
					
					var oldBufferLength:Number = _bufferLength;
					_bufferLength = value;
					
					postProcessBufferLengthChange(oldBufferLength);
				}
			}
		}
		
		/**
		 * Indicates whether the trait is in a buffering state. Dispatches
		 * a bufferingChange event if invocation results in the <code>buffering</code>
		 * property changing.
		 * 
		 * @see #canProcessBufferingChange()
		 * @see #processBufferingChange()
		 * @see #postProcessBufferingChange()
		 */		
		final public function set buffering(value:Boolean):void
		{
			if (value != _buffering)
			{
				if (canProcessBufferingChange(value))
				{
					processBufferingChange(value);
					
					_buffering = value;
					
					postProcessBufferingChange(!_buffering);
				}
			}
		}
		
		// IBufferable
		//
		
		/**
		 * @inheritDoc
		 **/
		public function get buffering():Boolean
		{
			return _buffering;
		}
		
		/**
		 * @inheritDoc
		 **/
		public function get bufferLength():Number
		{
			return _bufferLength;
		}
		
		/**
		 * @inheritDoc
		 **/
		public function get bufferTime():Number
		{
			return _bufferTime;
		}

		/**
		 * @inheritDoc
		 **/
		final public function set bufferTime(value:Number):void
		{
			// Coerce value into a positive:
			if (isNaN(value) || value < 0)
			{
				value = 0;
			}
			
			if (value != _bufferTime)
			{
				if (canProcessBufferTimeChange(value))
				{
					processBufferTimeChange(value);
					
					var oldBufferTime:Number = _bufferTime;
					_bufferTime = value;
					
					postProcessBufferTimeChange(oldBufferTime); 
				}
			}
		}
		
		// Internals
		//
		
		private var _buffering:Boolean = false;
		private var _bufferLength:Number = 0;
		private var _bufferTime:Number = 0;
		
		/**
		 * Called before buffering is started or stopped.
		 *
		 * @param newBuffering Proposed new <code>buffering</code> value.
		 * @return Returns <code>true</code> by default. 
		 * Subclasses that override this method can return <code>false</code> to
		 * abort processing.
		 *
		 */		
		protected function canProcessBufferingChange(newBuffering:Boolean):Boolean
		{
			return true;
		}
		
		/**
		 * Called immediately before the <code>buffering</code> value is changed.
		 * <p>Subclasses implement this method to communicate the change to the media.</p>
		 *
		 * @param newBuffering New <code>buffering</code> value. 
		 */		
		protected function processBufferingChange(newBuffering:Boolean):void
		{
		}
		
		/**
		 * Called just after <code>buffering</code> has changed.
		 * Dispatches the change event.
		 * <p>Subclasses that override should call this method 
		 * to dispatch the bufferingChange event.</p> 
		 * @param oldBuffering Previous <code>buffering</code> value.
		 *
		 */		
		protected function postProcessBufferingChange(oldBuffering:Boolean):void
		{
			dispatchEvent(new BufferingChangeEvent(_buffering));
		}
		
		/**
		 * Called before the <code>bufferLength</code> value is changed. 
		 * @param newSize Proposed new <code>bufferLength</code> value.
		 * @return Returns <code>true</code> by default. 
		 * Subclasses that override this method can return <code>false</code> to
		 * abort processing.
		 */		
		protected function canProcessBufferLengthChange(newSize:Number):Boolean
		{
			return true;
		}
		
		/**
		 * Called immediately before the <code>bufferLength</code> value is changed. 
		 * Subclasses implement this method to communicate the change to the media.
		 * @param newSize New <code>bufferLength</code> value.
		 */		
		protected function processBufferLengthChange(newSize:Number):void
		{
		}
		
		/**
		 * Called just after the <code>bufferLength</code> value has changed.
		 * @param oldSize Previous  <code>bufferLength</code> value.
		 * 
		 */		
		protected function postProcessBufferLengthChange(oldSize:Number):void
		{	
		}
		
		/**
		 * Called before <code>bufferTime</code> value is changed. 

		 * @param newTime Proposed new <code>bufferTime</code> value.
		 * @return Returns <code>true</code> by default. 
		 * Subclasses that override this method can return <code>false</code> to
		 * abort processing.
		 */		
		protected function canProcessBufferTimeChange(newTime:Number):Boolean
		{
			return true;
		}
		
		/**
		 * Called immediately before the <code>bufferTime</code> value is changed.
		 * Subclasses implement this method to communicate the change to the media. 
		 *
		 * @param newTime New <code>bufferTime</code> value.
		 */		
		protected function processBufferTimeChange(newTime:Number):void
		{
		}
		
		/**
		 * Called just after the <code>bufferTime</code> value has changed.
		 * Dispatches the change event.
		 * <p>Subclasses that override should call this method 
		 * to dispatch the bufferTimeChange event.</p>
		 *  
		 * @param oldTime Previous <code>bufferTime</code> value.
		 * 

		 */		
		protected function postProcessBufferTimeChange(oldTime:Number):void
		{
			dispatchEvent(new BufferTimeChangeEvent(oldTime,_bufferTime));	
		}
	}
}