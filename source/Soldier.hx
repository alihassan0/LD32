package;
import flixel.*;
import flixel.util.*;
import flixel.effects.particles.*;
import flixel.ui.*;
import flixel.addons.weapon.FlxWeapon;
/**
 * ...
 * @author MrCdK
 */
class Soldier extends Person {
	
	private var player :Player;
	private var mode = 0;// 0 -> idle // 1-> run after
	public var type = 0;//0-> melee // 1-> shooter
	private var command = 0;//0-> melee // 1-> shooter
	public var emitter:FlxEmitter;
	private var whitePixel:FlxParticle;
	public var maxloyalty:Float = 10;
	public var loyalty:Float = 0;
	private var loyaltyBar:FlxBar;
	private var barOffset2:FlxPoint = new flixel.util.FlxPoint(0,-10);
	private var target:Person;
	private var swordRange:Int = 20;
	private var arrowsRange:Int = 60;
	private var arrowsSpeed:Int = 300;
	private var bow:FlxWeapon;
	public var initialPoint:FlxPoint;
	public var zone:Int = 0;
	public function new(X:Float=0, Y:Float=0 , ?type:Int = 0) 
	{
		super(X, Y);
		initialPoint = new flixel.util.FlxPoint(x,y);
		loadGraphic("assets/images/soldier2.png", true, 32, 32);
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		this.type = type;
		if(type == 0)
		{
			animation.add("run", [0,2,0,3], 15, true);
			animation.add("idle", [0,1], 2, true);
			animation.add("shoot", [4,5], 2, true);
			animation.add("melee", [6,7], 2, true);		
		}
		if(type == 1)
		{
			animation.add("run", [8,10,8,11], 15, true);
			animation.add("idle", [8,9], 2, true);
			animation.add("shoot", [12,13], 2, true);
			animation.add("melee", [14,15], 2, true);
		}
		animation.callback = animCallback;
		speed = 150;
		loyalty = maxloyalty;
		player = MenuState.player;
		loyaltyBar = new flixel.ui.FlxBar(x + barOffset2.x, y+ barOffset2.y,FlxBar.FILL_LEFT_TO_RIGHT , 30, 3,this ,"loyalty",0,maxloyalty,false);	
		loyaltyBar.createFilledBar(0xFF994C00,0xFFFDC303);

		FlxG.state.add(loyaltyBar);
		// Here we actually initialize out emitter
		// The parameters are X, Y and Size (Maximum number of particles the emitter can store)
		
		setUpEmitter();
		//	Tell the weapon to create 50 bullets using the bulletPNG image.
		//	The 5 value is the x offset, which makes the bullet fire from the tip of the players ship.
		bow = new FlxWeapon("bow",this);
		bow.bounds = new flixel.util.FlxRect(0,0,MenuState.tileMap.width,MenuState.tileMap.height );
		bow.makeImageBullet(10,"assets/images/arrow.png");
		bow.setFireRate(1);
		flixel.FlxG.state.add(bow.group);	
		//	Sets the direction and speed the bullets will be fired in
		bow.setBulletDirection(FlxWeapon.BULLET_UP, 200);
	}
	public function setUpEmitter():Void 
	{
		emitter = new FlxEmitter(x+5, y+height, 30);
		emitter.setSize(20,0);
		emitter.setXSpeed(0, 0);
		emitter.setYSpeed( -160,- 180);
		emitter.setRotation(0,0);
		emitter.lifespan = .05;
		emitter.endAlpha = new flixel.effects.particles.FlxTypedEmitter.Bounds(0.0,0.4);
		flixel.FlxG.state.add(emitter);

		for (i in 0...(Std.int(emitter.maxSize))) 
		{
			whitePixel = new FlxParticle();
			whitePixel.makeGraphic(4, 7, 0xFFFFAB00);
			whitePixel.visible = false; 
			emitter.add(whitePixel);
		}
	}
	override public function update():Void 
	{
		AiBrain();
		manageBars();
		if(isEnemy)
		{
			flixel.FlxG.collide(player,bow.group,hurtPerson);
			flixel.FlxG.collide(player.followers,bow.group,hurtPerson);
		}
		else
		{
			flixel.FlxG.collide(MenuState.soldiers,bow.group,hurtPerson);	
		}
		
		this.immovable = true;
		super.update();
	}
	public function AiBrain():Void 
	{
		if(isEnemy)
		{
			var tempPerson:Person = MenuState.getNearestFriendTo(new flixel.util.FlxPoint(x,y),0,100);
			if(tempPerson != null )
			{
				if(tempPerson != target)
				{
					shout("enemy found");
					signal();
				}
				target = tempPerson;
				controlEnemyMovement();
				
			}
			else
			{
				mode = 0;
				blindFollow(initialPoint,true);
				if(target != null)
				{
					if(shout("!!!!"))
					target= null;
				}
				animation.play("idle");
			}
		}
		else
		{
			follow();
		}
	}
	public function hurtPerson(p:Person,bullet:FlxSprite):Void
	{
		bullet.kill();
		p.hurt(10);
	}
	public function controlEnemyMovement():Void
	{
		var distance:Float = distToPoint(new FlxPoint(target.x,target.y));
		switch (mode) {
			case 0:
			animation.play("idle");
			blindFollow(initialPoint,true);
			if(distance<100){
			mode = 1 ;
			}
			case 1://follow target Mode
			animation.play("run");
			blindFollow(new flixel.util.FlxPoint(target.x,target.y),true);
			if(distance > 100){
			mode = 0;
			}
			if(type == 0 &&distance < swordRange){
			mode = 2;
			}	
			if(type == 1 &&distance < arrowsRange){
			mode = 2;
			}
			case 2: // attack
			if(type == 0)
			{
				animation.play("melee");
				if(distance > swordRange)
				{
					mode = 1;
				}
			}
			else if(type == 1)
			{
				animation.play("shoot");
				if(distance > arrowsRange)
				{
					mode = 1;
				}
			}
		}
	}
	public function animCallback(s:String, f:Int, i:Int):Void
	{
		if(target != null && target.alive && target.isEnemy != this.isEnemy)
		{
			if (s == "melee" && f == 1)
			{
				if(target!= null && target.alive)
				{
					target.hurt(5);
					FlxG.sound.play("assets/sounds/Hit.wav");
				}
			}
			if (s == "shoot" && f == 1)
			{
				if(target!= null && target.alive)
				{
					FlxG.sound.play("assets/sounds/arrow.wav");
					shoot();
				}
				
			}	
		}
		else
		{
			mode = 0;
		}
	}
	private function distToPoint(point:FlxPoint):Float
	{
		return Math.sqrt(Math.pow(point.x-x,2)+Math.pow(point.y -y,2));
	}
	private function angleToPoint(point:FlxPoint):Float{
		return Math.atan2(point.y-y,point.x -x);
	}

	public function attack(point:FlxPoint):Void {
		blindFollow(point,false);
		var distance:Float = distToPoint(point);
		if(distance < swordRange){
		animation.play("melee",false);
		}
	}
	public function hunt(point:FlxPoint):Void {
		blindFollow(point,false,arrowsRange);
		var distance:Float = distToPoint(point);
		if(distance < arrowsRange){
		animation.play("shoot",false);
		}
	}
	public function follow():Void {
		if(player.command == 0)//defense
		{
			followLeader();
		}
		else if (player.command == 1)
		{
			target = MenuState.getNearestTo(new flixel.util.FlxPoint(x,y),0,100);
			
			if(target != null)
			{	
				if(type ==0)
				attack(new flixel.util.FlxPoint(target.x,target.y));
				else
				hunt(new flixel.util.FlxPoint(target.x,target.y));
			}
			else
			{
				followLeader();
			}
		}
	}
	public function blindFollow(point:FlxPoint,animate:Bool,?arrowsRange=10):Void {
		var angle :Float = angleToPoint(point);
		if(distToPoint(point) > arrowsRange)
		{
			x += speed/60 * Math.cos(angle);
			y += speed/60 * Math.sin(angle);

			if(speed/60 * Math.cos(angle)<0)
			facing = flixel.FlxObject.RIGHT;
			else
			facing = flixel.FlxObject.LEFT;

			if(animate)
			animation.play("run");
		}
		else
			if(animate)
			{
				animation.play("idle");
				mode = 0;
			}
	}
	public function showParticle(amount:Int):Void
	{
		if(!emitter.on)
		{
			emitter.start(false,.7 ,.025 , amount);
			loyalty -= player.level*4;
			loyaltyBar.alpha = 1;
		}
	}

	public function manageBars():Void 
	{

		emitter.setPosition(x+5, y+height);
		if(loyalty< 0)
		{
			turnToFollower();
			loyalty = maxloyalty + 1;
		}
		else if(loyalty < maxloyalty && !emitter.on)
		loyalty += .01;

		loyaltyBar.alpha -= .004;
		loyaltyBar.x = x + barOffset2.x;
		loyaltyBar.y = y + barOffset2.y;
	}
	override public function kill():Void 
	{
		loyaltyBar.kill();
		
		MenuState.soldiers.remove(this,true);
		player.followers.remove(this);
		if(isEnemy)
		informHouse(zone);
		super.kill();
	}
	override public function revive():Void 
	{
		loyaltyBar.revive();
		loyalty = maxloyalty;
		MenuState.soldiers.remove(this,true);
	
		super.kill();
	}
	public function turnToFollower():Void {
		MenuState.soldiers.remove(this,true);
		player.followers.add(this);
		speed = player.speed*.8;
		isEnemy = false;
		informHouse(zone);
		color = 0xFF00FF00;
	}
	public function informHouse(i:Int):Void 
	{
		switch (i) {
			case 1: MenuState.house1.count --;
			case 2: MenuState.house2.count --;
			case 3: MenuState.house3.count --;
		}
	}
	public function followLeader():Void 
	{
	var angle:Float = (360/player.followers.length) * Math.PI/180;
	var radius:Float = 50.0;
	var i :Int = player.followers.members.indexOf(this);
	blindFollow(new flixel.util.FlxPoint(player.x + Math.cos(i*angle)*radius , player.y +Math.sin(i*angle)*radius),true);
	}
	public function shoot():Void {
		var angle:Int = cast angleToPoint(new flixel.util.FlxPoint(target.x,target.y))*180/Math.PI;
		bow.setBulletDirection(angle,arrowsSpeed);
		bow.setBulletOffset(width/2,height/2);
		if(distToPoint(new flixel.util.FlxPoint(target.x+target.width/2,target.y+target.height/2))<30)
		{
			shout("enemy is too close");
		}
		else if(bow.fire())
		{
			bow.currentBullet.angle = angle;
		}
		else
			trace("y");
		//
	}
}


