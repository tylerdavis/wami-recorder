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
	import edu.mit.csail.wami.utils.WaveFormat;
	
	/**
	 * A class documents the possible parameters and sets a few defaults.
	 * The defaults are set up to stream to localhost.
	 */
	public class WamiParams
	{
		// Show the debug interface.
		public var visible:Boolean = true;

		// Append this many milliseconds of audio before 
		// and after calls to startRecording/stopRecording.
		public var paddingMillis:uint = 200;

		// Send the audio using multiple HTTP Posts.
		public var stream:Boolean = false;
		
		// The URLs used in the debugging interface.
		public var testRecordUrl:String = "http://wami-recorder.appspot.com/";
		public var testPlayUrl:String = "http://wami-recorder.appspot.com/";
		
		// Callbacks for loading the client.
		public var loadedCallback:String;
		public var format:WaveFormat;
	
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
			
			if (params.paddingMillis != undefined) 
			{
				paddingMillis = int(params.paddingMillis);
			}
			
			loadedCallback = params.loadedCallback;
			
			format = new WaveFormat();
			if (params.rate != undefined) 
			{
				format.rate = uint(params.rate);
			}
		}
	}
}