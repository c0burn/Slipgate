enumflags { PLAT_LOW_TRIGGER };

/*==========
plat_hit_bottom
==========*/
void() plat_hit_bottom =
{
	self.state = STATE_BOTTOM;
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
};

/*==========
plat_go_down
==========*/
void() plat_go_down =
{
	self.state = STATE_DOWN;
	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	
	SUB_CalcMove (self.pos2, self.speed, plat_hit_bottom);
};

/*==========
plat_hit_top
==========*/
void() plat_hit_top =
{
	self.state = STATE_TOP;
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	
	self.think = plat_go_down;
	self.nextthink = self.ltime + 3;
};

/*==========
plat_go_up
==========*/
void() plat_go_up =
{
	self.state = STATE_UP;
	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	
	SUB_CalcMove (self.pos1, self.speed, plat_hit_top);
};

/*==========
plat_use
==========*/
void() plat_use =
{
	self.use = SUB_Null;
	plat_go_down();
};

/*==========
plat_crush

something has blocked the plat
cause damage and reverse the plats movement
==========*/
void() plat_crush =
{
	Damage(other, self, self, self.dmg);
	
	if (self.state == STATE_UP)
		plat_go_down ();
	else if (self.state == STATE_DOWN)
		plat_go_up ();
};

/*==========
plat_trigger_touch

when the trigger field is touched, the plat moves to the "up" position
==========*/
void() plat_trigger_touch =
{
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	self = self.owner;
	if (self.state == STATE_BOTTOM)
		plat_go_up();
	else if (self.state == STATE_TOP)
		self.nextthink = self.ltime + 1;	// delay going down
};

/*==========
plat_spawn_trigger

spawn a trigger that activates the plat when touched
plats are never activated directly by touching the plat itself
==========*/
void() plat_spawn_trigger =
{
	entity trigger = spawn();
	trigger.owner = self;
	trigger.touch = plat_trigger_touch;
	trigger.movetype = MOVETYPE_NONE;
	trigger.solid = SOLID_TRIGGER;
	
	vector tmin, tmax;
	tmin = self.mins + '25 25 0';
	tmax = self.maxs - '25 25 0';
	tmax_z = tmax_z + self.lip;
	tmin_z = tmax_z - (self.pos1_z - self.pos2_z + self.lip);
	
	if (self.spawnflags & PLAT_LOW_TRIGGER)
		tmax_z = tmin_z + self.lip;
	
	if (self.size_x <= 50)
	{
		tmin_x = (self.mins_x + self.maxs_x) / 2;
		tmax_x = tmin_x + 1;
	}
	if (self.size_y <= 50)
	{
		tmin_y = (self.mins_y + self.maxs_y) / 2;
		tmax_y = tmin_y + 1;
	}
	setsize (trigger, tmin, tmax);
};

/*QUAKED func_plat (0 .5 .8) ? PLAT_LOW_TRIGGER
A platform that moves vertically up and down.

Plats are always drawn in the editor in the "up" position, so they will light correctly.
They are moved to the "down" position on map load.
If the plat has a "targetname", it will start out disabled
in the "up" position until it is triggered, when it will lower and become a normal plat.

Keys:
"dmg" - damage to deal if blocked. default 1.
"speed"	- speed of movement. default 150.
"height" - override the movement distance, which by default
 is calculated from the height of the brush + 8
"lip" - amount of brush height to leave at end of move. default 8
"sounds" -
1) base fast
2) chain slow (default)
3) custom, see below
"noise" - sound to play at start of plat movement
"noise1" - sound to play at end of plat movement
*/
void() func_plat =
{
	if (self.sounds <= 0)
		self.sounds = 2;
	if (self.sounds == 1)
	{
		self.noise = "plats/plat1.wav";
		self.noise1 = "plats/plat2.wav";
	}
	else if (self.sounds == 2)
	{
		self.noise = "plats/medplat1.wav";
		self.noise1 = "plats/medplat2.wav";
	}
	else
	{
		if (!self.noise || !self.noise1)
		{
			objerror("noise and noise1 must be set if custom sounds are specified\n");
			remove(self);
			return;
		}
	}
	precache_sound(self.noise);
	precache_sound(self.noise1);

	if (self.dmg <= 0)
		self.dmg = 1;
	if (self.speed <= 0)
		self.speed = 150;
	if (self.lip <= 0)
		self.lip = 16;
		
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setmodel (self, self.model);
	
	self.use = plat_use;
	self.blocked = plat_crush;
	
	// pos1 is the top position, pos2 is the bottom
	self.pos1 = self.origin;
	self.pos2 = self.origin;
	if (self.height)
		self.pos2_z = self.origin_z - self.height;
	else
		self.pos2_z = self.origin_z - self.size_z + self.lip;

	plat_spawn_trigger();
	
	// plat must be triggered to lower it
	if (self.targetname != "")
	{
		self.state = STATE_UP;
		setorigin (self, self.pos1);
	}
	else
	{
		self.state = STATE_BOTTOM;
		setorigin (self, self.pos2);
	}
};
