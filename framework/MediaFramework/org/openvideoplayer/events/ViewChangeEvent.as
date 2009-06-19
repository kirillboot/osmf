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
package org.openvideoplayer.events
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	/**
	 * A trait that implements the IViewable interface dispatches
	 * this event when its <code>view</code> property has changed.
	 */	
	public class ViewChangeEvent extends TraitEvent
	{
		/**
		 * The ViewChangeEvent.VIEW_CHANGE constant defines the value
		 * of the type property of the event object for a viewChange
		 * event.
		 * 
		 * @eventType PAUSED_CHANGE 
		 */
		public static const VIEW_CHANGE:String = "viewChange";
		
		/**
		 * Constructor.
		 *  
		 * @param oldView Previous view.
		 * @param newView New view.
		 * @param bubbles Specifies whether the event can bubble up the display list hierarchy.
 		 * @param cancelable Specifies whether the behavior associated with the event can be prevented. 
		 */		
		public function ViewChangeEvent(oldView:DisplayObject, newView:DisplayObject, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			_oldView = oldView;
			_newView = newView;
			
			super(VIEW_CHANGE, bubbles, cancelable);
		}
		
		/**
		 * Old value of <code>view</code> before it was changed.
		 */
		public function get oldView():DisplayObject
		{
			return _oldView;
		}
		
		/**
		 * New value of <code>view</code> resulting from this change.
		 */
		public function get newView():DisplayObject
		{
			return _newView;
		}
		
		/**
		 * @private
		 * @inheritDoc
		 */
		override public function clone():Event
		{
			return new ViewChangeEvent(_oldView,_newView,bubbles,cancelable);
		}
		
		// Internals
		//
		
		private var _oldView:DisplayObject;
		private var _newView:DisplayObject;
	}
}