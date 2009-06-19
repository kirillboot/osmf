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
package org.openvideoplayer.audio
{
	import flash.events.Event;
	import flash.net.NetStream;
	import flash.net.URLRequest;
	
	import org.openvideoplayer.events.PausedChangeEvent;
	import org.openvideoplayer.events.PlayingChangeEvent;
	import org.openvideoplayer.loaders.ILoader;
	import org.openvideoplayer.media.IURLResource;
	import org.openvideoplayer.media.LoadableMediaElement;
	import org.openvideoplayer.media.URLResource;
	import org.openvideoplayer.net.*;
	import org.openvideoplayer.traits.IAudible;
	import org.openvideoplayer.traits.IBufferable;
	import org.openvideoplayer.traits.ILoadable;
	import org.openvideoplayer.traits.ITemporal;
	import org.openvideoplayer.traits.MediaTraitType;
	import org.openvideoplayer.traits.PausibleTrait;
	import org.openvideoplayer.traits.PlayableTrait;
	import org.openvideoplayer.traits.SeekableTrait;

   /** 
	 * AudioElement is a media element specifically created for audio playback.
	 * It supports both streaming and progressive formats.
	 * <p>AudioElement can load and present any MP3 or AAC file.
	 * It supports MP3 files over HTTP, as well as audio-only streams from
	 * Flash Media Server.</p>
     * <p>The AudioElement has IAudible, IBufferable, ILoadable, IPausible, IPlayable, ISeekable,
     * and ITemporal traits.</p>
	 * <p>The basic steps for creating and using an AudioElement are:
	 * <ol>
	 * <li>Create a new IURLResource pointing to the URL of the audio stream or file
	 * containing the sound to be loaded.</li>
	 * <li>Create a new NetLoader.</li>
	 * <li>Create the new AudioElement, 
	 * passing the NetLoader and IURLResource
	 * as parameters.</li>
	 * <li>Get the AudioElement's ILoadable trait using the 
	 * <code>MediaElement.getTrait(LOADABLE)</code> method.</li>
	 * <li>Load the sound using the ILoadable's <code>load()</code> method.</li>
	 * <li>Control the media using the AudioElement's traits, and handle its trait
	 * change events.</li>
	 * <li>When done with the AudioElement, unload the sound using the  
	 * using the ILoadable's <code>unload()</code> method.</li>
	 * </ol>
	 * </p>
	 * 
	 * @see org.openvideoplayer.net.NetLoader
	 * @see org.openvideoplayer.media.IURLResource
	 * @see org.openvideoplayer.media.MediaElement
	 * @see org.openvideoplayer.traits
	 */
	public class AudioElement extends LoadableMediaElement
	{
		/**
		 * Constructor.  
		 * @param loader Loader used to load the sound. Typically this is a
		 * NetLoader.
		 * @param resource URL that points to the sound source that the AudioElement will use.  
		 * @see org.openvideoplayer.net.NetLoader
		 */ 
		public function AudioElement(loader:ILoader=null, resource:IURLResource=null)
		{
			super(loader, resource);
		}
		
		/**
		 *  @private 
		 */ 
		override protected function processLoadedState():void
		{
			var urlResource:URLResource = resource as URLResource;
			var loadable:ILoadable = getTrait(MediaTraitType.LOADABLE) as ILoadable;

			if (urlResource.url.protocol == "rtmp")     // Streaming
			{
				var context:NetLoadedContext = loadable.loadedContext as NetLoadedContext;
				stream = context.stream;
				playable = new NetStreamPlayableTrait(stream, urlResource);
				seekable = new NetStreamSeekableTrait(stream);
				temporal = new NetStreamTemporalTrait(stream);
				pausible = new NetStreamPausibleTrait(stream);
				audible = new NetStreamAudibleTrait(stream);	
				bufferable = new NetStreamBufferableTrait(stream);					
				playable.addEventListener(PlayingChangeEvent.PLAYING_CHANGE, onPlayingChanged);						
				pausible.addEventListener(PausedChangeEvent.PAUSED_CHANGE, onPausedChanged);		
				addTrait(MediaTraitType.BUFFERABLE, bufferable);			
			}
			else    // Progressive
			{
				soundAdapter = new SoundAdapter(new URLRequest(urlResource.url.toString()));
				playable = new AudioPlayableTrait(soundAdapter);
				seekable = new AudioSeekableTrait(soundAdapter);				
				temporal = new AudioTemporalTrait(soundAdapter);
				pausible = new AudioPausibleTrait(soundAdapter);
				audible = new AudioAudibleTrait(soundAdapter);	
				soundAdapter.addEventListener("playbackError", onPlaybackError);				
			}
			seekable.temporal = temporal;		
			
			addTrait(MediaTraitType.PLAYABLE, playable);
			addTrait(MediaTraitType.SEEKABLE, seekable);
			addTrait(MediaTraitType.TEMPORAL, temporal);
			addTrait(MediaTraitType.PAUSIBLE, pausible);
			addTrait(MediaTraitType.AUDIBLE, audible);				
		}	
		
		/**
		 * @private 
		 */ 
		override protected function processUnloadingState():void
		{
			if (soundAdapter)
			{
				soundAdapter.pause();   //Stop
			}
			removeTrait(MediaTraitType.PLAYABLE);
			removeTrait(MediaTraitType.SEEKABLE);
			removeTrait(MediaTraitType.TEMPORAL);
			removeTrait(MediaTraitType.PAUSIBLE);
			removeTrait(MediaTraitType.AUDIBLE);
			
			if (bufferable)  // Streaming
			{
				removeTrait(MediaTraitType.BUFFERABLE);
				bufferable = null;
			}			
			playable.removeEventListener(PlayingChangeEvent.PLAYING_CHANGE, onPlayingChanged);						
			pausible.removeEventListener(PausedChangeEvent.PAUSED_CHANGE, onPausedChanged);	
			playable = null;
			seekable = null;
			temporal = null;
			pausible = null;
			audible = null;	
		}	
		
		private function onPlaybackError(event:Event):void
		{
			//TODO write load handler
		}
					
		/**
		 * Event handler for the Playable trait's playingChange event.
		 **/
		private function onPlayingChanged(event:PlayingChangeEvent):void
		{			
			if (event.playing && pausible.paused)
			{
				pausible.resetPaused();
			}			
		}
		
		/**
		 * Event handler for the Pausible trait's pausedChange event.
		 **/		
		private function onPausedChanged(event:PausedChangeEvent):void
		{			
			if (event.paused && playable.playing)
			{				
				playable.resetPlaying();
			}			
		}
		
		private var bufferable:IBufferable;
		private var playable:PlayableTrait;
		private var seekable:SeekableTrait;
		private var temporal:ITemporal;
		private var pausible:PausibleTrait;
		private var audible:IAudible;
		
		private var soundAdapter:SoundAdapter;
		private var stream:NetStream;
	}
}