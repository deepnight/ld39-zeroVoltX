package en.m;

import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import hxd.Key;

class Helicopter extends en.Mob {
	static var ALL : Array<Helicopter> = [];

	var waitDones : Map<Int,Bool>;

	var propel : HSprite;
	var propelBack : HSprite;
	public function new(x,y) {
		super(x,y);
		ALL.push(this);
		waitDones = new Map();
		setLife(30);
		speed = 6.5;
		frict = 0.7;
		spr.anim.playAndLoop("heli").setSpeed(0.2);

		propel = Assets.tiles.h_get("heliPropel",0, 0.5,0.5);
		game.scroller.add(propel, Const.DP_ENT);

		propelBack = Assets.tiles.h_get("heliPropel",0, 0.5,0.5);
		game.scroller.add(propelBack, Const.DP_ENT);
	}

	override function generatePlan() {
		var rlist = new mt.RandList( wave.makeRand().random );
		rlist.add("s1.5 R8 s1 LD6/5 _4 R10 LU6/5 _4 L1",1);
		rlist.add("RU2/2 RD10/2 _4 D2 LU10/2 _4 D1",1);
		return rlist.draw();
	}

	override function onDie() {
		super.onDie();
		game.addScore(this,150);
		Assets.SBANK.explo13(1);
		fx.explode(centerX, centerY);
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
		propel.remove();
		propelBack.remove();
	}

	override public function postUpdate() {
		super.postUpdate();
		spr.y += Math.sin(id + ftime*0.06)*3;
		propel.setPos(spr.x, spr.y-2);
		propel.alpha = 0.5;
		propel.rotate(-0.8);

		propelBack.setPos(propel.x, propel.y);
		propelBack.alpha = 0.4;
		propelBack.rotate(0.05);
	}


	override function onPlanCmdStart(inst:Plan.WaveInstruction) {
		super.onPlanCmdStart(inst);
		if( inst.cmd=="_" ) {
			if( waitDones.exists(cx) )
				return false;

			for(e in en.m.Helicopter.ALL)
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

	var side = 1;
	var shots = 0;
	override public function update() {
		super.update();

		if( MLib.fabs(dx)+MLib.fabs(dy)<=0.01 ) {
			if( isOnScreen(-1) && !cd.has("shoot") ) {
				var e = en.bu.MobBullet.linear(this, 1.57, 2);
				e.setPosPixel(centerX+side*5, centerY);
				side *= -1;
				shots++;
				if( shots>=5 ) {
					shots = 0;
					cd.setS("shoot",1);
				}
				else
					cd.setS("shoot",0.15);
			}
		}
	}
}
