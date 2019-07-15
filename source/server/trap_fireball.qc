static enumflags { LAVABALL_SOUNDS };

/*==========
fireball_touch
==========*/
static void() fireball_touch =
{
	if (other.classname == self.classname)
		return;
	
	Damage (other, self, self, self.dmg);
	remove(self);
};

/*==========
fireball_launch
==========*/
static void() fireball_launch =
{	
	if (self.spawnflags & LAVABALL_SOUNDS)
		sound (self, CHAN_VOICE, "boss1/throw.wav", 1, ATTN_NORM);

	for (float i = 0; i < self.count; i++)	
	{
		entity fireball = spawn();
		fireball.classname = "fireball";
		fireball.solid = SOLID_TRIGGER;
		fireball.movetype = MOVETYPE_TOSS;
		setmodel (fireball, "progs/lavaball.mdl");
		setsize (fireball, '0 0 0', '0 0 0');
		setorigin (fireball, self.origin);
		
		fireball.velocity_x = crandom() * 50;
		fireball.velocity_y = crandom() * 50;
		fireball.velocity_z = self.speed + (random() * 200);
		fireball.avelocity = [100, 100, 100];

		fireball.touch = fireball_touch;
		fireball.think = SUB_Remove;
		fireball.nextthink = time + 5;
	}
};

/*==========
fireball_fly
==========*/
static void() fireball_fly =
{
	fireball_launch();
	self.think = fireball_fly;
	self.nextthink = time + self.wait + random()*self.wait;
};

/*QUAKED misc_fireball (1 .5 0) (-8 -8 -8) (8 8 8) SOUNDS X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{	model ("progs/lavaball.mdl");	}
Flying lava balls

Keys:
speed - set the vertical speed of fireballs. default 1000.
wait - delay between fireballs (with some randomness). default 3 seconds.
count - number of fireballs to launch. default 1.
dmg - damage dealt by fireballs. default 20.
targetname - if set, must be triggered to activate.

Spawnflags:
SOUNDS - if set, fireballs will make a whooshing sound when launched.
*/
void() misc_fireball =
{
	precache_model ("progs/lavaball.mdl");
	if (self.spawnflags & LAVABALL_SOUNDS)
		precache_sound ("boss1/throw.wav");
	
	SetPositiveDefault(speed, 1000);
	SetPositiveDefault(count, 1);
	SetPositiveDefault(wait, 3);
	SetPositiveDefault(dmg, 20);
	
	// triggered only
	if (self.targetname != "")
		self.use = fireball_launch;
	else
	{
		self.think = fireball_fly;
		self.nextthink = time + self.wait + random()*self.wait;
	}
};
