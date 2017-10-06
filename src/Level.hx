 import mt.heaps.slib.*;
import mt.deepnight.Tweenie;
import mt.MLib;
import mt.deepnight.Color;
import mt.heaps.HParticle;

class Level extends mt.Process {
	var coll : haxe.ds.Vector<Bool>;
	var roads : haxe.ds.Vector<Bool>;
	var walls : haxe.ds.Vector<Bool>;
	var pixels : Map<UInt, Array<CPoint>>;
	public var sb : HSpriteBatch;
	var gradient : HSprite;
	public var wid : Int;
	public var hei : Int;
	var emitters : Array<Emitter>;

	var cityFactor : Map<Int,Float>;
	var clouds : Array<{ e:HSprite, spd:Float }>;

	public function new() {
		super(Game.ME);

		emitters = [];
		createRootInLayers(Game.ME.scroller, Const.DP_BG);

		gradient = Assets.tiles.h_get("gradientLight");
		Game.ME.root.add(gradient, Const.DP_FX_TOP);
		gradient.smooth = true;
		gradient.blendMode = Add;
		gradient.alpha = 0.3;

		clouds = [];
		wid = hei = -1;
		readMap();
		render();
	}

	override function onResize() {
		super.onResize();
		gradient.scaleX = w()/Const.SCALE / gradient.tile.width;
	}
	override function onDispose() {
		super.onDispose();
		gradient.remove();
	}

	function readMap() {
		var bd = hxd.Res.map.toBitmap();
		wid = bd.width;
		hei = bd.height;
		coll = new haxe.ds.Vector(wid*hei);
		roads = new haxe.ds.Vector(wid*hei);
		walls = new haxe.ds.Vector(wid*hei);
		pixels = new Map();
		for(cy in 0...hei)
		for(cx in 0...wid) {
			var c = Color.removeAlpha( bd.getPixel(cx,cy) );
			roads.set( coordId(cx,cy), c==0x181818 );
			walls.set( coordId(cx,cy), c==0x7a7a7a );
			if( !pixels.exists(c) )
				pixels.set(c, []);
			pixels.get(c).push( new CPoint(cx,cy) );
			coll.set( coordId(cx,cy), c==0xFFFFFF);
		}

		var fMarks = new Map();
		for(pt in getPixels(0x00ff78)) fMarks.set(pt.cy, true);
		var cMarks = new Map();
		for(pt in getPixels(0x004eff)) cMarks.set(pt.cy, true);
		var f = 0.;
		var cy = hei-1;
		cityFactor = new Map();
		var isCity = false;
		while( cy>0 ) {
			if( fMarks.exists(cy) )
				isCity = false;
			if( cMarks.exists(cy) )
				isCity = true;
			f = MLib.fclamp(f + (isCity?0.1:-0.1), 0, 1);
			cityFactor.set(cy, f);
			cy--;
		}
	}

	public function iteratePixels(c:UInt, cb:Int->Int->Void) {
		if( !pixels.exists(c) )
			return;

		for(pt in pixels.get(c))
			cb(pt.cx, pt.cy);
	}

	public inline function getPixel(c:UInt) : Null<CPoint> {
		return pixels.exists(c) ? pixels.get(c)[0] : null;
	}

	public function getPixels(c:UInt) : Array<CPoint> {
		return pixels.exists(c) ? pixels.get(c) : [];
	}

	//function addSpot(k:String, cx,cy) {
		//if( !spots.exists(k) )
			//spots.set(k, []);
		//spots.get(k).push( { cx:cx, cy:cy } );
	//}
//
	//public inline function getSpot(k:String) : Null<{cx:Int, cy:Int}> {
		//return spots.exists(k) ? spots.get(k)[0] : null;
	//}
//
	//public inline function getSpots(k:String) : Array<{cx:Int, cy:Int}> {
		//return spots.exists(k) ? spots.get(k) : [];
	//}

	inline function hasRoad(x,y) return isValid(x,y) ? roads.get(coordId(x,y))==true : true;
	inline function hasWall(x,y) return isValid(x,y-2) ? walls.get(coordId(x,y-2))==true : true;

	public function render() {
		var rseed = new mt.Rand(1);

		if( sb!=null )
			sb.remove();
		sb = new HSpriteBatch(Assets.tiles.tile, root);
		sb.hasRotationScale = true;

		// Ground
		for(cx in 0...wid)
		for(cy in 0...hei) {
			if( cx%2==0 && cy%2==0 ) {
				var e = Assets.tiles.hbe_getRandom(sb, "cityGround", rseed.random);
				//e.setPos(
				e.x = cx*Const.GRID;
				e.y = cy*Const.GRID;
			}
		}

		// Roads
		for(cx in 0...wid)
		for(cy in 0...hei) {
			if( hasRoad(cx,cy) ) {
				var k =
					( hasRoad(cx,cy-1 ) ? 1 : 0 )
					+ ( hasRoad(cx+1,cy ) ? 2 : 0 )
					+ ( hasRoad(cx,cy+1 ) ? 4 : 0 )
					+ ( hasRoad(cx-1,cy ) ? 8 : 0 );
				var e = Assets.tiles.hbe_get(sb, "road", k);
				e.x = cx*Const.GRID;
				e.y = cy*Const.GRID;
			}
		}


		// Craters
		for(cy in 0...hei) {
			if( cy%8==0 ) {
				var e = Assets.tiles.hbe_getRandom(sb, "crater", rseed.random);
				e.rotation = rseed.range(0,0.7,true);
				e.scaleX = rseed.range(0.8,1);
				e.scaleY = rseed.range(0.8,1);
				e.x = rseed.range(0,wid)*Const.GRID;
				e.y = (cy+rseed.range(0,5))*Const.GRID;
				if( rseed.random(100)<40 )
					createFire(rseed, e.x+e.t.width*0.5+rseed.range(0,5,true), e.y+e.t.height*0.5+rseed.range(0,5,true) );
			}
		}

		// Ruins
		for(cx in 0...wid)
		for(cy in 0...hei) {
			if( cx%2==0 && cy%2==0 && !hasRoad(cx,cy) && !hasRoad(cx+1,cy) && !hasRoad(cx+1,cy+1) && !hasRoad(cx,cy+1) ) {
				if( !hasWall(cx,cy) && !hasWall(cx+1,cy) && !hasWall(cx+1,cy+1) && !hasWall(cx,cy+1) )
					if( rseed.random(100)<80 ) {
						var e = Assets.tiles.hbe_getRandom(sb, "ruins", rseed.random);
						e.x = cx*Const.GRID + rseed.irange(0,15,true);
						e.y = cy*Const.GRID + rseed.irange(0,15,true);
					}
			}
		}

		// City
		for(cx in 0...wid)
		for(cy in 0...hei) {
			if( cx%2==0 && cy%2==0 && !hasRoad(cx,cy) && !hasRoad(cx+1,cy) && !hasRoad(cx+1,cy+1) && !hasRoad(cx,cy+1) ) {
				if( !hasWall(cx,cy) && !hasWall(cx+1,cy) && !hasWall(cx+1,cy+1) && !hasWall(cx,cy+1) )
					if( rseed.rand()<cityFactor.get(cy) ) {
						for(i in 0...5)
							if( rseed.random(100)<55 ) {
								var e = Assets.tiles.hbe_getRandom(sb, "city", rseed.random);
								e.x = cx*Const.GRID + rseed.range(0,8,true);
								e.y = cy*Const.GRID - 10 + i*4;
								//e.y = cy*Const.GRID + rseed.range(0,10,true);
							}
					}
					else {
						for(i in 0...5)
							if( rseed.random(100)<65 ) {
								var e = Assets.tiles.hbe_getRandom(sb, "forest", rseed.random);
								e.x = cx*Const.GRID + rseed.range(0,16,true);
								e.y = cy*Const.GRID - 20 + i*4;
								//e.y = cy*Const.GRID + rseed.range(0,10,true);
							}
					}
			}
		}

		// Fires
		for(cx in 0...wid)
		for(cy in 0...hei) {
			if( rseed.random(100)<8 )
				createEmber(rseed, (cx*Const.GRID)+rseed.range(0,18,true), (cy*Const.GRID)+rseed.range(0,1,true) );
			else if( rseed.rand()<cityFactor.get(cy) && rseed.random(100)<7 )
				createFire(rseed, (cx*Const.GRID)+rseed.range(0,18,true), (cy*Const.GRID)+rseed.range(0,1,true) );
		}
	}

	function createFire(rseed:mt.Rand, x:Float, y:Float) {
		var e = Assets.tiles.hbe_getRandom(sb, "burnt", rseed.random);
		e.alpha = rnd(0.6,0.8);
		e.setCenterRatio(0.5,0.5);
		e.x = x;
		e.y = y+3;
		e.scaleX = rnd(1,2,true);
		e.scaleY = rnd(1,2,true);
		e.rotation = rnd(0,0.2,true);

		var em = new mt.heaps.HParticle.Emitter(Const.FPS);
		em.tickS = 0.10;
		var fx = Game.ME.fx;
		em.activeCond = function() return Game.ME.vp.isOnScreen(x,y);
		em.onUpdate = function() {
			// Rising flames
			var p = fx.allocBgAdd(fx.getTile("flame"), x+rnd(0,4,true), y);
			p.setFadeS(rnd(0.2,0.4), 0.2, rnd(0.2,0.4));
			p.gx = rnd(0,0.05);
			p.gy = -rnd(0.02,0.03);
			p.frict = rnd(0.85,0.89);
			p.scaleMul = rnd(0.93, 0.99);
			p.lifeS = rnd(0.5,0.7);

			// Ground
			var p = fx.allocBgAdd(fx.getTile("flame"), x+rnd(0,4,true), y+rnd(0,0,true));
			p.scale = rnd(0.5,1);
			p.setFadeS(rnd(0.2,0.4), 0.2, rnd(0.2,0.4));
			p.scaleMul = rnd(0.93, 0.99);
			p.lifeS = rnd(0.5,0.7);
		}
		emitters.push(em);
	}

	function createEmber(rseed:mt.Rand, x:Float, y:Float) {
		var e = Assets.tiles.hbe_getRandom(sb, "burnt", rseed.random);
		e.alpha = rnd(0.6,0.8);
		e.setCenterRatio(0.5,0.5);
		e.x = x;
		e.y = y+3;
		e.scaleX = rnd(1,2,true);
		e.scaleY = rnd(1,2,true);
		e.rotation = rnd(0,0.2,true);

		var em = new mt.heaps.HParticle.Emitter(Const.FPS);
		em.tickS = 0.4;
		var fx = Game.ME.fx;
		em.activeCond = function() return Game.ME.vp.isOnScreen(x,y);
		em.onUpdate = function() {
			var p = fx.allocBgAdd(fx.getTile("dot"), x+rnd(0,3,true), y+rnd(0,1,true));
			p.colorAnimS(0xFFFF80,0xFF0000,rnd(1,3));
			p.setFadeS(rnd(0.2,0.4), rnd(0.2,0.5), rnd(0.2,0.4));
			//p.scaleMul = rnd(0.93, 0.99);
			p.lifeS = rnd(1.5,3);
		}
		emitters.push(em);
	}

	public function createCrater(x:Float,y:Float, s:Float) {
		var rseed = new mt.Rand(1866);
		var e = Assets.tiles.hbe_getRandom(sb, "crater", rseed.random);
		e.setCenterRatio(0.5,0.5);
		e.rotation = rseed.range(0,0.7,true);
		e.scaleX = rseed.range(0.7,1)*s;
		e.scaleY = rseed.range(0.7,1)*s;
		e.x = x;
		e.y = y;
		if( rseed.random(100)<40 )
			createFire(rseed, e.x+e.t.width*0.5+rseed.range(0,5,true), e.y+e.t.height*0.5+rseed.range(0,5,true) );

		if( rseed.random(100)<70 )
			createEmber(rseed, x,y);
	}

	public inline function hasColl(x,y) return !isValid(x,y) ? true : coll.get( coordId(x,y) );
	public inline function isValid(x,y) return x>=0 && x<wid && y>=0 && y<hei;
	public inline function coordId(x,y) return x+y*wid;


	override function update() {
		super.update();

		if( !cd.hasSetS("cloud",rnd(0.7,1.5)) ) {
			var e : HSprite = Assets.tiles.h_getRandom("cloud");
			e.rotation = rnd(0,0.2,true);
			//e.setScale(rnd(0.6,1));
			e.scaleX = rnd(0.6,1,true);
			e.scaleY = MLib.fabs( e.scaleX * rnd(0.8,1.1) );
			e.setCenterRatio(0.5,1);
			Game.ME.scroller.add(e, Const.DP_FX_BG);
			if( Std.random(100)<80 ) {
				e.x = rnd(-100,30);
			}
			else {
				e.x = wid*Const.GRID + rnd(-30,100);
			}
			e.y = Game.ME.vp.topY;
			clouds.push({e:e, spd:rnd(1,3)});
			tw.createS(e.x, e.x+rnd(0,35,true), TLinear, 10);
		}

		var i = 0;
		while(i<clouds.length) {
			clouds[i].e.y+=Game.ME.sSpeed*Const.GRID * clouds[i].spd;
			if( clouds[i].e.y>=Game.ME.vp.bottomY+200 ) {
				clouds[i].e.remove();
				clouds.splice(i,1);
			}
			else
				i++;
		}

		for(e in emitters)
			e.update(1);
	}
}