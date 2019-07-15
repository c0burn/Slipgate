/*==========
hurt_touch

this was seriously bugged in id1. now correctly damages everything touching it.
==========*/
static void() hurt_touch =
{
	force_retouch = 2;
	
	if (other.takedamage)
	{
		if (other.hurt_time > time)
			return;
		Damage (other, self, self, self.dmg);
		other.hurt_time = time + self.wait;
	}
};

/*QUAKED trigger_hurt (.5 .5 .5) ? X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
A trigger that damages anything alive that touches it.

Keys:
dmg - damage to deal. default 5.
wait - time in seconds between causing damage. default 1
*/
void() trigger_hurt =
{
	self.touch = hurt_touch;
	SetPositiveDefault(dmg, 5);
	SetPositiveDefault(wait, 1);
	InitTrigger();
};

/*==========
void_touch
==========*/
static void() void_touch =
{
	force_retouch = 2;
	
	// just remove items and monsters
	if (other.flags & FL_ITEM || other.flags & FL_MONSTER)
	{
		remove(other);
		return;
	}
	
	// insta kill players
	if (other.flags & FL_CLIENT)
	{
		// remove all armor
		other.items = other.items - (other.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
		other.armortype = other.armorvalue = 0;
		// remove pent
		other.items = other.items - other.items & IT_INVULNERABILITY;
		other.invincible_finished = other.invincible_time = other.invincible_sound = 0;
		
		stuffcmd(other, "v_cshift 0 0 0 255\n");
		
		Damage (other, self, self, other.health);
		return;
	}
};

/*QUAKED trigger_void (.5 .5 .5) ? X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
A variable sized trigger designed for "void" areas that removes items, projectiles and monsters touching it.
Always kills the player regardless of pentagram or armor.
*/
void() trigger_void =
{
	self.touch = void_touch;
	InitTrigger();
};
