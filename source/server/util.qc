/*==========
SetStringDefault
==========*/
void(.string field, string val) SetStringDefault =
{
	if (!self.field)
		self.field = val;
};

/*==========
SetFloatDefault
==========*/
void(.float field, float val) SetFloatDefault =
{
	if (self.field == 0)
		self.field = val;
};

/*==========
SetPositiveDefault
==========*/
void(.float field, float val) SetPositiveDefault =
{
	if (self.field <= 0)
		self.field = val;
};

/*==========
realorigin
==========*/
vector(entity e) realorigin =
{
	return 0.5 * (e.absmin + e.absmax);
};

/*==========
anglemod
==========*/
float(float v) anglemod =
{
	return v - floor(v/360) * 360;
};

/*==========
angcomp
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
==========*/
float() crandom =
{
	return 2 * (random() - 0.5);
};

/*==========
randomvec
==========*/
vector() randomvec =
{
	return [crandom(), crandom(), crandom()];
};

/*==========
randomrange
==========*/ 
float(float range) randomrange =
{
	if (range < 1)
		return 0;
	float result = floor(random() * range);
	// random can return 1 in some engines
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
	e.classname = "DebugMarker";
	e.solid = SOLID_NOT;
	e.movetype = MOVETYPE_NONE;
	setmodel(e, "progs/s_bubble.spr");
	setsize(e, '0 0 0', '0 0 0');
	setorigin(e, org);
	
	e.think = SUB_Remove;
	e.nextthink = time + 5;
};

static vector v_forward2, v_up2, v_right2;

/*==========
save_vectors
==========*/
static inline void() save_vectors =
{
	v_forward2 = v_forward;
	v_up2 = v_up;
	v_right2 = v_right;
};

/*==========
restore_vectors
==========*/
static inline void() restore_vectors = 
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
