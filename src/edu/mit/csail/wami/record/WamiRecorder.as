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
package edu.mit.csail.wami.record
{
	import edu.mit.csail.wami.utils.StateListener;
	import edu.mit.csail.wami.utils.Pipe;
	import edu.mit.csail.wami.utils.WaveFormat;
	
	import flash.events.EventDispatcher;
	import flash.events.SampleDataEvent;
	import flash.events.StatusEvent;
	import flash.media.Microphone;
	import flash.utils.ByteArray;
	import flash.media.SoundCodec;
	
	public class WamiRecorder implements IRecorder
	{
		private static var CHUNK_DURATION:Number = .25;
		private var mic:Microphone = null;
		private var stream:Boolean;
		private var chunkSize:int;
		private var format:WaveFormat;
		private var audioPipe:Pipe;
		private var listener:StateListener;
		
		public function WamiRecorder(s:Boolean)
		{
			format = new WaveFormat();
			stream = s;
			var bytesPerSample:uint = format.channels * (format.bits/8) * format.rate;
			chunkSize = stream ? bytesPerSample * CHUNK_DURATION : int.MAX_VALUE;
			
			if (chunkSize <= 0)
			{
				throw Error("Desired duration is too small, even for streaming chunks: " + chunkSize);
			}
		}
		
		public function start(url:String, listener:StateListener):void 
		{
			if (mic) return;
			audioPipe = createAudioPipe(url);
			this.listener = listener;
			mic = Microphone.getMicrophone();
			mic.rate = format.getRecordRate();
			mic.setSilenceLevel(0, 10000);
			mic.addEventListener(SampleDataEvent.SAMPLE_DATA, sampleHandler);
			listener.started();
		}
		
		public function createAudioPipe(url:String):Pipe
		{
			var post:Pipe;
			if (stream)
			{
				post = new MultiPost(url, "audio/x-wav.chunk-%s", 3*1000, listener);
			}
			else
			{
				post = new SinglePost(url, "audio/x-wav", 30*1000, listener);
			}
			
			// Setup the audio pipes.  A transcoding pipe converts floats
			// to shorts and passes them on to a chunking pipe, which spits
			// out chunks to a pipe that possibly adds a WAVE header
			// before passing the chunks on to a pipe that does HTTP posts.
			var pipe:Pipe = new EncodePipe(format);
			pipe.setSink(new ChunkPipe(chunkSize))
				.setSink(new WavePipe(format, stream))
				.setSink(post);

			return pipe;
		}
		
		internal function sampleHandler(evt:SampleDataEvent):void
		{
			evt.data.position = 0;
			try 
			{
				audioPipe.write(evt.data);
			}
			catch (error:Error)
			{
				listener.failed(error);
			}
		}
		
		public function stop():void 
		{
			if (!mic) return;
			mic.removeEventListener(SampleDataEvent.SAMPLE_DATA, sampleHandler);
			audioPipe.close();
			mic = null;
			listener.finished();
		}
		
		public function level():int 
		{
			if (!mic) return 0;
			return mic.activityLevel;
		}
	}
}