package en.bu;

import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import hxd.Key;

class HeroBullet extends en.Bullet {
	public function new(dmgBonus:Int) {
		super(0,0);
		this.dmg = 1+dmgBonus;
		spr.set("gunBullet", dmgBonus>0 ? 1 : 0);
		spr.setCenterRatio(0.9,0.5);
	}

	override function physicsUpdate() {
		super.physicsUpdate();
	}

	override public function postUpdate() {
		super.postUpdate();
		spr.rotation = Math.atan2(dy,dx);
	}

	function onHit(e:Entity) {
		fx.hit(centerX, centerY);
		e.hit(dmg);
		destroy();
	}

	override function onStep() {
		super.onStep();
		for(e in en.Mob.ALL)
			if( !e.destroyed && dist(e)<=e.radius ) {
				onHit(e);
				break;
			}
	}

	override public function update() {
		super.update();
	}
}
