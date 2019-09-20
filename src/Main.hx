import dn.Tweenie;

class Main extends dn.Process {
	public static var ME : Main;

	public function new(p) {
		super();
		ME = this;
		createRoot(p);
		new dn.heaps.GameFocusHelper(Boot.ME.s2d, Assets.font);

		transition( function() return new Game() );
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
}

