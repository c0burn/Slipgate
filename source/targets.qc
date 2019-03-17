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
DelayKilltargets

actually removes any kiltargets
==========*/
void() DelayKilltargets =
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

If "delay" is set, a temporary entity will be created that will fire the targets after the delay
==========*/
void() UseTargets =
{
	entity e;
	
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

	// remove any killtargets
	// in id1, if both target and killtarget were set, target was ignored
	// this mod allows both to be set, however id1 contains several maps with
	// triggers that contain an identical target + killtarget so by adding
	// this feature we can get some unintended side effects
	// the solution is to remove the target field ONLY if it's identical to killtarget,
	// as it would have had no effect in id1
	if (self.killtarget != "")
	{
		if (self.target == self.killtarget)
			self.target = "";

		// we use a think to remove the killtargets because we could be in the 
		// middle of a touch function
		// this works around any SV_TouchLinks bugs - notably e2m2 if you shoot
		// one trigger and jump over the gap on easy skill it will crash vanilla engines
		// most modern sourceports have a fix for this, however this way we also fix dosquake..
		e = spawn();
		e.classname = "DelayKilltargets";
		e.killtarget = self.killtarget;
		e.think = DelayKilltargets;
		e.nextthink = time;
	}
	
	// fire any targets
	if (self.target != "")
	{
		entity act = activator;
		e = world;
		while (1)
		{
			e = find (e, targetname, self.target);
			if (!e)
				break;
				
			entity stemp = self;
			entity otemp = other;
			self = e;
			other = stemp;

			if (self.use)
				self.use();

			self = stemp;
			other = otemp;
			activator = act;
		}
	}
};
