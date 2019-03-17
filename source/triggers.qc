/*==========
InitTrigger
==========*/
void() InitTrigger =
{
	if (self.angles)
		SetMovedir();

	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model);	// link into world
	// make invisible
	self.modelindex = 0;
	self.model = "";
};

float SPAWNFLAG_NOMESSAGE	= 1;
float SPAWNFLAG_NOTOUCH		= 1;

/*==========
trigger_wait
==========*/
void() trigger_wait =
{
	if (self.max_health)
	{
		self.health = self.max_health;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
		setorigin(self, self.origin);	// link into world
	}
};

/*==========
trigger_fire
==========*/
void() trigger_fire =
{
	// already triggered
	if (self.nextthink > time)
		return;

	if (self.classname == "trigger_secret")
	{
		if (self.enemy.classname != "player")
			return;
		// bump secret counter
		found_secrets = found_secrets + 1;
		WriteByte (MSG_ALL, SVC_FOUNDSECRET);
	}

	if (self.noise != "")
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

	self.takedamage = DAMAGE_NO;

	activator = self.enemy;
	UseTargets();

	if (self.wait > 0)
	{
		self.think = trigger_wait;
		self.nextthink = time + self.wait;
	}
	else	// trigger_once
	{
		self.touch = SUB_Null;
		self.think = SUB_Remove;
		self.nextthink = time;
	}
};

/*==========
trigger_killed
==========*/
void(entity inflictor, entity attacker) trigger_killed =
{
	self.enemy = attacker;
	trigger_fire();
};

/*==========
trigger_use
==========*/
void() trigger_use =
{
	self.enemy = activator;
	trigger_fire();
};

/*==========
trigger_touch
==========*/
void() trigger_touch =
{
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	// check player is facing the right way
	if (self.movedir)
	{
		makevectors (other.angles);
		if (v_forward * self.movedir < 0)
			return;
	}
	
	self.enemy = other;
	trigger_fire();
};

/*QUAKED trigger_multiple (.5 .5 .5) ? NOTOUCH
Variable sized repeatable trigger.

Keys:
"target" - entities to trigger upon firing
"killtarget" - entities to remove upon firing
"message" - will be printed to player upon activation
"delay" - will wait after activation before firing
"health" - if set, trigger must be killed to activate
"wait" - time between triggers. default 0.2
"sounds" -
0) none
1) secret
2) beep beep
3) large switch
"angle" - player must be facing this direction to activate the trigger.
0 is assumed to mean no restriction, so use 360 for an angle of 0.

Spawnflags:
If NOTOUCH is set, the trigger is only fired by other entities, not by touching.
NOTOUCH has been obsoleted by trigger_relay.
*/
void() trigger_multiple =
{
	if (self.sounds == 1)
	{
		precache_sound ("misc/secret.wav");
		self.noise = "misc/secret.wav";
	}
	else if (self.sounds == 2)
	{
		precache_sound ("misc/talk.wav");
		self.noise = "misc/talk.wav";
	}
	else if (self.sounds == 3)
	{
		precache_sound ("misc/trigger1.wav");
		self.noise = "misc/trigger1.wav";
	}
	
	if (!self.wait)
		self.wait = 0.2;

	self.use = trigger_use;
	InitTrigger();

	if (self.health > 0)
	{
		if (self.spawnflags & SPAWNFLAG_NOTOUCH)
		{
			objerror ("health and NOTOUCH doesn't make sense\n");
			remove(self);
			return;
		}
		self.max_health = self.health;
		self.th_die = trigger_killed;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
		setorigin (self, self.origin);	// make sure it links into the world
	}
	else if (!(self.spawnflags & SPAWNFLAG_NOTOUCH))
	{
		self.touch = trigger_touch;
	}
};

/*QUAKED trigger_once (.5 .5 .5) ? NOTOUCH
Variable sized trigger. Triggers once, then removes itself.

Keys:
"target" - entities to trigger upon firing
"killtarget" - entities to remove upon firing
"message" - will be printed to player upon activation
"delay" - will wait after activation before firing
"health" - if set, trigger must be killed to activate
"wait" - time between triggers. default 0.2
"sounds" -
0) none
1) secret
2) beep beep
3) large switch
"angle" - player must be facing this direction to activate the trigger.
0 is assumed to mean no restriction, so use 360 for an angle of 0.

Spawnflags:
If NOTOUCH is set, the trigger is only fired by other entities, not by touching.
NOTOUCH has been obsoleted by trigger_relay.
*/
void() trigger_once =
{
	self.wait = -1;
	trigger_multiple();
};

/*QUAKED trigger_relay (.5 .5 .5) (-8 -8 -8) (8 8 8)
This fixed size trigger cannot be touched, it can only be fired by other events.
It can contain killtargets, targets, delays, and messages.
*/
void() trigger_relay =
{
	self.use = UseTargets;
};

/*QUAKED trigger_secret (.5 .5 .5) ?
Variable sized secret counter trigger. Triggers once, then removes itself.

Keys:
"target" - entities to trigger upon firing
"killtarget" - entities to remove upon firing
"message" - will be printed to player upon activation. default "You found a secret area!"
"delay" - will wait after activation before firing
"health" - if set, trigger must be killed to activate
"sounds" -
1) secret (default if not set)
2) beep beep
3) large switch
"angle" - player must be facing this direction to activate the trigger.
0 is assumed to mean no restriction, so use 360 for an angle of 0.

Spawnflags:
If NOTOUCH is set, the trigger is only fired by other entities, not by touching.
NOTOUCH has been obsoleted by trigger_relay.
*/
void() trigger_secret =
{
	total_secrets = total_secrets + 1;
	self.wait = -1;
	if (!self.message)
		self.message = "You found a secret area!";
	if (self.sounds <= 0)
		self.sounds = 1;

	trigger_multiple();
};

/*==========
counter_use
==========*/
void() counter_use =
{
	self.count = self.count - 1;
	
	// more to go
	if (self.count > 0)
	{
		if (activator.classname == "player")
		{
			if (!(self.spawnflags & SPAWNFLAG_NOMESSAGE))
			{
				if (self.count > 3)
					centerprint (activator, "There are more to go...");
				else if (self.count == 3)
					centerprint (activator, "Only 3 more to go...");
				else if (self.count == 2)
					centerprint (activator, "Only 2 more to go...");
				else
					centerprint (activator, "Only 1 more to go...");
			}
		}
		return;
	}
	
	self.use = SUB_Null;	// don't allow further triggering
	
	if (activator.classname == "player")
		if (!(self.spawnflags & SPAWNFLAG_NOMESSAGE))
			centerprint(activator, "Sequence completed!");
	
	self.enemy = activator;
	trigger_fire();
};

/*QUAKED trigger_counter (.5 .5 .5) ? NOMESSAGE
Acts as an intermediary for an action that takes multiple inputs.
If NOMESSAGE is not set, it will print "Only 2 more to go.." etc when triggered and "Sequence completed!" when finished.
After the counter has been triggered "count" times (default 2), it will fire all of it's targets and remove itself.
*/
void() trigger_counter =
{
	self.wait = -1;
	if (self.count <= 0)
		self.count = 2;
	self.use = counter_use;
};





float	TELEPORT_PLAYER_ONLY	= 1;
float	TELEPORT_SILENT			= 2;

void() play_teleport =
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

	remove (self);
};

void(vector org) spawn_tfog =
{
	entity e = spawn();
	setorigin(e, org);
	e.nextthink = time + 0.2;
	e.think = play_teleport;

	te_teleport(org);
};

void() tdeath_touch =
{
	if (other == self.owner)	// the engine doesn't respect .owner for triggers
		return;
		
	if (other.classname == "player")
	{
		// monsters can't telefrag players
		if (self.owner.classname != "player")
		{
			Damage (self.owner, self, self, 50000);
			return;
		}
		
		// check for pentagram
		if (other.items & IT_INVULNERABILITY)
		{
			// check for double pentagram
			if (self.owner.items & IT_INVULNERABILITY)
			{
				// kill the player on the spot
				self.classname = "teledeath3";
				other.items = other.items - IT_INVULNERABILITY;
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

void(vector org, entity death_owner) spawn_tdeath =
{
	entity death = spawn();
	death.classname = "teledeath";
	death.owner = death_owner;
	death.movetype = MOVETYPE_NONE;
	death.solid = SOLID_TRIGGER;
	setsize (death, death_owner.mins - '1 1 1', death_owner.maxs + '1 1 1');
	setorigin (death, org);
	death.touch = tdeath_touch;
	death.think = SUB_Remove;
	death.nextthink = time + 0.2;
	force_retouch = 2;	// make sure even still objects get hit
};

/*==========
teleport_touch
==========*/
void() teleport_touch =
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

	// look for destination
	entity t = find (world, targetname, self.target);
	if (!t)
	{
		objerror ("couldn't find target");
		self.touch = SUB_Null;
		self.think = SUB_Remove;
		self.nextthink = time;
	}
	
	// fire targets
	activator = other;
	UseTargets();

	// spawn teleport flash at source and destination
	spawn_tfog (other.origin);
	makevectors (t.mangle);
	vector org = t.origin + v_forward * 32;
	spawn_tfog (org);
	spawn_tdeath(t.origin, other);

	// move the player/monster
	setorigin (other, t.origin);
	other.angles = t.mangle;
	other.flags = other.flags - (other.flags & FL_ONGROUND);
	// if a player, lock him down for a little while
	if (other.classname == "player")
	{
		other.fixangle = TRUE;				// turn this way immediately
		other.teleport_time = time + 0.7;	// don't let player move back into teleport
		other.velocity = v_forward * 300;	// give a forwards push
	}
};

/*==========
teleport_use
==========*/
void() teleport_use =
{
	self.use = SUB_Null;
	self.touch = teleport_touch;

	force_retouch = 2;	// make sure even still objects get hit
};

/*QUAKED trigger_teleport (.5 .5 .5) ? PLAYER_ONLY SILENT
Variable sized trigger that teleports players and monsters to a destination marker.
"target" must be set to an info_teleport_destination with a matching "targetname" field.
If the trigger_teleport has a "targetname", it will only teleport entities once it has been triggered.
This is used in id1 for teleporting monsters - this has been obsoleted by the MONSTER_TELEPORT flag.
*/
void() trigger_teleport =
{
	if (!self.target)
	{
		objerror ("no target");
		remove(self);
		return;
	}

	InitTrigger();
	
	if (self.targetname != "")
	{
		dprint("trigger_teleport with a targetname\n");
		self.use = teleport_use;
	}
	else
		self.touch = teleport_touch;

	if (!(self.spawnflags & TELEPORT_SILENT))
		ambient_teleport();
};

/*
==============================================================================

trigger_setskill

==============================================================================
*/

static void() skill_touch =
{
	if (other.classname != "player")
		return;
		
	cvar_set ("skill", self.message);
};

/*QUAKED trigger_setskill (.5 .5 .5) ?
sets skill level to the value of "message"
*/
static void() trigger_setskill =
{
	InitTrigger ();
	self.touch = skill_touch;
};


/*
==============================================================================

ONLY REGISTERED TRIGGERS

==============================================================================
*/

void() trigger_onlyregistered_touch =
{
	if (other.classname != "player")
		return;
	if (self.attack_finished > time)
		return;

	self.attack_finished = time + 2;
	if (cvar("registered"))
	{
		self.message = "";
		activator = other;
		UseTargets ();
		remove (self);
	}
	else
	{
		if (self.message != "")
		{
			centerprint (other, self.message);
			sound (other, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
		}
	}
};

/*QUAKED trigger_onlyregistered (.5 .5 .5) ?
Only fires if playing the registered version, otherwise prints the message
*/
void() trigger_onlyregistered =
{
	precache_sound ("misc/talk.wav");
	InitTrigger ();
	self.touch = trigger_onlyregistered_touch;
};

//============================================================================

void() hurt_on =
{
	self.solid = SOLID_TRIGGER;
	self.nextthink = -1;
};

void() hurt_touch =
{
	if (other.takedamage)
	{
		self.solid = SOLID_NOT;
		Damage (other, self, self, self.dmg);
		self.think = hurt_on;
		self.nextthink = time + 1;
	}

	return;
};

/*QUAKED trigger_hurt (.5 .5 .5) ?
Any object touching this will be hurt
set dmg to damage amount
defalt dmg = 5
*/
void() trigger_hurt =
{
	InitTrigger ();
	self.touch = hurt_touch;
	if (self.dmg <= 0)
		self.dmg = 5;
};

//============================================================================

float PUSH_ONCE = 1;

void() trigger_push_touch =
{
	if (other.classname == "grenade")
		other.velocity = self.speed * self.movedir * 10;
	else if (other.health > 0)
	{
		other.velocity = self.speed * self.movedir * 10;
		if (other.classname == "player")
		{
			if (other.fly_sound < time)
			{
				other.fly_sound = time + 1.5;
				sound (other, CHAN_AUTO, "ambience/windfly.wav", 1, ATTN_NORM);
			}
		}
	}
	if (self.spawnflags & PUSH_ONCE)
		remove(self);
};


/*QUAKED trigger_push (.5 .5 .5) ? PUSH_ONCE
Pushes the player
*/
void() trigger_push =
{
	InitTrigger ();
	precache_sound ("ambience/windfly.wav");
	self.touch = trigger_push_touch;
	if (!self.speed)
		self.speed = 1000;
};

//============================================================================

void() trigger_monsterjump_touch =
{
	if ( other.flags & (FL_MONSTER | FL_FLY | FL_SWIM) != FL_MONSTER )
		return;

// set XY even if not on ground, so the jump will clear lips
	other.velocity_x = self.movedir_x * self.speed;
	other.velocity_y = self.movedir_y * self.speed;
	
	if ( !(other.flags & FL_ONGROUND) )
		return;
	
	other.flags = other.flags - FL_ONGROUND;

	other.velocity_z = self.height;
};

/*QUAKED trigger_monsterjump (.5 .5 .5) ?
Walking monsters that touch this will jump in the direction of the trigger's angle
"speed" default to 200, the speed thrown forward
"height" default to 200, the speed thrown upwards
*/
void() trigger_monsterjump =
{
	if (!self.speed)
		self.speed = 200;
	if (!self.height)
		self.height = 200;
	if (self.angles == '0 0 0')
		self.angles = '0 360 0';
	InitTrigger ();
	self.touch = trigger_monsterjump_touch;
};

/*==========
ladder_touch
==========*/
static void() ladder_touch =
{
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	
	// check player is facing the right way
	if (self.movedir)
	{
		makevectors (other.angles);
		if (v_forward * self.movedir < 0)
			return;
	}
	other.flags = other.flags | FL_ONLADDER;
	other.gravity = SMALL_FLOAT;	// because 0 = normal gravity
};

/*QUAKED trigger_ladder (.5 .5 .5) ?
Invisible ladder trigger.
When the player is touching this trigger, he can climb by holding jump.
If "angle" is set, the player must face that direction to climb the ladder.
An angle of 0 is assumed to mean no direction, so use an angle of 360 instead.
*/
static void() trigger_ladder =
{
	InitTrigger();
	self.touch = ladder_touch;
};
