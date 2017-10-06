import mt.Process;
import mt.deepnight.Tweenie;
import mt.MLib;
import hxd.Key;

class Game extends mt.Process {
	static var CHECKPOINT = -1.;

	public static var ME : Game;

	public var lvl : Level;
	public var fx : Fx;

	public var scroller : h2d.Layers;
	public var hero : en.Hero;
	public var sSpeed(get,never) : Float;
	public var vp : Viewport;

	var ldBulletMap : Map<Int,Bool>;
	var scoreTf : h2d.Text;
	public var score : Int;

	public function new() {
		super();
		ME = this;
		createRoot(Main.ME.root);
		cd.setS("noCrash",1); // macro fix
		ldBulletMap = new Map();

		score = 0;
		scroller = new h2d.Layers();
		root.add(scroller, Const.DP_BG);

		fx = new Fx();
		lvl = new Level();
		vp = new Viewport();
		new Tutorial();

		hero = new en.Hero();
		var e = Assets.tiles.h_get("logo",0,0.5,0.5);
		e.setPos(Const.VWID*Const.GRID*0.5, lvl.hei*Const.GRID - Const.VHEI*Const.GRID*0.5);
		scroller.add(e, Const.DP_UI);

		// Add waves
		lvl.iteratePixels(0x8e53ec, function(x,y) {
			new en.WaveEmitter(x,y, 1, function() return new en.m.Hammer(0,0));
		});
		lvl.iteratePixels(0xFF0000, function(x,y) {
			new en.WaveEmitter(x,y, 6, function() return new en.m.Bee(0,0));
		});
		lvl.iteratePixels(0xa0834a, function(x,y) {
			new en.WaveEmitter(x,y, 1, function() return new en.m.Hunter(0,0));
		});
		lvl.iteratePixels(0x536b33, function(x,y) {
			var w = new en.WaveEmitter(x,y, 5, function() return new en.m.Helicopter(0,0), 0.19);
			var r = w.makeRand();
			w.topTriggerDist = r.irange(2,4);
		});
		lvl.iteratePixels(0xff00ea, function(x,y) {
			var w = new en.WaveEmitter(x,y, 12, function() return new en.m.SmallHeli(0,0), 0.25);
			var r = w.makeRand();
			w.topTriggerDist = r.irange(3,6);
		});

		lvl.iteratePixels(0xffd200, function(x,y) {
			var w = new en.WaveEmitter(x,y, 1, function() return new en.m.LolBall(0,0), 0.25);
			w.topTriggerDist = 3;
		});
		lvl.iteratePixels(0x400000, function(x,y) {
			new en.m.Turret(x,y);
		});
		lvl.iteratePixels(0x7a7a7a, function(x,y) {
			new en.m.Wall(x,y);
		});

		#if debug
		// SEB DEBUG
		lvl.iteratePixels(0x0000ff, function(x,y) {
			new en.WaveEmitter(x,y, 1, function() return new en.m.Hunter(0,0));
		});
		#end

		scoreTf = new h2d.Text(Assets.font);
		root.add(scoreTf, Const.DP_UI);
		scoreTf.x = 5;
		addScore(0);

		var tf = new h2d.Text(Assets.font);
		root.add(tf, Const.DP_UI);
		tf.text = "INSERT COIN";
		tf.x = 5;
		tf.y = 15;
		createChildProcess(function(p) {
			if( !cd.hasSetS("coin",0.33) )
				tf.visible = !tf.visible;
			if( sSpeed>0 ) {
				tf.remove();
				p.destroy();
			}
		});

		// Intro
		var f = new h2d.Flow();
		f.isVertical = true;
		f.horizontalAlign = Middle;
		f.minWidth = Const.VWID*Const.GRID;
		scroller.add(f, Const.DP_TOP);
		f.y = ( lvl.hei-Const.VHEI-3) * Const.GRID;

		var tf = new h2d.Text(Assets.font,f);
		tf.textColor = 0x496676;
		tf.text = Lang.untranslated("A game created in 48h by");

		var tf = new h2d.Text(Assets.font,f);
		tf.textColor = 0x62889D;
		tf.text = Lang.untranslated("Sébastien \"deepnight\" Bénard");

		createChildProcess(function(p) {
			if( vp.elapsedDistCase>=4 ) {
				tw.createS(f.alpha, 0, 1.5).end( f.remove );
				p.destroy();
			}
		});

		// Credits
		var f = new h2d.Flow();
		f.isVertical = true;
		f.verticalSpacing = 20;
		f.horizontalAlign = Middle;
		f.minWidth = Const.VWID*Const.GRID;
		scroller.add(f, Const.DP_TOP);
		f.y = 70;

		var tf = new h2d.Text(Assets.font,f);
		tf.maxWidth = f.minWidth*0.5;
		tf.textColor = 0xFECB01;
		tf.text = Lang.untranslated("Zero Volt X - a 48h game for Ludum Dare 39");

		var tf = new h2d.Text(Assets.font,f);
		tf.maxWidth = f.minWidth*0.66;
		tf.text = Lang.untranslated("More games I made: deepnight.net");

		var tf = new h2d.Text(Assets.font,f);
		tf.maxWidth = f.minWidth*0.66;
		tf.text = Lang.untranslated("First time I do a classic Shooter, I really hope you liked it :)");

		var tf = new h2d.Text(Assets.font,f);
		tf.maxWidth = f.minWidth*0.66;
		tf.text = Lang.untranslated("Didn't have time to implement a decent boss, so that's it for now.");

		var tf = new h2d.Text(Assets.font,f);
		tf.text = Lang.untranslated("Thank you for playing!!");


		mt.Process.resizeAll();

		if( CHECKPOINT<=0 )
			CHECKPOINT = vp.elapsedDistCase;
		else
			loadCheckPoint();
	}


	public function addScore(?e:Entity, v) {
		score+=v;
		scoreTf.text = "SCORE: "+ mt.deepnight.Lib.leadingZeros(score, 6);
		if( e!=null ) {
			var tf = new h2d.Text(Assets.font);
			scroller.add(tf, Const.DP_UI);
			tf.text = ""+v;
			tf.setPos(e.centerX-tf.textWidth*0.5, e.centerY-tf.textHeight*0.5);
			tw.createMs(tf.alpha, 500|0, TEaseIn, 400).end( tf.remove );
		}
	}

	public function loadCheckPoint(?dist:Float) {
		hero.barriers = hero.maxBarriers;
		vp.elapsedDistCase = dist!=null ? dist : CHECKPOINT;
		scAccu = scPixel;
		for(e in Entity.ALL) {
			if( e.cy>=vp.topCy )
				if( e.is(en.Mob) || e.is(en.WaveEmitter) )
					e.destroy();
		}
		hero.setPosCase( Std.int(lvl.wid*0.5), vp.bottomCy-5 );
	}

	override function onResize() {
		super.onResize();
		//hei = MLib.ceil( h()/Const.SCALE/Const.GRID );
	}

	public function restart(resetCheck=false) {
		Main.ME.transition( function() {
			if( resetCheck )
				CHECKPOINT = -1;

			return new Game();
		});
	}

	override function onDispose() {
		super.onDispose();
		for(e in Entity.ALL)
			e.destroy();
		gc();
	}

	function gc() {
		if( Entity.GC.length>0 ) {
			for(e in Entity.GC)
				e.dispose();
			Entity.GC = [];
		}
	}

	public function updateKeys() {
		if( Key.isPressed(Key.R) )
			restart( Key.isDown(Key.SHIFT) );

		if( Key.isPressed(Key.K) ) {
			mt.deepnight.Sfx.toggleMuteGroup(0);
			new Notif(true, Lang.untranslated("Sounds: "+(mt.deepnight.Sfx.isMuted(0)?"Off":"ON")));
		}

		if( Key.isPressed(Key.M) ) {
			mt.deepnight.Sfx.toggleMuteGroup(1);
			new Notif(true, Lang.untranslated("Music: "+(mt.deepnight.Sfx.isMuted(1)?"Off":"ON")));
		}

		if( Key.isPressed(Key.ESCAPE) ) {
			if( cd.has("escapeKey") )
				hxd.System.exit();
			else {
				cd.setS("escapeKey",4);
				new Notif(Lang.untranslated("Press ESCAPE again to quit"));
			}
		}
	}

	inline function get_sSpeed() {
		if( vp.topCy<=1 )
			return 0.;
		return 0.0125 * (hero.cy<=vp.topCy+1 ? 2.5:hero.cy<=vp.topCy+3 ? 1.8:1) * (Tutorial.ME.hasDone("controls")?1 : 0);
		//return 0.0125 * (hero.cy<=vp.topCy+3 ? 2.5:1) * (Tutorial.ME.hasDone("controls")?1 : 0);
	}

	public var scFrame = false;
	public var scAccu = 0.;
	public var scPixel = 0.;
	override public function update() {
		super.update();

		// Scroller
		scAccu+=sSpeed;

		scPixel = 1/Const.GRID;
		scFrame = false;
		if( scAccu>=scPixel ) {
			scAccu-=scPixel;
			vp.elapsedDistCase+=scPixel;
			scFrame = true;
		}
		scroller.y = -lvl.hei*Const.GRID + MLib.ceil(Boot.ME.cached.height) + vp.elapsedDistCase*Const.GRID;

		// LD bullets
		for( pt in lvl.getPixels(0x7cffe8) ) {
			if( pt.cy==vp.topCy )  {
				if( ldBulletMap.exists(lvl.coordId(pt.cx,pt.cy)) )
					continue;

				ldBulletMap.set(lvl.coordId(pt.cx,pt.cy), true);
				var n = 4;
				for(i in 0...n) {
					en.bu.MobBullet.linearLD(
						pt.centerX-Const.GRID*0.4+Const.GRID*0.8*i/(n-1) + rnd(0,2,true),
						pt.centerY-rnd(5,12), 1.57,
						rnd(0.95,1.02)
					);
				}
			}
		}

		// Checkpoints
		var ptDist = 0.;
		for(pt in lvl.getPixels(0xff6000)) {
			ptDist = lvl.hei-pt.cy - vp.hei*0.5;
			if( vp.elapsedDistCase >= ptDist  && ptDist>CHECKPOINT ) {
				CHECKPOINT = ptDist;
				new Notif(Lang.untranslated("Checkpoint reached"));
				Assets.SBANK.check03(1);
			}
		}


		// Update
		for(e in Entity.ALL)
			if( !e.destroyed ) {
				e.preUpdate();
				e.update();
				e.postUpdate();
			}
		gc();
	}
}
