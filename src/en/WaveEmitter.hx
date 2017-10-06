package en;

import mt.MLib;
import mt.deepnight.Lib;

typedef WaveInstruction = {
	var cmd:String;
	var val:Int;
}

class WaveEmitter extends Entity {
	public var seed : Int;
	var running : Bool;
	var count : Int;
	var tickCb : Void->en.Mob;
	var freqS : Float;
	public var topTriggerDist = 7;

	public function new(x,y, n:Int, cb:Void->en.Mob, freqS=0.5) {
		super(x,y);
		this.freqS = freqS;
		count = n;
		running = false;
		tickCb = cb;
		//seed = cx+cy*lvl.wid;
		seed = cy;

		spr.set("red");
	}

	public inline function makeRand() return new mt.Rand(seed);


	function getTriggerY() {
		if( cx<=0 || cx>=lvl.wid-1 )
			return game.vp.topCy+topTriggerDist;
		return game.vp.topCy-1;
	}

	override public function update() {
		super.update();
		//#if !debug
		spr.visible = false;
		//#end
		spr.alpha = count>0 ? 1 : 0.5;
		if( !running && count>0 && cy>=getTriggerY() )
			running = true;

		if( running ) {
			followScroll = true;
			if( !cd.hasSetS("pop",freqS) ) {
				var e : en.Mob = tickCb();
				if( cx<=0 )
					e.setPosPixel(centerX-Const.GRID, centerY);
				else if( cx>=lvl.wid-1 )
					e.setPosPixel(centerX+Const.GRID, centerY);
				else
					e.setPosPixel(centerX, centerY);
				e.wave = this;
				count--;
				if( count<=0 ) {
					followScroll = false;
					running = false;
				}
			}
		}
	}
}