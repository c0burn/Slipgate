#define SMALL_FLOAT (float)(__variant)0x00800000i

/*==========
ladder_touch
==========*/
static void() ladder_touch =
{
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	
	// check player is facing the right way
	if (self.movedir)
	{
		makevectors (other.angles);
		if (v_forward * self.movedir < 0)
			return;
	}
	other.flags2 = other.flags2 | FL2_ONLADDER;
	other.gravity = SMALL_FLOAT;	// because setting it to 0 would be normal gravity
};

/*QUAKED trigger_ladder (.5 .5 .5) ? X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
Invisible ladder trigger.
When the player is touching this trigger, they can climb by holding jump.
If "angle" is set, the player must face that direction to climb the ladder.
An angle of 0 is assumed to mean no direction, so use an angle of 360 instead.
*/
void() trigger_ladder =
{
	InitTrigger();
	self.touch = ladder_touch;
};
