package;

import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	var sound:FlxSound;

	//Zalrek mod stuff, sprite swapping
	var curMood:String = '';

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'exorcism':
				sound = new FlxSound().loadEmbedded(Paths.music('Lunchbox'),true);
				sound.volume = 0;
				FlxG.sound.list.add(sound);
				sound.fadeIn(1, 0, 0.8);
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		box = new FlxSprite(-20, 45);
		
		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			
			case 'exorcism':
				hasDialog = true;
				
		}

		box.frames = Paths.getSparrowAtlas('speech_bubble_talking', 'shared'); //replace later
		box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
		box.animation.addByIndices('normal', 'speech bubble normal', [4], "", 24);
		box.setGraphicSize(Std.int(box.width * 1 * 1));
		box.y = (FlxG.height - box.height) + 80;
		

		this.dialogueList = dialogueList;
		
		if (!hasDialog)
			return;
				
			
		//Zalrek mod related stuff, gets portraits ready
		if (PlayState.SONG.song.toLowerCase() == 'exorcism') {
			portraitRight = new FlxSprite(0, 40);
			portraitRight.frames = Paths.getSparrowAtlas('characters/portraits/Boyfriend', 'shared');
			portraitRight.animation.addByPrefix('enter', 'Neutral', 24, false);
			portraitRight.setGraphicSize(Std.int(portraitRight.width * 1 * 0.75));
			portraitRight.updateHitbox();
			portraitRight.antialiasing = true;
			portraitRight.scrollFactor.set();
			add(portraitRight);
			portraitRight.visible = false;

			portraitRight.x = (box.x + box.width) - (portraitRight.width) - 60;
			portraitRight.y = box.y - 180;
		}

		
		if (PlayState.SONG.song.toLowerCase() == 'exorcism') {
			portraitLeft = new FlxSprite(-20, 40);
			portraitLeft.frames = Paths.getSparrowAtlas('characters/portraits/Zalrek', 'shared');
			portraitLeft.animation.addByPrefix('enter', 'Neutral', 24, false);
			portraitLeft.setGraphicSize(Std.int(portraitLeft.width * 1 * 0.75));
			portraitLeft.updateHitbox();
			portraitLeft.antialiasing = true;
			portraitLeft.scrollFactor.set();
			add(portraitLeft);
			portraitLeft.visible = false;

			portraitLeft.x = box.x + portraitRight.width - 180;
		}

		
		
		box.animation.play('normalOpen');
		//box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
		box.updateHitbox();
		add(box);

		box.screenCenter(X);
		box.x = box.x + 50;
		//portraitLeft.screenCenter(X);
		


		if (!talkingRight)
		{
			// box.flipX = true;
		}

		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		dropText.font = 'Pixel Arial 11 Bold';
		dropText.color = FlxColor.BLACK;
		add(dropText);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = 'Pixel Arial 11 Bold';
		swagDialogue.color = 0xFF3F2021;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{	

		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (PlayerSettings.player1.controls.ACCEPT && dialogueStarted == true)
		{
			remove(dialogue);
				
			FlxG.sound.play(Paths.sound('clickText'), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;

					if (PlayState.SONG.song.toLowerCase() == 'exorcism')
						sound.fadeOut(2.2, 0);
					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 5;
						bgFade.alpha -= 1 / 5 * 0.7;
						portraitLeft.visible = false;
						portraitRight.visible = false;
						swagDialogue.alpha -= 1 / 5;
						dropText.alpha = swagDialogue.alpha;
					}, 5);

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();

		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);

		//Zalrek mod related stuff. Checks if Zal is in the line and plays dialogue. Will check for other characters later
		switch (curCharacter)
		{
			case 'bf':
				portraitLeft.visible = false;
				swagDialogue.color = 0xFF0097C4;
				//trace('Dialogue color should be 0xFF0097C4, but is ' + swagDialogue.color);
				if (!portraitRight.visible)
				{
					portraitRight.frames = Paths.getSparrowAtlas('characters/portraits/Boyfriend', 'shared');
					portraitRight.animation.addByPrefix('enter', curMood, 24, false);
					portraitRight.setGraphicSize(Std.int(portraitRight.width * 1 * 0.75));
					portraitRight.updateHitbox();
					portraitRight.antialiasing = true;
					portraitRight.scrollFactor.set();

					portraitRight.x = (box.x + box.width) - (portraitRight.width) - 60;
					portraitRight.y = box.y - 180;

					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
			case 'zalrek':
				portraitRight.visible = false;
				swagDialogue.color = 0xFF820F0F;
				//trace('Dialogue color should be 0xFF820F0F, but is ' + swagDialogue.color);
				if (!portraitLeft.visible)
				{
					portraitLeft.frames = Paths.getSparrowAtlas('characters/portraits/Zalrek', 'shared');
					portraitLeft.animation.addByPrefix('enter', curMood, 24, false);
					portraitLeft.setGraphicSize(Std.int(portraitLeft.width * 1 * 0.75));
					portraitLeft.updateHitbox();
					portraitLeft.antialiasing = true;
					portraitLeft.scrollFactor.set();

					portraitLeft.x = box.x + portraitRight.width - 180;

					portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
				}
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];

		//Zalrek mod related stuff, getting mood from file
		if (curCharacter == 'bf' || curCharacter == 'zalrek') {
			curMood = splitName[2];
			//trace('Character is ' + curCharacter + ' and mood is ' + curMood);
			dialogueList[0] = dialogueList[0].substr(splitName[1].length + splitName[2].length + 3).trim();
		}

		else {
			dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
		}
		
	}
}
