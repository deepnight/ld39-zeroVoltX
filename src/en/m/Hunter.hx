package en.m;

import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import hxd.Key;

class Hunter extends en.Mob {
	public function new(x,y) {
		super(x,y);
		setLife(25);
		speed = 2;
		spr.anim.playAndLoop("hunter").setSpeed(0.2);
		cd.setS("shoot", rnd(0,1));
		cd.setS("spread", 1);
	}

	override function generatePlan() {
		var rlist = new mt.RandList( wave.makeRand().random );
		rlist.add("D4 _3 RD2/1 _2 LD2/1 _3 RD2/2 _2 D1",1);
		rlist.add("D3 _2 RD4/3 _3 LD3/1 _2 RD2/2 _2 D1",1);
		return rlist.draw();
	}

	override function onDie() {
		super.onDie();
		Assets.SBANK.explo06(rnd(0.4,0.6));
		game.addScore(this,1000);
		fx.explode(centerX, centerY);
	}

	override public function dispose() {
		super.dispose();
	}


	var allow = true;
	override public function update() {
		super.update();

		if( MLib.fabs(dx)+MLib.fabs(dy)<=0.01 ) {
			if( isOnScreen(-1) && !cd.has("spread") && allow ) {
				var n = 8;
				for( i in 0...n ) {
					en.bu.MobBullet.linear(this, 6.28*i/n, 2);
				}
				allow = false;
			}
		}
		else
			allow = true;
		//if( isOnScreen(-1) && !cd.hasSetS("shoot", rnd(3,5)) )
			//en.bu.MobBullet.autoAim(this);
	}
}
