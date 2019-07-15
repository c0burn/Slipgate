/*==========
monsterjump_touch
==========*/
static void() monsterjump_touch =
{
	if (other.flags & (FL_MONSTER | FL_FLY | FL_SWIM) != FL_MONSTER)
		return;
	if (other.health <= 0)
		return;
	if (self.netname != "")
	{
		if (other.classname != self.netname)
			return;
	}

	// set XY even if not on ground, so the jump will clear lips
	other.velocity_x = self.movedir_x * self.speed;
	other.velocity_y = self.movedir_y * self.speed;
	if (!(other.flags & FL_ONGROUND))
		return;
	other.flags = other.flags - FL_ONGROUND;
	other.velocity_z = self.height;
};

/*QUAKED trigger_monsterjump (.5 .5 .5) ? X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
Walking monsters that touch this will jump at a set "speed" and "height" according to "angle"

Keys:
"angle" - angle to fling monsters
"speed" - defaults to 200, the speed thrown forward
"height" - defaults to 200, the speed thrown upwards
"netname" - only monsters with this classname will be affected, e.g. "monster_shambler"
*/
void() trigger_monsterjump =
{
	if (!self.angles)
		self.angles = '0 360 0';
		
	SetPositiveDefault(speed, 200);
	SetPositiveDefault(height, 200);
	self.touch = monsterjump_touch;
	InitTrigger();
};
