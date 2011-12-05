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
	import edu.mit.csail.wami.utils.BytePipe;
	import edu.mit.csail.wami.utils.Pipe;
	import edu.mit.csail.wami.utils.StateListener;
	import edu.mit.csail.wami.utils.WaveFormat;
	
	import flash.events.SampleDataEvent;
	import flash.events.StatusEvent;
	import flash.media.Microphone;
	import flash.media.SoundCodec;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	public class WamiRecorder implements IRecorder
	{
		private static var CHUNK_DURATION_MILLIS:Number = 200;
		
		private var mic:Microphone = null;
		private var stream:Boolean;
		private var chunkSize:uint;
		private var format:WaveFormat;
		private var audioPipe:Pipe;
		private var listener:StateListener;
		private var circularBuffer:BytePipe;
		private var paddingMillis:uint;
		private var stopInterval:uint;
		private var paddingBufferSize:uint;
		
		// To determine if the amount of audio recorded matches up with 
		// the length of time we've recorded (i.e. not dropping any frames)
		private var handled:uint;
		private var startTime:Date;
		private var stopTime:Date;
		
		/**
		 * The WAMI recorder actually listens constantly, keeping a buffer of the last
		 * few milliseconds of audio.  Often people start talking before they click the
		 * button, so we prepend paddingMillis milliseconds to the audio.
		 */
		public function WamiRecorder(mic:Microphone, format:WaveFormat, s:Boolean, paddingMillis:uint)
		{
			this.format = format;
			stream = s;
			var bytesPerSecond:uint = format.channels * (format.bits/8) * format.rate;
			chunkSize = stream ? bytesPerSecond * CHUNK_DURATION_MILLIS / 1000.0 : int.MAX_VALUE;
			
			this.paddingBufferSize = uint(bytesPerSecond*paddingMillis/1000.0);
			this.circularBuffer = new BytePipe(paddingBufferSize);
			this.paddingMillis = paddingMillis;
			
			this.mic = mic;
			mic.addEventListener(StatusEvent.STATUS, onMicStatus);
			if (!mic.muted && paddingMillis > 0) 
			{
				startListening();
			}
			
			if (chunkSize <= 0)
			{
				throw new Error("Desired duration is too small, even for streaming chunks: " + chunkSize);
			}
		}

		private function stopListening():void
		{
			mic.removeEventListener(SampleDataEvent.SAMPLE_DATA, sampleHandler);
		}
		
		private function startListening():void
		{
			mic.rate = WaveFormat.toRoundedRate(format.rate);
			mic.codec = SoundCodec.NELLYMOSER;  // Just to clarify 5, 8, 11, 16, 22 and 44 kHz
			mic.setSilenceLevel(0, 10000);
			mic.addEventListener(SampleDataEvent.SAMPLE_DATA, sampleHandler);
			trace("Listening...");
		}
		
		protected function onMicStatus(event:StatusEvent):void
		{
			trace("status: " + event.code);
			if (event.code == "Microphone.Unmuted") 
			{
				startListening();
			} else if (event.code == "Microphone.Muted") {
				stopListening();
			}
		}
		
		public function start(url:String, listener:StateListener):void 
		{
			if (mic.muted || paddingMillis > 0)
			{
				// Forces security if mic is still muted in debugging mode.
				startListening();
			}

			// Flash might be able to decide on a different sample rate
			// than the one you suggest depending on your audio card...
			format.rate = WaveFormat.fromRoundedRate(mic.rate);
			trace("Recording at rate: " + format.rate);

			reallyStop();
			audioPipe = createAudioPipe(url);

			if (paddingMillis > 0) {
				// Prepend a small amount of audio we've already recorded.
				circularBuffer.close();
				audioPipe.write(circularBuffer.getByteArray());
				circularBuffer = new BytePipe(paddingBufferSize);
			}
			
			this.listener = listener;
			listener.started();

			handled = 0;
			startTime = new Date();
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
				if (audioPipe)
				{
					audioPipe.write(evt.data);
					handled += evt.data.length / 4;
				}
				else if (paddingMillis > 0)
				{
					circularBuffer.write(evt.data);
				}
			}
			catch (error:Error)
			{
				listener.failed(error);
			}
		}
		
		public function stop():void 
		{
			stopInterval = setInterval(reallyStop, paddingMillis);
		}
		
		public function level():int 
		{
			if (!audioPipe) return 0;
			return mic.activityLevel;
		}
		
		private function reallyStop():void
		{
			clearInterval(stopInterval);
			if (!audioPipe) return;
			audioPipe.close();
			audioPipe = null;
			validateAudioLength();
			listener.finished();
		}
		
		private function validateAudioLength():void
		{
			stopTime = new Date();
			var seconds:Number = ((stopTime.time - startTime.time + paddingMillis) / 1000.0);
			var expectedSamples:uint = uint(seconds*format.rate);
			trace("Expected Samples: " + expectedSamples + " Actual Samples: " + handled);
			
			startTime = null;
			stopTime = null;
		}
	}
}