package;
import flixel.*;
import flixel.util.*;
import flixel.ui.*;
import flixel.text.FlxText;
/**
 * ...
 * @author MrCdK
 */

using flixel.util.FlxSpriteUtil;

class Person extends FlxSprite {
	public var speed:Float = 250;
	public var level:Int = 1;
	public var range:Float = 50.0;
	private var healthBar:FlxBar;
	private var barOffset:FlxPoint = new flixel.util.FlxPoint(0,0);
	public var isEnemy:Bool = true;
	public var rangeSprite:FlxSprite;
	private var rangeIndex:Float = 1.1;
	private var statusText:FlxText;
	private var statusIndex:Float = 0;
	private var rangeScale:Float = 1.5;

	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		range *= rangeScale;
		flixel.FlxG.state.add(this);
		health = 100;
		rangeSprite = new flixel.FlxSprite(x,y).makeGraphic(cast 2*range,cast 2*range, 0x00ffffff,true);
		FlxG.state.add(rangeSprite);
		
		healthBar = new flixel.ui.FlxBar(x + barOffset.x, y+ barOffset.y,FlxBar.FILL_LEFT_TO_RIGHT , 30, 3,this ,"health",0,100,false);	
		flixel.FlxG.state.add(healthBar);

		statusText = new FlxText(x,y,100,"come").setFormat(null,8,0xff003300,"center");
		statusText.alpha = 0;
		flixel.FlxG.state.add(statusText);

	}
	override public function update():Void 
	{
		super.update();
		manageHealthBar();
		if(health < 100)
		health += .01 * level;
		
	}
	public function manageHealthBar():Void 
	{
		if(health > 80)
			healthBar.alpha -= .01;
		healthBar.x = x + barOffset.x;
		healthBar.y = y + barOffset.y;

		rangeSprite.x = x + width/2 - range;
		rangeSprite.y = y + height/2 - range;

		if(rangeIndex < 1)
		{
			var lineStyle = { color: FlxColor.GREEN, thickness: 1.0 };
			rangeSprite.fill(0x00ffffff);
			rangeSprite.drawCircle(range, range, range*rangeIndex, 0x00ffffff,lineStyle);
			if(rangeIndex >.1)
			rangeSprite.alpha = 1-rangeIndex;
			rangeIndex += 1/60;//1 second
		}

		statusText.x = x + width/2 - statusText.width/2;
		statusText.y = y + height/2 - statusText.height/2;

		if(statusIndex < 1 || statusText.alpha >0)
		{
			statusText.scale = new flixel.util.FlxPoint(1 + statusIndex* 1.2 ,1 + statusIndex*1.2);
			statusText.y -= 15*statusIndex;
			statusText.alpha -= .01;
			statusIndex += 1/60;//1 second
		}

	}
	override public function hurt(Damage:Float):Void 
	{
		healthBar.alpha = 1;
		super.hurt(Damage);
	}
	public function signal():Bool 
	{
		if(rangeIndex > 1)
		{
			rangeIndex = 0;
			return true;
		}
		return false;	
	}
	public function shout(text:String):Bool 
	{
		if(statusText.alpha < 0.1 )
		{
			statusIndex = 0;
			statusText.alpha = 1;
			statusText.text = text;
			if(isEnemy)
			statusText.color = flixel.util.FlxColor.RED;
			else
			statusText.color = flixel.util.FlxColor.GREEN;
			return true;
		}
		return false;
	}
	override public function kill():Void 
	{
		healthBar.kill();
		statusText.kill();
		rangeSprite.kill();
		if(health <= 0)
		FlxG.sound.play("assets/sounds/die.wav");		
		super.kill();
	}
	override public function revive():Void 
	{
		healthBar.revive();
		statusText.revive();
		rangeSprite.revive();
		health = 100;	
		super.kill();
	}
}
