package en.m;

import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import hxd.Key;

class Turret extends en.Mob {
	public function new(x,y) {
		super(x,y);
		setLife(100);
		speed = 0;
		spr.anim.playAndLoop("turret").setSpeed(0.2);
		cd.setS("shoot", rnd(0,1));
		followScroll = false;
		shadow.remove();
		shadow = null;

		var e = Assets.tiles.hbe_get(lvl.sb,"structure");
		e.setCenterRatio(0.5,0);
		e.setPos(centerX, centerY+20);
	}

	override function onDie() {
		super.onDie();
		game.addScore(this,100);
		Assets.SBANK.explo04(1);
		fx.bigExplode(centerX, centerY);
		lvl.createCrater(centerX, centerY, 1);
	}

	override public function dispose() {
		super.dispose();
	}

	override function checkOffScreen() {
		if( cy>game.vp.bottomCy )
			destroy();
	}

	override function onTouchHero() {}

	override public function postUpdate() {
		super.postUpdate();
		spr.y+=10;
	}

	var shots = 0;
	override public function update() {
		super.update();

		if( isOnScreen(-2) && !cd.has("shoot") ) {
			en.bu.MobBullet.autoAim(this);
			shots++;
			if( shots>=5 ) {
				shots = 0;
				cd.setS("shoot",rnd(2,3));
			}
			else
				cd.setS("shoot",0.4);
		}
	}
}
