/*==========
GibTouch

squelch, splat
==========*/
static void() GibTouch =
{
	if (other != world)
		return;
	// don't sound more than once per gib
	if (self.count)
		return;
	// don't always sound
	if (random() < 0.5)
		return;
	self.count = 1;
	float r = random();
	if (r < 0.2)
		sound (self, CHAN_VOICE, "zombie/z_miss.wav", 0.5, ATTN_IDLE);
	else
		sound (self, CHAN_VOICE, "player/tornoff2.wav", 0.5, ATTN_IDLE);
};

/*==========
GibVelocity
==========*/
static vector(float dm) GibVelocity =
{
	vector v = [100 * crandom(), 100 * crandom(), 200 + 100 * random()];
	if (dm > -50)
		return v * 0.7;
	else if (dm > -200)
		return v * 2;
	else
		return v * 10;
};

/*==========
SpawnGib
==========*/
void(string gibname) SpawnGib =
{
	entity gib = spawn();
	gib.classname = "gib";
	gib.owner = self;
	gib.solid = SOLID_TRIGGER;
	gib.movetype = MOVETYPE_BOUNCE;
	setmodel (gib, gibname);
	setsize (gib, '0 0 0', '0 0 0');
	
	vector org = self.origin;
	setorigin (gib, [org_x + crandom() * 0.5 * self.size_x, org_y + crandom() * 0.5 * self.size_y, org_z + crandom() * 0.5 * self.size_z]);
	gib.velocity = GibVelocity(self.health);
	gib.avelocity = randomvec() * 100;
	gib.frame = randomrange(10);

	gib.touch = GibTouch;
	gib.think = SUB_Remove;
	gib.nextthink = time + 10 + random() * 10;
};

/*==========
GibSound
==========*/
static void() GibSound =
{
	float r = randomrange(4);
	
	// player death sounds have no attenuation
	float attn;
	if (self.classname == "player")
		attn = ATTN_NONE;
	else
		attn = ATTN_NORM;
		
	if (r == 0)
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, attn);
	else if (r == 1)
		sound (self, CHAN_VOICE, "player/teledth1.wav", 1, attn);
	else if (r == 2)
		sound (self, CHAN_VOICE, "player/gib.wav", 1, attn);
	else if (r == 4)
		sound (self, CHAN_VOICE, "player/tornoff2.wav", 1, attn);
};

/*==========
BecomeGibs
==========*/
void() BecomeGibs =
{
	GibSound();
	
	self.think = SUB_Null;
	self.nextthink = -1;
	self.deadflag = DEAD_DEAD;
	self.takedamage = DAMAGE_NO;
	self.frame = 0;
	self.flags = self.flags - (self.flags & FL_ONGROUND);

	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_BOUNCE;
	setmodel (self, self.headmodel);
	setsize (self, '-16 -16 0', '16 16 16');
	setorigin(self, self.origin + self.view_ofs + [0,0,8]);
	self.view_ofs = '0 0 8';
	
	self.velocity = GibVelocity(self.health);
	self.avelocity = [0, crandom() * 600, 0];
};

/*==========
SpawnMeatSpray
==========*/
void(vector org, vector vel) SpawnMeatSpray =
{
	entity gib = spawn();
	gib.owner = self;
	gib.solid = SOLID_NOT;
	gib.movetype = MOVETYPE_TOSS;
	setmodel (gib, "progs/zom_gib.mdl");
	setsize (gib, '0 0 0', '0 0 0');		
	setorigin (gib, org);
	
	gib.velocity = vel;
	gib.velocity_z = gib.velocity_z + 250 + 50 * random();
	gib.avelocity = '3000 1000 2000';
	
	gib.touch = SUB_Remove;
	gib.think = SUB_Remove;
	gib.nextthink = time + 1;
};

/*==========
SpawnBlood
==========*/
void(vector org, vector vel, float damage) SpawnBlood =
{
	particle(org, vel, 66, damage);
	particle(org, vel, 73, damage);
};

/*==========
SpawnTouchParticles
==========*/
void(float damage, float col) SpawnTouchParticles =
{
	vector vel = normalize(self.velocity);
	vector org = self.origin - 4 * vel;
	
	makevectors(vel);
	vel = v_right * crandom() + v_up * crandom();
	vel = vel * random() * 4;
	
	particle(org, vel, col, damage);
};

/*==========
SpawnTouchblood
==========*/
void(float damage) SpawnTouchblood =
{
	SpawnTouchParticles(damage, 66);
	SpawnTouchParticles(damage, 73);
};
