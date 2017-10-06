import mt.deepnight.Tweenie;

class Main extends mt.Process {
	public static var ME : Main;

	public function new(p) {
		super();
		ME = this;
		createRoot(p);

		transition( function() return new Game() );
		onResize();
	}


	var curProcess : mt.Process;
	public function transition(cb:Void->mt.Process) {
		var d = 0.8;
		if( curProcess!=null && curProcess.root!=null ) {
			tw.createS(curProcess.root.alpha, 0, d).end( function() {
				curProcess.destroy();
				delayer.addS(function() {
					curProcess = cb();
					mt.Process.resizeAll();
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

