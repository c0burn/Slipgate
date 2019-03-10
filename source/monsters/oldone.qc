$frame old1 old2 old3 old4 old5 old6 old7 old8 old9 
$frame old10 old11 old12 old13 old14 old15 old16 old17 old18 old19 
$frame old20 old21 old22 old23 old24 old25 old26 old27 old28 old29 
$frame old30 old31 old32 old33 old34 old35 old36 old37 old38 old39 
$frame old40 old41 old42 old43 old44 old45 old46 

$frame shake1 shake2 shake3 shake4 shake5 shake6 shake7 shake8
$frame shake9 shake10 shake11 shake12 shake13 shake14
$frame shake15 shake16 shake17 shake18 shake19 shake20 shake21

entity shub;

/*==========
shub_awake
==========*/
void() shub_awake =
{
	self.frame = self.frame + 1;
	if (self.frame > $old46)
		self.frame = $old1;
	
	self.think = shub_awake;
	self.nextthink = time + 0.1;
		
	if (time < self.attack_finished)
		return;
	sound(self, CHAN_VOICE, "boss2/idle.wav", 1, ATTN_IDLE);
	self.attack_finished = time + 2 + random() * 2;
};

/*==========
shub_idle
==========*/
void() shub_idle =
{
	self.frame = self.frame + 1;
	if (self.frame > $old46)
		self.frame = $old1;
	
	// look for a player
	entity client = checkclient();
	if (client)
	{
		if (visible(client))
		{
			self.enemy = client;
			sound(self, CHAN_BODY, "boss2/sight.wav", 1, ATTN_NONE);	// no attenuation
			self.attack_finished = time + 3;
			self.think = shub_awake;
			self.nextthink = time + 0.1;
			return;
		}
	}
	
	self.think = shub_idle;
	self.nextthink = time + 0.1;
};

/*==========
shub_finale_3
==========*/
void() shub_finale_3 =
{
	// switch cd track
	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);
	WriteByte (MSG_ALL, 3);
	
	// turn lights back on and spawn a load of gibs
	lightstyle (0, "m");	
	sound (self, CHAN_VOICE, "boss2/pop2.wav", 1, ATTN_NONE);	// no attenuation
	for (float i = 0; i < 20; i++)
	{
		SpawnGib("progs/gib3.mdl");
		SpawnGib("progs/gib4.mdl");
		SpawnGib("progs/gib5.mdl");
		SpawnGib("progs/blood.mdl");
	}
	
	// start the end text
	WriteByte (MSG_ALL, SVC_FINALE);
	WriteString (MSG_ALL, "Congratulations and well done! You have\nbeaten the hideous Shub-Niggurath, and\nher hundreds of ugly changelings and\nmonsters. You have proven that your\nskill and your cunning are greater than\nall the powers of Quake. You are the\nmaster now. Id Software salutes you.");

	// find the intermission spot
	entity pos = find (world, classname, "info_intermission");
	if (!pos)
		error ("no info_intermission");
	
	// put a player model down and face it towards the intermission spot
	entity p = spawn();
	p.solid = SOLID_NOT;
	p.movetype = MOVETYPE_NONE;
	setmodel (p, "progs/dplayer.mdl");
	makevectors(self.angles);
	setorigin (p, self.origin + v_forward * 128);
	p.angles_y = vectoyaw(pos.origin - p.origin);
	
	// remove shub
	remove (self);
};

void() shub_thrash1		=[	$shake1, shub_thrash2	] {lightstyle(0, "m");};
void() shub_thrash2		=[	$shake2, shub_thrash3	] {lightstyle(0, "k");};
void() shub_thrash3		=[	$shake3, shub_thrash4	] {lightstyle(0, "k");};
void() shub_thrash4		=[	$shake4, shub_thrash5	] {lightstyle(0, "i");};
void() shub_thrash5		=[	$shake5, shub_thrash6	] {lightstyle(0, "g");};
void() shub_thrash6		=[	$shake6, shub_thrash7	] {lightstyle(0, "e");};
void() shub_thrash7		=[	$shake7, shub_thrash8	] {lightstyle(0, "c");};
void() shub_thrash8		=[	$shake8, shub_thrash9	] {lightstyle(0, "a");};
void() shub_thrash9		=[	$shake9, shub_thrash10	] {lightstyle(0, "c");};
void() shub_thrash10	=[	$shake10, shub_thrash11	] {lightstyle(0, "e");};
void() shub_thrash11	=[	$shake11, shub_thrash12	] {lightstyle(0, "g");};
void() shub_thrash12	=[	$shake12, shub_thrash13	] {lightstyle(0, "i");};
void() shub_thrash13	=[	$shake13, shub_thrash14	] {lightstyle(0, "k");};
void() shub_thrash14	=[	$shake14, shub_thrash15	] {lightstyle(0, "m");};
void() shub_thrash15	=[	$shake15, shub_thrash16	]
{
	lightstyle(0, "m");
	self.count = self.count + 1;
	if (self.count < 3)
		self.think = shub_thrash1;
};
void() shub_thrash16	=[	$shake16, shub_thrash17	] {lightstyle(0, "g");};
void() shub_thrash17	=[	$shake17, shub_thrash18	] {lightstyle(0, "c");};
void() shub_thrash18	=[	$shake18, shub_thrash19	] {lightstyle(0, "b");};
void() shub_thrash19	=[	$shake19, shub_thrash20	] {lightstyle(0, "a");};
void() shub_thrash20	=[	$shake20, shub_thrash21	] {lightstyle(0, "a");};
void() shub_thrash21	=[	$shake21, shub_thrash21	] {shub_finale_3();};

/*==========
shub_finale_3
==========*/
void() shub_finale_2 =
{
	shub.think = shub_thrash1;
	sound(shub, CHAN_VOICE, "boss2/death.wav", 1, ATTN_NONE);	// no attenuation
	remove(self);
};

/*==========
shub_finale_2
==========*/
void() shub_finale_1 =
{
	// start a teleport splash inside shub
	te_teleport(shub.origin + [0, 0, 192]);
	sound(shub, CHAN_VOICE, "misc/r_tele1.wav", 1, ATTN_NONE);	// no attenuation
	
	// wait for 2 seconds
	self.nextthink = time + 2;
	self.think = shub_finale_2;
};

/*==========
shub_die
==========*/
void(entity inflictor, entity attacker) shub_die =
{
	// bump the kill counter
	killed_monsters = killed_monsters + 1;
	WriteByte (MSG_ALL, SVC_KILLEDMONSTER);
	
	// put up the end of level scoreboard
	intermission_running = 1;
	intermission_exittime = -1;
	WriteByte (MSG_ALL, SVC_INTERMISSION);
	
	// find the intermission spot
	entity pos = find (world, classname, "info_intermission");
	if (!pos)
		error("no info_intermission");

	// move all players to the intermission spot
	entity p = find (world, classname, "player");
	while (p != world)
	{
		p.view_ofs = '0 0 0';
		p.angles = other.v_angle = pos.mangle;
		p.fixangle = TRUE;
		p.think = SUB_Null;
		p.nextthink = time + 0.1;
		p.takedamage = DAMAGE_NO;
		p.solid = SOLID_NOT;
		p.movetype = MOVETYPE_NONE;
		p.modelindex = 0;
		setorigin(p, pos.origin);
		p = find(p, classname, "player");
	}

	// wait for 1 second
	entity timer = spawn();
	timer.think = shub_finale_1;
	timer.nextthink = time + 1;
};

/*==========
shub_pain
==========*/
void (entity attacker, float damage) shub_pain =
{
	self.health = 40000;
};

/*QUAKED monster_oldone (1 0 0) (-160 -128 -24) (128 128 256)
{	model ("progs/oldone.mdl");		}
Shub-Niggurath.
*/
void() monster_oldone =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}

	precache_model2 ("progs/oldone.mdl");
	precache_model ("progs/dplayer.mdl");

	precache_sound2 ("boss2/death.wav");
	precache_sound2 ("boss2/idle.wav");
	precache_sound2 ("boss2/sight.wav");
	precache_sound2 ("boss2/pop2.wav");

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;
	
	setmodel (self, "progs/oldone.mdl");
	setsize (self, '-160 -128 -24', '160 128 256');

	self.health = 40000;		// kill by telefrag
	self.takedamage = DAMAGE_YES;
	self.th_pain = shub_pain;
	self.th_die = shub_die;
	
	shub = self;
	total_monsters = total_monsters + 1;
	
	self.think = shub_idle;
	self.nextthink = time + 0.1;
};

