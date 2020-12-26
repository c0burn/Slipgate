enumflags { H_ROTTEN, H_MEGA };

/*==========
health_touch
==========*/
void() health_touch =
{	
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
		
	// already at max health?
	if (other.health >= other.max_health)
		if (self.health < 100)
			return;
	// absolute max health
	if (other.health >= 250)
		return;

	// give health and cap it
	other.health = other.health + self.health;
	if (other.health > other.max_health)
		if (self.health < 100)
			other.health = other.max_health;
	if (other.health > 250)
		other.health = 250;
		
	sprint(other, "You receive ");
	sprint(other, ftos(self.health));
	sprint(other, " health\n");
	
	sound(other, CHAN_ITEM, self.noise, 1, ATTN_NORM);
	stuffcmd (other, "bf\n");

	if (self.health == 100)
	{
		other.items = other.items | IT_SUPERHEALTH;
		other.health_rot_time = time + 5;
	}
	
	self.model = string_null;
	self.solid = SOLID_NOT;
	if (deathmatch)
	{
		self.think = ItemRespawn;
		self.nextthink = time + 20;
	}
	
	// fire targets
	activator = other;
	UseTargets();
};

/*QUAKED item_health (0 0 1) (0 0 0) (32 32 56) Rotten Megahealth X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ( {{ spawnflags & 1 -> { "path" : "maps/b_bh10.bsp" }, spawnflags & 2 -> { "path" : "maps/b_bh100.bsp" },
	 "maps/b_bh25.bsp" }} );
}
Health box. Normally gives 25 points.
Rotten box heals 15 points.
Megahealth will add 100 health, then start to
rot the player back down to 100 health after 5 seconds.
*/
void() item_health =
{	
	if (self.spawnflags & H_ROTTEN)
	{
		precache_model("maps/b_bh10.bsp");
		setmodel(self, "maps/b_bh10.bsp");
		self.noise = "items/r_item1.wav";
		self.health = 15;
	}
	else if (self.spawnflags & H_MEGA)
	{
		precache_model("maps/b_bh100.bsp");
		setmodel(self, "maps/b_bh100.bsp");
		self.noise = "items/r_item2.wav";
		self.health = 100;
	}
	else
	{
		precache_model("maps/b_bh25.bsp");
		setmodel(self, "maps/b_bh25.bsp");
		self.noise = "items/health1.wav";
		self.health = 25;
	}
	precache_sound(self.noise);
	self.touch = health_touch;
	setsize (self, '0 0 0', '32 32 56');
	StartItem ();
};
