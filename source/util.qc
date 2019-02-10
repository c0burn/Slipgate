/*==========
anglemod
correct an angle so it's between 0 and 359
==========*/
float(float v) anglemod =
{
	return v - floor(v/360) * 360;
};

/*==========
angcomp
calculate the difference between two angles
==========*/
float (float y1, float y2) angcomp =
{
	y1 = anglemod(y1);
	y2 = anglemod(y2);
	float answer = y1 - y2;
	if (answer > 180)
		answer = answer - 360;
	else if (answer < -180)
		answer = answer + 360;
	return answer;
};

/*==========
crandom
returns -1 to +1
==========*/
float() crandom =
{
	return 2 * (random() - 0.5);
};

/*==========
randomvec
returns a random vector with all 3 components between -1 and +1
==========*/
vector() randomvec =
{
	return [crandom(), crandom(), crandom()];
};

/*==========
randomrange
returns a whole number between 0 and range - 1
==========*/ 
float(float range) randomrange =
{
	if (range < 1)
		return 0;
	float result = floor(random() * range);
	// random can return 1 in vanilla engines
	if (result == range)
		return range - 1;
	else
		return result;
};

/*==========
spawn_debug_marker
==========*/
void(vector org) spawn_debug_marker =
{
	if (!developer)
		return;
	
	entity e = spawn();
	e.solid = SOLID_NOT;
	e.movetype = MOVETYPE_NONE;
	setmodel(e, "progs/s_bubble.spr");
	setsize(e, '0 0 0', '0 0 0');
	setorigin(e, org);
	
	e.think = SUB_Remove;
	e.nextthink = time + 5;
};
