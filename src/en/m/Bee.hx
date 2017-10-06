package en.m;

import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import hxd.Key;

class Bee extends en.Mob {
	public function new(x,y) {
		super(x,y);
		setLife(24);
		speed = 0.9;
		spr.anim.playAndLoop("bee").setSpeed(0.2);
		cd.setS("shoot", rnd(0,1));
	}

	override function generatePlan() {
		var rlist = new mt.RandList( wave.makeRand().random );
		rlist.add("R14 U2 L1",1);
		rlist.add("R12 (D3 L8 D3 R8)x2 D1",1);
		rlist.add("s1 R10 s2 U3 s1 L6 D1",1);
		return rlist.draw();
	}

	override function onDie() {
		super.onDie();
		fx.explode(centerX, centerY);
		Assets.SBANK.explo08(rnd(0.4,0.6));
		game.addScore(this,250);
	}

	override public function dispose() {
		super.dispose();
	}


	override function onFollowPlan(xDir:Int, yDir:Int) {
		super.onFollowPlan(xDir, yDir);
		var ta = xDir==1 ? 0 : xDir==-1 ? -3.14 : yDir==1 ? 1.57 : yDir==-1 ? -1.57 : spr.rotation;
		if( !isOnScreen(0) )
			spr.rotation = ta;
		else
			spr.rotation += Lib.angularSubstractionRad(ta,spr.rotation)*0.2;
	}

	override public function update() {
		super.update();

		if( isOnScreen(-1) && !cd.hasSetS("shoot", rnd(1,3)) )
			en.bu.MobBullet.autoAim(this);
	}
}
