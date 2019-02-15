/*==========
func_wall_use
==========*/
void() func_wall_use =
{
	self.frame = 1 - self.frame;
};

/*QUAKED func_wall (0 .5 .8) ? X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
Simple solid bmodel

Keys:
"targetname" "name"
if triggered, the bmodel will toggle its frame/animation sequence from +0 -> +9 to +a -> +j
*/
void() func_wall =
{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};

/*QUAKED func_illusionary (0 .5 .8) ? X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
A simple bmodel that looks solid but lets the player walk through it

Keys:
"targetname" "name"
if triggered, the bmodel will toggle its frame/animation sequence from +0 -> +9 to +a -> +j
*/
void() func_illusionary =
{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel (self, self.model);
	
	if (self.targetname != "")
		self.use = func_wall_use;
	else
		makestatic(self);
};

/*QUAKED func_episodegate (0 .5 .8) ? E1 E2 E3 E4 X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
This bmodel will only appear if the episode has already been completed.

Keys:
"targetname" "name"
if triggered, the bmodel will toggle its frame/animation sequence from +0 -> +9 to +a -> +j

Spawnflags:
E1, E2, E3, E4
*/
void() func_episodegate =
{
	if (!(serverflags & self.spawnflags))
	{
		remove(self);
		return;
	}
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};

/*QUAKED func_bossgate (0 .5 .8) ? X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
This bmodel appears unless the player has all of the episode runes.

Keys:
"targetname" "name"
if triggered, the bmodel will toggle its frame/animation sequence from +0 -> +9 to +a -> +j
*/
void() func_bossgate =
{
	if ((serverflags & 15) == 15)
	{
		remove(self);
		return;
	}
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	self.use = func_wall_use;
	setmodel (self, self.model);
};
