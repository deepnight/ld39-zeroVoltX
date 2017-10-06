package en.m;

import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import hxd.Key;

class SmallHeli extends en.Mob {
	static var ALL : Array<SmallHeli> = [];

	var waitDones : Map<Int,Bool>;

	var pWrapper : h2d.Sprite;
	var propel : HSprite;
	var propelBack : HSprite;
	public function new(x,y) {
		super(x,y);
		ALL.push(this);
		waitDones = new Map();
		setLife(8);
		speed = 2.5;
		frict = 0.85;
		spr.anim.playAndLoop("smallHeli").setSpeed(0.2);

		cd.setS("shoot", rnd(0,2));

		pWrapper = new h2d.Sprite();
		pWrapper.scaleY = 0.7;
		game.scroller.add(pWrapper, Const.DP_ENT);
		propel = Assets.tiles.h_get("heliPropel",0, 0.5,0.5, pWrapper);

		propelBack = Assets.tiles.h_get("heliPropel",0, 0.5,0.5, pWrapper);
	}

	override function generatePlan() {
		var rlist = new mt.RandList( wave.makeRand().random );
		rlist.add("R12 D2 L10 D2 R10 D1",1);
		return rlist.draw();
	}

	override function onDie() {
		super.onDie();
		game.addScore(this,25);
		Assets.SBANK.explo10(rnd(0.4,0.6));
		fx.explode(centerX, centerY);
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
		pWrapper.remove();
	}

	override public function postUpdate() {
		super.postUpdate();
		spr.y += Math.sin(id + ftime*0.06)*3;
		pWrapper.setPos(spr.x, spr.y-7);
		propel.alpha = 0.5;
		propel.rotate(-0.8);

		//propelBack.setPos(propel.x, propel.y);
		propelBack.alpha = 0.4;
		propelBack.rotate(0.05);
		dir = dx>0 ? -1 : 1;
	}


	override function onPlanCmdStart(inst:Plan.WaveInstruction) {
		super.onPlanCmdStart(inst);
		if( inst.cmd=="_" ) {
			if( waitDones.exists(cx) )
				return false;

			for(e in en.m.SmallHeli.ALL)
				if( e.wave==wave && e!=this ) {
					e.waitDones.set( cx, true );
					e.cd.setS("pausePlan", inst.a);
				}
		}
		return true;
	}


	override function onFollowPlan(xDir:Int, yDir:Int) {
		super.onFollowPlan(xDir, yDir);
		//var ta = xDir==1 ? 0 : xDir==-1 ? -3.14 : yDir==1 ? 1.57 : yDir==-1 ? -1.57 : spr.rotation;
		//if( !isOnScreen(0) )
			//spr.rotation = ta;
		//else
			//spr.rotation += Lib.angularSubstractionRad(ta,spr.rotation)*0.2;
	}

	override public function update() {
		super.update();

		if( isOnScreen(-1) && !cd.hasSetS("shoot",rnd(4,7)) )
			en.bu.MobBullet.linear(this, 1.57);
	}
}
