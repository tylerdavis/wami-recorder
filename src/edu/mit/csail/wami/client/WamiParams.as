/* 
* Copyright (c) 2011
* Spoken Language Systems Group
* MIT Computer Science and Artificial Intelligence Laboratory
* Massachusetts Institute of Technology
*
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without
* restriction, including without limitation the rights to use, copy,
* modify, merge, publish, distribute, sublicense, and/or sell copies
* of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be
* included in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
* NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
* BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
* ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*/
package edu.mit.csail.wami.client
{	
	import edu.mit.csail.wami.utils.External;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * A class documents the possible parameters and sets a few defaults.
	 * The defaults are set up to stream to localhost.
	 */
	public class WamiParams
	{
		// Show the debug interface.
		public var visible:Boolean = true;

		// Send the audio using multiple HTTP Posts
		public var stream:Boolean = false;
		
		//public var testRecordUrl:String = "http://localhost:8080/portal/record?test=/Users/imcgraw/Desktop/mtest.wav";
		
		public var testRecordUrl:String = "http://wami-recorder.appspot.com/";
		public var testPlayUrl:String = "http://wami-recorder.appspot.com/";
		//public var testRecordUrl:String = "http://localhost:8080/portal/record?wsessionid=test";
		//public var testPlayUrl:String = "http://localhost:8080/portal/play?wsessionid=test&operation=playback";
		//public var testRecordUrl:String = "http://people.csail.mit.edu/imcgraw/post/test.php";
		//public var testPlayUrl:String = "http://people.csail.mit.edu/imcgraw/post/output.wav";
		
		// Callbacks for loading the client.
		public var loadedCallback:String;
	
		public function WamiParams(params:Object):void
		{
			if (params.stream != undefined)
			{
				stream = params.stream == "true";
			}
			
			if (params.visible != undefined) 
			{
				visible = params.visible == "true";
			}
						
			loadedCallback = params.loadedCallback;
		}
	}
}