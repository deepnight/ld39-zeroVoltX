class Viewport {
	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var lvl(get,never) : Level; inline function get_lvl() return Game.ME.lvl;

	public var elapsedDistCase : Float;
	public var hei : Int;

	public var topCy(get,never) : Int;
	public var bottomCy(get,never) : Int;

	public var topY(get,never) : Float;
	public var bottomY(get,never) : Float;

	public function new() {
		hei = Const.VHEI;
		elapsedDistCase = 1;
	}

	inline function get_topCy() {
		return Std.int( bottomCy-hei+1 );
	}

	inline function get_bottomCy() {
		return Std.int( lvl.hei-1-elapsedDistCase );
	}

	inline function get_topY() {
		return bottomY - (hei-1)*Const.GRID;
	}
	inline function get_bottomY() {
		return ( lvl.hei-1-elapsedDistCase ) * Const.GRID;
	}

	public inline function isOnScreen(x:Float,y:Float, ?padding=20) {
		return
			x>=-padding && x<lvl.wid*Const.GRID+padding &&
			y>=topY-padding && y<bottomY+padding;
	}
}