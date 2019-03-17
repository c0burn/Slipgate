
void() train_next;
void() func_train_find;

void() train_blocked =
{
	if (time < self.attack_finished)
		return;
	self.attack_finished = time + 0.5;
	Damage (other, self, self, self.dmg);
};
void() train_use =
{
	if (self.think != func_train_find)
		return;		// already activated
	train_next();
};

void() train_wait =
{
	if (self.wait)
	{
		self.nextthink = self.ltime + self.wait;
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	}
	else
		self.nextthink = self.ltime + 0.1;
	
	self.think = train_next;
};

void() train_next =
{
	local entity	targ;

	targ = find (world, targetname, self.target);
	self.target = targ.target;
	if (!self.target)
		objerror ("train_next: no next target");
	if (targ.wait)
		self.wait = targ.wait;
	else
		self.wait = 0;
	sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	SUB_CalcMove (targ.origin - self.mins, self.speed, train_wait);
};

void() func_train_find =

{
	local entity	targ;

	targ = find (world, targetname, self.target);
	self.target = targ.target;
	setorigin (self, targ.origin - self.mins);
	if (!self.targetname)
	{	// not triggered, so start immediately
		self.nextthink = self.ltime + 0.1;
		self.think = train_next;
	}
};

/*QUAKED func_train (0 .5 .8) ?
Trains are moving platforms that players can ride.
The targets origin specifies the min point of the train at each corner.
The train spawns at the first target it is pointing at.
If the train is the target of a button or trigger, it will not begin moving until activated.
speed	default 100
dmg		default	2
sounds
1) ratchet metal

*/
void() func_train =
{	
	if (!self.speed)
		self.speed = 100;
	if (!self.target)
		objerror ("func_train without a target");
	if (!self.dmg)
		self.dmg = 2;

	if (self.sounds == 0)
	{
		self.noise = ("misc/null.wav");
		precache_sound ("misc/null.wav");
		self.noise1 = ("misc/null.wav");
		precache_sound ("misc/null.wav");
	}

	if (self.sounds == 1)
	{
		self.noise = ("plats/train2.wav");
		precache_sound ("plats/train2.wav");
		self.noise1 = ("plats/train1.wav");
		precache_sound ("plats/train1.wav");
	}

	self.cnt = 1;
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	self.blocked = train_blocked;
	self.use = train_use;
	self.classname = "train";

	setmodel (self, self.model);
	setsize (self, self.mins , self.maxs);
	setorigin (self, self.origin);

// start trains on the second frame, to make sure their targets have had
// a chance to spawn
	self.nextthink = self.ltime + 0.1;
	self.think = func_train_find;
};

void() teleporttrain_next =
{
	if (!self.target)
	{
		self.enemy = world;
		return;
	}
	self.enemy = find(world, targetname, self.target);
	if (self.enemy.classname == "path_corner")
	{
		vector dir = normalize(self.enemy.origin - self.origin);
		self.velocity = dir * self.speed;
		self.target = self.enemy.target;
	}
	else
	{
		objerror("unable to find target\n");
		remove(self);
	}
};

void() teleporttrain_move =
{	
	if (!self.enemy)
	{
		self.velocity = '0 0 0';
		self.think = SUB_Null;
		return;
	}
	
	if (vlen(self.origin - self.enemy.origin) < self.size_x)
		teleporttrain_next();

	self.think = teleporttrain_move;
	self.nextthink = time + 0.1;
};

void() teleporttrain_use =
{
	if (self.think == teleporttrain_move)	// already moving
		return;

	teleporttrain_next();
	teleporttrain_move();
};

void() teleporttrain_find =
{
	// always start positioned on the first path_corner
	self.enemy = find(world, targetname, self.target);
	if (self.enemy.classname == "path_corner")
	{
		setorigin (self, self.enemy.origin);
		self.target = self.enemy.target;
	}
	else
	{
		objerror("unable to find target\n");
		remove(self);
		return;
	}
	
	// not triggered, so start immediately
	if (!self.targetname)
	{
		self.think = teleporttrain_move;
		self.nextthink = time + 0.1;
	}
	else
		self.use = teleporttrain_use;
};

/*QUAKED misc_teleporttrain (.5 .5 .5) (-16 -16 -16) (16 16 16) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{	model("progs/teleport.mdl");	}

Teleporter target for final boss level. Must target a series of 'path_corner' entities.
It will position itself on its first target at map load.
If a targetname is set, it must be triggered to start moving, otherwise it will start automatically.
*/
void() misc_teleporttrain =
{	
	if (!self.target)
	{
		objerror ("no target");
		remove(self);
		return;
	}
	if (self.speed <= 0)
		self.speed = 100;

	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_FLY;
	precache_model ("progs/teleport.mdl");
	setmodel (self, "progs/teleport.mdl");
	setsize (self, '-16 -16 -16', '16 16 16');

	self.avelocity = '100 200 300';
	
	self.think = teleporttrain_find;
	self.nextthink = time + 0.1;
};
