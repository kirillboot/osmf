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
package
{
	import flash.display.Sprite;
	
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.URLResource;
	import org.osmf.net.NetLoader;
	import org.osmf.utils.URL;
	import org.osmf.video.VideoElement;

	/**
	 * Variation on HelloWorld, using MediaPlayer + IViewable
	 * rather than MediaPlayerSprite.
	 **/
	[SWF(width="640", height="352")]
	public class HelloWorld5 extends Sprite
	{
		public function HelloWorld5()
		{
			var mediaPlayer:MediaPlayer = new MediaPlayer();
			
			// Set the MediaElement on the MediaPlayer.  Because
			// autoPlay defaults to true, playback begins immediately.
			mediaPlayer.media = new VideoElement
				( new URLResource(new URL(REMOTE_PROGRESSIVE))
				);
				
			if (mediaPlayer.displayObject != null)
			{
				addChild(mediaPlayer.displayObject);
			}
		}
		
		private static const REMOTE_PROGRESSIVE:String
			= "http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv";
	}
}
