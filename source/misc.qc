enumflags { MISC_MODEL_SOLID };

/*QUAKED misc_model (0 0 1) (-16 -16 -16) (16 16 16) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ({"path" : mdl, "skin" : skin, "frame": frame});
}
Custom map object. Non-solid by default.

"mdl" "name" - model to load, e.g. "progs/grenade.mdl". Will also work on .bsp and .spr
"pos1", "pos2" "vector" - bounding box size. if not defined it will default to '-16 -16 -16', '16 16 16'
"skin" "n" - model or sprite skin
"frame" "n" - model or sprite frame

==========
Spawnflags
==========
1 - Object is solid
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

/*QUAKED misc_demon_dead (1 0 0) (-32 -32 -24) (32 32 0) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ({"path":"progs/demon.mdl","frame":53});
}
Dead Fiend
*/
void() misc_demon_dead =
{
	self.mdl = "progs/demon.mdl";
	self.pos1 = '-32 -32 -24';
	self.pos2 = '32 32 0';
	self.frame = 53;
	misc_model();	
};

/*QUAKED misc_demon_head (1 0 0) (-16 -16 0) (16 16 16) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ("progs/h_demon.mdl");
}
Fiend Head
*/
void() misc_demon_head =
{
	self.mdl = "progs/h_demon.mdl";
	self.pos1 = '-16 -16 0';
	self.pos2 = '16 16 16';
	misc_model();
};

/*QUAKED misc_dog_dead_1 (1 0 0) (-16 -16 -24) (16 16 0) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ({"path":"progs/dog.mdl","frame":16});
}
Dead dog
*/
void() misc_dog_dead_1 =
{
	self.mdl = "progs/dog.mdl";
	self.pos1 = '-16 -16 -24';
	self.pos2 = '16 16 0';
	self.frame = 16;
	misc_model();
};

/*QUAKED misc_dog_dead_2 (1 0 0) (-16 -16 -24) (16 16 0) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ({"path":"progs/dog.mdl","frame":25});
}
Dead dog
*/
void() misc_dog_dead_2 =
{
	self.mdl = "progs/dog.mdl";
	self.pos1 = '-16 -16 -24';
	self.pos2 = '16 16 0';
	self.frame = 25;
	misc_model();
};

/*QUAKED misc_dog_head (1 0 0) (-16 -16 0) (16 16 16) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ("progs/h_dog.mdl");
}
dog Head
*/
void() misc_dog_head =
{
	self.mdl = "progs/h_dog.mdl";
	self.pos1 = '-16 -16 0';
	self.pos2 = '16 16 16';
	misc_model();
};

/*QUAKED misc_enforcer_dead_1 (1 0 0) (-16 -16 -24) (16 16 0) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ({"path":"progs/enforcer.mdl","frame":54});
}
Dead Enforcer
*/
void() misc_enforcer_dead_1 =
{
	self.mdl = "progs/enforcer.mdl";
	self.pos1 = '-16 -16 -24';
	self.pos2 = '16 16 0';
	self.frame = 54;
	misc_model();
};

/*QUAKED misc_enforcer_dead_2 (1 0 0) (-16 -16 -24) (16 16 0) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ({"path":"progs/enforcer.mdl","frame":65});
}
Dead Enforcer
*/
void() misc_enforcer_dead_2 =
{
	self.mdl = "progs/enforcer.mdl";
	self.pos1 = '-16 -16 -24';
	self.pos2 = '16 16 0';
	self.frame = 65;
	misc_model();
};

/*QUAKED misc_enforcer_head (1 0 0) (-16 -16 0) (16 16 16) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ("progs/h_mega.mdl");
}
Enforcer Head
*/
void() misc_enforcer_head =
{
	self.mdl = "progs/h_mega.mdl";
	self.pos1 = '-16 -16 0';
	self.pos2 = '16 16 16';
	misc_model();
};

/*QUAKED misc_fish_dead (1 0 0) (-16 -16 -24) (16 16 0) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ({"path":"progs/fish.mdl","frame":38});
}
Dead Fish
*/
void() misc_fish_dead =
{
	self.mdl = "progs/fish.mdl";
	self.pos1 = '-16 -16 -24';
	self.pos2 = '16 16 0';
	self.frame = 38;
	misc_model();
};

/*QUAKED misc_hknight_dead_1 (1 0 0) (-16 -16 -24) (16 16 0) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ({"path":"progs/hknight.mdl","frame":53});
}
Dead Death Knight
*/
void() misc_hknight_dead_1 =
{
	self.mdl = "progs/knight.mdl";
	self.pos1 = '-16 -16 -24';
	self.pos2 = '16 16 0';
	self.frame = 53;
	misc_model();
};

/*QUAKED misc_hknight_dead_2 (1 0 0) (-16 -16 -24) (16 16 0) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ({"path":"progs/hknight.mdl","frame":62});
}
Dead Death Knight
*/
void() misc_hknight_dead_2 =
{
	self.mdl = "progs/hknight.mdl";
	self.pos1 = '-16 -16 -24';
	self.pos2 = '16 16 0';
	self.frame = 62;
	misc_model();
};

/*QUAKED misc_hknight_head (1 0 0) (-16 -16 0) (16 16 16) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ("progs/h_hellkn.mdl");
}
Death Knight Head
*/
void() misc_hknight_head =
{
	self.mdl = "progs/h_hellkn.mdl";
	self.pos1 = '-16 -16 0';
	self.pos2 = '16 16 16';
	misc_model();
};

/*QUAKED misc_knight_dead_1 (1 0 0) (-16 -16 -24) (16 16 0) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ({"path":"progs/knight.mdl","frame":85});
}
Dead Knight
*/
void() misc_knight_dead_1 =
{
	self.mdl = "progs/knight.mdl";
	self.pos1 = '-16 -16 -24';
	self.pos2 = '16 16 0';
	self.frame = 85;
	misc_model();
};

/*QUAKED misc_knight_dead_2 (1 0 0) (-16 -16 -24) (16 16 0) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ({"path":"progs/knight.mdl","frame":96});
}
Dead Knight
*/
void() misc_knight_dead_2 =
{
	self.mdl = "progs/knight.mdl";
	self.pos1 = '-16 -16 -24';
	self.pos2 = '16 16 0';
	self.frame = 96;
	misc_model();
};

/*QUAKED misc_knight_head (1 0 0) (-16 -16 0) (16 16 16) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ("progs/h_knight.mdl");
}
Knight Head
*/
void() misc_knight_head =
{
	self.mdl = "progs/h_knight.mdl";
	self.pos1 = '-16 -16 0';
	self.pos2 = '16 16 16';
	misc_model();
};

/*QUAKED misc_ogre_dead_1 (1 0 0) (-32 -32 -24) (32 32 0) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ({"path":"progs/ogre.mdl","frame":125});
}
Dead Ogre
*/
void() misc_ogre_dead_1 =
{
	self.mdl = "progs/ogre.mdl";
	self.pos1 = '-32 -32 -24';
	self.pos2 = '32 32 0';
	self.frame = 125;
	misc_model();
};

/*QUAKED misc_ogre_dead_2 (1 0 0) (-32 -32 -24) (32 32 0) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ({"path":"progs/ogre.mdl","frame":135});
}
Dead Ogre
*/
void() misc_ogre_dead_2 =
{
	self.mdl = "progs/ogre.mdl";
	self.pos1 = '-32 -32 -24';
	self.pos2 = '32 32 0';
	self.frame = 135;
	misc_model();
};

/*QUAKED misc_ogre_head (1 0 0) (-16 -16 0) (16 16 16) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ("progs/h_ogre.mdl");
}
Ogre Head
*/
void() misc_ogre_head =
{
	self.mdl = "progs/h_ogre.mdl";
	self.pos1 = '-16 -16 0';
	self.pos2 = '16 16 16';
	misc_model();
};

/*QUAKED misc_shalrath_dead (1 0 0) (-32 -32 -24) (32 32 0) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ({"path":"progs/shalrath.mdl","frame":22});
}
Dead Vore
*/
void() misc_shalrath_dead =
{
	self.mdl = "progs/shalrath.mdl";
	self.pos1 = '-32 -32 -24';
	self.pos2 = '32 32 0';
	self.frame = 22;
	misc_model();
};

/*QUAKED misc_shalrath_head (1 0 0) (-16 -16 0) (16 16 16) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ("progs/h_shal.mdl");
}
Vore Head
*/
void() misc_shalrath_head =
{
	self.mdl = "progs/h_shal.mdl";
	self.pos1 = '-16 -16 0';
	self.pos2 = '16 16 16';
	misc_model();
};

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

/*QUAKED misc_soldier_dead_1 (1 0 0) (-16 -16 -24) (16 16 0) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ({"path":"progs/soldier.mdl","frame":28});
}
Dead Grunt
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
Dead Grunt
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
Grunt Head
*/
void() misc_soldier_head =
{
	self.mdl = "progs/h_guard.mdl";
	self.pos1 = '-16 -16 0';
	self.pos2 = '16 16 16';
	misc_model();
};

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
