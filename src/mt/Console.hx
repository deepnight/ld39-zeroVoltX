package mt;

class Console {
	public static var MAX_LOGS:Int = 250;

	public static var ENABLED:Bool = true;
	
	static var BUFFER : Array<{s: String, t: Float, i: haxe.PosInfos}> = [];
	public static function dump(?max:Int):String {
		var b = max!=null ? BUFFER.slice(-max) : BUFFER;
		return b.map(function(o) return "[time: "+o.t+"] "+o.s).join("\n");
	}

	public static function flushBuffer(){
		if( BUFFER.length == 0 )
			return null;
		var b = BUFFER;
		BUFFER = [];
		return b;
	}
	
	static function i_trace(str, infos) {
		if ( ENABLED == false ) return;
		
		if ( BUFFER.length >= MAX_LOGS ) BUFFER.shift();
		
		var t = #if flash flash.Lib.getTimer(); #elseif lime  lime.system.System.getTimer(); #else Sys.time() * 0.001; #end

		BUFFER.push({s: str, t: t, i: infos});

		str = "[time:" + t + "] " + str;
		//forward trace to native trace only in a verbose mode. Otherwise the log remains in console frame only	
		#if (mBase && !standalone && !air)
			if( BaseConst.VERBOSE ) Device.trace(str,infos);
		#elseif gameBase
			#if !standalone if( Config.VERBOSE ) Device.trace(str,infos);
			#else
				if( Config.VERBOSE ) trace(str,infos);
			#end
		#elseif debug
			haxe.Log.trace(str, infos);
		#end
	}
	
	//NOTE if noConsoleLogs, the function call to dbg will be empty after inlining, and haxe is able to optimize and remove the function call
	inline public static function dbg(str, ?infos:haxe.PosInfos ) { 
		#if (debug && !noConsoleLogs)
		i_trace(str,infos);
		#end
	}
	
	inline public static function log(str, ?infos:haxe.PosInfos) { 
		#if (!noConsoleLogs)
		i_trace(str, infos);
		#end
	}

	#if mBase
	inline public static function mdbg(str, ?infos:haxe.PosInfos) {
		#if (debug && !noConsoleLogs)
		if( BaseConst.MBASE_LOG ) i_trace(str,infos);
		#end
	}

	inline public static function mlog(str, ?infos:haxe.PosInfos) { 
		#if (!noConsoleLogs)
		if( BaseConst.MBASE_LOG ) i_trace(str,infos);
		#end
	}
	#elseif gameBase
	inline public static function mdbg(str, ?infos:haxe.PosInfos) {
		#if (debug && !noConsoleLogs)
		if( Config.BASE_LOG ) i_trace(str,infos);
		#end
	}

	inline public static function mlog(str, ?infos:haxe.PosInfos) { 
		#if (!noConsoleLogs)
		if( Config.BASE_LOG ) i_trace(str,infos);
		#end
	}
	#end
	
}
