$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9
$frame stand10 stand11 stand12 stand13

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8

$frame run1 run2 run3 run4 run5 run6

$frame leap1 leap2 leap3 leap4 leap5 leap6 leap7 leap8 leap9 leap10
$frame leap11 leap12

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9

$frame attacka1 attacka2 attacka3 attacka4 attacka5 attacka6 attacka7 attacka8
$frame attacka9 attacka10 attacka11 attacka12 attacka13 attacka14 attacka15

void()	demon1_stand1	=[	$stand1,	demon1_stand2	] {ai_stand();
if (random() < 0.1)
    sound (self, CHAN_VOICE, "demon/idle1.wav", 1, ATTN_IDLE);
};
void()	demon1_stand2	=[	$stand2,	demon1_stand3	] {ai_stand();};
void()	demon1_stand3	=[	$stand3,	demon1_stand4	] {ai_stand();};
void()	demon1_stand4	=[	$stand4,	demon1_stand5	] {ai_stand();};
void()	demon1_stand5	=[	$stand5,	demon1_stand6	] {ai_stand();};
void()	demon1_stand6	=[	$stand6,	demon1_stand7	] {ai_stand();};
void()	demon1_stand7	=[	$stand7,	demon1_stand8	] {ai_stand();};
void()	demon1_stand8	=[	$stand8,	demon1_stand9	] {ai_stand();};
void()	demon1_stand9	=[	$stand9,	demon1_stand10	] {ai_stand();};
void()	demon1_stand10	=[	$stand10,	demon1_stand11	] {ai_stand();};
void()	demon1_stand11	=[	$stand11,	demon1_stand12	] {ai_stand();};
void()	demon1_stand12	=[	$stand12,	demon1_stand13	] {ai_stand();};
void()	demon1_stand13	=[	$stand13,	demon1_stand1	] {ai_stand();};

void()	demon1_walk1	=[	$walk1,		demon1_walk2	] {
if (random() < 0.2)
    sound (self, CHAN_VOICE, "demon/idle1.wav", 1, ATTN_IDLE);
ai_walk(8);
};
void()	demon1_walk2	=[	$walk2,		demon1_walk3	] {ai_walk(6);};
void()	demon1_walk3	=[	$walk3,		demon1_walk4	] {ai_walk(6);};
void()	demon1_walk4	=[	$walk4,		demon1_walk5	] {ai_walk(7);};
void()	demon1_walk5	=[	$walk5,		demon1_walk6	] {ai_walk(4);};
void()	demon1_walk6	=[	$walk6,		demon1_walk7	] {ai_walk(6);};
void()	demon1_walk7	=[	$walk7,		demon1_walk8	] {ai_walk(10);};
void()	demon1_walk8	=[	$walk8,		demon1_walk1	] {ai_walk(10);};

void()	demon1_run1	=[	$run1,		demon1_run2	] {
if (random() < 0.2)
    sound (self, CHAN_VOICE, "demon/idle1.wav", 1, ATTN_IDLE);
ai_run(20);};
void()	demon1_run2	=[	$run2,		demon1_run3	] {ai_run(15);};
void()	demon1_run3	=[	$run3,		demon1_run4	] {ai_run(36);};
void()	demon1_run4	=[	$run4,		demon1_run5	] {ai_run(20);};
void()	demon1_run5	=[	$run5,		demon1_run6	] {ai_run(15);};
void()	demon1_run6	=[	$run6,		demon1_run1	] {ai_run(36);};

void() demon1_jump1;
void() demon1_jump11;

void()	Demon_JumpTouch =
{
	if (self.health <= 0)
		return;
		
	if (other.takedamage)
	{
		if (vlen(self.velocity) > 400)
		{
			float ldmg = 40 + 10 * random();
			Damage (other, self, self, ldmg);	
		}
	}

	if (!checkbottom(self))
	{
		if (self.flags & FL_ONGROUND)
		{
			self.touch = SUB_Null;
			self.think = demon1_jump1;
			self.nextthink = time + 0.1;
		}
		return;
	}

	self.touch = SUB_Null;
	self.think = demon1_jump11;
	self.nextthink = time + 0.1;
};



void()	demon1_jump1	=[	$leap1,		demon1_jump2	] {ai_face();};
void()	demon1_jump2	=[	$leap2,		demon1_jump3	] {ai_face();};
void()	demon1_jump3	=[	$leap3,		demon1_jump4	] {ai_face();};
void()	demon1_jump4	=[	$leap4,		demon1_jump5	]
{
	ai_face();
	
	self.touch = Demon_JumpTouch;
	makevectors (self.angles);
	self.origin_z = self.origin_z + 1;
	self.velocity = v_forward * 600 + '0 0 250';
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
};
void()	demon1_jump5	=[	$leap5,		demon1_jump6	] {};
void()	demon1_jump6	=[	$leap6,		demon1_jump7	] {};
void()	demon1_jump7	=[	$leap7,		demon1_jump8	] {};
void()	demon1_jump8	=[ 	$leap8,		demon1_jump9	] {};
void()	demon1_jump9	=[ 	$leap9,		demon1_jump10	] {};
void()	demon1_jump10	=[ 	$leap10,	demon1_jump1	] {self.nextthink = time + 3;};
void()	demon1_jump11	=[ 	$leap11,	demon1_jump12	] {};
void()	demon1_jump12	=[ 	$leap12,	demon1_run1		] {};

void(float side)	Demon_Melee =
{	
	ai_face ();
	walkmove (self.ideal_yaw, 12);

	if (vlen(self.enemy.origin - self.origin) > 100)
		return;
	if (!CanDamage (self.enemy, self))
		return;

    sound (self, CHAN_WEAPON, "demon/dhit2.wav", 1, ATTN_NORM);
	float ldmg = 10 + 5 * random();
	Damage (self.enemy, self, self, ldmg);	

	makevectors (self.angles);
	SpawnMeatSpray (self.origin + v_forward*16, side * v_right);
};


void()	demon1_atta1	=[	$attacka1,		demon1_atta2	] {ai_charge(4);};
void()	demon1_atta2	=[	$attacka2,		demon1_atta3	] {ai_charge(0);};
void()	demon1_atta3	=[	$attacka3,		demon1_atta4	] {ai_charge(0);};
void()	demon1_atta4	=[	$attacka4,		demon1_atta5	] {ai_charge(1);};
void()	demon1_atta5	=[	$attacka5,		demon1_atta6	] {ai_charge(2); Demon_Melee(200);};
void()	demon1_atta6	=[	$attacka6,		demon1_atta7	] {ai_charge(1);};
void()	demon1_atta7	=[	$attacka7,		demon1_atta8	] {ai_charge(6);};
void()	demon1_atta8	=[	$attacka8,		demon1_atta9	] {ai_charge(8);};
void()	demon1_atta9	=[	$attacka9,		demon1_atta10	] {ai_charge(4);};
void()	demon1_atta10	=[	$attacka10,		demon1_atta11	] {ai_charge(2);};
void()	demon1_atta11	=[	$attacka11,		demon1_atta12	] {Demon_Melee(-200);};
void()	demon1_atta12	=[	$attacka12,		demon1_atta13	] {ai_charge(5);};
void()	demon1_atta13	=[	$attacka13,		demon1_atta14	] {ai_charge(8);};
void()	demon1_atta14	=[	$attacka14,		demon1_atta15	] {ai_charge(4);};
void()	demon1_atta15	=[	$attacka15,		demon1_run1		] {ai_charge(4);};

void()	demon1_pain1	=[	$pain1,		demon1_pain2	] {};
void()	demon1_pain2	=[	$pain2,		demon1_pain3	] {};
void()	demon1_pain3	=[	$pain3,		demon1_pain4	] {};
void()	demon1_pain4	=[	$pain4,		demon1_pain5	] {};
void()	demon1_pain5	=[	$pain5,		demon1_pain6	] {};
void()	demon1_pain6	=[	$pain6,		demon1_run1	] {};

void(entity attacker, float damage)	demon_pain =
{
	if (self.touch == Demon_JumpTouch)
		return;
	if (self.pain_finished > time)
		return;

	self.pain_finished = time + 1;
    sound (self, CHAN_VOICE, "demon/dpain1.wav", 1, ATTN_NORM);

	if (random()*200 > damage)
		return;		// didn't flinch
		
	demon1_pain1 ();
};

void()	demon1_die1		=[	$death1,		demon1_die2	] {};
void()	demon1_die2		=[	$death2,		demon1_die3	] {};
void()	demon1_die3		=[	$death3,		demon1_die4	] {};
void()	demon1_die4		=[	$death4,		demon1_die5	] {};
void()	demon1_die5		=[	$death5,		demon1_die6	] {};
void()	demon1_die6		=[	$death6,		demon1_die7	] {};
void()	demon1_die7		=[	$death7,		demon1_die8	] {};
void()	demon1_die8		=[	$death8,		demon1_die9	] {};
void()	demon1_die9		=[	$death9,		demon1_die9 ] {};

void(entity inflictor, entity attacker) demon_die =
{
	if (self.health < -80)
	{
		SpawnGib("progs/gib3.mdl");
		SpawnGib("progs/gib4.mdl");
		SpawnGib("progs/gib5.mdl");
		BecomeGibs();
		return;
	}

	sound (self, CHAN_VOICE, "demon/ddeath.wav", 1, ATTN_NORM);
	self.solid = SOLID_NOT;
	demon1_die1 ();
};

void() Demon_MeleeAttack =
{
	sound (self, CHAN_VOICE, "demon/idle1.wav", 1, ATTN_NORM);
	demon1_atta1 ();
};

/*QUAKED monster_demon1 (1 0 0) (-32 -32 -24) (32 32 64) Ambush
{
	model ("progs/demon.mdl");
}
Fiend.
"In essence, organic buzzsaws, rife with pummeling power!"
*/
void() monster_demon1 =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/demon.mdl");
	precache_model ("progs/h_demon.mdl");

	precache_sound ("demon/ddeath.wav");
	precache_sound ("demon/dhit2.wav");
	precache_sound ("demon/djump.wav");
	precache_sound ("demon/dpain1.wav");
	precache_sound ("demon/idle1.wav");
	precache_sound ("demon/sight2.wav");

	self.th_stand = demon1_stand1;
	self.th_walk = demon1_walk1;
	self.th_run = demon1_run1;
	self.th_die = demon_die;
	self.th_melee = Demon_MeleeAttack;
	self.th_missile = demon1_jump1;
	self.th_pain = demon_pain;
		
	monster_start("progs/demon.mdl", "progs/h_demon.mdl", 300, 0, VEC_HULL2_MIN, VEC_HULL2_MAX);
};

float()	CheckDemonJump =
{
	vector spot1 = self.origin;
	vector spot2 = self.enemy.origin;
	traceline (spot1, spot2, MOVE_MISSILE, self);
	if (trace_inwater)
		if (trace_inopen)
			return FALSE;
	if (trace_ent != self.enemy)
		return FALSE;
	
	// too high above player
	if (self.origin_z + self.mins_z > self.enemy.origin_z + self.enemy.mins_z + 0.75 * self.enemy.size_z)
		return FALSE;
	
	// too low below player
	if (self.origin_z + self.maxs_z < self.enemy.origin_z + self.enemy.mins_z + 0.25 * self.enemy.size_z)
		return FALSE;

	vector dist = self.enemy.origin - self.origin;
	dist_z = 0;
	float len = vlen(dist);
	if (len < 100)
		return FALSE;
	if (len > 200)
	{
		if (random() < 0.9)
			return FALSE;
	}
	return TRUE;
};

float()	DemonCheckAttack =
{
	if (enemy_range == RANGE_MELEE)
	{
		if (CanDamage(self.enemy, self))
		{
			self.attack_state = AS_MELEE;
			return TRUE;
		}
	}
	
	if (enemy_range == RANGE_FAR)
		return FALSE;
	
	if (CheckDemonJump())
	{
		sound (self, CHAN_VOICE, "demon/djump.wav", 1, ATTN_NORM);
		self.attack_state = AS_MISSILE;
		return TRUE;
	}
	
	return FALSE;
};
