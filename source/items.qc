/*========================================
items.qc
========================================*/

/*==========
ItemRespawn
==========*/
void() ItemRespawn =
{
	sound (self, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM);
	self.model = self.mdl;
	self.solid = SOLID_TRIGGER;
	setorigin (self, self.origin);	// link into world
};

/*==========
PlaceItem
==========*/
void() PlaceItem =
{
	self.mdl = self.model;
	self.flags = FL_ITEM;
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_TOSS;
	setorigin(self, self.origin);	// link into world

	self.origin_z = self.origin_z + 6;
	if (!droptofloor())
	{
		dprint(self.classname);
		dprint (" fell out of level at ");
		dprint (vtos(self.origin));
		dprint ("\n");
		remove(self);
	}
};

/*==========
StartItem
==========*/
void() StartItem =
{
	self.think = PlaceItem;
	self.nextthink = time + 0.2;
};
