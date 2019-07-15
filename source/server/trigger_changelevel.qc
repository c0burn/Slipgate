enumflags { CHANGELEVEL_NO_INTERMISSION };

void() GotoNextMap;
void() StartIntermission;

/*==========
changelevel_touch
==========*/
void() changelevel_touch =
{
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;

	if ((cvar("noexit") && (mapname != "start") && deathmatch))
	{
		if (cvar("noexit") == 2)
			Damage (other, self, self, 50000);
		return;
	}

	if (coop || deathmatch)
	{
		bprint (other.netname);
		bprint (" exited the level\n");
	}

	nextmap = self.map;
	activator = other;
	UseTargets();

	if ((self.spawnflags & CHANGELEVEL_NO_INTERMISSION) && (!deathmatch))
	{
		GotoNextMap();
		return;
	}

	self.touch = SUB_Null;
	self.think = StartIntermission;
	self.nextthink = time + 0.1;
};

/*QUAKED trigger_changelevel (0.5 0.5 0.5) ? NO_INTERMISSION X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
When the player touches this trigger, they get sent to the map listed in the "map" key.
Unless the NO_INTERMISSION flag is set, the view will go to the info_intermission spot and display the end of level stats.
*/
void() trigger_changelevel =
{
	if (!self.map)
	{
		objerror("no map");
		remove(self);
		return;
	}
	self.touch = changelevel_touch;
	InitTrigger();
};
