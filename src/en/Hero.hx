package en;

import mt.MLib;
import mt.heaps.slib.*;
import mt.deepnight.Lib;
import hxd.Key;

class Hero extends Entity {
	static var MOUSE = false;
	static var BASE = 4;
	static var MAX = 8;

	var stacks : Array<Int>;
	var jauges : Array<HSprite>;
	public var power(get,never) : Float;
	public var shield(get,never) : Float;
	public var missile(get,never) : Float;

	public var maxBarriers : Int;
	public var barriers : Float;
	var bSpr : HSprite;

	//public var heat : Float;
	//public var heatBar : Bar;
	var xOff : Int;

	var iShield : HSprite;
	var iGun : HSprite;
	var iMiss : HSprite;
	var flame : HSprite;
	var missileCdF : Float;

	public function new() {
		super(0,0);
		setPosAtColor(0x00FF00);

		//heat = 0;
		xOff = 0;
		stacks = [];
		resetStacks(false);
		maxBarriers = 1;
		barriers = 0;
		missileCdF = 0;
		followScroll = true;
		radius = 7;
		//heatBar = new Bar(16,3, 0xFF6000);

		game.scroller.add(spr, Const.DP_HERO);

		flame = Assets.tiles.h_getAndPlay("reactorFlame");
		game.scroller.add(flame, Const.DP_HERO);
		flame.setCenterRatio(0.5,0);
		flame.anim.setSpeed(0.4).reverse();

		iShield = Assets.tiles.h_get("iconShield",0,0.5,0.5);
		game.scroller.add(iShield, Const.DP_HERO);

		iGun = Assets.tiles.h_get("iconGun",0,0.5,0.5);
		game.scroller.add(iGun, Const.DP_HERO);

		iMiss = Assets.tiles.h_get("iconMissile",0,0.5,0.5);
		game.scroller.add(iMiss, Const.DP_HERO);

		jauges = [];
		for(i in 0...stacks.length) {
			var e = Assets.tiles.h_get("jauge");
			game.scroller.add(e,Const.DP_UI);
			jauges.push(e);
		}
		jauges[0].setCenterRatio(0.5,0.5);
		jauges[1].setCenterRatio(0.5,1);
		jauges[2].setCenterRatio(0.5,0.5);
		jauges[0].scaleY*=-1;

		spr.set("heroIdle");
		//spr.anim.registerStateAnim("heroTurnLeft",1, function() return dx<0);
		//spr.anim.registerStateAnim("heroIdle",0);

		bSpr = Assets.tiles.h_get("shield");
		game.scroller.add(bSpr, Const.DP_HERO);
		bSpr.setCenterRatio(0.5,0.5);

		//bRefill = Assets.tiles.h_get("shield");
		//game.scroller.add(bRefill, Const.DP_FX_BG);
		//bRefill.setCenterRatio(0.5,0.5);

		initShadow();
	}

	override public function hit(dmg:Int) {
		if( cd.has("immune") )
			return;

		fx.flashBangS(0xFF0000,0.2);
		if( barriers>=1 ) {
			barriers = Std.int(barriers-1);
			Assets.SBANK.shieldDown03(0.8);
			fx.lostShield(centerX, centerY);
			cd.setS("immune", 1);
			return;
		}

		#if !debug
		super.hit(dmg);
		#end
	}


	override public function dispose() {
		super.dispose();
		//heatBar.destroy();
		flame.remove();
		bSpr.remove();
		//bRefill.remove();
		iShield.remove();
		iGun.remove();
		iMiss.remove();
		for(e in jauges)
			e.remove();
		jauges = null;
	}

	override function onDie() {
		super.onDie();
		Assets.SBANK.explo02(1);
		Assets.SBANK.explo03(1);
		fx.flashBangS(0xFF0000,1,1);
		fx.bigExplode(centerX, centerY);
		game.delayer.addS( game.restart.bind(false), 1);
	}

	inline function isOverheat() return cd.has("overheat");

	var curvePow = 1.0;
	inline function get_shield() return isOverheat() ? 0.15 : Math.pow( stacks[0] / MAX, curvePow );
	inline function get_power() return isOverheat() ? 0.15 : Math.pow( stacks[1] / MAX, curvePow );
	inline function get_missile() return isOverheat() ? 0.15 : Math.pow( stacks[2] / MAX, curvePow );

	inline function unlockControl(s:Float) cd.unset("lockControl");
	function lockControlS(s:Float) cd.setS("lockControl",s);
	inline function controlsLocked() return cd.has("lockControl");


	function keyPressed(k:Int) {
		if( Key.isDown(k) && !cd.has("klock"+k) ) {
			cd.setS("klock"+k,99);
			return true;
		}
		if( !Key.isDown(k) )
			cd.unset("klock"+k);
		return false;
	}

	public function sendToStack(id:Int) {
		if( stacks[id]==MAX )
			return false;

		var v = MLib.min(2, MAX-stacks[id]);
		stacks[id]+=v;
		if( v==2 ) {
			var a = id==0 ? 1 : id==1 ? 2 : 0;
			var b = id==0 ? 2 : id==1 ? 0 : 1;
			//trace(id+" "+a+" "+b);
			if( stacks[a]==0 )
				stacks[b]-=v;
			else if( stacks[b]==0 )
				stacks[a]-=v;
			else {
				stacks[a]--;
				stacks[b]--;
			}
		}
		else {
			var a =
				id==0 ? ( stacks[1]>stacks[2] ? 1 : 2 ) :
				id==1 ? ( stacks[0]>stacks[2] ? 0 : 2 ) :
				( stacks[0]>stacks[1] ? 0 : 1 );
			//trace("=> "+a);
			stacks[a]--;
		}
		//trace(stacks);
		jauges[id].colorAdd = h3d.Vector.fromColor(0xFFffffff);
		cd.setS("jaugeBlink",0.06);

		var vol = 0.3;
		if( stacks[id]>=MAX )
			Assets.SBANK.bleep07(0.25);
		switch( id ) {
			case 0 : Assets.SBANK.bleep04(vol);
			case 1 : Assets.SBANK.bleep05(vol);
			case 2 : Assets.SBANK.bleep06(vol);
		}
		return true;
	}

	function resetStacks(playSound:Bool) {
		if( stacks[0]!=BASE || stacks[1]!= BASE )
			if( playSound )
				Assets.SBANK.bleep08(0.3);
		stacks[0] = stacks[1] = stacks[2] = BASE;
		//trace(stacks);
	}

	inline function getBarrierColor(b:Int) {
		return 0x05E078;
		//return switch( b ) {
			//case 0,1 : 0xDD2243
			//case 2 : 0xDED907;
			//case 3 : 0x05E078;
		//}
	}

	function getJaugeColor(r:Float) {
		return r>=1 ? 0xC13FE2 :
				r>=0.75 ? 0x11EE5F :
				r>=0.5 ? 0xE6C71A :
				r>=0.25 ? 0xF86D07 :
				0xD32C49;
	}
	override public function postUpdate() {
		super.postUpdate();

		if( cd.has("immune") && !cd.hasSetS("immBlink",0.1) )
			blink();
		//if( cd.has("immune") )
			//spr.visible = !spr.visible;
		//else
			//spr.visible = true;

		spr.x+=xOff;

		flame.setPos(spr.x, spr.y+6);
		flame.scaleY = dy<0 ? 1.25 : dy>0 ? 0.5 : 1;

		//heatBar.set(heat+rnd(0,0.1));
		//heatBar.x = Std.int(spr.x - heatBar.wid*0.5);
		//heatBar.y = Std.int(spr.y + radius+10);

		bSpr.x = centerX;
		bSpr.y = centerY+1;
		bSpr.visible = barriers>=1;
		bSpr.colorize(getBarrierColor(Std.int(barriers)));
		bSpr.blendMode = Add;
		bSpr.alpha = 0.8+0.2*Math.cos(ftime*0.1);

		if( barriers<maxBarriers ) {
			var r = barriers - Std.int(barriers);
			fx.shieldRefill(this, r, getBarrierColor(Std.int(barriers)+1));
		}

		for(i in 0...stacks.length) {
			var e = jauges[i];
			e.setFrame(stacks[i]);
			var r = stacks[i]/MAX;
			e.colorize(getJaugeColor(r));
			if( !cd.has("jaugeBlink") && e.colorAdd!=null ) {
				e.colorAdd.r*=0.6;
				e.colorAdd.g*=0.6;
				e.colorAdd.b*=0.6;
				if( e.colorAdd.r<=0.03 && e.colorAdd.g<=0.03 && e.colorAdd.b<=0.03 )
					e.colorAdd = null;
			}

		}
		jauges[0].setPos(centerX-16, centerY);
		jauges[0].rotation = -1.57;
		jauges[1].setPos(centerX, centerY-16);
		jauges[2].setPos(centerX+16, centerY);
		jauges[2].rotation = -1.57;

		iShield.setPos(centerX-24, centerY);
		iShield.colorize(getJaugeColor(shield));
		iShield.alpha = shield*.75;

		iGun.setPos(centerX, centerY-26);
		iGun.colorize(getJaugeColor(power));
		iGun.alpha = power*.75;

		iMiss.setPos(centerX+24, centerY);
		iMiss.colorize(getJaugeColor(missile));
		iMiss.alpha = missile*.75;


		//bRefill.setPos(bSpr.x, bSpr.y);
		//var r = barriers - Std.int(barriers);
		//bRefill.setScale(1.25 - 0.25 * r);
		//bRefill.visible = barriers<3 && shield>0;
		//bRefill.alpha = 0.1 + 0.7*r;
	}

	override function physicsUpdate() {
		if( dy>0 && centerY>=game.vp.bottomY )
			dy = 0;
		if( dy<0 && centerY<=game.vp.topY + Const.GRID*1 )
			dy = 0;
		if( dx<0 && centerX<=Const.GRID )
			dx = 0;
		if( dx>0 && centerX>=(lvl.wid-1)*Const.GRID )
			dx = 0;
		super.physicsUpdate();
	}

	override public function update() {
		super.update();

		var s = MOUSE ? 0.13 : 0.07;

		if( !controlsLocked() ) {
			if( game.sSpeed>0 && game.vp.elapsedDistCase>=5 && !cd.has("lazer") ) {
				var n = isOverheat() ? 1 : MLib.ceil(power*6);
				if( power>=0.75 )
					n+=3;
				var range = 16 + power*5;
				//var range = 12*power;
				for(i in 0...n) {
					var e = new en.bu.HeroBullet(power>=1 ? 1 : 0);
					e.dy = -0.6;
					if( n==1 )
						e.setPosPixel(centerX, centerY);
					else
						e.setPosPixel(centerX - range*0.5 + range*i/(n-1), centerY - Math.sin(3.14*i/(n-1))*5);
				}
				cd.setS("lazer", isOverheat() ? 0.20 : 0.15);
			}

			// Missiles
			missileCdF++;
			if( game.sSpeed>0 && game.vp.elapsedDistCase>=5 && missileCdF >= Const.FPS * (1.5 - missile*0.6) ) {
				var n = isOverheat() ? 0 : MLib.ceil(missile*2);
				if( missile>=1 )
					n+=3;
				else if( missile>=0.75 )
					n+=2;
				for(i in 0...n)
					delayer.addS( function() {
						new en.bu.Homing(this, missile>=1 ? 2 : 0);
					}, i/n*0.6);
				missileCdF = 0;
			}

			// Stack controls
			if( ( keyPressed(Key.Q) || keyPressed(Key.A) ) && Tutorial.ME.isDoingOrDone("shield") )
				sendToStack(0);

			if( ( keyPressed(Key.Z) || keyPressed(Key.W) ) && Tutorial.ME.isDoingOrDone("lazer") )
				sendToStack(1);

			if( keyPressed(Key.D) && Tutorial.ME.isDoingOrDone("missile") )
				sendToStack(2);

			if( keyPressed(Key.S) && Tutorial.ME.isDoingOrDone("balance") )
				resetStacks(true);

			// Movement
			if( MOUSE ) {
				var mx = hxd.Stage.getInstance().mouseX / Const.SCALE - game.scroller.x;
				var my = hxd.Stage.getInstance().mouseY / Const.SCALE - game.scroller.y;

				var a = Math.atan2(my-centerY, mx-centerX);
				if( dist(mx,my)>=2 ) {
					var mul = MLib.fmin(1, dist(mx,my)/10);
					dx+=Math.cos(a)*s * mul;
					dy+=Math.sin(a)*s * mul;
				}
			}
			else {
				if( Key.isDown(Key.LEFT) ) {
					dx-=s;
					cd.setS("l", 999);
				}
				if( Key.isDown(Key.RIGHT) ) {
					dx+=s;
					cd.setS("r", 999);
				}

				if( Key.isDown(Key.UP) ) {
					cd.setS("u", 999);
					dy-=s;
				}
				if( Key.isDown(Key.DOWN) ) {
					cd.setS("d", 999);
					dy+=s;
				}
			}
			//fx.markerFree(mx,my,true);
		}

		if( shield>0.5 )
			fx.shieldFeedback(this, shield, getBarrierColor(Std.int(barriers)));

		#if debug
		if( keyPressed(Key.SPACE) ) {
			//game.loadCheckPoint(240);
			//new en.WaveEmitter(lvl.wid-1, game.vp.topCy+5, 6, function() return new en.m.LolBall(0,0));
			new en.m.LolBall(cx,game.vp.topCy+3);
			new en.m.Turret(cx-6, game.vp.topCy);
			//new Notif(Lang.untranslated("hello world"));
			//new en.LazerBeam(this, 0,-10, -1.57);
		}

		if( keyPressed(Key.K) ) {
			for(e in Entity.ALL)
			if( e.is(en.Mob) && !e.is(en.m.Wall) || e.is(en.Bullet) || e.is(en.WaveEmitter) ) {
				e.destroy();
			}
		}
		#end

		// Rotation
		if( !cd.hasSetS("turn", 0.08) ) {
			var tf = dx>s ? 4 : dx<-s ? 0 : 2;
			xOff = dx>s ? 2 : dx<-s ? -2 : 0;
			if( tf!=spr.frame )
				spr.setFrame( tf>spr.frame ? spr.frame+1 : spr.frame-1 );
		}

		// Shields
		if( Tutorial.ME.isDoingOrDone("shield") && barriers<maxBarriers ) {
			var old = barriers;
			barriers += 0.003 * shield;
			if( shield>=1 )
				barriers += 0.003;
			else if( shield>=0.75 )
				barriers += 0.002;
			if( Std.int(barriers)!=Std.int(old) ) {
				Assets.SBANK.shieldUp02(1);
				fx.shieldReady(this, getBarrierColor(Std.int(barriers)));
			}
			if( barriers>maxBarriers )
				barriers = maxBarriers;
		}

		#if debug
		setLabel(pretty(hxd.Timer.fps()));
		//setLabel(Std.int(game.vp.elapsedDistCase));
		#end
	}
}
