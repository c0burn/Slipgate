void() train_next;

void() train_blocked =
{
	if (time < self.attack_finished)
		return;
	self.attack_finished = time + 0.5;
	Damage (other, self, self, self.dmg);
};

void() train_wait =
{
	self.think = train_next;
	if (self.wait > 0)
	{
		if (self.movetype == MOVETYPE_PUSH)
			self.nextthink = self.ltime + self.wait;
		else
			self.nextthink = time + self.wait;
			
		if (self.noise != "")
			sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	}
	else
	{
		if (self.movetype == MOVETYPE_PUSH)
			self.nextthink = self.ltime + 0.1;
		else
			self.nextthink = time + 0.1;
	}
};

void() train_next =
{
	entity targ = find(world, targetname, self.target);
	self.target = targ.target;
	if (!self.target)
	{
		self.velocity = '0 0 0';
		self.think = SUB_Null;
		self.nextthink = -1;
		objerror("train_next: no next target");
		return;
	}

	if (targ.wait > 0)
		self.wait = targ.wait;
	else
		self.wait = 0;
		
	if (self.noise1 != "")
		sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);
	SUB_CalcMove (targ.origin - self.mins, self.speed, train_wait);
};

void() train_use =
{
	self.use = SUB_Null;
	train_next();
};

void() train_find =
{
	entity targ = find(world, targetname, self.target);
	self.target = targ.target;
	setorigin (self, targ.origin - self.mins);
	if (!self.targetname)
	{
		if (self.movetype == MOVETYPE_PUSH)
			self.nextthink = self.ltime + 0.1;
		else
			self.nextthink = time + 0.1;
		self.think = train_next;
	}
	else
		self.use = train_use;
};

/*QUAKED func_train (0 .5 .8) ?
Trains are moving platforms that players can ride.
Must target a series of 'path_corner' entities.
The targets origin specifies the min point of the train at each corner.
It will always position itself on its first target at map load.
If a targetname is set, it must be triggered to start moving, otherwise it will start immediately.

speed	default 100
dmg		default	2
sounds
-1) custom, set "noise" and "noise1"
0) none
1) ratchet metal
*/
void() func_train =
{	
	if (!self.target)
	{
		objerror ("func_train without a target");
		remove(self);
		return;
	}
	
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	self.blocked = train_blocked;
	setmodel (self, self.model);
	setsize (self, self.mins, self.maxs);
	setorigin (self, self.origin);

	SetPositiveDefault(speed, 100);
	SetPositiveDefault(dmg, 2);
	if (self.sounds == 0)
	{
		self.noise = "";
		self.noise1 = "";
	}
	else if (self.sounds == 1)
	{
		self.noise = "plats/train2.wav";
		self.noise1 = "plats/train1.wav";
	}
	if (self.noise != "")
		precache_sound (self.noise);
	if (self.noise1 != "")
		precache_sound (self.noise1);
	
	self.think = train_find;
	self.nextthink = self.ltime + 0.1;
};

/*QUAKED misc_teleporttrain (.5 .5 .5) (-16 -16 -16) (16 16 16) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{	model("progs/teleport.mdl");	}

Floating teleporter target for final boss level. Must target a series of 'path_corner' entities.
It will always position itself on its first target at map load.
If a targetname is set, it must be triggered to start moving, otherwise it will start immediately.

speed	default 100
*/
void() misc_teleporttrain =
{	
	if (!self.target)
	{
		objerror ("misc_teleporttrain without a target");
		remove(self);
		return;
	}
	
	self.solid = SOLID_NOT;
	self.movetype = MOVETYPE_NOCLIP;
	precache_model ("progs/teleport.mdl");
	setmodel (self, "progs/teleport.mdl");
	setsize (self, '-16 -16 -16', '16 16 16');

	SetPositiveDefault(speed, 100);
	self.avelocity = '20 40 80';
	
	self.think = train_find;
	self.nextthink = time + 0.1;
};
