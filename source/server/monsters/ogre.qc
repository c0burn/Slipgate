$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7
$frame walk8 walk9 walk10 walk11 walk12 walk13 walk14 walk15 walk16

$frame run1 run2 run3 run4 run5 run6 run7 run8

$frame swing1 swing2 swing3 swing4 swing5 swing6 swing7
$frame swing8 swing9 swing10 swing11 swing12 swing13 swing14

$frame smash1 smash2 smash3 smash4 smash5 smash6 smash7
$frame smash8 smash9 smash10 smash11 smash12 smash13 smash14

$frame shoot1 shoot2 shoot3 shoot4 shoot5 shoot6

$frame pain1 pain2 pain3 pain4 pain5

$frame painb1 painb2 painb3

$frame painc1 painc2 painc3 painc4 painc5 painc6

$frame paind1 paind2 paind3 paind4 paind5 paind6 paind7 paind8 paind9 paind10
$frame paind11 paind12 paind13 paind14 paind15 paind16

$frame paine1 paine2 paine3 paine4 paine5 paine6 paine7 paine8 paine9 paine10
$frame paine11 paine12 paine13 paine14 paine15

$frame death1 death2 death3 death4 death5 death6
$frame death7 death8 death9 death10 death11 death12
$frame death13 death14

$frame bdeath1 bdeath2 bdeath3 bdeath4 bdeath5 bdeath6
$frame bdeath7 bdeath8 bdeath9 bdeath10

$frame pull1 pull2 pull3 pull4 pull5 pull6 pull7 pull8 pull9 pull10 pull11

#define OGRE_G_VEL				600
#define OGRE_DEFAULT_ELEVATION	45

/*==========
OgreGrenadeExplode
==========*/
void() OgreGrenadeExplode =
{
	RadiusDamage(self, self.owner, 40, world);
	te_explosion(self.origin);
	BecomeExplosion();
};

/*==========
OgreGrenadeTouch
==========*/
void() OgreGrenadeTouch =
{
	if (other.takedamage == DAMAGE_AIM)
	{
		OgreGrenadeExplode();
		return;
	}
	sound(self, CHAN_VOICE, "weapons/bounce.wav", 1, ATTN_NORM);
};

/*==========
OgreIterateElevation
==========*/
float(float theta, vector dest, vector org) OgreIterateElevation =
{
	vector ofs = dest - org;
	float z = ofs_z;
	ofs_z = 0;
	float y = vlen(ofs);
	
	float a = 0.5 * sv_gravity * y * y / (OGRE_G_VEL * OGRE_G_VEL);
	float b = -y;
	float c = a + z;

	// can't reach target
	if (b * b < 4 * a * c)
	{
		dprint("OGRE_DEFAULT_ELEVATION\n");
		return OGRE_DEFAULT_ELEVATION;
	}

	float tan_theta = tan(theta);
	theta = atan2(a * tan_theta * tan_theta - c, 2 * a * tan_theta + b);

	while (theta > 90)
		theta = theta - 180;
	return theta;
};

/*==========
OgreFireGrenade
==========*/
void(float spam) OgreFireGrenade =
{
	self.effects = self.effects | EF_MUZZLEFLASH;
	
	sound (self, CHAN_WEAPON, "weapons/grenade.wav", 1, ATTN_NORM);

	vector org = self.origin;

	entity missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_BBOX;
	
	setmodel (missile, "progs/grenade.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, org);
	
	// chose where to aim
	vector dest;
	// aim at last known enemy location
	if (spam)
	{
		dest = self.enemy_last;
		spawn_debug_marker(dest);
	}
	// aim at enemy
	else
	{
		// lead player on hard
		/*if (skill > 1)
		{
			vector ofs = self.enemy.origin + self.enemy.view_ofs - org;
			float t = vlen(ofs) / OGRE_G_VEL;
			vector vel = self.enemy.velocity;
			vel_z = 0;
			dest = self.enemy.origin + self.enemy.view_ofs + (t * vel);
		}
		// aim at enemy position
		else
		*/
		dest = self.enemy.origin + self.enemy.view_ofs;
	}
	float elevation = OgreIterateElevation(OGRE_DEFAULT_ELEVATION, dest, org);
	elevation = OgreIterateElevation(elevation, dest, org);
	elevation = OgreIterateElevation(elevation, dest, org);
	elevation = OgreIterateElevation(elevation, dest, org);
	
	vector ang = normalize(dest - org);
	ang = vectoangles(ang);
	ang_x = -elevation;
	makevectors(ang);

	missile.velocity = v_forward * OGRE_G_VEL;
	missile.avelocity = '300 300 300';
	missile.angles = vectoangles(missile.velocity);
	missile.touch = OgreGrenadeTouch;

	missile.nextthink = time + 2.5;
	missile.think = OgreGrenadeExplode;
};

void() ogre_grenade1	=[	$shoot1,	ogre_grenade2	] {ai_face();};
void() ogre_grenade2	=[	$shoot2,	ogre_grenade3	] {ai_face();};
void() ogre_grenade3	=[	$shoot2,	ogre_grenade4	] {ai_face();};
void() ogre_grenade4	=[	$shoot3,	ogre_grenade5	] {ai_face();OgreFireGrenade(FALSE);};
void() ogre_grenade5	=[	$shoot4,	ogre_grenade6	] {ai_face();};
void() ogre_grenade6	=[	$shoot5,	ogre_grenade7	] {ai_face();};
void() ogre_grenade7	=[	$shoot6,	ogre_run1		] {ai_face();};

void() ogre_spam1	=[	$shoot1,	ogre_spam2	] {ai_face_last();};
void() ogre_spam2	=[	$shoot2,	ogre_spam3	] {ai_face_last();};
void() ogre_spam3	=[	$shoot2,	ogre_spam4	] {ai_face_last();};
void() ogre_spam4	=[	$shoot3,	ogre_spam5	] {ai_face_last();OgreFireGrenade(TRUE);};
void() ogre_spam5	=[	$shoot4,	ogre_spam6	] {ai_face_last();};
void() ogre_spam6	=[	$shoot5,	ogre_spam7	] {ai_face_last();};
void() ogre_spam7	=[	$shoot6,	ogre_run1	] {ai_face_last();};

/*==========
OgreChainsaw
==========*/
void() OgreChainsaw =
{
	float delta = vlen(self.enemy.origin - self.origin);
	if (delta > 100)
		return;
	if (!CanDamage(self.enemy, self))
		return;

	float ldmg = (random() + random() + random()) * 4;
	Damage (self.enemy, self, self, ldmg);

	SpawnBlood(trace_endpos, randomvec() * 8, 12);
	if (random() < 0.1)
	{
		makevectors (self.angles);
		if (random() < 0.5)
			SpawnMeatSpray (self.origin + v_forward*16, v_right * 200 + v_up * 50);
		else
			SpawnMeatSpray (self.origin + v_forward*16, v_up * 50 - v_right * 200);
	}
};

void() ogre_swing1	=[	$swing1,		ogre_swing2	] {ai_charge(11);};
void() ogre_swing2	=[	$swing2,		ogre_swing3	] {ai_charge(1);};
void() ogre_swing3	=[	$swing3,		ogre_swing4	] {ai_charge(4);};
void() ogre_swing4	=[	$swing4,		ogre_swing5	] {ai_charge(13);};
void() ogre_swing5	=[	$swing5,		ogre_swing6	] {ai_charge(19);OgreChainsaw();};
void() ogre_swing6	=[	$swing6,		ogre_swing7	] {ai_charge(10);OgreChainsaw();};
void() ogre_swing7	=[	$swing7,		ogre_swing8	] {ai_charge(10);OgreChainsaw();};
void() ogre_swing8	=[	$swing8,		ogre_swing9	] {ai_charge(10);OgreChainsaw();};
void() ogre_swing9	=[	$swing9,		ogre_swing10] {ai_charge(10);OgreChainsaw();};
void() ogre_swing10	=[	$swing10,		ogre_swing11] {ai_charge(10);OgreChainsaw();};
void() ogre_swing11	=[	$swing11,		ogre_swing12] {ai_charge(10);OgreChainsaw();};
void() ogre_swing12	=[	$swing12,		ogre_swing13] {ai_charge(3);};
void() ogre_swing13	=[	$swing13,		ogre_swing14] {ai_charge(8);};
void() ogre_swing14	=[	$swing14,		ogre_run1	] {ai_charge(9);};

void() ogre_smash1	=[	$smash1,		ogre_smash2	] {ai_charge(6);};
void() ogre_smash2	=[	$smash2,		ogre_smash3	] {ai_charge(0);};
void() ogre_smash3	=[	$smash3,		ogre_smash4	] {ai_charge(0);};
void() ogre_smash4	=[	$smash4,		ogre_smash5	] {ai_charge(1);};
void() ogre_smash5	=[	$smash5,		ogre_smash6	] {ai_charge(4);};
void() ogre_smash6	=[	$smash6,		ogre_smash7	] {ai_charge(14);OgreChainsaw();};
void() ogre_smash7	=[	$smash7,		ogre_smash8	] {ai_charge(14);OgreChainsaw();};
void() ogre_smash8	=[	$smash8,		ogre_smash9	] {ai_charge(20);OgreChainsaw();};
void() ogre_smash9	=[	$smash9,		ogre_smash10] {ai_charge(23);OgreChainsaw();};
void() ogre_smash10	=[	$smash10,		ogre_smash11] {ai_charge(10);OgreChainsaw();};
void() ogre_smash11	=[	$smash11,		ogre_smash12]
{
	ai_charge(12);
	OgreChainsaw();
	self.nextthink = self.nextthink + random()*0.2;
};
void() ogre_smash12	=[	$smash12,		ogre_smash13	] {ai_charge(0);};
void() ogre_smash13	=[	$smash13,		ogre_smash14	] {ai_charge(4);};
void() ogre_smash14	=[	$smash14,		ogre_run1		] {ai_charge(12);};

/*==========
ogre_melee
==========*/
void() ogre_melee =
{
	sound (self, CHAN_WEAPON, "ogre/ogsawatk.wav", 1, ATTN_NORM);
	if (random() < 0.5)
		ogre_smash1();
	else
		ogre_swing1();
};

void() ogre_stand1	=[	$stand1,	ogre_stand2	] {ai_stand();};
void() ogre_stand2	=[	$stand2,	ogre_stand3	] {ai_stand();};
void() ogre_stand3	=[	$stand3,	ogre_stand4	] {ai_stand();};
void() ogre_stand4	=[	$stand4,	ogre_stand5	] {ai_stand();};
void() ogre_stand5	=[	$stand5,	ogre_stand6	] {
if (random() < 0.2)
	sound (self, CHAN_VOICE, "ogre/ogidle.wav", 1, ATTN_IDLE);
ai_stand();
};
void() ogre_stand6	=[	$stand6,	ogre_stand7	] {ai_stand();};
void() ogre_stand7	=[	$stand7,	ogre_stand8	] {ai_stand();};
void() ogre_stand8	=[	$stand8,	ogre_stand9	] {ai_stand();};
void() ogre_stand9	=[	$stand9,	ogre_stand1	] {ai_stand();};

void() ogre_walk1	=[	$walk1,		ogre_walk2	] {ai_walk(3);};
void() ogre_walk2	=[	$walk2,		ogre_walk3	] {ai_walk(2);};
void() ogre_walk3	=[	$walk3,		ogre_walk4	] {ai_walk(2);
if (random() < 0.2)
	sound (self, CHAN_VOICE, "ogre/ogidle.wav", 1, ATTN_IDLE);
};
void() ogre_walk4	=[	$walk4,		ogre_walk5	] {ai_walk(2);};
void() ogre_walk5	=[	$walk5,		ogre_walk6	] {ai_walk(2);};
void() ogre_walk6	=[	$walk6,		ogre_walk7	] {ai_walk(5);
if (random() < 0.1)
	sound (self, CHAN_VOICE, "ogre/ogdrag.wav", 1, ATTN_IDLE);
};
void() ogre_walk7	=[	$walk7,		ogre_walk8	] {ai_walk(3);};
void() ogre_walk8	=[	$walk8,		ogre_walk9	] {ai_walk(2);};
void() ogre_walk9	=[	$walk9,		ogre_walk10	] {ai_walk(3);};
void() ogre_walk10	=[	$walk10,	ogre_walk11	] {ai_walk(1);};
void() ogre_walk11	=[	$walk11,	ogre_walk12	] {ai_walk(2);};
void() ogre_walk12	=[	$walk12,	ogre_walk13	] {ai_walk(3);};
void() ogre_walk13	=[	$walk13,	ogre_walk14	] {ai_walk(3);};
void() ogre_walk14	=[	$walk14,	ogre_walk15	] {ai_walk(3);};
void() ogre_walk15	=[	$walk15,	ogre_walk16	] {ai_walk(3);};
void() ogre_walk16	=[	$walk16,	ogre_walk1	] {ai_walk(4);};

void() ogre_run1	=[	$run1,		ogre_run2	] {ai_run(9);
if (random() < 0.2)
	sound (self, CHAN_VOICE, "ogre/ogidle2.wav", 1, ATTN_IDLE);
};
void() ogre_run2	=[	$run2,		ogre_run3	] {ai_run(12);};
void() ogre_run3	=[	$run3,		ogre_run4	] {ai_run(8);};
void() ogre_run4	=[	$run4,		ogre_run5	] {ai_run(22);};
void() ogre_run5	=[	$run5,		ogre_run6	] {ai_run(16);};
void() ogre_run6	=[	$run6,		ogre_run7	] {ai_run(4);};
void() ogre_run7	=[	$run7,		ogre_run8	] {ai_run(13);};
void() ogre_run8	=[	$run8,		ogre_run1	] {ai_run(24);};

void()	ogre_pain1	=[	$pain1,		ogre_pain2	] {};
void()	ogre_pain2	=[	$pain2,		ogre_pain3	] {};
void()	ogre_pain3	=[	$pain3,		ogre_pain4	] {};
void()	ogre_pain4	=[	$pain4,		ogre_pain5	] {};
void()	ogre_pain5	=[	$pain5,		ogre_run1	] {};

void()	ogre_painb1	=[	$painb1,	ogre_painb2	] {};
void()	ogre_painb2	=[	$painb2,	ogre_painb3	] {};
void()	ogre_painb3	=[	$painb3,	ogre_run1	] {};

void()	ogre_painc1	=[	$painc1,	ogre_painc2	] {};
void()	ogre_painc2	=[	$painc2,	ogre_painc3	] {};
void()	ogre_painc3	=[	$painc3,	ogre_painc4	] {};
void()	ogre_painc4	=[	$painc4,	ogre_painc5	] {};
void()	ogre_painc5	=[	$painc5,	ogre_painc6	] {};
void()	ogre_painc6	=[	$painc6,	ogre_run1	] {};

void()	ogre_paind1	=[	$paind1,	ogre_paind2	] {};
void()	ogre_paind2	=[	$paind2,	ogre_paind3	] {ai_pain(10);};
void()	ogre_paind3	=[	$paind3,	ogre_paind4	] {ai_pain(9);};
void()	ogre_paind4	=[	$paind4,	ogre_paind5	] {ai_pain(4);};
void()	ogre_paind5	=[	$paind5,	ogre_paind6	] {};
void()	ogre_paind6	=[	$paind6,	ogre_paind7	] {};
void()	ogre_paind7	=[	$paind7,	ogre_paind8	] {};
void()	ogre_paind8	=[	$paind8,	ogre_paind9	] {};
void()	ogre_paind9	=[	$paind9,	ogre_paind10] {};
void()	ogre_paind10=[	$paind10,	ogre_paind11] {};
void()	ogre_paind11=[	$paind11,	ogre_paind12] {};
void()	ogre_paind12=[	$paind12,	ogre_paind13] {};
void()	ogre_paind13=[	$paind13,	ogre_paind14] {};
void()	ogre_paind14=[	$paind14,	ogre_paind15] {};
void()	ogre_paind15=[	$paind15,	ogre_paind16] {};
void()	ogre_paind16=[	$paind16,	ogre_run1	] {};

void()	ogre_paine1	=[	$paine1,	ogre_paine2	] {};
void()	ogre_paine2	=[	$paine2,	ogre_paine3	] {ai_pain(10);};
void()	ogre_paine3	=[	$paine3,	ogre_paine4	] {ai_pain(9);};
void()	ogre_paine4	=[	$paine4,	ogre_paine5	] {ai_pain(4);};
void()	ogre_paine5	=[	$paine5,	ogre_paine6	] {};
void()	ogre_paine6	=[	$paine6,	ogre_paine7	] {};
void()	ogre_paine7	=[	$paine7,	ogre_paine8	] {};
void()	ogre_paine8	=[	$paine8,	ogre_paine9	] {};
void()	ogre_paine9	=[	$paine9,	ogre_paine10] {};
void()	ogre_paine10=[	$paine10,	ogre_paine11] {};
void()	ogre_paine11=[	$paine11,	ogre_paine12] {};
void()	ogre_paine12=[	$paine12,	ogre_paine13] {};
void()	ogre_paine13=[	$paine13,	ogre_paine14] {};
void()	ogre_paine14=[	$paine14,	ogre_paine15] {};
void()	ogre_paine15=[	$paine15,	ogre_run1	] {};

/*==========
ogre_pain
==========*/
void(entity attacker, float damage)	ogre_pain =
{
	if (self.pain_finished > time)
		return;
	sound (self, CHAN_VOICE, "ogre/ogpain1.wav", 1, ATTN_NORM);		

	float r = randomrange(4);
	if (r == 0)
	{
		ogre_pain1 ();
		self.pain_finished = time + 1;
	}
	else if (r == 1)
	{
		ogre_painb1 ();
		self.pain_finished = time + 1;
	}
	else if (r == 2)
	{
		ogre_painc1 ();
		self.pain_finished = time + 1;
	}
	else
	{
		r = random();
		if (r < 0.5)
		{
			ogre_paind1 ();
			self.pain_finished = time + 2;
		}
		else
		{
			ogre_paine1 ();
			self.pain_finished = time + 2;
		}
	}
};

void()	ogre_die1	=[	$death1,	ogre_die2	] {};
void()	ogre_die2	=[	$death2,	ogre_die3	] {};
void()	ogre_die3	=[	$death3,	ogre_die4	] {DropBackpack();};
void()	ogre_die4	=[	$death4,	ogre_die5	] {};
void()	ogre_die5	=[	$death5,	ogre_die6	] {};
void()	ogre_die6	=[	$death6,	ogre_die7	] {};
void()	ogre_die7	=[	$death7,	ogre_die8	] {};
void()	ogre_die8	=[	$death8,	ogre_die9	] {};
void()	ogre_die9	=[	$death9,	ogre_die10	] {};
void()	ogre_die10	=[	$death10,	ogre_die11	] {};
void()	ogre_die11	=[	$death11,	ogre_die12	] {};
void()	ogre_die12	=[	$death12,	ogre_die13	] {};
void()	ogre_die13	=[	$death13,	ogre_die14	] {};
void()	ogre_die14	=[	$death14,	ogre_die14	] {};

void()	ogre_bdie1	=[	$bdeath1,	ogre_bdie2	] {};
void()	ogre_bdie2	=[	$bdeath2,	ogre_bdie3	] {ai_forward(5);};
void()	ogre_bdie3	=[	$bdeath3,	ogre_bdie4	] {DropBackpack();};
void()	ogre_bdie4	=[	$bdeath4,	ogre_bdie5	] {ai_forward(1);};
void()	ogre_bdie5	=[	$bdeath5,	ogre_bdie6	] {ai_forward(3);};
void()	ogre_bdie6	=[	$bdeath6,	ogre_bdie7	] {ai_forward(7);};
void()	ogre_bdie7	=[	$bdeath7,	ogre_bdie8	] {ai_forward(25);};
void()	ogre_bdie8	=[	$bdeath8,	ogre_bdie9	] {};
void()	ogre_bdie9	=[	$bdeath9,	ogre_bdie10	] {};
void()	ogre_bdie10	=[	$bdeath10,	ogre_bdie10	] {};

/*==========
ogre_die
==========*/
void(entity inflictor, entity attacker) ogre_die =
{
	if (self.health < -80)
	{
		SpawnGib ("progs/gib1.mdl");
		SpawnGib ("progs/gib2.mdl");
		SpawnGib ("progs/gib3.mdl");
		SpawnGib ("progs/gib4.mdl");
		SpawnGib ("progs/gib5.mdl");
		BecomeGibs ();
		return;
	}
	
	self.solid = SOLID_NOT;
	sound (self, CHAN_VOICE, "ogre/ogdth.wav", 1, ATTN_NORM);
	if (random() < 0.5)
		ogre_die1 ();
	else
		ogre_bdie1 ();
};

/*QUAKED monster_ogre (1 0 0) (-32 -32 -24) (32 32 64) Ambush
{
	model ("progs/ogre.mdl");
}
Ogre.
"What's worse than a cannibal monster eight feet tall? One with a chainsaw. And a sack of grenades."
*/
void() monster_ogre =
{	
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/ogre.mdl");
	precache_model ("progs/h_ogre.mdl");
	precache_model ("progs/grenade.mdl");

	precache_sound ("ogre/ogdrag.wav");
	precache_sound ("ogre/ogdth.wav");
	precache_sound ("ogre/ogidle.wav");
	precache_sound ("ogre/ogidle2.wav");
	precache_sound ("ogre/ogpain1.wav");
	precache_sound ("ogre/ogsawatk.wav");
	precache_sound ("ogre/ogwake.wav");

	self.th_stand = ogre_stand1;
	self.th_walk = ogre_walk1;
	self.th_run = ogre_run1;
	self.th_die = ogre_die;
	self.th_melee = ogre_melee;
	self.th_missile = ogre_grenade1;
	self.th_spam = ogre_spam1;
	self.th_pain = ogre_pain;
	
	if (random() < 0.3)
		self.skin = 1;
	self.ammo_rockets = 2;
	
	monster_start("progs/ogre.mdl", "progs/h_ogre.mdl", 200, 0, VEC_HULL2_MIN, VEC_HULL2_MAX);
};

/*==========
monster_ogre_marksman
For compatibility only.
==========*/
void() monster_ogre_marksman =
{
	self.classname = "monster_ogre";
	monster_ogre ();
};
