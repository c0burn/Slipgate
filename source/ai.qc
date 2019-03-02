
entity	sight_entity;
float	sight_entity_time;

/*
=============
t_movetarget

Something has bumped into a movetarget.  If it is a monster
moving towards it, change the next destination and continue.
==============
*/
void() t_movetarget =
{
local entity	temp;

	if (other.movetarget != self)
		return;
	
	if (other.enemy)
		return;		// fighting, not following a path

	temp = self;
	self = other;
	other = temp;

	if (self.classname == "monster_ogre")
		sound (self, CHAN_VOICE, "ogre/ogdrag.wav", 1, ATTN_IDLE);// play chainsaw drag sound

	self.goalentity = self.movetarget = find (world, targetname, other.target);
	self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
	if (!self.movetarget)
	{
		self.pausetime = time + 999999;
		self.th_stand ();
		return;
	}
};

/*QUAKED path_corner (0.5 0.3 0) (-8 -8 -8) (8 8 8)
Monsters will continue walking towards the next target corner.
*/
void() path_corner =
{
	if (!self.targetname)
		objerror ("monster_movetarget: no targetname");
		
	self.solid = SOLID_TRIGGER;
	self.touch = t_movetarget;
	setsize (self, '-8 -8 -8', '8 8 8');
};






//============================================================================

/*
=============
range

returns the range catagorization of an entity reletive to self
0	melee range, will become hostile even if back is turned
1	visibility and infront, or visibility and show hostile
2	infront and show hostile
3	only triggered by damage
=============
*/
float(entity targ) range =
{
	vector spot1 = self.origin + self.view_ofs;
	vector spot2 = targ.origin + targ.view_ofs;
	
	float r = vlen (spot1 - spot2);
	if (r < 120)
		return RANGE_MELEE;
	if (r < 500)
		return RANGE_NEAR;
	if (r < 1000)
		return RANGE_MID;
	return RANGE_FAR;
};

/*
=============
visible

returns 1 if the entity is visible to self, even if not infront ()
=============
*/
float (entity targ) visible =
{
	local vector	spot1, spot2;
	
	spot1 = self.origin + self.view_ofs;
	spot2 = targ.origin + targ.view_ofs;
	traceline (spot1, spot2, TRUE, self);	// see through other monsters
	
	if (trace_inopen && trace_inwater)
		return FALSE;			// sight line crossed contents

	if (trace_fraction == 1)
		return TRUE;
	return FALSE;
};


/*
=============
infront

returns 1 if the entity is in front (in sight) of self
=============
*/
float(entity targ) infront =
{
	makevectors (self.angles);
	vector vec = normalize (targ.origin - self.origin);
	float dot = vec * v_forward;
	if (dot > 0.3)
		return TRUE;
	else
		return FALSE;
};


void() HuntTarget =
{
	self.goalentity = self.enemy;
	self.ideal_yaw = vectoyaw(self.enemy.origin - self.origin);
	self.think = self.th_run;
	self.nextthink = time + 0.1;
	SUB_AttackFinished(1);		// wait a while before first attack
};

void() SightSound =
{
	if (self.classname == "monster_ogre")	
		sound (self, CHAN_BODY, "ogre/ogwake.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_knight")
		sound (self, CHAN_BODY, "knight/ksight.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_shambler")
		sound (self, CHAN_BODY, "shambler/ssight.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_demon1")
		sound (self, CHAN_BODY, "demon/sight2.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_wizard")
		sound (self, CHAN_BODY, "wizard/wsight.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_zombie")
		sound (self, CHAN_BODY, "zombie/z_idle.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_dog")
		sound (self, CHAN_BODY, "dog/dsight.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_hell_knight")
		sound (self, CHAN_BODY, "hknight/sight1.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_tarbaby")
		sound (self, CHAN_BODY, "blob/sight1.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_enforcer")
	{
		float r = randomrange(4);
		if (r == 0)
			sound (self, CHAN_BODY, "enforcer/sight1.wav", 1, ATTN_NORM);
		else if (r == 1)
			sound (self, CHAN_BODY, "enforcer/sight2.wav", 1, ATTN_NORM);
		else if (r == 2)
			sound (self, CHAN_BODY, "enforcer/sight3.wav", 1, ATTN_NORM);
		else
			sound (self, CHAN_BODY, "enforcer/sight4.wav", 1, ATTN_NORM);
	}
	else if (self.classname == "monster_army")
		sound (self, CHAN_BODY, "soldier/sight1.wav", 1, ATTN_NORM);
	else if (self.classname == "monster_shalrath")
		sound (self, CHAN_BODY, "shalrath/sight.wav", 1, ATTN_NORM);
};

void() FoundTarget =
{
	if (self.enemy.classname == "player")
	{
		sight_entity = self;
		sight_entity_time = time;
	}
	
	self.show_hostile = time + 1;		// wake up other monsters

	SightSound ();
	HuntTarget ();
};

/*==========
FindTarget
==========*/
float() FindTarget =
{
	if (intermission_running)
		return FALSE;

	if (sight_entity_time >= time - 0.1 && !(self.spawnflags & 3) )
	{
		entity client = sight_entity;
		if (client.enemy == self.enemy)
			return FALSE;
	}
	else
	{
		client = checkclient ();
		if (!client)
			return FALSE;
	}

	if (client == self.enemy)
		return FALSE;

	if (client.flags & FL_NOTARGET)
		return FALSE;
	if (client.items & IT_INVISIBILITY)
		return FALSE;

	float r = range(client);
	if (r == RANGE_FAR)
		return FALSE;
		
	if (!visible (client))
		return FALSE;

	if (r == RANGE_NEAR)
	{
		if (client.show_hostile < time && !infront (client))
			return FALSE;
	}
	else if (r == RANGE_MID)
	{
		if (!infront (client))
			return FALSE;
	}
	
//
// got one
//
	self.enemy = client;
	if (self.enemy.classname != "player")
	{
		self.enemy = self.enemy.enemy;
		if (self.enemy.classname != "player")
		{
			self.enemy = world;
			return FALSE;
		}
	}
	
	FoundTarget ();

	return TRUE;
};


//=============================================================================

void(float dist) ai_forward =
{
	walkmove(self.angles_y, dist);
};

void(float dist) ai_back =
{
	walkmove(self.angles_y + 180, dist);
};

void(float dist) ai_pain =
{
	ai_back(dist);
};

void(float dist) ai_painforward =
{
	ai_forward(dist);
};

void(float dist) ai_walk =
{
	if (FindTarget())
		return;
	movetogoal(dist);
};

void() ai_stand =
{
	if (FindTarget())
		return;
};

void() ai_turn =
{
	if (FindTarget())
		return;
	changeyaw ();
};

float() FacingIdeal =
{
	float delta = anglemod(self.angles_y - self.ideal_yaw);
	if (delta > 45 && delta < 315)
		return FALSE;
	return TRUE;
};


//=============================================================================

float()	WizardCheckAttack;
float()	DogCheckAttack;

float() CheckAnyAttack =
{
	if (!enemy_vis)
		return FALSE;
	if (self.classname == "monster_army")
		return SoldierCheckAttack ();
	if (self.classname == "monster_ogre")
		return OgreCheckAttack ();
	if (self.classname == "monster_shambler")
		return ShamCheckAttack ();
	if (self.classname == "monster_demon1")
		return DemonCheckAttack ();
	if (self.classname == "monster_dog")
		return DogCheckAttack ();
	if (self.classname == "monster_wizard")
		return WizardCheckAttack ();
	return CheckAttack ();
};


/*==========
ai_run_melee

Turn until facing enemy then launch melee attack
==========
*/
void() ai_run_melee =
{
	self.ideal_yaw = enemy_yaw;
	changeyaw();
	if (FacingIdeal())
	{
		self.th_melee ();
		self.attack_state = AS_STRAIGHT;
	}
};

/*==============
ai_run_missile

Turn until facing enemy then launch missile attack
==========*/
void() ai_run_missile =
{
	self.ideal_yaw = enemy_yaw;
	changeyaw();
	// if the enemy has dropped out of sight, cancel the attack
	if (!enemy_vis)
	{
		self.attack_state = AS_STRAIGHT;
		return;
	}
	if (FacingIdeal())
	{
		self.th_missile ();
		self.attack_state = AS_STRAIGHT;
	}
};

/*==========
ai_run_slide

Face the enemy and strafe sideways
==========*/
void(float dist) ai_run_slide =
{
	self.ideal_yaw = enemy_yaw;
	changeyaw();
	
	float ofs;
	if (self.lefty)
		ofs = 90;
	else
		ofs = -90;
	
	if (walkmove (self.ideal_yaw + ofs, dist))
		return;
	self.lefty = 1 - self.lefty;
	walkmove (self.ideal_yaw - ofs, dist);
};

#define ROUTE_MAX 256
float route_busy;
.float route;
.entity route_table[ROUTE_MAX];
.float distance;
.float route_time;

/*============
ClearRoute

clear the monsters current route
============*/
void() ClearRoute =
{
	self.route = -1;
	for (float i = 0; i < ROUTE_MAX; i = i + 1)
		self.route_table[i] = world;
};

/*============
ClearWayTable

clear the waypoint table (which is shared between all monsters)
marks all waypoints as not visited and infinite distance
============*/
void() ClearWayTable =
{
	entity e = way_head;
	while (e)
	{
		e.state = -1;
		e.distance = -1;
		e.last_way = world;
		e = e._next;
	}
};

/*==========
CheckDoors

check if a door is in the way of two waypoints while checking a route
==========*/
float(entity e) CheckDoors =
{
	traceline(self.enemy.origin, e.origin, TRUE, self.enemy);
	if (trace_fraction == 1)
		return TRUE;
	if (trace_ent == e)
		return TRUE;
		
	if (trace_ent.classname == "door")
	{
		// we check .owner because it's the master door
		if (trace_ent.owner.items) // key door
			return FALSE;
		if (trace_ent.owner.health) // shootable door
			return FALSE;
		if (trace_ent.owner.targetname != "") // triggered door
			return FALSE;

		return TRUE; // regular door with a trigger field
	}
	
	dprint("CheckDoors: \n");
	dprint(trace_ent.classname);
	dprint("\n");
	
	return FALSE; // something else in the way
};

/*==========
CheckRoute

called from RouteThink to update the distances between the waypoints
==========*/
void(entity e) CheckRoute =
{
	if (!e)
		return;
	if (e.state > 0)
		return;
	if (!CheckDoors(e))
		return;

	float dist = self.enemy.distance;
	dist = dist + vlen(self.enemy.origin - e.origin);
	dist = dist + random() * 32;	// add some fuzzyness
	
	if ((e.distance == -1) || (dist < e.distance))
	{
		e.distance = dist;
		e.last_way = self.enemy;
	}
};

/*==========
RouteThink

return the shortest path to the goal waypoint
==========*/
void() RouteThink =
{
	entity e;

	// the monster died while calculating a route - free up the table
	if (self.owner.health <= 0)
	{
		route_busy = 0;
		remove(self);
		fixer = world;
		return;
	}

	// visit all waypoints linking to current waypoint and update their distance
	CheckRoute(self.enemy.target1);
	CheckRoute(self.enemy.target2);
	CheckRoute(self.enemy.target3);
	CheckRoute(self.enemy.target4);

	// mark this waypoint as visited
	self.enemy.state = 1;

	// found route
	if (self.goalentity.state == 1)
	{
		//dprint("RouteThink: found route\n");
		
		e = self.goalentity;
		float i = 0;
		while (e)
		{
			self.owner.route_table[i] = e;
			e = e.last_way;
			if (e)		// don't count the final waypoint, as it's the one the monster is already at
				i = i + 1;
		}
		
		self.owner.route = i - 1;	// because route_table is a zero indexed array
		self.owner.route_time = time + 5;
		route_busy = FALSE;
		remove(self);
		fixer = world;
		return;
	}

	// find the nearest, unvisited waypoint
	entity best = world;
	float bdist = -1;
	e = way_head;
	while (e)
	{
		if (e.state == -1) // not visited
		{
			if (e.distance > 0) // we use -1 for "infinite distance"
			{
				if (e.distance < bdist || bdist == -1)
				{
					best = e;
					bdist = e.distance;
				}
			}
		}
		e = e._next;
	}

	// no valid route exists between the two waypoints
	if (best == world)
	{
		//dprint("RouteThink: no valid route exists\n");
		route_busy = FALSE;
		remove(self);
		fixer = world;
		return;
	}

	// update the next waypoint
	self.enemy = best;
	self.think = RouteThink;
	self.nextthink = time;
};

/*============
StartRoute

called by monsters when they want to find a path between waypoint A and B
uses thinks to avoid tripping the runaway counter (RouteThink)
============*/
void(entity e1, entity e2) StartRoute =
{	
	// no waypoints exist in map
	if (!waypoints)
		return;
	// another monster is already calculating a route
	if (route_busy)
		return;
	// sanity check
	if (e1 == world || e2 == world || e1 == e2)
		return;
	
	//dprint("StartRoute\n");
	
	// mark the table as busy and clear it for use
	route_busy = TRUE;
	ClearWayTable();

	// the first waypoint is always distance zero
	e1.distance = 0;

	if (!fixer)
		fixer = spawn();
	fixer.owner = self;
	fixer.enemy = e1; // start waypoint
	fixer.goalentity = e2; // end waypoint
	fixer.nextthink = time;
	fixer.think = RouteThink;
};

/*==========
FindWaypoint
==========*/
entity(entity monster, entity start) FindWaypoint =
{
	if (!waypoints)
		return world;

	if (start != world)
	{
		float best_dist = vlen(start.origin - monster.origin);
		entity best = start;
	}
	else
	{
		best_dist = -1;
		best = world;
	}

	entity w = way_head;
	while(w)
	{
		float way_dist = vlen(w.origin - monster.origin);
		if (way_dist < best_dist || best_dist == -1)
		{
			if (wisible(monster, w))
			{
				best_dist = way_dist;
				best = w;
				
				if (best_dist < 20)
					return best;
			}
		}
		w = w._next;
	}

	if (best_dist < 256)
	{
		//dprint("FindWaypoint: found\n");
		return best;
	}
	else
	{
		//dprint("FindWaypoint: world\n");
		return world;
	}
};

/*==========
ai_movetogoal
==========*/

float (float dist) SV_CloseEnough =
{
	if (self.goalentity.absmin.x > self.absmax.x + dist)
		return FALSE;
	if (self.goalentity.absmax.x < self.absmin.x - dist)
		return FALSE;
		
	if (self.goalentity.absmin.y > self.absmax.y + dist)
		return FALSE;
	if (self.goalentity.absmax.y < self.absmin.y - dist)
		return FALSE;
		
	if (self.goalentity.absmin.z > self.absmax.z + dist)
		return FALSE;
	if (self.goalentity.absmax.z < self.absmin.z - dist)
		return FALSE;
		
	return TRUE;
};


//.float blocked_time;
//.float blocked_count;

void(entity goal, float dist) ai_movetogoal =
{	
	// new target
	if (self.goalentity != goal)
	{
		self.goalentity = goal;
		self.ideal_yaw = vectoyaw(goal.origin - self.origin);
	}

	if (SV_CloseEnough(dist))
	{
		//dprint("SV_CloseEnough\n");
		//self.flags = self.flags | FL_PARTIALGROUND;
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
		changeyaw();
		if (walkmove(self.angles_y, dist))
			return;
		float ofs;
		if (self.lefty)
			ofs = 45;
		else
			ofs = -45;
			
		if (walkmove(self.angles_y + ofs, dist))
			return;
		self.lefty = 1 - self.lefty;
		walkmove(self.angles_y - ofs, dist);
	}
	else
		movetogoal(dist);
	
	/*
	if (self.blocked_count > 10)
	{
		self.blocked_count = 0;
		self.blocked_time = time + 5;
	}
	if (self.blocked_time > time)
	{
		movetogoal(dist);
		return;	
	}
	
	self.ideal_yaw = vectoyaw(goal.origin - self.origin);
	changeyaw();
	if (walkmove(self.angles_y, dist))
		return;

	self.blocked_count = self.blocked_count + 1;
	float ofs;
	if (self.lefty)
		ofs = 45;
	else
		ofs = -45;
		
	if (walkmove(self.angles_y + ofs, dist))
		return;
		
	self.lefty = 1 - self.lefty;
	walkmove(self.angles_y - ofs, dist);*/
};

/*
=============
ai_run

The monster has an enemy it is trying to kill
=============
*/
void(float dist) ai_run =
{	
	// stop all attacks during intermission
	if (intermission_running)
	{
		ClearRoute();
		self.enemy = self.goalentity = world;
		self.th_stand();
		return;
	}
	// enemy has died, so look for a new one
	if (self.enemy.health <= 0)
	{
		ClearRoute();
		self.enemy = self.goalentity = world;
		// look for previous enemy
		if (self.oldenemy.health > 0)
		{
			self.enemy = self.oldenemy;
			HuntTarget();
		}
		else
		{
			// go back to walking beat
			if (self.movetarget)
			{
				self.goalentity = self.movetarget;
				self.th_walk();
			}
			// otherwise, stand still
			else
				self.th_stand();
				
			return;
		}
	}

	// FIXME: get rid of globals
	enemy_vis = visible(self.enemy);
	enemy_infront = infront(self.enemy);
	enemy_range = range(self.enemy);
	enemy_yaw = vectoyaw(self.enemy.origin - self.origin);
	
	// look for other players in co-op
	if (enemy_vis)
		self.search_time = time + 5;
	if (coop && self.search_time < time)
	{
		if (FindTarget())
			return;
	}
	
	// we've started an attack, so make sure we're facing the right way
	if (self.attack_state == AS_MISSILE)
	{
		ai_run_missile();
		return;
	}
	if (self.attack_state == AS_MELEE)
	{
		ai_run_melee();
		return;
	}

	// check for beginning an attack
	if (CheckAnyAttack())
		return;
	
	// used by scrags
	if (self.attack_state == AS_SLIDING)
	{
		ai_run_slide(dist);
		return;
	}
	
	// no waypoints in map, so just use regular movement
	if (!waypoints)
	{
		ai_movetogoal(self.enemy, dist);
		return;
	}

	// we have an enemy, but no route, so find a route to the enemy	
	if (self.route < 0)
	{
		//dprint("Finding route\n");
		self.current_way = FindWaypoint(self, self.current_way);
		self.enemy.current_way = FindWaypoint(self.enemy, self.enemy.current_way);
		StartRoute(self.current_way, self.enemy.current_way);
		
		ai_movetogoal(self.enemy, dist);
		return;
	}
	
	// monster has failed to move to the next waypoint, so drop the route
	if (time > self.route_time)
	{
		//dprint("Dropping route\n");
		ClearRoute();
		ai_movetogoal(self.enemy, dist);
		return;
	}

	// periodically refresh enemy waypoint
	/*
	if (!route_busy)
	{
		self.enemy.current_way = FindWaypoint(self.enemy, self.enemy.current_way);
		if (self.route_table[0] != self.enemy.current_way)
			StartRoute(self.current_way, self.enemy.current_way);
	}
	*/
	
	// move to the next waypoint
	entity w = self.route_table[self.route];
	ai_movetogoal(w, dist);
	
	// hit next waypoint?
	if (vlen(self.origin - w.origin) < 64)
	{
		self.route_time = time + 5;
		self.current_way = self.route_table[self.route];
		self.route = self.route - 1;

		// hit last waypoint
		if (self.route < 0)
		{
			dprint("Hit last waypoint\n");
			ClearRoute();
		}
	}
};
