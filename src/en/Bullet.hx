package en;

import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import hxd.Key;

class Bullet extends Entity {
	public var dmg : Int;
	private function new(x,y) {
		super(x,y);
		frict = 1;
		dmg = 1;
		//spr.anim.play("mobBullet").loop();
	}

	override function onHitWall() {
		super.onHitWall();
		destroy();
	}

	override public function update() {
		super.update();
		if( !isOnScreen(3) )
			destroy();
	}
}
