/*==========
backpack_touch
==========*/
void() backpack_touch =
{
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	other.items = other.items | self.items;
	other.ammo_shells = other.ammo_shells + self.ammo_shells;
	other.ammo_nails = other.ammo_nails + self.ammo_nails;
	other.ammo_rockets = other.ammo_rockets + self.ammo_rockets;
	other.ammo_cells = other.ammo_cells + self.ammo_cells;
	W_BoundAmmo(other);
	W_SetCurrentAmmo(other);
	
	sound (other, CHAN_ITEM, "weapons/lock4.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	
	// tell the player what's inside
	float comma = FALSE;
	sprint (other, "You get ");
	if (self.items)
	{
		if (self.items & IT_AXE)
		{
			sprint(other, "the Axe");
			comma = TRUE;
		}
		if (self.items & IT_SHOTGUN)
		{
			if (comma) sprint(other, ", ");
			sprint(other, "the Shotgun");
			comma = TRUE;
		}
		if (self.items & IT_SUPER_SHOTGUN)
		{
			if (comma) sprint(other, ", ");
			sprint(other, "the Double-barrelled Shotgun");
			comma = TRUE;
		}
		if (self.items & IT_NAILGUN)
		{
			if (comma) sprint(other, ", ");
			sprint(other, "the Nailgun");
			comma = TRUE;
		}
		if (self.items & IT_SUPER_NAILGUN)
		{
			if (comma) sprint(other, ", ");
			sprint(other, "the Perforator");
			comma = TRUE;
		}
		if (self.items & IT_GRENADE_LAUNCHER)
		{
			if (comma) sprint(other, ", ");
			sprint(other, "the Grenade Launcher");
			comma = TRUE;
		}
		if (self.items & IT_ROCKET_LAUNCHER)
		{
			if (comma) sprint(other, ", ");
			sprint(other, "the Rocket Launcher");
			comma = TRUE;
		}		
		if (self.items & IT_LIGHTNING)
		{
			if (comma) sprint(other, ", ");
			sprint(other, "the Thunderbolt");
			comma = TRUE;
		}				
	}
	if (self.ammo_shells)
	{
		if (comma) sprint(other, ", ");
		comma = TRUE;
		sprint (other, ftos(self.ammo_shells));
		sprint (other, " shells");
	}
	if (self.ammo_nails)
	{
		if (comma) sprint(other, ", ");
		comma = TRUE;
		sprint (other,  ftos(self.ammo_nails));
		sprint (other, " nails");
	}
	if (self.ammo_rockets)
	{
		if (comma) sprint(other, ", ");
		comma = TRUE;
		sprint (other, ftos(self.ammo_rockets));
		sprint (other, " rockets");
	}
	if (self.ammo_cells)
	{
		if (comma) sprint(other, ", ");
		comma = TRUE;
		sprint (other, ftos(self.ammo_cells));
		sprint (other, " cells");
	}
	sprint (other, "\n");
	
	
	// fire all targets
	activator = other;
	SUB_UseTargets();

	// set up for respawn in deathmatch
	if (self.classname == "item_backpack")	// map item, not dropped backpack
	{
		self.solid = SOLID_NOT;
		self.model = string_null;
		if (deathmatch)
		{
			self.think = ItemRespawn;
			self.nextthink = time + 30;
		}
	}
	else
	{
		remove(self);
	}
};

/*==========
DropBackpack

called by players and monsters upon death
drops a backpack containing current weapon and ammo
==========*/
void() DropBackpack =
{
	// nothing to drop
	if (!(self.ammo_shells + self.ammo_nails + self.ammo_rockets + self.ammo_cells))
		return;

	entity backpack = spawn();
	backpack.classname = "item_backpack_dropped";

	backpack.items = self.weapon;
	backpack.ammo_shells = self.ammo_shells;
	backpack.ammo_nails = self.ammo_nails;
	backpack.ammo_rockets = self.ammo_rockets;
	backpack.ammo_cells = self.ammo_cells;
	
	backpack.flags = FL_ITEM;
	backpack.solid = SOLID_TRIGGER;
	backpack.movetype = MOVETYPE_TOSS;
	setmodel (backpack, "progs/backpack.mdl");
	setsize (backpack, '-16 -16 0', '16 16 56');
	setorigin (backpack, self.origin - '0 0 24');
	backpack.touch = backpack_touch;
	backpack.velocity = [crandom() * 100, crandom() * 100, 300];

	backpack.nextthink = time + 120;
	backpack.think = SUB_Remove;
};

/*QUAKED item_backback (0 0 1) (-16 -16 0) (16 16 56) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{	model("progs/backpack.mdl");	}
Backpack pickup. Contains 40 shells, 50 nails, 10 rockets and 12 cells.
Set ammo_shells, ammo_nails, ammo_rockets and ammo_cells to override defaults.
Use a value of -1, not 0, to not give any ammo of that type.
Set the items bitfield to the IT_SHOTGUN etc values to make it contain weapons.
You can give more than one weapon.
*/
void() item_backback =
{
	precache_sound ("weapons/lock4.wav");
	precache_model ("progs/backpack.mdl");
	setmodel (self, "progs/backpack.mdl");
	setsize (self, '-16 -16 0', '16 16 56');
	self.touch = backpack_touch;

	// remove anything that isn't a weapon
	self.items = self.items & (IT_AXE | IT_SHOTGUN | IT_SUPER_SHOTGUN | IT_NAILGUN | IT_SUPER_NAILGUN |
		IT_GRENADE_LAUNCHER | IT_ROCKET_LAUNCHER | IT_LIGHTNING);
	
	if (!self.ammo_shells)
		self.ammo_shells = 40;
	if (self.ammo_shells < 0)
		self.ammo_shells = 0;

	if (!self.ammo_nails)
		self.ammo_nails = 50;
	if (self.ammo_nails < 0)
		self.ammo_nails = 0;

	if (!self.ammo_rockets)
		self.ammo_rockets = 10;
	if (self.ammo_rockets < 0)
		self.ammo_rockets = 0;

	if (!self.ammo_cells)
		self.ammo_cells = 12;
	if (self.ammo_cells < 0)
		self.ammo_cells = 0;
	
	StartItem();
};
