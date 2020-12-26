/*================================================================================
	waypoints.qc

	each waypoint can have up to 4 other waypoints it can link to
	if a waypoint is linked, the link does not have to be 2-way, it can just point
	in one direction

	the waypoints are held in a linked list (way_head, way_foot) for speed to avoid
	using find() with classname's as this is slow

	many thanks to FrikaC for the FrikBot, whose code this is heavily based upon
================================================================================*/

float waypoint_mode;
float WM_UNINIT		= 0;	// waypoints not loaded
float WM_LOADING	= 1;	// waypoints are loading
float WM_LOADED		= 2;	// waypoints are loaded (also set when there's no waypoints in the map)
float WM_EDITOR		= 3;	// editor is currently active

float	scr_centertime;
.float	menu, menuopt, menutime, menubuttonreleased;
float MENU_MAIN		= 0;	// main menu
float MENU_WAYS		= 1;	// waypoint sub menu
float MENU_LINKS	= 2;	// link sub menu
float MENU_LINKS_C	= 3;	// create link
float MENU_LINKS_D	= 4;	// delete link
float MENU_LINKS_C2	= 5;	// create link x2
float MENU_LINKS_D2	= 6;	// delete link x2

entity 	way_head, way_foot;
float	waypoints;
entity	fixer;
.entity	target1, target2, target3, target4;
.entity	_next, _last;
.entity	current_way, last_way;

/*==========
wisible
==========*/
float (entity monster, entity way) wisible =
{
	vector spot1 = monster.origin + monster.view_ofs;
	vector spot2 = way.origin;
	traceline (spot1, spot2, TRUE, monster);
	if (trace_fraction == 1 || trace_ent == way)
		return TRUE;
	else
		return FALSE;
};

/*==========
PrintQCWaypoint

use thinks to avoid tripping runaway loop counter
==========*/
void() PrintQCWaypoint =
{
	// go to next waypoint in list
	entity t;
	if (self.enemy == world)
		t = way_head;
	else
		t = self.enemy._next;

	// reached last waypoint
	if (t == world)
	{
		remove(self);
		fixer = world;
		bprint("};\n// End dump\n");
		return;
	}
	
	// dump current waypoint
	bprint("\tSpawnWaypoint(");

	t.origin_x = rint(t.origin_x);
	t.origin_y = rint(t.origin_y);
	t.origin_z = rint(t.origin_z);

	string h = vtos(t.origin);
	bprint(h);
	bprint(", ");

	h = ftos(t.target1.count);
	bprint(h);
	bprint(", ");

	h = ftos(t.target2.count);
	bprint(h);
	bprint(", ");

	h = ftos(t.target3.count);
	bprint(h);
	bprint(", ");

	h = ftos(t.target4.count);
	bprint(h);
	bprint(");\n");

	self.nextthink = time + 0.01;
	self.enemy = t;
};

/*==========
DumpWaypoints
==========*/
void() DumpWaypoints =
{
	if (!waypoints)
	{
		bprint("No waypoints to dump!\n");
		return;
	}

	bprint("// Waypoint Dump - ");
	bprint(mapname);
	bprint(".qc\n");

	bprint("void() waypoints_");
	bprint(mapname);
	bprint(" =\n{\n");

	if (!fixer)
		fixer = spawn();
	fixer.nextthink = time + 0.01;
	fixer.think = PrintQCWaypoint;
	fixer.enemy = world;
};

/*==========
CheckLinked

returns TRUE if ways are linked
==========*/
float (entity e1, entity e2) CheckLinked =
{
	if ((e1 == e2) || (e2 == world) || (e1 == world))
		return FALSE;
	else if (e1.target1 == e2)
		return TRUE;
	else if (e1.target2 == e2)
		return TRUE;
	else if (e1.target3 == e2)
		return TRUE;
	else if (e1.target4 == e2)
		return TRUE;
	else
		return FALSE;
};

/*==========
LinkWays

links e1 to e2 (each way has max of 4 links)
==========*/
float (entity e1, entity e2) LinkWays =
{
	if ((e1 == e2) || (e2 == world) || (e1 == world))
	{
		bprint("tried to link waypoint to itself, or nothing!\n");
		return FALSE;
	}
	else if (CheckLinked(e1, e2))
	{
		bprint("waypoints are already linked!\n");
		return FALSE; // already linked
	}

	if (e1.target1 == world)
	{
		e1.target1 = e2;
		return TRUE;
	}
	else if (e1.target2 == world)
	{
		e1.target2 = e2;
		return TRUE;
	}
	else if (e1.target3 == world)
	{
		e1.target3 = e2;
		return TRUE;
	}
	else if (e1.target4 == world)
	{
		e1.target4 = e2;
		return TRUE;
	}
	else
	{
		bprint("waypoint already has max (4) links!\n");
		return FALSE;
	}
};

/*==========
UnlinkWays

unlinks e1 from e2 (one direction only)
==========*/
void(entity e1, entity e2) UnlinkWays =
{
	if ((e1 == e2) || (e2 == world) || (e1 == world))
	{
		bprint("can't unlink waypoint from itself!\n");
		return;
	}
	else if (!CheckLinked(e1, e2))
	{
		bprint("waypoints are not linked!\n");
		return;
	}

	if (e1.target1 == e2)
		e1.target1 = world;
	if (e1.target2 == e2)
		e1.target2 = world;
	if (e1.target3 == e2)
		e1.target3 = world;
	if (e1.target4 == e2)
		e1.target4 = world;
};

/*==========
DeleteWaypoint
==========*/
void(entity what) DeleteWaypoint =
{
	if (way_head == what)
		way_head = what._next;
	if (way_foot == what)
		way_foot = what._last;
	if (what._last)
		what._last._next = what._next;
	if (what._next)
		what._next._last = what._last;
	waypoints = 0;
	entity t = way_head;
	while(t)
	{
	 	waypoints = waypoints + 1;
		t.count = waypoints;
		if (CheckLinked(t, what))
			UnlinkWays(t, what);
		t = t._next;
	}
	if (self.current_way == what)
		self.current_way = world;
	if (self.last_way == what)
		self.last_way = world;
	remove(what);
};

/*==========
MakeWaypoint

used in editor to spawn new waypoint
the waypoint loading code uses SpawnWaypoint, not this function
==========*/
entity(vector org) MakeWaypoint =
{
	entity way = spawn();
	way.classname = "waypoint";
	way.solid = SOLID_TRIGGER;
	way.movetype = MOVETYPE_NONE;
	
	setorigin(way, org);
	setmodel(way, "progs/s_way1.spr");
	setsize(way, VEC_HULL_MIN, VEC_HULL_MAX);

	waypoints = waypoints + 1;
	if (!way_head) // first waypoint
	{
		way_head = way;
		way_foot = way;
	}
	else
	{
		way_foot._next = way;
		way._last = way_foot;
		way_foot = way;
	}
	way.count = waypoints;
	return way;
};

/*==========
FindWayPoint

finds closest wisible way to self
only used to select nearest way in the editor
==========*/
entity(entity start) FindWayPoint =
{
	vector org = self.origin;
	
	if (start != world)
	{
		float dst = vlen(start.origin - org);
		entity best = start;
	}
	else
	{
		dst = 100000;
		best = world;
	}

	entity t = way_head;
	while(t)
	{
		if (dst < 20)
			return best;

		float tdst = vlen(t.origin - org);
		if (tdst < dst)
		{
			if (wisible(self, t))
			{
				dst = tdst;
				best = t;
			}
		}
		t = t._next;
	}
	return best;
};

/*==========
DrawWaypointLinks
==========*/
void() DrawWaypointLinks =
{
	// if we're in the linking sub-menus, then draw a helper beam (for creation)
	// or lightning (for deletion)
	if (self.menu >= MENU_LINKS_C && self.menu <= MENU_LINKS_D2)
	{
		if (self.current_way && self.last_way)
		{
			if (self.current_way != self.last_way)
			{
				if (self.menu == MENU_LINKS_C || self.menu == MENU_LINKS_C2)
					te_beam(self.current_way.origin, self.last_way.origin, self.current_way);
				else
					te_lightning1(self.current_way.origin, self.last_way.origin, self);
			}
		}
		return;
	}

	if (self.current_way)
	{
		if (self.current_way.target1)
			te_beam(self.current_way.origin, self.current_way.target1.origin, self.current_way);
		if (self.current_way.target2)
			te_beam(self.current_way.origin, self.current_way.target2.origin, self.current_way);
		if (self.current_way.target3)
			te_beam(self.current_way.origin, self.current_way.target3.origin, self.current_way);
		if (self.current_way.target4)
			te_beam(self.current_way.origin, self.current_way.target4.origin, self.current_way);
	}
};

/*==========
SelectNearestWaypoint
==========*/
void() SelectNearestWaypoint =
{
	entity t = FindWayPoint(self.current_way);
	if (t)
	{
		float dist = vlen(self.origin - t.origin);
		if (dist < 64)
		{
			// new waypoint selected
			if (self.current_way != t) 
			{
				// unselect previous waypoint
				if (self.current_way)
				{
					setmodel(self.current_way, "progs/s_way1.spr");
					setsize(self.current_way, VEC_HULL_MIN, VEC_HULL_MAX);
				}

				// select new waypoint
				setmodel(t, "progs/s_way2.spr");
				setsize(t, VEC_HULL_MIN, VEC_HULL_MAX);
				self.current_way = t;
			}
		}
	}
};

/*==========
DisplayMenu

wish i had real string management
==========*/
void() DisplayMenu =
{
	// don't constantly re-draw the menu
	if (time < self.menutime)
		return;
	self.menutime = time + scr_centertime;
	
	string s1, s2, s3, s4, s5, s6, s7;
	s1 = s2 = s3 = s4 = s5 = s6 = s7 = string_null;

	if (self.menu == MENU_MAIN)
	{
		s1 = "\bWaypoint Editor\b\n\n";
		if (self.menuopt == 0) s2 = "\x85 \bWaypoint Management  \n"; else s2 = "  Waypoint Management  \n";
		if (self.menuopt == 1) s3 = "\x85 \bLink Management      \n"; else s3 = "  Link Management      \n";
		if (self.menuopt == 2) s4 = "\x85 \bDisplay Waypoint Info\n"; else s4 = "  Display Waypoint Info\n";
		if (self.menuopt == 3) s5 = "\x85 \bDump .qc             \n";	else s5 = "  Dump .qc             \n";
		if (self.menuopt == 4) s6 = "\x85 \bExit                 \n";	else s6 = "  Exit                 \n";
	}
	else if (self.menu == MENU_WAYS)
	{
		s1 = "\bWaypoint Editor \x85 Waypoint Management\b\n\n";
		if (self.menuopt == 0) s2 = "\x85 \bMove Waypoint     \n"; else s2 = "  Move Waypoint     \n";
		if (self.menuopt == 1) s3 = "\x85 \bDelete Waypoint   \n"; else s3 = "  Delete Waypoint   \n";
		if (self.menuopt == 2) s4 = "\x85 \bMake Waypoint     \n"; else s4 = "  Make Waypoint     \n";
		if (self.menuopt == 3) s5 = "\x85 \bMake Way + Link   \n"; else s5 = "  Make Way + Link   \n";
		if (self.menuopt == 4) s6 = "\x85 \bMake Way + Link x2\n"; else s6 = "  Make Way + Link x2\n";
		if (self.menuopt == 5) s7 = "\x85 \bBack              \n"; else s7 = "  Back              \n";
	}
	else if (self.menu == MENU_LINKS)
	{
		s1 = "\bWaypoint Editor \x85 Link Management\b\n\n";
		if (self.menuopt == 0) s2 = "\x85 \bUnlink Waypoint\n"; else s2 = "  Unlink Waypoint\n";
		if (self.menuopt == 1) s3 = "\x85 \bCreate Link    \n"; else s3 = "  Create Link    \n";
		if (self.menuopt == 2) s4 = "\x85 \bDelete Link    \n"; else s4 = "  Delete Link    \n";
		if (self.menuopt == 3) s5 = "\x85 \bCreate Link x2 \n"; else s5 = "  Create Link x2 \n";
		if (self.menuopt == 4) s6 = "\x85 \bDelete Link x2 \n"; else s6 = "  Delete Link x2 \n";
		if (self.menuopt == 5) s7 = "\x85 \bBack           \n"; else s7 = "  Back           \n";
	}
	else // selection sub menus (link, delete, etc)
	{
		if (self.menu == MENU_LINKS_C)
			s1 = "\bWaypoint Editor \x85 Create link (one way)\b\n\n";
		else if (self.menu == MENU_LINKS_D)
			s1 = "\bWaypoint Editor \x85 Delete link (one way))\b\n\n";
		else if (self.menu == MENU_LINKS_C2)
			s1 = "\bWaypoint Editor \x85 Create link (two way))\b\n\n";
		else if (self.menu == MENU_LINKS_D2)
			s1 = "\bWaypoint Editor \x85 Delete link (two way))\b\n\n";
		
		s2 = "\bPlease select waypoint\n\n";
		if (self.menuopt == 0) s3 = "\x85 \bSelect               \n"; else s3 = "  Select               \n";
		if (self.menuopt == 1) s4 = "\x85 \bCancel               \n"; else s4 = "  Cancel               \n";
	}

	centerprint(self, s1, s2, s3, s4, s5, s6, s7);
};

/*==========
ToggleWaypointMenu
==========*/
void() ToggleWaypointMenu =
{
	// don't allow until all waypoints loaded
	if (waypoint_mode < WM_LOADED)
		return;

	// reset menu for next use
	self.menu = MENU_MAIN;
	self.menuopt = 0;
	self.menutime = time;
	centerprint (self, string_null);
	
	// menu on
	if (waypoint_mode == WM_LOADED)
	{
		stuffcmd(self, "crosshair 0\n");
		stuffcmd(self, "viewsize 120\n");
		stuffcmd(self, "r_drawviewmodel 0\n");
		waypoint_mode = WM_EDITOR;
		entity t = way_head;
		while (t)
		{
			setmodel(t, "progs/s_way1.spr");
			setsize(t, VEC_HULL_MIN, VEC_HULL_MAX);
			t = t._next;
		}
		if (self.current_way)
		{
			setmodel(self.current_way, "progs/s_way2.spr");
			setsize(self.current_way, VEC_HULL_MIN, VEC_HULL_MAX);
		}
	}
	// menu off
	else
	{
		stuffcmd(self, "crosshair 1\n");
		stuffcmd(self, "viewsize 100\n");
		stuffcmd(self, "r_drawviewmodel 1\n");
		waypoint_mode = WM_LOADED;
		t = way_head;
		while (t)
		{
			setmodel(t, "progs/s_null.spr");
			setsize(t, VEC_HULL_MIN, VEC_HULL_MAX);
			t = t._next;
		}
	}
};

/*==========
WaypointMenuNavigate

used for scrolling through the menu options
uses the keys bound to "next weapon" and "previous weapon"
==========*/
void(float dir) WaypointMenuNavigate =
{
	float options = 0;
	if (self.menu == MENU_MAIN)
		options = 5;
	else if (self.menu == MENU_WAYS || self.menu == MENU_LINKS)
		options = 6;
	else
		options = 2;
		
	self.menuopt = self.menuopt + dir;
	if (self.menuopt > options - 1)
		self.menuopt = 0;
	if (self.menuopt < 0)
		self.menuopt = options - 1;
};

/*==========
WaypointMenuBack
==========*/
void() WaypointMenuBack =
{
	if (self.menu == MENU_MAIN)
	{
		ToggleWaypointMenu();
		return;
	}
	
	self.menuopt = 0;
	// go back to the main menu if we're in the waypoint or linking sub-menu
	if (self.menu == MENU_WAYS || self.menu == MENU_LINKS)
		self.menu = MENU_MAIN;
	// otherwise go back to the linking sub-menu
	else
		self.menu = MENU_LINKS;
};

/*==========
WaypointMenuAction
==========*/
void(float command) WaypointMenuAction =
{
	if (!self.menubuttonreleased)
		return;
	self.menubuttonreleased = FALSE;
	self.attack_finished = time + 0.1;

//
// main menu
//
	if (self.menu == MENU_MAIN)
	{
		if (command == 1)
		{
			self.menu = MENU_WAYS;
			self.menuopt = 0;
		}
		else if (command == 2)
		{
			self.menu = MENU_LINKS;
			self.menuopt = 0;
		}
		else if (command == 3)
		{
			if (self.current_way)
			{
				bprint("Waypoint #");
				bprint(ftos(self.current_way.count));
				bprint(" - Position ");
				bprint(vtos(self.current_way.origin));
				bprint(" - Links to ");
				if (self.current_way.target1)
				{
					bprint(ftos(self.current_way.target1.count));
					bprint(" ");
				}
				if (self.current_way.target2)
				{
					bprint(ftos(self.current_way.target2.count));
					bprint(" ");
				}
				if (self.current_way.target3)
				{
					bprint(ftos(self.current_way.target3.count));
					bprint(" ");
				}
				if (self.current_way.target4)
					bprint(ftos(self.current_way.target4.count));
				bprint("\n");
			}
		}
		else if (command == 4)
			DumpWaypoints();
		else if (command == 5)
			WaypointMenuBack();
		return;
	}

//
// waypoint menu
//
	if (self.menu == MENU_WAYS)
	{
		// move waypoint
		if (command == 1)
		{
			if (self.current_way)
				setorigin(self.current_way, self.origin);
			else
				sprint(self, "No waypoint selected - unable to move!\n");
		}
		// delete waypoint
		else if (command == 2)
		{
			if (self.current_way)
				DeleteWaypoint(self.current_way);
			else
				sprint(self, "No waypoint selected - unable to delete!\n");
		}
		// create waypoint - no linking
		else if (command == 3)
		{
			MakeWaypoint(self.origin);
		}
		// create waypoint + link to last
		else if (command == 4)
		{
			entity way = MakeWaypoint(self.origin);
			LinkWays(self.current_way, way);
		}
		// create waypoint + link two ways to last
		else if (command == 5)
		{
			way = MakeWaypoint(self.origin);
			LinkWays(self.current_way, way);
			LinkWays(way, self.current_way);
		}
		else if (command == 6)
			WaypointMenuBack();
		return;
	}
	
//
// linking menu
//
	if (self.menu == MENU_LINKS)
	{
		if (command == 1) // unlink all
		{
			if (self.current_way)
				self.current_way.target1 = self.current_way.target2 = self.current_way.target3 = self.current_way.target4 = world;
			else
				sprint(self, "No waypoint selected - unable to unlink!\n");
		}
		else if (command == 2) // create one way link
		{
			if (self.current_way)
			{
				self.menuopt = 0;
				self.last_way = self.current_way;
				self.menu = MENU_LINKS_C;
			}
			else
				sprint(self, "No waypoint selected!\n");
		}
		else if (command == 3) // remove one way link
		{
			if (self.current_way)
			{
				self.menuopt = 0;
				self.last_way = self.current_way;
				self.menu = MENU_LINKS_D;
			}
			else
				sprint(self, "No waypoint selected!\n");
		}
		else if (command == 4) // create two way link
		{
			if (self.current_way)
			{
				self.menuopt = 0;
				self.last_way = self.current_way;
				self.menu = MENU_LINKS_C2;
			}
			else
				sprint(self, "No waypoint selected!\n");
		}
		else if (command == 5) // remove two way link
		{
			if (self.current_way)
			{
				self.menuopt = 0;
				self.last_way = self.current_way;
				self.menu = MENU_LINKS_D2;
			}
			else
				sprint(self, "No waypoint selected!\n");
		}
		else if (command == 6)
			WaypointMenuBack();
		return;
	}

//
// linking submenu
//
	if (self.menu >= MENU_LINKS_C && self.menu <= MENU_LINKS_D2)
	{
		if (command == 1)
		{		
			if (self.menu == MENU_LINKS_C)	// create one way link
				LinkWays(self.last_way, self.current_way);
			else if (self.menu == MENU_LINKS_D) // remove one way link
				UnlinkWays(self.last_way, self.current_way);
			else if (self.menu == MENU_LINKS_C2) // create two way link
			{
				LinkWays(self.last_way, self.current_way);
				LinkWays(self.current_way, self.last_way);
			}
			else if (self.menu == MENU_LINKS_D2) // remove two way link
			{
				UnlinkWays(self.last_way, self.current_way);
				UnlinkWays(self.current_way, self.last_way);
			}
			
			WaypointMenuBack();
		}
		else if (command == 2)
			WaypointMenuBack();
	}
};

/*==========
WaypointMenu
==========*/
void() WaypointMenu =
{
	DisplayMenu();

	// pressing fire will set button0 = TRUE for several frames so we need to track release
	if (!self.button0)
		self.menubuttonreleased = TRUE;

	// use impulses for next weapon/previous weapon to scroll the menu
	if (self.impulse == 10)
		WaypointMenuNavigate(-1);
	else if (self.impulse == 12)
		WaypointMenuNavigate(1);
	// use fire button to select options
	else if (self.button0)
		WaypointMenuAction(self.menuopt + 1);
	else
		return;
	
	self.impulse = 0;
	self.menutime = time;	// refresh menu immediately
};

/*==========
WaypointForNum

returns the entity for a given waypoint number
returns world if not found
only used in waypoint loading code
==========*/
entity(float num) WaypointForNum =
{
	if (num < 1)
		return world;

	entity t = way_head;
	while (t)
	{
		if (t.count == num)
			return t;
		t = t._next;
	}
	return world;
};

/*==========
FixThisWaypoint

use thinks to avoid tripping runaway loop counter
==========*/
void() FixThisWaypoint =
{
	self.enemy.target1 = WaypointForNum(self.enemy.ammo_shells);
	self.enemy.target2 = WaypointForNum(self.enemy.ammo_nails);
	self.enemy.target3 = WaypointForNum(self.enemy.ammo_rockets);
	self.enemy.target4 = WaypointForNum(self.enemy.ammo_cells);

	self.enemy = self.enemy._next;
	self.nextthink = time + 0.01;
	
	// reached last waypoint
	if (self.enemy == world)
	{
		bprint("waypoints loaded\n");
		waypoint_mode = WM_LOADED;
		remove(self);
		fixer = world;
	}
};

/*==========
FixWaypoints

once all waypoints have been loaded, link them up
we want to link target1-4 (entities) for speed
ammo_shells is the waypoint number for target1, ammo_nails is target2, etc
==========*/
void() FixWaypoints =
{
	if (!fixer)
		fixer = spawn();
	fixer.nextthink = time + 0.01;
	fixer.think = FixThisWaypoint;
	fixer.enemy = way_head; // start waypoint
};

/*==========
SpawnWaypoint

used by the hardcoded qc waypoints
==========*/
void(vector org, float t1, float t2, float t3, float t4) SpawnWaypoint =
{
	entity way = spawn();
	way.classname = "waypoint";
	way.solid = SOLID_TRIGGER;
	way.movetype = MOVETYPE_NONE;

	setorigin(way, org);
	setmodel(way, "progs/s_null.spr");
	setsize(way, VEC_HULL_MIN, VEC_HULL_MAX);

	way.ammo_shells = t1;
	way.ammo_nails = t2;
	way.ammo_rockets = t3;
	way.ammo_cells = t4;
	waypoints = waypoints + 1;
	way.count = waypoints;

	if (!way_head) // first waypoint
	{
		way_head = way;
		way_foot = way;
	}
	else
	{
		way_foot._next = way;
		way._last = way_foot;
		way_foot = way;
	}
};

// Waypoint Dump - e1m2.qc
void() waypoints_e1m2 =
{
	SpawnWaypoint('1481.0 1670.0 288.0', 2, 13, 15, 0);
	SpawnWaypoint('1518.0 1504.0 264.0', 1, 3, 4, 5);
	SpawnWaypoint('1711.0 1524.0 264.0', 2, 14, 0, 0);
	SpawnWaypoint('1317.0 1521.0 264.0', 2, 0, 0, 0);
	SpawnWaypoint('1469.0 1277.0 200.0', 2, 6, 9, 18);
	SpawnWaypoint('1679.0 1273.0 200.0', 5, 7, 8, 0);
	SpawnWaypoint('1677.0 1406.0 200.0', 6, 8, 0, 0);
	SpawnWaypoint('1766.0 1289.0 200.0', 6, 7, 0, 0);
	SpawnWaypoint('1368.0 1274.0 200.0', 5, 10, 12, 0);
	SpawnWaypoint('1353.0 1441.0 200.0', 9, 11, 0, 0);
	SpawnWaypoint('1192.0 1441.0 200.0', 10, 12, 0, 0);
	SpawnWaypoint('1201.0 1279.0 200.0', 11, 9, 0, 0);
	SpawnWaypoint('1800.0 1720.0 264.0', 1, 14, 0, 0);
	SpawnWaypoint('1800.0 1614.0 264.0', 13, 3, 0, 0);
	SpawnWaypoint('1310.0 1720.0 264.0', 1, 16, 0, 0);
	SpawnWaypoint('1192.0 1720.0 264.0', 15, 17, 0, 0);
	SpawnWaypoint('1195.0 1584.0 264.0', 16, 0, 0, 0);
	SpawnWaypoint('1484.0 1087.0 204.0', 5, 19, 0, 0);
	SpawnWaypoint('1492.0 905.0 200.0', 18, 20, 0, 0);
	SpawnWaypoint('1498.0 791.0 248.0', 19, 21, 0, 0);
	SpawnWaypoint('1477.0 666.0 264.0', 20, 22, 0, 0);
	SpawnWaypoint('1341.0 656.0 296.0', 21, 23, 0, 0);
	SpawnWaypoint('1232.0 662.0 312.0', 22, 24, 0, 0);
	SpawnWaypoint('1066.0 671.0 312.0', 23, 25, 0, 0);
	SpawnWaypoint('1078.0 527.0 312.0', 24, 26, 0, 0);
	SpawnWaypoint('1082.0 391.0 308.0', 25, 27, 0, 0);
	SpawnWaypoint('1096.0  93.0 308.0', 26, 28, 0, 0);
	SpawnWaypoint('1099.0 -133.0 320.0', 27, 29, 95, 0);
	SpawnWaypoint('1210.0 -115.0 320.0', 28, 30, 0, 0);
	SpawnWaypoint('1373.0 -119.0 320.0', 29, 31, 0, 0);
	SpawnWaypoint('1420.0 -25.0 320.0', 30, 32, 0, 0);
	SpawnWaypoint('1422.0  89.0 320.0', 31, 33, 0, 0);
	SpawnWaypoint('1408.0 337.0 320.0', 32, 34, 0, 0);
	SpawnWaypoint('1513.0 391.0 320.0', 33, 35, 0, 0);
	SpawnWaypoint('1629.0 394.0 312.0', 34, 36, 0, 0);
	SpawnWaypoint('1755.0 391.0 312.0', 35, 37, 0, 0);
	SpawnWaypoint('1795.0 315.0 312.0', 36, 38, 0, 0);
	SpawnWaypoint('1787.0 165.0 312.0', 37, 39, 0, 0);
	SpawnWaypoint('1791.0  43.0 312.0', 38, 40, 0, 0);
	SpawnWaypoint('1849.0 -98.0 312.0', 39, 41, 0, 0);
	SpawnWaypoint('1907.0 -95.0 312.0', 40, 42, 0, 0);
	SpawnWaypoint('1999.0 -109.0 312.0', 41, 43, 0, 0);
	SpawnWaypoint('2046.0 -137.0 312.0', 42, 44, 0, 0);
	SpawnWaypoint('2044.0 -246.0 312.0', 43, 45, 0, 0);
	SpawnWaypoint('2038.0 -360.0 312.0', 44, 46, 0, 0);
	SpawnWaypoint('1969.0 -357.0 312.0', 45, 47, 0, 0);
	SpawnWaypoint('1847.0 -354.0 312.0', 46, 48, 0, 0);
	SpawnWaypoint('1716.0 -359.0 312.0', 47, 49, 0, 0);
	SpawnWaypoint('1556.0 -355.0 312.0', 48, 50, 0, 0);
	SpawnWaypoint('1259.0 -332.0 312.0', 49, 51, 0, 0);
	SpawnWaypoint('1149.0 -391.0 312.0', 50, 52, 0, 0);
	SpawnWaypoint('1093.0 -512.0 312.0', 51, 53, 0, 0);
	SpawnWaypoint('1116.0 -649.0 312.0', 52, 54, 0, 0);
	SpawnWaypoint('1249.0 -730.0 312.0', 53, 55, 0, 0);
	SpawnWaypoint('1376.0 -728.0 312.0', 54, 56, 0, 0);
	SpawnWaypoint('1503.0 -717.0 312.0', 55, 57, 0, 0);
	SpawnWaypoint('1679.0 -705.0 360.0', 56, 58, 0, 0);
	SpawnWaypoint('1675.0 -807.0 392.0', 57, 59, 0, 0);
	SpawnWaypoint('1670.0 -918.0 408.0', 58, 60, 0, 0);
	SpawnWaypoint('1620.0 -916.0 424.0', 59, 61, 0, 0);
	SpawnWaypoint('1489.0 -905.0 440.0', 60, 62, 0, 0);
	SpawnWaypoint('1369.0 -908.0 440.0', 61, 63, 68, 0);
	SpawnWaypoint('1220.0 -911.0 440.0', 62, 64, 0, 0);
	SpawnWaypoint('1073.0 -906.0 440.0', 63, 65, 70, 0);
	SpawnWaypoint('928.0 -900.0 440.0', 64, 66, 71, 0);
	SpawnWaypoint('880.0 -849.0 440.0', 65, 67, 0, 0);
	SpawnWaypoint('882.0 -743.0 440.0', 66, 0, 0, 0);
	SpawnWaypoint('1410.0 -1183.0 440.0', 62, 69, 0, 0);
	SpawnWaypoint('1311.0 -1191.0 440.0', 68, 70, 0, 0);
	SpawnWaypoint('1182.0 -1192.0 440.0', 69, 64, 0, 0);
	SpawnWaypoint('874.0 -1043.0 440.0', 65, 72, 0, 0);
	SpawnWaypoint('870.0 -1130.0 440.0', 71, 73, 0, 0);
	SpawnWaypoint('877.0 -1184.0 432.0', 72, 74, 0, 0);
	SpawnWaypoint('676.0 -1219.0 432.0', 73, 75, 0, 0);
	SpawnWaypoint('586.0 -1199.0 432.0', 74, 76, 97, 0);
	SpawnWaypoint('511.0 -1174.0 432.0', 75, 77, 97, 0);
	SpawnWaypoint('418.0 -1093.0 432.0', 76, 78, 0, 0);
	SpawnWaypoint('391.0 -977.0 432.0', 77, 79, 0, 0);
	SpawnWaypoint('450.0 -864.0 432.0', 78, 80, 0, 0);
	SpawnWaypoint('587.0 -851.0 432.0', 79, 81, 96, 0);
	SpawnWaypoint('612.0 -725.0 432.0', 80, 82, 0, 0);
	SpawnWaypoint('558.0 -628.0 392.0', 81, 83, 0, 0);
	SpawnWaypoint('562.0 -508.0 350.0', 82, 84, 0, 0);
	SpawnWaypoint('567.0 -385.0 320.0', 83, 85, 92, 0);
	SpawnWaypoint('484.0 -407.0 320.0', 84, 86, 0, 0);
	SpawnWaypoint('395.0 -447.0 320.0', 85, 87, 0, 0);
	SpawnWaypoint('267.0 -468.0 320.0', 86, 88, 0, 0);
	SpawnWaypoint('170.0 -383.0 320.0', 87, 89, 0, 0);
	SpawnWaypoint('269.0 -302.0 320.0', 88, 90, 98, 0);
	SpawnWaypoint('403.0 -291.0 320.0', 89, 91, 0, 0);
	SpawnWaypoint('559.0 -269.0 320.0', 90, 92, 0, 0);
	SpawnWaypoint('580.0 -224.0 320.0', 91, 93, 84, 0);
	SpawnWaypoint('613.0 -143.0 320.0', 92, 94, 0, 0);
	SpawnWaypoint('688.0 -102.0 320.0', 93, 95, 0, 0);
	SpawnWaypoint('802.0 -117.0 320.0', 94, 28, 0, 0);
	SpawnWaypoint('585.0 -1005.0 432.0', 80, 97, 0, 0);
	SpawnWaypoint('595.0 -1090.0 432.0', 96, 75, 76, 0);
	SpawnWaypoint('245.0 -224.0 328.0', 89, 99, 0, 0);
	SpawnWaypoint('238.0 -100.0 320.0', 98, 100, 0, 0);
	SpawnWaypoint('246.0  55.0 320.0', 99, 101, 102, 0);
	SpawnWaypoint('253.0 158.0 320.0', 100, 0, 0, 0);
	SpawnWaypoint(' 90.0  59.0 320.0', 100, 103, 111, 0);
	SpawnWaypoint(' 47.0  67.0 320.0', 102, 104, 0, 0);
	SpawnWaypoint('-92.0  91.0 320.0', 103, 105, 111, 110);
	SpawnWaypoint('-243.0  79.0 320.0', 104, 106, 109, 107);
	SpawnWaypoint('-366.0 -26.0 320.0', 105, 107, 0, 0);
	SpawnWaypoint('-375.0  52.0 320.0', 106, 108, 105, 0);
	SpawnWaypoint('-356.0 166.0 320.0', 107, 109, 0, 0);
	SpawnWaypoint('-277.0 274.0 320.0', 108, 110, 105, 0);
	SpawnWaypoint('-29.0 260.0 320.0', 109, 111, 104, 0);
	SpawnWaypoint('121.0 248.0 320.0', 110, 102, 104, 0);
	SpawnWaypoint('-107.0 -47.0 320.0', 104, 113, 0, 0);
	SpawnWaypoint('-107.0 -121.0 320.0', 112, 114, 0, 0);
	SpawnWaypoint('-120.0 -257.0 336.0', 113, 115, 0, 0);
	SpawnWaypoint('-122.0 -277.0 336.0', 114, 116, 0, 0);
	SpawnWaypoint('-108.0 -403.0 384.0', 115, 117, 0, 0);
	SpawnWaypoint('-133.0 -454.0 384.0', 116, 118, 0, 0);
	SpawnWaypoint('-208.0 -493.0 384.0', 117, 119, 0, 0);
	SpawnWaypoint('-314.0 -493.0 416.0', 118, 120, 0, 0);
	SpawnWaypoint('-388.0 -489.0 464.0', 119, 121, 0, 0);
	SpawnWaypoint('-479.0 -488.0 480.0', 120, 122, 123, 0);
	SpawnWaypoint('-488.0 -363.0 480.0', 121, 125, 0, 0);
	SpawnWaypoint('-463.0 -675.0 482.0', 121, 124, 0, 0);
	SpawnWaypoint('-283.0 -698.0 480.0', 123, 0, 0, 0);
	SpawnWaypoint('-264.0 -290.0 480.0', 122, 0, 0, 0);
};
// End dump

/*==========
LoadWaypoints
==========*/
void() LoadWaypoints =
{
	waypoint_mode = WM_LOADING;

	if (mapname == "e1m2")
		waypoints_e1m2();
		
	if (waypoints)
		FixWaypoints();
	else
	{
		waypoint_mode = WM_LOADED;
		bprint("no waypoints loaded\n");
	}
};

/*==========
WaypointPreFrame

called from PlayerPreThink
==========*/
void() WaypointPreFrame =
{
	if (waypoint_mode < WM_EDITOR)
		return;
	SelectNearestWaypoint();
	DrawWaypointLinks();
};

/*==========
WaypointPostFrame

called from PlayerPostThink
==========*/
void() WaypointPostFrame =
{
	if (waypoint_mode < WM_LOADED)
		return;
	if (self.impulse == 100)
	{
		dprint("ToggleWaypointMenu\n");
		ToggleWaypointMenu();
		self.impulse = 0;
		return;
	}
	if (waypoint_mode < WM_EDITOR)
		return;
	WaypointMenu();
};

/*==========
WaypointFrame

called from StartFrame
==========*/
void() WaypointFrame =
{
	if (framecount < 5)
		return;
	if (waypoint_mode == WM_UNINIT)
		LoadWaypoints();
};

/*==========
WaypointInit

called from worldspawn
==========*/
void() WaypointInit =
{
	precache_model("progs/beam.mdl");
	precache_model("progs/s_way1.spr");
	precache_model("progs/s_way2.spr");
	precache_model("progs/s_null.spr");
	
	waypoint_mode = WM_UNINIT;
	way_head = world;
	way_foot = world;
	waypoints = 0;
	
	// used for the menu refresh timer
	scr_centertime = cvar("scr_centertime") - 0.1;
	if (scr_centertime < 0)
		scr_centertime = 0;
};
