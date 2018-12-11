package mt;
import format.swf.Data.MatrixPart;
import h2d.Anim;
import h2d.Tile;
import h3d.mat.Texture;
import hxd.Math;
import h3d.mat.Data;

import format.png.Data;
using StringTools;

/***
 * Better uses in conjunction with pvr_tools
 */

class PVRTexture extends h3d.mat.Texture {

	// call reallocMT on any thread, call returned function on GPU thread
	public var reallocMT : Void-> (Void -> Void);
	var half : Bool;

	@:allow(mt.Assets)
	static function fromPixels( pixels : hxd.Pixels, isHalf:Bool ) {
		var p = haxe.EnumFlags.ofInt(0);

		if ( pixels.flags.has(hxd.Pixels.Flags.Compressed) )
			p.set(Compressed);
		if ( pixels.flags.has(hxd.Pixels.Flags.NoAlpha) )
			p.set(NoAlpha);
		if ( pixels.flags.has(hxd.Pixels.Flags.AlphaPremultiplied) )
			p.set(AlphaPremultiplied);

		var t = new PVRTexture(pixels.width, pixels.height, p);
		if( t.half = isHalf ){
			t.width <<= 1;
			t.height <<= 1;
		}
		t.uploadPixels(pixels);

		return t;
	}

	public override function uploadPixels(px,mipLevel=0,side=0){
		if( half ){
			width >>= 1;
			height >>= 1;
		}
		super.uploadPixels(px,mipLevel,side);
		if( half ){
			width <<= 1;
			height <<= 1;
		}
	}

}

class Assets {

	public static var USE_HALF_SIZE = false;

	/**
	 * try to snatch the best texture format available
	 */
	static function resolveBitmapData(path:String):String {
		var drv = h3d.Engine.getCurrent().driver;
		if ( drv == null) throw "mt:h3d : driver not ready";

		if ( drv.hasFeature( ETC1 ) ) {
			var etc1Path = path.replace(".png", ".etc1.pvr.z");
			if ( openfl.Assets.exists( etc1Path ) )
				return etc1Path;
		}

		if( drv.hasFeature( PVRTC1 ) ){
			var pvrtcPath = path.replace(".png", ".pvrtc1.pvr.z");
			if ( openfl.Assets.exists( pvrtcPath ) )
				return pvrtcPath;
		}

		if( drv.hasFeature( S3TC ) ){
			var s3tcPath = path.replace(".png", ".s3tc.pvr.z");
			if ( openfl.Assets.exists( s3tcPath ) ) {
				return s3tcPath;
			}
		}

		#if cpp
		var glDrv : h3d.impl.GlDriver = cast drv;
		if( glDrv.supports4444){
			var reducedPath = path.replace(".png", ".4444.pvr.z");
			if ( openfl.Assets.exists( reducedPath ) )
				return reducedPath;
		}

		if( glDrv.supports565){
			var reducedPath = path.replace(".png", ".565.pvr.z");
			if ( openfl.Assets.exists( reducedPath ) )
				return reducedPath;
		}

		if( glDrv.supports5551){
			var reducedPath = path.replace(".png", ".5551.pvr.z");
			if ( openfl.Assets.exists( reducedPath ) )
				return reducedPath;
		}
		#end

		//let the system perform auto detect
		var pvrPath = path.replace(".png", ".8888.pvr.z");
		if ( openfl.Assets.exists( pvrPath  ) )
			return pvrPath;

		//let the system perform auto detect
		var pvrPath = path.replace(".png", ".pvr.z");
		if ( openfl.Assets.exists( pvrPath ) )
			return pvrPath;

		return path;
	}

	static function resolveDepackBitmapData(path:String):String {
		for ( p in [".4444.pvr.z", ".4444.pvr",".565.pvr.z",".565.pvr",".5551.pvr.z",".5551.pvr"]) {
			var rpath = path.replace(".png", p);
			if ( openfl.Assets.exists( rpath ) )
				return rpath;
		}
		return path;
	}

	public static var USE_CACHE = true;
	static function shouldDepack(path:String) {
		for ( p in [".4444.pvr.z", ".4444.pvr",".565.pvr.z",".565.pvr",".5551.pvr.z",".5551.pvr"])
			if( StringTools.endsWith( path, p))
				return true;

		return false;
	}

	public static var ALL_PIXELS : Map<String,h2d.Tile> = new Map();
	static var DEBUG = #if debug true #else false#end;

	/**
	 * Retrieve an adequate tile
	 * if the pvr is not pot we WILL have problems
	 */
	public static function getTile(path:String, forceRetain=false) : Void -> h2d.Tile {
		path = resolveBitmapData(path);

		var isHalf = false;
		if( USE_HALF_SIZE ) {
			var halfPath = path.split(".pvr").join(".half.pvr");
			if( openfl.Assets.exists( halfPath ) ){
				path = halfPath;
				isHalf = true;
			}
		}

		inline function isStillUncomressed(path:String)
			return ((path.lastIndexOf( ".png" ) >= 0) || (path.lastIndexOf( ".jpg" ) >= 0));

		var depack = false;

		#if flash
		if ( shouldDepack(path))
			depack = true;

		//usually because not supported by driver
		if ( !depack && isStillUncomressed(path)) {
			var npath = resolveDepackBitmapData(path);
			if ( npath != path){
				depack = true;
				path = npath;
			}
		}
		#end

		if ( isStillUncomressed(path) ) {
			
			#if (flash)
			
			if ( openfl.Assets.exists(StringTools.replace(path, ".png", ".png.bin") ) )
			{
				path = StringTools.replace(path, ".png", ".png.bin");
				
				var textureBytes = openfl.Assets.getBytes(path);
				if ( textureBytes == null) throw "Impossible to read PNG file : " + path;
				
				var bytes = mt.ByteConversions.byteArray2Bytes(textureBytes);
				var i = new haxe.io.BytesInput(bytes);
				var data = new format.png.Reader(i).read();
				var bytes = format.png.Tools.extract32(data);
				var h = format.png.Tools.getHeader(data);			
				var view = new hxd.BytesView(bytes, 0, bytes.length);
				var pixels = new hxd.Pixels(h.width, h.height, view, hxd.PixelFormat.BGRA);
				return function(){
					return h2d.Tile.fromPixels(pixels);
				}
			}
			else // no luck, so let's go with crappy BitmapData pre multiplication information loss
			{
				var bmpData = openfl.Assets.getBitmapData(path, true);
				var bmp = hxd.BitmapData.fromNative( bmpData );
				return function(){
					return h2d.Tile.fromBitmap( bmp );
				}
			}
			#else
			var bmpData = openfl.Assets.getBitmapData(path, true);
			var bmp = hxd.BitmapData.fromNative( bmpData );

			if ( 	hxd.Math.nextPow2(bmp.width) != bmp.width
			||		hxd.Math.nextPow2(bmp.height) != bmp.height )
				hxd.System.trace1("Texture "+path+" is not SPOT, this is a very BIG issue for mobile/flash targets (upload speed,shader perf)");

			return function(){
				return h2d.Tile.fromBitmap( bmp );
			}
			#end
		}
		else {
			if ( USE_CACHE && ALL_PIXELS.exists( path ) )
				return function() return ALL_PIXELS.get( path );

			if ( DEBUG) trace("mt.Assets : loading pvr: "+path);
			hxd.Profiler.begin("mt.Assets.pvr.getTexture");

			var pix = getPVRPixels( path, depack );
			hxd.Profiler.end("mt.Assets.pvr.getTexture");

			inline function withoutExtensions(p:String) {
				return p.split(".")[0];
			}

			var f : String = withoutExtensions(path);
			var meta = null;
			var metaPath : String = f+".meta.json";
			if ( openfl.Assets.exists( metaPath ) ) {
				var data = haxe.Json.parse(openfl.Assets.getText(metaPath));
				meta = { height: Reflect.field(data, "height"), width: Reflect.field(data, "width") };
			}

			return function(){
				#if (retain_texture || flash)
				var retain = true;
				#else
				var retain = forceRetain;
				#end
				var tex = PVRTexture.fromPixels( pix, isHalf );
				if( retain )
					tex.pixels = pix;
				pix = null;
				tex.name = path;
				tex.realloc = function(){
					if( tex.pixels != null && tex.pixels.bytes != null ){
						tex.uploadPixels(tex.pixels);
					}else{
						if( DEBUG ) trace("mt.Assets : realloc pvr: "+path);
						tex.uploadPixels( getPVRPixels(path,depack) );
					}
				}
				tex.reallocMT = function(){
					if( tex.pixels!=null && tex.pixels.bytes != null )
						return function() tex.uploadPixels(tex.pixels);
					else{
						var pixels = getPVRPixels(path,depack);
						return function() tex.uploadPixels(pixels);
					}
				}
				var tile =  new h2d.Tile(tex, 0, 0, tex.width, tex.height);

				if (meta != null)
					tile.scaleToSize(meta.width,meta.height);

				if( USE_CACHE )
					ALL_PIXELS.set(path, tile);

				return tile;
			}
		}
	}

	static public function getTileDeferred(path:String, worker:mt.Worker, onTile:h2d.Tile->Void, forceRetain=false) : Void {
		var f;
		var t = new mt.Worker.WorkerTask( function() f = getTile(path,forceRetain) );
		t.onComplete = function(){
			onTile(f());
		};
		worker.enqueue( t );
	}

	static function getPVRPixels( path, depack ){
		var mipmapCount;

		// Allocations in subfunction for GC
		function getPackPixels() {
			var ba = openfl.Assets.getBytes(path);
			if ( ba == null) return null;
			var bytes = hxd.ByteConversions.byteArrayToBytes(ba);
			if ( path.lastIndexOf( ".z" ) >= 0 )
				bytes = haxe.zip.Uncompress.run(bytes);
			var t = new hxd.fmt.pvr.Reader(bytes);
			var d : hxd.fmt.pvr.Data = t.read();

			mipmapCount = d.mipmapCount;
			return d.toPixels();
		}
		var pix = getPackPixels();
		if ( pix == null) throw "no such image "+path;
		if ( depack && mipmapCount <= 1) {
			var npix = hxd.Pixels.alloc(pix.width, pix.height, BGRA);

			var pw = pix.width;
			var ph = pix.height;
			var ba = hxd.ByteConversions.bytesViewToByteArray( pix.bytes );
			ba.position = pix.bytes.position;

			var format = pix.format;

			var is4444 	= switch( format) { case Mixed(4, 4, 4, 4):true; default:false; };
			var is565 	= switch( format) { case Mixed(5, 6, 5, 0):true; default:false; };
			var is5551 	= switch( format) { case Mixed(5, 5, 5, 1):true; default:false; };

			var mask4	= (1 << 4) - 1;
			var mask5	= (1 << 5) - 1;
			var mask6	= (1 << 6) - 1;

			//rgba 4:4:4:4
			//bgra 8:8:8:8
			if ( is4444 )
				for ( y in 0...pix.height) {
					for ( x in 0...pix.width){
						var idx = (x + y * pw) << 2;
						var b0 = ba.readUnsignedByte();
						var b1 = ba.readUnsignedByte();
						var dword = b0 | (b1<<8);

						//rgba
						var a = (dword ) 		& mask4;
						var b = (dword >>> 4) 	& mask4;
						var g = (dword >>> 8) 	& mask4;
						var r = (dword >>> 12) 	& mask4;

						npix.bytes.set( idx, 	(b<<4)|b);
						npix.bytes.set( idx+1, 	(g<<4)|g);//r
						npix.bytes.set( idx+2, 	(r<<4)|r);//g
						npix.bytes.set( idx+3, 	(a<<4)|a);//b
					}
				}

			else if ( is565 )
				for ( y in 0...pix.height) {
					for ( x in 0...pix.width){
						var idx = (x + y * pw) << 2;
						var b0 = ba.readUnsignedByte();
						var b1 = ba.readUnsignedByte();
						var dword = b0 | (b1<<8);

						var b = (dword ) 		& mask5;
						var g = (dword >>> 5) 	& mask6;
						var r = (dword >>> 11) 	& mask5;

						npix.bytes.set( idx, 	(b<<3) | (b>>2));
						npix.bytes.set( idx+1, 	(g<<2) | (g>>3));//r
						npix.bytes.set( idx+2, 	(r<<3) | (g>>2));//g

						npix.bytes.set( idx+3, 	0xFF);//b
					}
				}

			else if ( is5551 )
				for ( y in 0...pix.height) {
					for ( x in 0...pix.width){
						var idx = (x + y * pw) << 2;
						var b0 = ba.readUnsignedByte();
						var b1 = ba.readUnsignedByte();
						var dword = b0 | (b1<<8);

						//rgba
						var a = (dword ) 		& 1;
						var b = (dword >>> 1) 	& mask5;
						var g = (dword >>> 6) 	& mask5;
						var r = (dword >>> 11) 	& mask5;

						npix.bytes.set( idx, 	(b<<3)|(b>>2));
						npix.bytes.set( idx+1, 	(g<<3)|(g>>2));//r
						npix.bytes.set( idx+2, 	(r<<3)|(r>>2));//g
						npix.bytes.set( idx+3, 	a>0?0xFF:0);//b
					}
				}

			pix = npix;
		}

	#if cpp
		cpp.vm.Gc.run( true );
	#end

		return pix;
	}
}
