/*==========
explobox_explode
==========*/
static void() explobox_explode =
{
	setorigin(self, realorigin(self));	// fix our origin as we're a bmodel
	
	RadiusDamage (self, self, self.dmg, world);
	te_explosion(self.origin);
	BecomeExplosion();
	
	// fire targets
	activator = self.enemy;
	UseTargets();
};

/*==========
explobox_die
==========*/
static void(entity inflictor, entity attacker) explobox_die =
{
	self.enemy = attacker;		// for firing targets
	self.solid = SOLID_NOT;
	self.takedamage = DAMAGE_NO;
	self.think = explobox_explode;
	self.nextthink = self.ltime + 0.1;
};

/*==========
explobox_use
==========*/
static static void() explobox_use =
{
	self.enemy = activator;		// for firing targets
	self.use = SUB_Null;
	self.think = explobox_explode;
	self.nextthink = self.ltime + 0.1;	
};

/*==========
explobox_drop
==========*/
static float() explobox_drop =
{
	self.origin_z = self.origin_z + 2;
	if (!droptofloor())
	{
		dprint (self.classname);
		dprint (" fell out of level at ");
		dprint (vtos(realorigin(self)));
		dprint ("\n");
		remove(self);
		return TRUE;
	}
	return FALSE;
};

/*==========
explobox_start
==========*/
static void() explobox_start =
{
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	if (self.classname == "misc_explobox2")
	{
		precache_model2 ("maps/b_exbox2.bsp");
		setmodel (self, "maps/b_exbox2.bsp");
		setsize(self, '0 0 0', '32 32 32');
		if (explobox_drop())
			return;
	}
	else if (self.classname == "misc_explobox")
	{
		precache_model ("maps/b_explob.bsp");
		setmodel (self, "maps/b_explob.bsp");
		setsize(self, '0 0 0', '32 32 64');
		if (explobox_drop())
			return;
	}
	else
		setmodel (self, self.model);

	self.classname = "explobox";
	SetPositiveDefault(dmg, 160);
	self.colour = 192;
	
	// if targetname is set, it must be triggered
	if (self.targetname != "")
		self.use = explobox_use;
	else
	{
		SetPositiveDefault(health, 20);
		self.takedamage = DAMAGE_AIM;
		self.th_die = explobox_die;
	}
};

/*QUAKED misc_explobox (1 .5 0) (0 0 0) (32 32 64) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model("maps/b_explob.bsp");
}
Large explosive box
If "targetname" is set, cannot be shot and must be triggered.

Keys:
"targetname" - if set, cannot be shot and must be triggered.
"health" - override default health of 20.
"dmg" - override default damage of 160.
*/
void() misc_explobox =
{	
	explobox_start();
};

/*QUAKED misc_explobox2 (1 .5 0) (0 0 0) (32 32 32) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model("maps/b_exbox2.bsp");
}
Small explosive box

Keys:
"targetname" - if set, cannot be shot and must be triggered.
"health" - override default health of 20.
"dmg" - override default damage of 160.
*/
void() misc_explobox2 =
{
	explobox_start();
};

/*QUAKED func_explosive (1 .5 0) ? X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
Brush that explodes when shot or triggered

Keys:
"targetname" - if set, cannot be shot and must be triggered.
"health" - override default health of 20.
"dmg" - override default damage of 160.
*/
void() func_explosive =
{
	explobox_start();
};
