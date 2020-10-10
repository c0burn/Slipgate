$frame rise1 rise2 rise3 rise4 rise5 rise6 rise7 rise8 rise9 rise10
$frame rise11 rise12 rise13 rise14 rise15 rise16 rise17 

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8
$frame walk9 walk10 walk11 walk12 walk13 walk14 walk15
$frame walk16 walk17 walk18 walk19 walk20 walk21 walk22
$frame walk23 walk24 walk25 walk26 walk27 walk28 walk29 walk30 walk31

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9

$frame attack1 attack2 attack3 attack4 attack5 attack6 attack7 attack8
$frame attack9 attack10 attack11 attack12 attack13 attack14 attack15
$frame attack16 attack17 attack18 attack19 attack20 attack21 attack22
$frame attack23

$frame shocka1 shocka2 shocka3 shocka4 shocka5 shocka6 shocka7 shocka8
$frame shocka9 shocka10 

$frame shockb1 shockb2 shockb3 shockb4 shockb5 shockb6

$frame shockc1 shockc2 shockc3 shockc4 shockc5 shockc6 shockc7 shockc8 
$frame shockc9 shockc10

#define CHTHON_M_VEL 300

void() boss_missile1;

/*==========
boss_idle
==========*/
void() boss_idle =
{
	// look for a new player in co-op
	if (coop)
	{
		entity client = checkclient();
		if (client)
		{
			if (visible(client))
			{
				self.enemy = client;
				boss_missile1();
				return;
			}
		}
	}
	
	self.walkframe = self.walkframe + 1;
	if (self.walkframe > 30)
		self.walkframe = 0;
	self.frame = $walk1 + self.walkframe;
	
	self.think = boss_idle;
	self.nextthink = time + 0.1;
};

void() boss_rise1	=[	$rise1, boss_rise2 ] {te_lavasplash(self.origin);sound(self, CHAN_BODY, "boss1/out1.wav", 1, ATTN_NORM);};
void() boss_rise2	=[	$rise2, boss_rise3 ] {};
void() boss_rise3	=[	$rise3, boss_rise4 ] {};
void() boss_rise4	=[	$rise4, boss_rise5 ] {};
void() boss_rise5	=[	$rise5, boss_rise6 ] {sound (self, CHAN_VOICE, "boss1/sight1.wav", 1, ATTN_NORM);};
void() boss_rise6	=[	$rise6, boss_rise7 ] {};
void() boss_rise7	=[	$rise7, boss_rise8 ] {};
void() boss_rise8	=[	$rise8, boss_rise9 ] {};
void() boss_rise9	=[	$rise9, boss_rise10 ] {};
void() boss_rise10	=[	$rise10, boss_rise11 ] {};
void() boss_rise11	=[	$rise11, boss_rise12 ] {};
void() boss_rise12	=[	$rise12, boss_rise13 ] {};
void() boss_rise13	=[	$rise13, boss_rise14 ] {};
void() boss_rise14	=[	$rise14, boss_rise15 ] {};
void() boss_rise15	=[	$rise15, boss_rise16 ] {};
void() boss_rise16	=[	$rise16, boss_rise17 ] {};
void() boss_rise17	=[	$rise17, boss_missile1 ] {};

/*==========
boss_missile
==========*/
void(float ofs) boss_missile =
{
	sound (self, CHAN_WEAPON, "boss1/throw.wav", 1, ATTN_NORM);
	
	makevectors(self.angles);
	vector org = self.origin + v_forward * 100 + v_right * ofs + v_up * self.view_ofs_z;
	
	vector d;
	// lead the player on hard mode
	if (skill > 1)
	{
		float t = vlen(self.enemy.origin + self.enemy.view_ofs - org) / CHTHON_M_VEL;
		vector vec = self.enemy.velocity;
		vec_z = 0;
		d = self.enemy.origin + self.enemy.view_ofs + (t * vec);
	}
	else
		d = self.enemy.origin + self.enemy.view_ofs;
	
	vec = normalize(d - org);
	launch_spike (org, vec);
	setmodel (newmis, "progs/lavaball.mdl");
	setsize (newmis, '0 0 0', '0 0 0');
	newmis.avelocity = '200 100 300';
	newmis.velocity = vec * CHTHON_M_VEL;
	newmis.touch = T_MissileTouch;
};

/*==========
boss_check_enemy
==========*/
void() boss_check_enemy =
{
	// look for a new player in coop
	if (coop)
	{
		// randomly switch, or switch when player is dead
		if (random() < 0.5 || self.enemy.health <= 0)
		{
			entity client = checkclient();
			if (!client)
			{
				if (self.enemy.health > 0)
					return;

				// go to idle, no live players found
				self.enemy = world;
				boss_idle();
				return;
			}
			self.enemy = client;
		}
		return;
	}
	
	// go to idle in single player if the player is dead
	if (self.enemy.health <= 0)
	{
		self.enemy = world;
		boss_idle();
	}
};

void() boss_missile1	=[	$attack1, boss_missile2 ] {ai_face();};
void() boss_missile2	=[	$attack2, boss_missile3 ] {ai_face();};
void() boss_missile3	=[	$attack3, boss_missile4 ] {ai_face();};
void() boss_missile4	=[	$attack4, boss_missile5 ] {ai_face();};
void() boss_missile5	=[	$attack5, boss_missile6 ] {ai_face();};
void() boss_missile6	=[	$attack6, boss_missile7 ] {ai_face();};
void() boss_missile7	=[	$attack7, boss_missile8 ] {ai_face();boss_missile(100);};
void() boss_missile8	=[	$attack8, boss_missile9 ] {ai_face();};
void() boss_missile9	=[	$attack9, boss_missile10 ] {ai_face();};
void() boss_missile10	=[	$attack10, boss_missile11 ] {ai_face();};
void() boss_missile11	=[	$attack11, boss_missile12 ] {ai_face();};
void() boss_missile12	=[	$attack12, boss_missile13 ] {ai_face();};
void() boss_missile13	=[	$attack13, boss_missile14 ] {ai_face();};
void() boss_missile14	=[	$attack14, boss_missile15 ] {ai_face();};
void() boss_missile15	=[	$attack15, boss_missile16 ] {ai_face();};
void() boss_missile16	=[	$attack16, boss_missile17 ] {ai_face();};
void() boss_missile17	=[	$attack17, boss_missile18 ] {ai_face();};
void() boss_missile18	=[	$attack18, boss_missile19 ] {ai_face();boss_missile(-100);};
void() boss_missile19	=[	$attack19, boss_missile20 ] {ai_face();};
void() boss_missile20	=[	$attack20, boss_missile21 ] {ai_face();};
void() boss_missile21	=[	$attack21, boss_missile22 ] {ai_face();};
void() boss_missile22	=[	$attack22, boss_missile23 ] {ai_face();};
void() boss_missile23	=[	$attack23, boss_missile1 ] {ai_face();boss_check_enemy();};

void() boss_shocka1 =[	$shocka1, boss_shocka2 ] {};
void() boss_shocka2 =[	$shocka2, boss_shocka3 ] {};
void() boss_shocka3 =[	$shocka3, boss_shocka4 ] {};
void() boss_shocka4 =[	$shocka4, boss_shocka5 ] {};
void() boss_shocka5 =[	$shocka5, boss_shocka6 ] {};
void() boss_shocka6 =[	$shocka6, boss_shocka7 ] {};
void() boss_shocka7 =[	$shocka7, boss_shocka8 ] {};
void() boss_shocka8 =[	$shocka8, boss_shocka9 ] {};
void() boss_shocka9 =[	$shocka9, boss_shocka10 ] {};
void() boss_shocka10 =[	$shocka10, boss_missile1 ] {};

void() boss_shockb1 =[	$shockb1, boss_shockb2 ] {};
void() boss_shockb2 =[	$shockb2, boss_shockb3 ] {};
void() boss_shockb3 =[	$shockb3, boss_shockb4 ] {};
void() boss_shockb4 =[	$shockb4, boss_shockb5 ] {};
void() boss_shockb5 =[	$shockb5, boss_shockb6 ] {};
void() boss_shockb6 =[	$shockb6, boss_shockb7 ] {};
void() boss_shockb7 =[	$shockb1, boss_shockb8 ] {};
void() boss_shockb8 =[	$shockb2, boss_shockb9 ] {};
void() boss_shockb9 =[	$shockb3, boss_shockb10 ] {};
void() boss_shockb10 =[	$shockb4, boss_missile1 ] {};

void() boss_shockc1 =[	$shockc1, boss_shockc2 ] {};
void() boss_shockc2 =[	$shockc2, boss_shockc3 ] {};
void() boss_shockc3 =[	$shockc3, boss_shockc4 ] {};
void() boss_shockc4 =[	$shockc4, boss_shockc5 ] {};
void() boss_shockc5 =[	$shockc5, boss_shockc6 ] {};
void() boss_shockc6 =[	$shockc6, boss_shockc7 ] {};
void() boss_shockc7 =[	$shockc7, boss_shockc8 ] {};
void() boss_shockc8 =[	$shockc8, boss_shockc9 ] {};
void() boss_shockc9 =[	$shockc9, boss_shockc10 ] {};
void() boss_shockc10 =[	$shockc10, boss_death1 ] {};

void() boss_death1 = [$death1, boss_death2] {sound (self, CHAN_VOICE, "boss1/death.wav", 1, ATTN_NORM);};
void() boss_death2 = [$death2, boss_death3] {};
void() boss_death3 = [$death3, boss_death4] {};
void() boss_death4 = [$death4, boss_death5] {};
void() boss_death5 = [$death5, boss_death6] {};
void() boss_death6 = [$death6, boss_death7] {};
void() boss_death7 = [$death7, boss_death8] {};
void() boss_death8 = [$death8, boss_death9] {te_lavasplash(self.origin);sound (self, CHAN_BODY, "boss1/out1.wav", 1, ATTN_NORM);};
void() boss_death9 = [$death9, boss_death10] {};
void() boss_death10 = [$death9, boss_death10]
{	
	// bump kill counter
	killed_monsters = killed_monsters + 1;
	WriteByte (MSG_ALL, SVC_KILLEDMONSTER);
	
	// use targets
	activator = self.enemy;
	UseTargets();

	remove(self);
};

/*==========
boss_awake
==========*/
void() boss_awake =
{
	self.health = skill + 1;
	self.yaw_speed = 20;
	self.view_ofs = '0 0 200';
	
	if (activator.classname == "player")
		self.enemy = activator;

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	self.takedamage = DAMAGE_NO;
	setmodel (self, "progs/boss.mdl");
	setsize (self, '-128 -128 -24', '128 128 256');
	
	boss_rise1();
};

/*QUAKED monster_boss (1 0 0) (-128 -128 -24) (128 128 256)
{
	model ("progs/boss.mdl");
}
Chthon.
Must be triggered to activate.
*/
void() monster_boss =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	precache_model ("progs/boss.mdl");
	precache_model ("progs/lavaball.mdl");

	precache_sound ("boss1/out1.wav");
	precache_sound ("boss1/sight1.wav");
	precache_sound ("boss1/throw.wav");
	precache_sound ("boss1/pain.wav");
	precache_sound ("boss1/death.wav");
	precache_sound ("misc/power.wav");

	total_monsters = total_monsters + 1;
	
	self.use = boss_awake;
};

//===========================================================================

void() lightning_use;

/*==========
lightning_fire
==========*/
void() lightning_fire =
{
	// return electrodes when the bolt is done
	if (time >= self.attack_finished)
	{
		self.state = 0;
		entity oself = self;
		self = self.target1;
		door_go_down ();
		self = oself.target2;
		door_go_down ();
		return;
	}
	
	// use two beams that meet in the middle, rather than the
	// hack of making a single beam shorter
	te_lightning3(self.pos1, self.pos2, self.target1);
	te_lightning3(self.pos2, self.origin, self.target2);
	
	self.nextthink = time + 0.1;
	self.think = lightning_fire;
};

/*==========
lightning_use
==========*/
void() lightning_use =
{
	if (self.state)
		return;

	// check the electrodes are aligned and not moving
	if (self.target1.state != self.target2.state)
		return;
	if (self.target1.state != STATE_BOTTOM && self.target1.state != STATE_TOP)
		return;

	self.state = 1;

	// don't let the electrodes go back up until the bolt is done
	self.target1.nextthink = -1;
	self.target2.nextthink = -1;
	self.attack_finished = time + 1;

	// find the position of the electrodes and then move the
	// event_lightning entity to the middle of the electrodes.
	// this is because e1m7 annoyingly has it positioned to the left of the
	// button so the sound of the lightning is always panned incorrectly!
	self.pos1 = (self.target1.mins + self.target1.maxs) * 0.5;
	self.pos1_z = self.target1.absmin_z - 16;
	self.pos2 = (self.target2.mins + self.target2.maxs) * 0.5;
	self.pos2_z = self.target2.absmin_z - 16;
	float len = vlen(self.pos2 - self.pos1);
	vector dir = normalize(self.pos2 - self.pos1);
	setorigin(self, self.pos1 + dir * len * 0.5);
	sound (self, CHAN_VOICE, "misc/power.wav", 1, ATTN_NONE);	// no attenuation
	lightning_fire();
	
	// decrease chthon health
	entity chthon = find (world, classname, "monster_boss");
	if (!chthon)
		return;
	if (self.target1.state == STATE_TOP && chthon.health > 0)
	{
		self = chthon;
		self.enemy = activator;
		sound (self, CHAN_VOICE, "boss1/pain.wav", 1, ATTN_NORM);
		self.health = self.health - 1;
		if (self.health > 1)
			boss_shocka1();
		else if (self.health == 1)
			boss_shockb1();
		else if (self.health == 0)
			boss_shockc1();
	}
};

/*==========
event_lightning_go
==========*/
void() event_lightning_go =
{
	// find electrodes
	self.target1 = find(world, target, "lightning");
	self.target2 = find(self.target1, target, "lightning");
	if (!self.target1 || !self.target2)
	{
		objerror("unable to find lightning targets");
		remove(self);
		return;
	}
	
	self.use = lightning_use;
};

/*QUAKED event_lightning (0 1 1) (-8 -8 -8) (8 8 8)
Triggerable lightning event for Chthon only.
You must have two func_door's in the level which both contain a target of "lightning" (not targetname!)
*/
void() event_lightning =
{
	precache_sound ("misc/power.wav");
	self.think = event_lightning_go;
	self.nextthink = time + 0.2;
};
