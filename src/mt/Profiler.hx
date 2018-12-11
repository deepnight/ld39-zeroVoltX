package mt;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class ProfilerTag {
	public var tag(default,null): String;
	public var start:Float = -1.;
	public var total:Float = 0.;
	public var hit:Int = 0;

	public function new( tag : String ) {
		this.tag = tag;
	}
}


class Profiler {
	public static var minLimit = -1;// 0.0001;
	
	static var h : haxe.ds.Vector<ProfilerTag>;	
	
	#if macro
	static var maxIndex = 0;
	static var indexes = new haxe.ds.StringMap<Int>();
	
	static function getIndex( tag : String ) {
		if ( indexes.exists(tag) )
			return indexes.get(tag);
		var idx = maxIndex++;
		indexes.set(tag, idx);
		if( idx == 0 ){
			Context.onGenerate(function(_) { 
				var c = haxe.macro.TypeTools.getClass(Context.getType("mt.Profiler"));
				var arr = [];
				for( k in indexes.keys() ){
					arr[ indexes.get(k) ] = k;
				}
				trace( arr );
				c.meta.remove("tags");
				c.meta.add("tags", [macro $v{arr}], Context.currentPos());
				maxIndex = 0;
				indexes = new haxe.ds.StringMap();
			});
		}
		
	
		return idx;
	}
	#else
	public static #if prod inline #end function init() {
		#if !prod
		var a : Array<Array<String>> = cast haxe.rtti.Meta.getType( mt.Profiler ).tags;
		var a = a[0];
		h = new haxe.ds.Vector( a.length );
		for ( i in 0...a.length )
			h.set(i,new ProfilerTag( a[i] ));
		#end
	}
	#end
	
	inline static function stamp() {
		#if flash
			return flash.Lib.getTimer() / 1000;
		#elseif (neko || php)
			return Sys.time();
		#elseif js
			return Date.now().getTime() / 1000;
		#elseif cpp
			return untyped __global__.__time_stamp();
		#elseif sys
			return Sys.time();
		#else
			return 0;
		#end
	}
	
	macro public static function begin( tag : String ) {
		if ( !haxe.macro.Context.defined("prod") ) {
			var idx = getIndex(tag);
			return macro mt.Profiler.__begin($v{idx});
		}
		return macro {};
	}
	
	macro public static function end( tag : String ){
		if ( !haxe.macro.Context.defined("prod") ) {
			var idx = getIndex(tag);
			return macro mt.Profiler.__end($v{idx});
		}
		return macro {};
	}
	
	macro public static inline function clear( tag : String ) {
		if ( !haxe.macro.Context.defined("prod") ) {
			var idx = getIndex(tag);
			return macro mt.Profiler.__clear($v{idx});
		}
		return macro {};
	}	
	
	@:noCompletion
	public static inline function __begin( idx : Int ) {
		var ent = h.get(idx);
		ent.start = stamp();
		ent.hit++;
	}
	
	@:noCompletion
	public static inline function __end( idx : Int ) {
		var ent = h.get(idx);
		if ( ent.start > -1 ){
			ent.total += stamp() - ent.start;
			ent.start = -1;
		}
	}
	
	@:noCompletion
	static inline function __clear( idx : Int ) {
		#if !prod
		var ent = h.get(idx);
		ent.total = ent.hit = 0;
		ent.start = -1;
		#end
	}

	public static function clean(){
		#if !prod
		for ( ent in h ){
			ent.total = 0.;
			ent.hit = 0;
			ent.start = -1.0;
		}
		#end
	}
	
	public static function dump( ?trunkValues : Bool = true ) : String {
		#if prod
		return null;
		#else
		var s = "";
		
		var k = 10000.0;
		
		#if !mobile
		k *= 10.0;
		#end
		
		function trunk(v:Float) return trunkValues ? (Std.int( v * k ) / k) : v;
		var maxLen = 0;
		var arr = [];
		for ( ent in h ) {
			if( ent.hit > 0 && ent.total > minLimit ){
				arr.push(ent);
				if( ent.tag.length > maxLen )
					maxLen = ent.tag.length;
			}
		}
		arr.sort(function(a, b) return Reflect.compare(a.total , b.total));
		
		for ( ent in arr )
			s += (StringTools.rpad(ent.tag," ",maxLen)+" total: " + trunk(ent.total))+" hit: "+ent.hit+" avg: "+ trunk(ent.total/ent.hit) + "\n";
		return s;
		#end
	}
}