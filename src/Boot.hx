import mt.deepnight.Tweenie;

class Boot extends hxd.App {
	public static var ME : Boot;
	public var cached : h2d.CachedBitmap;
	var tw : mt.deepnight.Tweenie;
	var delayer : mt.Delayer;
	public var debugEnt = false;

	// Boot
	static function main() {
		hxd.Res.initEmbed({compressSounds:true});
		new Boot();
	}

	// Engine ready
	override function init() {
		ME = this;
		engine.backgroundColor = 0xff<<24|0x0;
		#if hl
		@:privateAccess hxd.Stage.getInstance().window.vsync = true;
		@:privateAccess hxd.Stage.getInstance().window.displayMode = Borderless;
		#end

		delayer = new mt.Delayer(Const.FPS);
		tw = new mt.deepnight.Tweenie(Const.FPS);
		Lang.init("en");
		Assets.init();
		wantedFPS = Const.FPS;
		hxd.Timer.tmod_factor = 0.0; // DT smoothing

		cached = new h2d.CachedBitmap(s2d);

		var c = new h2d.Console(Assets.font, s2d);
		h2d.Console.HIDE_LOG_TIMEOUT = 60;
		mt.deepnight.Lib.redirectTracesToH2dConsole(c);
		c.addCommand("d", [], function() {
			debugEnt = !debugEnt;
			for(e in Entity.ALL)
				@:privateAccess e.invalidateDebug = true;
		});

		new Main(cached);
		onResize();
	}


	override function onResize() {
		super.onResize();
		var w = hxd.Stage.getInstance().width;
		var h = hxd.Stage.getInstance().height;
		if( !Const.GIF_MODE )
			Const.SCALE = Std.int( mt.MLib.fmin( w/(Const.VWID*Const.GRID), h/(Const.VHEI*Const.GRID) ) );
		cached.setScale(Const.SCALE);
		cached.width = Const.VWID*Const.GRID;
		cached.height = Const.VHEI*Const.GRID;
		cached.x = Std.int( w*0.5 - cached.width*Const.SCALE*0.5 );
		cached.y = Std.int( h*0.5 - cached.height*Const.SCALE*0.5 );
		//cached.width = mt.MLib.ceil( w / Const.SCALE );
		//cached.height = mt.MLib.ceil( h / Const.SCALE );
		mt.Process.resizeAll();
	}

	var accu = 0.;
	var slowMo = 0.;
	var paused = false;
	override function update(dt:Float) {
		super.update(dt);
		delayer.update(1);
		tw.update(1);

		Game.ME.updateKeys();

		//#if debug
		if( hxd.Key.isPressed(hxd.Key.NUMPAD_SUB) ) {
			slowMo = slowMo==0 ? 1 : 0;
		}
		if( hxd.Key.isPressed(hxd.Key.P) ) {
			paused = !paused;
		}
		//#end
		accu += dt / ( 1 + slowMo*4 ) * (paused?0:1);
		//#if debug
		if( hxd.Key.isDown(hxd.Key.NUMPAD_ADD) )
			accu+=10;
		//#end
		while( accu>=1 ) {
			accu-=1;
			mt.Process.updateAll(1);
		}
	}
}

