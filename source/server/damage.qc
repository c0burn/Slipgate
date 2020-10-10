/*==========
CanDamage

used for explosions and melee attacks
==========*/
float(entity targ, entity inflictor) CanDamage =
{
	// bmodels need special checking because their origin is 0,0,0
	if (targ.movetype == MOVETYPE_PUSH)
	{
		traceline(inflictor.origin, realorigin(targ), TRUE, self);
		if (trace_fraction == 1)
			return TRUE;
		if (trace_ent == targ)
			return TRUE;
		return FALSE;
	}

	traceline(inflictor.origin, targ.origin, TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '-15 15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;
	traceline(inflictor.origin, targ.origin + '15 -15 0', TRUE, self);
	if (trace_fraction == 1)
		return TRUE;

	return FALSE;
};

/*==========
Killed
==========*/
void(entity targ, entity inflictor, entity attacker) Killed =
{
	entity oself = self;
	self = targ;

	// doors, triggers, etc
	if (self.movetype == MOVETYPE_PUSH || self.movetype == MOVETYPE_NONE)
	{
		self.th_die(inflictor, attacker);
		self = oself;
		return;
	}

	if (self.flags & FL_CLIENT)
	{
		// don't let sbar look bad
		if (self.health < -99)
			self.health = -99;

		// display obituary text
		Obituary(self, attacker, inflictor);
	}
	
	if (self.flags & FL_MONSTER)
		monster_death_use();

	self.takedamage = DAMAGE_NO;
	self.touch = SUB_Null;

	self.th_die (inflictor, attacker);

	self = oself;
};

/*==========
Damage
==========*/
void(entity targ, entity inflictor, entity attacker, float damage) Damage =
{
	if (!targ.takedamage)
		return;

	// check for quad damage
	if (attacker.items & IT_QUAD)
		damage = damage * 4;
		
	// save damage based upon armor
	float save, take;
	save = ceil(targ.armortype * damage);
	// lost all armor
	if (save >= targ.armorvalue)
	{
		save = targ.armorvalue;
		targ.armortype = 0;
		targ.items = targ.items - (targ.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
	}
	targ.armorvalue = targ.armorvalue - save;
	take = ceil(damage - save);

	if (targ.flags & FL_CLIENT)
	{
		// add to the damage total for clients, which will be sent as a single
		// message at the end of the frame
		targ.dmg_take = targ.dmg_take + take;
		targ.dmg_save = targ.dmg_save + save;
		targ.dmg_inflictor = attacker;
	}

	// push players around
	if ( (inflictor != world) && (targ.movetype == MOVETYPE_WALK) )
	{
		vector dir = targ.origin - realorigin(inflictor);
		dir = normalize(dir);
		targ.velocity = targ.velocity + dir*damage*8;
	}

	// check for godmode or pent
	if (targ.flags & FL_GODMODE)
		return;
	if (targ.items & IT_INVULNERABILITY)
	{
		if (targ.invincible_sound < time)
		{
			sound (targ, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
			targ.invincible_sound = time + 2;
		}
		return;
	}
	// team play damage avoidance
	if ((teamplay == 1) && (targ.team > 0) && (targ.team == attacker.team))
		return;

	// do the damage
	targ.health = targ.health - take;
	if (targ.health <= 0)
	{
		Killed (targ, inflictor, attacker);
		return;
	}

	// react to the damage
	entity oself = self;
	self = targ;

	// monsters get mad, unless of the same class (except for grunts)
	if ( (self.flags & FL_MONSTER) && (attacker.flags & FL_CLIENT | FL_MONSTER) )
	{
		if (self != attacker && attacker != self.enemy)
		{
			if ( (self.classname != attacker.classname) || (self.classname == "monster_army" ) )
			{
				if (self.enemy.classname == "player")
					self.oldenemy = self.enemy;
				self.enemy = attacker;
				FoundTarget();
			}
		}
	}

	if (self.th_pain)
	{
		self.th_pain (attacker, take);
		// nightmare mode monsters don't go into pain frames often
		if (skill == 3 && self.flags & FL_MONSTER)
			self.pain_finished = time + 5;
	}

	self = oself;
};

/*==========
RadiusDamage
==========*/
void(entity inflictor, entity attacker, float damage, entity ignore) RadiusDamage =
{
	float attacker_damaged = FALSE;
	float attacker_points = 0;
	entity head = findradius(inflictor.origin, damage + 40);
	while (head)
	{
		if (head != ignore)
		{
			if (head.takedamage)
			{
				vector org = realorigin(head);
				float points = 0.5*vlen (inflictor.origin - org);
				if (points < 0)
					points = 0;
				points = damage - points;
				if (points > 0)
				{
					if (CanDamage (head, inflictor))
					{
						if (head == attacker)
						{
							attacker_damaged = TRUE;
							attacker_points = points * 0.5;
						}
						else
						{
							if (head.classname == "monster_shambler")
								Damage (head, inflictor, attacker, points * 0.5);
							else
								Damage (head, inflictor, attacker, points);
						}
					}
				}
			}
		}
		head = head.chain;
	}

	if (attacker_damaged)
		Damage (attacker, inflictor, attacker, attacker_points);
};
