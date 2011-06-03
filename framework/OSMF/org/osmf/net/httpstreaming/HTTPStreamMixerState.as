/*****************************************************
 *  
 *  Copyright 2011 Adobe Systems Incorporated.  All Rights Reserved.
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
 *  Portions created by Adobe Systems Incorporated are Copyright (C) 2011 Adobe Systems 
 *  Incorporated. All Rights Reserved. 
 *  
 *****************************************************/
package org.osmf.net.httpstreaming
{
	[ExcludeClass]
	
	/**
	 * @private
	 * 
	 * Enumeration of the states an HTTPStreamMixer cycles through.
	 */ 
	public class HTTPStreamMixerState
	{
		public static const INIT:String = "init";
		public static const INIT_DEFAULT:String = "initDefault";
		public static const INIT_AUDIO:String = "initAudio";
		public static const SEEK:String = "seek";
		public static const CONSUME_BUFFERED:String = "consumeBuffered";
		public static const CONSUME_DEFAULT:String = "consumeDefault";
		public static const CONSUME_MIXED:String = "consumeMixed";
	}
}