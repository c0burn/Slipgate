static enumflags { PLAT_LOW_TRIGGER };

/*==========
plat_hit_bottom
==========*/
static void() plat_hit_bottom =
{
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.state = STATE_BOTTOM;
};

/*==========
plat_go_down
==========*/
static void() plat_go_down =
{
	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	self.state = STATE_DOWN;
	SUB_CalcMove (self.pos2, self.speed, plat_hit_bottom);
};

/*==========
plat_hit_top
==========*/
static void() plat_hit_top =
{
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	self.state = STATE_TOP;
	self.think = plat_go_down;
	self.nextthink = self.ltime + self.wait;
};

/*==========
plat_go_up
==========*/
static void() plat_go_up =
{
	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	self.state = STATE_UP;
	SUB_CalcMove (self.pos1, self.speed, plat_hit_top);
};

/*==========
plat_use
==========*/
static void() plat_use =
{
	self.use = SUB_Null;
	plat_go_down();
};

/*==========
plat_crush

something has blocked the plat - 
cause some damage and reverse the plats movement
==========*/
static void() plat_crush =
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
static void() plat_trigger_touch =
{
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	if (self.owner.use == plat_use)		// plat has a targetname and is still waiting to be triggered
		return;

	self = self.owner;
	if (self.state == STATE_BOTTOM)
		plat_go_up();
	else if (self.state == STATE_TOP)
		self.nextthink = self.ltime + 1;	// delay going down if player is stood on the plat
};

/*==========
plat_spawn_trigger

spawn a trigger that activates the plat when touched
plats are never activated directly by touching the plat itself
==========*/
static void() plat_spawn_trigger =
{
	entity trigger = spawn();
	trigger.classname = "func_plat_trigger";
	trigger.owner = self;
	self.trigger_field = trigger;
	trigger.touch = plat_trigger_touch;
	trigger.movetype = MOVETYPE_NONE;
	trigger.solid = SOLID_TRIGGER;

	vector tmin, tmax;
	tmin = self.mins + [25, 25, self.lip];
	tmax = self.maxs - [25, 25, -self.lip];
	if (self.spawnflags & PLAT_LOW_TRIGGER)
		tmax_z = tmin_z + self.lip;

	if (self.size_x <= 50)
	{
		tmin_x = self.mins_x;
		tmax_x = self.maxs_x;
	}
	if (self.size_y <= 50)
	{
		tmin_y = self.mins_y;
		tmax_y = self.maxs_y;
	}
	setsize (trigger, tmin, tmax);
};

/*QUAKED func_plat (0 .5 .8) ? LOW_TRIGGER X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
A platform that moves vertically up and down.

Plats are always drawn in the map editor in the "up" position, so they will light correctly.
They are then moved to the down position on map load.

Plats spawn a trigger field that cause the plat to rise when a player touches it. By default
this trigger field spans the entire height of the plat. The plat will stay in the up position as
long as the player is touching the trigger and will fall again when they step off.

The plat will move a distance of its "height" minus any "lip".

If the plat has a "targetname", it will start disabled in the up position until
it is triggered, when it will lower and behave like a normal plat.

Spawnflags:
LOW_TRIGGER - the plat trigger field is spawned only at the bottom of the plat.

Keys:
"dmg" - damage to deal if blocked. default 1.
"speed"	- speed of movement. default 150.
"lip" - amount of height to leave at end of move. this should usually be
 the height of the component of your plat that a player can step upon. default 8.
"height" - override the movement distance, which by default
 is calculated from the height of the actual brush minus any lip.
 "wait" - time to wait at top before returning. default 3.
"sounds" -
-1) custom, see below
0) chain slow
1) base fast
2) chain slow (default)
3) base alternative
"noise" - sound to play at start of plat movement
"noise1" - sound to play at end of plat movement
*/
void() func_plat =
{
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	setmodel (self, self.model);

	// sounds
	// -1 custom, 1 = base, 2 = medieval (default), 3 = base alternative
	SetFloatDefault(sounds, 2);
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
	else if (self.sounds == 3)
	{
		self.noise = "plats/plat3.wav";
		self.noise1 = "plats/plat4.wav";
	}
	if (!self.noise || !self.noise1)
	{
		objerror("noise and noise1 must be set for custom sound\n");
		remove(self);
		return;
	}
	precache_sound(self.noise);
	precache_sound(self.noise1);

	// defaults
	SetPositiveDefault(dmg, 1);
	SetPositiveDefault(speed, 150);
	SetPositiveDefault(lip, 8);
	SetPositiveDefault(wait, 3);
	SetFloatDefault(height, self.size_z - self.lip);

	self.blocked = plat_crush;
	
	// pos1 is the top position, pos2 is the bottom
	self.pos1 = self.origin;
	self.pos2 = self.origin;
	self.pos2_z = self.pos2_z - self.height;
	plat_spawn_trigger();

	// if a plat has a targetname, the
	// plat must be triggered to lower it
	if (self.targetname != "")
	{
		self.use = plat_use;
		self.state = STATE_TOP;
		setorigin (self, self.pos1);
	}
	else
	{
		self.state = STATE_BOTTOM;
		setorigin (self, self.pos2);
	}
};
