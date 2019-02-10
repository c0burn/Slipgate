/*==========
W_RankForWeapon

used by W_DeathmatchWeapon, returns a rank for a weapon
==========*/
float(entity player, float w) W_RankForWeapon =
{
	if (w == IT_LIGHTNING && player.ammo_cells)
		return 1;
	if (w == IT_ROCKET_LAUNCHER && player.ammo_rockets)
		return 2;
	if (w == IT_SUPER_NAILGUN && player.ammo_nails > 1)
		return 3;
	if (w == IT_GRENADE_LAUNCHER && player.ammo_rockets)
		return 4;
	if (w == IT_SUPER_SHOTGUN && player.ammo_shells > 1)
		return 5;
	if (w == IT_NAILGUN && player.ammo_nails) 
		return 6;
	if (w == IT_SHOTGUN && player.ammo_shells)
		return 7;
	return 8;
};

/*==========
W_DeathmatchWeapon

compares two weapons and returns the best one
only used in deathmatch
==========*/
float(entity player, float old, float new) W_DeathmatchWeapon =
{
	float or = W_RankForWeapon(player, old);
	float nr = W_RankForWeapon(player, new);
	if (nr < or)
		return new;
	else
		return old;
};

/*==========
W_BoundAmmo

caps player ammo at the max allowed
==========*/
void(entity player) W_BoundAmmo =
{
	if (player.ammo_shells > 100)
		player.ammo_shells = 100;
	if (player.ammo_nails > 200)
		player.ammo_nails = 200;
	if (player.ammo_rockets > 100)
		player.ammo_rockets = 100;		
	if (player.ammo_cells > 100)
		player.ammo_cells = 100;		
};

/*==========
W_BestWeapon

returns the players best weapon
to avoid self damage:
does not switch to GL or RL
does not switch to Thunderbolt if underwater
==========*/
float(entity player) W_BestWeapon =
{
	if ((player.waterlevel < 2) && (player.ammo_cells > 0) && (player.items & IT_LIGHTNING))
		return IT_LIGHTNING;
	if ((player.ammo_nails > 1) && (player.items & IT_SUPER_NAILGUN))
		return IT_SUPER_NAILGUN;
	if ((player.ammo_shells > 1) && (player.items & IT_SUPER_SHOTGUN))
		return IT_SUPER_SHOTGUN;
	if ((player.ammo_nails > 1) && (player.items & IT_NAILGUN))
		return IT_NAILGUN;
	if ((player.ammo_shells > 0) && (player.items & IT_SHOTGUN))
		return IT_SHOTGUN;
	return IT_AXE;
};

/*==========
W_SetCurrentAmmo

update the sbar with the correct ammo icon
updates .currentammo
==========*/
void(entity player) W_SetCurrentAmmo =
{	
	player.currentammo = 0;
	player.items = player.items - (player.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS));
	if (player.weapon == IT_SHOTGUN || player.weapon == IT_SUPER_SHOTGUN)
	{
		player.currentammo = player.ammo_shells;
		player.items = player.items | IT_SHELLS;
	}
	else if (player.weapon == IT_NAILGUN || player.weapon == IT_SUPER_NAILGUN)
	{
		player.currentammo = player.ammo_nails;
		player.items = player.items | IT_NAILS;
	}
	else if (player.weapon == IT_GRENADE_LAUNCHER || player.weapon == IT_ROCKET_LAUNCHER)
	{
		player.currentammo = player.ammo_rockets;
		player.items = player.items | IT_ROCKETS;
	}
	else if (player.weapon == IT_LIGHTNING)
	{
		player.currentammo = player.ammo_cells;
		player.items = player.items | IT_CELLS;
	}
};

/*==========
W_UpdateWeapon

updates the weapon view model
==========*/
void() player_stand;

void(entity player) W_UpdateWeapon =
{
	if (player.weapon == IT_AXE)
		player.weaponmodel = "progs/v_axe.mdl";
	else if (player.weapon == IT_SHOTGUN)
		player.weaponmodel = "progs/v_shot.mdl";
	else if (player.weapon == IT_SUPER_SHOTGUN)
		player.weaponmodel = "progs/v_shot2.mdl";	
	else if (player.weapon == IT_NAILGUN)
		player.weaponmodel = "progs/v_nail.mdl";
	else if (player.weapon == IT_SUPER_NAILGUN)
		player.weaponmodel = "progs/v_nail2.mdl";
	else if (player.weapon == IT_GRENADE_LAUNCHER)
		player.weaponmodel = "progs/v_rock.mdl";
	else if (player.weapon == IT_ROCKET_LAUNCHER)
		player.weaponmodel = "progs/v_rock2.mdl";
	else if (player.weapon == IT_LIGHTNING)
		player.weaponmodel = "progs/v_light.mdl";
	else
		player.weaponmodel = "";
	W_SetCurrentAmmo(player);
	
	entity oself = self;
	self = player;
	player_stand();
	self = oself;
};

/*==========
W_CheckNoAmmo

returns TRUE if the player has enough ammo for their current gun
==========*/
float(entity player) W_CheckNoAmmo =
{
	if (!player.weapon)
		return TRUE;
	if (player.weapon == IT_AXE)
		return TRUE;
	if (player.weapon == IT_SUPER_SHOTGUN || player.weapon == IT_SUPER_NAILGUN)
	{
		if (player.currentammo > 1)
			return TRUE;
		else
			return FALSE;
	}
	if (player.currentammo > 0)
		return TRUE;
	return FALSE;
};

/*==========
W_FireAxe
==========*/
void() W_FireAxe =
{
	makevectors (self.v_angle);
	vector source = self.origin + '0 0 16';
	traceline (source, source + v_forward*64, FALSE, self);
	if (trace_fraction == 1.0)
		return;
	
	vector org = trace_endpos - v_forward * 4;
	if (trace_ent.takedamage)
	{
		trace_ent.axhitme = 1;
		if (trace_ent.classname == "func_breakable")
			particle(org, '0 0 0', trace_ent.colour, 20);
		else
			SpawnBlood (org, '0 0 0', 20);
		T_Damage (trace_ent, self, self, 20);
	}
	else
	{
		sound (self, CHAN_WEAPON, "player/axhit2.wav", 1, ATTN_NORM);
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
};

entity	multi_ent;
float	multi_damage;

void() ClearMultiDamage =
{
	multi_ent = world;
	multi_damage = 0;
};

void() ApplyMultiDamage =
{
	if (!multi_ent)
		return;
	T_Damage (multi_ent, self, self, multi_damage);
};

void(entity hit, float damage) AddMultiDamage =
{
	if (!hit)
		return;
	
	if (hit != multi_ent)
	{
		ApplyMultiDamage ();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;
};

void(float damage, vector dir) TraceAttack =
{
	local	vector	vel, org;
	
	vel = normalize(dir + v_up*crandom() + v_right*crandom());
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;

	org = trace_endpos - dir*4;

	if (trace_ent.takedamage)
	{
		if (trace_ent.classname == "func_breakable")
			particle(org, vel*0.02, trace_ent.colour, damage);
		else
			SpawnBlood (org, vel*0.2, damage);
			
		AddMultiDamage (trace_ent, damage);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
};

void(float shotcount, vector dir, vector spread) FireBullets =
{
	local	vector direction;
	local	vector	src;
	
	makevectors(self.v_angle);

	src = self.origin + v_forward*10;
	src_z = self.absmin_z + self.size_z * 0.7;

	ClearMultiDamage ();
	while (shotcount > 0)
	{
		direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;

		traceline (src, src + direction*2048, FALSE, self);
		if (trace_fraction != 1.0)
			TraceAttack (4, direction);

		shotcount = shotcount - 1;
	}
	ApplyMultiDamage ();
};

void() W_FireShotgun =
{
	local vector dir;

	sound (self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);	

	self.punchangle_x = -2;
	
	self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	dir = aim (self, 100000);
	FireBullets (6, dir, '0.04 0.04 0');
};

void() W_FireSuperShotgun =
{
	local vector dir;
		
	sound (self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);	

	self.punchangle_x = -4;
	
	self.currentammo = self.ammo_shells = self.ammo_shells - 2;
	dir = aim (self, 100000);
	FireBullets (14, dir, '0.14 0.08 0');
};

void()	s_explode1	=	[0,		s_explode2] {};
void()	s_explode2	=	[1,		s_explode3] {};
void()	s_explode3	=	[2,		s_explode4] {};
void()	s_explode4	=	[3,		s_explode5] {};
void()	s_explode5	=	[4,		s_explode6] {};
void()	s_explode6	=	[5,		SUB_Remove] {};

void() BecomeExplosion =
{
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/s_explod.spr");
	s_explode1();
};

void() T_MissileTouch =
{
	local float	damg;

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	damg = 100 + random()*20;
	
	if (other.health)
	{
		if (other.classname == "monster_shambler")
			damg = damg * 0.5;	// mostly immune
		T_Damage (other, self, self.owner, damg );
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	T_RadiusDamage (self, self.owner, 120, other);

//	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};

void() W_FireRocket =
{
	local	entity missile;
	
	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	
	sound (self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_FLYMISSILE;
	missile.solid = SOLID_BBOX;
	missile.classname = "missile";
		
// set missile speed	

	makevectors (self.v_angle);
	//missile.velocity = aim(self, 1000);
	missile.velocity = v_forward * 1000;
	missile.angles = vectoangles(missile.velocity);
	missile.avelocity = [0, 0, 300];
	
	missile.touch = T_MissileTouch;
	
// set missile duration
	missile.nextthink = time + 5;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/missile.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin + v_forward * 12 + self.view_ofs - v_up * 12);
};

void(vector p1, vector p2, entity from, float damage) LightningDamage =
{
	traceline (p1, p2, FALSE, self);
	if (trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
	}
};

void() W_FireLightning =
{
	if (self.ammo_cells < 1)
	{
		self.weapon = W_BestWeapon(self);
		W_UpdateWeapon(self);
		return;
	}

// explode if under water
	if (self.waterlevel > 1)
	{
		float cells = self.ammo_cells;
		self.ammo_cells = 0;
		self.weapon = W_BestWeapon(self);
		W_UpdateWeapon (self);
		T_RadiusDamage (self, self, 35*cells, world);
		return;
	}

	if (self.t_width < time)
	{
		sound (self, CHAN_WEAPON, "weapons/lhit.wav", 1, ATTN_NORM);
		self.t_width = time + 0.6;
	}
	self.punchangle_x = -2;

	self.currentammo = self.ammo_cells = self.ammo_cells - 1;

	makevectors(self.v_angle);
	traceline (self.origin, self.origin + v_forward * 600, TRUE, self);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity (MSG_BROADCAST, self);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
	WriteCoord (MSG_BROADCAST, trace_endpos_x);
	WriteCoord (MSG_BROADCAST, trace_endpos_y);
	WriteCoord (MSG_BROADCAST, trace_endpos_z);

	LightningDamage (self.origin, trace_endpos + v_forward * 4, self, 30);
};

void() GrenadeExplode =
{
	T_RadiusDamage (self, self.owner, 120, world);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};

void() GrenadeTouch =
{
	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	if (other.takedamage == DAMAGE_AIM)
	{
		GrenadeExplode();
		return;
	}

	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);	// bounce sound
	if (self.velocity == '0 0 0')
		self.avelocity = '0 0 0';
};

void() W_FireGrenade =
{
	local	entity missile;
	
	self.currentammo = self.ammo_rockets = self.ammo_rockets - 1;
	
	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	self.punchangle_x = -2;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	missile.classname = "grenade";
		
// set missile speed	

	makevectors (self.v_angle);
	missile.velocity = v_forward * 600 + crandom()*v_right*10 + crandom()*v_up*10 + '0 0 200';
	
	
	//if (self.v_angle_x)
		//missile.velocity = v_forward*600 + v_up*200 + crandom()*v_right*10 + crandom()*v_up*10;
	/*else
	{
		dprint("v_angle_x == 0\n");
		missile.velocity = v_forward * 600;
		missile.velocity_z = 200;
	}*/

	missile.avelocity = '300 300 300';
	
	missile.angles = vectoangles(missile.velocity);
	
	missile.touch = GrenadeTouch;
	
// set missile duration
	missile.think = GrenadeExplode;
	missile.nextthink = time + 2.5;

	setmodel (missile, "progs/grenade.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin + v_forward*12 + self.view_ofs - v_up*12);
};

void() spike_touch;
void() superspike_touch;

/*
===============
launch_spike

Used for both the player and the ogre
===============
*/
void(vector org, vector dir) launch_spike =
{	
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);

	newmis.velocity = dir * 1000;
};

void() W_FireSuperSpikes =
{
	local vector	dir;
	
	sound (self, CHAN_WEAPON, "weapons/spike2.wav", 1, ATTN_NORM);
	self.attack_finished = time + 0.2;
	self.currentammo = self.ammo_nails = self.ammo_nails - 2;
	//dir = aim (self, 1000);
	//launch_spike (self.origin + '0 0 16', dir);
	
	dir = v_forward;
	launch_spike (self.origin + v_forward * 12 + self.view_ofs - v_up * 12, dir);
	
	newmis.touch = superspike_touch;
	setmodel (newmis, "progs/s_spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	self.punchangle_x = -2;
};

void(float ox) W_FireSpikes =
{
	local vector	dir;
	
	makevectors (self.v_angle);
	
	if (self.ammo_nails >= 2 && self.weapon == IT_SUPER_NAILGUN)
	{
		W_FireSuperSpikes ();
		return;
	}

	if (self.ammo_nails < 1)
	{
		self.weapon = W_BestWeapon (self);
		W_UpdateWeapon (self);
		return;
	}

	sound (self, CHAN_WEAPON, "weapons/rocket1i.wav", 1, ATTN_NORM);
	self.attack_finished = time + 0.2;
	self.currentammo = self.ammo_nails = self.ammo_nails - 1;
	//dir = aim (self, 1000);
	//launch_spike (self.origin + '0 0 16' + v_right*ox, dir);
	
	dir = v_forward;
	launch_spike (self.origin + v_forward * 8 + self.view_ofs - v_up * 12 + v_right * ox, dir);
	

	self.punchangle_x = -2;
};



void() spike_touch =
{

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		if (other.classname == "func_breakable")
		{
			vector vel;
			vel = wall_velocity () * 0.2;
			particle(self.origin + vel * 0.01, vel * 0.02, other.colour, 9);
		}
		else
			spawn_touchblood (9);
			
		T_Damage (other, self, self.owner, 9);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		
		if (self.classname == "wizspike")
			WriteByte (MSG_BROADCAST, TE_WIZSPIKE);
		else if (self.classname == "knightspike")
			WriteByte (MSG_BROADCAST, TE_KNIGHTSPIKE);
		else
			WriteByte (MSG_BROADCAST, TE_SPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};

void() superspike_touch =
{
	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		if (other.classname == "func_breakable")
		{
			vector vel;
			vel = wall_velocity () * 0.2;
			particle(self.origin + vel * 0.01, vel * 0.02, other.colour, 18);
		}
		else
			spawn_touchblood(18);
			
		T_Damage (other, self, self.owner, 18);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};


/*==========
W_Attack
==========*/
void()	player_axe1;
void()	player_axeb1;
void()	player_axec1;
void()	player_axed1;
void()	player_shot1;
void()	player_nail1;
void()	player_lightning;
void()	player_rocket1;
void() W_Attack =
{
	if (time < self.attack_finished)
		return;
	if (!self.weapon)
		return;
	if (!W_CheckNoAmmo(self))
	{
		self.weapon = W_BestWeapon(self);
		W_UpdateWeapon(self);
		return;
	}
		
	makevectors	(self.v_angle);
	self.show_hostile = time + 1;

	if (self.weapon == IT_AXE)
	{
		sound (self, CHAN_WEAPON, "weapons/ax1.wav", 1, ATTN_NORM);
		float r = random();
		if (r < 0.25)
			player_axe1 ();
		else if (r<0.5)
			player_axeb1 ();
		else if (r<0.75)
			player_axec1 ();
		else
			player_axed1 ();
		self.attack_finished = time + 0.5;
	}
	else if (self.weapon == IT_SHOTGUN)
	{
		player_shot1 ();
		W_FireShotgun ();
		self.attack_finished = time + 0.5;
	}
	else if (self.weapon == IT_SUPER_SHOTGUN)
	{
		player_shot1 ();
		W_FireSuperShotgun ();
		self.attack_finished = time + 0.7;
	}
	else if (self.weapon == IT_NAILGUN)
	{
		player_nail1 ();
	}
	else if (self.weapon == IT_SUPER_NAILGUN)
	{
		player_nail1 ();
	}
	else if (self.weapon == IT_GRENADE_LAUNCHER)
	{
		player_rocket1();
		W_FireGrenade();
		self.attack_finished = time + 0.6;
	}
	else if (self.weapon == IT_ROCKET_LAUNCHER)
	{
		player_rocket1();
		W_FireRocket();
		self.attack_finished = time + 0.8;
	}
	else if (self.weapon == IT_LIGHTNING)
	{
		sound (self, CHAN_AUTO, "weapons/lstart.wav", 1, ATTN_NORM);
		player_lightning();
	}
};

/*==========
W_ChangeWeapon
==========*/
void(float wep) W_ChangeWeapon =
{
	float am = 0;
	float it = 0;
	if (wep == 1)
	{
		it = IT_AXE;
	}
	else if (wep == 2)
	{
		it = IT_SHOTGUN;
		if (self.ammo_shells < 1)
			am = 1;
	}
	else if (wep == 3)
	{
		it = IT_SUPER_SHOTGUN;
		if (self.ammo_shells < 2)
			am = 1;
	}		
	else if (wep == 4)
	{
		it = IT_NAILGUN;
		if (self.ammo_nails < 1)
			am = 1;
	}
	else if (wep == 5)
	{
		it = IT_SUPER_NAILGUN;
		if (self.ammo_nails < 2)
			am = 1;
	}
	else if (wep == 6)
	{
		it = IT_GRENADE_LAUNCHER;
		if (self.ammo_rockets < 1)
			am = 1;
	}
	else if (wep == 7)
	{
		it = IT_ROCKET_LAUNCHER;
		if (self.ammo_rockets < 1)
			am = 1;
	}
	else if (wep == 8)
	{
		it = IT_LIGHTNING;
		if (self.ammo_cells < 1)
			am = 1;
	}
	
	if (!(self.items & it))
	{
		sprint (self, "no weapon.\n");
		return;
	}
	if (am)
	{
		sprint (self, "not enough ammo.\n");
		return;
	}
	
	self.weapon = it;
	W_UpdateWeapon(self);
};

/*==========
W_Cheat
==========*/
void() W_Cheat =
{
	self.ammo_rockets = 100;
	self.ammo_nails = 200;
	self.ammo_shells = 100;
	self.ammo_cells = 200;
	self.items = self.items | 
		IT_AXE |
		IT_SHOTGUN |
		IT_SUPER_SHOTGUN |
		IT_NAILGUN |
		IT_SUPER_NAILGUN |
		IT_GRENADE_LAUNCHER |
		IT_ROCKET_LAUNCHER |
		IT_LIGHTNING |
		IT_KEY1 | IT_KEY2;

	self.weapon = IT_ROCKET_LAUNCHER;
	W_UpdateWeapon(self);
};

/*==========
W_RuneCheat
==========*/
void() W_RuneCheat =
{
	if (!(serverflags & 1))
		serverflags = serverflags + 1;
	else if (!(serverflags & 2))
		serverflags = serverflags + 2;
	else if (!(serverflags & 4))
		serverflags = serverflags + 4;
	else if (!(serverflags & 8))
		serverflags = serverflags + 8;
};

/*==========
QuadCheat
==========*/
void() W_QuadCheat =
{
	self.super_time = 1;
	self.super_damage_finished = time + 30;
	self.items = self.items | IT_QUAD;
	sprint(self, "You got the Quad Damage\n");
	sound(self, CHAN_VOICE, "items/damage.wav", 1.0, ATTN_NORM);
	stuffcmd(self, "bf\n");
};

/*==========
PentCheat
==========*/
void() W_PentCheat =
{
	self.invincible_time = 1;
	self.invincible_finished = time + 30;
	self.items = self.items | IT_INVULNERABILITY;
	sprint(self, "You got the Pentagram of Protection!\n");
	sound(self, CHAN_VOICE, "items/protect.wav", 1.0, ATTN_NORM);
	stuffcmd(self, "bf\n");
};

/*==========
RingCheat
==========*/
void() W_RingCheat =
{
	self.invisible_time = 1;
	self.invisible_finished = time + 30;
	self.items = self.items | IT_INVISIBILITY;
	sprint(self, "You got the Ring of Shadows\n");
	sound(self, CHAN_VOICE, "items/inv1.wav", 1.0, ATTN_NORM);
	stuffcmd(self, "bf\n");
};

/*==========
SuitCheat
==========*/
void() W_SuitCheat =
{
	self.rad_time = 1;
	self.radsuit_finished = time + 30;
	self.items = self.items | IT_SUIT;
	sprint(self, "You got the Biosuit\n");
	sound(self, CHAN_VOICE, "items/suit.wav", 1.0, ATTN_NORM);
	stuffcmd(self, "bf\n");
};

void() DebugTrace =
{
	makevectors (self.v_angle);
	vector source = self.origin + '0 0 16';
	traceline (source, source + v_forward*4096, FALSE, self);
	
	if (trace_ent)
		eprint(trace_ent);
};

/*==========
W_ImpulseCommands
==========*/
void() W_ImpulseCommands =
{
	if (!(deathmatch || coop))
	{
		if (self.impulse == 9)
			W_Cheat();
		if (self.impulse == 11)
			W_RuneCheat();
		if (self.impulse == 255)
			W_QuadCheat();
		if (self.impulse == 254)
			W_PentCheat();
		if (self.impulse == 253)
			W_RingCheat();
		if (self.impulse == 252)
			W_SuitCheat();
		if (self.impulse == 251)
		{
			W_Cheat();
			W_QuadCheat();
			W_PentCheat();
		}
	}
	if (self.impulse == 200)
		DebugTrace();

	if (time < self.attack_finished)
		return;
	if (self.impulse >= 1 && self.impulse <= 8)
		W_ChangeWeapon(self.impulse);
	self.impulse = 0;
};

/*==========
W_QuadDamageSound
==========*/
void() W_QuadDamageSound =
{
	if (self.super_damage_finished > time)
	{
		if (self.super_sound < time)
		{
			self.super_sound = time + 1;
			sound (self, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
		}
	}
};

/*==========
W_WeaponFrame
==========*/
void() W_WeaponFrame =
{
	W_ImpulseCommands();

	if (self.button0)
	{
		W_QuadDamageSound();
		W_Attack();
	}
};
