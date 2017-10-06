import mt.MLib;
import mt.deepnight.Lib;
class CPoint {
	public var cx : Int;
	public var cy : Int;

	public var centerX(get,never) : Float;
	inline function get_centerX() return (cx+0.5)*Const.GRID;
	public var centerY(get,never) : Float;
	inline function get_centerY() return (cy+0.5)*Const.GRID;

	public function new(x,y) {
		set(x,y);
	}

	public inline function set(x,y) {
		cx = x;
		cy = y;
	}

	public inline function distCase(?e:Entity, ?x:Int, ?y:Int) {
		return e!=null
			? e.distCase(cx,cy)
			: Lib.distance(centerX, centerY, (x+0.5)*Const.GRID, (y+0.5)*Const.GRID) / Const.GRID;
	}
}

