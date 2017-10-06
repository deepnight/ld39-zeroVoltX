import h2d.Sprite;
import mt.heaps.HParticle;
import mt.deepnight.Lib;
import mt.deepnight.Color;
import mt.deepnight.Tweenie;
import mt.MLib;


class Fx extends mt.Process {
	public var pool : ParticlePool;

	public var bgAddSb    : h2d.SpriteBatch;
	public var bgNormalSb    : h2d.SpriteBatch;
	public var topAddSb       : h2d.SpriteBatch;
	public var topNormalSb    : h2d.SpriteBatch;

	var game(get,never) : Game; inline function get_game() return Game.ME;
	var level(get,never) : Level; inline function get_level() return Game.ME.lvl;

	public function new() {
		super(Game.ME);

		pool = new ParticlePool(Assets.tiles.tile, 2048, Const.FPS);

		bgAddSb = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(bgAddSb, Const.DP_FX_BG);
		bgAddSb.blendMode = Add;
		bgAddSb.hasRotationScale = true;

		bgNormalSb = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(bgNormalSb, Const.DP_FX_BG);
		bgNormalSb.hasRotationScale = true;

		topNormalSb = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(topNormalSb, Const.DP_FX_TOP);
		topNormalSb.hasRotationScale = true;

		topAddSb = new h2d.SpriteBatch(Assets.tiles.tile);
		game.scroller.add(topAddSb, Const.DP_FX_TOP);
		topAddSb.blendMode = Add;
		topAddSb.hasRotationScale = true;
	}

	override public function onDispose() {
		super.onDispose();

		pool.dispose();

		bgAddSb.remove();
		bgNormalSb.remove();
		topAddSb.remove();
		topNormalSb.remove();
	}


	public inline function allocTopAdd(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(topAddSb, t, x, y);
	}

	public inline function allocTopNormal(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(topNormalSb, t,x,y);
	}

	public inline function allocBgAdd(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(bgAddSb, t,x,y);
	}

	public inline function allocBgNormal(t:h2d.Tile, x:Float, y:Float) : HParticle {
		return pool.alloc(bgNormalSb, t,x,y);
	}

	public inline function getTile(id:String) : h2d.Tile {
		return Assets.tiles.getTileRandom(id);
	}

	public function killAll() {
		pool.killAll();
	}

	public function markerEntity(e:Entity, ?c=0xFF00FF, ?short=false) {
		#if debug
		if( e==null )
			return;

		markerCase(e.cx, e.cy, c, short);
		#end
	}

	public function markerCase(cx:Int, cy:Int, ?c=0xFF00FF, ?short=false) {
		var p = allocTopAdd(getTile("circle"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.frict = 0.92;
		p.lifeS = short ? 0.06 : 3;

		var p = allocTopAdd(getTile("dot"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(2);
		p.frict = 0.92;
		p.lifeS = short ? 0.06 : 3;
	}

	public function markerFree(x:Float, y:Float, ?c=0xFF00FF, ?short=false) {
		var p = allocTopAdd(getTile("star"), x,y);
		p.setFadeS(1, 0, 0.06);
		p.colorize(c);
		p.setScale(3);
		p.dr = 0.3;
		p.frict = 0.92;
		p.lifeS = short ? 0.06 : 3;
	}

	public function markerText(cx:Int, cy:Int, txt:String, ?t=1.0) {
		var tf = new h2d.Text(Assets.font, topNormalSb);
		tf.text = txt;

		var p = allocTopAdd(getTile("circle"), (cx+0.5)*Const.GRID, (cy+0.5)*Const.GRID);
		p.colorize(0x0080FF);
		p.frict = 0.92;
		p.alpha = 0.6;
		p.lifeS = 0.3;
		p.fadeOutSpeed = 0.4;
		p.onKill = tf.remove;

		tf.setPos(p.x-tf.textWidth*0.5, p.y-tf.textHeight*0.5);
	}

	public function hit(x,y) {
		var p = allocTopNormal(getTile("hit"), x,y);
		p.alpha = rnd(0.7,1);
		p.ds = rnd(0.01,0.02);
		p.dsFrict = 0.98;
		p.playAnimAndKill(Assets.tiles, "hit", 0.4 * rnd(0.6,1));
		p.rotation = rnd(0,6.28);
	}

	public function explode(x,y) {
		// Smoke
		var n = 4;
		for(i in 0...n) {
			var p = allocBgNormal(getTile("smoke"), x+rnd(2,8,true), y+rnd(2,8,true));
			p.playAnimAndKill(Assets.tiles, "smoke", 0.12 * rnd(0.85,1.25));
			p.rotation = rnd(0,6.28);
			p.ds = rnd(0.01,0.02);
			p.dsFrict = 0.99;
			p.delayS = 0.3*i/n - rnd(0,0.05);
			p.lifeS = 3;
		}

		// Main explosion
		var n = 4;
		for(i in 0...n) {
			var p = allocTopNormal(getTile("explode"), x+rnd(0,5,true), y+rnd(0,5,true));
			p.playAnimAndKill(Assets.tiles, "explode", 0.6 * rnd(0.75,1.5));
			p.rotation = rnd(0,6.28);
			p.delayS = 0.3*i/n - rnd(0,0.05);
			p.lifeS = 3;
		}

		// Small explosions
		var n = 6;
		for(i in 0...n) {
			var p = allocBgNormal(getTile("explode"), x+rnd(8,13,true), y+rnd(8,13,true));
			p.playAnimAndKill(Assets.tiles, "explode", 0.3 * rnd(0.75,1.5));
			p.setScale(rnd(0.4,0.6));
			p.rotation = rnd(0,6.28);
			p.delayS = 0.2 + 0.3*i/n - rnd(0,0.05);
			p.lifeS = 3;
		}

		// Lines
		var n = irnd(6,10);
		for(i in 0...n) {
			var a = rnd(0,6.28);
			var p = allocBgNormal(getTile("line"), x+rnd(0,5,true), y+rnd(0,5,true));
			p.colorAnimS(0xFFFF00, 0x5F37C8, rnd(0.5,1));
			p.moveAwayFrom(x,y, rnd(1.5,2));
			p.rotation = p.getMoveAng();
			p.scaleX = rnd(0.7,1.5);
			p.scaleXMul = rnd(0.97,0.99);
			p.frict = rnd(0.92,0.97);
			p.delayS = 0.15*i/n - rnd(0,0.05);
		}

		// Falling parts
		var n = irnd(4,8);
		for(i in 0...n) {
			var a = rnd(0,6.28);
			var p = allocBgNormal(getTile("expBall"), x+rnd(0,3,true), y-rnd(3,8));
			p.moveAwayFrom(x,y, rnd(2,4));
			p.setScale(rnd(0.5,1));
			p.scaleMul = rnd(0.97,0.99);
			p.frict = 0.97;
			p.gy = rnd(0.05,0.10);
			p.delayS = 0.3*i/n - rnd(0,0.05);
			p.onUpdate = _followAng;
			p.onUpdate(p);
		}
	}

	public function halo(x:Float, y:Float, c:UInt, ?scale=1.0) {
		var p = allocTopNormal(getTile("halo"), x,y);
		p.colorAnimS(c, 0x4E1672, 0.3);
		p.scale = 0.3*scale;
		p.ds = 0.1*scale;
		p.dsFrict = 0.8;
		p.lifeS = 0.2;
	}

	public function flashBangS(c:UInt, a:Float, ?t=0.1) {
		var e = new h2d.Bitmap(h2d.Tile.fromColor(c,1,1,a));
		game.root.add(e, Const.DP_FX_TOP);
		e.scaleX = game.w();
		e.scaleY = game.h();
		e.blendMode = Add;
		game.tw.createS(e.alpha, 0, t).end( function() {
			e.remove();
		});

	}

	public function bigExplode(x,y) {
		halo(x,y, 0xFFFF00, 2);
		// Smoke
		var n = 8;
		for(i in 0...n) {
			var p = allocBgNormal(getTile("smoke"), x+rnd(2,18,true), y+rnd(2,18,true));
			p.playAnimAndKill(Assets.tiles, "smoke", 0.08 * rnd(0.85,1.25));
			p.rotation = rnd(0,6.28);
			p.ds = rnd(0.01,0.02);
			p.dsFrict = 0.99;
			p.delayS = 0.6*i/n - rnd(0,0.05);
			p.lifeS = 10;
		}

		// Main explosions
		var n = 10;
		for(i in 0...n) {
			var p = allocTopNormal(getTile("explode"), x+rnd(0,15,true), y+rnd(0,15,true));
			p.playAnimAndKill(Assets.tiles, "explode", 0.3 * rnd(0.75,1.5));
			p.rotation = rnd(0,6.28);
			p.delayS = 1*i/n - rnd(0,0.05);
			p.ds = rnd(0.02,0.03);
			p.dsFrict = 0.98;
			p.lifeS = 10;
		}

		// Small explosions
		var n = 16;
		for(i in 0...n) {
			var p = allocBgNormal(getTile("explode"), x+rnd(8,13,true), y+rnd(8,13,true));
			p.playAnimAndKill(Assets.tiles, "explode", 0.3 * rnd(0.75,1.5));
			p.setScale(rnd(0.4,0.6));
			p.rotation = rnd(0,6.28);
			p.delayS = 0.2 + 1*i/n - rnd(0,0.05);
			p.lifeS = 10;
		}

		// Lines
		var n = irnd(30,40);
		for(i in 0...n) {
			var a = rnd(0,6.28);
			var p = allocBgNormal(getTile("line"), x+rnd(0,5,true), y+rnd(0,5,true));
			p.colorAnimS(0xFFFF00, 0x5F37C8, rnd(0.5,1));
			p.moveAwayFrom(x,y, rnd(1.5,2));
			p.rotation = p.getMoveAng();
			p.scaleX = rnd(0.7,1.5);
			p.scaleXMul = rnd(0.97,0.99);
			p.frict = rnd(0.92,0.97);
			p.delayS = 0.15*i/n - rnd(0,0.05);
		}

		// Falling parts
		var n = irnd(40,45);
		for(i in 0...n) {
			var a = rnd(0,6.28);
			var p = allocBgNormal(getTile("expBall"), x+rnd(0,3,true), y-rnd(3,8));
			p.moveAwayFrom(x,y, rnd(2,4));
			p.setScale(rnd(0.5,1));
			p.scaleMul = rnd(0.97,0.99);
			p.frict = 0.97;
			p.gy = rnd(0.05,0.10);
			p.delayS = 0.6*i/n - rnd(0,0.05);
			p.onUpdate = _followAng;
			p.onUpdate(p);
		}
	}

	public function smallExplode(x,y) {
		var p = allocBgNormal(getTile("smoke"), x+rnd(2,8,true), y+rnd(2,8,true));
		p.playAnimAndKill(Assets.tiles, "smoke", 0.3 * rnd(0.85,1.25));
		p.scale = 0.4;
		p.rotation = rnd(0,6.28);
		p.ds = rnd(0.01,0.02);
		p.dsFrict = 0.99;
		p.lifeS = 3;

		var p = allocTopNormal(getTile("explode"), x+rnd(0,5,true), y+rnd(0,5,true));
		p.playAnimAndKill(Assets.tiles, "explode", 0.6 * rnd(0.75,1.5));
		p.scale = 0.6;
		p.rotation = rnd(0,6.28);
		p.lifeS = 3;
	}

	public function tail(lx:Float,ly:Float, x:Float,y:Float, c:UInt) {
		var p = allocTopAdd(getTile("tail"), lx,ly);
		p.colorize(c);
		p.setFadeS(rnd(0.1,0.2), 0.1, rnd(0.2,0.4));
		p.rotation = Math.atan2(y-ly, x-lx);
		p.scaleX = Lib.distance(lx, ly, x, y) / p.t.width;
		p.scaleY = rnd(1,2);
		p.scaleYMul = rnd(0.97,0.99);
		p.lifeS = rnd(0.3, 0.6);
	}

	public function lostShield(x:Float, y:Float) {
		halo(x,y, 0x0AF53F, 2.5);
		var n = 50;
		for( i in 0...n ) {
			var a = 6.28 * i/n + rnd(0,0.1,true);
			var p = allocTopAdd(getTile("line"), x+Math.cos(a)*10, y+Math.sin(a)*15);
			p.colorize(0x0AF53F);
			p.setFadeS(rnd(0.7,1), 0, rnd(1,2));
			p.moveAwayFrom(x,y, rnd(12,15));
			p.scaleXMul = rnd(0.92,0.97);
			p.rotation = p.getMoveAng()+1.57 + rnd(0,0.1,true);
			p.frict = rnd(0.70, 0.75);
			p.lifeS = rnd(1,2);
		}
	}

	function _trackEntity(p:HParticle) {
		var e : Entity = p.userData;
		if( !Math.isNaN(p.data0) )
			p.setPos( p.x + e.centerX-p.data0, p.y + e.centerY-p.data1 );

		p.data0 = e.centerX;
		p.data1 = e.centerY;
	}

	public function shieldFeedback(e:Entity, r:Float, c:UInt) {
		var x = e.centerX;
		var y = e.centerY-1;
		var n = 4;
		var base = rnd(0,6.28);
		for( i in 0...n ) {
			var a = base + 6.28 * i/n + rnd(0,0.1,true);
			var p = allocTopAdd(getTile("line"), x+Math.cos(a)*rnd(5,13), y+1+Math.sin(a)*rnd(5,16));
			p.setFadeS( r*rnd(0.15,0.3), 0.1, rnd(0.2,0.3));
			p.colorize(c);
			p.scale = rnd(0.33,0.75);
			p.rotation = Math.atan2(y-p.y, x-p.x) + rnd(0,0.1,true);
			p.lifeS = 0.1;
			p.userData = e;
			p.onUpdate = _trackEntity;
		}
	}

	public function shieldRefill(e:Entity, r:Float, c:UInt) {
		var x = e.centerX;
		var y = e.centerY-1;
		var base = rnd(0,6.28);
		var n = 8;
		for( i in 0...n ) {
			var a = base + 6.28 * i/n + rnd(0,0.1,true);
			var p = allocTopAdd(getTile("star"), x+Math.cos(a)*(16-r*3), y+1+Math.sin(a)*(19-r*3));
			p.alpha = 0.1 + rnd(0.1,0.2) * r;
			p.colorize(c);
			p.scale = 0.5 + 0.5*r;
			p.rotation = Math.atan2(y-p.y, x-p.x) + 1.57 + rnd(0,0.1,true);
			p.lifeS = 0.03;
			p.userData = e;
			p.onUpdate = _trackEntity;
		}
	}


	public function shieldReady(e:Entity, c:UInt) {
		var x = e.centerX;
		var y = e.centerY;
		var n = 40;
		for( i in 0...n ) {
			var a = 6.28 * i/n + rnd(0,0.1,true);
			var p = allocTopAdd(getTile("line"), x+Math.cos(a)*27, y+1+Math.sin(a)*30);
			p.setCenterRatio(1,0.5);
			p.colorize(c);
			p.setFadeS(rnd(0.3,0.4), 0, 0.1);
			p.moveTo(x,y, 5);
			p.scaleXMul = rnd(0.85,0.90);
			p.rotation = p.getMoveAng() + rnd(0,0.1,true);
			p.dr = -0.3;
			p.frict = 0.65;
			p.lifeS = 0.3;
			p.userData = e;
			p.onUpdate = _trackEntity;
		}
	}


	function _followAng(p:HParticle) {
		p.rotation = p.getMoveAng();
	}

	override function update() {
		super.update();
		pool.update(1);
	}
}