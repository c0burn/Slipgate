/*========================================
breakable.qc
========================================*/

enumflags { EXPLODE, NO_EXPLOSION_SPRITE, NO_EXPLOSION_SOUND, SPAWN_SMOKE };

/*==========
breakable_pain
==========*/
void(entity attacker, float damage) breakable_pain =
{
	// play impact sound if set
	if (self.noise2 != "")
		sound(self, CHAN_VOICE, self.noise2, 1, ATTN_NORM);
};

/*==========
breakable_think
==========*/
void() breakable_think =
{
	// hack to drop to ground if something below us was removed
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
		
	// fade out when self.attack_finished is up
	if (time > self.attack_finished)
	{
		if (self.alpha == 0)
			self.alpha = 1;

		self.alpha = self.alpha - 0.1;
		if (self.alpha <= 0)
		{
			remove(self);
			return;
		}
	}
		
	self.think = breakable_think;
	self.nextthink = time + 0.1;
};

/*==========
breakable_touch
==========*/
void() breakable_touch =
{
	if (other != world)
		return;
	if (self.count)
		return;
	if (random() < 0.5)
		return;
	self.count = 1;
	if (self.noise2 != "")
		sound(self, CHAN_VOICE, self.noise2, 0.5, ATTN_IDLE);
};

/*==========
breakable_smoke
==========*/
void(vector org) breakable_smoke =
{
	entity smoke = spawn();
	smoke.classname = "smoke";
	smoke.solid = SOLID_NOT;
	smoke.movetype = MOVETYPE_TOSS;
	setmodel(smoke, "progs/smoke.mdl");
	setorigin(smoke, org);
	setsize(smoke, '0 0 0', '0 0 0');
	
	smoke.velocity = [crandom()*200, crandom()*200, random()*100 + 100];
	smoke.think = SUB_Remove;
	smoke.nextthink = time + 1;
};

/*==========
breakable_spawn_debris
==========*/
void(vector org, vector sz, vector dir) breakable_spawn_debris =
{
	entity debris = spawn();
	debris.classname = "debris";
	debris.solid = SOLID_TRIGGER;
	debris.movetype = MOVETYPE_BOUNCE;
	
	setorigin(debris, [org.x + random() * sz.x, org.y + random() * sz.y, org.z + random() * sz.z]);
	
	float r = random();
	if (r < 0.33)
		setmodel(debris, self.mdl1);
	else if (r < 0.66)
		setmodel(debris, self.mdl2);
	else
		setmodel(debris, self.mdl3);

	// spawn some smoke particles
	if (self.spawnflags & SPAWN_SMOKE)
		if (random() < 0.5)
			breakable_smoke(debris.origin);
			
	debris.angles_y = random() * 360;
	debris.velocity = dir * (50 + random() * 50);
	debris.velocity_z = 50 + random() * 50;
	if (self.health < -40)
		debris.velocity = debris.velocity * 2;
	debris.avelocity = randomvec() * 100;
	
	debris.noise2 = self.noise2;
	debris.touch = breakable_touch;
	
	debris.think = breakable_think;
	debris.nextthink = time + 0.1;
	debris.attack_finished = time + 10 + random() * 10;
};

/*==========
breakable_explode
==========*/
void() breakable_explode =
{
	// fix bmodel origin
	vector org = 0.5 * (self.absmin + self.absmax);
	setorigin(self, org);

	if (self.dmg > 0)
		T_RadiusDamage (self, self, self.dmg, world);

	if (self.spawnflags & NO_EXPLOSION_SOUND)
	{
		// vanilla hack to get explosion particles with no sound/light
		particle (org, '0 0 0', 0, 255);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_EXPLOSION);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}

	if (self.spawnflags & NO_EXPLOSION_SPRITE)
		remove(self);
	else
		BecomeExplosion ();
};

/*==========
breakable_break
==========*/
void(entity inflictor) breakable_break =
{
	self.takedamage = DAMAGE_NO;
	self.use = SUB_Null;
	
	// play sound, if set
	if (self.noise1 != "")
		sound(self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);

	// turn shadow off, supported by ericw-tools
	if (self.switchshadstyle >= 32)
		lightstyle(self.switchshadstyle, "m");
	
	// the debris moves away from the direction of attack
	// if movedir is set, this always overrides the direction
	while (self.count > 0)
	{
		vector dir;
		if (self.movedir)
			dir = self.movedir;
		else
		{
			if (inflictor == world)
				dir = randomvec();
			else
				dir = normalize((self.absmin + self.absmax) * 0.5 - inflictor.origin);
		}
		breakable_spawn_debris(self.absmin, self.size, dir);
		self.count = self.count - 1;
	}

	if (self.spawnflags & EXPLODE)
		self.think = breakable_explode;
	else
		self.think = SUB_Remove;
	self.nextthink = self.ltime + 0.01;		// use ltime because it's MOVETYPE_PUSH

	// fire targets	
	activator = self.enemy;
	SUB_UseTargets();
};

/*==========
breakable_die
==========*/
void(entity inflictor, entity attacker) breakable_die =
{	
	self.enemy = attacker;
	breakable_break(inflictor);
};

/*==========
breakable_use
==========*/
void() breakable_use =
{
	self.enemy = activator;
	breakable_break(world);
};

/*QUAKED func_breakable (0 .5 .8) ? EXPLODE NO_EXPLOSION_SPRITE NO_EXPLOSION_SOUND SPAWN_SMOKE X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
Breakable brush model

Spawnflags:

EXPLODDE - will explode upon destruction. Set the dmg key to the force of the explosion.
You can set dmg to 0 for just the explosion effects.
NO_EXPLOSION_SPRITE - don't show explosion sprite.
NO_EXPLOSION_SOUND - don't make explosion sound or light.
SPAWN_SMOKE - will spawn some additional smoke upon destuction

Keys:

"style" "n"
Preset style, 1=base crates, 2=stone/brick
Sets debris model, particle color and sounds automatically
If mdl1-3, noise or colour are set they will override the preset

"mdl1", "mdl2", "mdl3" "name"
custom models for debris chunks

"color" "n"
particle color for damage, range 0-254 (from palette)

"noise1", "noise2" "name"
custom sound for break / damage

"health" "n"
damage required to destroy. default 30.

"targetname" "name"
if set, the breakable must be triggered to destroy it

"count" "n"
number of pieces of debris to spawn. default 8.

"angle" "n"
If set, overrides the direction debris moves in. Range 0-360 for yaw, or -1 and -2 for up/down. Use 360 for a yaw of 0.

"dmg" "n"
Amount of explosive damage to deal. Default 60.
*/
void() func_breakable =
{
	// turn shadow on, supported by ericw-tools
	if (self.switchshadstyle >= 32)
		lightstyle(self.switchshadstyle, "a");

	// pre-set styles
	// 1 - base crate
	if (self.style == 1)
	{
		if (!self.mdl1)
			self.mdl1 = "maps/crate1.bsp";
		if (!self.mdl2)
			self.mdl2 = "maps/crate2.bsp";
		if (!self.mdl3)
			self.mdl3 = "maps/crate3.bsp";
		if (!self.noise1)
			self.noise1 = "break/metbrk.wav";
		if (!self.noise2)
			self.noise2 = "break/methit.wav";
		if (!self.colour)
			self.colour = 24;
	}
	// 2 - stone/brick
	else if (self.style == 2)
	{
		if (!self.mdl1)
			self.mdl1 = "maps/brick1.bsp";
		if (!self.mdl2)
			self.mdl2 = "maps/brick2.bsp";
		if (!self.mdl3)
			self.mdl3 = "maps/brick3.bsp";
		if (!self.noise1)
			self.noise1 = "break/stonebrk.wav";
		if (!self.noise2)
			self.noise2 = "break/stonehit.wav";
		if (!self.colour)
			self.colour = 16;
	}
	
	if (!self.mdl1 || !self.mdl2 || !self.mdl3)
	{
		objerror("mdl1, mdl2 or mdl3 not set\n");
		remove(self);
		return;
	}
	precache_model(self.mdl1);
	precache_model(self.mdl2);
	precache_model(self.mdl3);
	
	// destruction and impact noises - optional
	if (self.noise1 != "")
		precache_sound(self.noise1);
	if (self.noise2 != "")
		precache_sound(self.noise2);
	
	if (self.count <= 0)
		self.count = 8;
	if (self.dmg <= 0)
		self.dmg = 60;
	if (self.angles)
		SetMovedir();
	
	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel (self, self.model);

	// shootable, not triggered
	if (!self.targetname)
	{
		if (self.health <= 0)
			self.health = 30;
		self.takedamage = DAMAGE_YES;
		self.th_pain = breakable_pain;
		self.th_die = breakable_die;
	}
	else
		self.use = breakable_use;
};
