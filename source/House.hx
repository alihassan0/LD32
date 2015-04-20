package;
import flixel.*;
import flixel.util.*;
import flixel.group.FlxTypedGroup;
import flixel.effects.FlxFlicker;
/**
 * ...
 * @author MrCdK
 */
class House extends Soldier {

public var maxNumber:Int;
public var count:Int = 0 ;
private var hzone:Int = 0 ;
private var timer:FlxTimer;

	public function new(X:Float=0, Y:Float=0 , color:Int , maxNumber:Int, hzone:Int)
	{
		super(X, Y);
		this.hzone = hzone;
		this.loadGraphic("assets/images/house2.png");
		
		timer = new flixel.util.FlxTimer();
		timer.start(3 ,spawnEnemies,Std.int(Math.POSITIVE_INFINITY));
		this.color = color;
		this.maxNumber = maxNumber;
	}
	public function spawnEnemies(t:FlxTimer):Void 
	{
		if((hzone == 1)|| (hzone == 2 && MenuState.zoneUnlocked2) || (hzone == 3 && MenuState.zoneUnlocked3))
		{
			if(count < maxNumber)
			{
				var s:Soldier = new Soldier(x+width/2 , y+height/2 , Math.floor(Math.random()*2));
				s.zone = hzone;
				MenuState.soldiers.add(s);
				s.initialPoint = new flixel.util.FlxPoint(x - Math.random()*100 , y  +50 - Math.random()*100);
				count ++ ;
				t.time = 5+count*2;
			}			
		}
	}
	override public function AiBrain():Void
	{
		
	}
	override public function kill():Void
	{
		alpha = 0;
		timer.destroy();
		MenuState.player.level ++;
		if(hzone == 1)
		{
			MenuState.zoneUnlocked2 = true;
			MenuState.zoneUnlocked1 = false;
			MenuState.blockers1.kill();
		}
		if(hzone == 2)
		{
			MenuState.zoneUnlocked3 = true;
			MenuState.zoneUnlocked2 = false;
			MenuState.blockers2.kill();
		}
		if(hzone == 3)
		{
			MenuState.zoneUnlocked3 = false;
			MenuState.player.isWinner = true;
			flixel.FlxG.switchState(new GameOverState());
		}
	}
	override public function showParticle(amount:Int):Void
	{

	}
	override public function hurt(Damage:Float):Void 
	{
		Damage /= (4*hzone);
		healthBar.kill();
		healthBar.alpha = 1;
		super.hurt(Damage);
	}
}