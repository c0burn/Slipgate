static enumflags { PUSH_ONCE, PUSH_NO_SOUND };

/*==========
push_touch
==========*/
static void() push_touch =
{
	if (other.classname == "grenade")
		other.velocity = self.speed * self.movedir * 10;
	else if (other.health > 0)
	{
		other.velocity = self.speed * self.movedir * 10;
		if (other.classname == "player" && !(self.spawnflags & PUSH_NO_SOUND))
		{
			if (other.fly_sound < time)
			{
				other.fly_sound = time + 1.5;
				if (self.noise != "")
					sound (other, CHAN_AUTO, self.noise, 1, ATTN_NORM);
			}
		}
	}
	if (self.spawnflags & PUSH_ONCE)
	{
		self.solid = SOLID_NOT;
		self.touch = SUB_Null;
		self.think = SUB_Remove;
		self.nextthink = time;
	}
};

/*QUAKED trigger_push (.5 .5 .5) ? PUSH_ONCE NO_SOUND X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
Pushes the player in the direction of "angle" at "speed" and makes the flying wind sound.
Note that "speed" will be multiplied by a factor of 10, so 30 = 300
Use an "angle" of 360 for 0, -1 for up and -2 for down.
Set "noise" for a custom sound
Set PUSH_ONCE to remove after first use.
Set NO_SOUND to make silent.
*/
void() trigger_push =
{
	if (!(self.spawnflags & PUSH_NO_SOUND))
	{
		SetStringDefault(noise, "ambience/windfly.wav");
		precache_sound (self.noise);
	}
	SetPositiveDefault(speed, 1000);
	self.touch = push_touch;
	InitTrigger();
};