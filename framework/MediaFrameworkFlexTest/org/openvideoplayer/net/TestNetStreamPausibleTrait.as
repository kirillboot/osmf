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
package org.openvideoplayer.net
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import org.openvideoplayer.traits.TestPausibleTrait;
	import org.openvideoplayer.utils.NetFactory;

	public class TestNetStreamPausibleTrait extends TestPausibleTrait
	{
		override public function setUp():void
		{
			netFactory = new NetFactory();

			super.setUp();
		}
		
		override public function tearDown():void
		{
			super.tearDown();
			
			netFactory = null;
		}

		override protected function createInterfaceObject(... args):Object
		{
			var connection:NetConnection = netFactory.createNetConnection();
			connection.connect(null);
			var netStream:NetStream = netFactory.createNetStream(connection);
			netStream.client = new NetClient();
			
			return new NetStreamPausibleTrait(netStream);
		}
		
		private var netFactory:NetFactory;
	}
}