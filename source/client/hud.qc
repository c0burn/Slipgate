#define hudtrans autocvar(scr_sbaralpha, 1.0)

float hud_health;
float hud_items;
float hud_runes;
float hud_pain_time;
float hud_weapon_time[7];
float hud_item_time[6];

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
float	IT2_RUNE1			= 1<<5;
float	IT2_RUNE2			= 1<<6;
float	IT2_RUNE3			= 1<<7;
float	IT2_RUNE4			= 1<<8;

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
float	STAT_ITEMS			= 15;

string hud_item_prefix[] = { "gfx/sb_", "gfx/sba1_", "gfx/sba2_", "gfx/sba3_", "gfx/sba4_", "gfx/sba5_" };
string hud_item_names[] = { "key1", "key2", "invis", "invuln", "suit", "quad" };

string hud_weapon_prefix[] = { "gfx/inv_", "gfx/inv2_", "gfx/inva1_","gfx/inva2_","gfx/inva3_","gfx/inva4_","gfx/inva5_" };
string hud_weapon_names[] = { "shotgun", "sshotgun", "nailgun", "snailgun", "rlaunch", "srlaunch", "lightng" };

string hud_num[] = { "gfx/num_0", "gfx/num_1","gfx/num_2", "gfx/num_3", "gfx/num_4", "gfx/num_5", 
	"gfx/num_6", "gfx/num_7", "gfx/num_8", "gfx/num_9" };
string hud_anum[] = { "gfx/anum_0", "gfx/anum_1","gfx/anum_2", "gfx/anum_3", "gfx/anum_4", "gfx/anum_5", 
	"gfx/anum_6", "gfx/anum_7", "gfx/anum_8", "gfx/anum_9" };

/*==========
Hud_DrawLargeValue
==========*/
void(vector pos, float value, float threshhold, float ralign) Hud_DrawLargeValue =
{
	value = bound(0, value, 999);

	string s = ftos(floor(value));
	float len = strlen(s);
	if (ralign)
		pos_x += 24 * (3 - len);

	while (len > 0)
	{
		len = len - 1;
		//float c = str2chr(s, len) - '0';
		float c = stof(substring(s, len, 1));
		
		if (value <= threshhold)
			drawpic(pos + len * [24], hud_anum[c], [24, 24], [1, 1, 1], hudtrans);
		else
			drawpic(pos + len * [24], hud_num[c], [24, 24], [1, 1, 1], hudtrans);
	}
};

/*==========
Hud_DrawSmallValue
==========*/
void(vector pos, float value, float threshhold, float ralign) Hud_DrawSmallValue =
{
	value = bound(0, value, 999);
	
	string s = ftos(floor(value));
	float len = strlen(s);
	if (ralign)
		pos_x += 8 * (3 - len);

	while (len > 0)
	{
		len = len - 1;
		float c = str2chr(s, len);
		if (value <= threshhold)
			drawcharacter(pos + len * [8], c, [8,8], [0.5,0,0], hudtrans);
		else
			drawcharacter(pos + len * [8], c - 30, [8,8], [1,1,1], hudtrans);	// c-30 shifts to gold numbers
	}
};

/*==========
Hud_DrawItems
==========*/
void(vector virtsize) Hud_DrawItems =
{	
	vector pos = [(virtsize_x - 128) / 2, 0];
	drawsubpic(pos, [128,16], "gfx/ibar", [192/320,8/24], [128/320,16/24], [1,1,1], 1);
	
	// keys and powerups
	for (float i = 0; i < 6; i++)
	{
		// don't have the item
		if (!(hud_items & (1 << (i+17))))
			continue;
			
		float flash = (time - hud_item_time[i]) * 10;
		if (flash >= 10)
			flash = 0;
		else
			flash = (flash % 5) + 1;

		if (i == 3 && flash)	// stupid hack - the flash icons for the pentagram are named invul not invuln
			drawpic(pos + [16*i], strcat(hud_item_prefix[flash], "invul"), [16,16], [1,1,1], 1);
		else
			drawpic(pos + [16*i], strcat(hud_item_prefix[flash], hud_item_names[i]), [16,16], [1,1,1], 1);
	}

	// runes
	if (hud_runes & IT2_RUNE1)
		drawpic(pos + [96], "gfx/sb_sigil1", [8, 16], [1, 1, 1], hudtrans);
	if (hud_runes & IT2_RUNE2)
		drawpic(pos + [104], "gfx/sb_sigil2", [8, 16], [1, 1, 1], hudtrans);
	if (hud_runes & IT2_RUNE3)
		drawpic(pos + [112], "gfx/sb_sigil3", [8, 16], [1, 1, 1], hudtrans);
	if (hud_runes & IT2_RUNE4)
		drawpic(pos + [120], "gfx/sb_sigil4", [8, 16], [1, 1, 1], hudtrans);
};

/*==========
Hud_DrawWeapons
==========*/
void(vector virtsize) Hud_DrawWeapons =
{		
	float wp = getstatf(STAT_ACTIVEWEAPON);
	vector pos = [(virtsize_x - 192) / 2, virtsize_y - 16];
		
	for (float i = 0; i < 7; i++)
	{
		// don't have the weapon
		if (!(hud_items & (1 << i)))
			continue;
			
		float flash = (time - hud_weapon_time[i]) * 10;
		if (flash >= 10)
		{
			if (wp == (1 << i))
				flash = 1;
			else
				flash = 0;
		}
		else
			flash = (flash % 5) + 2;

		if (i == 6)		// thunderbolt is twice as wide
			drawpic(pos + [24*i], strcat(hud_weapon_prefix[flash], hud_weapon_names[i]), [48,16], [1,1,1], hudtrans);
		else
			drawpic(pos + [24*i], strcat(hud_weapon_prefix[flash], hud_weapon_names[i]), [24,16], [1,1,1], hudtrans);
	}
};

/*==========
Hud_DrawAmmo
==========*/
void(vector virtsize) Hud_DrawAmmo =
{
	// 
	// current ammo value and icon
	//
	vector pos = [virtsize_x - 32, virtsize_y - 32];
	
	if (hud_items & IT_SHELLS)
		drawpic(pos, "gfx/sb_shells", [24, 24], [1, 1, 1], hudtrans);
	else if (hud_items & IT_NAILS)
		drawpic(pos, "gfx/sb_nails", [24, 24], [1, 1, 1], hudtrans);
	else if (hud_items & IT_ROCKETS)
		drawpic(pos, "gfx/sb_rocket", [24, 24], [1, 1, 1], hudtrans);
	else if (hud_items & IT_CELLS)
		drawpic(pos, "gfx/sb_cells", [24, 24], [1, 1, 1], hudtrans);

	if (hud_items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS))	// don't draw with axe
	{
		float ca = getstatf(STAT_AMMO);
		Hud_DrawLargeValue(pos - [80], ca, 10, TRUE);
	}

	//
	// small ammo icons
	//
	pos = [(virtsize_x - 192) / 2, virtsize_y - 24];
		
	drawsubpic(pos, [192,24], "gfx/ibar", [0/320,0/24], [192/320,24/24], [1,1,1], hudtrans);
	Hud_DrawSmallValue(pos + [8, 0], getstatf(STAT_SHELLS), 10, TRUE);
	Hud_DrawSmallValue(pos + [56, 0], getstatf(STAT_NAILS), 10, TRUE);
	Hud_DrawSmallValue(pos + [104, 0], getstatf(STAT_ROCKETS), 10, TRUE);
	Hud_DrawSmallValue(pos + [152, 0], getstatf(STAT_CELLS), 10, TRUE);
};

/*==========
Hud_DrawArmor
==========*/
void(vector virtsize) Hud_DrawArmor =
{		
	if (!(hud_items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3 | IT_INVULNERABILITY)))
		return;

	vector pos = [116, virtsize_y - 32];
	
	if (hud_items & IT_INVULNERABILITY)
		drawpic(pos, "gfx/disc", [24, 24], [1, 1, 1], hudtrans);
	else if (hud_items & IT_ARMOR1)
		drawpic(pos, "gfx/sb_armor1", [24, 24], [1, 1, 1], hudtrans);
	else if (hud_items & IT_ARMOR2)
		drawpic(pos, "gfx/sb_armor2", [24, 24], [1, 1, 1], hudtrans);
	else if (hud_items & IT_ARMOR3)
		drawpic(pos, "gfx/sb_armor3", [24, 24], [1, 1, 1], hudtrans);

	if (hud_items & IT_INVULNERABILITY)
		Hud_DrawLargeValue(pos + [28], 666, 666, FALSE);
	else
		Hud_DrawLargeValue(pos + [28], getstatf(STAT_ARMOR), 20, FALSE);
};

/*==========
Hud_DrawHealth
==========*/
void(vector virtsize) Hud_DrawHealth =
{
	vector pos = [8, virtsize_y - 32];
	if (hud_items & IT_INVISIBILITY)
	{
		// special face for pent + ring
		if (hud_items & IT_INVULNERABILITY)
			drawpic(pos, "gfx/face_inv2", [24, 24], [1, 1, 1], hudtrans);
		else
			drawpic(pos, "gfx/face_invis", [24, 24], [1, 1, 1], hudtrans);
	}
	else if (hud_items & IT_INVULNERABILITY)
	{
		// the vanilla hud never used invul1, we use it for the normal pentagram
		// face and switch to invul2 when resisting attacks for a bit of variety
		if (hud_pain_time > time)
			drawpic(pos, "gfx/face_invul2", [24, 24], [1, 1, 1], hudtrans);
		else
			drawpic(pos, "gfx/face_invul1", [24, 24], [1, 1, 1], hudtrans);
	}
	else if (hud_pain_time > time)
	{
		if (hud_health < 20)
			drawpic(pos, "gfx/face_p5", [24, 24], [1, 1, 1], hudtrans);
		else if (hud_health < 40)
			drawpic(pos, "gfx/face_p4", [24, 24], [1, 1, 1], hudtrans);
		else if (hud_health < 60)
			drawpic(pos, "gfx/face_p3", [24, 24], [1, 1, 1], hudtrans);
		else if (hud_health < 80)
			drawpic(pos, "gfx/face_p2", [24, 24], [1, 1, 1], hudtrans);
		else
			drawpic(pos, "gfx/face_p1", [24, 24], [1, 1, 1], hudtrans);
	}
	else
	{
		if (hud_items & IT_QUAD)
			drawpic(pos, "gfx/face_quad", [24, 24], [1, 1, 1], hudtrans);
		else
		{
			if (hud_health < 20)
				drawpic(pos, "gfx/face5", [24, 24], [1, 1, 1], hudtrans);
			else if (hud_health < 40)
				drawpic(pos, "gfx/face4", [24, 24], [1, 1, 1], hudtrans);
			else if (hud_health < 60)
				drawpic(pos, "gfx/face3", [24, 24], [1, 1, 1], hudtrans);
			else if (hud_health < 80)
				drawpic(pos, "gfx/face2", [24, 24], [1, 1, 1], hudtrans);
			else
				drawpic(pos, "gfx/face1", [24, 24], [1, 1, 1], hudtrans);
		}
	}
	
	Hud_DrawLargeValue(pos + [28], hud_health, 20, FALSE);
};

/*==========
Hud_DrawStats
==========*/
void(vector virtsize) Hud_DrawStats =
{
	string s = strcat("kills: ", ftos(getstatf(STAT_MONSTERS)), " / ", ftos(getstatf(STAT_TOTALMONSTERS)) );
	s = strcat(s, " secrets: ", ftos(getstatf(STAT_SECRETS)), " / ", ftos(getstatf(STAT_TOTALSECRETS)) );
	vector pos = [virtsize_x / 2 - stringwidth(s, 0) / 2, virtsize_y - 16];
	drawstring(pos, s, [8, 8], [1,1,1], 1, 0);
	
	
	pos = [virtsize_x / 2 - stringwidth(world.message, 0) / 2, virtsize_y / 2 - 64];
	drawstring(pos, world.message, [8, 8], [1,1,1], 1, 0);
};

/*==========
CSQC_DrawScores
==========*/
void(vector virtsize, float showscores) CSQC_DrawScores =
{
	if (!showscores)
		return;
	if (!deathmatch)
		return;
};

/*==========
CSQC_DrawHud
==========*/
void(vector virtsize, float showscores) CSQC_DrawHud =
{	
	if (intermission)
		return;
	if (showscores)
	{
		Hud_DrawStats(virtsize);
		return;
	}
	
	hud_health = getstatf(STAT_HEALTH);
	// just draw a red haze when dead
	/*if (hud_health <= 0)
	{
		drawfill([0, 0, 0], virtsize, [1, 0, 0], 0.3);
		return;
	}*/
	// items have changed - keep track of
	// when a new item was picked up
	float it = getstatf(STAT_ITEMS, 0, 23);
	if (!hud_items)
		hud_items = it;
	else
	{
		if (it != hud_items)
		{
			// weapons
			for (float i = 0; i < 7; i++)
			{
				if (it & (1 << i))
					if (!(hud_items & (1 << i)))
						hud_weapon_time[i] = time;
			}
			// keys and powerups
			for (float i = 0; i < 6; i++)
			{
				if (it & (1 << (i+17)))
					if (!(hud_items & (1 << (i+17))))
						hud_item_time[i] = time;
			}
			// update hud_items with the new items
			hud_items = it;
		}
	}

	hud_runes = getstatf(STAT_ITEMS, 23, 9);
	
	Hud_DrawHealth(virtsize);
	Hud_DrawArmor(virtsize);
	Hud_DrawAmmo(virtsize);
	Hud_DrawWeapons(virtsize);
	Hud_DrawItems(virtsize);
};

/*==========
CSQC_ConsoleCommand
==========*/
float(string cmdstr) CSQC_ConsoleCommand =
{
	return FALSE;
};

/*==========
CSQC_Parse_Damage
==========*/
float(float save, float take, vector dir) CSQC_Parse_Damage =
{
	if (take)
		hud_pain_time = time + 0.2;
	return FALSE;
};

/*==========
CSQC_Init
==========*/
void(float apilevel, string enginename, float engineversion) CSQC_Init =
{
	
};
