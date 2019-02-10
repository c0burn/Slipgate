/*==========
weapon_touch
==========*/
void() weapon_touch =
{
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	if (coop && (other.items & self.weapon))
		return;

	float olditems = other.items;
	other.items = other.items | self.weapon;
	other.ammo_shells = other.ammo_shells + self.ammo_shells;
	other.ammo_nails = other.ammo_nails + self.ammo_nails;
	other.ammo_rockets = other.ammo_rockets + self.ammo_rockets;
	other.ammo_cells = other.ammo_cells + self.ammo_cells;
	W_BoundAmmo(other);
	W_SetCurrentAmmo(other);
	
	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other, "\n");
	
	sound (other, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	self.model = string_null;
	self.solid = SOLID_NOT;
	if (deathmatch)
	{
		self.think = ItemRespawn;
		self.nextthink = time + 30;
	}
	
	// in deathmatch, we switch to a new gun if it's better
	// in single player and coop, we switch if it's a new gun
	if (!(olditems & self.weapon))
	{
		if (deathmatch)
		{
			other.weapon = W_DeathmatchWeapon(other, other.weapon, self.weapon);
			W_UpdateWeapon(other);
		}
		else
		{
			other.weapon = self.weapon;
			W_UpdateWeapon(other);
		}
	}
	
	// fire targets
	activator = other;
	SUB_UseTargets();
};

/*QUAKED weapon_supershotgun (0 0 1) (-16 -16 0) (16 16 56) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{	model("progs/g_shot.mdl");	}
Double-barrelled Shotgun
*/
void() weapon_supershotgun =
{
	precache_model ("progs/g_shot.mdl");
	setmodel (self, "progs/g_shot.mdl");
	self.weapon = IT_SUPER_SHOTGUN;
	self.netname = "Double-barrelled Shotgun";
	self.ammo_shells = 5;
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_nailgun (0 0 1) (-16 -16 0) (16 16 56) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{	model("progs/g_nail.mdl");	}
Nailgun
*/
void() weapon_nailgun =
{
	precache_model ("progs/g_nail.mdl");
	setmodel (self, "progs/g_nail.mdl");
	self.weapon = IT_NAILGUN;
	self.netname = "nailgun";
	self.ammo_nails = 30;
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_supernailgun (0 0 1) (-16 -16 0) (16 16 56) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{	model("progs/g_nail2.mdl");	}
Perforator
*/
void() weapon_supernailgun =
{
	precache_model ("progs/g_nail2.mdl");
	setmodel (self, "progs/g_nail2.mdl");
	self.weapon = IT_SUPER_NAILGUN;
	self.netname = "Super Nailgun";
	self.ammo_nails = 30;
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	
	dprint("***** SNAILGUN *****");
	dprint(vtos(self.origin));
	dprint("\n");
	
	StartItem ();
};

/*QUAKED weapon_grenadelauncher (0 0 1) (-16 -16 0) (16 16 56) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{	model("progs/g_rock.mdl");	}
Grenade Launcher
*/
void() weapon_grenadelauncher =
{
	precache_model ("progs/g_rock.mdl");
	setmodel (self, "progs/g_rock.mdl");
	self.weapon = IT_GRENADE_LAUNCHER;
	self.netname = "Grenade Launcher";
	self.ammo_rockets = 5;
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_rocketlauncher (0 0 1) (-16 -16 0) (16 16 56) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{	model("progs/g_rock2.mdl");	}
Rocket Launcher
*/
void() weapon_rocketlauncher =
{
	precache_model ("progs/g_rock2.mdl");
	setmodel (self, "progs/g_rock2.mdl");
	self.weapon = IT_ROCKET_LAUNCHER;
	self.netname = "Rocket Launcher";
	self.ammo_rockets = 5;
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED weapon_lightning (0 0 1) (-16 -16 0) (16 16 56) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{	model("progs/g_light.mdl");	}
Thunderbolt
*/
void() weapon_lightning =
{
	precache_model ("progs/g_light.mdl");
	setmodel (self, "progs/g_light.mdl");
	self.weapon = IT_LIGHTNING;
	self.netname = "Thunderbolt";
	self.ammo_cells = 15;
	self.touch = weapon_touch;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem();
};
