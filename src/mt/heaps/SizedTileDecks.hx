package mt.heaps;

import mt.RandDeck;
import mt.heaps.slib.SpriteLib;

abstract SizedTileDecks(Array<SizedTileDeck>) from Array<SizedTileDeck> to Array<SizedTileDeck> {
	public var decks (get, never) : Array<SizedTileDeck>;
	public var length(get, never) : Int;

	inline function get_decks()  return this;
	inline function get_length() return this.length;

	public inline function iterator() {
		return new hxd.impl.ArrayIterator(this);
	}

	public static function fromGroup(slib : SpriteLib, k : String, ?px : Float, ?py : Float, ?rnd : Int->Int) : SizedTileDecks {
		inline function getKey(wid : Int, hei : Int) { return ((wid << 16)|hei); }
		var map = new Map<Int, SizedTileDeck>();

		var group  = slib.getGroup(k);
		if (group == null) return [];

		for (f in group.anim) {
			var fd  = slib.getFrameData(k, f).realFrame;
			var key = getKey(fd.realWid, fd.realHei);

			var deck = map.get(key);
			if (deck == null) {
				deck = new SizedTileDeck(fd.realWid, fd.realHei, rnd);
				map.set(key, deck);
			}

			deck.push(slib.getTile(k, f, px, py));
		}

		var decks = [for (deck in map) deck];
		for (d in decks) d.shuffle();
		return decks;
	}

	public function getBestFit(wid : Int, hei : Int) : { tile : h2d.Tile, wid : Int, hei : Int }  {
		var bestScore = Math.POSITIVE_INFINITY;
		var bestDeck : SizedTileDeck = null;
		for (d in decks) {
			if (d.wid > wid || d.hei > hei) continue;
			var score = (wid - d.wid) + (hei - d.hei);
			if (score < bestScore) {
				bestScore = score;
				bestDeck  = d; 
			}
		}
		if (bestDeck == null) return null;
		return {
			tile : bestDeck.pop(),
			wid  : bestDeck.wid,
			hei  : bestDeck.hei
		};
	}
}

class SizedTileDeck extends RandDeck<h2d.Tile> {
	public var wid (default, null) : Int;
	public var hei (default, null) : Int;

	public function new(wid : Int, hei : Int, ?rnd : Int->Int) {
		super(rnd);
		this.wid = wid;
		this.hei = hei;
	}
}