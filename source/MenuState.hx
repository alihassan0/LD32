package;

import flixel.*;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.*;
import flixel.tile.FlxTilemap;
import openfl.Assets;
import flixel.group.FlxTypedGroup;
/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	private var tileMap:FlxTilemap;
	public static var player:Player;
	public static var soldiers:FlxTypedGroup<Soldier>;
	override public function create():Void
	{
		super.create();
		FlxG.state.bgColor = 0xffffffff;
		//FlxG.state.add(new FlxText( 100,100, 300,"hello ld 32", 20));
		
		tileMap = new FlxTilemap();
		tileMap.loadMap(Assets.getText("assets/data/testmap.csv"), "assets/images/tileset.png", 32, 32,0, 1);
		FlxG.state.add(tileMap);

		player = new Player(50,50);
		FlxG.camera.follow(player, FlxCamera.STYLE_TOPDOWN, 1);
		flixel.FlxG.camera.bounds = new flixel.util.FlxRect(0,0,tileMap.width,tileMap.height);
		
		soldiers = new flixel.group.FlxTypedGroup<Soldier>();
	
		for (i in 0 ... 3) {
		var soldier :Soldier = new Soldier(Math.random()*tileMap.width,Math.random()*tileMap.height,Math.floor(Math.random()*2));	
		//var soldier :Soldier = new Soldier(400+Math.random()*100,400+Math.random()*100);
		
		soldier.color = 0xFFFF0000;
		soldiers.add(soldier);
		
		}
		
		for (i in 0 ... 0) {
		var soldier :Soldier = new Soldier(Math.random()*tileMap.width,Math.random()*tileMap.height);	
		player.followers.add(soldier);
		soldier.color = 0xFF00FF00;
		soldier.isEnemy = false;
		}
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	public static function getNearestTo(p:FlxPoint, type:Int, range:Int):Person {
		var minDist:Float = range;
		var minIndex:Int = -1;
		for (i in 0 ... soldiers.length) {
			if(soldiers.members[i]!= null)
			{
				var dist:Float = Math.sqrt(Math.pow(soldiers.members[i].x-p.x,2)+Math.pow(soldiers.members[i].y -p.y,2));
				if(dist > 0 && dist < minDist)
				{
					minDist = dist;
					minIndex = i;
				}	
			}
		}
		if(minIndex == -1)
		return null;
		else
		return soldiers.members[minIndex];
	}
	public static function getNearestFriendTo(p:FlxPoint, type:Int, range:Int):Person {
		var minDist:Float = Math.sqrt(Math.pow(player.x-p.x,2)+Math.pow(player.y -p.y,2));
		var minIndex:Int = -1;
		for (i in 0 ... player.followers.length) {
			if(player.followers.members[i]!= null && player.followers.members[i].alive)
			{
				var dist:Float = Math.sqrt(Math.pow(player.followers.members[i].x-p.x,2)+Math.pow(player.followers.members[i].y -p.y,2));
				if(dist > 0 && dist < minDist)
				{
					minDist = dist;
					minIndex = i;
				}	
			}
		}
		if(minIndex == -1 )
		{
			if( minDist < range)
			return player;
			else
			return null;
		}
		else
		{
			return player.followers.members[minIndex];
		}
	}
	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
	}	
}