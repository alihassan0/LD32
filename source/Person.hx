package;
import flixel.*;
import flixel.util.*;
import flixel.ui.*;
/**
 * ...
 * @author MrCdK
 */
class Person extends FlxSprite {
	public var speed:Float = 250;
	public var level:Int = 1;
	
	private var healthBar:FlxBar;
	private var barOffset:FlxPoint = new flixel.util.FlxPoint(0,0);

	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		health = 100;
		healthBar = new flixel.ui.FlxBar(x + barOffset.x, y+ barOffset.y,FlxBar.FILL_LEFT_TO_RIGHT , 30, 3,this ,"health",0,100,false);	
		flixel.FlxG.state.add(healthBar);
	}
	override public function update():Void 
	{
		super.update();
		manageHealthBar();
	}
	public function manageHealthBar():Void 
	{
		healthBar.alpha -= .01;
		healthBar.x = x + barOffset.x;
		healthBar.y = y + barOffset.y;
	}
	override public function hurt(Damage:Float):Void 
	{
		healthBar.alpha = 1;
		super.hurt(Damage);
	}
	override public function kill():Void 
	{
		healthBar.kill();
		super.kill();
	}
}
