/*==========
GotoNextMap
========*/
void() GotoNextMap =
{
	if (cvar("samelevel") && (deathmatch || coop))
		changelevel (mapname);
	else
		changelevel (nextmap);
};

/*==========
ExitIntermission
==========*/
void() ExitIntermission =
{
	if (deathmatch)
	{
		GotoNextMap();
		return;
	}

	intermission_exittime = time + 1;
	intermission_running = intermission_running + 1;

	//
	// run some text if at the end of an episode
	//
	if (intermission_running == 2)
	{
		if (world.model == "maps/e1m7.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);
			if (!cvar("registered"))
			{
				WriteByte (MSG_ALL, SVC_FINALE);
				WriteString (MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task in the other three\nhaunted lands of Quake. Or are you? If\nyou don't register Quake, you'll never\nknow what awaits you in the Realm of\nBlack Magic, the Netherworld, and the\nElder World!");
			}
			else
			{
				WriteByte (MSG_ALL, SVC_FINALE);
				WriteString (MSG_ALL, "As the corpse of the monstrous entity\nChthon sinks back into the lava whence\nit rose, you grip the Rune of Earth\nMagic tightly. Now that you have\nconquered the Dimension of the Doomed,\nrealm of Earth Magic, you are ready to\ncomplete your task. A Rune of magic\npower lies at the end of each haunted\nland of Quake. Go forth, seek the\ntotality of the four Runes!");
			}
			return;
		}
		else if (world.model == "maps/e2m6.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);

			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "The Rune of Black Magic throbs evilly in\nyour hand and whispers dark thoughts\ninto your brain. You learn the inmost\nlore of the Hell-Mother; Shub-Niggurath!\nYou now know that she is behind all the\nterrible plotting which has led to so\nmuch death and horror. But she is not\ninviolate! Armed with this Rune, you\nrealize that once all four Runes are\ncombined, the gate to Shub-Niggurath's\nPit will open, and you can face the\nWitch-Goddess herself in her frightful\notherworld cathedral.");
			return;
		}
		else if (world.model == "maps/e3m6.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);

			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "The charred viscera of diabolic horrors\nbubble viscously as you seize the Rune\nof Hell Magic. Its heat scorches your\nhand, and its terrible secrets blight\nyour mind. Gathering the shreds of your\ncourage, you shake the devil's shackles\nfrom your soul, and become ever more\nhard and determined to destroy the\nhideous creatures whose mere existence\nthreatens the souls and psyches of all\nthe population of Earth.");
			return;
		}
		else if (world.model == "maps/e4m7.bsp")
		{
			WriteByte (MSG_ALL, SVC_CDTRACK);
			WriteByte (MSG_ALL, 2);
			WriteByte (MSG_ALL, 3);

			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "Despite the awful might of the Elder\nWorld, you have achieved the Rune of\nElder Magic, capstone of all types of\narcane wisdom. Beyond good and evil,\nbeyond life and death, the Rune\npulsates, heavy with import. Patient and\npotent, the Elder Being Shub-Niggurath\nweaves her dire plans to clear off all\nlife from the Earth, and bring her own\nfoul offspring to our world! For all the\ndwellers in these nightmare dimensions\nare her descendants! Once all Runes of\nmagic power are united, the energy\nbehind them will blast open the Gateway\nto Shub-Niggurath, and you can travel\nthere to foil the Hell-Mother's plots\nin person.");
			return;
		}

		GotoNextMap();
	}

	if (intermission_running == 3)
	{
		if (!cvar("registered"))
		{	// shareware episode has been completed, go to sell screen
			WriteByte (MSG_ALL, SVC_SELLSCREEN);
			return;
		}
		if ( (serverflags & 15) == 15)
		{
			WriteByte (MSG_ALL, SVC_FINALE);
			WriteString (MSG_ALL, "Now, you have all four Runes. You sense\ntremendous invisible forces moving to\nunseal ancient barriers. Shub-Niggurath\nhad hoped to use the Runes Herself to\nclear off the Earth, but now instead,\nyou will use them to enter her home and\nconfront her as an avatar of avenging\nEarth-life. If you defeat her, you will\nbe remembered forever as the savior of\nthe planet. If she conquers, it will be\nas if you had never been born.");
			return;
		}
	}

	GotoNextMap();
};

/*==========
IntermissionChangeSpot
==========*/
static void() IntermissionChangeSpot =
{
	if (!(self.flags & FL_JUMPRELEASED))
		return;
	self.flags = self.flags - FL_JUMPRELEASED;

	// move to the next spot, if available
	entity nextspot = self.enemy.enemy;
	if (!nextspot)
		return;

	self.enemy = nextspot;
	self.angles = self.v_angle = nextspot.mangle;
	self.fixangle = TRUE;
	setorigin (self, nextspot.origin);
};

/*==========
IntermissionThink

called by players from PlayerPreThink
==========*/
void() IntermissionThink =
{
	if (self.button2)
		IntermissionChangeSpot();
	else
		self.flags = self.flags | FL_JUMPRELEASED;

	if (time < intermission_exittime || intermission_exittime == -1)
		return;
	if (!self.button0)
		return;
	ExitIntermission();
};

/*==========
FindIntermission
==========*/
static entity() FindIntermission =
{
	// count the number of intermission spots in the map,
	// and put them into a linked list
	float count = 0;
	entity first = world;
	entity last = world;
	entity spot = find(world, classname, "info_intermission");
	while (spot)
	{
		if (!first)
			first = spot;
		if (last != world)
			last.enemy = spot;
		last = spot;
		count = count + 1;
		spot = find(spot, classname, "info_intermission");
	}
	// no intermission spots found in map, so try and use player start instead
	if (!count)
	{
		spot = find (world, classname, "info_player_start");
		if (spot)
			return spot;
		error("no intermission spot found");
	}
	last.enemy = first;		// make it a loop

	// pick a random spot
	float pick = randomrange(count) + 1;
	spot = world;
	while (pick)
	{
		spot = find(spot, classname, "info_intermission");
		pick = pick - 1;
	}
	return spot;
};

/*==========
StartIntermission
==========*/
void() StartIntermission =
{
	intermission_running = 1;
	
	if (deathmatch)
		intermission_exittime = time + 5;
	else
		intermission_exittime = time + 2;

	// change cd track
	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);
	WriteByte (MSG_ALL, 3);

	// find the intermission spot and move all players to it
	entity pos = FindIntermission();
	other = find (world, classname, "player");
	while (other != world)
	{
		other.enemy = pos;
		other.view_ofs = '0 0 0';
		other.angles = other.v_angle = pos.mangle;
		other.fixangle = TRUE;
		other.think = SUB_Null;
		other.nextthink = time + 0.1;
		other.takedamage = DAMAGE_NO;
		other.solid = SOLID_NOT;
		other.movetype = MOVETYPE_NONE;
		// we have to use a null sprite, because the
		// server won't update players with no modelindex, and
		// we now support intermission spot cycling
		setmodel (other, "progs/s_null.spr");
		setsize (other, '0 0 0', '0 0 0');
		setorigin (other, pos.origin);
		other = find (other, classname, "player");
	}

	// remove sbar and put up end of level stats
	WriteByte (MSG_ALL, SVC_INTERMISSION);
};