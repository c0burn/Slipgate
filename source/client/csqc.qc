vector mousecursor;
float playerangle;
vector playerpos;

void(float vwidth, float vheight, float notmenu) CSQC_UpdateView =
{
	clearscene();
	setviewprop(VF_DRAWENGINESBAR, 0);
	setviewprop(VF_DRAWCROSSHAIR, 0);
	setviewprop(VF_AFOV, 90);
	
	traceline(playerpos, playerpos + '0 0 200', FALSE, world);
	setviewprop(VF_ORIGIN, trace_endpos);
	
	setviewprop(VF_ANGLES, '90 0 0');
	
	vector m = mousecursor;
    m_z = 0.99;
	vector p1 = unproject(m);
	m_z = 0;
	vector p2 = unproject(m);
	traceline(p2, p1, TRUE, world);
	
	playerangle = vectoyaw(trace_endpos - playerpos);
	setviewprop(VF_CL_VIEWANGLES_Y, playerangle);
	
	addentities(MASK_ENGINE);
	renderscene();
	
	mousecursor_x = bound(0, mousecursor_x, vwidth);
	mousecursor_y = bound(0, mousecursor_y, vheight);
	drawstring(mousecursor, "+", [16,16], [8,0,0], 1, 0);
};

float PlayerDeltaListen(float isnew)
{
	
	playerpos = self.origin;
	return TRUE;
};

void(float apiver, string enginename, float enginever) CSQC_Init =
{
	deltalisten("progs/player.mdl", PlayerDeltaListen, 0);
};

void CSQC_Input_Frame(void)
{
	input_angles = [0, playerangle, 0];
}

float CSQC_InputEvent (float evtype, float scanx, float chary, float devid)
{
	switch(evtype)
	{
		case IE_MOUSEDELTA:
			mousecursor_x += scanx;
			mousecursor_y += chary;
			return TRUE;
		case IE_MOUSEABS:
			mousecursor_x = scanx;
			mousecursor_y = chary;
			return TRUE;
	}
	return FALSE;
};
