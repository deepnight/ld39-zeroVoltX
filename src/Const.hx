class Const {
	#if !debug
	public static var GIF_MODE = false;
	#else
	//public static var GIF_MODE = false;
	public static var GIF_MODE = true;
	#end
	public static var FPS = 60;
	public static var GRID = 18;
	public static var SCALE = 1;
	public static var GRAVITY = 0.027;
	public static var INFINITE = 999999;
	public static var VWID = 18; //324
	public static var VHEI = 16; //288

	static var _inc = 0;
	public static var DP_BG = _inc++;
	public static var DP_FX_BG = _inc++;
	public static var DP_ENT = _inc++;
	public static var DP_FX_TOP = _inc++;
	public static var DP_HERO = _inc++;
	public static var DP_UI = _inc++;
	public static var DP_TOP = _inc++;
}