/*
==============================================================================

SHAL-RATH

==============================================================================
*/
$cd id1/models/shalrath
$origin 0 0 24
$base base
$skin skin
$scale 0.7

$frame attack1 attack2 attack3 attack4 attack5 attack6 attack7 attack8
$frame attack9 attack10 attack11

$frame pain1 pain2 pain3 pain4 pain5 

$frame death1 death2 death3 death4 death5 death6 death7

$frame	idle1 idle2 idle3 idle4 idle5 idle6 idle7 idle8 idle9

$frame	walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10
$frame	walk11 walk12

void(entity attacker, float damage) shalrath_pain;

void() ShalMissile;

void() shal_stand1     =[      $idle1,       shal_stand2    ] {ai_stand();};
void() shal_stand2     =[      $idle2,       shal_stand3    ] {ai_stand();};
void() shal_stand3     =[      $idle3,       shal_stand4    ] {ai_stand();};
void() shal_stand4     =[      $idle4,       shal_stand5    ] {ai_stand();};
void() shal_stand5     =[      $idle5,       shal_stand6    ] {ai_stand();};
void() shal_stand6     =[      $idle6,       shal_stand7    ] {ai_stand();};
void() shal_stand7     =[      $idle7,       shal_stand8    ] {ai_stand();};
void() shal_stand8     =[      $idle8,       shal_stand9    ] {ai_stand();};
void() shal_stand9     =[      $idle9,       shal_stand1    ] {ai_stand();};

void() shal_walk1    =[      $walk1,       shal_walk2    ] {ai_walk(5);};
void() shal_walk2     =[      $walk2,       shal_walk3    ] {if (random() < 0.2) sound (self, CHAN_VOICE, "shalrath/idle.wav", 1, ATTN_IDLE);ai_walk(6);};
void() shal_walk3     =[      $walk3,       shal_walk4    ] {ai_walk(4);};
void() shal_walk4     =[      $walk4,       shal_walk5    ] {ai_walk(0);};
void() shal_walk5     =[      $walk5,       shal_walk6    ] {ai_walk(0);};
void() shal_walk6     =[      $walk6,       shal_walk7    ] {ai_walk(0);};
void() shal_walk7     =[      $walk7,       shal_walk8    ] {ai_walk(0);};
void() shal_walk8     =[      $walk8,       shal_walk9    ] {ai_walk(5);};
void() shal_walk9     =[      $walk9,       shal_walk10    ] {ai_walk(6);};
void() shal_walk10    =[      $walk10,       shal_walk11    ] {ai_walk(5);};
void() shal_walk11    =[      $walk11,       shal_walk12    ] {ai_walk(0);};
void() shal_walk12    =[      $walk12,       shal_walk1    ] {ai_walk(4);};

void() shal_run1    =[      $walk1,       shal_run2    ] {ai_run(5);};
void() shal_run2     =[      $walk2,       shal_run3    ] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "shalrath/idle.wav", 1, ATTN_IDLE);
ai_run(6);};
void() shal_run3     =[      $walk3,       shal_run4    ] {ai_run(4);};
void() shal_run4     =[      $walk4,       shal_run5    ] {ai_run(0);};
void() shal_run5     =[      $walk5,       shal_run6    ] {ai_run(0);};
void() shal_run6     =[      $walk6,       shal_run7    ] {ai_run(0);};
void() shal_run7     =[      $walk7,       shal_run8    ] {ai_run(0);};
void() shal_run8     =[      $walk8,       shal_run9    ] {ai_run(5);};
void() shal_run9     =[      $walk9,       shal_run10    ] {ai_run(6);};
void() shal_run10     =[      $walk10,       shal_run11    ] {ai_run(5);};
void() shal_run11    =[      $walk11,       shal_run12    ] {ai_run(0);};
void() shal_run12    =[      $walk12,       shal_run1    ] {ai_run(4);};


void() shal_attack1     =[      $attack1,       shal_attack2    ] {
sound (self, CHAN_VOICE, "shalrath/attack.wav", 1, ATTN_NORM);
ai_face();
};
void() shal_attack2     =[      $attack2,       shal_attack3    ] {ai_face();};
void() shal_attack3     =[      $attack3,       shal_attack4    ] {ai_face();};
void() shal_attack4     =[      $attack4,       shal_attack5    ] {ai_face();};
void() shal_attack5     =[      $attack5,       shal_attack6    ] {ai_face();};
void() shal_attack6     =[      $attack6,       shal_attack7    ] {ai_face();};
void() shal_attack7     =[      $attack7,       shal_attack8    ] {ai_face();};
void() shal_attack8     =[      $attack8,       shal_attack9    ] {ai_face();};
void() shal_attack9     =[      $attack9,       shal_attack10   ] {ShalMissile();};
void() shal_attack10    =[      $attack10,      shal_attack11   ] {ai_face();};
void() shal_attack11    =[      $attack11,      shal_run1   ] {};

void() shal_pain1       =[      $pain1, shal_pain2      ] {};
void() shal_pain2       =[      $pain2, shal_pain3      ] {};
void() shal_pain3       =[      $pain3, shal_pain4      ] {};
void() shal_pain4       =[      $pain4, shal_pain5      ] {};
void() shal_pain5       =[      $pain5, shal_run1      ] {};

void() shal_death1      =[      $death1,        shal_death2     ] {};
void() shal_death2      =[      $death2,        shal_death3     ] {};
void() shal_death3      =[      $death3,        shal_death4     ] {};
void() shal_death4      =[      $death4,        shal_death5     ] {};
void() shal_death5      =[      $death5,        shal_death6     ] {};
void() shal_death6      =[      $death6,        shal_death7     ] {};
void() shal_death7      =[      $death7,        shal_death7    ] {};

void(entity attacker, float damage) shalrath_pain =
{
	if (self.pain_finished > time)
		return;
	sound (self, CHAN_VOICE, "shalrath/pain.wav", 1, ATTN_NORM);
	self.pain_finished = time + 3;
	shal_pain1();
};

void(entity inflictor, entity attacker) shalrath_die =
{
	// check for gib
	if (self.health < -90)
	{
		SpawnGib("progs/gib3.mdl");
		SpawnGib("progs/gib4.mdl");
		SpawnGib("progs/gib5.mdl");
		BecomeGibs();
		return;
	}
	
	// regular death
	sound (self, CHAN_VOICE, "shalrath/death.wav", 1, ATTN_NORM);
	self.solid = SOLID_NOT;
	shal_death1();
};

/*
================
ShalMissile
================
*/
void() ShalMissileTouch;
void() ShalHome;
void() ShalMissile =
{
	local	entity 	missile;
	local	vector	dir;
	local	float	dist, flytime;

	dir = normalize((self.enemy.origin + '0 0 10') - self.origin);
	dist = vlen (self.enemy.origin - self.origin);
	flytime = dist * 0.002;
	if (flytime < 0.1)
		flytime = 0.1;

	self.effects = self.effects | EF_MUZZLEFLASH;
	sound (self, CHAN_WEAPON, "shalrath/attack2.wav", 1, ATTN_NORM);

	missile = spawn ();
	missile.owner = self;

	missile.solid = SOLID_BBOX;
	missile.movetype = MOVETYPE_FLYMISSILE;
	setmodel (missile, "progs/v_spike.mdl");
	setsize (missile, '0 0 0', '0 0 0');		

	missile.origin = self.origin + '0 8 20';
	missile.velocity = dir * 400;
	missile.avelocity = '300 300 300';
	
	missile.think = ShalHome;
	missile.nextthink = time + flytime;
	
	missile.enemy = self.enemy;
	missile.touch = ShalMissileTouch;
};

void() ShalHome =
{
	if (self.enemy.health <= 0)
		return;
	if (self.owner.health <= 0 && skill < 2)
		return;
		
	vector dir = normalize(self.enemy.origin + '0 0 10' - self.origin);
	if (skill == 3)
		self.velocity = dir * 350;
	else
		self.velocity = dir * 250;

	self.nextthink = time + 0.2;
	self.think = ShalHome;	
};

void() ShalMissileTouch =
{		
	RadiusDamage (self, self.owner, 40, world);
	te_tarexplosion(self.origin);
	remove(self);
};

//=================================================================

/*QUAKED monster_shalrath (1 0 0) (-32 -32 -24) (32 32 48) Ambush
{
	model ({ "path" : "progs/shalrath.mdl",	"frame": 23 });
}
Vore.
"A spideresque hybrid horror. Keep your eye on the energy pod he hurls."
*/
void() monster_shalrath =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model2 ("progs/shalrath.mdl");
	precache_model2 ("progs/h_shal.mdl");
	precache_model2 ("progs/v_spike.mdl");
	
	precache_sound2 ("shalrath/attack.wav");
	precache_sound2 ("shalrath/attack2.wav");
	precache_sound2 ("shalrath/death.wav");
	precache_sound2 ("shalrath/idle.wav");
	precache_sound2 ("shalrath/pain.wav");
	precache_sound2 ("shalrath/sight.wav");

	self.th_stand = shal_stand1;
	self.th_walk = shal_walk1;
	self.th_run = shal_run1;
	self.th_die = shalrath_die;
	self.th_pain = shalrath_pain;
	self.th_missile = shal_attack1;

	monster_start("progs/shalrath.mdl", "progs/h_shal.mdl", 400, 0, VEC_HULL2_MIN, VEC_HULL2_MAX);
};
