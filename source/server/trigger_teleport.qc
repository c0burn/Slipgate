static enumflags { TELEPORT_PLAYER_ONLY, TELEPORT_SILENT };

/*==========
play_teleport
==========*/
static void() play_teleport =
{
	float r = randomrange(5);
	if (r == 0)
		sound (self, CHAN_VOICE, "misc/r_tele1.wav", 1, ATTN_NORM);
	else if (r == 1)
		sound (self, CHAN_VOICE, "misc/r_tele2.wav", 1, ATTN_NORM);
	else if (r == 2)
		sound (self, CHAN_VOICE, "misc/r_tele3.wav", 1, ATTN_NORM);
	else if (r == 3)
		sound (self, CHAN_VOICE, "misc/r_tele4.wav", 1, ATTN_NORM);
	else
		sound (self, CHAN_VOICE, "misc/r_tele5.wav", 1, ATTN_NORM);

	remove(self);
};

/*==========
spawn_tfog
==========*/
void(vector org) spawn_tfog =
{
	te_teleport(org);
	
	entity e = spawn();
	setorigin(e, org);
	e.think = play_teleport;
	e.nextthink = time + 0.2;	// delay sound slightly
};

/*==========
tdeath_touch
==========*/
static void() tdeath_touch =
{
	if (!other.takedamage)
		return;
	if (other == self.owner)	// the engine doesn't respect .owner for triggers!
		return;
	
	if (other.classname == "player")
	{
		// monsters can't telefrag players
		if (self.owner.flags & FL_MONSTER)
		{
			Damage (self.owner, self, self, 50000);
			return;
		}
		
		// check for pentagram on the player on the spot
		if (other.items & IT_INVULNERABILITY)
		{
			// check for pentagram on both players
			if (self.owner.items & IT_INVULNERABILITY)
			{
				// kill the player on the spot
				self.classname = "teledeath3";
				other.items = other.items - IT_INVULNERABILITY;
				other.invincible_time = other.invincible_finished = 0;
				Damage (other, self, self, 50000);
			}
			else
			{
				// kill the teleporting player
				self.classname = "teledeath2";
				Damage (self.owner, self, self, 50000);
			}
			return;
		}
	}
	Damage(other, self, self, 50000);
};

/*==========
spawn_tdeath
==========*/
void(vector org, entity who) spawn_tdeath =
{
	force_retouch = 2;	// make sure even still objects get hit
	
	entity e = spawn();
	e.classname = "teledeath";
	e.owner = who;
	e.movetype = MOVETYPE_NONE;
	e.solid = SOLID_TRIGGER;
	setsize (e, who.mins - '1 1 1', who.maxs + '1 1 1');
	setorigin (e, org);
	e.touch = tdeath_touch;
	e.think = SUB_Remove;
	e.nextthink = time + 0.2;
};

/*==========
teleport_touch
==========*/
static void() teleport_touch =
{
	if (self.spawnflags & TELEPORT_PLAYER_ONLY)
	{
		if (other.classname != "player")
			return;
	}
	if (other.health <= 0)
		return;
	if (other.solid != SOLID_SLIDEBOX)	// only players/monsters
		return;

	// look for the destination
	entity t = find (world, targetname, self.target);
	if (!t)
	{
		objerror ("couldn't find target");
		remove(self);
		return;
	}
	if (t.classname != "info_teleporter_destination")
	{
		dprint("warning: teleport destination is ");
		dprint(t.classname);
		dprint(" at ");
		dprint(vtos(t.origin));
		dprint("\n");
	}
	
	// fire targets
	activator = other;
	UseTargets();

	// spawn teleport flash at source and destination
	spawn_tfog (other.origin);
	makevectors (t.angles);
	vector org = t.origin + '0 0 27';
	spawn_tfog (org + v_forward * 32);
	spawn_tdeath(org, other);

	// move the player/monster
	setorigin (other, org);
	other.angles = t.angles;
	other.flags = other.flags - (other.flags & FL_ONGROUND);
	if (other.classname == "player")
	{
		other.fixangle = TRUE;				// turn this way immediately
		other.teleport_time = time + 0.7;	// don't let player move back into teleporter
		other.velocity = v_forward * 300;	// give a forwards push
	}
};

/*==========
teleport_use

using a teleporter makes it active. it then behaves like any other teleporter.
==========*/
static void() teleport_use =
{
	force_retouch = 2;	// make sure even still objects get hit
	self.touch = teleport_touch;
	self.use = SUB_Null;
};

/*QUAKED trigger_teleport (.5 .5 .5) ? PLAYER_ONLY SILENT X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
Variable sized trigger that teleports players and monsters to a destination marker.
"target" must be set to an info_teleport_destination with a matching "targetname" field.
If the trigger_teleport has a "targetname", it will only teleport entities once it has been triggered.
This is used in id1 for teleporting monsters - this has been obsoleted by the MONSTER_TELEPORT flag.

Spawnflags: 
PLAYER_ONLY - just players, not monsters
SILENT - don't spawn ambient teleporter noise
*/
void() trigger_teleport =
{
	if (!self.target)
	{
		objerror ("no target");
		remove(self);
		return;
	}
	if (self.targetname != "")
		self.use = teleport_use;
	else
		self.touch = teleport_touch;

	if (!(self.spawnflags & TELEPORT_SILENT))
		ambient_teleport();

	InitTrigger();
};
