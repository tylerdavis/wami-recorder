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
	import flash.external.ExternalInterface;
	
	/**
	 * Make external calls only if available.
	 */
	public class External
	{
		public static function call(functionName:String, ... arguments):void
		{
			if (ExternalInterface.available && functionName) 
			{
				try 
				{
					ExternalInterface.call(functionName, arguments);
				}
				catch (e:Error)
				{
					trace("Error calling external function: " + e.message);
				}
			}
			else
			{	
				trace("WamiUtils.call: " + functionName + "(" + arguments + ")");
			}
		}	
		
		public static function addCallback(functionName:String, closure:Function):void
		{
			if (ExternalInterface.available && functionName) 
			{
				try
				{
					ExternalInterface.addCallback(functionName, closure);
				}
				catch (e:Error)
				{
					trace("Error calling external function: " + e.message);
				}
			}
			else
			{
				trace("WamiUtils.addCallback: " + functionName);
			}
		}
	}
}