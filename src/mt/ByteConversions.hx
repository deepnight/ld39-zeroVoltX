package mt;

import haxe.io.Bytes;
/**
 * Tries to provide consistent access to haxe.io.bytes from any primitive
 */
class ByteConversions
{

	
	public static inline function bytesData2Bytes(input : haxe.io.BytesData) : haxe.io.Bytes
	{
		return haxe.io.Bytes.ofData(input);
	}
	
#if (flash||openfl)
	public static function byteArrayToBytes( v: flash.utils.ByteArray ) : haxe.io.Bytes 
	{
		return
		#if (flash)
		Bytes.ofData( v );
		#elseif js 
		{
			var b :Bytes = Bytes.alloc(v.length);
			for ( i in 0...v.length )
				b.set(i,v[i]);
			b;
		};
		#elseif (neko||cpp)
		v; 
		#end
	}
	
	#if js
	public static function arrayBufferToBytes(v : js.html.ArrayBuffer) : haxe.io.Bytes
	{
		return byteArrayToBytes(flash.utils.ByteArray.nmeOfBuffer(v));
	}
	#end
	
	public static inline function bytesData2ByteArray(input : haxe.io.BytesData) : flash.utils.ByteArray
	{
		#if (cpp||neko)
		var bytes = haxe.io.Bytes.ofData(input);
		return flash.utils.ByteArray.fromBytes(bytes);
		#else
		return input;
		#end
	}	
	
	public static inline function bytes2ByteArray(bytes : haxe.io.Bytes) : flash.utils.ByteArray
	{
		#if (cpp||neko)
		return flash.utils.ByteArray.fromBytes(bytes);
		#else
		return bytes.getData();
		#end
	}
	
	public static inline function byteArray2BytesData(input : flash.utils.ByteArray) : haxe.io.BytesData
	{
		#if (cpp||neko)
		return input.getData();
		#else
		return input;
		#end
	}
	
	public static inline function byteArray2Bytes(input : flash.utils.ByteArray) : haxe.io.Bytes
	{
		return haxe.io.Bytes.ofData(byteArray2BytesData(input));
	}
	
#end
	
}

