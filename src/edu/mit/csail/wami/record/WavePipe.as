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
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import edu.mit.csail.wami.utils.Pipe;
	import edu.mit.csail.wami.utils.WaveFormat;
	
	/**
	 * Adds the header to the WAV.
	 */
	public class WavePipe extends Pipe
	{
		private var format:WaveFormat;
		private var streaming:Boolean;
		private var buffer:ByteArray;
		private var written:Boolean = false;
		
		public function WavePipe(format:WaveFormat, streaming:Boolean)
		{
			this.format = format;
			this.streaming = streaming;
			if (!streaming) this.buffer = new ByteArray();
		}
		
		override public function write(bytes:ByteArray):void
		{
			if (!streaming)
			{
				buffer.writeBytes(bytes, bytes.position, bytes.bytesAvailable);
				return;
			}
			
			if (!written)
			{
				bytes = addHeader(bytes, false);
				written = true;
			}
			
			super.write(bytes);
		}

		private function addHeader(bytes:ByteArray, computeLength:Boolean):ByteArray
		{
			var data:ByteArray = format.toByteArray(computeLength ? bytes.length : 0);
			bytes.readBytes(data, data.length, bytes.bytesAvailable);
			data.position = 0;
			return data;
		}
		
		override public function close():void
		{
			if (!streaming)
			{
				// Write the whole WAV (including the header).
				buffer.position = 0;
				super.write(addHeader(buffer, true));
			}
			
			super.close();
		}
	}
}