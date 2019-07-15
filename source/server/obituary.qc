/*==========
Obituary
==========*/
void(entity targ, entity attacker, entity inflictor) Obituary =
{
	string deathstring, deathstring2;
	float rnum = random();

	// regular telefrag
	if (attacker.classname == "teledeath")
	{
		bprint (targ.netname);
		bprint (" was telefragged by ");
		bprint (attacker.owner.netname);
		bprint ("\n");

		attacker.owner.frags = attacker.owner.frags + 1;
		return;
	}

	// inverse pentagram telefrag
	if (attacker.classname == "teledeath2")
	{
		bprint ("Satan's power deflects ");
		bprint (targ.netname);
		bprint ("'s telefrag\n");

		targ.frags = targ.frags - 1;
		return;
	}

	// double pentagram telefrag
	if (attacker.classname == "teledeath3")
	{
		bprint (targ.netname);
		bprint (" was telefragged by ");
		bprint (attacker.owner.netname);
		bprint ("'s Satan power\n");
		
		attacker.owner.frags = attacker.owner.frags + 1;
		return;
	}
	
	if (attacker.classname == "player")
	{
		// killed self
		if (targ == attacker)
		{
			attacker.frags = attacker.frags - 1;
			bprint (targ.netname);

			if (targ.weapon == IT_LIGHTNING && targ.waterlevel > 1)
			{
				bprint (" discharges into the water.\n");
				return;
			}
			if (inflictor.classname == "grenade")
				bprint (" tries to put the pin back in\n");
			else
				bprint (" becomes bored with life\n");
			return;
		}
		// killed a team mate
		else if ( (teamplay == 2) && (targ.team > 0) && (targ.team == attacker.team) )
		{
			bprint (attacker.netname);
			
			if (rnum < 0.25)
				deathstring = " mows down a teammate\n";
			else if (rnum < 0.50)
				deathstring = " checks his glasses\n";
			else if (rnum < 0.75)
				deathstring = " gets a frag for the other team\n";
			else
				deathstring = " loses another friend\n";
			
			bprint (deathstring);
			attacker.frags = attacker.frags - 1;
			return;
		}
		else
		{
			attacker.frags = attacker.frags + 1;

			rnum = attacker.weapon;
			if (rnum == IT_AXE)
			{
				deathstring = " was ax-murdered by ";
				deathstring2 = "\n";
			}
			if (rnum == IT_SHOTGUN)
			{
				deathstring = " chewed on ";
				deathstring2 = "'s boomstick\n";
			}
			if (rnum == IT_SUPER_SHOTGUN)
			{
				deathstring = " ate 2 loads of ";
				deathstring2 = "'s buckshot\n";
			}
			if (rnum == IT_NAILGUN)
			{
				deathstring = " was nailed by ";
				deathstring2 = "\n";
			}
			if (rnum == IT_SUPER_NAILGUN)
			{
				deathstring = " was punctured by ";
				deathstring2 = "\n";
			}
			if (rnum == IT_GRENADE_LAUNCHER)
			{
				deathstring = " eats ";
				deathstring2 = "'s pineapple\n";
				if (targ.health < -40)
				{
					deathstring = " was gibbed by ";
					deathstring2 = "'s grenade\n";
				}
			}
			if (rnum == IT_ROCKET_LAUNCHER)
			{
				deathstring = " rides ";
				deathstring2 = "'s rocket\n";
				if (targ.health < -40)
				{
					deathstring = " was gibbed by ";
					deathstring2 = "'s rocket\n" ;
				}
			}
			if (rnum == IT_LIGHTNING)
			{
				deathstring = " accepts ";
				if (attacker.waterlevel > 1)
					deathstring2 = "'s discharge\n";
				else
					deathstring2 = "'s shaft\n";
			}
			bprint (targ.netname);
			bprint (deathstring);
			bprint (attacker.netname);
			bprint (deathstring2);
		}
		return;
	}
	else
	{
		targ.frags = targ.frags - 1;
		bprint (targ.netname);

		// killed by a monster?
		if (attacker.flags & FL_MONSTER)
		{
			if (attacker.classname == "monster_army")
				bprint (" was shot by a Grunt\n");
			if (attacker.classname == "monster_boss")
				bprint (" became one with Chthon\n");
			if (attacker.classname == "monster_demon1")
				bprint (" was eviscerated by a Fiend\n");
			if (attacker.classname == "monster_dog")
				bprint (" was mauled by a Rottweiler\n");
			if (attacker.classname == "monster_enforcer")
				bprint (" was blasted by an Enforcer\n");
			if (attacker.classname == "monster_fish")
				bprint (" was fed to the Rotfish\n");
			if (attacker.classname == "monster_hell_knight")
				bprint (" was slain by a Death Knight\n");
			if (attacker.classname == "monster_knight")
				bprint (" was slashed by a Knight\n");
			if (attacker.classname == "monster_ogre")
				bprint (" was destroyed by an Ogre\n");
			if (attacker.classname == "monster_shalrath")
				bprint (" was exploded by a Vore\n");
			if (attacker.classname == "monster_shambler")
				bprint (" was smashed by a Shambler\n");
			if (attacker.classname == "monster_tarbaby")
				bprint (" was slimed by a Spawn\n");
			if (attacker.classname == "monster_wizard")
				bprint (" was scragged by a Scrag\n");
			if (attacker.classname == "monster_zombie")
				bprint (" joins the Zombies\n");

			return;
		}

		// tricks and traps
		if (attacker.classname == "explobox")
		{
			bprint (" blew up\n");
			return;
		}
		if (attacker.solid == SOLID_BSP && attacker != world)
		{
			bprint (" was squished\n");
			return;
		}
		if (attacker.classname == "trap_shooter" || attacker.classname == "trap_spikeshooter")
		{
			bprint (" was spiked\n");
			return;
		}
		if (attacker.classname == "fireball")
		{
			bprint (" ate a lavaball\n");
			return;
		}
		if (attacker.classname == "trigger_changelevel")
		{
			bprint (" tried to leave\n");
			return;
		}
		if (attacker.classname == "trigger_hurt")
		{
			bprint (" was in the wrong place at the wrong time\n");
			return;
		}
		if (attacker.classname == "trigger_void")
		{
			bprint (" touched the void\n");
			return;
		}
			
		// in-water deaths
		rnum = targ.watertype;
		if (rnum == CONTENT_WATER)
		{
			if (random() < 0.5)
				bprint (" sleeps with the fishes\n");
			else
				bprint (" sucks it down\n");
			return;
		}
		else if (rnum == CONTENT_SLIME)
		{
			if (random() < 0.5)
				bprint (" gulped a load of slime\n");
			else
				bprint (" can't exist on slime alone\n");
			return;
		}
		else if (rnum == CONTENT_LAVA)
		{
			if (targ.health < -15)
			{
				bprint (" burst into flames\n");
				return;
			}
			if (random() < 0.5)
				bprint (" turned into hot slag\n");
			else
				bprint (" visits the Volcano God\n");
			return;
		}

		// fell to their death?
		if (targ.deathtype == "falling")
		{
			targ.deathtype = "";
			bprint (" fell to his death\n");
			return;
		}

		// hell if I know; he's just dead!!!
		bprint (" died\n");
	}
};
