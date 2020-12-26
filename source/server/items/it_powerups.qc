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

	if (deathmatch || self.spawnflags & ITEM_RESPAWN)
	{
		self.think = ItemRespawn;
		self.nextthink = time + self.teleport_time;
	}
	
	// fire targets
	activator = other;
	UseTargets();
};

/*===========
powerup_start
==========*/
static void(string mod, string snd, string name, float it, float respawn) powerup_start =
{
	precache_model (mod);
	setmodel (self, mod);
	precache_sound (snd);
	self.noise = snd;
	SetPositiveDefault(teleport_time, respawn);
	self.netname = name;
	self.items = it;
	setsize (self, '-16 -16 -24', '16 16 32');
	self.touch = powerup_touch;
	StartItem();
};

/*QUAKED item_artifact_invulnerability (0 0 1) (-16 -16 -24) (16 16 32) X X X X DONT_DROP RESPAWN X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{	model("progs/invulner.mdl");	}
Pentagram of Protection
Player is invulnerable for 30 seconds
*/
void() item_artifact_invulnerability =
{
	powerup_start("progs/invulner.mdl", "items/protect.wav", "Pentagram of Protection", IT_INVULNERABILITY, 300);
};

/*QUAKED item_artifact_envirosuit (0 0 1) (-16 -16 -24) (16 16 32) X X X X DONT_DROP RESPAWN X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{	model("progs/suit.mdl");	}
Biosuit
Player takes no damage from water or slime for 30 seconds
*/
void() item_artifact_envirosuit =
{
	powerup_start("progs/suit.mdl", "items/suit.wav", "Biosuit", IT_SUIT, 60);
};

/*QUAKED item_artifact_invisibility (0 0 1) (-16 -16 -24) (16 16 32) X X X X DONT_DROP RESPAWN X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{	model("progs/invisibl.mdl");	}
Ring of Shadows
Player is invisible for 30 seconds
*/
void() item_artifact_invisibility =
{
	powerup_start("progs/invisibl.mdl", "items/inv1.wav", "Ring of Shadows", IT_INVISIBILITY, 300);
};

/*QUAKED item_artifact_super_damage (0 0 1) (-16 -16 -24) (16 16 32) X X X X DONT_DROP RESPAWN X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{	model("progs/quaddama.mdl");	}
Quad Damage
Player does 4x damage for 30 seconds
*/
void() item_artifact_super_damage =
{
	powerup_start("progs/quaddama.mdl", "items/damage.wav", "Quad Damage", IT_QUAD, 60);
};
