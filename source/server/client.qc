
// prototypes
void(entity attacker, float damage) player_pain;
void() player_stand;
void (vector org) spawn_tfog;
void (vector org, entity death_owner) spawn_tdeath;

float	modelindex_eyes, modelindex_player;

/*
=============================================================================

				LEVEL CHANGING / INTERMISSION

=============================================================================
*/


void() SetChangeParms =
{
	// player was dead during the intermission
	if (self.health <= 0)
	{
		SetNewParms();
		return;
	}

	// items
	// remove powerups and keys
	self.items = self.items - (self.items &
	(IT_SUPERHEALTH | IT_KEY1 | IT_KEY2 | IT_INVISIBILITY | IT_INVULNERABILITY | IT_SUIT | IT_QUAD));
	parm1 = self.items;

	// cap super health
	if (self.health > 100)
		self.health = 100;
	if (self.health < 50)
		self.health = 50;
	parm2 = self.health;

	// weapons and ammo
	parm3 = self.weapon;
	if (self.ammo_shells < 25)
		self.ammo_shells = 25;
	parm4 = self.ammo_shells;
	parm5 = self.ammo_nails;
	parm6 = self.ammo_rockets;
	parm7 = self.ammo_cells;

	// armor
	parm8 = self.armorvalue;
	parm9 = self.armortype;
};

void() SetNewParms =
{
	parm1 = IT_AXE | IT_SHOTGUN;	// items
	parm2 = 100;					// health
	parm3 = IT_SHOTGUN;				// weapon
	parm4 = 25;						// shells
	parm5 = 0;						// nails
	parm6 = 0;						// rockets
	parm7 = 0;						// cells
	parm8 = 0;						// armorvalue
	parm9 = 0;						// armortype
};

void() DecodeLevelParms =
{
	// take away all items on starting a new episode
	if ((!deathmatch) && (mapname == "start"))
		SetNewParms();

	self.items = parm1;
	self.health = parm2;
	self.weapon = parm3;
	self.ammo_shells = parm4;
	self.ammo_nails = parm5;
	self.ammo_rockets = parm6;
	self.ammo_cells = parm7;
	self.armorvalue = parm8;
	self.armortype = parm9;
};




/*
=============================================================================

				PLAYER GAME EDGE FUNCTIONS

=============================================================================
*/

// called by ClientKill and DeadThink
void() respawn =
{
	if (coop)
	{
		// make a copy of the dead body for appearances sake
		CopyToBodyQue (self);
		// get the spawn parms as they were at level start
		setspawnparms (self);
		// respawn
		PutClientInServer ();
	}
	else if (deathmatch)
	{
		// make a copy of the dead body for appearances sake
		CopyToBodyQue (self);
		// set default spawn parms
		SetNewParms ();
		// respawn
		PutClientInServer ();
	}
	else
	{	// restart the entire server
		localcmd ("restart\n");
	}
};


/*
============
ClientKill

Player entered the suicide command
============
*/
void() ClientKill =
{
	// don't allow suicide during the intermission
	// the engine aleady blocks it when dead
	if (intermission_running)
		return;

	/*
	bprint (self.netname);
	bprint (" suicides\n");
	*/

	self.frags = self.frags - 1;	// extra penalty
	self.health = 0;
	Killed(self, self, self);
};

/*
============
SelectSpawnPoint

Returns the entity to spawn at
============
*/
entity() SelectSpawnPoint =
{
	local	entity spot;
	local	entity thing;
	local	float  pcount;

	if (developer)
	{
		spot = find (world, classname, "info_player_test");
		if (spot)
			return spot;
	}

	if (coop)
	{
		lastspawn = find(lastspawn, classname, "info_player_coop");
		if (lastspawn == world)
			lastspawn = find (lastspawn, classname, "info_player_start");
		if (lastspawn != world)
			return lastspawn;
	}
	else if (deathmatch)
	{
		spot = lastspawn;
		while (1)
		{
			spot = find(spot, classname, "info_player_deathmatch");
			if (spot)
			{
				if (spot == lastspawn)
					return lastspawn;
				pcount = 0;
				thing = findradius(spot.origin, 32);
				while(thing)
				{
					if (thing.classname == "player")
						pcount = pcount + 1;
					thing = thing.chain;
				}
				if (pcount == 0)
				{
					lastspawn = spot;
					return spot;
				}
			}
			else
			{
				spot = find (world, classname, "info_player_start");
				if (!spot)
					error ("PutClientInServer: no info_player_start on level");
				return spot;
			}
		}
	}

	if (serverflags)
	{	// return with a rune to start
		spot = find (world, classname, "info_player_start2");
		if (spot)
			return spot;
	}

	spot = find (world, classname, "info_player_start");
	if (!spot)
		error ("PutClientInServer: no info_player_start on level");

	return spot;
};

/*
===========
PutClientInServer

called each time a player is spawned
============
*/
void() DecodeLevelParms;
void(entity inflictor, entity attacker) PlayerDie;

/*
void() PutClientInServer =
{
	self.classname = "player";
	self.health = 100;
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;

	entity spot = SelectSpawnPoint ();
	self.origin = self.oldorigin = spot.origin + '0 0 128';
	self.angles = [0, -90, 0];
	self.fixangle = TRUE;

	setmodel (self, "progs/s_null.spr");
	setsize (self, [0, 0, 0], [0, 0, 0]);
};
*/

void() PutClientInServer =
{
	self.classname = "player";
	self.health = self.max_health = 100;
	self.headmodel = "progs/h_player.mdl";
	self.deadflag = DEAD_NO;
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_WALK;
	self.flags = FL_CLIENT;
	self.th_pain = player_pain;
	self.th_die = PlayerDie;
	self.view_ofs = '0 0 22';

	// liquid stuff
	self.air_finished = time + 12;
	self.dmg = 2;

	// powerups
	self.effects = 0;
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.invisible_finished = 0;
	self.invincible_finished = 0;
	self.invincible_time = 0;

	// get items from parms and update weapon
	DecodeLevelParms();
	W_UpdateWeapon(self);
	self.show_hostile = 0;
	self.attack_finished = time;

	// put the player on the spawn spot
	entity spot = SelectSpawnPoint ();
	self.origin = self.oldorigin = spot.origin + '0 0 1';
	self.angles = spot.angles;
	self.fixangle = TRUE;
	self.pausetime = 0;
	self.velocity = '0 0 0';

	setmodel (self, "progs/eyes.mdl");
	modelindex_eyes = self.modelindex;
	setmodel (self, "progs/player.mdl");
	modelindex_player = self.modelindex;
	setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);

	player_stand();
	if (deathmatch || coop)
	{
		makevectors(self.angles);
		spawn_tfog (self.origin + v_forward*20);
	}
	spawn_tdeath (self.origin, self);
};


/*
===============================================================================

RULES

===============================================================================
*/

/*
go to the next level for deathmatch
only called if a time or frag limit has expired
*/
void() NextLevel =
{
	local entity o;

	if (mapname == "start")
	{
		if (!cvar("registered"))
		{
			mapname = "e1m1";
		}
		else if (!(serverflags & 1))
		{
			mapname = "e1m1";
			serverflags = serverflags | 1;
		}
		else if (!(serverflags & 2))
		{
			mapname = "e2m1";
			serverflags = serverflags | 2;
		}
		else if (!(serverflags & 4))
		{
			mapname = "e3m1";
			serverflags = serverflags | 4;
		}
		else if (!(serverflags & 8))
		{
			mapname = "e4m1";
			serverflags = serverflags - 7;
		}

		o = spawn();
		o.map = mapname;
	}
	else
	{
		// find a trigger changelevel
		o = find(world, classname, "trigger_changelevel");

		// go back to start if no trigger_changelevel
		if (!o)
		{
			mapname = "start";
			o = spawn();
			o.map = mapname;
		}
	}

	nextmap = o.map;
	gameover = TRUE;

	if (o.nextthink < time)
	{
		o.think = StartIntermission;
		o.nextthink = time + 0.1;
	}
};

/*
============
CheckRules

Exit deathmatch games upon conditions
============
*/
void() CheckRules =
{
	local	float		timelimit;
	local	float		fraglimit;

	if (gameover)	// someone else quit the game already
		return;

	timelimit = cvar("timelimit") * 60;
	fraglimit = cvar("fraglimit");

	if (timelimit && time >= timelimit)
	{
		NextLevel ();
		return;
	}

	if (fraglimit && self.frags >= fraglimit)
	{
		NextLevel ();
		return;
	}
};

//============================================================================

void() PlayerDeathThink =
{
	if (self.deadflag == DEAD_DYING)
		return;

	// come to a stop
	if (self.flags & FL_ONGROUND)
	{
		float forward = vlen(self.velocity);
		forward = forward - 20;
		if (forward <= 0)
			self.velocity = '0 0 0';
		else
			self.velocity = forward * normalize(self.velocity);
	}

	// wait for button down
	if (self.deadflag == DEAD_DEAD)
	{
		if (self.button0 || self.button2)
			self.deadflag = DEAD_RESPAWNABLE;
		return;
	}

	// wait for button release
	if (!self.button0 && !self.button2)
		respawn();
};


void() PlayerJump =
{
	if (self.flags & FL_WATERJUMP)
		return;

	if (self.waterlevel >= 2)
	{
		if (self.watertype == CONTENT_WATER)
			self.velocity_z = 100;
		else if (self.watertype == CONTENT_SLIME)
			self.velocity_z = 80;
		else
			self.velocity_z = 50;

// play swiming sound
		if (self.swim_flag < time)
		{
			self.swim_flag = time + 1;
			if (random() < 0.5)
				sound (self, CHAN_BODY, "misc/water1.wav", 1, ATTN_NORM);
			else
				sound (self, CHAN_BODY, "misc/water2.wav", 1, ATTN_NORM);
		}

		return;
	}

	if (!(self.flags & FL_ONGROUND))
		return;

	if ( !(self.flags & FL_JUMPRELEASED) )
		return;		// don't pogo stick

	self.flags = self.flags - (self.flags & FL_JUMPRELEASED);

	self.flags = self.flags - FL_ONGROUND;	// don't stairwalk

	self.button2 = 0;
// player jumping sound
	sound (self, CHAN_BODY, "player/plyrjmp8.wav", 1, ATTN_NORM);
	self.velocity_z = self.velocity_z + 270;
};


/*
===========
WaterMove

============
*/
.float	dmgtime;


void() CheckWaterJump =
{
	local vector start, end;

// check for a jump-out-of-water
	makevectors (self.angles);
	start = self.origin;
	start_z = start_z + 8;
	v_forward_z = 0;
	normalize(v_forward);
	end = start + v_forward*24;
	traceline (start, end, TRUE, self);
	if (trace_fraction < 1)
	{	// solid at waist
		start_z = start_z + self.maxs_z - 8;
		end = start + v_forward*24;
		self.movedir = trace_plane_normal * -50;
		traceline (start, end, TRUE, self);
		if (trace_fraction == 1)
		{	// open at eye level
			self.flags = self.flags | FL_WATERJUMP;
			self.velocity_z = 225;
			self.flags = self.flags - (self.flags & FL_JUMPRELEASED);
			self.teleport_time = time + 2;	// safety net
			return;
		}
	}
};

void() WaterMove =
{
	// don't drown if no clip...
	if (self.movetype == MOVETYPE_NOCLIP)
	{
		self.air_finished = time + 12;
		self.dmg = 2;
		return;
	}

	if (self.waterlevel == 2)
		CheckWaterJump ();

	if (self.waterlevel != 3)
	{
		if (self.air_finished < time)
			sound (self, CHAN_VOICE, "player/gasp2.wav", 1, ATTN_NORM);
		else if (self.air_finished < time + 9)
			sound (self, CHAN_VOICE, "player/gasp1.wav", 1, ATTN_NORM);
		self.air_finished = time + 12;
		self.dmg = 2;
	}
	else if (self.air_finished < time)
	{	// drown!
		if (self.pain_finished < time)
		{
			self.dmg = self.dmg + 2;
			if (self.dmg > 15)
				self.dmg = 10;
			Damage (self, world, world, self.dmg);
			self.pain_finished = time + 1;
		}
	}

	if (!self.waterlevel)
	{
		if (self.flags & FL_INWATER)
		{
			// play leave water sound
			sound (self, CHAN_BODY, "misc/outwater.wav", 1, ATTN_NORM);
			self.flags = self.flags - FL_INWATER;
		}
		return;
	}

	if (self.watertype == CONTENT_LAVA)
	{	// do damage
		if (self.dmgtime < time)
		{
			if (self.radsuit_finished > time)
				self.dmgtime = time + 1;
			else
				self.dmgtime = time + 0.2;

			Damage (self, world, world, 10*self.waterlevel);
		}
	}
	else if (self.watertype == CONTENT_SLIME)
	{	// do damage
		if (self.dmgtime < time && self.radsuit_finished < time)
		{
			self.dmgtime = time + 1;

			Damage (self, world, world, 4*self.waterlevel);
		}
	}

	if ( !(self.flags & FL_INWATER) )
	{

// player enter water sound

		if (self.watertype == CONTENT_LAVA)
			sound (self, CHAN_BODY, "player/inlava.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/inh2o.wav", 1, ATTN_NORM);
		if (self.watertype == CONTENT_SLIME)
			sound (self, CHAN_BODY, "player/slimbrn2.wav", 1, ATTN_NORM);

		self.flags = self.flags + FL_INWATER;
		self.dmgtime = 0;
	}

	if (! (self.flags & FL_WATERJUMP) )
		self.velocity = self.velocity - 0.8*self.waterlevel*frametime*self.velocity;
};

/*
================
PlayerPreThink

Called every frame before physics are run
================
*/
.float ladder_sound;
.float ladder_time;


void() PlayerPreThink =
{
	if (intermission_running)
	{
		IntermissionThink();
		return;
	}
	if (self.deadflag)
	{
		PlayerDeathThink();
		return;
	}
	WaypointPreFrame();

	CheckRules ();
	WaterMove ();

	if (self.flags2 & FL2_ONLADDER)
	{
		self.flags2 = self.flags2 - FL2_ONLADDER;
		// climb
		if (self.button2)
		{
			// don't pogo stick if we drop off
			self.flags = self.flags - self.flags & FL_JUMPRELEASED;

			self.velocity = '0 0 160';
			if (time > self.ladder_time)
			{
				self.ladder_time = time + 0.5;

				self.ladder_sound = self.ladder_sound + 1;
				if (self.ladder_sound > 4)
					self.ladder_sound = 0;

				if (self.ladder_sound == 0)
					sound(self, CHAN_BODY, "player/ladder1.wav", 1, ATTN_IDLE);
				if (self.ladder_sound == 1)
					sound(self, CHAN_BODY, "player/ladder2.wav", 1, ATTN_IDLE);
				if (self.ladder_sound == 2)
					sound(self, CHAN_BODY, "player/ladder3.wav", 1, ATTN_IDLE);
				if (self.ladder_sound == 3)
					sound(self, CHAN_BODY, "player/ladder4.wav", 1, ATTN_IDLE);
				if (self.ladder_sound == 4)
					sound(self, CHAN_BODY, "player/ladder5.wav", 1, ATTN_IDLE);

			}
		}
		else
		{
			self.flags = self.flags | FL_JUMPRELEASED;
			// restrict horizontal movement
			self.velocity = 0.9 * self.velocity;
			self.velocity_z = 0;
		}
	}
	else
	{
		self.gravity = 1;
		if (self.button2)
			PlayerJump ();
		else
			self.flags = self.flags | FL_JUMPRELEASED;
	}

	// teleporters can force a non-moving pause time
	if (time < self.pausetime)
		self.velocity = '0 0 0';

	// check weapon ammo
	if (time > self.attack_finished && !W_CheckNoAmmo(self))
	{
		self.weapon = W_BestWeapon(self);
		W_UpdateWeapon(self);
	}
};

/*
================
CheckPowerups

Check for turning off powerups
================
*/
void() CheckPowerups =
{
// megahelth
	if (self.items & IT_SUPERHEALTH)
	{
		if (self.health <= self.max_health)
		{
			self.items = self.items - IT_SUPERHEALTH;
		}
		else if (time > self.health_rot_time)
		{
			self.health = self.health - 1;
			self.health_rot_time = time + 1;
		}
	}

// invisibility
	if (self.invisible_finished)
	{
// sound and screen flash when items starts to run out
		if (self.invisible_sound < time)
		{
			sound (self, CHAN_AUTO, "items/inv3.wav", 0.5, ATTN_IDLE);
			self.invisible_sound = time + ((random() * 3) + 1);
		}


		if (self.invisible_finished < time + 3)
		{
			if (self.invisible_time == 1)
			{
				sprint (self, "Ring of Shadows magic is fading\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/inv2.wav", 1, ATTN_NORM);
				self.invisible_time = time + 1;
			}

			if (self.invisible_time < time)
			{
				self.invisible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.invisible_finished < time)
		{	// just stopped
			self.items = self.items - IT_INVISIBILITY;
			self.invisible_finished = 0;
			self.invisible_time = 0;
		}

	// use the eyes
		self.frame = 0;
		self.modelindex = modelindex_eyes;
	}
	else
		self.modelindex = modelindex_player;	// don't use eyes

// invincibility
	if (self.invincible_finished)
	{
// sound and screen flash when items starts to run out
		if (self.invincible_finished < time + 3)
		{
			if (self.invincible_time == 1)
			{
				sprint (self, "Protection is almost burned out\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/protect2.wav", 1, ATTN_NORM);
				self.invincible_time = time + 1;
			}

			if (self.invincible_time < time)
			{
				self.invincible_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.invincible_finished < time)
		{	// just stopped
			self.items = self.items - IT_INVULNERABILITY;
			self.invincible_time = 0;
			self.invincible_finished = 0;
		}
		if (self.invincible_finished > time)
			self.effects = self.effects | EF_DIMLIGHT;
		else
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);
	}

// super damage
	if (self.super_damage_finished)
	{

// sound and screen flash when items starts to run out

		if (self.super_damage_finished < time + 3)
		{
			if (self.super_time == 1)
			{
				sprint (self, "Quad Damage is wearing off\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/damage2.wav", 1, ATTN_NORM);
				self.super_time = time + 1;
			}

			if (self.super_time < time)
			{
				self.super_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.super_damage_finished < time)
		{	// just stopped
			self.items = self.items - IT_QUAD;
			self.super_damage_finished = 0;
			self.super_time = 0;
		}
		if (self.super_damage_finished > time)
			self.effects = self.effects | EF_DIMLIGHT;
		else
			self.effects = self.effects - (self.effects & EF_DIMLIGHT);
	}

// suit
	if (self.radsuit_finished)
	{
		self.air_finished = time + 12;		// don't drown

// sound and screen flash when items starts to run out
		if (self.radsuit_finished < time + 3)
		{
			if (self.rad_time == 1)
			{
				sprint (self, "Air supply in Biosuit expiring\n");
				stuffcmd (self, "bf\n");
				sound (self, CHAN_AUTO, "items/suit2.wav", 1, ATTN_NORM);
				self.rad_time = time + 1;
			}

			if (self.rad_time < time)
			{
				self.rad_time = time + 1;
				stuffcmd (self, "bf\n");
			}
		}

		if (self.radsuit_finished < time)
		{	// just stopped
			self.items = self.items - IT_SUIT;
			self.rad_time = 0;
			self.radsuit_finished = 0;
		}
	}

};


/*
================
PlayerPostThink

Called every frame after physics are run
================
*/

void() PlayerPostThink =
{
	if (intermission_running || self.deadflag)
		return;

	WaypointPostFrame();
	W_WeaponFrame ();

	if ((self.jump_flag < -300) && (self.flags & FL_ONGROUND) && (self.health > 0))
	{
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
		else if (self.jump_flag < -650)
		{
			Damage (self, world, world, 5);
			sound (self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
			self.deathtype = "falling";
		}
		else
			sound (self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);

		self.jump_flag = 0;
	}

	if (!(self.flags & FL_ONGROUND))
		self.jump_flag = self.velocity_z;

	
	CheckPowerups ();
};


/*
===========
ClientConnect

called when a player connects to a server
============
*/
void() ClientConnect =
{
	bprint (self.netname);
	bprint (" entered the game\n");

	// a client connecting during an intermission can cause problems
	if (intermission_running)
		ExitIntermission();
};

/*
===========
ClientDisconnect

called when a player disconnects from a server
============
*/
void() ClientDisconnect =
{
	// if the level end trigger has been activated, just return
	// since they aren't *really* leaving
	if (gameover)
		return;

	self.classname = string_null;
	self.health = 0;
	sound (self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);

	// let everyone else know
	bprint (self.netname);
	bprint (" left the game with ");
	bprint (ftos(self.frags));
	if (self.frags == 1)
		bprint (" frag\n");
	else
		bprint (" frags");

	// already gibbed?
	if (self.model == "progs/h_player.mdl")
		return;

	self.effects = 0;
	self.modelindex = modelindex_player;
	self.frame = 60; // $deatha11
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_TOSS;
	self.deadflag = DEAD_DEAD;
	self.think = SUB_Null;
	self.nextthink = -1;
};

