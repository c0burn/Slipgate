enumflags { ITEM_DONT_DROP=16, ITEM_RESPAWN };

/*==========
ItemRespawn
==========*/
void() ItemRespawn =
{
	sound (self, CHAN_VOICE, "items/itembk2.wav", 1, ATTN_NORM);
	self.model = self.mdl;
	self.solid = SOLID_TRIGGER;
	setorigin (self, self.origin);	// link back into world
};

/*==========
PlaceItem
==========*/
void() PlaceItem =
{
	self.mdl = self.model;
	self.flags = FL_ITEM;
	self.solid = SOLID_TRIGGER;
	
	if (self.spawnflags & ITEM_DONT_DROP)
	{
		self.movetype = MOVETYPE_NONE;
		setorigin(self, self.origin);
	}
	else
	{
		self.movetype = MOVETYPE_TOSS;
		setorigin(self, self.origin + '0 0 6');
		if (!droptofloor())
		{
			dprint(self.classname);
			dprint (" fell out of level at ");
			dprint (vtos(self.origin));
			dprint ("\n");
			remove(self);
		}
	}
};

/*==========
StartItem
==========*/
void() StartItem =
{
	if (self.spawnflags & (ITEM_DONT_DROP | ITEM_RESPAWN))
	{
		dprint("potential ");
		dprint(self.classname);
		dprint(" with erroneous spawnflag at ");
		dprint(vtos(self.origin));
		dprint("\n");
	}
	
	self.think = PlaceItem;
	self.nextthink = time + 0.2;
};
