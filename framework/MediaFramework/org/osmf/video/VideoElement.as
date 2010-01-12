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
package org.osmf.video
{
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.media.Video;
	import flash.net.NetStream;
	import flash.utils.ByteArray;
	
	import org.osmf.events.ContentProtectionEvent;
	import org.osmf.events.MediaError;
	import org.osmf.events.MediaErrorCodes;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.media.DefaultTraitResolver;
	import org.osmf.media.IMediaResource;
	import org.osmf.media.IURLResource;
	import org.osmf.media.LoadableMediaElement;
	import org.osmf.metadata.KeyValueFacet;
	import org.osmf.metadata.MetadataNamespaces;
	import org.osmf.metadata.ObjectIdentifier;
	import org.osmf.metadata.TemporalFacet;
	import org.osmf.metadata.TemporalFacetEvent;
	import org.osmf.net.ModifiableTimeTrait;
	import org.osmf.net.NetClient;
	import org.osmf.net.NetLoadedContext;
	import org.osmf.net.NetLoader;
	import org.osmf.net.NetStreamAudioTrait;
	import org.osmf.net.NetStreamBufferTrait;
	import org.osmf.net.NetStreamCodes;
	import org.osmf.net.NetStreamLoadTrait;
	import org.osmf.net.NetStreamPlayTrait;
	import org.osmf.net.NetStreamSeekTrait;
	import org.osmf.net.NetStreamTimeTrait;
	import org.osmf.net.NetStreamUtils;
	import org.osmf.net.NetStreamDisplayObjectTrait;
	import org.osmf.net.StreamType;
	import org.osmf.net.dynamicstreaming.DynamicNetStream;
	import org.osmf.net.dynamicstreaming.DynamicStreamingResource;
	import org.osmf.net.dynamicstreaming.NetStreamDynamicStreamTrait;
	import org.osmf.traits.ILoader;
	import org.osmf.traits.LoadState;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;
	import org.osmf.traits.TimeTrait;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.utils.OSMFStrings;

	CONFIG::FLASH_10_1
	{
	import flash.events.DRMAuthenticateEvent;
	import flash.events.DRMErrorEvent;
	import flash.events.DRMStatusEvent;
	import flash.net.drm.DRMContentData;	
	import flash.system.SystemUpdaterType;
	import flash.system.SystemUpdater;	
	import org.osmf.net.NetStreamContentProtectionTrait;
	}
	
	/**
	* VideoElement is a media element specifically created for video playback.
	* It supports both streaming and progressive formats.
	* <p>The VideoElement uses a NetLoader class to load and unload its media.
	* Developers requiring custom loading logic for video
	* can pass their own loaders to the VideoElement constructor. 
	* These loaders should subclass NetLoader.</p>
	* <p>The basic steps for creating and using a VideoElement are:
	* <ol>
	* <li>Create a new IURLResource pointing to the URL of the video stream or file
	* containing the video to be loaded.</li>
	* <li>Create a new NetLoader.</li>
	* <li>Create the new VideoElement, 
	* passing the NetLoader and IURLResource
	* as parameters.</li>
	* <li>Get the VideoElement's LoadTrait using the 
	* <code>MediaElement.getTrait(MediaTraitType.LOAD)</code> method.</li>
	* <li>Load the video using the LoadTrait's <code>load()</code> method.</li>
	* <li>Control the media using the VideoElement's traits and handle its trait
	* change events.</li>
	* <li>When done with the VideoElement, unload the video using the  
	* using the LoadTrait's <code>unload()</code> method.</li>
	* </ol>
	* </p>
	* 
	* @see org.osmf.net.NetLoader
	* @see org.osmf.media.IURLResource
	* @see org.osmf.media.MediaElement
	* @see org.osmf.traits
	**/

	public class VideoElement extends LoadableMediaElement
	{
		/**
		 * Constructor.
		 * 
		 * @param loader Loader used to load the video.
		 * @param resource An object implementing IMediaResource that points to the video 
		 * the VideoElement will use.
		 * 
		 * @throws ArgumentError If loader is null, or resource is neither an
		 * IURLResource nor a DynamicStreamingResource.
		 */
		public function VideoElement(loader:NetLoader, resource:IMediaResource=null)
		{	
			super(loader, resource);
			
			// The resource argument must either implement IURLResource or be
			// a DynamicStreamingResource object			
			if (resource != null)
			{
				var urlResource:IURLResource = resource as IURLResource;
				var dsResource:DynamicStreamingResource = resource as DynamicStreamingResource;
				
				if (urlResource == null && dsResource == null) 
				{
					throw new ArgumentError(OSMFStrings.getString(OSMFStrings.INVALID_PARAM));
				}
			}
		}
		       	
       	/**
       	 * The NetClient used by this VideoElement's NetStream.  Available after the 
       	 * element has been loaded.
	 	 *  
       	 *  @langversion 3.0
       	 *  @playerversion Flash 10
       	 *  @playerversion AIR 1.5
       	 *  @productversion OSMF 1.0
       	 */ 
       	public function get client():NetClient
       	{
       		return stream.client as NetClient;
       	}
       	
       	/**
       	 * Defines the duration that the element's TimeTrait will expose when the
       	 * element's content is unloaded.
       	 * 
       	 * Setting this property to a positive value results in the element becoming
       	 * temporal. Any other value will remove the element's TimeTrait, unless the
       	 * loaded content is exposing a duration. 
       	 * 
       	 *  @langversion 3.0
       	 *  @playerversion Flash 10
       	 *  @playerversion AIR 1.5
       	 *  @productversion OSMF 1.0
       	 */       	
       	public function set defaultDuration(value:Number):void
		{
			if (isNaN(value) || value < 0)
			{
				if (defaultTimeTrait != null)
				{
					// Remove the default trait if the default duration
					// gets set to not a number:
					removeTraitResolver(MediaTraitType.TIME);
					defaultTimeTrait = null;
				}
			}
			else 
			{
				if (defaultTimeTrait == null)
				{		
					// Add the default trait if when default duration
					// gets set:
					defaultTimeTrait = new ModifiableTimeTrait();
		       		addTraitResolver
		       			( MediaTraitType.TIME
		       			, new DefaultTraitResolver
		       				( MediaTraitType.TIME
		       				, defaultTimeTrait
		       				)
		       			);
		  		}
		  		
		  		defaultTimeTrait.duration = value; 
			}	
		}
		
		public function get defaultDuration():Number
		{
			return defaultTimeTrait ? defaultTimeTrait.duration : NaN;
		}
		
		/**
		 * Specifies whether the video should be smoothed (interpolated) when it is scaled. 
		 * For smoothing to work, the runtime must be in high-quality mode (the default). 
		 * The default value is false (no smoothing).  For video playback using Flash Player
		 * 9.0.115.0 and later versions, set this property to true to take advantage of mipmapping image optimization.
		 * 
		 * @see flash.media.Video
		**/
		public function set smoothing(value:Boolean):void
		{
			_smoothing = value;
			if (video != null)
			{
				video.smoothing = value;
			}
		}

		public function get smoothing():Boolean
		{
			return _smoothing;			
		}
		
		/**
		 * Indicates the type of filter applied to decoded video as part of post-processing. The default value is 0, which lets the video compressor apply a deblocking filter as needed.
		 * see flash.media.Video for more information on deblocking modes.
		 * 
		 * @see flash.media.Video
		 */ 
		public function set deblocking(value:int):void
		{
			_deblocking = value;
			if (video != null)
			{
				video.deblocking = value;
			}
		}

		public function get deblocking():int
		{
			return _deblocking;			
		}
		
       	// Overrides
       	//
       	
      	/**
		 * @private
		 **/
		override protected function createLoadTrait(loader:ILoader, resource:IMediaResource):LoadTrait
		{
			return new NetStreamLoadTrait(loader, resource);
		}
       	
	    /**
	     * @private
		 **/
		override protected function processReadyState():void
		{
			var loadTrait:LoadTrait = getTrait(MediaTraitType.LOAD) as LoadTrait;
			var context:NetLoadedContext = NetLoadedContext(loadTrait.loadedContext);
			stream = context.stream;
				
			// Set the video's dimensions so that it doesn't appear at the wrong size.
			// We'll set the correct dimensions once the metadata is loaded.  (FM-206)
			video = new Video();
			video.smoothing = _smoothing;
			video.deblocking = _deblocking;
			video.width = video.height = 0;

			video.attachNetStream(stream);
			
			// Hook up our metadata listeners
			NetClient(stream.client).addHandler(NetStreamCodes.ON_META_DATA, onMetaData);
			NetClient(stream.client).addHandler(NetStreamCodes.ON_CUE_POINT, onCuePoint);
						
			stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatusEvent);
						
			CONFIG::FLASH_10_1
    		{
    			// Listen for all errors
    			stream.addEventListener(DRMErrorEvent.DRM_ERROR, onDRMErrorEvent);
    						    			 			
    			// DRMContent data Sidecar
    			var metadataFacet:KeyValueFacet = resource.metadata.getFacet(MetadataNamespaces.DRM_METADATA) as KeyValueFacet;
    			if (metadataFacet != null)
    			{    				
    				var metadata:ByteArray = metadataFacet.getValue(new ObjectIdentifier(MetadataNamespaces.DRM_CONTENT_METADATA_KEY));
    				addProtectableTrait(metadata).addEventListener(ContentProtectionEvent.AUTHENTICATION_COMPLETE, onMetadataAuth);	   
    				return;  //Don't add traits until the "auth" has completed. 			
	    		}
	    		else
	    		{
	    			// Non sidecar
    				stream.addEventListener(StatusEvent.STATUS, onStatus);
	    		}			
    		}
			finishLoad();			
		}
		
		// DRM APIs
		CONFIG::FLASH_10_1
    	{
  			private function onStatus(event:StatusEvent):void
			{
				if (event.code == DRM_STATUS_CODE 
					&& getTrait(MediaTraitType.CONTENT_PROTECTION) == null)
				{			
					createProtectionTrait().addEventListener(ContentProtectionEvent.AUTHENTICATION_COMPLETE, reloadAfterAuth);	  			
	    		}
	  		}
	  		
	  		// Inline metadata + credentials.  The NetStream is dead at this point, restart with new credentials
	  		private function reloadAfterAuth(event:ContentProtectionEvent):void
	  		{
	  			if (LoadTrait(getTrait(MediaTraitType.LOAD)).loadState == LoadState.READY)
	  			{				  			
	  				LoadTrait(getTrait(MediaTraitType.LOAD)).unload();	  	
	  			}

	  			LoadTrait(getTrait(MediaTraitType.LOAD)).load();  		  					
	  		}	
			
			private function createProtectionTrait():NetStreamContentProtectionTrait
			{				
				var protectionTrait:NetStreamContentProtectionTrait = new NetStreamContentProtectionTrait();		    	
		    	addTrait(MediaTraitType.CONTENT_PROTECTION, protectionTrait);	
		    	return protectionTrait;	    			
			}	
			
			private function addProtectableTrait(contentData:ByteArray):NetStreamContentProtectionTrait
			{			
	    		var trait:NetStreamContentProtectionTrait = createProtectionTrait();
			   	trait.drmMetadata = contentData;
			   	return trait;
			}
							
			private function onDRMErrorEvent(event:DRMErrorEvent):void
			{
				if (event.errorID == MediaErrorCodes.DRM_NEEDS_AUTHENTICATION)  // Needs authentication
				{					
					NetStreamContentProtectionTrait(getTrait(MediaTraitType.CONTENT_PROTECTION)).drmMetadata = event.contentData;
				}
				else // Inline DRM - Errors need to be forwarded
				{				
					var trait:NetStreamContentProtectionTrait = NetStreamContentProtectionTrait(getTrait(MediaTraitType.CONTENT_PROTECTION));
					trait.dispatchEvent(new ContentProtectionEvent(ContentProtectionEvent.AUTHENTICATION_FAILED, false, false, null, new MediaError(event.errorID)));	
				}				
			}	
			
			private function onMetadataAuth(event:Event):void
			{
				finishLoad();	
			}	
		}
			
		
		private function finishLoad():void
		{
			var loadTrait:LoadTrait = getTrait(MediaTraitType.LOAD) as LoadTrait;
			var context:NetLoadedContext = NetLoadedContext(loadTrait.loadedContext);

	    	addTrait(MediaTraitType.AUDIO, new NetStreamAudioTrait(stream));
	    	addTrait(MediaTraitType.BUFFER, new NetStreamBufferTrait(stream));
			var timeTrait:TimeTrait = new NetStreamTimeTrait(stream, resource);
			addTrait(MediaTraitType.TIME, timeTrait);
			addTrait(MediaTraitType.PLAY, new NetStreamPlayTrait(stream, resource));
			displayObjectTrait = new NetStreamDisplayObjectTrait(stream, video, video.width, video.height);
			addTrait(MediaTraitType.DISPLAY_OBJECT, displayObjectTrait);
			
			if (NetStreamUtils.getStreamType(resource) != StreamType.LIVE)
			{
	    		addTrait(MediaTraitType.SEEK, new NetStreamSeekTrait(timeTrait, stream));
	  		}
	    	
			var dynRes:DynamicStreamingResource = resource as DynamicStreamingResource;
			if (dynRes != null)
			{
				addTrait(MediaTraitType.DYNAMIC_STREAM, new NetStreamDynamicStreamTrait(stream as DynamicNetStream, dynRes));
			}	    	
		}
		
		/**
		 * @private
		 **/
		override protected function processUnloadingState():void
		{
			NetClient(stream.client).removeHandler(NetStreamCodes.ON_META_DATA, onMetaData);
			
			stream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatusEvent)
			
	    	removeTrait(MediaTraitType.AUDIO);
	    	removeTrait(MediaTraitType.BUFFER);
			removeTrait(MediaTraitType.PLAY);
			removeTrait(MediaTraitType.TIME);
			removeTrait(MediaTraitType.DISPLAY_OBJECT);
	    	removeTrait(MediaTraitType.SEEK);
    		removeTrait(MediaTraitType.DYNAMIC_STREAM);
	    	
	    	CONFIG::FLASH_10_1
    		{    			
    			stream.removeEventListener(DRMErrorEvent.DRM_ERROR, onDRMErrorEvent);
    			stream.removeEventListener(StatusEvent.STATUS, onStatus);
    			removeTrait(MediaTraitType.CONTENT_PROTECTION);    					
    		}
    		
	    	// Null refs to garbage collect.	    	
			video.attachNetStream(null);
			stream = null;
			video = null;
			displayObjectTrait = null;
		}

		private function onMetaData(info:Object):void 
    	{   
			var cuePoints:Array = info.cuePoints;
			
			if (cuePoints != null && cuePoints.length > 0)
			{
				var temporalFacetDynamic:TemporalFacet = new TemporalFacet(MetadataNamespaces.TEMPORAL_METADATA_DYNAMIC, this);
				
				for (var i:int = 0; i < cuePoints.length; i++)
				{
					var cuePoint:CuePoint = new CuePoint(CuePointType.fromString(cuePoints[i].type), cuePoints[i].time, 
																					cuePoints[i].name, cuePoints[i].parameters);
					temporalFacetDynamic.addValue(cuePoint);
				}
				
				metadata.addFacet(temporalFacetDynamic);			
			}			    		
     	}
     	
     	private function onCuePoint(info:Object):void
     	{
     		if (_temporalFacetEmbedded == null)
     		{
				_temporalFacetEmbedded = new TemporalFacet(MetadataNamespaces.TEMPORAL_METADATA_EMBEDDED, this);
				metadata.addFacet(_temporalFacetEmbedded);
     		}

			var cuePoint:CuePoint = new CuePoint(CuePointType.fromString(info.type), info.time, info.name, info.parameters);
			_temporalFacetEmbedded.dispatchEvent(new TemporalFacetEvent(TemporalFacetEvent.POSITION_REACHED, cuePoint));     		
     	}     	
     	     	
     	// Fired when the DRM subsystem is updated.  NetStream needs to be recreated.
     	private function onUpdateComplete(event:Event):void
     	{     		
    		(getTrait(MediaTraitType.LOAD) as LoadTrait).unload();
    		(getTrait(MediaTraitType.LOAD) as LoadTrait).load();		
     	}
     	
     	private function onUpdateError(event:Event):void
     	{     	
     		dispatchEvent(new ErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, "Error Updating DRM: " + event.toString()));
     		(getTrait(MediaTraitType.LOAD) as LoadTrait).unload();
     	}
     	     	
     	private function onNetStatusEvent(event:NetStatusEvent):void
     	{
     		var error:MediaError = null;
 			switch (event.info.code)
			{
				case NetStreamCodes.NETSTREAM_PLAY_FAILED:
				case NetStreamCodes.NETSTREAM_FAILED:
					error = new MediaError(MediaErrorCodes.PLAY_FAILED);
					break;
				case NetStreamCodes.NETSTREAM_PLAY_STREAMNOTFOUND:
					error = new MediaError(MediaErrorCodes.STREAM_NOT_FOUND);
					break;
				case NetStreamCodes.NETSTREAM_PLAY_FILESTRUCTUREINVALID:
					error = new MediaError(MediaErrorCodes.FILE_STRUCTURE_INVALID);
					break;
				case NetStreamCodes.NETSTREAM_PLAY_NOSUPPORTEDTRACKFOUND:
					error = new MediaError(MediaErrorCodes.NO_SUPPORTED_TRACK_FOUND);
					break;	
			}
			
			CONFIG::FLASH_10_1
			{
				switch (event.info.code)
				{
					case NetStreamCodes.NETSTREAM_DRM_UPDATE:
		     			var drmUpdater:SystemUpdater = new SystemUpdater();
		     			drmUpdater.addEventListener(Event.COMPLETE, onUpdateComplete);
		     			drmUpdater.addEventListener(IOErrorEvent.IO_ERROR, onUpdateError);
		     			drmUpdater.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onUpdateError);
		     			drmUpdater.addEventListener(Event.CANCEL, onUpdateError);
		     			drmUpdater.update(SystemUpdaterType.DRM);   
		     			break;				
	    		}
			}
						
			if (error != null)
			{
				dispatchEvent(new MediaErrorEvent(MediaErrorEvent.MEDIA_ERROR, false, false, error));
			}
     	}
     	
     	private static const DRM_STATUS_CODE:String = "DRM.encryptedFLV";
     	
     	private var displayObjectTrait:DisplayObjectTrait;
     	private var defaultTimeTrait:ModifiableTimeTrait;
     	
     	private var stream:NetStream;
      	private var video:Video;
      	
		private var _temporalFacetEmbedded:TemporalFacet;	// facet for cue points embedded in the stream
		private var _smoothing:Boolean;
		private var _deblocking:int;
	}
}
