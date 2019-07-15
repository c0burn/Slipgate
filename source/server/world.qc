/*========================================
world.qc
========================================*/

/*==========
main
==========*/
void() main = {};

/*==========
setup_gravity
==========*/
void() setup_gravity =
{
	// custom map gravity
	if (mapname == "e1m8")
		cvar_set ("sv_gravity", "100");
	else if (self.gravity)
		cvar_set ("sv_gravity", ftos(self.gravity));
	else
		cvar_set ("sv_gravity", "800");
		
	sv_gravity = cvar("sv_gravity");
};

/*==========
precache_sounds
==========*/
void() precache_sounds =
{
	// sounds used from C code
	precache_sound ("demon/dland2.wav");		// landing thud
	precache_sound ("misc/h2ohit1.wav");		// landing splash
	precache_sound ("misc/talk.wav");			// chat
	precache_sound ("weapons/r_exp3.wav");		// explosion
	precache_sound ("weapons/ric1.wav");		// spike ricochet
	precache_sound ("weapons/ric2.wav");		// spike ricochet
	precache_sound ("weapons/ric3.wav");		// spike ricochet
	precache_sound ("weapons/tink1.wav");		// spike tink
	precache_sound ("wizard/hit.wav");			// scrag projectile impact
	precache_sound ("hknight/hit.wav");			// death knight projectile impact
	
	// player movement sounds
	precache_sound ("player/plyrjmp8.wav");		// player jump
	precache_sound ("player/land.wav");			// player landing
	precache_sound ("player/land2.wav");		// player hurt landing
	precache_sound ("player/ladder1.wav");
	precache_sound ("player/ladder2.wav");
	precache_sound ("player/ladder3.wav");
	precache_sound ("player/ladder4.wav");
	precache_sound ("player/ladder5.wav");
	
	// player pain sounds
	precache_sound ("player/pain1.wav");
	precache_sound ("player/pain2.wav");
	precache_sound ("player/pain3.wav");
	precache_sound ("player/pain4.wav");
	precache_sound ("player/pain5.wav");
	precache_sound ("player/pain6.wav");
	
	// player death sounds
	precache_sound ("player/death1.wav");
	precache_sound ("player/death2.wav");
	precache_sound ("player/death3.wav");
	precache_sound ("player/death4.wav");
	precache_sound ("player/death5.wav");

	// gib sounds
	precache_sound ("player/gib.wav");
	precache_sound ("player/udeath.wav");
	precache_sound ("player/tornoff2.wav");
	precache_sound ("player/teledth1.wav");	
	precache_sound ("zombie/z_miss.wav");	

	// player liquid sounds
	precache_sound ("player/h2ojump.wav");		// jumping into water
	precache_sound ("player/inh2o.wav");		// enter water
	precache_sound ("player/slimbrn2.wav");		// enter slime
	precache_sound ("player/inlava.wav");		// enter lava
	precache_sound ("misc/outwater.wav");		// leaving water
	precache_sound ("player/lburn1.wav");		// lava burn
	precache_sound ("player/lburn2.wav");		// lava burn
	precache_sound ("misc/water1.wav");			// swimming
	precache_sound ("misc/water2.wav");			// swimming
	precache_sound ("player/drown1.wav");		// drowning pain
	precache_sound ("player/drown2.wav");		// drowning pain
	precache_sound ("player/gasp1.wav");		// gasping for air
	precache_sound ("player/gasp2.wav");		// taking breath
	precache_sound ("player/h2odeath.wav");		// drowning death

	// teleport sounds
	precache_sound ("misc/r_tele1.wav");
	precache_sound ("misc/r_tele2.wav");
	precache_sound ("misc/r_tele3.wav");
	precache_sound ("misc/r_tele4.wav");
	precache_sound ("misc/r_tele5.wav");
	
	// items
	precache_sound ("items/itembk2.wav");		// item respawn
	precache_sound ("weapons/lock4.wav");		// ammo pick up
	precache_sound ("weapons/pkup.wav");		// weapon pick up
	precache_sound ("items/armor1.wav");		// armor pick up
	// pentagram of protection
	precache_sound ("items/protect.wav");
	precache_sound ("items/protect2.wav");
	precache_sound ("items/protect3.wav");
	// biosuit
	precache_sound ("items/suit.wav");
	precache_sound ("items/suit2.wav");
	// ring of shadows
	precache_sound ("items/inv1.wav");
	precache_sound ("items/inv2.wav");
	precache_sound ("items/inv3.wav");
	// quad damage
	precache_sound ("items/damage.wav");
	precache_sound ("items/damage2.wav");
	precache_sound ("items/damage3.wav");
	
	// weapon sounds
	precache_sound ("weapons/ax1.wav");			// axe swoosh
	precache_sound ("player/axhit1.wav");		// axe hit meat
	precache_sound ("player/axhit2.wav");		// axe hit world
	precache_sound ("weapons/guncock.wav");		// shotgun
	precache_sound ("weapons/shotgn2.wav");		// super shotgun
	precache_sound ("weapons/rocket1i.wav");	// nailgun
	precache_sound ("weapons/spike2.wav");		// super nailgun
	precache_sound ("weapons/grenade.wav");		// grenade launcher
	precache_sound ("weapons/bounce.wav");		// grenade bounce
	precache_sound ("weapons/sgun1.wav");		// rocket launcher
	precache_sound ("weapons/lstart.wav");		// thunderbolt start
	precache_sound ("weapons/lhit.wav");		// thunderbolt
};

/*==========
precache_models
==========*/
void() precache_models =
{
	// player models
	precache_model ("progs/player.mdl");
	precache_model ("progs/h_player.mdl");
	precache_model ("progs/eyes.mdl");
	
	// gore
	precache_model ("progs/zom_gib.mdl");
	precache_model ("progs/gib1.mdl");
	precache_model ("progs/gib2.mdl");
	precache_model ("progs/gib3.mdl");
	precache_model ("progs/gib4.mdl");
	precache_model ("progs/gib5.mdl");
	precache_model ("progs/blood.mdl");
	
	// sprites
	precache_model ("progs/s_bubble.spr");
	precache_model ("progs/s_explod.spr");
	precache_model ("progs/s_null.spr");

	// weapon models
	precache_model ("progs/v_axe.mdl");
	precache_model ("progs/v_shot.mdl");
	precache_model ("progs/v_nail.mdl");
	precache_model ("progs/v_rock.mdl");
	precache_model ("progs/v_shot2.mdl");
	precache_model ("progs/v_nail2.mdl");
	precache_model ("progs/v_rock2.mdl");
	precache_model ("progs/v_light.mdl");
	
	// projectiles, etc
	precache_model ("progs/bolt.mdl");
	precache_model ("progs/bolt2.mdl");
	precache_model ("progs/bolt3.mdl");
	precache_model ("progs/beam.mdl");
	precache_model ("progs/missile.mdl");
	precache_model ("progs/grenade.mdl");
	precache_model ("progs/spike.mdl");
	precache_model ("progs/s_spike.mdl");
	precache_model ("progs/backpack.mdl");
	precache_model ("progs/smoke.mdl");
};

/*QUAKED worldspawn (0 0 0) ?
The world entity.

Keys:
"message" "name" - Map name
"sounds" "n" - CD / Music track to play
"worldtype" "n":
0 - medieval, 1 - metal, 2 - base
*/
void() worldspawn =
{	
	// fix skill at map start
	skill = rint(cvar("skill"));
	if (skill < 0)
		skill = 0;
	if (skill > 3)
		skill = 3;

	precache_sounds();
	precache_models();
	setup_lightstyles();
	setup_gravity();
	InitBodyQue();
	WaypointInit();
};

/*==========
StartFrame
==========*/
void() StartFrame =
{
	framecount = framecount + 1;
	
	teamplay = cvar("teamplay");
	developer = cvar("developer");
	
	WaypointFrame();
};
