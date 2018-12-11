package mt;


/**
 * All available haxe/openfl platforms
 */
enum PlatformName {
	Flash;
	Android;
	Ios;
	Air;
	Cpp;
	Neko;
	Javascript;
	Unknown;
}


class Platform {

	public static function getCurrent():PlatformName {
		#if flash
		return Flash;
		#elseif android
		return Android;
		#elseif ios
		return Ios;
		#elseif air
		return Air;
		#elseif cpp
		return Cpp;
		#elseif neko
		return Neko;
		#elseif javascript
		return Javascript;
		#else
		return Unknown;
		#end
	}

	public static function getSystemName():String {
		#if sys
		return Sys.systemName();
		#elseif flash
		return flash.system.Capabilities.os + " ( Flash player " +flash.system.Capabilities.version + ")";
		#elseif javascript
		return js.Browser.navigator.appName+" " + js.Browser.navigator.appVersion;
		#else
		return "unknown system";
		#end
	}

}