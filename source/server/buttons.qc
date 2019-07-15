static enumflags { BUTTON_START_OFF };

/*==========
button_done

the button is back in its original position
==========*/
static void() button_done =
{
	self.state = STATE_BOTTOM;
};

/*==========
button_return

the button starts to return to its original position
==========*/
static void() button_return =
{
	self.state = STATE_DOWN;
	// use normal textures
	self.frame = 0;
	// can be shot again
	if (self.max_health)
	{
		self.health = self.max_health;
		self.takedamage = DAMAGE_YES;
	}
	SUB_CalcMove (self.pos1, self.speed, button_done);
};

/*==========
button_wait

the button has reached it's secondary position
==========*/
static void() button_wait =
{
	self.state = STATE_TOP;
	// use alternatve textures
	self.frame = 1;
	// fire targets	
	activator = self.enemy;
	UseTargets();
	
	// return after a delay of self.wait
	if (self.wait > 0)
	{
		self.think = button_return;
		self.nextthink = self.ltime + self.wait;
	}
	// never return
	else
	{
		self.think = SUB_Null;
		self.nextthink = -1;
	}
};

/*==========
button_fire

the button has been activated by trigger, touch or damage
==========*/
static void() button_fire =
{
	// already activated
	if (self.state == STATE_UP || self.state == STATE_TOP)
		return;

	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
	self.state = STATE_UP;
	SUB_CalcMove (self.pos2, self.speed, button_wait);
};

/*==========
button_touch
==========*/
static void() button_touch =
{
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	self.enemy = other;
	button_fire ();
};

/*==========
button_killed

the button has been shot
==========*/
static void(entity inflictor, entity attacker) button_killed =
{
	self.takedamage = DAMAGE_NO;	// will be restored upon return
	self.enemy = attacker;
	button_fire();
};

/*==========
button_activate

enable the button for pushing or shooting
==========*/
static void() button_activate =
{
	// use normal texture
	self.frame = 0;
	
	// shootable button
	if (self.health > 0)
	{
		self.max_health = self.health;
		self.takedamage = DAMAGE_YES;
		self.th_die = button_killed;
	}
	// pushable button
	else
		self.touch = button_touch;
};

/*==========
button_use

the button has been triggered
==========*/
static void() button_use =
{
	// if the button starts disabled, using it enables it
	if (self.spawnflags & BUTTON_START_OFF)
	{
		self.spawnflags = self.spawnflags - BUTTON_START_OFF;
		button_activate();
		return;
	}

	self.enemy = activator;
	button_fire();
};

/*==========
button_blocked

do nothing
==========*/
static void() button_blocked =
{
	
};

/*QUAKED func_button (0 .5 .8) ? START_OFF X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
A button that can either be pushed or shot.

When a button is activated, it moves the distance of its size,
in the direction of its angle, leaving a "lip" at the end of the move.
Alternatively, you can specify a set "distance" to move.

When the move is completed, it triggers all of its targets, waits some time,
then returns to its original position where it can be pushed or shot again.

Spawnflags:
START_OFF - the button starts in a disabled state, and it must be triggered to enable it.
Once enabled, it acts like any other button.

Keys:
"target" - entities with a matching targetname will be triggered.
"killtarget" - entities with a matching targetname will be removed.
"targetname" - if triggered, the button will fire, unless it's already in motion
 or switched off. if switched off, it will enable itself.
"message" - message to print to player on activation.
"delay" - button will wait some time before triggering its targets.
"angle" - direction of movement. use -1 for up and -2 for down.
"speed"	- speed of movement. default 40.
"wait" - wait before returning. default 1 second. use -1 to never return.
"lip" - number of units to leave at end of the move. default 4.
"distance" - manually specify the distance to move, ignoring the size and lip
"health" - if set, the button must be shot rather than pushed.
"sounds" -
-1) custom sound
0) steam metal
1) wooden clunk
2) metallic click
3) in-out
"noise" - custom sound to use for button activation
*/
void() func_button =
{
	if (self.sounds == 0)
		self.noise = "buttons/airbut1.wav";
	else if (self.sounds == 1)
		self.noise = "buttons/switch21.wav";
	else if (self.sounds == 2)
		self.noise = "buttons/switch02.wav";
	else if (self.sounds == 3)
		self.noise = "buttons/switch04.wav";
	if (!self.noise)
	{
		objerror("noise must be set for custom sound\n");
		remove(self);
		return;
	}
	precache_sound (self.noise);
	
	SetPositiveDefault(health, 0);
	SetPositiveDefault(speed, 40);
	SetFloatDefault(wait, 1);
	SetFloatDefault(lip, 4);

	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel (self, self.model);

	// calculate starting and secondary position
	SetMovedir();
	self.state = STATE_BOTTOM;
	self.pos1 = self.origin;
	if (self.distance > 0)
		self.pos2 = self.pos1 + (self.movedir * self.distance);
	else
		self.pos2 = self.pos1 + self.movedir * (fabs(self.movedir*self.size) - self.lip);

	self.blocked = button_blocked;
	self.use = button_use;
	
	if (self.spawnflags & BUTTON_START_OFF)
	{
		dprint("potential button with erroneous spawnflag at ");
		dprint(vtos(realorigin(self)));
		dprint("\n");
		
		self.frame = 1;	// use alternative texture
		return;
	}

	button_activate();
};
