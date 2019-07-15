static enumflags { TRIGGER_NOTOUCH, TRIGGER_START_OFF };

/*==========
InitTrigger
==========*/
void() InitTrigger =
{
	// if angles are set, the trigger is a one way touch
	if (self.angles != '0 0 0')
		SetMovedir();

	// link into world
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	setmodel (self, self.model);

	// make invisible
	self.modelindex = 0;
	self.model = "";
};

/*==========
trigger_reactivate
==========*/
static void() trigger_reactivate =
{
	// if shootable, make solid again
	if (self.max_health)
	{
		self.health = self.max_health;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
		setorigin(self, self.origin);	// link into world
	}
};

/*==========
trigger_fire
==========*/
void() trigger_fire =
{
	// already triggered
	if (self.nextthink > time)
		return;

	// bump secret counter
	if (self.classname == "trigger_secret")
	{
		if (self.enemy.classname != "player")
			return;
		found_secrets = found_secrets + 1;
		WriteByte (MSG_ALL, SVC_FOUNDSECRET);
	}

	if (self.noise != "")
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

	// fire targets
	activator = self.enemy;
	UseTargets();

	if (self.wait > 0)
	{
		self.think = trigger_reactivate;
		self.nextthink = time + self.wait;
		return;
	}
	
	remove(self);
};

/*==========
trigger_killed
==========*/
void(entity inflictor, entity attacker) trigger_killed =
{
	self.takedamage = DAMAGE_NO;
	self.enemy = attacker;
	trigger_fire();
};

/*==========
trigger_use
==========*/
void() trigger_use =
{
	self.enemy = activator;
	trigger_fire();
};

/*==========
trigger_touch
==========*/
void() trigger_touch =
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
	
	self.enemy = other;
	trigger_fire();
};

/*QUAKED trigger_multiple (.5 .5 .5) ? NOTOUCH X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
Variable sized repeatable trigger.

Keys:
"target" - entities to trigger upon firing
"killtarget" - entities to remove upon firing
"message" - will be printed to player upon activation
"delay" - will wait after activation before firing
"health" - if set, trigger must be killed to activate
"wait" - time between triggers. default 0.2
"sounds" -
0) none
1) secret
2) beep beep
3) large switch
"angle" - player must be facing this direction to activate the trigger.
0 is assumed to mean no restriction, so use 360 for an angle of 0.

Spawnflags:
If NOTOUCH is set, the trigger is only fired by other entities, not by touching.
NOTOUCH has been obsoleted by trigger_relay.
*/
void() trigger_multiple =
{
	if (self.sounds == 1)
		self.noise = "misc/secret.wav";
	else if (self.sounds == 2)
		self.noise = "misc/talk.wav";
	else if (self.sounds == 3)
		self.noise = "misc/trigger1.wav";
	if (self.noise != "")
		precache_sound(self.noise);
	
	SetFloatDefault(wait, 0.2);
	self.use = trigger_use;
	InitTrigger();

	// shootable trigger
	if (self.health > 0)
	{
		if (self.spawnflags & TRIGGER_NOTOUCH)
		{
			objerror ("health and NOTOUCH doesn't make sense\n");
			remove(self);
			return;
		}
		self.max_health = self.health;
		self.th_die = trigger_killed;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
		setorigin (self, self.origin);	// make sure it links into the world
		return;
	}
	
	if (!(self.spawnflags & TRIGGER_NOTOUCH))
		self.touch = trigger_touch;
};

/*QUAKED trigger_once (.5 .5 .5) ? NOTOUCH X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
Variable sized trigger. Triggers once, then removes itself.

Keys:
"target" - entities to trigger upon firing
"killtarget" - entities to remove upon firing
"message" - will be printed to player upon activation
"delay" - will wait after activation before firing
"health" - if set, trigger must be killed to activate
"wait" - time between triggers. default 0.2
"sounds" -
0) none
1) secret
2) beep beep
3) large switch
"angle" - player must be facing this direction to activate the trigger.
0 is assumed to mean no restriction, so use 360 for an angle of 0.

Spawnflags:
If NOTOUCH is set, the trigger is only fired by other entities, not by touching.
NOTOUCH has been obsoleted by trigger_relay.
*/
void() trigger_once =
{
	self.wait = -1;
	trigger_multiple();
};

/*QUAKED trigger_relay (.5 .5 .5) (-8 -8 -8) (8 8 8)
This fixed size trigger cannot be touched, it can only be fired by other events.
It can contain targets, killtargets, delays, and messages.
*/
void() trigger_relay =
{
	self.use = UseTargets;
};

/*QUAKED trigger_secret (.5 .5 .5) ? NOTOUCH X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
Variable sized secret counter trigger. Triggers once, then removes itself.

Keys:
"target" - entities to trigger upon firing
"killtarget" - entities to remove upon firing
"message" - will be printed to player upon activation. default "You found a secret area!"
"delay" - will wait after activation before firing
"health" - if set, trigger must be killed to activate
"sounds" -
1) secret (default)
2) beep beep
3) large switch
"angle" - player must be facing this direction to activate the trigger.
0 is assumed to mean no restriction, so use 360 for an angle of 0.

Spawnflags:
If NOTOUCH is set, the trigger is only fired by other entities, not by touching.
NOTOUCH has been obsoleted by trigger_relay.
*/
void() trigger_secret =
{
	total_secrets = total_secrets + 1;
	self.wait = -1;
	SetStringDefault(message, "Your found a secret area!");
	SetPositiveDefault(sounds, 1);
	trigger_multiple();
};

static enumflags { COUNTER_NOMESSAGE };

/*==========
counter_use
==========*/
void() counter_use =
{
	self.count = self.count - 1;
	
	// more to go
	if (self.count > 0)
	{
		if (activator.classname == "player")
		{
			if (!(self.spawnflags & COUNTER_NOMESSAGE))
			{
				if (self.count > 3)
					centerprint (activator, "There are more to go...");
				else if (self.count == 3)
					centerprint (activator, "Only 3 more to go...");
				else if (self.count == 2)
					centerprint (activator, "Only 2 more to go...");
				else
					centerprint (activator, "Only 1 more to go...");
			}
		}
		return;
	}
	
	self.use = SUB_Null;	// don't allow further triggering
	
	if (activator.classname == "player")
	{
		if (!(self.spawnflags & COUNTER_NOMESSAGE))
			centerprint(activator, "Sequence completed!");
	}
	
	// fire targets
	self.enemy = activator;
	trigger_fire();
};

/*QUAKED trigger_counter (.5 .5 .5) ? NOMESSAGE X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
Acts as an intermediary for an action that takes multiple inputs - cannot be interacted with directly.
It will print "Only X more to go.." when triggered and "Sequence completed!" when finished.
After the counter has been triggered "count" times (default 2), it will fire all of it's targets and remove itself.

Spawnflags:
NOMESSAGE - don't display any messages
*/
void() trigger_counter =
{
	SetPositiveDefault(count, 2);
	self.use = counter_use;
};

/*==========
skill_touch
==========*/
static void() skill_touch =
{
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	cvar_set("skill", self.message);
};

/*QUAKED trigger_setskill (.5 .5 .5) ? X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
Trigger that sets "skill" to the value of "message".
*/
void() trigger_setskill =
{
	self.touch = skill_touch;
	InitTrigger();
};

/*==========
onlyregistered_touch
==========*/
static void() onlyregistered_touch =
{
	if (other.classname != "player")
		return;
	if (self.attack_finished > time)
		return;
	self.attack_finished = time + 2;
	if (cvar("registered"))
	{
		self.message = "";
		activator = other;
		UseTargets ();
		remove(self);
		return;
	}

	if (self.message != "")
	{
		centerprint (other, self.message);
		sound (other, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
	}
};

/*QUAKED trigger_onlyregistered (.5 .5 .5) ? X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
Only fires if playing the registered version, otherwise prints the message.
*/
void() trigger_onlyregistered =
{
	self.touch = onlyregistered_touch;
	InitTrigger();
};
