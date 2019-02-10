/*========================================
defs.qc
========================================*/

/*==========
System Globals
==========*/

entity		self;
entity		other;
entity		world;
float		time;
float		frametime;
float		force_retouch;
string		mapname;
float		deathmatch;
float		coop;
float		teamplay;
float		serverflags;
float		total_secrets;
float		total_monsters;
float		found_secrets;
float		killed_monsters;
float		parm1, parm2, parm3, parm4, parm5, parm6, parm7, parm8,
			parm9, parm10, parm11, parm12, parm13, parm14, parm15, parm16;
vector		v_forward, v_up, v_right;
float		trace_allsolid;
float		trace_startsolid;
float		trace_fraction;
vector		trace_endpos;
vector		trace_plane_normal;
float		trace_plane_dist;
entity		trace_ent;
float		trace_inopen;
float		trace_inwater;
entity		msg_entity;
void() 		main;
void()		StartFrame;
void() 		PlayerPreThink;
void() 		PlayerPostThink;
void()		ClientKill;
void()		ClientConnect;
void() 		PutClientInServer;
void()		ClientDisconnect;
void()		SetNewParms;
void()		SetChangeParms;	
void		end_sys_globals;

/*==========
System Fields
==========*/

.float		modelindex;
.vector		absmin, absmax;
.float		ltime;
.float		movetype;
.float		solid;
.vector		origin;
.vector		oldorigin;
.vector		velocity;
.vector		angles;
.vector		avelocity;
.vector		punchangle;
.string		classname;
.string		model;
.float		frame;
.float		skin;
.float		effects;
.vector		mins, maxs;
.vector		size;
.void()		touch;
.void()		use;
.void()		think;
.void()		blocked;
.float		nextthink;
.entity		groundentity;
.float		health;
.float		frags;
.float		weapon;
.string		weaponmodel;
.float		weaponframe;
.float		currentammo;
.float		ammo_shells, ammo_nails, ammo_rockets, ammo_cells;
.float		items;
.float		takedamage;
.entity		chain;
.float		deadflag;
.vector		view_ofs;
.float		button0;
.float		button1;
.float		button2;
.float		impulse;
.float		fixangle;
.vector		v_angle;
.float		idealpitch;
.string		netname;
.entity 	enemy;
.float		flags;
.float		colormap;
.float		team;
.float		max_health;
.float		teleport_time;
.float		armortype;
.float		armorvalue;
.float		waterlevel;
.float		watertype;
.float		ideal_yaw;
.float		yaw_speed;
.entity		aiment;
.entity 	goalentity;
.float		spawnflags;
.string		target;
.string		targetname;
.float		dmg_take;
.float		dmg_save;
.entity		dmg_inflictor;
.entity		owner;
.vector		movedir;
.string		message;
.float		sounds;
.string		noise, noise1, noise2, noise3;
void		end_sys_fields;

/*==========
Builtins
==========*/

__used void(vector ang) makevectors = #1;
__used void(entity e, vector o) setorigin = #2;
__used void(entity e, string m) setmodel = #3;
__used void(entity e, vector min, vector max) setsize = #4;
__used void() break = #6;
__used float() random = #7;
__used void(entity e, float chan, string samp, float vol, float atten) sound = #8;
__used vector(vector v) normalize = #9;
__used void(string e) error = #10;
__used void(string e) objerror = #11;
__used float(vector v) vlen = #12;
__used float(vector v) vectoyaw = #13;
__used entity() spawn = #14;
__used void(entity e) remove = #15;
__used void(vector v1, vector v2, float nomonsters, entity forent) traceline = #16;
__used entity() checkclient = #17;
__used entity(entity start, .string fld, string match) find = #18;
__used string(string s) precache_sound	= #19;
__used string(string s) precache_model	= #20;
__used void(entity client, string s) stuffcmd = #21;
__used entity(vector org, float rad) findradius = #22;
__used void(string s) bprint = #23;
__used void(entity client, string s, optional string s2) sprint = #24;
__used void(string s) dprint = #25;
__used string(float f) ftos = #26;
__used string(vector v) vtos = #27;
__used void() coredump	= #28;
__used void() traceon = #29;
__used void() traceoff	= #30;
__used void(entity e) eprint = #31;
__used float(float yaw, float dist) walkmove = #32;
__used float() droptofloor= #34;
__used void(float style, string value) lightstyle = #35;
__used float(float v) rint	= #36;
__used float(float v) floor = #37;
__used float(float v) ceil	= #38;
__used float(entity e) checkbottom	= #40;
__used float(vector v) pointcontents = #41;
__used float(float f) fabs = #43;
__used vector(entity e, float speed) aim = #44;
__used float(string s) cvar = #45;
__used void(string s) localcmd = #46;
__used entity(entity e) nextent = #47;
__used void particle(vector o, vector d, float color, float count) = #48;
__used void() changeyaw = #49;
__used vector(vector v) vectoangles = #51;
__used void(float to, float f) WriteByte = #52;
__used void(float to, float f) WriteChar = #53;
__used void(float to, float f) WriteShort = #54;
__used void(float to, float f) WriteLong = #55;
__used void(float to, float f) WriteCoord = #56;
__used void(float to, float f) WriteAngle = #57;
__used void(float to, string s) WriteString = #58;
__used void(float to, entity s) WriteEntity = #59;
__used void(float step) movetogoal	= #67;
__used string(string s) precache_file = #68;
__used void(entity e) makestatic = #69;
__used void(string s) changelevel = #70;
__used void(string var, string val) cvar_set = #72;
__used void(entity client, string s1, optional string s2, optional string s3,
	optional string s4, optional string s5, optional string s6, optional string s7) centerprint = #73;
__used void(vector pos, string samp, float vol, float atten) ambientsound = #74;
__used string(string s) precache_model2 = #75;
__used string(string s) precache_sound2 = #76;
__used string(string s) precache_file2	= #77;
__used void(entity e) setspawnparms = #78;

/*==========
Constants
==========*/

// booleans
const float	FALSE				= 0;
const float TRUE				= 1;

// flags
float	FL_FLY					= 1;
float	FL_SWIM					= 2;
// 4 is unused
float	FL_CLIENT				= 8;
float	FL_INWATER				= 16;
float	FL_MONSTER				= 32;
float	FL_GODMODE				= 64;
float	FL_NOTARGET				= 128;
float	FL_ITEM					= 256;
float	FL_ONGROUND				= 512;
float	FL_PARTIALGROUND		= 1024;
float	FL_WATERJUMP			= 2048;
float	FL_JUMPRELEASED			= 4096;
// values below here are gamecode only
float	FL_ONLADDER				= 8192;
;
// movetype
float	MOVETYPE_NONE			= 0;
float	MOVETYPE_WALK			= 3;
float	MOVETYPE_STEP			= 4;
float	MOVETYPE_FLY			= 5;
float	MOVETYPE_TOSS			= 6;
float	MOVETYPE_PUSH			= 7;
float	MOVETYPE_NOCLIP			= 8;
float	MOVETYPE_FLYMISSILE		= 9;
float	MOVETYPE_BOUNCE			= 10;

// solid
float	SOLID_NOT			= 0;
float	SOLID_TRIGGER		= 1;
float	SOLID_BBOX			= 2;
float	SOLID_SLIDEBOX		= 3;
float	SOLID_BSP			= 4;

// range
float	RANGE_MELEE			= 0;
float	RANGE_NEAR			= 1;
float	RANGE_MID			= 2;
float	RANGE_FAR			= 3;

// deadflag
float	DEAD_NO				= 0;
float	DEAD_DYING			= 1;
float	DEAD_DEAD			= 2;
float	DEAD_RESPAWNABLE	= 4;

// takedamage
float	DAMAGE_NO			= 0;
float	DAMAGE_YES			= 1;
float	DAMAGE_AIM			= 2;

// items
float	IT_SHOTGUN			= 1;
float	IT_SUPER_SHOTGUN	= 2;
float	IT_NAILGUN			= 4;
float	IT_SUPER_NAILGUN	= 8;
float	IT_GRENADE_LAUNCHER	= 16;
float	IT_ROCKET_LAUNCHER	= 32;
float	IT_LIGHTNING		= 64;
float	IT_EXTRA_WEAPON		= 128;
float	IT_SHELLS			= 256;
float	IT_NAILS			= 512;
float	IT_ROCKETS			= 1024;
float	IT_CELLS			= 2048;
float	IT_AXE				= 4096;
float	IT_ARMOR1			= 8192;
float	IT_ARMOR2			= 16384;
float	IT_ARMOR3			= 32768;
float	IT_SUPERHEALTH		= 65536;
float	IT_KEY1				= 131072;
float	IT_KEY2				= 262144;
float	IT_INVISIBILITY		= 524288;
float	IT_INVULNERABILITY	= 1048576;
float	IT_SUIT				= 2097152;
float	IT_QUAD				= 4194304;

// content
float	CONTENT_EMPTY		= -1;
float	CONTENT_SOLID		= -2;
float	CONTENT_WATER		= -3;
float	CONTENT_SLIME		= -4;
float	CONTENT_LAVA		= -5;
float	CONTENT_SKY			= -6;

// state
float	STATE_TOP			= 0;
float	STATE_BOTTOM		= 1;
float	STATE_UP			= 2;
float	STATE_DOWN			= 3;

// hull sizes
vector	VEC_ORIGIN			= '0 0 0';
vector	VEC_HULL_MIN		= '-16 -16 -24';
vector	VEC_HULL_MAX		= '16 16 32';
vector	VEC_HULL2_MIN		= '-32 -32 -24';
vector	VEC_HULL2_MAX		= '32 32 64';

// protocol bytes
float	SVC_BAD			  	= 0;
float	SVC_NOP				= 1;
float	SVC_DISCONNECT		= 2;
float	SVC_UPDATESTAT		= 3;
float	SVC_VERSION			= 4;
float	SVC_SETVIEW			= 5;
float	SVC_SOUND			= 6;
float	SVC_TIME			= 7;
float	SVC_PRINT			= 8;
float	SVC_STUFFTEXT		= 9;
float	SVC_SETANGLE		= 10;
float	SVC_SERVERINFO		= 11;
float	SVC_LIGHTSTYLE		= 12;
float	SVC_UPDATENAME		= 13;
float	SVC_UPDATEFRAGS		= 14;
float	SVC_CLIENTDATA		= 15;
float	SVC_STOPSOUND		= 16;
float	SVC_UPDATECOLORS	= 17;
float	SVC_PARTICLE		= 18;
float	SVC_DAMAGE			= 19;
float	SVC_SPAWNSTATIC		= 20;
float	SVC_SPAWNBINARY		= 21;
float	SVC_SPAWNBASELINE	= 22;
float	SVC_TEMPENTITY		= 23;
float	SVC_SETPAUSE		= 24;
float	SVC_SIGNONNUM		= 25;
float	SVC_CENTERPRINT		= 26;
float	SVC_KILLEDMONSTER	= 27;
float	SVC_FOUNDSECRET		= 28;
float	SVC_SPAWNSTATICSOUND= 29;
float	SVC_INTERMISSION	= 30;
float	SVC_FINALE			= 31;
float	SVC_CDTRACK			= 32;
float	SVC_SELLSCREEN		= 33;
float	SVC_CUTSCENE		= 34;

// stats
float	STAT_HEALTH			= 0;
float	STAT_FRAGS			= 1;
float	STAT_WEAPON			= 2;
float	STAT_AMMO			= 3;
float	STAT_ARMOR			= 4;
float	STAT_WEAPONFRAME	= 5;
float	STAT_SHELLS			= 6;
float	STAT_NAILS			= 7;
float	STAT_ROCKETS		= 8;
float	STAT_CELLS			= 9;
float	STAT_ACTIVEWEAPON	= 10;
float	STAT_TOTALSECRETS	= 11;
float	STAT_TOTALMONSTERS	= 12;
float	STAT_SECRETS		= 13;
float	STAT_MONSTERS		= 14;

// temp ents
float	TE_SPIKE			= 0;
float	TE_SUPERSPIKE		= 1;
float	TE_GUNSHOT			= 2;
float	TE_EXPLOSION		= 3;
float	TE_TAREXPLOSION		= 4;
float	TE_LIGHTNING1		= 5;
float	TE_LIGHTNING2		= 6;
float	TE_WIZSPIKE			= 7;
float	TE_KNIGHTSPIKE		= 8;
float	TE_LIGHTNING3		= 9;
float	TE_LAVASPLASH		= 10;
float	TE_TELEPORT			= 11;
float	TE_EXPLOSION2 		= 12;
float	TE_BEAM				= 13;

// sound channels
float	CHAN_AUTO			= 0;
float	CHAN_WEAPON			= 1;
float	CHAN_VOICE			= 2;
float	CHAN_ITEM			= 3;
float	CHAN_BODY			= 4;

// sound attenuation
float	ATTN_NONE			= 0;
float	ATTN_NORM			= 1;
float	ATTN_IDLE			= 2;
float	ATTN_STATIC			= 3;

// update types
float	UPDATE_GENERAL		= 0;
float	UPDATE_STATIC		= 1;
float	UPDATE_BINARY		= 2;
float	UPDATE_TEMP			= 3;

// effects
float	EF_BRIGHTFIELD		= 1;
float	EF_MUZZLEFLASH		= 2;
float	EF_BRIGHTLIGHT	 	= 4;
float	EF_DIMLIGHT 		= 8;

// messages
float	MSG_BROADCAST		= 0;
float	MSG_ONE				= 1;
float	MSG_ALL				= 2;
float	MSG_INIT			= 3;

// attack styles
float	AS_STRAIGHT			= 1;
float	AS_SLIDING			= 2;
float	AS_MELEE			= 3;
float	AS_MISSILE			= 4;

/*==========
Globals
==========*/

string	string_null;
entity	newmis;
float	gameover;
entity	activator;
//entity	damage_attacker;
float	framecount;
float	skill;
entity	lastspawn;
float	developer;

/*==========
Fields
==========*/

// not used by gamecode, but used by map compiling utilities, so included to stop console warnings
__used .float light_lev;
__used .string wad;

.string 	map;
.float		worldtype;
.string		killtarget;
.float		style;
.float		style2;
.void()		th_stand;
.void()		th_walk;
.void()		th_run;
.void()		th_missile;
.void()		th_melee;
.void(entity inflictor, entity attacker) th_die;
.void(entity attacker, float damage) th_pain;
.entity		oldenemy;
.float		speed;
.float	lefty;
.float	search_time;
.float	attack_state;
.float	walkframe;
.float 	attack_finished;
.float	pain_finished;
.float	invincible_finished;
.float	invisible_finished;
.float	super_damage_finished;
.float	radsuit_finished;
.float	invincible_time, invincible_sound;
.float	invisible_time, invisible_sound;
.float	super_time, super_sound;
.float	rad_time;
.float	fly_sound;
.float	axhitme;
.float	show_hostile;
.float	jump_flag;
.float	swim_flag;
.float	air_finished;
.float	bubble_count;
.string	deathtype;
.string	mdl;
.vector	mangle;
.vector	oldorigin;
.float	t_length, t_width;
.vector	dest1, dest2;
.float	wait;
.float	delay;
.entity	trigger_field;
.string	noise4;
.float 	pausetime;
.entity movetarget;
.float	dmg;
.float	cnt;
.void()	think1;
.vector	finaldest;
.float	count;
.float	lip;
.float	state;
.vector	pos1, pos2;
.float	height;
.float	waitmin;
.float	distance;
.float	volume;
.float	alpha;
.float	gravity;
.float switchshadstyle;		// switchable shadows, supported by ericw-tools
.string mdl1, mdl2, mdl3;	// up to 3 models for unique breakable gibs
.float colour;				// particle colour
.string headmodel;			// head gib model
.float health_rot_time;		// megahealth timer

/*==========
Prototypes
==========*/

void(vector tdest, float tspeed, void() func) SUB_CalcMove;
void() SUB_CalcMoveDone;
void() SUB_Null;
void() SUB_UseTargets;
void() SUB_Remove;
void(entity targ, entity inflictor, entity attacker, float damage) T_Damage;
float(entity targ, entity inflictor) CanDamage;


float SMALL_FLOAT = (float)(__variant)0x00800000i;


float	intermission_running;
float	intermission_exittime;

