class Tutorial extends dn.Process {
	static var DONES : Map<String,Bool> = new Map();
	public static var ME : Tutorial;

	public var game(get,never) : Game; inline function get_game() return Game.ME;
	public var kidMode(get,never) : Bool; inline function get_kidMode() return Game.ME.cd.has("kid");
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
		return k==cur || hasDone(k) || kidMode;
	}

	public inline function hasDone(k) {
		if( disable || kidMode )
			return true;
		return DONES.exists(k);
	}

	override function update() {
		super.update();

		if( game.hero.destroyed || kidMode ) {
			destroy();
			return;
		}

		var dist = game.vp.elapsedDistCase;

		if( tryToStart("controls") )
			new TutorialTip(Lang.untranslated("Use keyboard *ARROWS* or GamePad to move."));
		if( hero.cy<=game.vp.bottomCy-8 )
			tryToComplete("controls");

		if( dist>=6 ) {
			if( tryToStart("energy") ) {
				game.pause();
				new TutorialTip(Lang.untranslated("*Your engines have limited power*. Spread your energy wisely among the ship systems."));
			}

			if( tryToStart("lazer") ) {
				game.pause();
				if( Game.ME.ca.isGamePad() )
					new TutorialTip(hero.centerX, hero.centerY-19, Lang.untranslated("Press *Y button multiple times* to boost *MACHINE GUNS*!"), function() return Game.ME.ca.yPressed());
				else
					new TutorialTip(hero.centerX, hero.centerY-19, Lang.untranslated("Press *W multiple times* to boost *MACHINE GUNS*!"), function() return Game.ME.ca.yPressed());
			}

			if( game.vp.elapsedDistCase>=14 && tryToStart("missile") ) {
				game.pause();
				if( Game.ME.ca.isGamePad() )
					new TutorialTip(hero.centerX+16, hero.centerY, Lang.untranslated("Press *B button multiple times* to boost *MISSILES*!"), function() return Game.ME.ca.bPressed());
				else
					new TutorialTip(hero.centerX+16, hero.centerY, Lang.untranslated("Press *D multiple times* to boost *MISSILES*!"), function() return Game.ME.ca.bPressed());
			}

			if( dist>=21 && tryToStart("shield") ) {
				game.pause();
				if( Game.ME.ca.isGamePad() )
					new TutorialTip(hero.centerX-17, hero.centerY, Lang.untranslated("Press *X button multiple times* to boost *SHIELD REGEN*!"), function() return Game.ME.ca.xPressed());
				else
					new TutorialTip(hero.centerX-17, hero.centerY, Lang.untranslated("Press *A multiple times* to boost *SHIELD REGEN*!"), function() return Game.ME.ca.xPressed());
			}

			if( dist>=26 && tryToStart("balance") ) {
				game.pause();
				if( Game.ME.ca.isGamePad() )
					new TutorialTip(hero.centerX, hero.centerY, Lang.untranslated("Press *A button* to balance energy."), function() return Game.ME.ca.aPressed());
				else
					new TutorialTip(hero.centerX, hero.centerY, Lang.untranslated("Press *S* to balance energy."), function() return Game.ME.ca.aPressed());
			}

			//if( hasDone("balance") && tryToStart("allDone") ) {
				//game.pause();
				//new TutorialTip(Lang.untranslated("Remember: *WASD\nGoog luck :)") );
			//}
		}
	}
}