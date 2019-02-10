/*QUAKED info_null (.5 .5 .5) (-8 -8 -8) (8 8 8)
Used as a positional target for spotlights, etc.
*/
void() info_null =
{
	remove(self);
};

/*QUAKED info_intermission (1 0.5 0.5) (-8 -8 -8) (8 8 8)
This is the camera point for the intermission.
Use mangle instead of angle, so you can set pitch and roll as well as yaw.
*/
void() info_intermission = {};

/*QUAKED info_player_start (0 .5 0) (-16 -16 -24) (16 16 32)
{
	model ({"path" : "progs/player.mdl", "frame" : 12});
}
The normal starting point for a level.
*/
void() info_player_start = {};

/*QUAKED info_player_start2 (0 .5 0) (-16 -16 -24) (16 16 32)
{
	model ({"path" : "progs/player.mdl", "frame" : 12});
}
Only used on start map for the return point from an episode.
*/
void() info_player_start2 = {};

/*QUAKED info_player_test (0 .5 0) (-16 -16 -24) (16 16 32)
{
	model ({"path" : "progs/player.mdl", "frame" : 12});
}
For debugging. If developer mode is active, player will always spawn here.
*/
void() info_player_test = {};

/*QUAKED info_player_deathmatch (0 .5 0) (-16 -16 -24) (16 16 32)
{
	model ({"path" : "progs/player.mdl", "frame" : 12});
}
Potential spawning position for deathmatch games.
*/
void() info_player_deathmatch = {};

/*QUAKED info_player_coop (0 .5 0) (-16 -16 -24) (16 16 32)
{
	model ({"path" : "progs/player.mdl", "frame" : 12});
}
Potential spawning position for coop games.
*/
void() info_player_coop = {};

/*QUAKED info_teleport_destination (.5 .5 .5) (-16 -16 0) (16 16 56)
This is the destination marker for a teleporter.
It should have a "targetname" field with the same value as a teleporter's "target" field.
*/
void() info_teleport_destination =
{
	if (!self.targetname)
	{
		objerror ("no targetname");
		remove(self);
		return;
	}
	self.mangle = self.angles;
	self.angles = '0 0 0';
	self.model = "";
	self.origin = self.origin + '0 0 27';
};
