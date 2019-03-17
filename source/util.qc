/*==========
realorigin
==========*/
vector(entity e) realorigin =
{
	return 0.5 * (e.absmin + e.absmax);
};

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
	
	dprint(vtos(org));
	dprint("\n");
	
	entity e = spawn();
	e.solid = SOLID_NOT;
	e.movetype = MOVETYPE_NONE;
	setmodel(e, "progs/s_bubble.spr");
	setsize(e, '0 0 0', '0 0 0');
	setorigin(e, org);
	
	e.think = SUB_Remove;
	e.nextthink = time + 5;
};

vector v_forward2, v_up2, v_right2;

/*==========
save_vectors
==========*/
void() save_vectors =
{
	v_forward2 = v_forward;
	v_up2 = v_up;
	v_right2 = v_right;
};

/*==========
restore_vectors
==========*/
void() restore_vectors = 
{
	v_forward = v_forward2;
	v_up = v_up2;
	v_right = v_right2;	
};

/*==========
cos
==========*/
float(float n) cos =
{
	save_vectors();
	
    vector ang = [0, n, 0];
    makevectors(ang);
    float result = v_forward_x;
    
    restore_vectors();
    return result;
};

/*==========
sin
==========*/
float(float n) sin =
{
	save_vectors();
	
    vector ang = [0, n, 0];
    makevectors(ang);
    float result = v_forward_y;
    
    restore_vectors();
    return result;
};

/*==========
tan
==========*/
float(float n) tan =
{
	save_vectors();
	
    vector ang = [0, n, 0];
    makevectors(ang);
    float result = v_forward_y / v_forward_x;
    
    restore_vectors();
    return result;
};

/*==========
atan2
==========*/
float(float y, float x) atan2 =
{
	vector ang = [x, y, 0];
	return vectoyaw(ang);
};
