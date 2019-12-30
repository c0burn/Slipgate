static enumflags { SHOOTER_SUPERSPIKE, SHOOTER_LASER };

void(vector org, vector vec) LaunchLaser;

/*==========
shooter_use
==========*/
static void() shooter_use =
{
	if (self.spawnflags & SHOOTER_LASER)
	{
		sound (self, CHAN_VOICE, "enforcer/enfire.wav", 1, ATTN_NORM);
		LaunchLaser (self.origin, self.movedir);
	}
	else if (self.spawnflags & SHOOTER_SUPERSPIKE)
	{
		sound (self, CHAN_VOICE, "weapons/spike2.wav", 1, ATTN_NORM);
		launch_spike (self.origin, self.movedir);
		newmis.touch = superspike_touch;
	}
	else
	{
		sound (self, CHAN_VOICE, "weapons/rocket1i.wav", 1, ATTN_NORM);
		launch_spike (self.origin, self.movedir);
	}
	newmis.velocity = self.movedir * 500;
};

/*==========
shooter_think
==========*/
static void() shooter_think =
{
	shooter_use();
	self.think = shooter_think;
	self.nextthink = time + self.wait;
};

/*==========
shooter_precache
==========*/
static void() shooter_precache =
{
	if (self.spawnflags & SHOOTER_LASER)
	{
		precache_model2 ("progs/laser.mdl");
		precache_sound2 ("enforcer/enfire.wav");
		precache_sound2 ("enforcer/enfstop.wav");
	}
	else if (self.spawnflags & SHOOTER_SUPERSPIKE)
		precache_sound ("weapons/spike2.wav");
	else
		precache_sound("weapons/rocket1i.wav");
};

/*QUAKED trap_spikeshooter (1 .5 0) (-8 -8 -8) (8 8 8) SUPERSPIKE LASER
Fires projectiles when triggered.

Keys:
"angle" - direction of movement

Spawnflags:
If no spawnflag is set, shoots regular nails.
SUPERSPIKE - fire supernails
LASER - fire enforcer lasers
*/
void() trap_spikeshooter =
{
	shooter_precache();
	SetMovedir();
	self.use = shooter_use;
};

/*QUAKED trap_shooter (1 .5 0) (-8 -8 -8) (8 8 8) SUPERSPIKE LASER
Continuously fires projectiles.

Keys:
"angle" - direction of movement
"wait" - time between shots
"nextthink" - delay on first shot, so shooters can be staggered.

Spawnflags:
If no spawnflag is set, shoots regular nails.
SUPERSPIKE - fire supernails
LASER - fire enforcer lasers
*/
void() trap_shooter =
{
	shooter_precache();
	SetPositiveDefault(wait, 1);
	self.think = shooter_think;
	self.nextthink = self.nextthink + self.wait;
};
