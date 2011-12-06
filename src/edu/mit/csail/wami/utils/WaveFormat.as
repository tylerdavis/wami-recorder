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
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/**
	 * This class keeps track of all the information that goes into the
	 * header of a .wav file.
	 */
	public class WaveFormat
	{
		// Allow 8 and 16 kHz as well.
		public static var allRates:Boolean = false;

		public static var HEADER_LENGTH:uint = 44;

		public var channels:uint;
		public var rate:uint;
		public var bits:uint;
		public var endian:String; // Little-endian is generally the way to go.
		
		public function WaveFormat(rate:uint, channels:uint, bits:uint, endian:String)
		{
			this.rate = rate;
			this.channels = channels;
			this.endian = endian;
			this.bits = bits;
			
			validate();
		}

		// flash.media.Microphone quasi-rounds sample rates in kHz
		public static function toRoundedRate(rate:uint):uint
		{
			if (rate == 5512)
			{
				return 5;
			}
			else if (rate == 8000)
			{
				return 8;
			}
			else if (rate == 11025)
			{
				return 11;
			}
			else if (rate == 16000)
			{
				return 16;
			}
			else if (rate == 22050)
			{
				return 22;
			}
			else if (rate == 44100)
			{
				return 44;
			}
			
			throw new Error("Unsupported sample rate in Hz: " + rate);
		}
		
		
		public static function fromRoundedRate(rate:uint):uint
		{
			if (rate == 5)
			{
				return 5512;
			}
			else if (rate == 8)
			{
				return 8000;
			}
			else if (rate == 11)
			{
				return 11025;
			}
			else if (rate == 16)
			{
				return 16000;
			}
			else if (rate == 22)
			{
				return 22050;
			}
			else if (rate == 44)
			{
				return 44100;
			}
			
			throw new Error("Unsupported sample rate rounded in kHz: " + rate);
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
			var endian:String = Endian.LITTLE_ENDIAN;
			var chunkID:String = header.readUTFBytes(4);     
			if (chunkID == "RIFX")
			{
				endian = Endian.BIG_ENDIAN;
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
			var channels:uint = header.readShort();
			var rate:uint = header.readInt();
			var bps:uint = header.readInt();
			var bytesPerSample:uint = header.readShort();
			var bits:uint = header.readShort();
			var dataStr:String = header.readUTFBytes(4);          // "data"
			var dataLength:uint = header.readInt();

			return new WaveFormat(rate, channels, bits, endian);
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
			
			var msg:String = "";
			if (rate < 100) 
			{
				throw new Error("Rate should be in Hz");	
			} 
			else if (rate != 5512 && rate != 8000 && rate != 11025 && rate != 16000 && rate != 22050 && rate != 44100)
			{
				msg = "Sample rate of " + rate + " is not supported.";
				msg += " See flash.media.Microphone documentation."
				throw new Error(msg);
			}
			else if (!allRates && (rate == 8000 || rate == 16000 || rate == 11025)) {
				msg = "8kHz and 16kHz are supported for recording but not playback.  11kHz doesn't work in Ubuntu.";
				msg += "Enable all rates via a parameter passed into the Flash."
				throw new Error(msg);
			}
		}
		
		public function toString():String
		{
			return "Rate: " + rate + " Channels " + channels + " Bits: " + bits + " Endian: " + endian;
		}
	}
}