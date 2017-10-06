package en;

import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import hxd.Key;

class LazerBeam extends Entity {
	static var CHARGE : mt.deepnight.Sfx;
	static var LOOP : mt.deepnight.Sfx;

	var owner : Entity;
	public var dmg : Int;
	public var ang : Float;
	var glow : HSprite;

	var beamX(get,never) : Float;
	var beamY(get,never) : Float;
	public var offX : Float;
	public var offY : Float;

	var wid = 12;

	private function new(e:Entity, ox:Float, oy:Float, ang:Float) {
		super(0,0);
		if( LOOP==null ) {
			CHARGE = Assets.SBANK.charge03();
			LOOP = Assets.SBANK.beam01();
		}
		owner = e;
		offX = ox;
		offY = oy;
		this.ang = ang;
		followScroll = true;
		setPosPixel(beamX,beamY);
		dmg = 1;

		spr.set("beam");
		spr.rotation = ang;
		spr.setPivotCoord(3, spr.tile.height*0.5);
		spr.visible = false;

		glow = Assets.tiles.h_get("beamGlow");
		game.scroller.add(glow, Const.DP_FX_BG);
		glow.blendMode = Add;
		glow.setPivotCoord(3, glow.tile.height*0.5);
		glow.visible = false;
	}

	public function run(chargeS:Float, durationS:Float) {
		cd.setS("charge", chargeS);
		cd.setS("alive", chargeS+durationS);
		CHARGE.play(0.4);
	}

	inline function get_beamX() return owner.centerX+offX;
	inline function get_beamY() return owner.centerY+offY;

	override public function dispose() {
		super.dispose();
		glow.remove();
		LOOP.stop();
		CHARGE.stop();
	}

	override public function postUpdate() {
		super.postUpdate();
		glow.setPos(spr.x, spr.y);
		glow.rotation = spr.rotation;
	}

	public function isHitting(e:Entity) {
		if( !e.destroyed && cd.has("alive") && !cd.has("charge") ) {
			var da = Lib.angularDistanceRad(ang, Math.atan2(e.centerY-centerY,e.centerX-centerX));
			if( da>=1.57 )
				return false;
			return dist(e) * Math.sin(da) <= wid-2;
		}
		return false;
	}

	public function interrupt() {
		cd.unset("charge");
		cd.unset("alive");
	}

	public inline function isWorking() return cd.has("alive") || cd.has("charge");
	public inline function isShooting() return cd.has("alive") && !cd.has("charge");

	override public function update() {
		super.update();
		setPosPixel(beamX,beamY);
		spr.rotation = ang;
		if( owner.destroyed ) {
			destroy();
			return;
		}

		if( cd.has("charge") ) {
			spr.visible = true;
			glow.visible = false;
			spr.alpha = rnd(0.15,0.4);
			spr.scaleY = 0.2 + 0.1*MLib.fabs(Math.cos(ftime*0.2));
		}
		else if( cd.has("alive") ) {
			if( !LOOP.isPlaying() )
				LOOP.play(true,0.7);
			spr.alpha = 1;
			spr.scaleY = rnd(0.9,1.1);
			glow.visible = true;
			glow.scaleX = rnd(1,1.3);
			glow.alpha = rnd(0.1,0.3);
			if( !cd.hasSetS("flash",rnd(0.1,0.2)) )
				fx.flashBangS(0x0080FF,0.03, 0.1);
		}
		else if( !cd.has("alive") ) {
			LOOP.stop();
			glow.visible = false;
			spr.scaleY*=0.6;
			spr.alpha*=0.7;
			if( spr.scaleY<=0.1 )
				spr.visible = false;
		}
	}
}
