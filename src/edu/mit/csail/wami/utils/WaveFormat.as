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
package edu.mit.csail.wami.utils
{
	import edu.mit.csail.wami.utils.WaveFormat;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * This class keeps track of all the information that goes into the
	 * header of a .wav file.
	 */
	public class WaveFormat
	{
		public var channels:uint = 1;
		public var rate:uint = 22050;
		public var bits:uint = 16;
		
		// Little-endian is generally the way to go.
		public var endian:String = Endian.LITTLE_ENDIAN;
		public static var HEADER_LENGTH:uint = 44;
		
		public function WaveFormat()
		{
			validate();
		}

		// Why does flash.media.Microphone quasi-round sample rates in kHz??
		public function getRecordRate():uint
		{
			if (rate == 5512)
			{
				return 5;
			}
			else if (rate == 8000)
			{
				// throw new Error("8kHz could be supported, but it not easy to play back correctly.");
				return 8;
			}
			else if (rate == 11025)
			{
				return 11;
			}
			else if (rate == 22050)
			{
				return 22;
			}
			else if (rate == 44100)
			{
				return 44;
			}
			
			throw new Error("Unsupported sampling rate: " + rate);
		}
		
		public function toByteArray(length:uint):ByteArray
		{
			// https://ccrma.stanford.edu/courses/422/projects/WaveFormat/
			var id:String = (endian == Endian.LITTLE_ENDIAN) ? "RIFF" : "RIFX";
			var bytesPerSample:uint = channels*bits/8;
			
			var header:ByteArray = new ByteArray();
			header.endian = Endian.LITTLE_ENDIAN;
			header.writeUTFBytes(id);
			header.writeInt(length > 0 ? 36 + length : 0);
			header.writeUTFBytes("WAVE");
			header.writeUTFBytes("fmt ");
			header.writeInt(16);
			header.writeShort(1);
			header.writeShort(channels);
			header.writeInt(rate);
			header.writeInt(rate*bytesPerSample);
			header.writeShort(bytesPerSample);
			header.writeShort(bits);
			header.writeUTFBytes('data');
			header.writeInt(length);
			
			return header;
		}	
		
		public static function toWaveFormat(header:ByteArray):WaveFormat
		{
			var format:WaveFormat = new WaveFormat();
			
			var chunkID:String = header.readUTFBytes(4);     
			if (chunkID == "RIFX")
			{
				format.endian = Endian.BIG_ENDIAN;
			}
			else if (chunkID != "RIFF")
			{
				throw new Error("Invalid start of WAVE header: " + chunkID);
			}
			
			header.endian = Endian.LITTLE_ENDIAN;                 // Header is little-endian 
			var totalLength:uint = header.readInt() + 8;
			var waveFmtStr:String = header.readUTFBytes(8);       // "WAVEfmt "
			var subchunkSize:uint = header.readUnsignedInt();     // 16
			var audioFormat:uint = header.readShort();            // 1
			format.channels = header.readShort();
			format.rate = header.readInt();
			var bps:uint = header.readInt();
			var bytesPerSample:uint = header.readShort();
			format.bits = header.readShort();
			var dataStr:String = header.readUTFBytes(4);          // "data"
			var dataLength:uint = header.readInt();

			format.validate();
			return format;
		}
		
		public function validate():void
		{
			if (bits != 8 && bits != 16 && bits != 32)
			{
				throw new Error("Unsupported number of bits per sample: " + bits);
			}
			
			if (channels != 1 && channels != 2)
			{
				throw new Error("Unsupported number of channels: " + channels);
			}
			
			if (endian != Endian.BIG_ENDIAN && endian != Endian.LITTLE_ENDIAN)
			{
				throw new Error("Unsupported endian type: " + endian);
			}
			
			if (rate < 100) 
			{
				throw new Error("Rate should be in Hz");	
			} 
			else if (rate != 5512 && rate != 8000 && rate != 11025 && rate != 22050 && rate != 44100)
			{
				var msg:String = "Sample rate of " + rate + " is not supported.";
				msg += " See flash.media.Microphone documentation."
				throw new Error(msg);
				// though maybe you could write resampling code in actionscript... maybe...
			}
		}
		
		public function toString():String
		{
			return "Rate: " + rate + " Channels " + channels + " Bits: " + bits + " Endian: " + endian;
		}
	}
}