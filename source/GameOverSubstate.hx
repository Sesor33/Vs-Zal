package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	//Zalrek mod related variables
	var zalInsultDialogue:Array<String> = [];
	var disableInput:Bool = false;

	public function new(x:Float, y:Float)
	{
		var daStage = PlayState.curStage;
		var daBf:String = '';
		switch (PlayState.SONG.player1)
		{
			case 'bf-pixel':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			default:
				daBf = 'bf';
		}

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		//Zalrek mod stuff, game over text
		trace('you died. song is ' + PlayState.SONG.song);
		trace ('also you have died ' + PlayState.deaths + ' times');
		if (PlayState.SONG.song == 'Exsanguination' && PlayState.deaths >= 0) {
			zalInsultDialogue = CoolUtil.coolTextFile(Paths.txt('data/exsanguination/insults'));

			add(PlayState.zalPortrait);
			add(PlayState.speechBubble);
			add(PlayState.hintDropText);
			add(PlayState.hintText);

			PlayState.zalPortrait.animation.play('enter');
			FlxTween.tween(PlayState.zalPortrait, {alpha: 1}, 0.1);
			PlayState.speechBubble.animation.play('normalOpen');
			PlayState.speechBubble.animation.finishCallback = function(anim:String):Void {

				PlayState.hintText.resetText(zalInsultDialogue[PlayState.deaths - 1]);
				PlayState.hintText.start(0.04, true);
				PlayState.hintText.completeCallback = function()
				{
					disableInput = false;
				}
			}
		}

		if (PlayState.SONG.song == 'Exsanguination') {
			PlayState.deaths++;
			if (PlayState.deaths >= zalInsultDialogue.length - 1) {		
				PlayState.deaths = 0;
			}
		}
	}

	var startVibin:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT && !disableInput)
		{
			endBullshit();
		}

		else if (controls.ACCEPT && startVibin && !disableInput) {				
			FlxG.sound.play(Paths.sound('clickText'), 0.4);
			PlayState.hintText.resetText(zalInsultDialogue[PlayState.deaths]);
			PlayState.hintText.start(0.04, true);
		}
			

		if(FlxG.save.data.InstantRespawn)
		{
			LoadingState.loadAndSwitchState(new PlayState());
		}

		if (controls.BACK)
		{
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
				FlxG.switchState(new FreeplayState());
			PlayState.loadRep = false;
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
			startVibin = true;
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}

		if (PlayState.hintDropText.text != PlayState.hintText.text)
			PlayState.hintDropText.text = PlayState.hintText.text;
	}

	override function beatHit()
	{
		super.beatHit();

		if (startVibin && !isEnding)
		{
			bf.playAnim('deathLoop', true);
		}
		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			PlayState.startTime = 0;
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
