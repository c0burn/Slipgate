
/*==========
powerup_touch
==========*/
void() powerup_touch =
{
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	sprint (other, "You got the ");
	sprint (other, self.netname);
	sprint (other,"\n");

	sound (other, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	
	self.model = string_null;
	self.solid = SOLID_NOT;
	other.items = other.items | self.items;

	// do the apropriate action
	if (self.classname == "item_artifact_envirosuit")
	{
		other.rad_time = 1;
		other.radsuit_finished = time + 30;
	}
	if (self.classname == "item_artifact_invulnerability")
	{
		other.invincible_time = 1;
		other.invincible_finished = time + 30;
	}
	if (self.classname == "item_artifact_invisibility")
	{
		other.invisible_time = 1;
		other.invisible_finished = time + 30;
	}
	if (self.classname == "item_artifact_super_damage")
	{
		other.super_time = 1;
		other.super_damage_finished = time + 30;
	}

	if (deathmatch)
	{
		self.think = ItemRespawn;
		if ((self.classname == "item_artifact_invulnerability") || (self.classname == "item_artifact_invisibility"))
			self.nextthink = time + 300;
		else
			self.nextthink = time + 60;
	}
	
	// fire targets
	activator = other;
	UseTargets();
};

/*QUAKED item_artifact_invulnerability (0 0 1) (-16 -16 -24) (16 16 32) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{	model("progs/invulner.mdl");	}
Pentagram of Protection
Player is invulnerable for 30 seconds
*/
void() item_artifact_invulnerability =
{
	self.touch = powerup_touch;
	precache_model ("progs/invulner.mdl");
	precache_sound ("items/protect.wav");
	precache_sound ("items/protect2.wav");
	precache_sound ("items/protect3.wav");
	self.noise = "items/protect.wav";
	setmodel (self, "progs/invulner.mdl");
	self.netname = "Pentagram of Protection";
	self.items = IT_INVULNERABILITY;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*QUAKED item_artifact_envirosuit (0 0 1) (-16 -16 -24) (16 16 32) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{	model("progs/suit.mdl");	}
Biosuit
Player takes no damage from water or slime for 30 seconds
*/
void() item_artifact_envirosuit =
{
	self.touch = powerup_touch;
	precache_model ("progs/suit.mdl");
	precache_sound ("items/suit.wav");
	precache_sound ("items/suit2.wav");
	self.noise = "items/suit.wav";
	setmodel (self, "progs/suit.mdl");
	self.netname = "Biosuit";
	self.items = IT_SUIT;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*QUAKED item_artifact_invisibility (0 0 1) (-16 -16 -24) (16 16 32) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{	model("progs/invisibl.mdl");	}
Ring of Shadows
Player is invisible for 30 seconds
*/
void() item_artifact_invisibility =
{
	self.touch = powerup_touch;
	precache_model ("progs/invisibl.mdl");
	precache_sound ("items/inv1.wav");
	precache_sound ("items/inv2.wav");
	precache_sound ("items/inv3.wav");
	self.noise = "items/inv1.wav";
	setmodel (self, "progs/invisibl.mdl");
	self.netname = "Ring of Shadows";
	self.items = IT_INVISIBILITY;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};

/*QUAKED item_artifact_super_damage (0 0 1) (-16 -16 -24) (16 16 32) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{	model("progs/quaddama.mdl");	}
Quad Damage
Player does 4x damage for 30 seconds
*/
void() item_artifact_super_damage =
{
	self.touch = powerup_touch;
	precache_model ("progs/quaddama.mdl");
	precache_sound ("items/damage.wav");
	precache_sound ("items/damage2.wav");
	precache_sound ("items/damage3.wav");
	self.noise = "items/damage.wav";
	setmodel (self, "progs/quaddama.mdl");
	self.netname = "Quad Damage";
	self.items = IT_QUAD;
	setsize (self, '-16 -16 -24', '16 16 32');
	StartItem ();
};