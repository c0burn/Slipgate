enumflags { MONSTER_AMBUSH, MONSTER_TELEPORT=4 };

/*==========
monster_death_use

when a monster dies, it fires it's targets with its enemy as the activator
==========*/
void() monster_death_use =
{
	// drop to floor
	if (self.flags & FL_FLY)
		self.flags = self.flags - FL_FLY;
	if (self.flags & FL_SWIM)
		self.flags = self.flags - FL_SWIM;

	// use targets
	activator = self.enemy;
	UseTargets();

	// bump monster counter
	killed_monsters = killed_monsters + 1;
	WriteByte (MSG_ALL, SVC_KILLEDMONSTER);
};

/*==========
monster_use

using a monster makes it angry if the activator is a player
==========*/
static void() monster_use =
{
	if (self.enemy)
		return;
	if (self.health <= 0)
		return;
	if (activator.classname != "player")
		return;
	if (activator.items & IT_INVISIBILITY)
		return;
	if (activator.flags & FL_NOTARGET)
		return;

	self.enemy = activator;
	self.nextthink = time + 0.1;
	self.think = FoundTarget;
};

/*==========
monster_start_go
==========*/
static void() monster_start_go =
{
	// only walkmonsters drop to the floor
	if (self.flags & (FL_MONSTER | FL_FLY | FL_SWIM) == FL_MONSTER)
	{
		self.origin_z = self.origin_z + 1;
		droptofloor();
	}
	
	// print console warning if we're stuck in a wall
	if (!walkmove(0, 0))
	{
		dprint(self.classname);
		dprint(" in wall at: ");
		dprint(vtos(self.origin));
		dprint("\n");
	}
	
	self.think = self.th_stand;
	self.nextthink = time + 0.01 + random() * 0.5;
	
	// if the monster targets a path corner, they will move towards it
	// otherwise, they will fire their targets upon death
	if (self.target != "")
	{
		entity t = find(world, targetname, self.target);
		if (!t)
		{
			dprint(self.classname);
			dprint (" can't find target at: ");
			dprint (vtos(self.origin));
			dprint ("\n");
			return;
		}
		
		if (t.classname == "path_corner")
		{
			self.movetarget = self.goalentity = t;
			self.ideal_yaw = vectoyaw(t.origin - self.origin);
			self.think = self.th_walk;
		}
	}
};

/*==========
monster_teleport_use

using a monster with the teleport flag spawns it in
==========*/
static void() monster_teleport_use =
{
	self.use = monster_use;
	self.takedamage = DAMAGE_AIM;
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	setmodel(self, self.mdl);
	setsize(self, self.pos1, self.pos2);
	
	spawn_tdeath(self.origin, self);
	spawn_tfog(self.origin);
	
	self.think = self.th_stand;
	self.nextthink = time + 0.1;
	
	// if a player activated the monster,
	// get mad unless they're invisible or notarget
	if (activator.classname == "player")
	{
		if (activator.flags & FL_NOTARGET)
			return;
		if (activator.items & IT_INVISIBILITY)
			return;
		self.enemy = activator;
		self.think = FoundTarget;
		self.nextthink = time + 0.1;
	}
};

/*==========
monster_start
==========*/
void(string mod, string hmod, float hp, float fl, vector min, vector max) monster_start =
{
	if (cvar("nomonsters"))
	{
		remove(self);
		return;
	}
		
	total_monsters = total_monsters + 1;

	self.flags = FL_MONSTER + fl;	// FL_FLY or FL_SWIM
	self.headmodel = hmod;
	self.health = hp;
	
	if (self.flags & FL_FLY)
	{
		self.yaw_speed = 20;
		self.view_ofs = '0 0 25';
	}
	else if (self.flags & FL_SWIM)
	{
		self.yaw_speed = 10;
		self.view_ofs = '0 0 10';
	}
	else
	{
		self.yaw_speed = 30;
		self.view_ofs = '0 0 25';
	}
	self.ideal_yaw = self.angles_y;

	// teleport flag
	if (self.spawnflags & MONSTER_TELEPORT)
	{
		if (!self.targetname)
		{
			total_monsters = total_monsters - 1;
			objerror("teleporting monsters must have a targetname\n");
			remove(self);
			return;
		}
		
		self.use = monster_teleport_use;
		self.solid = SOLID_NOT;
		self.movetype = MOVETYPE_NONE;
		setsize(self, min, max);
		// save off fields so we can restore them later
		self.pos1 = min;
		self.pos2 = max;
		self.mdl = mod;	
		return;
	}
	
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	setmodel (self, mod);
	setsize (self, min, max);
	
	self.use = monster_use;
	self.takedamage = DAMAGE_AIM;
	
	self.think = monster_start_go;
	self.nextthink = time + 0.01 + random() * 0.5;
};
