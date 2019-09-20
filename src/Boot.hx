import dn.Tweenie;

class Boot extends hxd.App {
	public static var ME : Boot;
	public var gameWrapper : h2d.Object;
	public var mask : h2d.Mask;
	var tw : dn.Tweenie;
	var delayer : dn.Delayer;
	public var debugEnt = false;

	// Boot
	static function main() {

		new Boot();
	}

	// Engine ready
	override function init() {
		ME = this;
		engine.backgroundColor = 0xff<<24|0x0;
		#if hl
		@:privateAccess hxd.Window.getInstance().window.vsync = true;
		@:privateAccess hxd.Window.getInstance().window.displayMode = Borderless;
		#end

		// Resources
		#if debug
		hxd.Res.initLocal();
        #else
        hxd.Res.initEmbed({compressSounds:true});
        #end

		delayer = new dn.Delayer(Const.FPS);
		tw = new dn.Tweenie(Const.FPS);
		Lang.init("en");
		Assets.init();
		hxd.Timer.wantedFPS = Const.FPS;
		// hxd.Timer.tmod_factor = 0.0; // DT smoothing

		mask = new h2d.Mask(Const.VWID*Const.GRID, Const.VHEI*Const.GRID, s2d);
		gameWrapper = new h2d.Object(mask);

		var c = new h2d.Console(Assets.font, s2d);
		h2d.Console.HIDE_LOG_TIMEOUT = 60;
		dn.Lib.redirectTracesToH2dConsole(c);
		c.addCommand("d", [], function() {
			debugEnt = !debugEnt;
			for(e in Entity.ALL)
				@:privateAccess e.invalidateDebug = true;
		});

		new Main(mask);
		onResize();
	}


	override function onResize() {
		super.onResize();
		var w = hxd.Window.getInstance().width;
		var h = hxd.Window.getInstance().height;
		if( !Const.GIF_MODE )
			Const.SCALE = Std.int( M.fmin( w/(Const.VWID*Const.GRID), h/(Const.VHEI*Const.GRID) ) );
		mask.setScale(Const.SCALE);
		// cached.width = Const.VWID*Const.GRID;
		// cached.height = Const.VHEI*Const.GRID;
		mask.x = Std.int( w*0.5 - (Const.VWID*Const.GRID)*Const.SCALE*0.5 );
		mask.y = Std.int( h*0.5 - (Const.VHEI*Const.GRID)*Const.SCALE*0.5 );
		//cached.width = M.ceil( w / Const.SCALE );
		//cached.height = M.ceil( h / Const.SCALE );
		dn.Process.resizeAll();
	}

	var accu = 0.;
	var slowMo = 0.;
	var paused = false;
	override function update(dt:Float) {
		super.update(dt);
		var tmod = hxd.Timer.tmod;
		delayer.update(1);
		tw.update(1);

		Game.ME.updateKeys();

		#if debug
		if( hxd.Key.isPressed(hxd.Key.NUMPAD_SUB) ) {
			slowMo = slowMo==0 ? 1 : 0;
		}
		if( hxd.Key.isPressed(hxd.Key.P) ) {
			paused = !paused;
		}
		#end

		accu += tmod / ( 1 + slowMo*4 ) * (paused?0:1);

		#if debug
		if( hxd.Key.isDown(hxd.Key.NUMPAD_ADD) )
			accu+=10;
		#end

		while( accu>=1 ) {
			accu-=1;
			dn.Process.updateAll(1);
		}
	}
}

