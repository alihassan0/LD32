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
class IntroState extends FlxState
{
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	public static var tileMap:FlxTilemap;
	public static var player:Player;
	
	override public function create():Void
	{
		super.create();
		FlxG.state.bgColor = 0xffffffff;
		tileMap = new FlxTilemap();
		tileMap.loadMap(Assets.getText("assets/data/map.csv"), "assets/images/tileset2.png", 32, 32,0, 1);
		add(tileMap);
		//addTexts();
		addText(0, 0,"Brain Gun", 80, 0x00);
		addText(0, 80,"a game by ali hassan", 8, 0x00);
		addText(0, 95,"made for ludum dare 32", 8, 0x00);
		
		addText(0, 400,"press 'G' or 'H' to start", 16, 0x00);
		addText(0, 420,"controls :'G' persuades people .. 'H' switch between commands", 20, 0x00);
		
		flixel.FlxG.worldBounds.set(0,0,tileMap.width , tileMap.height);
		player = new Player(320,250);
		FlxG.camera.follow(player, FlxCamera.STYLE_TOPDOWN, 1);
		flixel.FlxG.camera.bounds = new flixel.util.FlxRect(0,0,tileMap.width,tileMap.height);
		//FlxG.state.add(tileMap);
		randomizeMap();	
		player.scale.set(8,8);
		player.alive = false;
	}
	public function addTexts():Void
	{

		addText(100, 100,"i'v always wanted \n to conqur the world", 20, 0x00);
		addText(450, 300,"but i never could because my body is so weak \n  i can't hold a sword or handle a bow :(", 15, 0x00);
		addText(450, 700,"but i won't let that stop me", 15, 0x00);
		addText(700, 500,"i am going to use this big Brain of mine", 30, 0x00);
		addText(1100, 500,"no one shall stand in my way ", 20, 0x00);
		addText(1500, 500,"with me Brain i can get anyone to OBEY ", 20, 0x00);
	}
	public function	addText(x:Int, y:Int, text:String,size:Int,color:Int)
	{
		var text:FlxText = new FlxText(x, y, 640, text).setFormat(null,size,color,"center");
		flixel.FlxG.state.add(text);

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
		var s:FlxSprite;
		
		for (i in 0 ... 30) {
			s = new flixel.FlxSprite(32*50,i*32,"assets/images/rock.png");
			s.immovable = true;
			add(s);
			s = new flixel.FlxSprite(32*100,i*32,"assets/images/rock.png");
			s.immovable = true;
			add(s);
		}
	}
	override public function update():Void
	{
		if(flixel.FlxG.keys.pressed.G || flixel.FlxG.keys.pressed.H)
		flixel.FlxG.switchState(new MenuState());
		super.update();
	}
}