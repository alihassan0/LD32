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
	public var isEnemy:Bool = true;
	private var emitter:FlxEmitter;
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
	public function new(X:Float=0, Y:Float=0) 
	{
		super(X, Y);
		loadGraphic("assets/images/soldier.png", true, 32, 32);
		setFacingFlip(FlxObject.LEFT, false, false);
		setFacingFlip(FlxObject.RIGHT, true, false);
		animation.add("run", [0,2,0,3], 15, true);
		animation.add("idle", [0,1], 2, true);
		animation.add("shoot", [4,5], 2, true);
		animation.add("melee", [6,7], 2, true);
		animation.callback = animCallback;
		speed = 150;
		player = MenuState.player;
		FlxG.state.add(this);
		loyaltyBar = new flixel.ui.FlxBar(x + barOffset2.x, y+ barOffset2.y,FlxBar.FILL_LEFT_TO_RIGHT , 30, 3,this ,"loyalty",0,maxloyalty,false);	
		loyaltyBar.createFilledBar(0xFFFFC368,0xFFFDC303);
		FlxG.state.add(loyaltyBar);
		// Here we actually initialize out emitter
		// The parameters are X, Y and Size (Maximum number of particles the emitter can store)
		
		setUpEmitter();
		//	Tell the weapon to create 50 bullets using the bulletPNG image.
		//	The 5 value is the x offset, which makes the bullet fire from the tip of the players ship.
		bow = new FlxWeapon("bow",this);
		bow.makePixelBullet(50);
		bow.makeImageBullet(10,"assets/images/arrow.png");
		flixel.FlxG.state.add(bow.group);	
		//	Sets the direction and speed the bullets will be fired in
		bow.setBulletDirection(FlxWeapon.BULLET_UP, 200);
	}
	public function setUpEmitter():Void 
	{
		emitter = new FlxEmitter(x+5, y+height, 30);
		emitter.setSize(20,0);
		emitter.setXSpeed(0, 0);
		emitter.setYSpeed( -60,- 80);
		emitter.setRotation(0,0);
		emitter.lifespan = .5;
		emitter.endAlpha = new flixel.effects.particles.FlxTypedEmitter.Bounds(0.0,0.4);
		flixel.FlxG.state.add(emitter);

		for (i in 0...(Std.int(emitter.maxSize))) 
		{
			whitePixel = new FlxParticle();
			whitePixel.makeGraphic(2, 4, FlxColor.GREEN);
			whitePixel.visible = false; 
			emitter.add(whitePixel);
		}
	}
	override public function update():Void 
	{
		if(isEnemy)
		{
			target = MenuState.getNearestFriendTo(new flixel.util.FlxPoint(x,y),0,100);
			controlEnemyMovement();
		}
		else
		{
			follow();
		}
		manageBars();
		flixel.FlxG.collide(player,bow.group,hurtPerson);
		flixel.FlxG.collide(player.followers,bow.group,hurtPerson);
		super.update();
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
		if(target != null && target.alive)
		{
			if (s == "melee" && f == 1)
			{
				if(target!= null && target.alive)
				{
					target.hurt(5);
				}
				
			}
			if (s == "shoot" && f == 1)
			{
				if(target!= null && target.alive)
				{
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
			trace(animation.frameIndex);
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
				
				attack(new flixel.util.FlxPoint(target.x,target.y));
			}
		}
	}
	public function blindFollow(point:FlxPoint,animate:Bool):Void {
		var angle :Float = angleToPoint(point);
		if(distToPoint(point) > 10)
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
				animation.play("idle");
	}
	public function showParticle(amount:Int):Void
	{
		if(!emitter.on)
		{
			emitter.start(false,.7 ,.08 , amount);
			loyalty -= player.level*3;
			loyaltyBar.alpha = 1;
		}
	}

	public function manageBars():Void 
	{

		emitter.setPosition(x+5, y+height);
		if(loyalty< 0)
		turnToFollower();
		else if(loyalty < maxloyalty && !emitter.on)
		loyalty += .03;

		loyaltyBar.alpha -= .004;
		loyaltyBar.x = x + barOffset2.x;
		loyaltyBar.y = y + barOffset2.y;
	}
	override public function kill():Void 
	{
		loyaltyBar.kill();
		
		MenuState.soldiers.remove(this,true);

		
		super.kill();
	}

	public function turnToFollower():Void {
		MenuState.soldiers.remove(this,true);
		player.followers.add(this);
		isEnemy = false;
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
		/*if(bow.fire())
		bow.currentBullet.angle = angle;*/
		//
	}
}


