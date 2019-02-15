/*========================================
it_keys.qc
========================================*/

/*==========
key_touch
==========*/
void() key_touch =
{
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	if (other.items & self.items)
		return;

	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other,"\n");

	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	other.items = other.items | self.items;

	self.solid = SOLID_NOT;
	self.model = string_null;

	// fire targets
	activator = other;
	SUB_UseTargets();
};

/*==========
key_setmodel
==========*/
void() key_setmodel =
{
	if (world.worldtype == 0)
	{
		precache_model ("progs/key_med.mdl");
		setmodel (self, "progs/key_med.mdl");
	}
	else if (world.worldtype == 1)
	{
		precache_model ("progs/key_rune.mdl");
		setmodel (self, "progs/key_rune.mdl");
	}
	else if (world.worldtype == 2)
	{
		precache_model2 ("progs/key_base.mdl");
		setmodel (self, "progs/key_base.mdl");
	}
};

/*==========
key_setsounds
==========*/
void() key_setsounds =
{
	if (world.worldtype == 0)
		self.noise = "misc/medkey.wav";
	if (world.worldtype == 1)
		self.noise = "misc/runekey.wav";
	if (world.worldtype == 2)
		self.noise = "misc/basekey.wav";
	precache_sound(self.noise);
};

/*QUAKED item_key1 (0 0 1) (-16 -16 -24) (16 16 32) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{	model("progs/key_med.mdl");	}
SILVER key
In order for keys to work
you MUST set your maps
worldtype to one of the
following:
0: medieval
1: metal
2: base
*/
void() item_key1 =
{
	if (world.worldtype == 0)
		self.netname = "silver key";
	else if (world.worldtype == 1)
		self.netname = "silver runekey";
	else if (world.worldtype == 2)
		self.netname = "silver keycard";
	key_setmodel();
	key_setsounds();
	self.touch = key_touch;
	self.items = IT_KEY1;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*QUAKED item_key2 (0 0 1) (-16 -16 -24) (16 16 32) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ({"path" : "progs/key_med.mdl", "skin" : 1});
}
GOLD key
In order for keys to work
you MUST set your maps
worldtype to one of the
following:
0: medieval
1: metal
2: base
*/
void() item_key2 =
{
	if (world.worldtype == 0)
		self.netname = "gold key";
	else if (world.worldtype == 1)
		self.netname = "gold runekey";
	else if (world.worldtype == 2)
		self.netname = "gold keycard";
	key_setmodel();
	key_setsounds();
	self.skin = 1;
	self.touch = key_touch;
	self.items = IT_KEY2;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*==========
sigil_touch
==========*/
void() sigil_touch =
{
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	serverflags = serverflags | (self.spawnflags & 15);
	centerprint (other, "You got the Rune of ", self.netname, " Magic!");
	sound (other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	self.solid = SOLID_NOT;
	self.model = string_null;
	
	// fire targets
	activator = other;
	SUB_UseTargets();
};

/*QUAKED item_sigil (0 0 1) (-16 -16 -24) (16 16 32) E1 E2 E3 E4 X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ( {{ spawnflags & 1 -> { "path" : "progs/end1.mdl" }, spawnflags & 2 -> { "path" : "progs/end2.mdl" },
	spawnflags & 4 -> { "path" : "progs/end3.mdl" }, spawnflags & 8 -> { "path" : "progs/end4.mdl" },
	 "progs/end1.mdl" }} );
}
End of episode rune. Use in conjuction with func_bossgate and func_episodegate.
Spawnflag must be set to the appropriate episode.
Episode 1 - Dimension of the Doomed - Rune of Earth Magic
Episode 2 - The Realm of Black Magic - Rune of Black Magic
Episode 3 - The Netherworld - Rune of Hell Magic
Episode 4 - The Elder World - Run of Elder Magic
*/
void() item_sigil =
{
	self.noise = "misc/runekey.wav";
	precache_sound(self.noise);

	if (self.spawnflags & 1)
	{
		self.netname = "Earth";
		precache_model ("progs/end1.mdl");
		setmodel (self, "progs/end1.mdl");
	}
	else if (self.spawnflags & 2)
	{
		self.netname = "Black";
		precache_model2 ("progs/end2.mdl");
		setmodel (self, "progs/end2.mdl");
	}
	else if (self.spawnflags & 4)
	{
		self.netname = "Hell";
		precache_model2 ("progs/end3.mdl");
		setmodel (self, "progs/end3.mdl");
	}
	else if (self.spawnflags & 8)
	{
		self.netname = "Elder";
		precache_model2 ("progs/end4.mdl");
		setmodel (self, "progs/end4.mdl");
	}
	else
	{
		objerror("invalid spawnflags\n");
		remove(self);
		return;
	}
	
	self.touch = sigil_touch;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};