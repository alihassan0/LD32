package;
import flixel.*;
import flixel.util.*;
import flixel.group.FlxTypedGroup;
/**
 * ...
 * @author MrCdK
 */
class Player extends Person {
	public var followers:FlxTypedGroup<Soldier>;
	public var command:Int = 0;	
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		loadGraphic("assets/images/player.png", true, 32, 32);
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		animation.add("run", [0,2,0,3], 15, true);
		animation.add("idle", [0,1], 2, true);
		width = 8;
		height = 14;
		offset.x = 4;
		offset.y = 2;
		drag.x = drag.y = 1600;
		followers = new FlxTypedGroup<Soldier>();
	}
	override public function update():Void 
	{
		super.update();

		if(FlxG.keys.justPressed.G )
		{
			persudeOthers();
		}
		if(FlxG.keys.justPressed.H )
		{
			if(command == 0)command = 1; else command = 0;
			trace(command);
		}
		controlMovementAndAnimation();	
	}


	public function persudeOthers():Void {
		var person:Person = MenuState.getNearestTo(new flixel.util.FlxPoint(x,y),0,100);
			if(person != null)
			{
				var soldier:Soldier = cast person;
				soldier.showParticle(20);
			}
	}
	public function controlMovementAndAnimation():Void {
		if(flixel.FlxG.keys.pressed.RIGHT){
			facing = FlxObject.LEFT;
			this.velocity.x = speed;
			animation.play("run");
		}

		if (flixel.FlxG.keys.pressed.LEFT) {
			facing = FlxObject.RIGHT;
			this.velocity.x = -speed;
			animation.play("run");
		}

		if(flixel.FlxG.keys.pressed.UP){
			this.velocity.y = -speed;
			animation.play("run");
		}

		if (flixel.FlxG.keys.pressed.DOWN) {
			this.velocity.y = speed;
			animation.play("run");
		}
		if(Math.abs(this.velocity.x) < 2 && Math.abs(this.velocity.y) < 2 )
		{
			animation.play("idle");
		}
	}
}
