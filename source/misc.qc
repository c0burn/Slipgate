enumflags { MISC_MODEL_SOLID };

/*QUAKED misc_model (0 0 1) (-16 -16 -16) (16 16 16) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ({"path" : mdl, "skin" : skin, "frame": frame});
}
*/
void() misc_model =
{
	if (!self.mdl)
	{
		objerror("no mdl");
		remove(self);
		return;
	}
	precache_model(self.mdl);
	
	self.movetype = MOVETYPE_NONE;
	if (self.spawnflags & MISC_MODEL_SOLID)
		self.solid = SOLID_BBOX;
	else
		self.solid = SOLID_NOT;	
		
	setmodel(self, self.mdl);
	if (self.pos1 && self.pos2)
		setsize(self, self.pos1, self.pos2);
	else
		setsize(self, '-16 -16 -16', '16 16 16');

	if (!(self.spawnflags & MISC_MODEL_SOLID))
		makestatic(self);
};

// SHAMBLER

/*QUAKED misc_shambler_dead (1 0 0) (-32 -32 -24) (32 32 0) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ({"path":"progs/shambler.mdl","frame":93});
}
Dead Shambler
*/
void() misc_shambler_dead =
{
	self.mdl = "progs/shambler.mdl";
	self.pos1 = '-32 -32 -24';
	self.pos2 = '32 32 0';
	self.frame = 93;
	misc_model();
};

/*QUAKED misc_shambler_head (1 0 0) (-16 -16 0) (16 16 16) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ("progs/h_shams.mdl");
}
Shambler Head
*/
void() misc_shambler_head =
{
	self.mdl = "progs/h_shams.mdl";
	self.pos1 = '-16 -16 0';
	self.pos2 = '16 16 16';
	misc_model();
};

// SOLDIER

/*QUAKED misc_soldier_dead_1 (1 0 0) (-16 -16 -24) (16 16 0) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ({"path":"progs/soldier.mdl","frame":28});
}
Dead Soldier
*/
void() misc_soldier_dead_1 =
{
	self.mdl = "progs/soldier.mdl";
	self.pos1 = '-16 -16 -24';
	self.pos2 = '16 16 0';
	self.frame = 17;
	misc_model();
};

/*QUAKED misc_soldier_dead_2 (1 0 0) (-16 -16 -24) (16 16 0) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ({"path":"progs/soldier.mdl","frame":28});
}
Dead Soldier
*/
void() misc_soldier_dead_2 =
{
	self.mdl = "progs/soldier.mdl";
	self.pos1 = '-16 -16 -24';
	self.pos2 = '16 16 0';
	self.frame = 28;
	misc_model();
};

/*QUAKED misc_soldier_head (1 0 0) (-16 -16 0) (16 16 16) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ("progs/h_guard.mdl");
}
Soldier Head
*/
void() misc_soldier_head =
{
	self.mdl = "progs/h_guard.mdl";
	self.pos1 = '-16 -16 0';
	self.pos2 = '16 16 16';
	misc_model();
};

// WIZARD

/*QUAKED misc_wizard_dead (1 0 0) (-16 -16 -24) (16 16 0) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ({"path":"progs/wizard.mdl","frame":53});
}
Dead Scrag
*/
void() misc_wizard_dead =
{
	self.mdl = "progs/wizard.mdl";
	self.pos1 = '-16 -16 -24';
	self.pos2 = '16 16 0';
	self.frame = 53;
	misc_model();
};

/*QUAKED misc_wizard_head (1 0 0) (-16 -16 0) (16 16 16) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ("progs/h_wizard.mdl");
}
Scrag Head
*/
void() misc_wizard_head =
{
	self.mdl = "progs/h_wizard.mdl";
	self.pos1 = '-16 -16 0';
	self.pos2 = '16 16 16';
	misc_model();
};

// ZOMBIE

/*QUAKED misc_zombie_dead (1 0 0) (-16 -16 -24) (16 16 0) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ({"path":"progs/zombie.mdl","frame":172});
}
Dead Zombie
*/
void() misc_zombie_dead =
{
	self.mdl = "progs/zombie.mdl";
	self.pos1 = '-16 -16 -24';
	self.pos2 = '16 16 0';
	self.frame = 172;
	misc_model();
};

/*QUAKED misc_zombie_head (1 0 0) (-16 -16 0) (16 16 16) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ("progs/h_zombie.mdl");
}
Zombie Head
*/
void() misc_zombie_head =
{
	self.mdl = "progs/h_zombie.mdl";
	self.pos1 = '-16 -16 0';
	self.pos2 = '16 16 16';
	misc_model();
};
