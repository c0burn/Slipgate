static entity multi_ent;
static float multi_damage;

/*==========
ClearMultiDamage
==========*/
static void() ClearMultiDamage =
{
	multi_ent = world;
	multi_damage = 0;
};

/*==========
ApplyMultiDamage
==========*/
static void() ApplyMultiDamage =
{
	if (!multi_ent)
		return;
	Damage (multi_ent, self, self, multi_damage);
};

/*==========
AddMultiDamage
==========*/
static void(entity hit, float damage) AddMultiDamage =
{
	if (!hit)
		return;
	
	if (hit != multi_ent)
	{
		ApplyMultiDamage();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;
};

/*==========
TraceAttack
==========*/
static void(float damage, vector dir) TraceAttack =
{
	vector org = trace_endpos - dir*4;
	if (trace_ent.takedamage)
	{
		vector vel = normalize(dir + v_up*crandom() + v_right*crandom());
		vel = vel + 2 * trace_plane_normal;
		vel = vel * 4;
	
		if (trace_ent.solid == SOLID_BSP)
			particle(org, vel, trace_ent.colour, damage);
		else
			SpawnBlood (org, vel, damage);
		AddMultiDamage (trace_ent, damage);
	}
	else
		te_gunshot(org);
};

/*==========
FireBullets
==========*/
void(float shotcount, vector dir, vector spread) FireBullets =
{
	makevectors(self.v_angle);
	vector src = self.origin + v_forward*10;
	src_z = self.absmin_z + self.size_z * 0.7;

	ClearMultiDamage();
	while (shotcount > 0)
	{
		vector direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;
		traceline (src, src + direction*2048, FALSE, self);
		if (trace_fraction != 1.0)
			TraceAttack (4, direction);
		shotcount = shotcount - 1;
	}
	ApplyMultiDamage();
};

/*==========
W_FireShotgun
==========*/
void() W_FireShotgun =
{
	sound (self, CHAN_WEAPON, "weapons/guncock.wav", 1, ATTN_NORM);	
	self.punchangle_x = -2;
	self.currentammo = self.ammo_shells = self.ammo_shells - 1;
	
	vector dir = aim (self, 100000);
	FireBullets (6, dir, '0.04 0.04 0');
};

/*==========
W_FireSuperShotgun
==========*/
void() W_FireSuperShotgun =
{
	sound (self ,CHAN_WEAPON, "weapons/shotgn2.wav", 1, ATTN_NORM);	
	self.punchangle_x = -4;
	self.currentammo = self.ammo_shells = self.ammo_shells - 2;
	
	vector dir = aim (self, 100000);
	FireBullets (14, dir, '0.14 0.08 0');
};
