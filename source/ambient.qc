/*==========
ambient_start
==========*/
void(string s, float vol, float atn) ambient_start =
{
	precache_sound(s);
	ambientsound(self.origin, s, vol, atn);
};

/*QUAKED ambient_custom (0.3 0.1 0.6) (-8 -8 -8) (8 8 8)
Customisable ambient sound.

Keys:
"noise" "name" - Ambient sound to play. Must have loop markers.
"volume" "n" - Set the volume of the sound. Range 0-1. Defaulf 0.5.
"distance" "n" - Set the attenuation of the ambient sound.
0 - static (default, usual for ambient sounds)
1 - idle (usually used for monster idle sounds)
2 - normal (normal attenuation)
3 - none (no attenuation, audible throughout entire map)
*/
void() ambient_custom =
{
	if (!self.noise)
	{
		objerror("no sound specified\n");
		remove(self);
		return;
	}
	if (self.volume > 1)
		self.volume = 1;
	if (self.volume <= 0)
		self.volume = 0.5;
	if (self.distance < 0)
		self.distance = 0;
	if (self.distance > 3)
		self.distance = 3;
	float atn = 0;
	switch (self.distance)
	{
		case 0:
		default:
			atn = ATTN_STATIC;
			break;
		case 1:
			atn = ATTN_IDLE;
			break;
		case 2:
			atn = ATTN_NORM;
			break;
		case 3:
			atn = ATTN_NONE;
			break;
	}
	ambient_start(self.noise, self.volume, atn);
};

/*QUAKED ambient_comp_hum (0.3 0.1 0.6) (-8 -8 -8) (8 8 8)
Ambient computer hum.
*/
void() ambient_comp_hum =
{
	ambient_start("ambience/comp1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED ambient_drip (0.3 0.1 0.6) (-8 -8 -8) (8 8 8)
Ambient water drip.
*/
void() ambient_drip =
{
	ambient_start("ambience/drip1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED ambient_drone (0.3 0.1 0.6) (-8 -8 -8) (8 8 8)
Ambient drone.
*/
void() ambient_drone =
{
	ambient_start("ambience/drone6.wav", 0.5, ATTN_STATIC);
};

/*QUAKED ambient_fire (0.3 0.1 0.6) (-8 -8 -8) (8 8 8)
Ambient fire crackling.
*/
void() ambient_fire =
{
	ambient_start("ambience/fire1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED ambient_flouro_buzz (0.3 0.1 0.6) (-8 -8 -8) (8 8 8)
Ambient flourescent light buzzing.
*/
void() ambient_flouro_buzz =
{
	ambient_start("ambience/buzz1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED ambient_light_buzz (0.3 0.1 0.6) (-8 -8 -8) (8 8 8)
Ambient light buzz.
*/
void() ambient_light_buzz =
{
	ambient_start("ambience/fl_hum1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED ambient_suck_wind (0.3 0.1 0.6) (-8 -8 -8) (8 8 8)
Ambient sucking wind.
*/
void() ambient_suck_wind =
{
	ambient_start("ambience/suck1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED ambient_swamp1 (0.3 0.1 0.6) (-8 -8 -8) (8 8 8)
Ambient swamp - 1st variation.
*/
void() ambient_swamp1 =
{
	ambient_start("ambience/swamp1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED ambient_swamp2 (0.3 0.1 0.6) (-8 -8 -8) (8 8 8)
Ambient swamp - 2nd variation.
*/
void() ambient_swamp2 =
{
	ambient_start("ambience/swamp2.wav", 0.5, ATTN_STATIC);
};

/*QUAKED ambient_teleport (0.3 0.1 0.6) (-8 -8 -8) (8 8 8)
Ambient teleporter hum.
*/
void() ambient_teleport =
{
	ambient_start("ambience/hum1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED ambient_thunder (0.3 0.1 0.6) (-8 -8 -8) (8 8 8)
Ambient thunder.
*/
void() ambient_thunder =
{
	ambient_start("ambience/thunder1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED ambient_water (0.3 0.1 0.6) (-8 -8 -8) (8 8 8)
Ambient water.
*/
void() ambient_water =
{
	ambient_start("ambience/water1.wav", 0.5, ATTN_STATIC);
};

/*QUAKED ambient_wind (0.3 0.1 0.6) (-8 -8 -8) (8 8 8)
Ambient wind.
*/
void() ambient_wind =
{
	ambient_start("ambience/wind2.wav", 0.5, ATTN_STATIC);
};
