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
	import edu.mit.csail.wami.utils.Pipe;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import edu.mit.csail.wami.utils.WaveFormat;

	/**
	 * Convert float format to WAVE
	 */
	public class EncodePipe extends Pipe
	{
		private var format:WaveFormat;
		
		function EncodePipe(format:WaveFormat)
		{
			this.format = format;
		}
		
		override public function write(bytes:ByteArray):void
		{
			var transcoded:ByteArray = new ByteArray();
			transcoded.endian = format.endian;
			while (bytes.bytesAvailable >= 4)
			{
				var sample:int;
				if (format.bits == 16)
				{
				 	sample = bytes.readFloat()*0x7fff;
					transcoded.writeShort(sample);
					if (format.channels == 2)
					{
						transcoded.writeShort(sample);
					}
				}
				else if (format.bits == 32)
				{
					sample = bytes.readFloat()*0x7fffffff;
					transcoded.writeInt(sample);
					if (format.channels == 2)
					{
						transcoded.writeInt(sample);
					}					
				}
				else
				{
					throw new Error("Unsupported bits per sample: " + format.bits);
				}
			}
			transcoded.position = 0;
			super.write(transcoded);
		}
	}
}