import hxd.Key;
import mt.MLib;

class Tutorial extends mt.Process {
	static var DONES : Map<String,Bool> = new Map();
	public static var ME : Tutorial;

	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var lvl(get,never) : Level; inline function get_lvl() return Game.ME.lvl;
	public var fx(get,never) : Fx; inline function get_fx() return Game.ME.fx;
	public var hero(get,never) : en.Hero; inline function get_hero() return Game.ME.hero;

	public var cur : Null<String>;

	var disable = false;

	public function new() {
		super(Game.ME);
		#if debug
		disable = true;
		#end
		ME = this;
		cd.setS("lock",1);
	}

	public function tryToStart(k) {
		if( disable || game.hero.destroyed )
			return false;

		if( DONES.exists(k) || cur!=null || cd.has("lock") )
			return false;

		cur = k;
		return true;
	}

	public function completeCurrent() {
		if( cur!=null )
			tryToComplete(cur);
	}
	public function tryToComplete(k) {
		if( cur!=k || game.hero.destroyed )
			return false;

		DONES.set(k,true);
		cur = null;
		cd.setS("lock",0.5);
		TutorialTip.clear();
		return true;
	}

	public inline function isDoingOrDone(k) {
		return k==cur || hasDone(k);
	}

	public inline function hasDone(k) {
		if( disable )
			return true;
		return DONES.exists(k);
	}

	override function update() {
		super.update();

		if( game.hero.destroyed ) {
			destroy();
			return;
		}

		var dist = game.vp.elapsedDistCase;

		if( tryToStart("controls") )
			new TutorialTip(Lang.untranslated("Use *ARROWS* to move."));
		if( hero.cy<=game.vp.bottomCy-8 )
		//if( hero.cd.has("l") && hero.cd.has("r") && hero.cd.has("u") && hero.cd.has("d") )
			tryToComplete("controls");

		if( dist>=6 ) {
			if( tryToStart("energy") ) {
				game.pause();
				new TutorialTip(Lang.untranslated("You have a *limited* amount of power. Spread it between you *ship systems* to maximize efficiency."));
			}

			if( tryToStart("lazer") ) {
				game.pause();
				new TutorialTip(hero.centerX, hero.centerY-19, Lang.untranslated("Invest more energy to your *machine gun* by pressing *W two times*!"), [Key.W,Key.Z]);
			}

			if( game.vp.elapsedDistCase>=14 && tryToStart("missile") ) {
				game.pause();
				new TutorialTip(hero.centerX+16, hero.centerY, Lang.untranslated("MOVE power to your *missiles* by pressing *D* multiple times!"), [Key.D]);
			}

			if( dist>=21 && tryToStart("shield") ) {
				game.pause();
				new TutorialTip(hero.centerX-17, hero.centerY, Lang.untranslated("Accelerate your *shield regen* by moving energy to the shield system: press *A*."), [Key.A,Key.Q]);
			}

			if( dist>=26 && tryToStart("balance") ) {
				game.pause();
				new TutorialTip(hero.centerX, hero.centerY, Lang.untranslated("You can't have full power in all 3 systems at the same time. Press *S* to balance energy *evenly*."), [Key.S]);
			}

			//if( hasDone("balance") && tryToStart("allDone") ) {
				//game.pause();
				//new TutorialTip(Lang.untranslated("Remember: *WASD\nGoog luck :)") );
			//}
		}
	}
}