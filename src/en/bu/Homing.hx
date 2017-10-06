package en.bu;

import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import hxd.Key;

class Homing extends en.Bullet {
	static var LAUNCH_DIR = 1;
	var target : Null<Entity>;
	var ang : Float;
	var precision : Float;
	var lastX : Float;
	var lastY : Float;

	public function new(e:Entity, dmgBonus:Int) {
		super(0,0);
		setPosPixel(e.centerX, e.centerY);
		frict = 0.8;
		precision = 1;
		dmg = 5 + dmgBonus;
		ang = -1.57;
		dx = rnd(0.05,0.4) * LAUNCH_DIR;
		dy = rnd(0.2,0.3);
		LAUNCH_DIR*=-1;
		lastX = centerX;
		lastY = centerY;

		cd.setS("launch",rnd(0.2,0.3));
		cd.setS("alive", 2.5);

		spr.anim.playAndLoop(dmgBonus!=0?"homingBig":"homing").setSpeed(0.2);
		spr.setCenterRatio(0.6,0.5);

		pickTarget();
	}

	function pickTarget() {
		var dh = new DecisionHelper(en.Mob.ALL);
		dh.remove( function(e:Entity) return e.destroyed || !e.isOnScreen() );
		dh.score( function(e) return -distCase(e)*0.5 );
		dh.score( function(e) return e.life<=dmg ? 6 : e.life<=dmg*2 ? 3 : 0 );
		dh.score( function(e) return e.cd.has("targeted") ? -1 : 0 );
		dh.score( function(e) return e.aimPrio );
		target = dh.getBest();
		if( target!=null )
			target.cd.setS("targeted",0.75);
	}

	override function physicsUpdate() {
		super.physicsUpdate();
	}

	override public function postUpdate() {
		super.postUpdate();
		spr.rotation = ang;
	}

	function onHit(e:Entity) {
		fx.smallExplode(centerX, centerY);
		Assets.SBANK.explo03(0.3);
		e.hit(dmg);
		destroy();
	}

	override function onStep() {
		super.onStep();
		for(e in en.Mob.ALL)
			if( !e.destroyed && dist(e)<=e.radius+7 ) {
				onHit(e);
				break;
			}
	}

	override public function update() {
		super.update();

		if( !cd.has("launch") )
			fx.tail(lastX, lastY, centerX, centerY, 0xFFFFFF);
		lastX = centerX;
		lastY = centerY;

		if( target!=null && target.destroyed )
			target = null;

		if( target==null && !cd.hasSetS("changeTarget",rnd(0.4,0.8)) )
			pickTarget();

		if( !cd.has("launch") ) {
			// Track
			precision-=0.01;
			precision = MLib.fclamp(precision-0.01, 0, 1);
			if( target!=null ) {
				var ta = Math.atan2(target.centerY-centerY, target.centerX-centerX);
				ang += Lib.angularSubstractionRad(ta,ang) * ( 0.01 + precision*0.35 );
			}
			// Move
			var s = 0.04;
			dx+=Math.cos(ang)*s;
			dy+=Math.sin(ang)*s;
		}

		if( !cd.has("alive") ) {
			destroy();
			fx.smallExplode(centerX, centerY);
		}
	}
}
