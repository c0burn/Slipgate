/*==========
fireball_touch
==========*/
void() fireball_touch =
{
	if (other.classname == self.classname)
		return;
	T_Damage (other, self, self, self.dmg);
	remove(self);
};

/*==========
fireball_fly
==========*/
void() fireball_fly =
{
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
	
	self.think = fireball_fly;
	self.nextthink = time + self.wait + random()*self.wait;
};

/*QUAKED misc_fireball (1 .5 0) (-8 -8 -8) (8 8 8)
{	model ("progs/lavaball.mdl");	}
Flying lava balls

Keys:
speed - set vertical speed of fireballs. default 1000.
wait - delay between fireballs (with some randomness). default 3 seconds.
count - number of fireballs to launch. default 1.
dmg - damage dealt by fireballs. default 20.
*/
void() misc_fireball =
{
	precache_model ("progs/lavaball.mdl");
	precache_sound ("boss1/throw.wav");
	
	if (self.speed <= 0)
		self.speed = 1000;
	if (self.count <= 0)
		self.count = 1;
	if (self.wait <= 0)
		self.wait = 3;
	if (self.dmg <= 20)
		self.dmg = 20;
	
	//self.use = fireball_use;
	self.think = fireball_fly;
	self.nextthink = time + self.wait + random()*self.wait;
};

//============================================================================


/*==========
explobox_explode
==========*/
void() explobox_explode =
{
	self.classname = "explo_box";
	T_RadiusDamage (self, self, 160, world);

	self.origin_x = self.origin_x + self.maxs_x * 0.5;
	self.origin_y = self.origin_y + self.maxs_y * 0.5;
	self.origin_z = self.origin_z + self.maxs_z * 0.5;
	
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	BecomeExplosion();
};

/*==========
explobox_die
==========*/
void(entity inflictor, entity attacker) explobox_die =
{
	self.takedamage = DAMAGE_NO;
	self.think = explobox_explode;
	self.nextthink = time + 0.1;
};

/*==========
explobox_start
==========*/
void() explobox_start =
{
	self.solid = SOLID_BBOX;
	self.movetype = MOVETYPE_NONE;
	if (self.classname == "misc_explobox2")
	{
		precache_model2 ("maps/b_exbox2.bsp");
		setmodel (self, "maps/b_exbox2.bsp");
		setsize(self, '0 0 0', '32 32 32');
	}
	else
	{
		precache_model ("maps/b_explob.bsp");
		setmodel (self, "maps/b_explob.bsp");		
		setsize(self, '0 0 0', '32 32 64');
	}

	self.origin_z = self.origin_z + 2;
	if (!droptofloor())
	{
		dprint (self.classname);
		dprint (" fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);
	}
		
	self.health = 20;
	self.th_die = explobox_die;
	self.takedamage = DAMAGE_AIM;
};

/*QUAKED misc_explobox (1 .5 0) (0 0 0) (32 32 64)
{
	model("maps/b_explob.bsp");
}
Explosive box
*/
void() misc_explobox =
{	
	explobox_start();
};

/*QUAKED misc_explobox2 (1 .5 0) (0 0 0) (32 32 32)
{
	model("maps/b_exbox2.bsp");
}
Smaller explosive box
*/
void() misc_explobox2 =
{
	explobox_start();
};

//============================================================================

float SPAWNFLAG_SUPERSPIKE	= 1;
float SPAWNFLAG_LASER = 2;

void(vector org, vector vec) LaunchLaser;

void() spikeshooter_use =
{
	if (self.spawnflags & SPAWNFLAG_LASER)
	{
		sound (self, CHAN_VOICE, "enforcer/enfire.wav", 1, ATTN_NORM);
		LaunchLaser (self.origin, self.movedir);
	}
	else
	{
		sound (self, CHAN_VOICE, "weapons/spike2.wav", 1, ATTN_NORM);
		launch_spike (self.origin, self.movedir);
		newmis.velocity = self.movedir * 500;
		if (self.spawnflags & SPAWNFLAG_SUPERSPIKE)
			newmis.touch = superspike_touch;
	}
};

void() shooter_think =
{
	spikeshooter_use ();
	self.nextthink = time + self.wait;
	newmis.velocity = self.movedir * 500;
};


/*QUAKED trap_spikeshooter (1 .5 0) (-8 -8 -8) (8 8 8) superspike laser
When triggered, fires a spike in the direction set in QuakeEd.
Laser is only for REGISTERED.
*/
void() trap_spikeshooter =
{
	SetMovedir ();
	self.use = spikeshooter_use;
	if (self.spawnflags & SPAWNFLAG_LASER)
	{
		precache_model2 ("progs/laser.mdl");
		precache_sound2 ("enforcer/enfire.wav");
		precache_sound2 ("enforcer/enfstop.wav");
	}
	else
		precache_sound ("weapons/spike2.wav");
};

/*QUAKED trap_shooter (1 .5 0) (-8 -8 -8) (8 8 8) superspike laser
Continuously fires spikes.
"wait" time between spike (1.0 default)
"nextthink" delay before firing first spike, so multiple shooters can be stagered.
*/
void() trap_shooter =
{
	trap_spikeshooter ();
	
	if (self.wait == 0)
		self.wait = 1;
	self.nextthink = self.nextthink + self.wait + self.ltime;
	self.think = shooter_think;
};
