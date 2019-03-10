
void() T_MissileTouch;
void(entity targ, entity attacker) ClientObituary;

void() monster_death_use;

//============================================================================

/*
============
CanDamage

Returns true if the inflictor can directly damage the target.  Used for
explosions and melee attacks.
============
*/
float(entity targ, entity inflictor) CanDamage =
{
	// bmodels need special checking because their origin is 0,0,0
	if (targ.movetype == MOVETYPE_PUSH)
	{
		traceline(inflictor.origin, 0.5 * (targ.absmin + targ.absmax), TRUE, self);
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


/*
============
Killed
============
*/
void(entity targ, entity inflictor, entity attacker) Killed =
{
	entity oself = self;
	self = targ;

	if (self.health < -99)
		self.health = -99;

	// doors, triggers, etc
	if (self.movetype == MOVETYPE_PUSH || self.movetype == MOVETYPE_NONE)
	{
		self.th_die (inflictor, attacker);
		self = oself;
		return;
	}

	self.enemy = attacker;

	if (self.flags & FL_MONSTER)
	{
		if (self.flags & FL_FLY)
			self.flags = self.flags - FL_FLY;
		if (self.flags & FL_SWIM)
			self.flags = self.flags - FL_SWIM;
			
		monster_death_use();
		killed_monsters = killed_monsters + 1;
		WriteByte (MSG_ALL, SVC_KILLEDMONSTER);
	}

	ClientObituary(self, attacker);
	
	self.takedamage = DAMAGE_NO;
	self.touch = SUB_Null;

	self.th_die (inflictor, attacker);
	
	self = oself;
};

/*
============
T_Damage

The damage is coming from inflictor, but get mad at attacker
This should be the only function that ever reduces health.
============
*/
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage=
{
	if (!targ.takedamage)
		return;

	// check for quad damage
	if (attacker.flags & FL_CLIENT)
		if (attacker.items & IT_QUAD)
			damage = damage * 4;

	// save damage based upon armor
	float save = ceil(targ.armortype * damage);
	// lost all armor
	if (save >= targ.armorvalue)
	{
		save = targ.armorvalue;
		targ.armortype = 0;
		targ.items = targ.items - (targ.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
	}
	targ.armorvalue = targ.armorvalue - save;
	float take = ceil(damage - save);

	// add to the damage total for clients, which will be sent as a single
	// message at the end of the frame
	if (targ.flags & FL_CLIENT)
	{
		targ.dmg_take = targ.dmg_take + take;
		targ.dmg_save = targ.dmg_save + save;
		targ.dmg_inflictor = inflictor;
	}

	// figure momentum add
	if ( (inflictor != world) && (targ.movetype == MOVETYPE_WALK) )
	{
		vector dir = targ.origin - (inflictor.absmin + inflictor.absmax) * 0.5;
		dir = normalize(dir);
		targ.velocity = targ.velocity + dir*damage*8;
	}

	// check for godmode or invincibility
	if (targ.flags & FL_CLIENT)
	{
		if (targ.flags & FL_GODMODE)
			return;
		if (targ.items & IT_INVULNERABILITY)
		{
			if (self.invincible_sound < time)
			{
				sound (targ, CHAN_ITEM, "items/protect3.wav", 1, ATTN_NORM);
				self.invincible_sound = time + 2;
			}
			return;
		}
	}
	
	// team play damage avoidance
	if ( (teamplay == 1) && (targ.team > 0) && (targ.team == attacker.team) )
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

	if ( (self.flags & FL_MONSTER) && attacker != world)
	{
		// get mad unless of the same class (except for soldiers)
		if (self != attacker && attacker != self.enemy)
		{
			if ( (self.classname != attacker.classname) || (self.classname == "monster_army" ) )
			{
				if (self.enemy.classname == "player")
					self.oldenemy = self.enemy;
				self.enemy = attacker;
				FoundTarget ();
			}
		}
	}

	if (self.th_pain)
	{
		self.th_pain (attacker, take);
		// nightmare mode monsters don't go into pain frames often
		if (skill == 3)
			self.pain_finished = time + 5;		
	}

	self = oself;
};

/*
============
T_RadiusDamage
============
*/
void(entity inflictor, entity attacker, float damage, entity ignore) T_RadiusDamage =
{
	local	float 	points;
	local	entity	head;
	local	vector	org;

	head = findradius(inflictor.origin, damage+40);
	
	while (head)
	{
		if (head != ignore)
		{
			if (head.takedamage)
			{
				org = head.origin + (head.mins + head.maxs)*0.5;
				points = 0.5*vlen (inflictor.origin - org);
				if (points < 0)
					points = 0;
				points = damage - points;
				if (head == attacker)
					points = points * 0.5;
				if (points > 0)
				{
					if (CanDamage (head, inflictor))
					{	// shambler takes half damage from all explosions
						if (head.classname == "monster_shambler")						
							T_Damage (head, inflictor, attacker, points*0.5);
						else
							T_Damage (head, inflictor, attacker, points);
					}
				}
			}
		}
		head = head.chain;
	}
};
