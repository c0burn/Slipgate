void()	s_explode1	=	[0,		s_explode2] {};
void()	s_explode2	=	[1,		s_explode3] {};
void()	s_explode3	=	[2,		s_explode4] {};
void()	s_explode4	=	[3,		s_explode5] {};
void()	s_explode5	=	[4,		s_explode6] {};
void()	s_explode6	=	[5,		SUB_Remove] {};

/*==========
BecomeExplosion
==========*/
void() BecomeExplosion =
{
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/s_explod.spr");
	s_explode1();
};

/*==========
grenade_explode
==========*/
static void() grenade_explode =
{
	RadiusDamage (self, self.owner, self.dmg, world);
	te_explosion(self.origin);
	BecomeExplosion();
};

/*==========
grenade_touch
==========*/
static void() grenade_touch =
{
	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	if (other.takedamage == DAMAGE_AIM)
	{
		grenade_explode();
		return;
	}
	sound (self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);
};

/*==========
launch_grenade

used for player, zombie and ogre grenades
==========*/
void(vector org, vector dir, float spd, float dam) launch_grenade =
{
	newmis = spawn();
	newmis.classname = "grenade";
	newmis.owner = self;
	newmis.solid = SOLID_BBOX;
	newmis.movetype = MOVETYPE_BOUNCE;

	setmodel (newmis, "progs/grenade.mdl");
	setsize (newmis, '0 0 0', '0 0 0');
	setorigin (newmis, org);

	newmis.dmg = dam;
	
	newmis.touch = grenade_touch;
	newmis.angles = vectoangles(dir);
	newmis.velocity = dir * spd;
	
	newmis.think = grenade_explode;
	newmis.nextthink = time + 2.5;
};

/*==========
spike_touch
==========*/
static void() spike_touch2 =
{
	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	// move out of the wall / floor slightly
	self.origin = self.origin - 8*normalize(self.velocity);

	// lasers always play an impact sound
	if (self.classname == "laser")
		sound (self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_IDLE);
	
	if (other.takedamage)
	{
		Damage(other, self, self.owner, self.dmg);
		if (other.solid == SOLID_BSP)
			SpawnTouchParticles(self.dmg, 192);
		else
			SpawnTouchblood(self.dmg);
	}
	else
	{
		if (self.classname == "laser")
			te_gunshot(self.origin);
		else if (self.classname == "spike")
			te_spike(self.origin);
		else if (self.classname == "superspike")
			te_superspike(self.origin);
		else if (self.classname == "wizspike")
			te_wizspike(self.origin);
		else if (self.classname == "knightspike")
			te_knightspike(self.origin);
	}

	remove(self);
};

/*==========
launch_spike

used for nails, lasers, scrag spit and hellknight fire
==========*/
void(string name, string mod, vector org, vector dir, float spd, float dam) launch_spike2 =
{
	newmis = spawn();
	newmis.classname = name;	// spike, superspike, laser, knightspike, wizspike
	newmis.owner = self;
	newmis.solid = SOLID_BBOX;
	newmis.movetype = MOVETYPE_FLYMISSILE;

	setmodel (newmis, mod);
	setsize (newmis, '0 0 0', '0 0 0');
	setorigin (newmis, org);

	newmis.dmg = dam;
	
	newmis.touch = spike_touch2;
	newmis.angles = vectoangles(dir);
	newmis.velocity = dir * spd;
	
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 10;
};
