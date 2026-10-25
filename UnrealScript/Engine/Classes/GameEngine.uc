//=============================================================================
// GameEngine: The game subsystem.
// This is a built-in Unreal class and it shouldn't be modified.
//=============================================================================
class GameEngine extends Engine
	native
	noexport
	transient;

// URL structure.
struct URL
{
	var string			Protocol,	// Protocol, i.e. "unreal" or "http".
						Host;		// Optional hostname, i.e. "204.157.115.40" or "unreal.epicgames.com", blank if local.
	var int				Port;		// Optional host port.
	var string			Map;		// Map name, i.e. "SkyCity", default is "Index".
	var array<string>	Op;			// Options.
	var string			Portal;		// Portal to enter through, default is "".
	var bool			Valid;
};

var Level			GLevel,
					GEntry;
var PendingLevel	GPendingLevel;
var URL				LastURL;
var config array<string>	ServerActors,
					ServerPackages;

var bool			FramePresentPending;

//#ifdef R6CODE
var string          m_MapName;
//#endif//R6CODE

defaultproperties
{
     ServerActors(0)="IpDrv.UdpBeacon"
     ServerActors(1)="YHGCM.YHMutator"
     ServerPackages(0)="GamePlay"
     ServerPackages(1)="R6Abstract"
     ServerPackages(2)="R6Engine"
     ServerPackages(3)="R6GameService"
     ServerPackages(4)="R6Game"
     ServerPackages(5)="R61stWeapons"
     ServerPackages(6)="R6Weapons"
     ServerPackages(7)="R6WeaponGadgets"
     ServerPackages(8)="R63rdWeapons"
     ServerPackages(9)="YHGCM"
     CacheSizeMegs=32
}
