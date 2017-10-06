package en.m;

import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import hxd.Key;

class Hammer extends en.Mob {
	var beam0 : en.LazerBeam;
	var beam1 : en.LazerBeam;

	public function new(x,y) {
		super(x,y);
		isBig = true;
		setLife(550); // 440
		radius = 26;
		speed = 0.4;
		aimPrio = 10;
		spr.set("hammer");
		beam0 = new en.LazerBeam(this, -15, 9, 1.57);
		beam1 = new en.LazerBeam(this, 11, 14, 1.57);
		cd.setS("lazer", rnd(3,4));
	}

	override function onDie() {
		super.onDie();
		for(i in 0...3)
			game.delayer.addS( function() Assets.SBANK.explo05(1), i*rnd(0.05,0.08) );
		fx.bigExplode(centerX, centerY);
		lvl.createCrater(centerX, centerY, rnd(1.2,1.3));
		game.addScore(this,15000);
	}

	override function hitSound() {
		Assets.SBANK.hit05(0.2);
	}

	override function generatePlan() {
		var rlist = new mt.RandList( wave.makeRand().random );
		rlist.add("D4 _4 R2 _5 L4 _5 R4 _5 D1",1);
		return rlist.draw();
	}

	override public function dispose() {
		super.dispose();
	}

	override public function postUpdate() {
		super.postUpdate();
		//if( beam0.isShooting() && cd.hasSetS("highlight",rnd(0.03,0.1)) )
		if( beam0.isShooting() )
			spr.setFrame(1);
			//spr.setFrame( spr.frame==0 ? 1 : 0);
		else
			spr.setFrame(0);
	}


	override public function update() {
		super.update();
		if( beam0.destroyed )
			beam0 = null;

		if( !cd.hasSetS("lazer", rnd(9,10)) ) {
			beam0.run(1.5, 2);
			beam1.run(1.5, 2);
		}

		if( !beam0.isWorking() && !cd.hasSetS("shoot", 0.7)  )
			en.bu.MobBullet.autoAim(this);

		if( beam0.isHitting(game.hero) || beam1.isHitting(game.hero) )
			game.hero.hit(1);
	}
}
