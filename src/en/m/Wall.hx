package en.m;

import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import hxd.Key;

class Wall extends en.Mob {
	public function new(x,y) {
		super(x,y);
		setLife(60);
		speed = 0;
		aimPrio = -20;
		spr.anim.playAndLoop("wall").setSpeed(0.2);
		followScroll = false;
		shadow.remove();
		shadow = null;

		var e = Assets.tiles.hbe_get(lvl.sb,"wallBase");
		e.setCenterRatio(0.5,0);
		e.setPos(centerX, centerY-2);
	}

	override function hitSound() {
		Assets.SBANK.hit02(0.2);
	}

	override function onDie() {
		super.onDie();
		game.addScore(this,5);
		Assets.SBANK.explo03(1);
		fx.explode(centerX, centerY);
	}

	override function onTouchHero() {}

	override function checkOffScreen() {
		if( cy>game.vp.bottomCy )
			destroy();
	}
 }
