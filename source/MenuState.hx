package;

import flixel.*;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.*;
import flixel.tile.*;
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
	public static var tileMap:FlxTilemap;
	private var collidabletileMap:FlxTilemap;
	public static var player:Player;
	public static var soldiers:FlxTypedGroup<Soldier>;


	private var zonetimer1:FlxTimer;
	private var zonetimer2:FlxTimer;
	private var zonetimer3:FlxTimer;

	public static var blockers1:FlxTypedGroup<flixel.FlxSprite>;
	public static var blockers2:FlxTypedGroup<flixel.FlxSprite>;
	

	public static var house1:House;
	public static var house2:House;
	public static var house3:House;

	private var zoneGroup1:FlxTypedGroup<Soldier>;
	private var zoneGroup2:FlxTypedGroup<Soldier>;
	private var zoneGroup3:FlxTypedGroup<Soldier>;
	
	public static var zoneUnlocked1:Bool = true;
	public static var zoneUnlocked2:Bool = false;
	public static var zoneUnlocked3:Bool = false;
	
	override public function create():Void
	{
		super.create();
		FlxG.state.bgColor = 0xffffffff;
		//FlxG.state.add(new FlxText( 100,100, 300,"hello ld 32", 20));
		//flixel.FlxG.debugger.drawDebug = true;
		tileMap = new FlxTilemap();
		tileMap.loadMap(Assets.getText("assets/data/map.csv"), "assets/images/tileset2.png", 32, 32,0, 1);
		FlxG.state.add(tileMap);
		randomizeMap();
		flixel.FlxG.worldBounds.set(0,0,tileMap.width , tileMap.height);
		player = new Player(50,50);
		FlxG.camera.follow(player, FlxCamera.STYLE_TOPDOWN, 1);
		flixel.FlxG.camera.bounds = new flixel.util.FlxRect(0,0,tileMap.width,tileMap.height);
		
		soldiers = new flixel.group.FlxTypedGroup<Soldier>();
	
		for (i in 0 ... 0)//enemies test 
		{
			var soldier :Soldier = new Soldier(100,100,1);
			soldier.initialPoint = new flixel.util.FlxPoint(soldier.x,soldier.y);	
			//var soldier :Soldier = new Soldier(400+Math.random()*100,400+Math.random()*100);
			soldier.color = 0xFFFF0000;
			soldiers.add(soldier);
		}
		soldiers.add(house1 = new House(50*32-64,15*32-32, 0xff033330, 10, 1));
		soldiers.add(house2 = new House(100*32-64,15*32-32, 0xff00ff00, 30,2));
		soldiers.add(house3 = new House(150*32-64,15*32-32, 0xff00ff00, 60,3));
		

		for (i in 0 ... 0)//followers test
		{
			var soldier :Soldier = new Soldier(Math.random()*tileMap.width,Math.random()*tileMap.height,1);	
			player.followers.add(soldier);
			soldier.color = 0xFF00FF00;
			soldier.isEnemy = false;
		}

		zonetimer1 = new flixel.util.FlxTimer();
		//zonetimer1.start(3 ,spawnEnemiesZone1,Std.int(Math.POSITIVE_INFINITY));	

		//zone 1 
		zoneGroup1 = new FlxTypedGroup<Soldier>();
		for (i in 0 ... 20) {
			var s:Soldier = new Soldier(0,0,Math.floor(Math.random()*2));
			zoneGroup1.add(s);
			add(s);
			s.kill();
		}
	}
	public function spawnEnemiesZone1(t:FlxTimer):Void 
	{
		var p :FlxPoint = getRandomPoint(1);
		while (!inbounds(p))p = getRandomPoint(1);
		var s  = zoneGroup1.getFirstDead();
		if(s!= null)
		{		
			s.initialPoint = p;
			s.revive();
			trace(p);
			s.reset(p.x,p.y);
		}
		MenuState.soldiers.add(s);
	}
	public function inbounds(p:FlxPoint):Bool 
	{
		if(Math.abs(player.x - p.x)<660 && Math.abs(player.y - p.y)<500)
			return false;
		return true;
	}
	public function getRandomPoint(zone:Int):FlxPoint 
	{
		return new flixel.util.FlxPoint(0+30 +Math.random()*(tileMap.width/3-60),30 +Math.random()*(tileMap.height/3-60));
	}
	
	public function	randomizeMap()
	{
		for (i in 0 ... 150) {
			for (j in 0 ... 30) {
				var t:Int = tileMap.getTile(i,j);
				var rand:Int = Math.floor(Math.random()*10);
				if(t == 29)
				{
					switch (rand)
					{
						case 0:tileMap.setTile(i,j,46);
						case 1:tileMap.setTile(i,j,47);
						case 2:tileMap.setTile(i,j,48);		
					}
				}
				if(t == 32)
				{
						switch (rand)
					{
						case 0:tileMap.setTile(i,j,49);
						case 1:tileMap.setTile(i,j,50);
						case 2:tileMap.setTile(i,j,51);		
					}	
				}
				if(t == 35)
				{
						switch (rand)
					{
						case 0:tileMap.setTile(i,j,52);
						case 1:tileMap.setTile(i,j,53);
						case 2:tileMap.setTile(i,j,54);		
					}	
				}
				
			}
		}
		blockers1 = new flixel.group.FlxTypedGroup<flixel.FlxSprite>();
		blockers2 = new flixel.group.FlxTypedGroup<flixel.FlxSprite>();
		var s:FlxSprite;
		for (i in 0 ... 30) {
			s = new flixel.FlxSprite(32*50,i*32,"assets/images/rock.png");
			s.immovable = true;
			blockers1.add(s);
			add(s);
			s = new flixel.FlxSprite(32*100,i*32,"assets/images/rock.png");
			s.immovable = true;
			blockers2.add(s);
			add(s);
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
		FlxG.collide(blockers1,player);
		FlxG.collide(blockers1,player.followers);
		FlxG.collide(blockers1,soldiers);


		FlxG.collide(blockers2,player);
		FlxG.collide(blockers2,player.followers);
		FlxG.collide(blockers2,soldiers);
		super.update();
	}
}