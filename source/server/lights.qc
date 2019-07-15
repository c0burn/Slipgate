/*========================================
lights.qc
========================================*/

static enumflags { LIGHT_START_OFF, LIGHT_FADE, LIGHT_NO_SOUND };

#define FADE_RAMP 13
static string abc[FADE_RAMP] = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m" };

#define NUM_LIGHTSTYLES 13
static string lightstyles[NUM_LIGHTSTYLES] =
{
	// 0 NORMAL
	"m",
	// 1 FLICKER (first variety)
	"mmnmmommommnonmmonqnmmo",
	// 2 SLOW STRONG PULSE
	"abcdefghijklmnopqrstuvwxyzyxwvutsrqponmlkjihgfedcba",
	// 3 CANDLE (first variety)
	"mmmmmaaaaammmmmaaaaaabcdefgabcdefg",
	// 4 FAST STROBE
	"mamamamamama",
	// 5 GENTLE PULSE 1
	"jklmnopqrstuvwxyzyxwvutsrqponmlkj",
	// 6 FLICKER (second variety)
	"nmonqnmomnmomomno",
	// 7 CANDLE (second variety)
	"mmmaaaabcdefgmmmmaaaammmaamm",
	// 8 CANDLE (third variety)
	"mmmaaammmaaammmabcdefaaaammmmabcdefmmmaaaa",
	// 9 SLOW STROBE (fourth variety)
	"aaaaaaaazzzzzzzz",
	// 10 FLUORESCENT FLICKER
	"mmamammmmammamamaaamammma",
	// 11 SLOW PULSE NOT FADE TO BLACK
	"abcdefghijklmnopqrrqponmlkjihgfedcba",
	// 12 BLINK OFF / ON (can be combined with animated textures, e.g. +0light, +1light, +alight)
	"aamm"
};

/*==========
lightstyle_lookup

look up a style by it's number and return the correct animation string
==========*/
static string(float num) lightstyle_lookup =
{
	if (num > NUM_LIGHTSTYLES - 1)
		num = NUM_LIGHTSTYLES - 1;
	if (num < 0)
		num = 0;
	return lightstyles[num];
};

/*==========
lightstyle_fade_lookup
==========*/
static string(float num) lightstyle_fade_lookup =
{
	if (num > FADE_RAMP - 1)
		num = FADE_RAMP - 1;
	if (num < 0)
		num = 0;
	return abc[num];
};

/*==========
setup_lightstyles

Setup light animation tables. 'a' is total darkness, 'z' is maxbright.
Styles 32+ are assigned by the light compiler for switchable lights.
==========*/
void() setup_lightstyles =
{
	for (float i = 0; i < NUM_LIGHTSTYLES - 1; i++)
	{
		lightstyle(i, lightstyle_lookup(i));
	}
};

/*==========
light_fade_in
==========*/
static void() light_fade_in =
{
	lightstyle(self.style, lightstyle_fade_lookup(self.count));
	
	self.count = self.count + 1;
	if (self.count > FADE_RAMP - 1)
	{
		self.count = FADE_RAMP - 1;
		return;
	}

	self.think = light_fade_in;
	self.nextthink = time + self.speed;
};

/*==========
light_fade_out
==========*/
static void() light_fade_out =
{	
	lightstyle(self.style, lightstyle_fade_lookup(self.count));
	
	self.count = self.count - 1;
	if (self.count < 0)
	{
		self.count = 0;	
		return;
	}
		
	self.think = light_fade_out;
	self.nextthink = time + self.speed;
};

/*==========
light_use

using a light will turn it on and off
==========*/
static void() light_use =
{
	if (self.spawnflags & LIGHT_START_OFF)
	{
		if (self.mdl != "")
			setmodel(self, self.mdl);
		if (self.noise1 != "")
			sound(self, CHAN_VOICE, self.noise2, 0.5, ATTN_IDLE);
			
		self.spawnflags = self.spawnflags - LIGHT_START_OFF;
		if (self.spawnflags & LIGHT_FADE && !self.style2)
			light_fade_in();
		else
			lightstyle(self.style, lightstyle_lookup(self.style2));
	}
	else
	{
		if (self.mdl != "")
			self.modelindex = 0;
		if (self.noise1 != "")
			sound(self, CHAN_VOICE, self.noise1, 0.5, ATTN_IDLE);
			
		self.spawnflags = self.spawnflags + LIGHT_START_OFF;
		if (self.spawnflags & LIGHT_FADE && !self.style2)
			light_fade_out();
		else
			lightstyle(self.style, "a");
	}
};

/*QUAKED light (1 1 0) (-8 -8 -8) (8 8 8) START_OFF FADE NO_SOUND
Non-displayed light
Please see your compiling utility documentation for full details,
this entry only describes things controlled by the QuakeC.

==========
Keys
==========
"targetname" "name"
Turns the light into a switchable light. You must target it to toggle it.

"speed" "n"
If the light is switchable and FADE_IN_OUT is set, the speed at which the light transitions from off to on and vice versa. Default 0.1.

"style" "n"
Set the animated light style. Default 0.
0 NORMAL
1 FLICKER (first variety)
2 SLOW STRONG PULSE
3 CANDLE (first variety)
4 FAST STROBE
5 GENTLE PULSE 1
6 FLICKER (second variety)
7 CANDLE (second variety)
8 CANDLE (third variety)
9 SLOW STROBE (fourth variety)
10 FLUORESCENT FLICKER
11 SLOW PULSE NOT FADE TO BLACK
12 BLINK OFF / ON (can be synced with animated textures, e.g. +0light, +1light, +alight)

"style2" "n"
Set the animated light style for a switchable light.
This is because "style" will be set by your compiling utility to a value in the range 32+,
so we need to tell the QuakeC what actual style to use.

==========
Spawnflags
==========
START_OFF - switchable lights only - light is switched off at map start - default is on
FADE - switchable lights only - light fades in and out when switched. you can't combine this with an animated style.
*/
static void() light =
{
	if (self.mdl != "")
	{
		if (!(self.spawnflags & LIGHT_START_OFF))
			setmodel(self, self.mdl);
	}
	
	// non-switchable light
	if (!self.targetname)
	{
		//remove(self);
		return;
	}
	
	// default fade speed
	if (self.speed <= 0)
		self.speed = 0.1;

	// switchable light
	if (self.style >= 32)
	{
		self.use = light_use;
		if (self.spawnflags & LIGHT_START_OFF)
		{
			self.count = 0;
			lightstyle(self.style, "a");
		}
		else
		{
			self.count = FADE_RAMP - 1;
			lightstyle(self.style, lightstyle_lookup(self.style2));
		}
	}
};

/*QUAKED light_fluoro (1 1 0) (-8 -8 -8) (8 8 8) START_OFF FADE NO_SOUND
Non-displayed light
Makes steady fluorescent humming sound
*/
static void() light_fluoro =
{		
	ambient_light_buzz();
	remove(self);
};

/*QUAKED light_fluorospark (1 1 0) (-8 -8 -8) (8 8 8) START_OFF FADE NO_SOUND
Non-displayed light
Makes sparking, broken fluorescent sound
*/
static void() light_fluorospark =
{		
	ambient_flouro_buzz();
	remove(self);
};

/*QUAKED light_globe (1 1 0) (-8 -8 -8) (8 8 8) START_OFF FADE NO_SOUND
Sprite globe light
*/
static void() light_globe =
{
	precache_model("progs/s_light.spr");
	setmodel(self, "progs/s_light.spr");
	makestatic(self);
};

/*QUAKED light_torch_small_walltorch (1 1 0) (-4 -4 -16) (4 4 32) START_OFF FADE NO_SOUND
{	model ("progs/flame.mdl");	}
Short wall torch
Makes crackling fire noise unless NO_SOUND is set
*/
static void() light_torch_small_walltorch =
{
	precache_model("progs/flame.mdl");
	setmodel(self, "progs/flame.mdl");
	if (!(self.spawnflags & LIGHT_NO_SOUND))
		ambient_fire();
	makestatic(self);
};

/*QUAKED light_torch_long_walltorch (1 1 0) (-8 -8 -48) (8 8 24) START_OFF FADE NO_SOUND
{	model ("progs/flame3.mdl");	}
Long wall torch
Makes crackling fire noise unless NO_SOUND is set
*/
static void() light_torch_long_walltorch =
{
	precache_model("progs/flame3.mdl");
	setmodel(self, "progs/flame3.mdl");
	if (!(self.spawnflags & LIGHT_NO_SOUND))
		ambient_fire();
	makestatic(self);
};

/*QUAKED light_flame_small_yellow (1 1 0) (-4 -4 -12) (4 4 16) START_OFF FADE NO_SOUND
{	model ("progs/flame2.mdl");	}
Small yellow flame
Makes crackling fire noise unless NO_SOUND is set
*/
static void() light_flame_small_yellow =
{
	precache_model("progs/flame2.mdl");
	setmodel(self, "progs/flame2.mdl");
	if (!(self.spawnflags & LIGHT_NO_SOUND))
		ambient_fire();
	makestatic(self);
};

/*==========
light_flame_small_white
For compatability only.
==========*/
static void() light_flame_small_white =
{
	self.classname = "light_flame_small_yellow";
	light_flame_small_yellow();
};

/*QUAKED light_flame_large_yellow (1 1 0) (-8 -8 -12) (8 8 40) START_OFF FADE NO_SOUND
{	model ( { "path" : "progs/flame2.mdl", "frame" : 1 } );	}
Large yellow flame
Makes crackling fire noise unless NO_SOUND is set
*/
static void() light_flame_large_yellow =
{
	precache_model("progs/flame2.mdl");
	setmodel (self, "progs/flame2.mdl");
	self.frame = 1;
	if (!(self.spawnflags & LIGHT_NO_SOUND))
		ambient_fire();
	makestatic(self);
};

/*==========
s_flame
==========*/
static void() s_flame =
{
	self.frame = self.frame + 1;
	if (self.frame > 13)
		self.frame = 0;
	self.think = s_flame;
	self.nextthink = time + 0.05;
};

/*QUAKED light_flame_sprite (1 1 0) (-16 -16 0) (16 16 40) START_OFF FADE NO_SOUND
Large yellow flame sprite
Makes crackling fire noise
See the "light" entity for a full description
*/
static void() light_flame_sprite =
{
	self.mdl = "progs/s_flame.spr";
	precache_model(self.mdl);

	self.noise = "ambience/fire1.wav";
	precache_sound(self.noise);
	self.noise1 = "misc/torchoff.wav";
	precache_sound(self.noise1);
	self.noise2 = "misc/torchon1.wav";
	precache_sound(self.noise2);
		
	if (!(self.spawnflags & LIGHT_NO_SOUND))
		ambient_fire();

	light();
	
	// assume any sensible engine that implements pr_checkextension
	// also has working spritegroups, so we can use 
	// makestatic and reduce network traffic
	if (cvar("pr_checkextension"))
	{
		self.frame = 14;		// frame 14 is a spritegroup which contains 14 frames
		//makestatic(self);
	}
	else
	{
		self.think = s_flame;	// animate frames 0-13 manually
		self.nextthink = time + 0.01 + random() * 0.5;
	}
};
