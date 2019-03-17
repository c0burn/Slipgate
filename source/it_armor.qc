/*========================================
it_armor.qc
========================================*/

/*==========
armor_touch
==========*/
void() armor_touch =
{	
	if (other.classname != "player")
		return;
	if (other.health <= 0)
		return;
	// player already has better armor
	if (other.armortype*other.armorvalue >= self.armortype*self.armorvalue)
		return;

	sprint(other, "You got the ");
	sprint(other, self.netname);
	sprint(other, "\n");
	sound(other, CHAN_ITEM, "items/armor1.wav", 1, ATTN_NORM);
	stuffcmd (other, "bf\n");
	
	other.armortype = self.armortype;
	other.armorvalue = self.armorvalue;
	other.items = other.items - (other.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)) + self.items;

	self.solid = SOLID_NOT;
	self.model = string_null;
	if (deathmatch)
	{
		self.think = ItemRespawn;
		self.nextthink = time + 20;
	}
	
	// fire targets
	activator = other;
	UseTargets();
};

/*QUAKED item_armor1 (0 0 1) (-16 -16 0) (16 16 32) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ({"path" : "progs/armor.mdl", "skin" : 0});
}
Green armor. 100 points, saves 30% of damage.
*/
void() item_armor1 =
{
	self.items = IT_ARMOR1;
	self.armortype = 0.3;
	self.armorvalue = 100;
	self.netname = "Green Armor";
	self.touch = armor_touch;
	precache_model ("progs/armor.mdl");
	setmodel (self, "progs/armor.mdl");
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED item_armor2 (0 0 1) (-16 -16 0) (16 16 32) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ({"path" : "progs/armor.mdl", "skin" : 1});
}
Yellow armor. 150 points, saves 60% of damage.
*/
void() item_armor2 =
{
	self.items = IT_ARMOR2;
	self.armortype = 0.6;
	self.armorvalue = 150;
	self.netname = "Yellow Armor";
	self.touch = armor_touch;
	precache_model ("progs/armor.mdl");
	setmodel (self, "progs/armor.mdl");
	self.skin = 1;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};

/*QUAKED item_armorInv (0 0 1) (-16 -16 0) (16 16 32) X X X X X X X X NOT_IN_EASY NOT_IN_NORMAL NOT_IN_HARD NOT_IN_DM
{
	model ({"path" : "progs/armor.mdl", "skin" : 2});
}
Red armor. 200 points, saves 80% of damage.
*/
void() item_armorInv =
{
	self.items = IT_ARMOR3;
	self.armortype = 0.8;
	self.armorvalue = 200;
	self.netname = "Red Armor";
	self.touch = armor_touch;
	precache_model ("progs/armor.mdl");
	setmodel (self, "progs/armor.mdl");
	self.skin = 2;
	setsize (self, '-16 -16 0', '16 16 56');
	StartItem ();
};