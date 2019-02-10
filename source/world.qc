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

"message" "name"
Map name

"sounds" "n"
CD / Music track to play

"worldtype" "n"
0 - medieval, 1 - metal, 2 - base
Affects the default door sounds, key models and sounds, and ammo box models.

"_wateralpha" "n"
"_slimealpha" "n"
"_lavaalpha" "n"
"_telaalpha" "n"
Set the transparency of the various liquid surfaces. range 0-1.

"fog" "density r g b"
Sets a global fog value.

"sky" "name"
Sky box to load, read from gfx\env\

"light" "n" | "_minlight" "n"
Set a global minimum light level of "n" across the whole map. This is an easy way to eliminate completely dark areas of the level, however you may lose some contrast as a result, so use with care. Default 0.

"_minlight_color" "r g b" | "_mincolor" "r g b"
Specify red(r), green(g) and blue(b) components for the colour of the minlight. RGB component values are between 0 and 255 (between 0 and 1 is also accepted). Default is white light ("255 255 255").

"_dist" "n"
Scales the fade distance of all lights by a factor of n. If n > 1 lights fade more quickly with distance and if n < 1, lights fade more slowly with distance and light reaches further.

"_range" "n"
Scales the brightness range of all lights without affecting their fade discance. Values of n > 0.5 makes lights brighter and n < 0.5 makes lights less bright. The same effect can be achieved on individual lights by adjusting both the "light" and "wait" attributes.

"_sunlight" "n"
Set the brightness of the sunlight coming from an unseen sun in the sky. Sky brushes (or more accurately bsp leafs with sky contents) will emit sunlight at an angle specified by the "_sun_mangle" key. Default 0.

"_anglescale" "n" | "_anglesense" "n"
Set the scaling of sunlight brightness due to the angle of incidence with a surface (more detailed explanation in the "_anglescale" light entity key below).

"_sunlight_mangle" "yaw pitch roll" | "_sun_mangle" "yaw pitch roll"
Specifies the direction of sunlight using yaw, pitch and roll in degrees. Yaw specifies the angle around the Z-axis from 0 to 359 degrees and pitch specifies the angle from 90 (shining straight up) to -90 (shining straight down from above). Roll has no effect, so use any value (e.g. 0). Default is straight down ("0 -90 0").

"_sunlight_penumbra" "n"
Specifies the penumbra width, in degrees, of sunlight. Useful values are 3-4 for a gentle soft edge, or 10-20+ for more diffuse sunlight. Default is 0.

"_sunlight_color" "r g b"
Specify red(r), green(g) and blue(b) components for the colour of the sunlight. RGB component values are between 0 and 255 (between 0 and 1 is also accepted). Default is white light ("255 255 255").

"_sunlight2" "n"
Set the brightness of a dome of lights arranged around the upper hemisphere. (i.e. ambient light, coming from above the horizon). Default 0.

"_sunlight_color2" "r g b" | "_sunlight2_color" "r g b"
Specifies the colour of _sunlight2, same format as "_sunlight_color". Default is white light ("255 255 255").

"_sunlight3" "n"
Same as "_sunlight2", but for the bottom hemisphere (i.e. ambient light, coming from below the horizon). Combine "_sunlight2" and "_sunlight3" to have light coming equally from all directions, e.g. for levels floating in the clouds. Default 0.

"_sunlight_color3" "r g b" | "_sunlight3_color" "r g b"
Specifies the colour of "_sunlight3". Default is white light ("255 255 255").

"_dirt" "n"
1 enables dirtmapping (ambient occlusion) on all lights, borrowed from q3map2. This adds shadows to corners and crevices. You can override the global setting for specific lights with the "_dirt" light entitiy key or "_sunlight_dirt", "_sunlight2_dirt", and "_minlight_dirt" worldspawn keys. Default is no dirtmapping (-1).

"_sunlight_dirt" "n"
1 enables dirtmapping (ambient occlusion) on sunlight, -1 to disable (making it illuminate the dirtmapping shadows). Default is to use the value of "_dirt".

"_sunlight2_dirt" "n"
1 enables dirtmapping (ambient occlusion) on sunlight2/3, -1 to disable. Default is to use the value of "_dirt".

"_minlight_dirt" "n"
1 enables dirtmapping (ambient occlusion) on minlight, -1 to disable. Default is to use the value of "_dirt".

"_dirtmode" "n"
Choose between ordered (0, default) and randomized (1) dirtmapping.

"_dirtdepth" "n"
Maximum depth of occlusion checking for dirtmapping, default 128.

"_dirtscale" "n"
Scale factor used in dirt calculations, default 1. Lower values (e.g. 0.5) make the dirt fainter, 2.0 would create much darker shadows.

"_dirtgain" "n"
Exponent used in dirt calculation, default 1. Lower values (e.g. 0.5) make the shadows darker and stretch further away from corners.

"_dirtangle" "n"
Cone angle in degrees for occlusion testing, default 88. Allowed range 1-90. Lower values can avoid unwanted dirt on arches, pipe interiors, etc.

"_gamma" "n"
Adjust brightness of final lightmap. Default 1, >1 is brighter, <1 is darker.

"_lightmap_scale" "n"
Forces all surfaces+submodels to use this specific lightmap scale. Removes "LMSHIFT" field.

"_bounce" "n"
1 enables bounce lighting, disabled by default.

"_bouncescale" "n"
Scales brightness of bounce lighting, default 1.

"_bouncecolorscale" "n"
Weight for bounce lighting to use texture colors from the map: 0=ignore map textures (default), 1=multiply bounce light color by texture color.

"_bouncestyled" "n"
1 makes styled lights bounce (e.g. flickering or switchable lights), default is 0, they do not bounce.

"_spotlightautofalloff" "n"
When set to 1, spotlight falloff is calculated from the distance to the targeted info_null. Ignored when "_falloff" is not 0. Default 0.
*/

void() DebugKilltargets_Do =
{
	float err = FALSE;

	entity e = world;
	e = nextent(e);
	while (e != world)
	{
		if (e.target != "")
		{
			if (e.killtarget != "")
			{
				dprint(e.classname);
				dprint(": ");
				dprint("target: ");
				dprint(e.target);
				dprint(" killtarget: ");
				dprint(e.killtarget);
				dprint("\n");

				if (e.target != e.killtarget)
					err = TRUE;					
			}
		}
		e = nextent(e);
	}
	remove(self);
	
	if (err)
		dprint("map contains entities with both a target and a killtarget\n");
}
	
void() DebugKilltargets =
{
	entity e = spawn();
	e.think = DebugKilltargets_Do;
	e.nextthink = time + 1;
};

void() worldspawn =
{	
	
	precache_sounds();
	precache_models();
	setup_lightstyles();
	setup_gravity();
	InitBodyQue();
	DebugKilltargets();
};

/*==========
StartFrame
==========*/
void() StartFrame =
{
	teamplay = cvar("teamplay");
	skill = cvar("skill");
	developer = cvar("developer");
	framecount = framecount + 1;
};
