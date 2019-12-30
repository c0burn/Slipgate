void() UseTargets;

/*==========
DelayUseTargets

use targets after a delay
==========*/
void() DelayUseTargets =
{
	activator = self.enemy;
	UseTargets();
	remove(self);	// temporary entity
};

/*==========
DelayKillTargets

actually removes any kiltargets
==========*/
void() DelayKillTargets =
{
	entity e = world;
	while (1)
	{
		e = find(e, targetname, self.killtarget);
		if (!e)
			break;
		remove(e);
	}
	remove(self);	// temporary entity
};

/*==========
UseTargets

"activator" should be set to the entity that initiated the firing

Centerprints any "message" to the "activator"

Removes all entities with a "targetname" that matches "killtarget"

Finds all entities with a "targetname" that matches "target" and calls their "use" function

If "delay" is set, a temporary entity will be created that will only fire the targets after the delay
==========*/
void() UseTargets =
{
	entity e, act;
	
	// if delay is set, create a temporary entity to fire later
	if (self.delay > 0)
	{
		e = spawn();
		e.classname = "DelayUseTargets";
		e.enemy = activator;
		e.message = self.message;
		e.target = self.target;
		e.killtarget = self.killtarget;
		e.think = DelayUseTargets;
		e.nextthink = time + self.delay;
		return;
	}

	// print any message if the activator is a player
	if (activator.classname == "player" && self.message != "")
	{
		centerprint (activator, self.message);
		if (!self.noise)
			sound (activator, CHAN_VOICE, "misc/talk.wav", 1, ATTN_NORM);
	}

	// remove any killtargets. we now support setting both target and killtarget on entities.
	if (self.killtarget != "")
	{
		// we use a think to remove the killtargets because we could be in the 
		// middle of a touch function, which can cause crashes in vanilla engines
		// without fixed SV_TouchLinks
		e = spawn();
		e.classname = "DelayKillTargets";
		e.killtarget = self.killtarget;
		e.think = DelayKillTargets;
		e.nextthink = time;		// do it on the next frame

		// clear out some essential fields to stop it being used before the actual removal
		e = world;
		while (1)
		{
			e = find(e, targetname, self.killtarget);
			if (!e)
				break;
			e.use = SUB_Null;
			e.touch = SUB_Null;
			e.think = SUB_Null;
			e.nextthink = -1;
		}
		
		// workaround for various maps that have triggers which contains both "target" and "killtarget"
		// set to identical values
		if (self.target == self.killtarget)
			return;
	}
	
	// fire any targets
	if (self.target != "")
	{
		act = activator;
		e = world;
		while (1)
		{
			e = find (e, targetname, self.target);
			if (!e)
				break;
			
			// save globals
			// set self to the entity being triggered and other to the activator
			entity stemp = self;
			entity otemp = other;
			self = e;
			other = stemp;

			if (self.use)
				self.use();

			// restore globals
			self = stemp;
			other = otemp;
			activator = act;
		}
	}
};
