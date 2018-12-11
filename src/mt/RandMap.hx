package mt;
import haxe.ds.Vector;

class RandMap {
	public var length (get, never) : Int;
	public var data : Vector<Float>;

	var freqs   : Array<Float>;
	var weights : Array<Float>;
	var noises  : Vector<Vector<Float>>;
	var rnd     : Void->Float;

	inline function get_length() return data.length;

	public function new(size : Int, freqs : Array<Float>, weights : Array<Float>, ?rnd : Void->Float) {
		if (freqs.length != weights.length) throw "freqs & weights must have the same number of elements";
		this.freqs   = freqs;
		this.weights = weights;
		this.data    = new Vector(size);
		this.rnd     = (rnd == null) ? Math.random : rnd;
		this.noises  = new Vector<Vector<Float>>(freqs.length);
		for (i in 0...freqs.length) noises[i] = new Vector<Float>(length);
		shuffle();
	}

	public function shuffle() {
		if (length == 1) {
			data[0] = rnd();
			return;
		}

		for (i in 0...freqs.length) {
			var phase = rnd() * 2 * Math.PI;
			for (j in 0...length)
				noises[i][j] = Math.sin(2 * Math.PI * freqs[i] * j / length + phase);
		}

		for (i in 0...length) data[i] = 0.0;

		for (i in 0...noises.length)
		for (j in 0...length)
			data[j] += weights[i] * noises[i][j];

		// clamp output between 0 & 1
		var max = 0.0;
		var min = Math.POSITIVE_INFINITY;
		for (v in data) {
			if (v > max) max = v;
			if (v < min) min = v;
		}

		var scale = max - min;
		if (scale == 0) scale = 1;

		for (i in 0...length) {
			data[i] = (data[i] - min) / scale;
		}
	}

	public function getDensityThreshold(density : Float) : Float {
		var indices = new Vector<Int>(length);
		for (i in 0...length) indices[i] = i;
		indices.sort(sortIndices);

		var max = density * length;
		for (i in 0...indices.length) {
			var threshold = data[indices[i]];
			var d = 0;
			for (v in data) if (v >= threshold) ++d;
			if (d >= max) return threshold;
		}

		return 1;
	}

	function sortIndices(a : Int, b : Int) : Int {
		var va = data[a];
		var vb = data[b];
		if (va > vb) return -1;
		if (va < vb) return  1;
		return 0;
	}
}