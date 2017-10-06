package en;

import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import hxd.Key;

class Mob extends Entity {
	public static var ALL : Array<Mob> = [];

	public var plan : Null<Plan>;
	var lastStartX : Float;
	var lastStartY : Float;
	var speed : Float;
	public var wave(default,set) : Null<WaveEmitter>;
	var isBig = false;

	public var aimPrio : Float;

	private function new(x,y) {
		super(x,y);
		aimPrio = 0;
		ALL.push(this);
		frict = 0.9;
		speed = 1;
		//spr.anim.play("mobBullet").loop();
		ignoreColl = true;
		followScroll = true;
		plan = new Plan("",false);

		spr.set("red");
		initShadow();
	}

	inline function set_wave(v) {
		wave = v;
		var rseed = wave.makeRand();
		var flip = cx<=2 ? false : cx>=lvl.wid-3 ? true : rseed.sign()==1;
		plan = new Plan(generatePlan(), flip);
		lastStartX = cx+xr;
		lastStartY = cy+yr;
		return wave;
	}

	function generatePlan() : String {
		return "R5";
	}

	override public function dispose() {
		super.dispose();
		ALL.remove(this);
	}

	override function physicsUpdate() {
		super.physicsUpdate();
	}

	override function onHitWall() {
		super.onHitWall();
	}

	override public function postUpdate() {
		super.postUpdate();
	}

	function onPlanCmdStart(inst:Plan.WaveInstruction) {
		return true;
	}

	function nextPlanInstruction() {
		var skip = false;
		do {
			skip = false;
			plan.nextInstruction();
			if( plan.inst!=null )
				if( !onPlanCmdStart(plan.inst) )
					skip = true;
		} while( skip );
		lastStartX = cx+xr;
		lastStartY = cy+yr;
	}

	function onFollowPlan(xDir:Int, yDir:Int) {
	}

	function hitSound() {
		Assets.SBANK.hit02(0.3);
	}

	override public function hit(dmg:Int) {
		if( isOnScreen(1) )
			hitSound();

		if( isOnScreen(0) )
			super.hit(dmg);
	}


	function checkOffScreen() {
		if( !isOnScreen(isBig ? 4 : 2) )
			destroy();
	}

	function onTouchHero() {
		game.hero.hit(1);
		hit(5);
	}

	override public function update() {
		super.update();

		if( !game.hero.destroyed && dist(game.hero)<=radius )
			onTouchHero();

		// Follow plan
		var spd = 0.007 * speed * plan.speed;
		//setLabel(plan.inst.cmd+plan.inst.a);
		if( plan!=null && plan.inst!=null && !cd.has("pausePlan") ) {
			switch( plan.inst.cmd ) {
				//case "sinL" :
					//onFollowPlan(-1,0);
					//dx += -spd;
					//dy += spd*Math.sin(ftime*0.1);
					//if( MLib.fabs(cx+xr-lastStartX)>=plan.inst.a )
						//nextPlanInstruction();

				case "sinD" :
					onFollowPlan(0,1);
					dx += spd*Math.sin(ftime*0.045);
					dy += spd*0.35;
					if( MLib.fabs(cy+yr-lastStartY)>=plan.inst.a )
						nextPlanInstruction();

				case "_":
					cd.setS("pausePlan", plan.inst.a, nextPlanInstruction);

				case "L" :
					onFollowPlan(-1,0);
					dx += -spd;
					if( MLib.fabs(cx+xr-lastStartX)>=plan.inst.a )
						nextPlanInstruction();

				case "R" :
					onFollowPlan(1,0);
					dx += spd;
					if( MLib.fabs(cx+xr-lastStartX)>=plan.inst.a )
						nextPlanInstruction();

				case "RD" :
					onFollowPlan(1,1);
					dx += spd * plan.inst.a/(plan.inst.a+plan.inst.b);
					dy += spd * plan.inst.b/(plan.inst.a+plan.inst.b);
					if( MLib.fabs(cx+xr-lastStartX)>=plan.inst.a )
						nextPlanInstruction();

				case "LD" :
					onFollowPlan(1,1);
					dx -= spd * plan.inst.a/(plan.inst.a+plan.inst.b);
					dy += spd * plan.inst.b/(plan.inst.a+plan.inst.b);
					if( MLib.fabs(cx+xr-lastStartX)>=plan.inst.a )
						nextPlanInstruction();

				case "RU" :
					onFollowPlan(1,-1);
					dx += spd * plan.inst.a/(plan.inst.a+plan.inst.b);
					dy -= spd * plan.inst.b/(plan.inst.a+plan.inst.b);
					if( MLib.fabs(cx+xr-lastStartX)>=plan.inst.a )
						nextPlanInstruction();

				case "LU" :
					onFollowPlan(1,-1);
					dx -= spd * plan.inst.a/(plan.inst.a+plan.inst.b);
					dy -= spd * plan.inst.b/(plan.inst.a+plan.inst.b);
					if( MLib.fabs(cx+xr-lastStartX)>=plan.inst.a )
						nextPlanInstruction();

				case "U" :
					onFollowPlan(0,-1);
					dy -= spd;
					if( MLib.fabs(cy+yr-lastStartY)>=plan.inst.a )
						nextPlanInstruction();
				case "D" :
					onFollowPlan(0,1);
					dy += spd;
					if( MLib.fabs(cy+yr-lastStartY)>=plan.inst.a )
						nextPlanInstruction();

				default : trace(this+" unknown cmd "+plan.inst);
			}
		}

		//fx.markerCase(lastStart.cx, lastStart.cy, true);

		checkOffScreen();
	}
}
