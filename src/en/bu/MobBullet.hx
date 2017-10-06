package en.bu;

import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import hxd.Key;

class MobBullet extends en.Bullet {
	private function new() {
		super(0,0);
		spr.anim.playAndLoop("mobBullet").setSpeed(0.4);
		ignoreColl = true;
	}

	public static function autoAim(from:Entity) {
		var e = new en.bu.MobBullet();
		e.setPosPixel(from.centerX, from.centerY);
		var a = Math.atan2(e.game.hero.centerY-e.rnd(10,16)-e.centerY, e.game.hero.centerX-e.centerX);
		var s = 0.05;
		e.dx = Math.cos(a)*s;
		e.dy = Math.sin(a)*s;
		return e;
	}

	public static function linear(from:Entity, a:Float, s=1.0) {
		var e = new en.bu.MobBullet();
		e.spr.anim.playAndLoop("mobBulletAlt").setSpeed(0.4);
		e.setPosPixel(from.centerX, from.centerY);
		e.dx = Math.cos(a)*s*0.05;
		e.dy = Math.sin(a)*s*0.05;
		return e;
	}

	public static function linearLD(x:Float, y:Float, a:Float, s=1.0) {
		var e = new en.bu.MobBullet();
		e.spr.anim.playAndLoop("mobBulletAlt").setSpeed(0.4);
		e.setPosPixel(x,y);
		e.dx = Math.cos(a)*s*0.06;
		e.dy = Math.sin(a)*s*0.06;
		return e;
	}

	override function physicsUpdate() {
		super.physicsUpdate();
	}

	override public function postUpdate() {
		super.postUpdate();
		if( spr.is("mobBulletAlt") )
			spr.rotation = Math.atan2(dy,dx);
	}

	function onBulletHit(e:Entity) {
		e.hit(dmg);
		destroy();
	}

	override function onStep() {
		super.onStep();
		if( !game.hero.destroyed && dist(game.hero)<=game.hero.radius )
			onBulletHit(game.hero);
	}

	override public function update() {
		super.update();
	}
}
