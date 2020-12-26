entity bodyque_head;

void() bodyque = {};

void() InitBodyQue =
{
	float count = 10;
	
	bodyque_head = world;
	entity prev = world;
	entity corpse = world;
	while (count)
	{
		corpse = spawn();
		corpse.classname = "bodyque";
		if (bodyque_head == world)
			bodyque_head = corpse;
		if (prev != world)
			prev.owner = corpse;
		prev = corpse;
		count = count - 1;
	}
	corpse.owner = bodyque_head;
};

void(entity ent) CopyToBodyQue =
{
	bodyque_head.angles = ent.angles;
	bodyque_head.model = ent.model;
	bodyque_head.modelindex = ent.modelindex;
	bodyque_head.frame = ent.frame;
	bodyque_head.colormap = ent.colormap;
	bodyque_head.movetype = ent.movetype;
	bodyque_head.velocity = ent.velocity;
	bodyque_head.flags = 0;
	setorigin (bodyque_head, ent.origin);
	setsize (bodyque_head, ent.mins, ent.maxs);
	bodyque_head = bodyque_head.owner;
};
