import mt.MLib;
import mt.deepnight.Color;
import mt.heaps.slib.*;

class Bar extends mt.Process {
	var bg : h2d.Graphics;
	var outline : h2d.Graphics;
	var bar : h2d.Graphics;
	public var value : Float;
	public var wid : Int;
	public var hei : Int;

	public var x(get,set) : Float;
	public var y(get,set) : Float;

	public function new(w:Int, h:Int, color:UInt) {
		super(Game.ME);
		value = 0;
		wid = w;
		hei = h;

		createRootInLayers(Game.ME.scroller, Const.DP_UI);

		outline = new h2d.Graphics(root);
		outline.beginFill(0xffffff);
		outline.drawRect(0,0,wid+2,hei+2);
		outline.x = outline.y = -1;

		bg = new h2d.Graphics(root);
		bg.beginFill(0xffffff);
		bg.drawRect(0,0,wid,hei);

		bar = new h2d.Graphics(root);
		bar.beginFill(0xFFFFFF);
		bar.drawRect(0,0,wid,hei);

		setColor(color);
		set(0);
	}

	public function setColor(c:UInt) {
		Color.setVector(outline.color, Color.setLuminosityInt(c, 0.12));
		Color.setVector(bg.color, Color.setLuminosityInt(c, 0.25));
		Color.setVector(bar.color, c);
	}

	inline function set_x(v) return root.x = v;
	inline function get_x() return root.x;
	inline function set_y(v) return root.y = v;
	inline function get_y() return root.y;

	public function set(v:Float) {
		value = MLib.fclamp(v,0,1);
	}

	override function onDispose() {
		super.onDispose();
	}

	override function update() {
		super.update();
		bar.scaleX += (value-bar.scaleX) * (value<bar.scaleX ? 0.4 : 0.15 );
	}
}