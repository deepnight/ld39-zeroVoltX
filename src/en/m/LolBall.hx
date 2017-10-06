package en.m;

import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import hxd.Key;

class LolBall extends en.Mob {
	var beams : Array<en.LazerBeam>;
	var ang : Float;
	public function new(x,y) {
		super(x,y);
		setLife(380);
		speed = 0.4;
		ang = 0;
		isBig = true;
		aimPrio = 15;
		beams = [];
		cd.setS("shoot", 5);
		for(a in [0, -1.57, 1.57, 3.14]) {
			var e = new en.LazerBeam(this, 0,0, a);
			beams.push(e);
		}
		spr.anim.registerStateAnim("ballSad", 2, 0.15, function() return life/maxLife<=0.33);
		spr.anim.registerStateAnim("ballLol", 1, 0.35, function() return beams[0].isShooting());
		spr.anim.registerStateAnim("ballHappy", 0);

		var t = 0.3;
		spr.anim.registerTransition("ballHappy","ballLol","ballFill",t);
		spr.anim.registerTransition("ballLol","ballHappy","ballFill",t);
	}

	override function hitSound() {
		Assets.SBANK.hit05(0.2);
	}

	override function generatePlan() {
		var rlist = new mt.RandList( wave.makeRand().random );
		rlist.add("s2 D7 _1 s1 (R4 _1 L4 _1)x4 D1",1);
		return rlist.draw();
	}

	override function onDie() {
		super.onDie();
		game.addScore(this,15000);
		Assets.SBANK.explo05(1);
		fx.explode(centerX, centerY);
	}

	override public function dispose() {
		super.dispose();
	}


	override public function update() {
		super.update();
		if( !cd.hasSetS("lazer",9) ) {
			for(e in beams)
				e.run(2,5);
		}
		if( beams[0].isShooting() )
			//ang+=0.002;
			for(e in beams) {
				if( e.isHitting(game.hero) ) {
					game.hero.hit(1);
					//e.interrupt();
				}
				e.ang+=0.01;
				e.offX = Math.cos(e.ang)*20;
				e.offY = Math.sin(e.ang)*15;
			}
	}
}
