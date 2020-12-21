import dn.Tweenie;

class Main extends dn.Process {
	public static var ME : Main;
	public var controller : dn.heaps.Controller;

	public function new(p) {
		super();
		ME = this;
		createRoot(p);
		// new dn.heaps.GameFocusHelper(Boot.ME.s2d, Assets.font);

		controller = new dn.heaps.Controller(Boot.ME.s2d);
		controller.bind(AXIS_LEFT_X_NEG, Key.LEFT);
		controller.bind(AXIS_LEFT_X_POS, Key.RIGHT);
		controller.bind(AXIS_LEFT_Y_NEG, Key.UP);
		controller.bind(AXIS_LEFT_Y_POS, Key.DOWN);
		controller.bind(Y, Key.Z, Key.W);
		controller.bind(X, Key.Q, Key.A);
		controller.bind(B, Key.D);
		controller.bind(A, Key.S);
		controller.bind(SELECT, Key.R);

		hxd.Timer.skip();

		delayer.addF(function() {
			Assets.music.playOnGroup(1,true);
			transition( function() return new Game() );
		}, 1);
		onResize();
	}


	var curProcess : dn.Process;
	public function transition(cb:Void->dn.Process) {
		var d = 0.8;
		if( curProcess!=null && curProcess.root!=null ) {
			tw.createS(curProcess.root.alpha, 0, d).end( function() {
				curProcess.destroy();
				delayer.addS(function() {
					curProcess = cb();
					dn.Process.resizeAll();
					tw.createS(curProcess.root.alpha, 0>1, d);
				}, 0.3);
			} );
		}
		else {
			curProcess = cb();
			tw.createS(curProcess.root.alpha, 0>1, d);
		}
	}

	override function update() {
		super.update();
		dn.heaps.Controller.beforeUpdate();
	}
}

