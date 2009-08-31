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
package org.openvideoplayer.examples
{
	import org.openvideoplayer.audio.AudioElement;
	import org.openvideoplayer.audio.SoundLoader;
	import org.openvideoplayer.composition.ParallelElement;
	import org.openvideoplayer.composition.SerialElement;
	import org.openvideoplayer.examples.chromeless.ChromelessPlayerElement;
	import org.openvideoplayer.examples.loaderproxy.VideoProxyElement;
	import org.openvideoplayer.examples.text.TextElement;
	import org.openvideoplayer.examples.traceproxy.TraceProxyElement;
	import org.openvideoplayer.image.ImageElement;
	import org.openvideoplayer.image.ImageLoader;
	import org.openvideoplayer.layout.AbsoluteLayoutFacet;
	import org.openvideoplayer.layout.RelativeLayoutFacet;
	import org.openvideoplayer.media.MediaElement;
	import org.openvideoplayer.media.URLResource;
	import org.openvideoplayer.net.NetLoader;
	import org.openvideoplayer.net.dynamicstreaming.DynamicStreamingItem;
	import org.openvideoplayer.net.dynamicstreaming.DynamicStreamingNetLoader;
	import org.openvideoplayer.net.dynamicstreaming.DynamicStreamingResource;
	import org.openvideoplayer.proxies.TemporalProxyElement;
	import org.openvideoplayer.swf.SWFElement;
	import org.openvideoplayer.swf.SWFLoader;
	import org.openvideoplayer.utils.FMSURL;
	import org.openvideoplayer.utils.URL;
	import org.openvideoplayer.video.VideoElement;
	
	/**
	 * Central repository of all examples for this application.
	 **/
	public class AllExamples
	{
		/**
		 * All examples to be used in the player.
		 **/
		public static function get examples():Array
		{
			var examples:Array = [];
			
			var mediaElement:MediaElement = null;
			
			examples.push
				( new Example
					( 	"Progressive Video"
					, 	"Demonstrates playback of a progressive video using VideoElement and NetLoader."
				  	,  	function():MediaElement
				  	   	{
				  	    	return new VideoElement(new NetLoader(), new URLResource(new URL(REMOTE_PROGRESSIVE)));
				  	   	}
				  	)
				);

			examples.push
				( new Example
					( 	"Streaming Video"
					, 	"Demonstrates playback of a streaming video using VideoElement and NetLoader."
				  	,  	function():MediaElement
				  	   	{
				  	   		return new VideoElement(new NetLoader(), new URLResource(new FMSURL(REMOTE_STREAM)));
				  	   	}
				  	)
				);

			examples.push
				( new Example
					( 	"Dynamic Streaming Video"
					, 	"Demonstrates the use of dynamic streaming.  The player will automatically switch between five variations of the same stream, each encoded at a different bitrate (from 408 Kbps to 1708 Kbps), based on the available bandwidth.  Note that the switching behavior can be modified via custom switching rules."
					, 	function():MediaElement
				  	   	{
							var dsResource:DynamicStreamingResource = new DynamicStreamingResource(new FMSURL(REMOTE_MBR_STREAM_HOST));
							for (var i:int = 0; i < 5; i++)
							{
								dsResource.addItem(MBR_STREAM_ITEMS[i]);
							}
							
				  	   		return new VideoElement(new DynamicStreamingNetLoader(), dsResource)
				  	   	}
					)
				);

			examples.push
				( new Example
					( 	"Image"
					, 	"Demonstrates display of an image using ImageElement and ImageLoader."
				  	,  	function():MediaElement
				  	   	{
							return new ImageElement(new ImageLoader(), new URLResource(new URL(REMOTE_IMAGE)));
				  	   	}
				  	)
				);

			examples.push
				( new Example
					( 	"SWF"
					, 	"Demonstrates display of a SWF using SWFElement and SWFLoader."
				  	,  	function():MediaElement
				  	   	{
							return new SWFElement(new SWFLoader(), new URLResource(new URL(REMOTE_SWF)));
				  	   	}
				  	)
				);

			examples.push
				( new Example
					( 	"Progressive Audio"
					, 	"Demonstrates playback of a progressive audio file using AudioElement and SoundLoader."
				  	,  	function():MediaElement
				  	   	{
							return new AudioElement(new SoundLoader(), new URLResource(new URL(REMOTE_MP3)));
				  	   	}
				  	)
				);

			examples.push
				( new Example
					( 	"Streaming Audio"
					, 	"Demonstrates playback of a streaming audio file using AudioElement and NetLoader."
				  	,  	function():MediaElement
				  	   	{
							return new AudioElement(new NetLoader(), new URLResource(new URL(REMOTE_STREAM)));
				  	   	}
				  	)
				);

			examples.push
				( new Example
					( 	"Invalid Progressive Video"
					, 	"Demonstrates load failures and error handling for a progressive video with an invalid URL."
				  	,  	function():MediaElement
				  	   	{
							return new VideoElement(new NetLoader(), new URLResource(new URL(REMOTE_INVALID_PROGRESSIVE)));
				  	   	}
				  	)
				);

			examples.push
				( new Example
					( 	"Invalid Streaming Video"
					, 	"Demonstrates load failures and error handling for a streaming video with an invalid URL."
				  	,  	function():MediaElement
				  	   	{
							return new VideoElement(new NetLoader(), new URLResource(new FMSURL(REMOTE_INVALID_STREAM)));
				  	   	}
				  	)
				);

			examples.push
				( new Example
					( 	"Invalid Image"
					, 	"Demonstrates load failures and error handling for an image with an invalid URL."
				  	,  	function():MediaElement
				  	   	{
							return new ImageElement(new ImageLoader(), new URLResource(new URL(REMOTE_INVALID_IMAGE)));
				  	   	}
				  	)
				);

			examples.push
				( new Example
					( 	"Invalid Progressive Audio"
					, 	"Demonstrates load failures and error handling for a progressive audio file with an invalid URL."
				  	,  	function():MediaElement
				  	   	{
							return new AudioElement(new SoundLoader(), new URLResource(new URL(REMOTE_INVALID_MP3)));
				  	   	}
				  	)
				);

			examples.push
				( new Example
					( 	"Invalid Streaming Audio"
					, 	"Demonstrates load failures and error handling for a streaming audio file with an invalid URL."
				  	,  	function():MediaElement
				  	   	{
							return new AudioElement(new NetLoader(), new URLResource(new URL(REMOTE_INVALID_STREAM)));
				  	   	}
				  	)
				);

			examples.push
				( new Example
					( 	"Serial Composition"
					, 	"Demonstrates playback of a SerialElement that contains two videos (one progressive, one streaming), using the default layout settings.  Note that the duration of the second video is not incorporated into the SerialElement until its playback begins (because we don't know the duration until it is loaded)."
				  	,  	function():MediaElement
				  	   	{
							var serialElement:SerialElement = new SerialElement();
							serialElement.addChild(new VideoElement(new NetLoader(), new URLResource(new URL(REMOTE_PROGRESSIVE))));
							serialElement.addChild(new VideoElement(new NetLoader(), new URLResource(new FMSURL(REMOTE_STREAM))));
							return serialElement; 
				  	   	} 
				  	)
				);

			examples.push
				( new Example
					( 	"Parallel Composition (Default Layout)"
					, 	"Demonstrates playback of a ParallelElement that contains two videos (one progressive, one streaming), using the default layout settings.  Note that only one video is shown.  This is because both videos use the default layout settings, and thus overlap each other."
				  	,  	function():MediaElement
				  	   	{
							var parallelElement:ParallelElement = new ParallelElement();
							parallelElement.addChild(new VideoElement(new NetLoader(), new URLResource(new URL(REMOTE_PROGRESSIVE))));
							parallelElement.addChild(new VideoElement(new NetLoader(), new URLResource(new FMSURL(REMOTE_STREAM))));
							return parallelElement;
				  	   	}
				  	)
				);

			
			examples.push
				( new Example
					( 	"Parallel Composition (Adjacent)"
					, 	"Demonstrates playback of a ParallelElement that contains two videos (one progressive, one streaming), with the videos laid out adjacently."
				  	,  	function():MediaElement
				  	   	{
							var parallelElement:ParallelElement = new ParallelElement();
							
							var mediaElement1:MediaElement = new VideoElement(new NetLoader(), new URLResource(new URL(REMOTE_PROGRESSIVE)));
							parallelElement.addChild(mediaElement1);
							
							var mediaElement2:MediaElement = new VideoElement(new NetLoader(), new URLResource(new FMSURL(REMOTE_STREAM)));
							parallelElement.addChild(mediaElement2);
							
							applyAdjacentLayout(parallelElement, mediaElement1, mediaElement2);
							
							return parallelElement;
				  	   	} 
				  	)
				);

			examples.push
				( new Example
					( 	"Invalid Serial Composition"
				  	, 	"Demonstrates load failures and error handling for a SerialElement whose second element has an invalid URL."
				  	,  	function():MediaElement
				  	   	{
							var serialElement:SerialElement = new SerialElement();
							serialElement.addChild(new VideoElement(new NetLoader(), new URLResource(new URL(REMOTE_PROGRESSIVE)))); 
							serialElement.addChild(new VideoElement(new NetLoader(), new URLResource(new FMSURL(REMOTE_INVALID_STREAM))));
							return serialElement;
				  	   	} 
				  	)
				);

			examples.push
				( new Example
					( 	"Local Video"
				  	, 	"Demonstrates playback of a local video file."
				  	,  	function():MediaElement
				  	   	{
				  	   		return new VideoElement(new NetLoader(), new URLResource(new URL(LOCAL_PROGRESSIVE)));
				  	   	} 
				  	)
				);

			examples.push
				( new Example
					( 	"Slideshow"
				  	, 	"Demonstrates the use of TemporalProxyElement to present a set of images in sequence."
				  	,  	function():MediaElement
				  	   	{
							var serialElement:SerialElement = new SerialElement();
							serialElement.addChild(new TemporalProxyElement(5, new ImageElement(new ImageLoader(), new URLResource(new URL(REMOTE_SLIDESHOW_IMAGE1)))));
							serialElement.addChild(new TemporalProxyElement(5, new ImageElement(new ImageLoader(), new URLResource(new URL(REMOTE_SLIDESHOW_IMAGE2)))));
							serialElement.addChild(new TemporalProxyElement(5, new ImageElement(new ImageLoader(), new URLResource(new URL(REMOTE_SLIDESHOW_IMAGE3)))));
							
							return serialElement;
				  	   	}
				  	)
				);

			examples.push
				( new Example
					( 	"Text"
					, 	"Demonstrates a custom MediaElement that displays text."
				  	,  	function():MediaElement
				  	   	{
				  	   		return new TextElement("Hello world!"); 
				  	   	}
				  	)
				);

			examples.push
				( new Example
					( 	"Captions"
				  	, 	"Demonstrates the use of TemporalProxyElement to present a set of text elements in sequence."
				  	,  	function():MediaElement
				  	   	{
							var serialElement:SerialElement = new SerialElement();
							serialElement.addChild(new TemporalProxyElement(3, new TextElement("War was Beginning.")));
							serialElement.addChild(new TemporalProxyElement(3, new TextElement("Captain: What happen ?")));
							serialElement.addChild(new TemporalProxyElement(4, new TextElement("Mechanic: Somebody set up us the bomb.")));
							serialElement.addChild(new TemporalProxyElement(3, new TextElement("Operator: We get signal.")));
							serialElement.addChild(new TemporalProxyElement(3, new TextElement("Captain: What !")));
							serialElement.addChild(new TemporalProxyElement(3, new TextElement("Operator: Main screen turn on.")));
							serialElement.addChild(new TemporalProxyElement(3, new TextElement("Captain: It's you !!")));
							serialElement.addChild(new TemporalProxyElement(3, new TextElement("CATS: How are you gentlemen !!")));
							serialElement.addChild(new TemporalProxyElement(5, new TextElement("CATS: All your base are belong to us.")));
							serialElement.addChild(new TemporalProxyElement(5, new TextElement("CATS: You are on the way to destruction.")));
							serialElement.addChild(new TemporalProxyElement(3, new TextElement("Captain: What you say !!")));
							serialElement.addChild(new TemporalProxyElement(4, new TextElement("CATS: You have no chance to survive make your time.")));
							serialElement.addChild(new TemporalProxyElement(3, new TextElement("CATS: Ha ha ha ha ...")));
							serialElement.addChild(new TemporalProxyElement(3, new TextElement("Operator: Captain !!")));
							serialElement.addChild(new TemporalProxyElement(3, new TextElement("Captain: Take off every 'ZIG'!!")));
							serialElement.addChild(new TemporalProxyElement(3, new TextElement("Captain: You know what you doing.")));
							serialElement.addChild(new TemporalProxyElement(3, new TextElement("Captain: Move 'ZIG'.")));
							serialElement.addChild(new TemporalProxyElement(3, new TextElement("Captain: For great justice.")));
							
							return serialElement;
				  	   	}
				  	)
				);

			examples.push
				( new Example
					( 	"Chromeless SWF (AS3)"
					, 	"Demonstrates playback of a chromeless, AS3 SWF.  The SWF exposes an API that a custom MediaElement uses to control the video."
				  	,  	function():MediaElement
				  	   	{
				  	   		return new ChromelessPlayerElement(new SWFLoader(), new URLResource(new URL(CHROMELESS_SWF_AS3)));
				  	   	} 
				  	)
				);

			examples.push
				( new Example
					( 	"Chromeless SWF (Flex)"
					, 	"Demonstrates playback of a chromeless, Flex-based SWF.  The SWF exposes an API that a custom MediaElement uses to control the video.  Note that the SWF also exposes some simple controls for playback (Play, Pause, Mute).  These buttons are included to demonstrate how the loaded SWF and the player can stay in sync."
				  	,  	function():MediaElement
				  	   	{
				  	   		return new ChromelessPlayerElement(new SWFLoader(), new URLResource(new URL(CHROMELESS_SWF_FLEX)));
				  	   	} 
				  	)
				);

			examples.push
				( new Example
					( 	"Video URL Changer"
					, 	"Demonstrates the use of a custom ProxyElement to perform preflight operations on a MediaElement in a non-invasive way.  In this example, the URL of the video is changed during the load operation, so that instead of playing a streaming video, we play a progressive video."
				  	,  	function():MediaElement
				  	   	{
				  	   		return new VideoProxyElement(new VideoElement(new NetLoader(), new URLResource(new FMSURL(REMOTE_STREAM))));
				  	   	} 
				  	)
				);

			examples.push
				( new Example
					( 	"Tracing ProxyElement (Dynamic Streaming Video)"
					, 	"Demonstrates the use of a custom ProxyElement to non-invasively listen in on the behavior of another MediaElement, in this case a VideoElement doing dynamic streaming.  All playback events are sent to the trace console."
					,	function():MediaElement
				  	   	{
							var dsResource:DynamicStreamingResource = new DynamicStreamingResource(new FMSURL(REMOTE_MBR_STREAM_HOST));
							for (var i:int = 0; i < 5; i++)
							{
								dsResource.addItem(MBR_STREAM_ITEMS[i]);
							}
				  	  		return new TraceProxyElement(new VideoElement(new DynamicStreamingNetLoader(), dsResource));
				  	   	}
				  	)
				);

			examples.push
				( new Example
					( 	"Tracing ProxyElement (SerialElement)"
					, 	"Demonstrates the use of a custom ProxyElement to non-invasively listen in on the behavior of another MediaElement, in this case a SerialElement containing two VideoElements.  All playback events are sent to the trace console."
				  	,  	function():MediaElement
				  	   	{
							var serialElement:SerialElement = new SerialElement();
							serialElement.addChild(new VideoElement(new NetLoader(), new URLResource(new URL(REMOTE_PROGRESSIVE)))); 
							serialElement.addChild(new VideoElement(new NetLoader(), new URLResource(new FMSURL(REMOTE_STREAM))));
				  	   		return new TraceProxyElement(serialElement);
				  	   	}
				  	)
				);
			
			return examples;
		}
		
		private static function applyAdjacentLayout(parent:MediaElement, left:MediaElement, right:MediaElement):void
		{
			var relativeLayout:RelativeLayoutFacet = new RelativeLayoutFacet();
			relativeLayout.width = 50;
			relativeLayout.height = 50;
			
			left.metadata.addFacet(relativeLayout);
			
			relativeLayout = new RelativeLayoutFacet();
			relativeLayout.width = 50;
			relativeLayout.height = 50;
			relativeLayout.x = 50;
			
			right.metadata.addFacet(relativeLayout);
			
			var absoluteLayout:AbsoluteLayoutFacet = new AbsoluteLayoutFacet();
			absoluteLayout.width = 640
			absoluteLayout.height = 500;
			
			parent.metadata.addFacet(absoluteLayout);
		}

		private static const REMOTE_PROGRESSIVE:String 			= "http://mediapm.edgesuite.net/strobe/content/test/AFaerysTale_sylviaApostol_640_500_short.flv";
		private static const REMOTE_STREAM:String 				= "rtmp://cp67126.edgefcs.net/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short";
		private static const REMOTE_MBR_STREAM_HOST:String 		= "rtmp://cp67126.edgefcs.net/ondemand";
		private static const REMOTE_MP3:String 					= "http://mediapm.edgesuite.net/osmf/content/test/train_1500.mp3";
		private static const REMOTE_IMAGE:String 				= "http://www.adobe.com/ubi/globalnav/include/adobe-lq.png";
		private static const REMOTE_SLIDESHOW_IMAGE1:String 	= "http://www.adobe.com/images/shared/product_mnemonics/50x50/flash_player_50x50.gif";
		private static const REMOTE_SLIDESHOW_IMAGE2:String 	= "http://www.adobe.com/images/shared/product_mnemonics/48x45/flash_cs3_48x45.jpg";
		private static const REMOTE_SLIDESHOW_IMAGE3:String 	= "http://www.adobe.com/images/shared/product_mnemonics/48x45/flex_48x45.gif";
		private static const REMOTE_SWF:String 					= "http://mediapm.edgesuite.net/osmf/swf/OverlaySampleSWF.swf";
		private static const REMOTE_INVALID_PROGRESSIVE:String 	= "http://mediapm.edgesuite.net/strobe/content/test/fail.flv";
		private static const REMOTE_INVALID_STREAM:String 		= "rtmp://cp67126.fail.edgefcs.net/ondemand/mediapm/strobe/content/test/SpaceAloneHD_sounas_640_500_short";
		private static const REMOTE_INVALID_IMAGE:String 		= "http://www.adobe.com/ubi/globalnav/include/fail.png";
		private static const REMOTE_INVALID_MP3:String 			= "http://mediapm.edgesuite.net/osmf/content/test/fail.mp3";
		private static const LOCAL_PROGRESSIVE:String 			= "video.flv";
		private static const CHROMELESS_SWF_AS3:String			= "http://mediapm.edgesuite.net/osmf/swf/ChromelessPlayer.swf";
		private static const CHROMELESS_SWF_FLEX:String			= "http://mediapm.edgesuite.net/osmf/swf/ChromelessFlexPlayer.swf";
		
		private static const MBR_STREAM_ITEMS:Array =
			[ new DynamicStreamingItem("mp4:mediapm/ovp/content/demo/video/elephants_dream/elephants_dream_768x428_24.0fps_408kbps.mp4", 408, 768, 428)
			, new DynamicStreamingItem("mp4:mediapm/ovp/content/demo/video/elephants_dream/elephants_dream_768x428_24.0fps_608kbps.mp4", 608, 768, 428)
			, new DynamicStreamingItem("mp4:mediapm/ovp/content/demo/video/elephants_dream/elephants_dream_1024x522_24.0fps_908kbps.mp4", 908, 1024, 522)
			, new DynamicStreamingItem("mp4:mediapm/ovp/content/demo/video/elephants_dream/elephants_dream_1024x522_24.0fps_1308kbps.mp4", 1308, 1024, 522)
			, new DynamicStreamingItem("mp4:mediapm/ovp/content/demo/video/elephants_dream/elephants_dream_1280x720_24.0fps_1708kbps.mp4", 1708, 1280, 720)
			];
	}
}