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

/*==========
SetMoveDir

the angle field in map editors is a single float, so up and down are constant values
==========*/
void() SetMovedir =
{
	if (self.angles == '0 -1 0')		// up
		self.movedir = '0 0 1';
	else if (self.angles == '0 -2 0')	// down
		self.movedir = '0 0 -1';
	else
	{
		makevectors (self.angles);
		self.movedir = v_forward;
	}
	self.angles = '0 0 0';
};

/*==========
SUB_CalcMoveDone

After moving, set origin to exact final destination and run think
==========*/
void() SUB_CalcMoveDone =
{
	setorigin(self, self.finaldest);
	self.velocity = '0 0 0';
	self.think = SUB_Null;
	self.nextthink = -1;
	if (self.think1)
		self.think1();
};

/*==========
SUB_CalcMove

calculate self.velocity and self.nextthink to reach dest from
self.origin traveling at speed
==========*/
void(vector dst, float spd, void() thnk) SUB_CalcMove =
{
	if (!spd)
	{
		objerror("no speed defined");
		return;
	}

	self.think = SUB_CalcMoveDone;
	self.think1 = thnk;
	self.finaldest = dst;
	
	if (dst == self.origin)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.01;
		return;
	}

	vector delta = dst - self.origin;
	float traveltime = vlen(delta) / spd;
	if (traveltime < 0.01)
	{
		self.velocity = '0 0 0';
		self.nextthink = self.ltime + 0.01;
		return;
	}

	self.nextthink = self.ltime + traveltime;
	self.velocity = delta / traveltime;
};

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
