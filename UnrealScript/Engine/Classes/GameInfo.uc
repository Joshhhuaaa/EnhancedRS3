//=============================================================================
// GameInfo.
//
// The GameInfo defines the game being played: the game rules, scoring, what actors 
// are allowed to exist in this game type, and who may enter the game.  While the 
// GameInfo class is the public interface, much of this functionality is delegated 
// to several classes to allow easy modification of specific game components.  These 
// classes include GameInfo, AccessControl, Mutator, BroadcastHandler, and GameRules.  
// A GameInfo actor is instantiated when the level is initialized for gameplay (in 
// C++ UGameEngine::LoadMap() ).  The class of this GameInfo actor is determined by 
// (in order) either the DefaultGameType if specified in the LevelInfo, or the 
// DefaultGame entry in the game's .ini file (in the Engine.Engine section), unless 
// its a network game in which case the DefaultServerGame entry is used.  
//
//=============================================================================
class GameInfo extends Info
	native;

//-----------------------------------------------------------------------------
// Variables.

var	byte					  Difficulty;
var bool				      bRestartLevel;			// Level should be restarted when player dies
var bool				      bPauseable;				// Whether the game is pauseable.
//#ifndef R6CODE
//var config bool				  bCoopWeaponMode;			// Whether or not weapons stay when picked up.
//#endif // #ifndef R6CODE
var	bool				      bCanChangeSkin;			// Allow player to change skins in game.
var	bool					  bGameEnded;				// set when game ends
var	bool					  bOverTime;
var localized bool			  bAlternateMode;
var	bool					  bCanViewOthers;
var bool					  bDelayedStart;
var bool					  bWaitingToStartMatch;
var globalconfig bool		  bChangeLevels;
//#ifdef R6CODE
var bool                      m_bChangedServerConfig;
//#endif
var		bool				  bAlreadyChanged;

var	  globalconfig int		  GoreLevel;				// 0=Normal, increasing values=less gore
//#ifndef R6CODE
//var   globalconfig float	  AutoAim;					// How much autoaiming to do (1 = none, 0 = always).
//#endif // #ifndef R6CODE
														// (cosine of max error to correct)
var   globalconfig float	  GameSpeed;				// Scale applied to game rate.
var   float                   StartTime;

var   string				  DefaultPlayerClassName;

// user interface
//#ifndef R6CODE
//var	  string				  ScoreBoardType;
//#endif
var   string			      BotMenuType;				// Type of bot menu to display.
var   string			      RulesMenuType;			// Type of rules menu to display.
var   string				  SettingsMenuType;			// Type of settings menu to display.
var   string				  GameUMenuType;			// Type of Game dropdown to display.
var   string				  MultiplayerUMenuType;		// Type of Multiplayer dropdown to display.
var   string				  GameOptionsMenuType;		// Type of options dropdown to display.
var	  string				  HUDType;					// HUD class this game uses.
var   string				  MapListType;				// Maplist this game uses.
var   string			      MapPrefix;				// Prefix characters for names of maps for this game type.
var   string			      BeaconName;				// Identifying string used for finding LAN servers.

var   int	                  MaxSpectators;			// Maximum number of spectators.
var	  int					  NumSpectators;			// Current number of spectators.
var   int		              MaxPlayers; 
var   int					  NumPlayers;				// number of human players
var	  int					  NumBots;					// number of non-human players (AI controlled but participating as a player)
var   int					  CurrentID;
var localized string	      DefaultPlayerName;
var localized string	      GameName;

// Message classes.
var class<LocalMessage>		  DeathMessageClass;
var class<GameMessage>		  GameMessageClass;

//-------------------------------------
// GameInfo components
var string AccessControlClass;
var AccessControl AccessControl;		// AccessControl controls whether players can enter and/or become admins
var string BroadcastHandlerClass;
var BroadcastHandler BroadcastHandler;	// handles message (text and localized) broadcasts

var class<PlayerController> PlayerControllerClass;	// type of player controller to spawn for players logging in
var string PlayerControllerClassName;

// ReplicationInfo
var() class<GameReplicationInfo> GameReplicationInfoClass;
var GameReplicationInfo GameReplicationInfo;

// Statistics Logging
var StatLog						StatLog;
var globalconfig bool			bLocalLog;
var globalconfig bool			bWorldLog;
var bool						bLoggingGame;			// Does this gametype log?
var class<StatLog>				StatLogClass;

//#ifdef R6LOAD_IFGAMEMODE
var string m_szGameTypeFlag;
//#endif R6LOAD_IFGAMEMODE

//#ifdef R6CODE
// m_bGameStarted has the game started, usefull in MP in order to prevent other players from joining the game 
// exception needs to be made for spectating
var BOOL m_bGameStarted;
var BOOL m_bGameOver;
var BOOL m_bCompilingStats; // are we compiling statistics for GameMenuStats page
//#endif R6CODE

//#ifdef R6CODE // Added by John Bennett, April 2002
var string m_szCurrGameType;     // The current game type being played (Deathmatch, team death match, etc).
var string m_szGameOptions;     // List of command line options
var BOOL   m_bUseClarkVoice;
var Array<string> m_BankListToLoad;
var BOOL   m_bPlayIntroVideo;
var BOOL   m_bPlayOutroVideo;
var BOOL   m_bPendingLevelExists;
//#endif R6CODE

//#ifdef R6CODE
function SetJumpingMaps(bool _flagSetting, int iNextMapIndex);
native(1210) final function AbortScoreSubmission();
function RestartGameMgr();
event PreLogOut(PlayerController ExitingPlayer);
event bool CanPlayIntroVideo();
event bool CanPlayOutroVideo();
event UpdateServer();
//#endif R6CODE

// #ifdef R6NOISE
function R6GameInfoMakeNoise( Actor.ESoundType eType, Actor soundsource );
// #endif // #ifdef R6NOISE

#ifdefDEBUG
exec function ToggleRestart();
#endif

//------------------------------------------------------------------------------
// Engine notifications.    

function PreBeginPlay()
{
	StartTime = 0;
	SetGameSpeed(GameSpeed);
	GameReplicationInfo = Spawn(GameReplicationInfoClass);
	InitGameReplicationInfo();
}

function PostBeginPlay()
{
	if ( bAlternateMode )
		GoreLevel = 2;
	InitLogging();
	Super.PostBeginPlay();
}

/* Reset() 
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	Super.Reset();
	bGameEnded = false;
	bOverTime = false;
	bWaitingToStartMatch = true;
	InitGameReplicationInfo();
}

/* InitLogging()
Set up statistics logging
*/
function InitLogging()
{
	local bool bLoggingWorld;

	if ( !bLoggingGame )
		return;

	bLoggingWorld = bWorldLog &&
		((Level.NetMode == NM_DedicatedServer) || (Level.NetMode == NM_ListenServer));
	if ( bLocalLog || bLoggingWorld )
	{
		StatLog = spawn(StatLogClass);
		Log("Initiating logging using "$StatLog$" class "$Statlogclass);
		StatLog.GenerateLogs(bLocalLog, bLoggingWorld);
		StatLog.StartLog();
		LogGameParameters();
	}
}

function Timer()
{
	BroadcastHandler.UpdateSentText();
}

// Called when game shutsdown.
event GameEnding()
{
	EndLogging("serverquit");
}

//------------------------------------------------------------------------------
// Replication

function InitGameReplicationInfo()
{
	GameReplicationInfo.GameName = GameName;
	GameReplicationInfo.GameClass = string(Class);
}

native function string GetNetworkNumber();
//#ifdef R6CODE
native(1514) final function ProcessR6Availabilty( string szGameType );
native(1280) final function INT GetCurrentMapNum();
native(1281) final function SetCurrentMapNum(INT iMapNum);
function SetUdpBeacon(InternetInfo _udpBeacon);
//#endif R6CODE

//------------------------------------------------------------------------------
// Game Querying.

function string GetInfo()
{
	local string ResultSet;

	// World logging enabled and working
	if ( StatLog.bWorld && !StatLog.bWorldBatcherError )
		ResultSet = "\\worldlog\\true";
	else
		ResultSet = "\\worldlog\\false";

	// World logging activated
	if ( StatLog.bWorld )
		ResultSet = ResultSet$"\\wantworldlog\\true";
	else
		ResultSet = ResultSet$"\\wantworldlog\\false";

	return ResultSet;
}

// Return the server's port number.
function int GetServerPort()
{
	local string S;
	local int i;

	// Figure out the server's port.
	S = Level.GetAddressURL();
	i = InStr( S, ":" );
	assert(i>=0);
	return int(Mid(S,i+1));
}

function bool SetPause( BOOL bPause, PlayerController P )
{
	if( bPauseable || Level.Netmode==NM_Standalone )
	{
		if( bPause )
			Level.Pauser=P.PlayerReplicationInfo;
		else
			Level.Pauser=None;
		return True;
	}
	else return False;
}

//------------------------------------------------------------------------------
// Stat Logging.

function LogGameParameters()
{
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"GameName"$Chr(9)$GameName);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"GameClass"$Chr(9)$Class);// <-- Move to c++
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"GameVersion"$Chr(9)$Level.EngineVersion);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"MinNetVersion"$Chr(9)$Level.MinNetVersion);
//#ifndef R6CODE
//	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"WeaponsStay"$Chr(9)$bCoopWeaponMode);
//#endif // #ifndef R6CODE
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"GoreLevel"$Chr(9)$GoreLevel);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"GameSpeed"$Chr(9)$int(GameSpeed*100));
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"MaxSpectators"$Chr(9)$MaxSpectators);
	StatLog.LogEventString(StatLog.GetTimeStamp()$Chr(9)$"game"$Chr(9)$"MaxPlayers"$Chr(9)$MaxPlayers);
}

//------------------------------------------------------------------------------
// Game parameters.

//
// Set gameplay speed.
//
function SetGameSpeed( Float T )
{
	local float OldSpeed;

#ifdefMPDEMO
    T = 1;
#endif
    
	OldSpeed = GameSpeed;
	GameSpeed = FMax(T, 0.1);
	Level.TimeDilation = GameSpeed;
	if ( GameSpeed != OldSpeed )
		SaveConfig();
	SetTimer(Level.TimeDilation, true);
}

//#ifdef R6CODE
function SetGamePassword(string szPasswd)
{
    local R6ServerInfo  pServerOptions;

    pServerOptions = class'Actor'.static.GetServerOptions();

    AccessControl.SetGamePassword(szPasswd);
    pServerOptions.GamePassword = szPasswd;
    pServerOptions.UsePassword = !(szPasswd=="");
    pServerOptions.SaveConfig();
}
//#endif R6CODE

//
// Called after setting low or high detail mode.
//
event DetailChange()
{
	local actor A;
	local zoneinfo Z;

	if( !Level.bHighDetailMode )
	{
		foreach DynamicActors(class'Actor', A)
		{
			if( A.bHighDetail && !A.bGameRelevant )
				A.Destroy();
		}
	}
	foreach AllActors(class'ZoneInfo', Z)
		Z.LinkToSkybox();
}

//------------------------------------------------------------------------------
// Player start functions

//
// Grab the next option from a string.
//
function bool GrabOption( out string Options, out string Result )
{
	if( Left(Options,1)=="?" )
	{
		// Get result.
		Result = Mid(Options,1);
		if( InStr(Result,"?")>=0 )
			Result = Left( Result, InStr(Result,"?") );

		// Update options.
		Options = Mid(Options,1);
		if( InStr(Options,"?")>=0 )
			Options = Mid( Options, InStr(Options,"?") );
		else
			Options = "";

		return true;
	}
	else return false;
}

//
// Break up a key=value pair into its key and value.
//
function GetKeyValue( string Pair, out string Key, out string Value )
{
	if( InStr(Pair,"=")>=0 )
	{
		Key   = Left(Pair,InStr(Pair,"="));
		Value = Mid(Pair,InStr(Pair,"=")+1);
	}
	else
	{
		Key   = Pair;
		Value = "";
	}
}

/* ParseOption()
 Find an option in the options string and return it.
*/
function string ParseOption( string Options, string InKey )
{
	local string Pair, Key, Value;
	while( GrabOption( Options, Pair ) )
	{
		GetKeyValue( Pair, Key, Value );
		if( Key ~= InKey )
			return Value;
	}
	return "";
}

/* Initialize the game.
 The GameInfo's InitGame() function is called before any other scripts (including 
 PreBeginPlay() ), and is used by the GameInfo to initialize parameters and spawn 
 its helper classes.
 Warning: this is called before actors' PreBeginPlay.
*/
event InitGame( string Options, out string Error )
{
	local string InOpt, LeftOpt;
	local int pos;
	local class<AccessControl> ACClass;
	local class<BroadcastHandler> BHClass;

	log( "InitGame:" @ Options );
	MaxPlayers = Min( 32,GetIntOption( Options, "MaxPlayers", MaxPlayers ));
	Difficulty = GetIntOption(Options, "Difficulty", Difficulty);

	InOpt = ParseOption( Options, "GameSpeed");
	if( InOpt != "" )
	{
		log("GameSpeed"@InOpt);
		SetGameSpeed(float(InOpt));
	}

	BHClass = class<BroadcastHandler>(DynamicLoadObject(BroadcastHandlerClass,Class'Class'));
	BroadcastHandler = spawn(BHClass);
    
	InOpt = ParseOption( Options, "AccessControl");
	if( InOpt != "" )
		ACClass = class<AccessControl>(DynamicLoadObject(InOpt, class'Class'));
	if ( ACClass != None )
		AccessControl = Spawn(ACClass);
	else
	{
		ACClass = class<AccessControl>(DynamicLoadObject(AccessControlClass, class'Class'));
		AccessControl = Spawn(ACClass);
	}

	InOpt = ParseOption( Options, "AdminPassword");
	if( InOpt!="" )
		AccessControl.SetAdminPassword(InOpt);

	InOpt = ParseOption( Options, "GamePassword");
	if( InOpt != "" )
	{
		AccessControl.SetGamePassWord(InOpt);
		log( "GamePassword" @ InOpt );
	}

	InOpt = ParseOption( Options, "LocalLog");
	if( InOpt ~= "true" )
		bLocalLog = True;

	InOpt = ParseOption( Options, "WorldLog");
	if( InOpt ~= "true" )
		bWorldLog = True;

}

// Deploy all characters in the map after all options were selected in the menus.
//#ifdef R6BUILDPLANNINGPHASE
function DeployCharacters(PlayerController PController)
{
    //Defined in R6GameInfo
    log("Wrong Deploy character");
}
//#ifdef R6BUILDPLANNINGPHASE

//
// Return beacon text for serverbeacon.
//
event string GetBeaconText()
{	
	return
		Level.ComputerName
	@	Left(Level.Title,24) 
	@	BeaconName
	@	NumPlayers
	$	"/"
	$	MaxPlayers;
}

/* ProcessServerTravel()
 Optional handling of ServerTravel for network games.
*/
function ProcessServerTravel( string URL, bool bItems )
{
	local playercontroller P, LocalPlayer;

	EndLogging("mapchange");

	// Notify clients we're switching level and give them time to receive.
	// We call PreClientTravel directly on any local PlayerPawns (ie listen server)
//#ifdef R6Code
    m_bPendingLevelExists=true;
//#endif
	foreach DynamicActors( class'PlayerController', P )
		if( NetConnection( P.Player)!=None )
//#ifndef R6Code
//		if( NetConnection( P.Player)!=None )
//            P.ClientTravel( URL, TRAVEL_Relative, bItems );
//#else 
		if( NetConnection( P.Player)!=None )
			P.ClientTravel( URL$"?Password="$AccessControl.GetGamePassword(), TRAVEL_Relative, bItems );
//#endif
		else
		{	
			LocalPlayer = P;
			P.PreClientTravel();
		}
//#ifndef R6Code
//	if ( (Level.NetMode == NM_ListenServer) && (LocalPlayer != None) )
//		Level.NextURL = Level.NextURL$"?Skin="$LocalPlayer.GetDefaultURL("Skin")
//					 $"?Face="$LocalPlayer.GetDefaultURL("Face")
//					 $"?Team="$LocalPlayer.GetDefaultURL("Team")
//					 $"?Name="$LocalPlayer.GetDefaultURL("Name")
//					 $"?Class="$LocalPlayer.GetDefaultURL("Class");
//#else

	if ( (Level.NetMode == NM_ListenServer) && (LocalPlayer != None) )
		Level.NextURL = Level.NextURL$"?Skin="$LocalPlayer.GetDefaultURL("Skin")
					 $"?Face="$LocalPlayer.GetDefaultURL("Face")
					 $"?Team="$LocalPlayer.GetDefaultURL("Team")
					 $"?Name="$LocalPlayer.GetDefaultURL("Name")
					 $"?Class="$LocalPlayer.GetDefaultURL("Class")
                     $"?Password="$AccessControl.GetGamePassword();
//#endif
	// Switch immediately if not networking.
	if( Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
		Level.NextSwitchCountdown = 0.0;
}

//
// Accept or reject a player on the server.
// Fails login if you set the Error to a non-empty string.
//
event PreLogin
(
	string Options,
	string Address,
	out string Error,
	out string FailCode
)
{
	local bool bSpectator;
	local string spec;

	spec = ParseOption ( Options, "SpectatorOnly" );	
	bSpectator = ( spec != "" );

	AccessControl.PreLogin(Options, Address, Error, FailCode, bSpectator);
}

function int GetIntOption( string Options, string ParseString, int CurrentValue)
{
	local string InOpt;

	InOpt = ParseOption( Options, ParseString );
	if ( InOpt != "" )
	{
		log(ParseString@InOpt);
		return int(InOpt);
	}	
	return CurrentValue;
}

function bool AtCapacity(bool bSpectator)
{
	if ( Level.NetMode == NM_Standalone )
		return false;

	if ( bSpectator )
		return ( (NumSpectators >= MaxSpectators)
			&& ((Level.NetMode != NM_ListenServer) || (NumPlayers > 0)) );
	else
		return ( (MaxPlayers>0) && (NumPlayers>=MaxPlayers) );
}

//
// Log a player in.
// Fails login if you set the Error string.
// PreLogin is called before Login, but significant game time may pass before
// Login is called, especially if content is downloaded.
//
event PlayerController Login
(
	string Portal,
	string Options,
	out string Error
)
{
	local NavigationPoint StartSpot;
	local PlayerController NewPlayer;
	local class<Pawn> DesiredPawnClass;
	local Pawn      TestPawn;
	local string          InName, InPassword, InChecksum, InClass;
	local byte            InTeam;
	local bool bSpectator;

	bSpectator = ( ParseOption( Options, "SpectatorOnly" ) != "" );

	// Make sure there is capacity. (This might have changed since the PreLogin call).
	if ( AtCapacity(bSpectator) )
	{
		Error=GameMessageClass.Default.MaxedOutMessage;
		return None;
	}

	// Get URL options.
	InName     = Left(ParseOption ( Options, "Name"), 20);
	InTeam     = GetIntOption( Options, "Team", 255 ); // default to "no team"
	InPassword = ParseOption ( Options, "Password" );
	InChecksum = ParseOption ( Options, "Checksum" );

	log( "Login:" @ InName );
	if( InPassword != "" )
		log( "Password"@InPassword );

	// Find a start spot.
	StartSpot = FindPlayerStart( None, InTeam, Portal );

	if( StartSpot == None )
	{
        Error=Localize("MPMiscMessages", "FailedPlaceMessage", "R6GameInfo");
		return None;
	}

	// Init player's administrative privileges
//	if ( AccessControl.AdminLogin(NewPlayer, InPassword) )
//	{
//		NewPlayer = spawn(AccessControl.AdminClass,,,StartSpot.Location,StartSpot.Rotation);
//		bSpectator = true;
//	}
//	else
//	{
		if ( PlayerControllerClass == None )
			PlayerControllerClass = class<PlayerController>(DynamicLoadObject(PlayerControllerClassName, class'Class'));
		NewPlayer = spawn(PlayerControllerClass,,,StartSpot.Location,StartSpot.Rotation);
//	}

	// Handle spawn failure.
	if( NewPlayer == None )
	{
		log("Couldn't spawn player controller of class "$PlayerControllerClass);
		Error = GameMessageClass.Default.FailedSpawnMessage;
		return None;
	}

	NewPlayer.StartSpot = StartSpot;

	// Init player's name
	if( InName=="" )
		InName=DefaultPlayerName;
	
	if(NewPlayer.PlayerReplicationInfo != none)		// R6CODE
	{
		if( Level.NetMode!=NM_Standalone || NewPlayer.PlayerReplicationInfo.PlayerName==DefaultPlayerName )
			ChangeName( NewPlayer, InName, false );

		// Init player's replication info
		NewPlayer.GameReplicationInfo = GameReplicationInfo;
	}

	NewPlayer.GotoState('Spectating');

	if ( bSpectator )
	{
		NewPlayer.bOnlySpectator = true;
		NewPlayer.PlayerReplicationInfo.bIsSpectator = true;
		NumSpectators++;
		return NewPlayer;
	}

	// Set the player's ID.
	if(NewPlayer.PlayerReplicationInfo != none)		// R6CODE
		NewPlayer.PlayerReplicationInfo.PlayerID = CurrentID++;

	InClass = ParseOption( Options, "Class" );
	if ( InClass != "" )
	{
		DesiredPawnClass = class<Pawn>(DynamicLoadObject(InClass, class'Class'));
		if ( DesiredPawnClass != None )
			NewPlayer.PawnClass = DesiredPawnClass;
	}

	// Log it.
	if ( StatLog != None )
		StatLog.LogPlayerConnect(NewPlayer);
	NewPlayer.ReceivedSecretChecksum = !(InChecksum ~= "NoChecksum");

	NumPlayers++;

	// If we are a server, broadcast a welcome message.
	if( Level.NetMode==NM_DedicatedServer || Level.NetMode==NM_ListenServer )
		BroadcastLocalizedMessage(GameMessageClass, 1, NewPlayer.PlayerReplicationInfo);

	// if delayed start, don't give a pawn to the player yet
	// Normal for multiplayer games
	if ( bDelayedStart )
	{
		NewPlayer.GotoState('BaseSpectating'); //		NewPlayer.GotoState('PlayerWaiting');
		return NewPlayer;	
	}

	// Try to match up to existing unoccupied player in level,
	// for savegames and coop level switching.
	ForEach DynamicActors(class'Pawn', TestPawn )
	{
		if ( (TestPawn!=None) && (PlayerController(TestPawn.Controller)!=None) && (PlayerController(TestPawn.Controller).Player==None) && (TestPawn.Health > 0)
			&&  (TestPawn.OwnerName~=InName) )
		{
            NewPlayer.Destroy();
            TestPawn.SetRotation(TestPawn.Controller.Rotation);
            TestPawn.bInitializeAnimation = false; // FIXME - temporary workaround for lack of meshinstance serialization
            TestPawn.PlayWaiting();
            return PlayerController(TestPawn.Controller);
		}
	}

	return newPlayer;
}	

/* StartMatch()
Start the game - inform all actors that the match is starting, and spawn player pawns
*/
function StartMatch()
{	
	local Controller P;
	local Actor A; 

	if (StatLog != None)
		StatLog.LogGameStart();

	// tell all actors the game is starting
	ForEach AllActors(class'Actor', A)
		A.MatchStarting();

	// start human players first
	for ( P = Level.ControllerList; P!=None; P=P.nextController )
		if ( P.IsA('PlayerController') && (P.Pawn == None) )
		{
			if ( bGameEnded ) return; // telefrag ended the game with ridiculous frag limit
			else if ( !PlayerController(P).bOnlySpectator  )
                RestartPlayer(P);
		}

	// start AI players
//#ifdef R6CODE
//	for ( P = Level.ControllerList; P!=None; P=P.nextController )
//		if ( P.bIsPlayer && !P.IsA('PlayerController') )
//			RestartPlayer(P);
//
//        bWaitingToStartMatch = false;
//#endif R6CODE
}

//
// Restart a player.
//
function RestartPlayer( Controller aPlayer )	
{
    /* // r6code: not needed. it spawn a useless pawn in the entry level.
    
	local NavigationPoint startSpot;
	local int TeamNum;
	local class<Pawn> DefaultPlayerClass;

	if( bRestartLevel && Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
        return;
//#ifndef R6CODE we don't need this
//	if ( (aPlayer.PlayerReplicationInfo == None) || (aPlayer.PlayerReplicationInfo.Team == None) )
//        TeamNum = 255;
//	else
//    {
//        TeamNum = aPlayer.PlayerReplicationInfo.Team.TeamIndex;
//    }
//#endif R6CODE
	startSpot = FindPlayerStart(aPlayer, TeamNum);
	if( startSpot == None )
	{
		log(" Player start not found!!!");
		return;
	}	

//#ifndef R6CODE  we don't need this
//	if ( (aPlayer.PlayerReplicationInfo.Team != None)
//		&& ((aPlayer.PawnClass == None) || !aPlayer.PlayerReplicationInfo.Team.BelongsOnTeam(aPlayer.PawnClass)) )
//			aPlayer.PawnClass = aPlayer.PlayerReplicationInfo.Team.DefaultPlayerClass;
//    if (aPlayer.PreviousPawnClass!=None && aPlayer.PawnClass != aPlayer.PreviousPawnClass)
//		BaseMutator.PlayerChangedClass(aPlayer);			
//#endif R6CODE
	if ( aPlayer.PawnClass != None )
		aPlayer.Pawn = Spawn(aPlayer.PawnClass,,,StartSpot.Location,StartSpot.Rotation);

 
	if( aPlayer.Pawn==None )
	{
		aPlayer.PawnClass = GetDefaultPlayerClass();
		aPlayer.Pawn = Spawn(aPlayer.PawnClass,,,StartSpot.Location,StartSpot.Rotation,true);
	}
	if ( aPlayer.Pawn == None )
	{
		log("Couldn't spawn player of type "$aPlayer.PawnClass$" at "$StartSpot);
		aPlayer.GotoState('Dead');
		return;
	}

	aPlayer.PreviousPawnClass = aPlayer.Pawn.Class;

	aPlayer.Possess(aPlayer.Pawn);
	aPlayer.PawnClass = aPlayer.Pawn.Class;

	aPlayer.PlayTeleportEffect(true, true);
	aPlayer.ClientSetRotation(aPlayer.Pawn.Rotation);

	AddDefaultInventory(aPlayer.Pawn);
	TriggerEvent( StartSpot.Event, StartSpot, aPlayer.Pawn);
    */
}

function class<Pawn> GetDefaultPlayerClass()
{
	return class<Pawn>(DynamicLoadObject(DefaultPlayerClassName,class'Class'));
}

//
// Called after a successful login. This is the first place
// it is safe to call replicated functions on the PlayerPawn.
//
event PostLogin( PlayerController NewPlayer )
{
	local Controller P;
//#ifndef R6CODE
//	local class<Scoreboard> S;
//#endif
	local class<HUD> H;

	if ( !bDelayedStart )
	{
		// start match, or let player enter, immediately
		bRestartLevel = false;	// let player spawn once in levels that must be restarted after every death
		if ( bWaitingToStartMatch )
			StartMatch();
		else
            RestartPlayer(newPlayer);
		bRestartLevel = Default.bRestartLevel;
	}
    
	// Start player's music.
	NewPlayer.ClientSetMusic( Level.Song, MTRAN_Fade );
	
	// tell client what hud and scoreboard to use
	H = class<HUD>(DynamicLoadObject(HUDType, class'Class'));
//#ifndef R6Code
//	S = class<Scoreboard>(DynamicLoadObject(ScoreboardType, class'Class'));
//#end R6CODE
	NewPlayer.ClientSetHUD(H,none);

	if ( NewPlayer.Pawn != None )
		NewPlayer.Pawn.ClientSetRotation(NewPlayer.Pawn.Rotation);
}

//
// Player exits.
//
function Logout( Controller Exiting )
{
	local bool bMessage;

	bMessage = true;
	if ( PlayerController(Exiting) != None )
	{
		if ( PlayerController(Exiting).bOnlySpectator )
		{
			bMessage = false;
			if ( Level.NetMode == NM_DedicatedServer )
				NumSpectators--;
		}
		else
			NumPlayers--;
	}
	if( bMessage && (Level.NetMode==NM_DedicatedServer || Level.NetMode==NM_ListenServer) )
		BroadcastLocalizedMessage(GameMessageClass, 4, Exiting.PlayerReplicationInfo);

	if ( StatLog != None )
		StatLog.LogPlayerDisconnect(Exiting);
}

//
// Examine the passed player's inventory, and accept or discard each item.
// AcceptInventory needs to gracefully handle the case of some inventory
// being accepted but other inventory not being accepted (such as the default
// weapon).  There are several things that can go wrong: A weapon's
// AmmoType not being accepted but the weapon being accepted -- the weapon
// should be killed off. Or the player's selected inventory item, active
// weapon, etc. not being accepted, leaving the player weaponless or leaving
// the HUD inventory rendering messed up (AcceptInventory should pick another
// applicable weapon/item as current).
//
event AcceptInventory(pawn PlayerPawn)
{
	//default accept all inventory except default weapon (spawned explicitly)
}

/* SetPlayerDefaults()
 first make sure pawn properties are back to default, then give mutators an opportunity
 to modify them
*/
function SetPlayerDefaults(Pawn PlayerPawn)
{
	PlayerPawn.JumpZ = PlayerPawn.Default.JumpZ;
	PlayerPawn.AirControl = PlayerPawn.Default.AirControl;
}


// %k = Owner's PlayerName (Killer)
// %o = Other's PlayerName (Victim)
// %w = Owner's Weapon ItemName
static native function string ParseKillMessage( string KillerName, string VictimName, string DeathMessage );
/* R6CODE
function Kick( string S )
{
	AccessControl.Kick(S);
}*/
function KickBan( string S )
{
	AccessControl.KickBan(S);
}

//-------------------------------------------------------------------------------------
// Level gameplay modification.

//
// Return whether Viewer is allowed to spectate from the
// point of view of ViewTarget.
//
function bool CanSpectate( PlayerController Viewer, bool bOnlySpectator, actor ViewTarget )
{
	return true;
}

//#ifndef R6CODE
// Return whether an item should respawn.
//function bool ShouldRespawn( Pickup Other )
//{
//	if( Level.NetMode == NM_StandAlone )
//		return false;
//
//	return Other.ReSpawnTime!=0.0;
//}

// Called when pawn has a chance to pick Item up (i.e. when 
//  the pawn touches a weapon pickup). Should return true if 
//  he wants to pick it up, false if he does not want it.
//function bool PickupQuery( Pawn Other, Pickup item )
//{
//	local byte bAllowPickup;
//
//	if ( (GameRulesModifiers != None) && GameRulesModifiers.OverridePickupQuery(Other, item, bAllowPickup) )
//		return (bAllowPickup == 1);
//
//    if ( Other.Inventory == None )
//		return true;
//	else
//        return false;
//}

// Discard a player's inventory after he dies.
//function DiscardInventory( Pawn Other )
//{
//	local inventory Inv,Next;
//	local float speed;
//
//	if( (Other.Weapon!=None) && Other.Weapon.bCanThrow && Other.Weapon.HasAmmo() )
//	{
//		if ( Other.Weapon.PickupAmmoCount == 0 )
//			Other.Weapon.PickupAmmoCount = 1;
//		speed = VSize(Other.Velocity);
//		if (speed != 0)
//			Other.TossWeapon(Normal(Other.Velocity/speed + 0.5 * VRand()) * (speed + 280));
//		else 
//			Other.TossWeapon(vect(0,0,0));
//	}
//	Other.Weapon = None;
//	Other.SelectedItem = None;
//	Inv = Other.Inventory;
//	while ( Inv != None )
//	{
//		Next = Inv.Inventory;
//		Inv.Destroy();
//		Inv = Next;
//	}	
//}
//#endif // #ifndef R6CODE

/* Try to change a player's name.
*/	
function ChangeName( Controller Other, coerce string S, bool bNameChange, optional bool bDontBroadcastNameChange )
{
    local string szNewNameMessage;
    local string _szNewName;

    _szNewName = TransformName(Other.PlayerReplicationInfo, S);

	if( _szNewName == "" )
		return;

    if(Caps(Other.PlayerReplicationInfo.PlayerName) == Caps(_szNewName))
        bDontBroadcastNameChange = true;

	if ( StatLog != None)
		StatLog.LogNameChange(Other);

	Other.PlayerReplicationInfo.SetPlayerName(_szNewName);

	if( bNameChange && (PlayerController(Other) != None) )
		BroadcastLocalizedMessage( GameMessageClass, 2, Other.PlayerReplicationInfo );	

    /*  R6CODE
    if(bDontBroadcastNameChange == false)
        Broadcast( none, szNewNameMessage, 'ServerMessage');
    */
}

// this function will return a unique player name based on the one requested
function string TransformName(PlayerReplicationInfo PRI, string NameRequested)
{
    local int _index;

    if (!NameInUse(PRI, NameRequested))
        return NameRequested;
    else
    {
        _index = 1;
        while (NameInUse(PRI, NameRequested $"(" $ _index $")" ) )
        {
            _index++;
        }
        return NameRequested $"(" $ _index $")";
    }
}

// returns true if name is currently being used
function bool NameInUse(PlayerReplicationInfo PRI, string NameRequested)
{
    local PlayerReplicationInfo _PRI;
    foreach DynamicActors(class'PlayerReplicationInfo', _PRI)
    {
        if((PRI != _PRI) && Caps(_PRI.PlayerName) == Caps(NameRequested))
            return true;    // yes this name is in use
    }
    return false;   // this name is not in use
}

/* Send a player to a URL.
*/
function SendPlayer( PlayerController aPlayer, string URL )
{
	aPlayer.ClientTravel( URL, TRAVEL_Relative, false );
}

/* Restart the game.
*/
// #ifndef R6CODE
//function RestartGame()
//{
//	local string NextMap;
//	local MapList myList;
//	local class<MapList> ML;
//    local R6ServerInfo  pServerOptions;
//    
//    pServerOptions = class'Actor'.static.GetServerOptions();
//
//	if ( (GameRulesModifiers != None) && GameRulesModifiers.HandleRestartGame() )
//		return;
//
//	// these server travels should all be relative to the current URL
//	if ( bChangeLevels && !bAlreadyChanged && (MapListType != "") )
//	{
//		// open a the nextmap actor for this game type and get the next map
//		bAlreadyChanged = true;
//		ML = class<MapList>(DynamicLoadObject(MapListType, class'Class'));
//		myList = spawn(ML);
//		NextMap = myList.GetNextMap();
//        pServerOptions.SaveConfig();
//		myList.Destroy();
//		if ( NextMap == "" )
//			NextMap = GetMapName(MapPrefix, NextMap,1);
//
//		if ( NextMap != "" )
//		{
//			Level.ServerTravel(NextMap, false);
//			return;
//		}
//	}
//
//	Level.ServerTravel( "?Restart", true );
//}
// #else R6CODE
function RestartGame()
{
	local string NextMap;
	local MapList myList;
    local R6ServerInfo  pServerOptions;

    pServerOptions = class'Actor'.static.GetServerOptions();

	// these server travels should all be relative to the current URL
    if ( bChangeLevels && !bAlreadyChanged )
	{
		// open a the nextmap actor for this game type and get the next map
		bAlreadyChanged = true;
        myList = pServerOptions.m_ServerMapList;
        if (m_bChangedServerConfig==true)
        {
            NextMap = myList.GetNextMap(1);
        }
        else
        {
            NextMap = myList.GetNextMap(myList.K_NextDefaultMap);
        }
		if ( NextMap == "" )
			NextMap = GetMapName(MapPrefix, NextMap,1);

		if ( NextMap != "" )
		{
			Level.ServerTravel(NextMap, false);
			return;
		}
	}

	Level.ServerTravel( "?Restart", true );
}
//#endif R6CODE

//==========================================================================
// Message broadcasting functions (handled by the BroadCastHandler)

event Broadcast( Actor Sender, coerce string Msg, optional name Type )
{
	BroadcastHandler.Broadcast(Sender,Msg,Type);
}

function BroadcastTeam( Actor Sender, coerce string Msg, optional name Type )
{
	BroadcastHandler.BroadcastTeam(Sender,Msg,Type);
}

/*
 Broadcast a localized message to all players.
 Most message deal with 0 to 2 related PRIs.
 The LocalMessage class defines how the PRI's and optional actor are used.
*/
event BroadcastLocalized( actor Sender, class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	BroadcastHandler.AllowBroadcastLocalized(Sender,Message,Switch,RelatedPRI_1,RelatedPRI_2,OptionalObject);
}

//==========================================================================
	
function bool CheckEndGame(PlayerReplicationInfo Winner, string Reason)
{
	local Controller P;

	// all player cameras focus on winner or final scene (picked by gamerules)
	for ( P=Level.ControllerList; P!=None; P=P.NextController )
	{
		P.ClientGameEnded();
		P.GotoState('GameEnded');
	}	
	return true;
}

/* End of game.
*/
function EndGame( PlayerReplicationInfo Winner, string Reason )
{
	// don't end game if not really ready
	if ( !CheckEndGame(Winner, Reason) )
	{
		bOverTime = true;
		return;
	}

	bGameEnded = true;
	TriggerEvent('EndGame', self, None);
	EndLogging(Reason);
}

function EndLogging(string Reason)
{
	if ( StatLog == None )
		return;
	StatLog.LogGameEnd(Reason);
	StatLog.StopLog();
	StatLog.Destroy();
	StatLog = None;
}

/* Return the 'best' player start for this player to start from.
 */
function NavigationPoint FindPlayerStart( Controller Player, optional byte InTeam, optional string incomingName )
{
	local NavigationPoint N, BestStart;
	local Teleporter Tel;
	local float BestRating, NewRating;

	// always pick StartSpot at start of match
	if ( (Player != None) && (Player.StartSpot != None)
		&& (bWaitingToStartMatch || ((Player.PlayerReplicationInfo != None) && Player.PlayerReplicationInfo.bWaitingPlayer))  )
	{
		return Player.StartSpot;
	}

	// if incoming start is specified, then just use it
	if( incomingName!="" )
		foreach AllActors( class 'Teleporter', Tel )
			if( string(Tel.Tag)~=incomingName )
				return Tel;

	for ( N=Level.NavigationPointList; N!=None; N=N.NextNavigationPoint )
	{
		NewRating = RatePlayerStart(N,InTeam,Player);
		if ( NewRating > BestRating )
		{
			BestRating = NewRating;
			BestStart = N;
		}
	}
	
	if ( BestStart == None )
	{
		log("Warning - PATHS NOT DEFINED or NO PLAYERSTART");			
		foreach AllActors( class 'NavigationPoint', N )
		{
			NewRating = RatePlayerStart(N,0,Player);
			if ( NewRating > BestRating )
			{
				BestRating = NewRating;
				BestStart = N;	
			}
		}
	}

	return BestStart;
}

/* Rate whether player should choose this NavigationPoint as its start
default implementation is for single player game
*/
function float RatePlayerStart(NavigationPoint N, byte Team, Controller Player)
{
	local PlayerStart P;

	P = PlayerStart(N);
	if ( P != None )
	{
		if ( P.bSinglePlayerStart )
		{
			if ( P.bEnabled )
				return 1000;
			return 20;
		}
		return 10;
	}
	return 0;
}

function bool TooManyBots()
{
	return false;
}

function INT MPSelectOperativeFace(bool bIsFemale)
{
	return -1;
}

// weather we should be compiling the stats for in game stats page
function SetCompilingStats(BOOL bStatsSetting)
{
    m_bCompilingStats = bStatsSetting;
}

function SetRoundRestartedByJoinFlag(BOOL bRestartableByJoin)
{
    GameReplicationInfo.m_bRestartableByJoin = bRestartableByJoin;
}

//R6CODE+
//R6CODE-

defaultproperties
{
     Difficulty=3
     MaxSpectators=2
     MaxPlayers=16
     bRestartLevel=True
     bPauseable=True
     bCanChangeSkin=True
     bCanViewOthers=True
     bWaitingToStartMatch=True
     bLocalLog=True
     bWorldLog=True
     m_bCompilingStats=True
     GameSpeed=1.000000
     DeathMessageClass=Class'Engine.LocalMessage'
     GameMessageClass=Class'Engine.GameMessage'
     GameReplicationInfoClass=Class'Engine.GameReplicationInfo'
     StatLogClass=Class'Engine.StatLogFile'
     HUDType="Engine.HUD"
     DefaultPlayerName="Player"
     GameName="Game"
     AccessControlClass="Engine.AccessControl"
     BroadcastHandlerClass="R6Game.R6BroadcastHandler"
     PlayerControllerClassName="Engine.PlayerController"
     m_szGameTypeFlag="RGM_AllMode"
}
