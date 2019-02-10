void(entity attacker, float damage) SUB_PainNull = {};

void() SUB_Null = {};

void() SUB_Remove = {remove(self);};

void() SUB_Fade =
{
	if (self.alpha == 0)
		self.alpha = 1;
		
	self.alpha = self.alpha - 0.1;
	if (self.alpha <= 0)
	{
		remove(self);
		return;
	}
	
	self.think = SUB_Fade;
	self.nextthink = time + 0.1;
};



/*
QuakeEd only writes a single float for angles (bad idea), so up and down are
just constant angles.
*/
void() SetMovedir =
{
	if (self.angles == '0 -1 0')
		self.movedir = '0 0 1';
	else if (self.angles == '0 -2 0')
		self.movedir = '0 0 -1';
	else
	{
		makevectors (self.angles);
		self.movedir = v_forward;
	}
	
	self.angles = '0 0 0';
};

/*
================
InitTrigger
================
*/
void() InitTrigger =
{
	if (self.angles)
		SetMovedir();

	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model);
	self.modelindex = 0;
	self.model = "";
};

/*
=============
SUB_CalcMove

calculate self.velocity and self.nextthink to reach dest from
self.origin traveling at speed
===============
*/

void(vector tdest, float tspeed, void() func) SUB_CalcMove =
{
local vector	vdestdelta;
local float		len, traveltime;

	if (!tspeed)
		objerror("No speed is defined!");

	self.think1 = func;
	self.finaldest = tdest;
	self.think = SUB_CalcMoveDone;

	if (tdest == self.origin)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}
		
// set destdelta to the vector needed to move
	vdestdelta = tdest - self.origin;
	
// calculate length of vector
	len = vlen (vdestdelta);
	
// divide by speed to get time to reach dest
	traveltime = len / tspeed;

	if (traveltime < 0.1)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.1;
		return;
	}
	
// set nextthink to trigger a think when dest is reached
	self.nextthink = self.ltime + traveltime;

// scale the destdelta vector by the time spent traveling to get velocity
	self.velocity = vdestdelta * (1/traveltime);	// qcc won't take vec/float	
};

/*
============
After moving, set origin to exact final destination
============
*/
void()  SUB_CalcMoveDone =
{
	setorigin(self, self.finaldest);
	self.velocity = '0 0 0';
	self.nextthink = -1;
	if (self.think1)
		self.think1();
};




//=============================================================================

void() DelayThink =
{
	activator = self.enemy;
	SUB_UseTargets ();
	remove(self);
};

void() DelayKill =
{
	entity t = world;
	while (1)
	{
		t = find(t, targetname, self.killtarget);
		if (!t)
			break;
		remove(t);
	}
	
	remove(self);
};

/*
==============================
SUB_UseTargets

the global "activator" should be set to the entity that initiated the firing.

If self.delay is set, a DelayedUse entity will be created that will actually
do the SUB_UseTargets after that many seconds have passed.

Centerprints any self.message to the activator.

Removes all entities with a targetname that match self.killtarget,
and removes them, so some events can remove other triggers.

Search for (string)targetname in all entities that
match (string)self.target and call their .use function

==============================
*/
void() SUB_UseTargets =
{
	// if delay is set, create a temporary entity to fire later
	if (self.delay)
	{
		entity t = spawn();
		t.classname = "DelayedUse";
		t.think = DelayThink;
		t.nextthink = time + self.delay;
		t.enemy = activator;
		t.message = self.message;
		t.target = self.target;
		t.killtarget = self.killtarget;
		return;
	}
	
	// print any message
	if (activator.classname == "player" && self.message != "")
	{
		centerprint (activator, self.message);
		if (!self.noise)
			sound (activator, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
	}

	// remove any killtargets
	// in id1, if both target and killtarget was set,
	// only killtarget was ever used and generally a triger_relay was used
	// if a mapper wanted to target and killtarget something at the same time
	// this mod allows both to be set, however id1 contains several maps with
	// triggers that contain an identical target + killtarget so if we fix
	// this bug we get some unintended side effects
	// the solution is to remove the target field ONLY if it's identical to killtarget,
	// as it would have had no effect in id1
	if (self.killtarget != "")
	{
		if (self.target == self.killtarget)
		{
			dprint(self.classname);
			dprint(" has target==killtarget\n");
			self.target = string_null;
		}

		// we use a think to remove the killtargets to avoid
		// any SV_TouchLinks bugs - notably e2m2 if you shoot one trigger
		// and jump over the gap on easy skill
		// most modern sourceports don't strictly require this,
		// but best to do things the clean way
		t = spawn();
		t.classname = "DelayedKill";
		t.think = DelayKill;
		t.nextthink = time;
		t.killtarget = self.killtarget;
	}
	
	// fire any targets
	if (self.target != "")
	{
		entity act = activator;
		t = world;
		while (1)
		{
			t = find (t, targetname, self.target);
			if (!t)
				break;
				
			entity stemp = self;
			entity otemp = other;
			self = t;
			other = stemp;
			
			if (self.use)
				self.use();
				
			self = stemp;
			other = otemp;
			activator = act;
		}
	}
};

/*

in nightmare mode, all attack_finished times become 0
some monsters refire twice automatically

*/

void(float normal) SUB_AttackFinished =
{
	self.cnt = 0;		// refire count for nightmare
	if (skill != 3)
		self.attack_finished = time + normal;
};

float (entity targ) visible;

void (void() thinkst) SUB_CheckRefire =
{
	if (skill != 3)
		return;
	if (self.cnt == 1)
		return;
	if (!visible (self.enemy))
		return;
	self.cnt = 1;
	self.think = thinkst;
};
