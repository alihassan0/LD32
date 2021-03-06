package;
import flixel.*;
import flixel.util.*;
import flixel.group.FlxTypedGroup;
import flixel.effects.FlxFlicker;
/**
 * ...
 * @author MrCdK
 */
class Player extends Person {
	public var followers:FlxTypedGroup<Soldier>;
	public var command:Int = 0;	
	public var isWinner:Bool = false;	
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		loadGraphic("assets/images/player.png", true, 32, 32);
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		animation.add("run", [0,2,0,3], 15, true);
		animation.add("idle", [0,1], 2, true);
		animation.callback = animCallback;
		drag.x = drag.y = 1600;
		followers = new FlxTypedGroup<Soldier>();
		isEnemy = false;
	}
	override public function update():Void 
	{
		super.update();
		if(alive)
		{
			if(FlxG.keys.justPressed.G )
			{
				persudeOthers();
			}
			if(FlxG.keys.justPressed.J )
			{
				if( command == 0)
				{
					if(health<100)
					health += 10*level;
					
					shout("heal");
					for (i in 0 ... followers.length) {
						if(followers.members[i] != null && followers.members[i].alive && followers.members[i].health < 100)
						{
							followers.members[i].health += 10*level;
							followers.members[i].healthBar.alpha = 1;
						}
					}
				}
			}
			if(FlxG.keys.justPressed.H)
			{
				if(command == 0)
				{
					command = 1;
					shout("Attack !!!");
				}
				else
				{
					command = 0;
					shout("Follow Me !!!");
				}
			}
			controlMovementAndAnimation();		
		}
		
	}
	public function animCallback(s:String, f:Int, i:Int):Void
	{
		if (s == "run" && i == 0)
		{
			FlxG.sound.play("assets/sounds/step.wav");	
		}
	}
	public function persudeOthers():Void {
		var person:Person = MenuState.getNearestTo(new flixel.util.FlxPoint(x,y),0,100);
		if(person != null && statusText.alpha < 0.1  )
		{
			var soldier:Soldier = cast person;
			//soldier.kill();
			if(!soldier.emitter.on)
			{
				soldier.showParticle(20);
				signal();
				FlxFlicker.flicker(soldier,1.0);
				shout("COME WITH ME !!");
				FlxG.sound.play("assets/sounds/Powerup.wav");
			}
		}
	}
	override public function kill():Void 
	{	
		flixel.FlxG.switchState(new GameOverState());
		super.kill();
	}
	public function controlMovementAndAnimation():Void {
		if(flixel.FlxG.keys.pressed.RIGHT && x < MenuState.tileMap.get_width()-width-16){
			facing = FlxObject.LEFT;
			this.velocity.x = speed;
			animation.play("run");
		}
		if (flixel.FlxG.keys.pressed.LEFT && x > 16) {
			facing = FlxObject.RIGHT;
			this.velocity.x = -speed;
			animation.play("run");
		}

		if(flixel.FlxG.keys.pressed.UP && y >16){
			this.velocity.y = -speed;
			animation.play("run");
		}

		if (flixel.FlxG.keys.pressed.DOWN && y < MenuState.tileMap.get_height()-height-16) {
			this.velocity.y = speed;
			animation.play("run");
		}
		if(Math.abs(this.velocity.x) < 2 && Math.abs(this.velocity.y) < 2 )
		{
			animation.play("idle");
		}
	}
}
