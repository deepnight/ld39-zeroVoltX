import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;

class Entity {
	public static var UNIQ = 0;
	public static var ALL : Array<Entity> = [];
	public static var GC : Array<Entity> = [];

	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var lvl(get,never) : Level; inline function get_lvl() return Game.ME.lvl;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;
	public var ftime(get,never) : Float; inline function get_ftime() return Game.ME.ftime;

	public var spr : HSprite;
	public var cd : mt.Cooldown;
	public var delayer : mt.Delayer;

	public var id : Int;

	public var cx : Int;
	public var cy : Int;
	public var xr : Float;
	public var yr : Float;
	public var dx : Float;
	public var dy : Float;
	public var radius(default,set) : Float;
	public var dir(default,set) : Int;
	var frict : Float;

	public var life : Int;
	public var maxLife : Int;

	public var centerX(get,never) : Float;
	public var centerY(get,never) : Float;
	public var startDist(get,never) : Float;

	public var onGround(get,never) : Bool;
	public var onGroundRecently(get,never) : Bool;
	public var destroyed : Bool;
	public var hasGravity : Bool;
	public var ignoreColl : Bool;
	public var followScroll : Bool;

	public var isInteractive : Bool;
	public var focusPriority : Float;

	var debug : Null<h2d.Graphics>;
	var invalidateDebug = true;
	var shadow : Null<HSprite>;

	var label : Null<h2d.Text>;

	public function new(x,y) {
		id = UNIQ++;
		ALL.push(this);
		isInteractive = false;
		ignoreColl = true;
		focusPriority = 0;
		cx = x;
		cy = y;
		xr = 0.5;
		yr = 1;
		dx = dy = 0;
		dir = 1;
		frict = 0.5;
		radius = Const.GRID*0.5;
		hasGravity = false;
		followScroll = false;
		setLife(1);

		cd = new mt.Cooldown(Const.FPS);
		delayer = new mt.Delayer(Const.FPS);

		spr = new mt.heaps.slib.HSprite(Assets.tiles);
		game.scroller.add(spr,Const.DP_ENT);
		spr.setCenterRatio(0.5,0.5);

		#if debug
		debug = new h2d.Graphics();
		game.scroller.add(debug, Const.DP_UI);
		#end
	}

	public function initShadow() {
		if( shadow!=null )
			shadow.remove();
		shadow = new mt.heaps.slib.HSprite(spr.lib, spr.groupName, spr.frame);
		game.scroller.add(shadow, Const.DP_BG);
		shadow.colorAdd = new h3d.Vector(-1,-1,-1);
		shadow.alpha = 0.9;

	}

	inline function get_startDist() {
		return lvl.hei-cy;
	}

	public function setLife(v:Int) {
		life = maxLife = v;
	}

	public function blink() {
		spr.colorAdd = h3d.Vector.fromColor(0xFFffffff);
	}

	public function hit(dmg:Int) {
		blink();
		life-=dmg;
		if( life<=0 && !destroyed ) {
			life = 0;
			onDie();
		}
	}

	inline function set_radius(v) {
		invalidateDebug = true;
		return radius = v;
	}
	public function renderDebug() {
		invalidateDebug = false;
		debug.clear();
		debug.visible = Boot.ME.debugEnt;
		debug.lineStyle(1, mt.deepnight.Color.makeColorHsl(id/15), 0.8);
		debug.drawCircle(0,0,radius);
	}

	function onDie() {
		destroy();
	}

	public function isOnScreen(cPadding=1) {
		return
			cx>=-cPadding
			&& cx<lvl.wid+cPadding
			&& centerY>=game.vp.topY-cPadding*Const.GRID
			&& centerY<game.vp.bottomY+cPadding*Const.GRID;
	}

	public function toString() return Type.getClassName(Type.getClass(this))+"#"+id;

	inline function set_dir(v) return dir = v==0? dir : v>0 ? 1 : -1;
	inline function get_onGround() return yr==1 && dy==0 && lvl.hasColl(cx,cy+1);
	inline function get_onGroundRecently() return onGround || cd.has("onGroundRecent");
	inline function get_centerX() return (cx+xr)*Const.GRID;
	inline function get_centerY() return (cy+yr)*Const.GRID;

	public inline function is(t:Class<Entity>) return Std.is(this, t);

	public inline function rnd(min,max,?s) return Lib.rnd(min,max,s);
	public inline function irnd(min,max,?s) return Lib.irnd(min,max,s);
	public inline function pretty(v,?p=2) return Lib.prettyFloat(v,p);

	public inline function dirTo(e:Entity) return e.centerX>centerX ? 1 : -1;
	public inline function dist(?e:Entity, ?x:Float, ?y:Float) {
		return Lib.distance(centerX, centerY, e!=null ? e.centerX : x, e!=null ? e.centerY : y);
	}
	public inline function distCase(?e:Entity, ?x:Int, ?y:Int) {
		return ( e!=null ? dist(e) : Lib.distance(centerX, centerY, (x+0.5)*Const.GRID, (y+0.5)*Const.GRID) ) / Const.GRID;
	}
	public inline function sightCheck(?e:Entity, ?x:Int, ?y:Int) {
		return mt.deepnight.Bresenham.checkThinLine(cx,cy, e!=null?e.cx:x, e!=null?e.cy:y, function(x,y) return !lvl.hasColl(x,y) );
	}

	public function setPosCase(x,y) {
		cx = x;
		cy = y;
		xr = 0.5;
		yr = 0.5;
	}

	public function setPosPixel(x:Float,y:Float) {
		cx = Std.int(x/Const.GRID);
		cy = Std.int(y/Const.GRID);
		xr = (x-cx*Const.GRID) / Const.GRID;
		yr = (y-cy*Const.GRID) / Const.GRID;
	}

	public function setPosAtColor(c:UInt) {
		var pt = lvl.getPixel(c);
		setPosCase(pt.cx, pt.cy);
	}

	public function onInteract() { }

	public function setLabel(?str:Dynamic, ?col=0xFFFFFF) {
		if( label!=null ) {
			label.remove();
			label = null;
		}

		if( str!=null && !Const.GIF_MODE ) {
			label = new h2d.Text(Assets.font);
			game.scroller.add(label, Const.DP_UI);
			label.text = Std.string(str);
			label.textColor = col;
		}
	}

	public inline function destroy() {
		if( !destroyed ) {
			GC.push(this);
			destroyed = true;
		}
	}

	public function dispose() {
		if( debug!=null )
			debug.remove();

		if( shadow!=null )
			shadow.remove();

		ALL.remove(this);
		spr.remove(); spr = null;
		cd.destroy(); cd = null;
		delayer.destroy(); delayer = null;
		setLabel();
	}

	public function postUpdate() {
		if( spr.colorAdd!=null ) {
			spr.colorAdd.r*=0.6;
			spr.colorAdd.g*=0.6;
			spr.colorAdd.b*=0.6;
			if( spr.colorAdd.r<=0.03 && spr.colorAdd.g<=0.03 && spr.colorAdd.b<=0.03 )
				spr.colorAdd = null;
		}
		if( shadow!=null ) {
			shadow.set(spr.lib, spr.groupName, spr.frame);
			shadow.pivot.copyFrom(spr.pivot);
			shadow.setPos(spr.x, spr.y+12);
			shadow.rotation = spr.rotation;
			shadow.scaleX = spr.scaleX*0.8;
			shadow.scaleY = spr.scaleY*0.8;
		}
		spr.x = Std.int((cx+xr)*Const.GRID);
		spr.y = (cy+yr)*Const.GRID;
		//spr.x = Std.int((cx+xr)*Const.GRID);
		//spr.y = Std.int((cy+yr)*Const.GRID);
		spr.scaleX = MLib.fabs(spr.scaleX) * dir;

		if( debug!=null ) {
			if( invalidateDebug && Boot.ME.debugEnt )
				renderDebug();
			debug.setPos(centerX, centerY);
		}

		if( label!=null )
			label.setPos( centerX-label.textWidth*0.5, centerY+radius+1 );
	}

	public function preUpdate() {
		cd.update(1);
		delayer.update(1);
	}

	function onStep() {}
	function onHitWall() {}

	var maxStep = 0.4;
	function physicsUpdate() {
		if( hasGravity && !onGround )
			dy+=Const.GRAVITY;

		var steps = MLib.fabs(dx)<=maxStep ? 1 : MLib.ceil(MLib.fabs(dx/maxStep));
		steps = MLib.max( steps, MLib.fabs(dy)<=maxStep ? 1 : MLib.ceil(MLib.fabs(dy/maxStep)) );
		if( followScroll && game.scFrame )
			yr-=game.scPixel;
		for(i in 0...steps) {
			if( destroyed )
				return;

			// X
			xr+=dx/steps;
			if( !ignoreColl ) {
				if( xr>0.8 && lvl.hasColl(cx+1,cy) ) {
					xr = 0.8;
					dx = 0;
					onHitWall();
				}
				if( xr<0.2 && lvl.hasColl(cx-1,cy) ) {
					xr = 0.2;
					dx = 0;
					onHitWall();
				}
			}
			while( xr>1 ) { xr--; cx++; }
			while( xr<0 ) { xr++; cx--; }

			// Y
			yr+=dy/steps;

			if( !ignoreColl ) {
				if( yr>0.8 && lvl.hasColl(cx,cy+1) ) {
					yr = 0.8;
					dy = 0;
					onHitWall();
				}
				if( yr<0.2 && lvl.hasColl(cx,cy-1) ) {
					yr = 0.2;
					dy = 0;
					onHitWall();
				}
			}
			while( yr>1 ) { yr--; cy++; }
			while( yr<0 ) { yr++; cy--; }

			onStep();
		}

		dx*=frict;
		dy*=frict;
		if( MLib.fabs(dx)<=0.001 ) dx = 0;
		if( MLib.fabs(dy)<=0.001 ) dy = 0;
	}


	public function update() {
		if( onGround )
			cd.setS("onGroundRecent",0.1);

		physicsUpdate();
	}
}