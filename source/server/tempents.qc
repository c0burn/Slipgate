/*==========
te_teleport
==========*/
void(vector org) te_teleport =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_TELEPORT);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
};

/*==========
te_teleport
==========*/
void(vector org) te_explosion =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
};

/*==========
te_explosion2
==========*/
void(vector org, float col, float len) te_explosion2 =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION2);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
	WriteByte (MSG_BROADCAST, col);
	WriteByte (MSG_BROADCAST, len);
};

/*==========
te_tarexplosion
==========*/
void(vector org) te_tarexplosion =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_TAREXPLOSION);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
};
	
/*==========
te_gunshot
==========*/
void(vector org) te_gunshot =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_GUNSHOT);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
};

/*==========
te_spike
==========*/
void(vector org) te_spike =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_SPIKE);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
};

/*==========
te_superspike
==========*/
void(vector org) te_superspike =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
};

/*==========
te_wizspike
==========*/
void(vector org) te_wizspike =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_WIZSPIKE);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
};

/*==========
te_knightspike
==========*/
void(vector org) te_knightspike =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_KNIGHTSPIKE);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
};

/*==========
te_lightning1
==========*/
void(vector v1, vector v2, entity ent) te_lightning1 =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LIGHTNING1);
	WriteEntity (MSG_BROADCAST, ent);
	WriteCoord (MSG_BROADCAST, v1_x);
	WriteCoord (MSG_BROADCAST, v1_y);
	WriteCoord (MSG_BROADCAST, v1_z);
	WriteCoord (MSG_BROADCAST, v2_x);
	WriteCoord (MSG_BROADCAST, v2_y);
	WriteCoord (MSG_BROADCAST, v2_z);
};

/*==========
te_lightning2
==========*/
void(vector v1, vector v2, entity ent) te_lightning2 =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity (MSG_BROADCAST, ent);
	WriteCoord (MSG_BROADCAST, v1_x);
	WriteCoord (MSG_BROADCAST, v1_y);
	WriteCoord (MSG_BROADCAST, v1_z);
	WriteCoord (MSG_BROADCAST, v2_x);
	WriteCoord (MSG_BROADCAST, v2_y);
	WriteCoord (MSG_BROADCAST, v2_z);
};

/*==========
te_lightning3
==========*/
void(vector v1, vector v2, entity ent) te_lightning3 =
{
	WriteByte (MSG_ALL, SVC_TEMPENTITY);
	WriteByte (MSG_ALL, TE_LIGHTNING3);
	WriteEntity (MSG_ALL, ent);
	WriteCoord (MSG_ALL, v1_x);
	WriteCoord (MSG_ALL, v1_y);
	WriteCoord (MSG_ALL, v1_z);
	WriteCoord (MSG_ALL, v2_x);
	WriteCoord (MSG_ALL, v2_y);
	WriteCoord (MSG_ALL, v2_z);
};

/*==========
te_beam
==========*/
void(vector v1, vector v2, entity ent) te_beam =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_BEAM);
	WriteEntity (MSG_BROADCAST, ent);
	WriteCoord (MSG_BROADCAST, v1_x);
	WriteCoord (MSG_BROADCAST, v1_y);
	WriteCoord (MSG_BROADCAST, v1_z);
	WriteCoord (MSG_BROADCAST, v2_x);
	WriteCoord (MSG_BROADCAST, v2_y);
	WriteCoord (MSG_BROADCAST, v2_z);
};

/*==========
te_lavasplash
==========*/
void(vector org) te_lavasplash =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_LAVASPLASH);
	WriteCoord (MSG_BROADCAST, org_x);
	WriteCoord (MSG_BROADCAST, org_y);
	WriteCoord (MSG_BROADCAST, org_z);
};
