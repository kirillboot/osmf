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
package org.openvideoplayer.audio
{
	import flash.media.SoundMixer;
	import flash.net.URLRequest;
	
	import org.openvideoplayer.traits.TestIPausible;
	import org.openvideoplayer.utils.TestConstants;

	public class TestAudioPausibleTrait extends TestIPausible
	{
		override protected function createInterfaceObject(... args):Object
		{
			var url:URLRequest = new URLRequest(TestConstants.LOCAL_SOUND_FILE);
			var soundAdapter:SoundAdapter = new SoundAdapter(url);
			
			// Mute our test file.
			soundAdapter.soundTransform.volume = 0;
			
			return new AudioPausibleTrait(soundAdapter);
		}
		
		override public function tearDown():void
		{
			super.tearDown();
			
			// Kill all sounds.
			SoundMixer.stopAll();
		}
	}
}