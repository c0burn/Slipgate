float AMMO_BIG = 1;

/*==========
ammo_touch
==========*/
void() ammo_touch =
{
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	float best = W_BestWeapon(other);
	
	if (self.items == IT_SHELLS)
	{
		if (other.ammo_shells >= 100)
			return;
		other.ammo_shells = other.ammo_shells + self.aflag;
	}
	if (self.items == IT_NAILS)
	{
		if (other.ammo_nails >= 200)
			return;
		other.ammo_nails = other.ammo_nails + self.aflag;
	}
	if (self.items == IT_ROCKETS)
	{
		if (other.ammo_rockets >= 100)
			return;
		other.ammo_rockets = other.ammo_rockets + self.aflag;
	}
	if (self.items == IT_CELLS)
	{
		if (other.ammo_cells >= 100)
			return;
		other.ammo_cells = other.ammo_cells + self.aflag;
	}
	W_BoundAmmo(other);
	W_SetCurrentAmmo(other);
	
	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	
	sprint (other, "You got ");
	sprint (other, ftos(self.aflag));
	sprint (other, " ");
	sprint (other, self.netname);
	sprint (other, "\n");

	self.model = string_null;
	self.solid = SOLID_NOT;
	if (deathmatch)
	{
		self.think = ItemRespawn;
		self.nextthink = time + 30;
	}

	// if the player was using their best weapon,
	// switch to a better one if we now have the ammo for it
	if (other.weapon == best)
	{
		best = W_BestWeapon(other);
		if (other.weapon != best)
		{
			other.weapon = best;
			W_UpdateWeapon(other);
		}
	}

	// fire all targets
	activator = other;
	SUB_UseTargets();
};

/*QUAKED item_shells (0 0 1) (0 0 0) (32 32 56) AMMO_BIG X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ( {{ spawnflags & 1 -> { "path" : "maps/b_shell1.bsp" }, "maps/b_shell0.bsp" }} );
}
Nox of 20 shells.
AMMO_BIG is a box of 40 shells.
*/
void() item_shells =
{
	self.touch = ammo_touch;
	if (self.spawnflags & AMMO_BIG)
	{
		precache_model ("maps/b_shell1.bsp");
		setmodel (self, "maps/b_shell1.bsp");
		self.aflag = 40;
	}
	else
	{
		precache_model ("maps/b_shell0.bsp");
		setmodel (self, "maps/b_shell0.bsp");
		self.aflag = 20;
	}
	self.items = IT_SHELLS;
	self.netname = "shells";
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};

/*QUAKED item_spikes (0 0 1) (0 0 0) (32 32 56) AMMO_BIG X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ( {{ spawnflags & 1 -> { "path" : "maps/b_nail1.bsp" }, "maps/b_nail0.bsp" }} );
}
Nox of 25 nails.
AMMO_BIG is a box of 50 nails.
*/
void() item_spikes =
{
	self.touch = ammo_touch;
	if (self.spawnflags & AMMO_BIG)
	{
		precache_model ("maps/b_nail1.bsp");
		setmodel (self, "maps/b_nail1.bsp");
		self.aflag = 50;
	}
	else
	{
		precache_model ("maps/b_nail0.bsp");
		setmodel (self, "maps/b_nail0.bsp");
		self.aflag = 25;
	}
	self.items = IT_NAILS;
	self.netname = "nails";
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};

/*QUAKED item_rockets (0 0 1) (0 0 0) (32 32 56) AMMO_BIG X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ( {{ spawnflags & 1 -> { "path" : "maps/b_rock1.bsp" }, "maps/b_rock0.bsp" }} );
}
Nox of 5 rockets.
AMMO_BIG is a box of 10 rockets.
*/
void() item_rockets =
{
	self.touch = ammo_touch;

	if (self.spawnflags & AMMO_BIG)
	{
		precache_model ("maps/b_rock1.bsp");
		setmodel (self, "maps/b_rock1.bsp");
		self.aflag = 10;
	}
	else
	{
		precache_model ("maps/b_rock0.bsp");
		setmodel (self, "maps/b_rock0.bsp");
		self.aflag = 5;
	}
	self.items = IT_ROCKETS;
	self.netname = "rockets";
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};


/*QUAKED item_cells (0 0 1) (0 0 0) (32 32 56) AMMO_BIG X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ( {{ spawnflags & 1 -> { "path" : "maps/b_batt1.bsp" }, "maps/b_batt0.bsp" }} );
}
Nox of 6 cells.
AMMO_BIG is a box of 12 cells.
*/
void() item_cells =
{
	self.touch = ammo_touch;

	if (self.spawnflags & AMMO_BIG)
	{
		precache_model ("maps/b_batt1.bsp");
		setmodel (self, "maps/b_batt1.bsp");
		self.aflag = 12;
	}
	else
	{
		precache_model ("maps/b_batt0.bsp");
		setmodel (self, "maps/b_batt0.bsp");
		self.aflag = 6;
	}
	self.items = IT_CELLS;
	self.netname = "cells";
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};

/*==========
item_weapon

Stupid id software remnant that is deprecated but used on dm5, dm6,
e2m2 and e3m7. despite the name, it's an ammo box. the vanilla item
contains a couple of bugs, for example nails are called spikes and don't
match the ammo count of the normal item.
converts itself to the correct entity upon spawn.
==========*/
float ITW_SHELLS	= 1;
float ITW_ROCKETS	= 2;
float ITW_NAILS		= 4;
float ITW_BIG		= 8;
void() item_weapon =
{
	dprint("item_weapon is deprecated, converted to correct entity\n");
	if (!self.spawnflags)
	{
		objerror("no spawnflags set");
		remove(self);
		return;
	}
	
	if (self.spawnflags & ITW_SHELLS)
	{
		if (self.spawnflags & ITW_BIG)
			self.spawnflags = AMMO_BIG;
		self.classname = "item_shells";
		item_shells();
	}
	else if (self.spawnflags & ITW_ROCKETS)
	{
		if (self.spawnflags & ITW_BIG)
			self.spawnflags = AMMO_BIG;
		self.classname = "item_rockets";
		item_rockets();
	}
	else if (self.spawnflags & ITW_NAILS)
	{
		if (self.spawnflags & ITW_BIG)
			self.spawnflags = AMMO_BIG;
		self.classname = "item_spikes";
		item_spikes();
	}
	else
	{
		objerror("invalid spawnflags set");
		remove(self);
	}
};