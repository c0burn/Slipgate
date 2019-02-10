/*==========
gib_touch

squelch, splat
==========*/
void() gib_touch =
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
gib_velocity
==========*/
vector(float dm) gib_velocity =
{
	vector v = [100 * crandom(), 100 * crandom(), 200 + 100 * random()];
	if (dm > -50)
		return v * 0.7;
	else if (dm > -200)
		return v;
	else
		return v * 1.5;
};

/*==========
spawn_gib
==========*/
void(string gibname) spawn_gib =
{
	entity gib = spawn();
	gib.classname = "gib";
	gib.owner = self;
	gib.solid = SOLID_TRIGGER;
	gib.movetype = MOVETYPE_BOUNCE;
	setmodel (gib, gibname);
	setsize (gib, '0 0 0', '0 0 0');
	
	vector sz = self.size * 0.5;
	vector org = self.absmin + sz;
	setorigin (gib, [org_x + sz_x * random(), org_y + sz_y * random(), org_z + sz_z * random()]);
	
	gib.velocity = gib_velocity(self.health);
	gib.avelocity = randomvec() * 100;
	gib.frame = randomrange(10);

	gib.touch = gib_touch;
	gib.think = SUB_Remove;
	gib.nextthink = time + 10 + random() * 10;
};

/*==========
become_gibs
==========*/
void() become_gibs =
{
	self.touch = gib_touch;
	self.think = SUB_Null;
	self.nextthink = -1;
	self.takedamage = DAMAGE_NO;
	self.frame = 0;
	self.flags = self.flags - (self.flags & FL_ONGROUND);

	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_BOUNCE;
	setmodel (self, self.headmodel);
	setsize (self, '-16 -16 0', '16 16 16');
	setorigin(self, self.origin + self.view_ofs);
	self.view_ofs = '0 0 8';
	
	self.velocity = gib_velocity(self.health);
	self.avelocity = [0, crandom() * 600, 0];
};

vector() wall_velocity =
{
	local vector	vel;
	
	vel = normalize (self.velocity);
	vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;
	
	return vel;
};

void(vector org, vector vel) SpawnMeatSpray =
{
	local	entity missile;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_NOT;

	makevectors (self.angles);

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 250 + 50*random();

	missile.avelocity = '3000 1000 2000';
	
// set missile duration
	missile.nextthink = time + 1;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/zom_gib.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, org);
};

void(vector org, vector vel, float damage) SpawnBlood =
{
	particle (org, vel*0.1, 64, damage*2);
	particle (org, vel*0.1, 73, damage*2);
};

void(float damage) spawn_touchblood =
{
	local vector vel;

	vel = wall_velocity () * 0.2;
	SpawnBlood (self.origin + vel*0.01, vel, damage);
};

