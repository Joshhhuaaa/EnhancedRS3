//=============================================================================
//  R6CheatManager.uc : Cheat manager for R6
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/24 * Created by Guillaume Borgia
//=============================================================================

class R6CheatManager extends CheatManager;

var BOOL m_bRenderGunDirection;
var BOOL m_bRenderViewDirection;
var BOOL m_bRenderBoneCorpse;
var BOOL m_bRenderFOV;
var BOOL m_bRenderRoute;
var BOOL m_bRenderNavPoint;
var BOOL m_bToggleHostageLog;
var BOOL m_bToggleHostageThreat;
var BOOL m_bHostageTestAnim;
var BOOL m_bToggleTerroLog;
var BOOL m_bRendSpot;
var BOOL m_bRendPawnState;
var BOOL m_bRendFocus;
var BOOL m_bToggleRainbowLog;
var BOOL m_bPlayerInvisble;
var BOOL m_bHideAll;
var BOOL m_bTogglePeek;
var BOOL m_bTogglePGDebug;
var BOOL m_bToggleThreatInfo;
var BOOL m_bToggleGameInfo;
var BOOL m_bToggleMissionLog;
var BOOL m_bFirstPersonPlayerView;
var BOOL m_bTeamGodMode;
var BOOL m_bSkipTick;

var INT  m_iHostageTestAnimIndex;
var INT  m_iGameInfoLevel;

var INT  m_iCounterLog;
var INT  m_iCounterLogMax;
var BOOL m_bNumberLog;

// navigation debug system
var BOOL                    m_bEnableNavDebug; 
var INT                     m_iCurNavPoint;
var FLOAT                   m_fNavPointDistance;
const                       c_iNavPointIndex = 10;
var array<vector>           m_aNavPointLocation;


var R6Pawn      m_curPawn;
var R6Hostage   m_hostage;

struct CommandInfo
{
    var name    m_functionName; // name used for quick string comparison
    var string  m_szDescription;
};


var CommandInfo m_aCommandInfo[128];
var INT         m_iCommandInfoIndex;


//------------------------------------------------------------------
// help: list all registered function
//------------------------------------------------------------------
exec function help()
{
    local INT i;
    local string sz;
    local INT iSize;
    local string szDot;

    if ( m_iCommandInfoIndex == 0 )
    {
        AddCommandInfo( ' ',          "-- on/off function ------" );
        AddCommandInfo( 'BoneCorpse',           "diplay bone of Ragdoll" );
        AddCommandInfo( 'GunDirection',         "diplay GunDirection of all pawn" );
        AddCommandInfo( 'HideAll',              "hide all interface (HUD, weapon, reticule)" );
        AddCommandInfo( 'Route',                "diplay RouteCache of all controller" );
        AddCommandInfo( 'NavPoint',             "diplay NavPoint" );
        AddCommandInfo( 'RouteAll',             "diplay all path nodes (float max distance to player)" );
        AddCommandInfo( 'ToggleNav',            "toggle the Navigation Point Debug System" );
        AddCommandInfo( 'ToggleRadius',         "diplay collision cylinder" );
        AddCommandInfo( 'ShowFOV',              "diplay field of view of all pawn" );
        AddCommandInfo( 'dbgPeek',              "debug peek system" );
        AddCommandInfo( 'RendPawnState',        "display current sate of pawn" );
        AddCommandInfo( 'RendFocus',            "toggle display of focus and focal point" );
        AddCommandInfo( 'God',                  "make you invincible" );
        AddCommandInfo( 'GodAll',               "it call godTeam and GodHostage" );
        AddCommandInfo( 'GodTeam',              "make you and your team invisible" );
        AddCommandInfo( 'GodHostage',           "make all hostage invisible" );
        AddCommandInfo( 'GodTerro',             "make all terro invisible" );
        
        AddCommandInfo( 'ToggleUnlimitedPractice', "mission objectives are updated but the game never ends" );
        

        AddCommandInfo( ' ',          "----server-------------------" );
        AddCommandInfo( 'SetRoundTime',         "set the current time left for this round in X sec" );
        AddCommandInfo( 'SetBetTime',           "set the bet time in X sec" );

        AddCommandInfo( ' ',          "-------------------------" );
        AddCommandInfo( 'dbgActor',             "all actor debug dump" );
        AddCommandInfo( 'dbgRainbow',           "all rainbow debug dump" );
        AddCommandInfo( 'dgbWeapon',            "current weapon debug info");
        AddCommandInfo( 'dbgThis',              "debug ouput this actor (pointed by the gun) (false = TraceActor,  true = TraceWorld)" );
        AddCommandInfo( 'dbgEdit',              "edit this actor (pointed by the gun)" );
        AddCommandInfo( 'SetPawn',              "set the current pawn" );
        AddCommandInfo( 'SetPawnPace',          ""$SetPawnPace( 0, true ) );
        AddCommandInfo( 'UsePath',              "current pawn will walk/run away from the player (int 1=run)" );
        AddCommandInfo( 'SetPState',            "set the selected pawn's state" );
        AddCommandInfo( 'SetCState',            "set the selected controller's state" );
        AddCommandInfo( 'SeeCurPawn',           "check if it can see the current pawn" );
        AddCommandInfo( 'CanWalk',              "curPawn: test CanWalkTo to player" );
        AddCommandInfo( 'TestFindPathToMe',     "curPawn: test findPathTo and findPathToward" );
        AddCommandInfo( 'KillThemAll',          "Kill all non-player pawn" );
        AddCommandInfo( 'KillTerro',            "Kill all terrorist" );
        AddCommandInfo( 'KillHostage',          "Kill all hostage" );
        AddCommandInfo( 'KillRainbow',          "Kill all rainbow" );
        AddCommandInfo( 'Suicide',              "Commit a gentle suicide" );
        AddCommandInfo( 'ToggleCollision',      "toggle pawn collision" );
        AddCommandInfo( 'TestGetFrame',         "test if the skeletal of all pawn have been updated" );
        AddCommandInfo( 'CheckFrienship',       "check isEnemy, isFriend and isNeutral" );
        AddCommandInfo( 'LogFriendship',        "list all frienship relation with all pawns (option: bCheckIfAlive)" );
        AddCommandInfo( 'LogFriendlyFire',      "list all friendly fire bool" );
        AddCommandInfo( 'ShowGameInfo',         "Show game mode info (0=debug, 1=Menu 2=Menu with failures msg)" );
        AddCommandInfo( 'LogPawn',              "LogPawn on the client and on the server" );
        AddCommandInfo( 'LogThis',              "Log pointed actor on the client and on the server" );
        AddCommandInfo( 'ListEscort',           "List escorted hostage" );
        AddCommandInfo( 'GetNbTerro',           "number of terro" );
        AddCommandInfo( 'GetNbRainbow',         "number of rainbow" );
        AddCommandInfo( 'GetNbHostage',         "number of hostage" );

        
        AddCommandInfo( ' ',         "-- hostage --------------" );
        AddCommandInfo( 'hHelp',                "display AI Hostage / Civilian debugger" );
        AddCommandInfo( 'dbgHostage',           "debug hostage" );
        AddCommandInfo( 'ToggleHostageLog',     "toggle hostage log of AI and PAWN" );
        AddCommandInfo( 'ToggleHostageThreat',  "toggle hostage threat detection" );
        AddCommandInfo( 'MoveEscort',           "order the escort to move there" );
        AddCommandInfo( 'SetHPos',              "set the hostage position: 0=Stand, 1=Kneel, 2=Prone, 3=Foetus, 4=Crouch, 5=Random" );
        AddCommandInfo( 'SetHRoll',             "set the hostage reaction roll (0 to disable)" );
        AddCommandInfo( 'resetThreat',          "reset threat" );
        AddCommandInfo( 'toggleThreatInfo',     "show Threat info" );
        AddCommandInfo( 'regroupHostages',      "tell hostages to regroup on me" );
        

        AddCommandInfo( ' ',         "-- hostage anim player --" );
        AddCommandInfo( 'HLA',                  "Hostage LIST anim" );
        AddCommandInfo( 'HSA',                  "Hostage SET anim Index (int index) " );
        AddCommandInfo( 'HP',                   "Hostage PLAY anim (0: no loop, 1: loop)" );
        AddCommandInfo( 'HNA',                  "Hostage NEXT anim " );
        AddCommandInfo( 'HPA',                  "Hostage PREVIOUS anim " );
        
        AddCommandInfo( ' ',         "-- terrorist-------------" );
        AddCommandInfo( 'CallTerro',            "Call terro of a group to the location of the player" );
        AddCommandInfo( 'dbgTerro',             "all terro debug dump" );
        AddCommandInfo( 'PlayerInvisible',      "toggle Player detection by terrorists" );
        AddCommandInfo( 'tNoThreat',            "set all terrorist back to no threat state" );
        AddCommandInfo( 'tSurrender',           "toggle display of action spot" );
        AddCommandInfo( 'tRunAway',             "toggle display of action spot" );
        AddCommandInfo( 'tSprayFire',           "toggle display of action spot" );
        AddCommandInfo( 'tAimedFire',           "toggle display of action spot" );
        AddCommandInfo( 'ToggleTerroLog',       "toggle terroriste log of AI and PAWN" );
        AddCommandInfo( 'RendSpot',             "toggle display of action spot" );

        AddCommandInfo( ' ',         "-- Weapon offset---------" );
        AddCommandInfo( 'WOX',       "Add the parameter to the X weapon Offset (move weapon +forward or -backward)");
        AddCommandInfo( 'WOY',       "Add the parameter to the Y weapon Offset (move weapon -right or +left");
        AddCommandInfo( 'WOZ',       "Add the parameter to the X weapon Offset (Move weapon +up or -Down");
        AddCommandInfo( 'ShowWO',    "Display the current weapon offset in the log");

        AddCommandInfo( ' ',         "-- misc -----------------" );
        AddCommandInfo( 'SetShake',             "Activate the camera shake when shooting 1 is true and 0 is false");
        AddCommandInfo( 'DesignJF',             "Weapon jump factor 0 is no jump, 0.5 is half 2 is twice");
        AddCommandInfo( 'DesignSF',             "Weapon return speed factor 0 is no return speed, 0.5 is half 2 is twice");
        AddCommandInfo( 'ForceKillResult',      "Force kill to 1=none 2=wounded 3=incapacited 4=kill and 0 is normal");
        AddCommandInfo( 'ForceStunResult',      "Force stun to 1=none 2=stuned 3=Dazed 4=Knocked out and 0 is normal");
        AddCommandInfo( 'BulletSpeed',          "Set the bullet speed for current weapon (cm/s), < 5000 is really slow and > 50000 is to fast");
        AddCommandInfo( 'HandDown',             "Put left hand down");
        AddCommandInfo( 'HandUp',               "Put left hand up");
        AddCommandInfo( 'HideWeapon',           "Hide the weapon in First Person View");
        AddCommandInfo( 'ShowWeapon',           "Show the weapon in First Person View");
        AddCommandInfo( 'ToggleHitLog',         "turn on/off Show all bullet Hit Logs");
        AddCommandInfo( 'logActReset',          "Log Actors reset");
        AddCommandInfo( 'logAct',               "Log Actors(nb to log)");
        AddCommandInfo( 'SetBombTimer',         "Set bomb timer: X sec");
        AddCommandInfo( 'SetBombInfo',          "info: fExpRadius, fKillRadius, iEnergy" );
        AddCommandInfo( 'GetBombInfo',          "get info" );
        AddCommandInfo( 'testBomb',             "test bomb: god, objective off.. arm bomb and set time to 5 sec" );
        
        AddCommandInfo( ' ',         "-- mission objective -----------------" );
        AddCommandInfo( 'ToggleMissionLog',     "Toggle Mission Objective Mgr log" );
        AddCommandInfo( 'NeutralizeTerro',      "Neutralize all terrorist in the level");
        AddCommandInfo( 'DisarmBombs',          "Disarms all the bombs on the level");
        AddCommandInfo( 'DeactivateIODevice',   "Deactivate IODevice like phone, laptop (ie: plant a bug)");   
        AddCommandInfo( 'RescueHostage',        "Rescue all hostages" );
        AddCommandInfo( 'DisableMorality',      "Disable morality rules" );
        AddCommandInfo( 'ToggleObjectiveMgr',   "Toggle mission objective mgr (the mission will not fail or complete)" );
        AddCommandInfo( 'CompleteMission',      "Complete the mission" );
        AddCommandInfo( 'AbortMission',         "Abort the mission" );
        
        //last one
        AddCommandInfo( '', "" ); 
    }
 
    log( "  -- List all registered function ---------------" );

    // find the longest function name
    i = 0;
    while ( m_aCommandInfo[i].m_functionName != '' || m_aCommandInfo[i].m_szDescription != "" )
    {
        sz = "" $m_aCommandInfo[i].m_functionName;
        if ( len( sz ) > iSize )
        {
            iSize = len( sz );
        }
        i++;
    }

    i = 0;
    szDot = ".................................";
    while ( m_aCommandInfo[i].m_functionName != '' || m_aCommandInfo[i].m_szDescription != "" )
    {
        sz = "" $m_aCommandInfo[i].m_functionName;
        if ( m_aCommandInfo[i].m_functionName == ' ' )
        {
            log( m_aCommandInfo[i].m_szDescription );
        }
        else
        {
            log( "" $sz$ "" $Left(szDot, iSize - Len(sz) )$ "..: " $m_aCommandInfo[i].m_szDescription );
        }   
        i++;
    }
    
}

//------------------------------------------------------------------
// AddCommandInfo
//	
//------------------------------------------------------------------
function AddCommandInfo( name functionName, string szDescription )
{
    local INT i;
    assert( m_iCommandInfoIndex < ArrayCount( m_aCommandInfo ) ); // increase the value of m_aCommandInfo

    m_aCommandInfo[ m_iCommandInfoIndex ].m_szDescription    = szDescription;
    m_aCommandInfo[ m_iCommandInfoIndex ].m_functionName     = functionName;
    m_iCommandInfoIndex++;
}

//============================================================================
// On off function begin --
exec function PhyStat()
{
    if ( !CanExec() ) return;

    ConsoleCommand("R6STATS TIMERS PHYSICS");
}

exec function ToggleRadius()
{
    if ( !CanExec() ) return;

    ConsoleCommand("ToggleRadius");   
}

exec function BoneCorpse()
{
    if ( !CanExec() ) return;

    m_bRenderBoneCorpse = !m_bRenderBoneCorpse;
    Player.Console.Message( "BoneCorpse = " $ m_bRenderBoneCorpse, 6.0 );
}

exec function GunDirection()
{
    if ( !CanExec() ) return;

    m_bRenderGunDirection = !m_bRenderGunDirection;
    Player.Console.Message( "GunDirection = " $ m_bRenderGunDirection, 6.0 );
}

exec function ViewDirection()
{
    if ( !CanExec() ) return;

    m_bRenderViewDirection = !m_bRenderViewDirection;
    Player.Console.Message( "GunDirection = " $ m_bRenderViewDirection, 6.0 );
}

exec function Route()
{
    if ( !CanExec() ) return;

    m_bRenderRoute = !m_bRenderRoute;
    Player.Console.Message( "Draw route = " $ m_bRenderRoute, 6.0 );
}

exec function NavPoint()
{
    if ( !CanExec() ) return;

    m_bRenderNavPoint = !m_bRenderNavPoint;
    Player.Console.Message( "Draw nav point = " $ m_bRenderNavPoint, 6.0 );
}

exec function RouteAll( OPTIONAL float fDistance )
{
    if ( !CanExec() ) return;

    if ( fDistance != 0 )
        Level.m_fDbgNavPointDistance = fDistance;

    ConsoleCommand("rend paths"); 
    Player.Console.Message( "RouteAll: " $Level.m_fDbgNavPointDistance$ " units", 6 );
}

exec function ShowFOV()
{
	local R6Pawn p;

    if ( !CanExec() ) return;

	if(m_bRenderFOV)
	{
		// detach FOV cones
		foreach AllActors( class 'R6Pawn', p )
        {
			if(!p.m_bIsPlayer && (p.m_FOV != none))
			{
				p.DetachFromBone(p.m_FOV);
				p.m_FOV.Destroy();
				p.m_FOV = none;
			}
		}
	}
	else
	{
		// attach FOV cones
		foreach AllActors( class 'R6Pawn', p )
        {
			if(!p.m_bIsPlayer && p.IsAlive())
			{
				p.m_FOV = Spawn(p.m_FOVClass);
				p.AttachToBone(p.m_FOV, 'R6 PonyTail2');
			}
		}
	}
	m_bRenderFOV = !m_bRenderFOV;
    Player.Console.Message( "ShowFOV = " $ m_bRenderFOV, 6.0 );
}


//------------------------------------------------------------------
// ToggleUnlimitedPractice
//	
//------------------------------------------------------------------
exec function ToggleUnlimitedPractice()
{
    local R6AbstractGameInfo gameInfo;

    if ( !CanExec() ) return;
    
    gameInfo = R6AbstractGameInfo(Level.Game);
    gameInfo.SetUnlimitedPractice( !gameInfo.IsUnlimitedPractice(), true );
}

exec function God()
{
    if ( !CanExec() ) return;

    if ( R6Pawn(pawn) == none )
        return;
    
    bGodMode = !bGodMode;
    R6Pawn(pawn).ServerGod( bGodMode, false, false, PlayerReplicationInfo.PlayerName, false );
    Player.Console.Message( "God " $bGodMode, 6.0 );
}

exec function GodTeam()
{
    if ( !CanExec() ) return;

    if(bOnlySpectator)
	{
		if(viewTarget.IsA('R6Pawn'))
		{		
		    m_bTeamGodMode = !m_bTeamGodMode;
			bGodMode = m_bTeamGodMode;
			R6Pawn(viewTarget).ServerGod( m_bTeamGodMode, true, false, PlayerReplicationInfo.PlayerName, false );
			Player.Console.Message( "GodTeam " $bGodMode, 6.0 );
		}
	}
	else
	{
		if(R6Pawn(pawn) == none)
			return;
	
		m_bTeamGodMode = !m_bTeamGodMode;
		R6Pawn(pawn).ServerGod( m_bTeamGodMode, true, false, PlayerReplicationInfo.PlayerName, false );
		Player.Console.Message( "GodTeam " $bGodMode, 6.0 );
	}
}

exec function GodTerro()
{
    if ( !CanExec() ) return;

    if ( R6Pawn(pawn) == none )
        return;
    
    R6Pawn(pawn).ServerGod( false, false, false, PlayerReplicationInfo.PlayerName, true);
    Player.Console.Message( "GodTerro", 6.0 );
}

exec function GodHostage()
{
    if ( !CanExec() ) return;

    if ( R6Pawn(pawn) == none )
        return;
    
    R6Pawn(pawn).ServerGod( false, false, true, PlayerReplicationInfo.PlayerName, false );
    Player.Console.Message( "GodHostage", 6.0 );
}

exec function GodAll()
{
    if ( !CanExec() ) return;

    GodTeam();
    GodHostage();
}

exec function PerfectAim()
{
    if ( !CanExec() ) return;

    Pawn.EngineWeapon.PerfectAim();
}

// kills only all the terrorists and none of your team members
exec function NeutralizeTerro()
{
    local R6Terrorist t;
    local int i;

    if ( !CanExec() ) return;

	foreach AllActors( class 'R6Terrorist', t )
    {
        t.ServerForceKillResult(4);
        t.R6TakeDamage( 1000, 1000, t, t.Location, vect(0,0,0), 0 );
	}
    Player.Console.Message( "Neutralized terro = " $i, 6.0 );
}

// disarms all the bombs on the level
exec function DisarmBombs()
{
    local R6IOBomb bomb;
    local int i;

    if ( !CanExec() ) return;

	foreach AllActors( class 'R6IOBomb', bomb )
    {
          bomb.DisarmBomb( R6Pawn( pawn ) );
          i++;
    }
    Player.Console.Message( "Bomb disarmed = " $i, 6.0 );    
}


// plant a bug
exec function DeactivateIODevice()
{
    local R6IODevice device;
    local int i;

    if ( !CanExec() ) return;

	foreach AllActors( class 'R6IODevice', device )
    {
        device.ToggleDevice( R6Pawn( pawn ) );
        i++;
    }
    Player.Console.Message( "Deactivated IODevice = " $i, 6.0 );    
}

exec function ToggleObjectiveMgr()
{
    local R6MissionObjectiveMgr moMgr;

    if ( !CanExec() ) return;

    moMgr = R6AbstractGameInfo(Level.Game).m_missionMgr;
    
    moMgr.m_bDontUpdateMgr = !moMgr.m_bDontUpdateMgr;
    Player.Console.Message( "Dont update mission objective manager = " $moMgr.m_bDontUpdateMgr, 6.0 );    

    if ( !moMgr.m_bDontUpdateMgr ) // if turned off, check if the game ends
    {
        if( Level.Game.CheckEndGame( none, "") )
	        Level.Game.EndGame(none , "");
    }
}


exec function RescueHostage()
{
    local R6Hostage     h;
    
    if ( !CanExec() ) return;

    foreach AllActors( class'R6Hostage', h )
    {
        if ( h.m_controller != none )
        {
            h.m_controller.SetStateExtracted();
            R6AbstractGameInfo(Level.Game).EnteredExtractionZone(h);
        }
    }

    log( "All hostages has been rescued" );

}

exec function DisableMorality()
{
    local R6MissionObjectiveMgr moMgr;
    local int i;
    
    if ( !CanExec() ) return;

    moMgr = R6AbstractGameInfo(Level.Game).m_missionMgr;
    
    while ( i < moMgr.m_aMissionObjectives.Length )
    {
        if ( moMgr.m_aMissionObjectives[i].m_bMoralityObjective )
        {
            moMgr.m_aMissionObjectives.Remove(i,1);
        }
        else
        {
            ++i;
        }
    }

    Player.Console.Message( "Morality rules removed", 6.0 );    
}

function DoCompleteMission()
{
    local R6MissionObjectiveMgr moMgr;
    
    if ( !CanExec() ) return;

    R6AbstractGameInfo(Level.Game).CompleteMission();
    Player.Console.Message( "CompleteMission", 6.0 );
}

function DoAbortMission()
{
    local R6MissionObjectiveMgr moMgr;
    
    if ( !CanExec() ) return;

    R6AbstractGameInfo(Level.Game).AbortMission();
    Player.Console.Message( "AbortMission", 6.0 );
}


exec function KillTerro()
{
    if ( !CanExec() ) return;

    KillAllPawns(class'R6Terrorist');
}

exec function KillHostage()
{
    if ( !CanExec() ) return;

    KillAllPawns(class'R6Hostage');
}

exec function KillRagdoll()
{
    local R6Pawn P;

    if ( !CanExec() ) return;

    ForEach DynamicActors(class'R6Pawn', P)
    {
	    if ( P.Physics == PHYS_KarmaRagDoll )
	    {
		    if ( P.Controller != None )
			    P.Controller.Destroy();

		    P.Destroy();
	    }
    }
}

function KillRainbowTeam()
{
    local R6RainbowTeam team;
	local int i;
    local bool bHuman;
    
    foreach AllActors( class 'R6RainbowTeam', team )
    {
        bHuman = false;
        for ( i = 0; i < team.m_iMemberCount; i++ )
        {
            if ( !team.m_Team[i].m_bIsPlayer )
            {
                team.m_Team[0] = team.m_Team[i];
                team.m_iMemberCount = 1;
                bHuman = true;
                break;
            }
            else
            {
                team.m_Team[i] = none;
            }
        }
        
        if ( !bHuman )
        {
            team.m_iMemberCount = 0;
        }
	}
}

exec function KillRainbow()
{
    if ( !CanExec() ) return;

    KillRainbowTeam();
    KillAllPawns(class'R6Rainbow');
    
}

exec function KillPawns()
{
    // R6CODE+
    if ( !CanExec() ) return;

    KillRainbowTeam();
	KillAllPawns(class'Pawn');
}

exec function PlayerInvisible()
{
    // canExec is on done on the server

    m_bPlayerInvisble = !m_bPlayerInvisble;
    R6PlayerController(Pawn.Controller).ServerPlayerInvisible( m_bPlayerInvisble );
}

function DoPlayerInvisible( bool bInvisible )
{
    local R6Terrorist t;

	foreach AllActors( class 'R6Terrorist', t )
    {
        t.m_bDontHearPlayer  = bInvisible;
        t.m_bDontSeePlayer   = bInvisible;
	}
    Player.Console.Message( "PlayerInvisible = " $ bInvisible, 6.0 );
}


exec function GiveMag(INT iNbOfExtraClips)
{
	local INT iWeaponIndex;

    if ( !CanExec() ) return;

    //if this check is by-passed, the server will still know the correct number of bullets
    if (Level.NetMode!= NM_Standalone)
    {
        return;
    }

	for (iWeaponIndex = 0; iWeaponIndex < 4; iWeaponIndex++)
	{
		Pawn.m_WeaponsCarried[iWeaponIndex].AddClips(iNbOfExtraClips);
	}
}


exec function HideAll()
{
    if(m_bHideAll)
    {
        m_bHideAll=false;
        R6AbstractHUD(PlayerController(Pawn.Controller).myHUD).m_iCycleHUDLayer = 0;
    }
    else
    {
        m_bHideAll=true;
        R6AbstractHUD(PlayerController(Pawn.Controller).myHUD).m_iCycleHUDLayer = 3;
    }

    R6PlayerController(Pawn.Controller).m_bUseFirstPersonWeapon = !m_bHideAll;
    R6AbstractHUD(PlayerController(Pawn.Controller).myHUD).m_bToggleHelmet = !m_bHideAll;
    R6PlayerController(Pawn.Controller).m_bHideReticule = m_bHideAll;

    //Player.Console.Message( "HideAll = " $ m_bHideAll, 3.0 );
}

exec function ToggleReticule()
{
    if ( !CanExec() ) return;

    R6PlayerController(Pawn.Controller).m_bHideReticule = !R6PlayerController(Pawn.Controller).m_bHideReticule;
}

// -- On/Off function end
//============================================================================

//============================================================================
// function tNoThreat - 
//============================================================================
exec function tNoThreat()
{
    local R6TerroristAI t;

    if ( !CanExec() ) return;

    foreach AllActors( class 'R6TerroristAI', t )
        t.GotoStateNoThreat();

    Player.Console.Message( "Terrorist going back to no threat state", 6.0 );
}

//============================================================================
// function tSurrender - 
//============================================================================
exec function tSurrender()
{
    local R6TerroristAI t;

    if ( !CanExec() ) return;

	foreach AllActors( class 'R6TerroristAI', t )
        t.m_eEngageReaction = EREACT_Surrender;

    Player.Console.Message( "All terrorists will surrender", 6.0 );
}

//============================================================================
// function tRunAway - 
//============================================================================
exec function tRunAway()
{
    local R6TerroristAI t;

    if ( !CanExec() ) return;

	foreach AllActors( class 'R6TerroristAI', t )
        t.m_eEngageReaction = EREACT_RunAway;

    Player.Console.Message( "All terrorists will run away", 6.0 );
}

//============================================================================
// function tSpeed
//============================================================================
exec function tSpeed( FLOAT fSpeed )
{
    local R6Terrorist t;

    if ( !CanExec() ) return;

	foreach AllActors( class 'R6Terrorist', t )
        t.m_fWalkingSpeed = fSpeed;

    Player.Console.Message( "All terrorists walk at " $ fSpeed, 6.0 );
}

//============================================================================
// function tSprayFire - 
//============================================================================
exec function tSprayFire()
{
    local R6TerroristAI t;

    if ( !CanExec() ) return;

	foreach AllActors( class 'R6TerroristAI', t )
        t.m_eEngageReaction = EREACT_SprayFire;

    Player.Console.Message( "All terrorists will spray fire", 6.0 );
}

//============================================================================
// function tAimedFire - 
//============================================================================
exec function tAimedFire()
{
    local R6TerroristAI t;

    if ( !CanExec() ) return;

	foreach AllActors( class 'R6TerroristAI', t )
        t.m_eEngageReaction = EREACT_AimedFire;

    Player.Console.Message( "All terrorists will aim fire", 6.0 );
}

//============================================================================
// function tTick - 
//============================================================================
exec function tTick( INT iTickFrequency )
{
    local R6Terrorist t;

    if ( !CanExec() ) return;

	foreach AllActors( class 'R6Terrorist', t )
    {
        t.m_wTickFrequency = iTickFrequency;
        t.m_wNbTickSkipped = RandRange(0, iTickFrequency);
    }

    Player.Console.Message( "Terrorists tick frequency " $ iTickFrequency, 6.0 );
}

//============================================================================
// function ActorTick - 
//============================================================================
exec function ActorTick( INT iTickFrequency )
{
    local Actor a;

    if ( !CanExec() ) return;

    m_bSkipTick = !m_bSkipTick;

	foreach AllActors( class 'Actor', a )
    {
        if(!m_bSkipTick)
        {
            a.m_bSkipTick = false;
            a.m_bTickOnlyWhenVisible = false;
        }
        else
        {
            a.m_bSkipTick = a.default.m_bSkipTick;
            a.m_bTickOnlyWhenVisible = a.default.m_bTickOnlyWhenVisible;
        }
    }

    Player.Console.Message( "Actor m_bSkipTick: " $ m_bSkipTick, 6.0 );
}

//============================================================================
// function ToggleHitLog - 
//============================================================================
exec function ToggleHitLog()
{
    if ( !CanExec() ) return;

    R6PlayerController(Pawn.Controller).m_bShowHitLogs = !R6PlayerController(Pawn.Controller).m_bShowHitLogs;
}

//============================================================================
// function CallTerro - 
//============================================================================
exec function CallTerro( OPTIONAL INT iGroup )
{
    local R6TerroristAI ai;

    if ( !CanExec() ) return;

    ForEach AllActors(class'R6TerroristAI', ai)
    {
        if(ai.m_pawn.m_iGroupID == iGroup)
        {
            log("Calling terrorist " $ ai.m_pawn $ " to " $ Pawn.Location );
            ai.GotoPointAndSearch(Pawn.Location, PACE_Run, false);
        }
    }
}

//============================================================================
// function UseKarma - 
//============================================================================
exec function UseKarma()
{
    local R6Pawn p;

    if ( !CanExec() ) return;

	foreach AllActors( class 'R6Pawn', p )
    {
        p.m_bUseKarmaRagdoll = !p.m_bUseKarmaRagdoll;
	}
    Player.Console.Message( "Toggled karma use", 6.0 );
}

//============================================================================
// function AutoSelect - select a team by default in the gameoptions
//============================================================================
exec function AutoSelect( string _szSelection)
{
    if ( !CanExec() ) return;

	class'Actor'.static.GetGameOptions().MPAutoSelection = _szSelection;
}

exec function ToggleWalk()
{
    if ( !CanExec() ) return;

    if((pawn == none) || (pawn.controller == none))
		return;

   if ( !CanExec() ) return;

	// set focus back to player pawn
	Walk();	

	if(m_bFirstPersonPlayerView)
		R6PlayerController(Pawn.Controller).Behindview(true);

	m_bFirstPersonPlayerView = !m_bFirstPersonPlayerView;
}

//============================================================================
// PostRender - 
//============================================================================
event PostRender( canvas Canvas )
{
    local R6Pawn p;
    local R6AbstractCorpse corpse;
    local R6AIController c;
    local NavigationPoint np;
    local R6ActionSpot as;
    local Vector vTemp;
    local Controller aController;

    //local R6IORotatingDoor door;
    //foreach AllActors(class 'R6IORotatingDoor', door)
	//{
	//    canvas.Draw3DLine( door.m_vCenterOfDoor, door.m_vCenterOfDoor + 120 * door.m_vDoorADir2D, class'Canvas'.Static.MakeColor(0,0,255));
	//    canvas.Draw3DLine( door.m_vCenterOfDoor, door.m_vCenterOfDoor - 120 * door.m_vDoorADir2D, class'Canvas'.Static.MakeColor(0,255,0));
    //    DrawText3D( door.Location + vect(0,0,50), door.m_vDoorADir2D );
	//}

    if(m_bRendSpot)
    {
        foreach AllActors( class'R6ActionSpot', as )
        {
            vTemp = as.Location;
            DrawText3D( vTemp, "ActionSpot " $ as.name );
            if(as.m_bInvestigate)
            {
                vTemp.z -= 10;
                DrawText3D( vTemp, "Investigate" );
            }
            if(as.m_eCover!=STAN_None)
            {
                vTemp.z -= 10;
                DrawText3D( vTemp, "Cover" );
            }
            if(as.m_eFire!=STAN_None)
            {
                vTemp.z -= 10;
                DrawText3D( vTemp, "Fire" );
            }
        }
    }

	if(m_bRenderViewDirection || m_bRenderGunDirection || m_bRendPawnState || m_bRendFocus )
	{
		foreach AllActors(class 'R6Pawn', p)
		{
            if(p.LastRenderTime == Level.TimeSeconds && p.IsAlive())
            {
                if(m_bRenderViewDirection)
			        p.DrawViewRotation(Canvas);

                if(m_bRenderGunDirection)
                    p.RenderGunDirection( Canvas );

                if(m_bRendPawnState)
                {
                    vTemp = p.Location;
                    vTemp.Z += 90;
                    DrawText3D( vTemp, p.name );
                    if(p.GetStateName() != p.Class.name)
                    {
                        vTemp.Z -= 15;
                        DrawText3D( vTemp, p.GetStateName() );
                    }
                    if( p.Controller != none)
                    {
                        vTemp.Z -= 15;
                        DrawText3D( vTemp, p.Controller.GetStateName() );
                        if(p.m_ePawnType == PAWN_Terrorist && (p.Controller.IsInState('MovingTo') || p.Controller.IsInState('Attack')) )
                        {
                            vTemp.Z -= 15;
                            DrawText3D( vTemp, R6TerroristAI(p.Controller).m_sDebugString );
                        }
                    }
                }

                if(m_bRendFocus)
                {
                    if(p.Controller.Focus!=none)
                    {
                        canvas.Draw3DLine( p.Controller.Focus.Location, p.Location + p.EyePosition(), class'Canvas'.Static.MakeColor(255,0,0));
                    }
                    canvas.Draw3DLine( p.Controller.FocalPoint, p.Location + p.EyePosition(), class'Canvas'.Static.MakeColor(255,150,150));
                }
            }
		}
	}

    if(m_bRenderBoneCorpse)
    {
        foreach AllActors( class 'R6AbstractCorpse', corpse )
        {
            corpse.RenderCorpseBones( Canvas );
        }
    }

    if(m_bRenderRoute)
    {
        for (aController=Level.ControllerList; aController!=None; aController=aController.NextController )
        {
            if( aController.isA('R6AIController') && R6AiController(aController).m_r6pawn.IsAlive() )
                DrawRoute( R6AiController(aController), Canvas );
        }
    }


    if(m_bRenderNavPoint)
    {
        foreach RadiusActors( class'NavigationPoint', np, 1000, ViewTarget.Location )
            DrawText3D( np.Location, string(np.name) );
    }

    if ( m_bEnableNavDebug )
    {
        processNavDebug( Canvas );
    }

    if ( m_bTogglePeek )
    {
        processDebugPeek( Canvas );
    }

    if ( m_bTogglePGDebug )
    {
        processDebugPG( Canvas );
    }

    if ( m_bToggleThreatInfo )
    {
        processThreatInfo( Canvas );
    }

    if (m_bToggleGameInfo)
    {
        displayGameInfo( Canvas );
    }
/*
	foreach AllActors(class 'R6Pawn', p)
	{
        if( p.m_ePawnType==PAWN_Terrorist && p.LastRenderTime==Level.TimeSeconds && p.IsAlive() )
        {
            vTemp = p.Location;
            vTemp.Z += 90;
            DrawText3D( vTemp, p.Name @ p.GetStateName() );
            vTemp.Z -= 15;
            vTemp.X += 20;
            if(p.Controller.Focus!=none)
                DrawText3D( vTemp, "F:" $ p.Controller.Focus.name $ "@" $ p.Controller.Focus.Location $ " FP: " $ p.Controller.FocalPoint );
            else
                DrawText3D( vTemp, "F:" $ p.Controller.Focus $ " FP: " $ p.Controller.FocalPoint );
            //canvas.Draw3DLine( r6con.RouteCache[i-1].Location, r6con.RouteCache[i].Location, class'Canvas'.Static.MakeColor(255,255,0));
        }
    }
*/
}


//------------------------------------------------------------------
// ToggleHostageThreat
//	
//------------------------------------------------------------------
exec function ToggleHostageThreat()
{
    local R6Hostage     h;
    
    if ( !CanExec() ) return;

    m_bToggleHostageThreat = !m_bToggleHostageThreat;

    foreach AllActors( class'R6Hostage', h )
    {
        R6HostageAI(h.controller).m_bDbgIgnoreThreat = m_bToggleHostageThreat;
    }
}

//------------------------------------------------------------------
// ToggleHostageLog
//	
//------------------------------------------------------------------
exec function ToggleHostageLog()
{
    local R6Hostage     h;
    
    if ( !CanExec() ) return;

    m_bToggleHostageLog = !m_bToggleHostageLog;

    foreach AllActors( class'R6Hostage', h )
    {
        h.bShowLog = m_bToggleHostageLog;
        R6HostageAI(h.controller).bShowLog = m_bToggleHostageLog;
        R6HostageAI(h.controller).m_mgr.bShowLog = m_bToggleHostageLog;
    }

}

//------------------------------------------------------------------
// ToggleTerroLog
//	
//------------------------------------------------------------------
exec function ToggleTerroLog()
{
    local R6Terrorist t;
    
    if ( !CanExec() ) return;

    m_bToggleTerroLog = !m_bToggleTerroLog;

    foreach AllActors( class'R6Terrorist', t )
    {
        t.bShowLog = m_bToggleTerroLog;
        R6TerroristAI(t.controller).bShowLog = m_bToggleTerroLog;
    }
}

//============================================================================
// function RendSpot - 
//============================================================================
exec function RendSpot()
{
    if ( !CanExec() ) return;

    m_bRendSpot = !m_bRendSpot;
    Player.Console.Message( "RendSpot " $ m_bRendSpot, 6.0 );
}

exec function TerroInfo()
{
    if ( !CanExec() ) return;

//    ConsoleCommand( "RendSpot" );
    ConsoleCommand( "RendPawnState" );
    ConsoleCommand( "RendFocus" );

//    ConsoleCommand("PlayerInvisible");
//    ConsoleCommand("God");
    ConsoleCommand("FullAmmo");
//    ConsoleCommand("Rend DebugLine");

//    ConsoleCommand("kdraw collision");
//    ConsoleCommand("kdraw contacts");

//    ConsoleCommand("stat anim");
}

//------------------------------------------------------------------
// ToggleRainbowLog
//	
//------------------------------------------------------------------
exec function ToggleRainbowLog()
{
	local R6Rainbow rainbow;

    if ( !CanExec() ) return;

	m_bToggleRainbowLog = !m_bToggleRainbowLog;
	foreach AllActors(class'R6Rainbow', rainbow)
	{
		//rainbow.bShowLog = m_bToggleRainbowLog;	
		if(!rainbow.m_bIsPlayer)
		{
			R6RainbowAI(rainbow.controller).bShowLog = m_bToggleRainbowLog;
			R6RainbowAI(rainbow.controller).m_TeamManager.bShowLog = m_bToggleRainbowLog;
		}
	}
}

function name GetNameOfActor( Actor aActor )
{
    if ( aActor == none )
    {
        return '';
    }
    else
    {
        return aActor.name;
    }
}

function Actor GetPointedActor( bool bVerboseLog, bool bTraceActor, OPTIONAL OUT vector vReturnHit, OPTIONAL bool bForceTrace )
{
    local Actor     anActor;
    local string    szOutput;
    local string    szController;
    local Vector    vViewDir;
    local Vector    vTraceStart;
    local Vector    vTraceEnd;
    local Vector    vHit;
    local Vector    vHitNormal;


    if ( ViewTarget != Pawn )
    {
        anActor = ViewTarget;
    }
    else
    {
        vViewDir    = vector(R6Pawn(pawn).GetFiringRotation());
        vTraceStart = R6Pawn(pawn).GetFiringStartPoint();
        vTraceStart += (vViewDir*40);
        vTraceEnd   = vTraceStart + 10000 * vViewDir;
    
        anActor = Trace( vHit, vHitNormal, vTraceEnd, vTraceStart, bTraceActor );
    }
   
    if ( anActor != none && Pawn(anActor) != none && Pawn(anActor).controller != none )
    {
        szController = "" $Pawn(anActor).controller.name$ " (" $Pawn(anActor).controller.getStateName()$ ")";
    }
    else
    {
        szController = "none";
    }

    szOutput = "Actor: " $anActor.name$ "  Controller: " $szController$ " class: " $anActor.class;
    log( szOutput );
    
    if ( bVerboseLog )
    {
        Player.Console.Message( "Controller: " $szController, 6.0 );
        Player.Console.Message( "Actor: " $anActor.name$ " (" $anActor.getStateName()$ ")" , 6.0 );
        Player.Console.Message( "Class: " $anActor.class, 6.0 );
    }

    vReturnHit = vHit;

    return anActor;
}

//------------------------------------------------------------------
// logThis
//	do a dbgLogActor on the client and on the server side
//------------------------------------------------------------------
exec event LogThis( OPTIONAL bool bDontTraceActor, OPTIONAL Actor anActor )
{
    if ( !bDontTraceActor || anActor == none )
        anActor = GetPointedActor( true, true );

    R6PlayerController(pawn.controller).DoDbgLogActor( anActor );
}

//------------------------------------------------------------------
// dbg the pointed actor
//	
//------------------------------------------------------------------
exec function dbgThis( OPTIONAL bool bTraceWorld )
{
    local Actor     anActor;

    if ( !CanExec() ) return;

    anActor = GetPointedActor( true, !bTraceWorld );

    if ( R6Hostage( anActor ) != none )
    {
        LogHostage( R6Hostage( anActor ) );
    }
    else if ( R6Terrorist( anActor ) != none )
    {
        LogTerro( R6Terrorist( anActor ) );
    }
    else if ( R6Rainbow( anActor ) != none )
    {
        LogRainbow( R6Rainbow( anActor ) );
    }
    else if ( R6IOBomb( anActor ) != none )
    {
        LogIOBomb( R6IOBomb( anActor ) );
    }
}

exec function dbgEdit( OPTIONAL bool bTraceWorld )
{
    local string    szCmd;
    local Actor     anActor;

    if ( !CanExec() ) return;

    anActor = GetPointedActor( true, !bTraceWorld );

    szCmd = "editactor Actor=" $anActor.name;
    ConsoleCommand( szCmd );
}

function LogR6Pawn( R6Pawn p )
{
    local Controller ai;
    local R6AIController r6ai;
    local R6PlayerController pController;
    local name aiName;
    local string szTemp;

    if ( !CanExec() ) return;

    ai = p.controller;
    if ( ai != none )
        aiName = ai.name;
    
    log( "== " $ p.name $  " ai: " $ aiName $ " ===============" );
    log( "   Location.............: " $ p.Location               );
    log( "   Pawn state...........: " $ p.getStateName()         ); 
    log( "   Coll. Height, Radius.: " $ p.CollisionHeight $ ", " $ p.CollisionRadius );
	Switch(p.Physics)
	{
		case PHYS_None:         szTemp = "None";     break;
		case PHYS_Walking:      szTemp = "Walking";  break;
		case PHYS_Falling:      szTemp = "Falling";  break;
		case PHYS_Rotating:     szTemp = "Rotating"; break;
		case PHYS_Ladder:       szTemp = "Ladder";   break;
        default:                szTemp = "Unknown";  break;
	}
    log( "   Physics..............: " $ szTemp $ " (" $ p.Physics $ ")" );
	Switch(p.m_eMovementPace)
	{
		case PACE_None:         szTemp = "None";      break;
		case PACE_Prone:        szTemp = "Prone";     break;
		case PACE_CrouchWalk:   szTemp = "CrouchWalk";break;
		case PACE_CrouchRun:    szTemp = "CrouchRun"; break;
		case PACE_Walk:         szTemp = "Walk";      break;
		case PACE_Run:          szTemp = "Run";       break;
        default:                szTemp = "Unknown";   break;
	}
    log( "   m_eMovementPace......: " $ szTemp $ " (" $ p.m_eMovementPace $ ")" );
	Switch(p.m_eHealth)
	{
		case HEALTH_Dead:           szTemp = "Dead";    break;
		case HEALTH_Incapacitated:  szTemp = "Incapacitated";     break;
		case HEALTH_Wounded:        szTemp = "Wounded"; break;
		case HEALTH_Healthy:        szTemp = "Healthy"; break;
        default:                    szTemp = "Unknown"; break;
	}
    // The "Left(string(b), 4)" is to strip the E of false to align all the varables on two columns
    log( "   Health...............: " $ szTemp $ " (" $ p.m_eHealth $ ")" );
    log( "   m_bPostureTransition.: " $ p.m_bPostureTransition );
	log( "   bIsWalking...........: " $ Left(string(p.bIsWalking), 4) );
    log( "   IsPeeking............: " $ p.IsPeeking()$ " left: "$p.IsPeekingLeft()$ " rate()= "$p.GetPeekingRate() );
    log( "   bIsCrouched..........: " $ Left(string(p.bIsCrouched), 4)
      $ ",   bWantsToCrouch.......: " $ Left(string(p.bWantsToCrouch), 4) );
    log( "   m_bIsProne...........: " $ Left(string(p.m_bIsProne), 4)
      $ ",   m_bWantsToProne......: " $ Left(string(p.m_bWantsToProne), 4) );
    log( "   m_bIsClimbingStairs..: " $ Left(string(p.m_bIsClimbingStairs), 4)
      $ ",   m_bIsMovingUpStairs..: " $ Left(string(p.m_bIsMovingUpStairs), 4) );
    log( "   m_bAutoClimbLadders..: " $ Left(string(p.m_bAutoClimbLadders), 4)
      $ ",   m_bIsClimbingLadder..: " $ Left(string(p.m_bIsClimbingLadder), 4) );
    log( "   m_bAvoidFacingWalls..: " $ Left(string(p.m_bAvoidFacingWalls), 4)
      $ ",   m_bCanClimbObject....: " $ Left(string(p.m_bCanClimbObject), 4) );
    log( "   m_bUseRagdoll........: " $ p.m_bUseRagdoll $ " (" $ p.m_ragdoll $ ")" );
    log( "   bCanWalkOffLedges....: " $ p.bCanWalkOffLedges );
    log( "   m_bCanDisarmBomb.....: " $ Left(string(p.m_bCanDisarmBomb), 4)
      $ ",   m_bCanArmBomb........: " $ Left(string(p.m_bCanArmBomb), 4) );
    log( "   m_iTeam..............: " $ p.m_iTeam );
    log( "   m_ladder.............: " $ p.m_ladder );

    if ( ai != none )
    {
        log( "   ** ai state..........: " $ ai.getStateName() );
	    Switch(ai.m_eMoveToResult)
	    {
		    case eMoveTo_none:      szTemp = "None";    break;
		    case eMoveTo_success:   szTemp = "Success"; break;
		    case eMoveTo_failed:    szTemp = "Failed";  break;
            default:                szTemp = "Unknown"; break;
	    }
        log( "   m_eMoveToResult......: " $ szTemp $ " (" $ ai.m_eMoveToResult $ ")" );
        log( "   MoveTarget...........: " $ GetNameOfActor( ai.moveTarget ) );
        log( "   Enemy................: " $ GetNameOfActor( ai.enemy ) );
        log( "   bRotateToDesired.....: " $ p.bRotateToDesired );
        log( "   Focus................: " $ GetNameOfActor( ai.focus ) );
        log( "   FocalPoint...........: " $ ai.FocalPoint );
        log( "   m_bCrawl.............: " $ ai.m_bCrawl  );
        log( "   Can reach a navpoint.: " $ ai.FindRandomDest( true ) );
        
        r6ai = R6AIController( p.controller );
        if ( r6ai != none ) // section for r6AIcontroller 
        {
            log( "   m_BumpedBy...........: " $ GetNameOfActor( r6ai.m_BumpedBy ) );
            log( "   m_bIgnoreBackupBump..: " $ r6ai.m_bIgnoreBackupBump );
            log( "   m_climbingObject.....: " $ GetNameOfActor( r6ai.m_climbingObject ) );
            log( "   m_ActorTarget........: " $ r6ai.m_ActorTarget );
        }
    }
    else
    {
        log("    no controller");
    }

    pController = R6PlayerController( p.controller );
    if ( pController != none )
    {
        log( "   ** PlayerController......: " $ pController.getStateName() );
        if (      p.m_ePeekingMode == PEEK_full )
            log( "   Peeking..............: Full "  );
        else if ( p.m_ePeekingMode == PEEK_fluid )
            log( "   Peeking..............: Fluid"  );
        else 
            log( "   Peeking..............: none"  );
            
            log( "   m_bPeekingLeft ......: " $ p.m_bPeekingLeft                );
            log( "   m_fPeeking...........: " $ p.m_fPeeking $ " / " $p.C_fPeekMiddleMax );
            log( "   m_fLastValidPeeking..: " $ p.m_fLastValidPeeking );
            log( "   m_bPeekingToCenter...: " $ p.m_bPeekingReturnToCenter      );
            log( "   m_fCrouchBlendRate...: " $ p.m_fCrouchBlendRate            );
            
    }

}

function LogHostage( R6Hostage h )
{
    local R6HostageAI   ai;
    local INT     i;
    local name    aiName;
    local name    lastSeenPawnName;
    local name    escortName;
    local name    terroristName;
    local vector  vPlayerLoc;
    local bool    bFastTrace;
    local name    animSeq;
	local float   animRate, animFrame;
    
    ai = R6HostageAI(h.controller);        
    
    if ( ai != none )
    {
        aiName = ai.name;

        if ( ai.m_terrorist!= none )
            terroristName = ai.m_terrorist.name;

        if ( ai.m_pawnToFollow != none )
            bFastTrace = FastTrace( ai.m_pawnToFollow.location, h.location );

        if ( ai.m_lastSeenPawn != none )
            lastSeenPawnName = ai.m_lastSeenPawn.name;
    
        if ( ai.m_escort != none )
            escortName = ai.m_escort.name;
    }
    
    if ( pawn != none && pawn.Controller.IsA( 'R6PlayerController' ) )
    {
        vPlayerLoc  = pawn.Location;
    }
    
    LogR6Pawn( h );
    if ( ai != none )
    {
        log( "   UsedTemplate.........: " @h.m_szUsedTemplate );
        log( "   Rainbow (following)..: " @GetNameOfActor( h.m_escortedByRainbow )@ " (" @GetNameOfActor( ai.m_pawnToFollow )@ ")" );
        log( "   ForceToStayHere......: " @ai.m_bForceToStayHere    );
        log( "   Distance from human..: " @VSize( vPlayerLoc - h.location ) );
        log( "   FastTrace............: " @bFastTrace               );
        log( "   RunningToward........: " @ai.m_bRunningToward      );
        log( "   RunToRainbowSuccess..: " @ai.m_bRunToRainbowSuccess );
        log( "   bNeedToRunToCatchUp..: " @ai.m_bNeedToRunToCatchUp );
        log( "   bStopDoTransition....: " @ai.m_bStopDoTransition   );
        log( "   Freed................: " @h.m_bFreed              );        
        log( "   Personality..........: " @h.m_ePersonality         );
        log( "   Position.............: " @h.m_ePosition            );
        log( "   Start as civilian....: " @h.m_bStartAsCivilian     );
        log( "   Hands Up.............: " @h.m_eHandsUpType         );
        log( "   ThreatInfo...........: " @ai.m_mgr.GetThreatInfoLog( ai.m_threatInfo ) );
        log( "   LastSeenPawn.........: " @lastSeenPawnName         );
        log( "   Escorted.............: " @h.m_bEscorted           );
        log( "   Escorted by..........: " @escortName               );
        log( "   Escorted by terro....: " @terroristName            );
        log( "   dbgIgnoreThreat......: " @ai.m_bDbgIgnoreThreat    );
        log( "   m_bSlowedPace........: " @ai.m_bSlowedPace         );
        log( "   m_bFollowIncreaseDist: " @ai.m_bFollowIncreaseDistance );
        log( "   m_bExtracted.........: " @h.m_bExtracted );
        log( "   m_bEscorted..........: " @h.m_bEscorted );
        
        
        
        log( "   Number of orders.....: " @ai.m_iNbOrder            );
        for ( i = 0; i < ai.m_iNbOrder; ++i )
        {
            log( "                          " @ai.Order_GetLog( ai.m_aOrderInfo[i] ) );
        }
    }
}


exec function dbgHostage()
{
    local INT           num;
    local R6Hostage     h;

    if ( !CanExec() ) return;

    log( "-- ALL HOSTAGE DUMP --" );
    foreach AllActors( class'R6Hostage', h )
    {
        LogHostage( h );
        ++num;
    }
    log( "   " @num@ " hostage(s)" );
}

function InitTestHostageAnim()
{
    local R6Hostage                 h;
    
    if ( !m_bHostageTestAnim )
    {
        foreach AllActors( class'R6Hostage', h )
        {
            R6HostageAI(h.controller).GotoState( 'DbgHostage' );
        }
        m_bHostageTestAnim = true;
    }
}

function HostageSetAnimIndex( INT increment )
{
    local R6Hostage     h;
    local R6HostageAI   ai;
    local R6HostageMgr mgr;
    local INT i;
    
    mgr = R6HostageMgr( level.GetHostageMgr() );

    m_iHostageTestAnimIndex += increment;
    if ( m_iHostageTestAnimIndex == mgr.GetAnimInfoSize() )
    {
        log( "TestHostageAnim: index = 0" );
        m_iHostageTestAnimIndex = 0;
    }

    HP();
}


//------------------------------------------------------------------
// Hostage list anim
//	
//------------------------------------------------------------------
exec function HLA()
{
    local R6HostageMgr.AnimInfo     animInfo;
    local R6HostageMgr              mgr;
    local INT                       i;
    
    if ( !CanExec() ) return;

    mgr = R6HostageMgr( level.GetHostageMgr() );

    for ( i = 0; i < mgr.GetAnimInfoSize(); i++ )
    {
        animInfo = mgr.GetAnimInfo( i );
        log( "" $i$ ": " $animInfo.m_name$ " rate: " $animInfo.m_fRate$" play type: "$animInfo.m_ePlayType );
    }
    log( "  total hostage anim: " $mgr.GetAnimInfoSize() );
}

//------------------------------------------------------------------
// hostage Play Anim
//	
//------------------------------------------------------------------
exec function HP( OPTIONAL bool bLoop )   
{
    local R6Hostage                 h;
    local R6HostageAI               ai;
    local R6HostageMgr.AnimInfo     animInfo;
    local bool                      bFound;

    if ( !CanExec() ) return;

    bFound = false;
    InitTestHostageAnim();

    foreach AllActors( class'R6Hostage', h )
    {
        ai = R6HostageAI(h.controller);

        if ( !bFound )
        {
            animInfo = ai.m_mgr.GetAnimInfo( m_iHostageTestAnimIndex );
            log( "play anim: "$animInfo.m_name$" rate: "$animInfo.m_fRate$" play type: "$animInfo.m_ePlayType$" ("$m_iHostageTestAnimIndex$"/"$ai.m_mgr.GetAnimInfoSize()$")" );
            bFound = true;
        }

        h.R6LoopAnim( '', 1 ); 
        if ( bLoop )
        {
            h.R6LoopAnim( animInfo.m_name, animInfo.m_fRate );
        }
        else
        {
            h.r6PlayAnim( animInfo.m_name, animInfo.m_fRate );
        }
    }
}

//------------------------------------------------------------------
// hostage Next Anim
//	
//------------------------------------------------------------------
exec function HNA() 
{
    if ( !CanExec() ) return;

    HostageSetAnimIndex( 1 );
}

//------------------------------------------------------------------
// hostage Previous Anim
//	
//------------------------------------------------------------------
exec function HPA() 
{
    if ( !CanExec() ) return;

    HostageSetAnimIndex( -1 );
}

//------------------------------------------------------------------
// hostage Set Anim ( index )
//	
//------------------------------------------------------------------
exec function HSA( INT index ) 
{
    if ( !CanExec() ) return;

    m_iHostageTestAnimIndex = index;

    HostageSetAnimIndex( 0 );
}

//============================================================================
// function dbgActor - 
//============================================================================
exec function dbgActor()
{
    local Actor         a;
    local INT           num;
    
    if ( !CanExec() ) return;

    log( "-- ALL ACTOR DUMP --" );
    foreach AllActors( class'Actor', a )
    {
        log( a.name $ " current state :  " $ a.getStateName() ); 
        log( "   position....................: " $ a.Location );
        log( "   bCollideActor, bCollideWorld: " $ a.bCollideActors $ ", " $ a.bCollideWorld );
        log( "   bBlockActors, bProjTarget...: " $ a.bBlockActors $ ", " $ a.bProjTarget );
        log( "   collision radius, height....: " $ a.CollisionRadius $ ", " $ a.CollisionHeight  );
        
        num++;
    }
    log( "   " $ num $ " actors" );
}

//============================================================================
// LogRainbow - 
//============================================================================
function LogRainbow( R6Rainbow rb )
{
    LogR6Pawn( rb );

	log( "   m_bSlideEnd..........: " $ rb.m_bSlideEnd );
    log( "   m_bMovingDiagonally..: " $ Left(string(rb.m_bMovingDiagonally), 5) );
	log( "   m_rRotationOffset....: " $ rb.m_rRotationOffset );
	log( "   R6 Bone Rotation.....: " $ rb.GetBoneRotation('R6') );
	log( "   Pelvis  Rotation.....: " $ rb.GetBoneRotation('R6 Pelvis') );
}

function LogIOBomb( R6IOBomb bomb )
{
    log( "IOBomb: " $bomb );
    log( "  m_bIsActivated..: " $bomb.m_bIsActivated );
    log( "  CanToggle().....: " $bomb.CanToggle()   );
    log( "  m_bExploded.....: " $bomb.m_bExploded   );
    log( "  m_fTimeLeft.....: " $bomb.m_fTimeLeft   );
    log( "  m_fRepTimeLeft..: " $bomb.m_fRepTimeLeft );
    log( "  GetTimeLeft()...: " $bomb.GetTimeLeft()  );
}

//============================================================================
// LogTerro - 
//============================================================================
function LogTerro( R6Terrorist t )
{
    local R6TerroristAI ai;
    local string szTemp;
    
    ai = R6TerroristAI(t.Controller);
    
    LogR6Pawn( t );
    log( " -- Terrorist info --" );
    log( "   Used Template........: " $ t.m_szUsedTemplate );
    log( "   m_DZone..............: " $ t.m_DZone.name );
    if(t.m_HeadAttachment != none)
        log( "   Attachment mesh......: " $ t.m_HeadAttachment.StaticMesh.name );
    else
        log( "   Attachment mesh......: None" );
	Switch(t.m_ePersonality)
	{
		case PERSO_Coward:          szTemp = "PERSO_Coward";    break;
		case PERSO_DeskJockey:      szTemp = "PERSO_DeskJockey";break;
		case PERSO_Normal:          szTemp = "PERSO_Normal";    break;
		case PERSO_Hardened:        szTemp = "PERSO_Hardened";  break;
		case PERSO_SuicideBomber:   szTemp = "PERSO_SuicideBomber";break;
		case PERSO_Sniper:          szTemp = "PERSO_Sniper";    break;
        default:                    szTemp = "Unknown";         break;
	}
    log( "   Personality..........: " $ szTemp $ " (" $ t.m_ePersonality $ ")" );

    log( "   FiringStartPoint.....: " $ t.GetFiringStartPoint() );
    log( "   FiringDirection......: " $ t.GetFiringRotation() );
    log( "   Group ID.............: " $ t.m_iGroupID );
    log( "   Current attack team..: " $ ai.m_iCurrentGroupID );
	Switch(t.m_ePlayerIsUsingHands)
	{
		case HANDS_None:    szTemp = "None";    break;
		case HANDS_Right:   szTemp = "Right";   break;
		case HANDS_Left:    szTemp = "Left";    break;
		case HANDS_Both:    szTemp = "Both";    break;
        default:            szTemp = "Unknown"; break;
	}
    log( "   PlayerIsUsingHands...: " $ szTemp $ " (" $ t.m_ePlayerIsUsingHands $ ")" );
    log( "    Assault.............: " $ INT(t.m_fSkillAssault*100)
      $ ",    Demolitions.........: " $ INT(t.m_fSkillDemolitions*100) );
    log( "    Electronics.........: " $ INT(t.m_fSkillElectronics*100)
      $ ",    SSniper.............: " $ INT(t.m_fSkillSniper*100) );
    log( "    Stealth.............: " $ INT(t.m_fSkillStealth*100)
      $ ",    SelfControl.........: " $ INT(t.m_fSkillSelfControl*100) );
    log( "    Leadership..........: " $ INT(t.m_fSkillLeadership*100)
      $ ",    Observation.........: " $ INT(t.m_fSkillObservation*100) );
    log("     Skills modifier.....: " $ t.SkillModifier() );
    log( "   m_bAllowLeave........: " $ Left(string(t.m_bAllowLeave), 4)
      $ ",   m_bHaveAGrenade......: " $ Left(string(t.m_bHaveAGrenade), 4) );

    if(ai!=None)
    {
        log( "  -See and Hear variable:-" );
	    Switch(ai.m_eReactionStatus)
	    {
		    case REACTION_HearAndSeeAll:    szTemp = "HearAndSeeAll";   break;
		    case REACTION_SeeHostage:       szTemp = "SeeHostage";      break;
		    case REACTION_HearBullet:       szTemp = "HearBullet";      break;
		    case REACTION_SeeRainbow:       szTemp = "SeeRainbow";      break;
		    case REACTION_Grenade:          szTemp = "Grenade";         break;
		    case REACTION_HearAndSeeNothing:szTemp = "HearAndSeeNothing";break;
            default:                        szTemp = "Unknown";         break;
	    }
        log( "   ReactionState........: "  $ szTemp $ " (" $ ai.m_eReactionStatus $ ")" );
        log( "   SeePlayer............: " $ Left(string(!t.m_bDontSeePlayer), 4)
          $ ",   HearPlayer...........: " $ Left(string(!t.m_bDontHearPlayer), 4) );
        log( "   m_eStateForEvent.....: " $ Left(string(ai.m_eStateForEvent), 4) );
        log( "   m_bHearInvestigate...: " $ Left(string(ai.m_bHearInvestigate), 4)
          $ ",   m_bSeeHostage........: " $ Left(string(ai.m_bSeeHostage), 4) );
        log( "   m_bHearThreat........: " $ Left(string(ai.m_bHearThreat), 4)
          $ ",   m_bSeeRainbow........: " $ Left(string(ai.m_bSeeRainbow), 4) );
        log( "   m_bHearGrenade.......: " $ Left(string(ai.m_bHearGrenade), 4) );
        log( "   m_eStrategy..........: " $ Left(string(t.m_eStrategy), 4) );
        
    }
}

//============================================================================
// function dbgRainbow - 
//============================================================================
exec function dbgRainbow()
{
    local R6Rainbow   rb;
    local INT         num;

    if ( !CanExec() ) return;

    log( "-- ALL RAINBOW DUMP --" );
    foreach AllActors( class'R6Rainbow', rb )
    {
        LogRainbow( rb );
        num++;
    }
    log( "   " $ num $ " rainbow" );
}

#ifdefDEBUG
exec function dbgWeapon()
{
    if ( !CanExec() ) return;

    log("pawn : "$pawn$" engine Weapon "$pawn.engineWeapon);

    pawn.engineWeapon.DisplayWeaponDGBInfo();
}
exec function dbgHisWeapon()
{
    local Actor HitActor;
    local vector HitLocation;
    local vector HitNormal;
    local vector Start;
    local vector End;

    if ( !CanExec() ) return;

    Start=pawn.Location + R6Pawn(Pawn).EyePosition();
    End=Start + 5000 * Vector(R6Pawn(Pawn).R6GetViewRotation());

    HitActor = Trace( HitLocation, HitNormal, end, start,true);

    if((HitActor != none) && (HitActor.IsA('R6Pawn')))
    {
        log("HitActor : "$HitActor$" engine Weapon "$R6Pawn(HitActor).engineWeapon);
        R6Pawn(HitActor).engineWeapon.DisplayWeaponDGBInfo();
    }
}
#endif

//============================================================================
// function dbgTerro - 
//============================================================================
exec function dbgTerro()
{
    local R6Terrorist   t;
    local INT           num;
    
    if ( !CanExec() ) return;

    log( "-- ALL TERRO DUMP --" );
    foreach AllActors( class'R6Terrorist', t )
    {
        LogTerro( t );
        num++;
    }
    log( "   " $ num $ " terrorists" );
}

//------------------------------------------------------------------
// SetPawn : set the current pawn
//------------------------------------------------------------------
function exec SetPawn()
{
    local Actor     anActor; 

    if ( !CanExec() ) return;

    anActor = GetPointedActor( false, true );

    if ( R6Pawn( anActor ) != none )
    {
        m_curPawn = R6Pawn( anActor );
        Player.Console.Message( "ESCORTED: " $m_curPawn.controller.name, 6.0 );
    }
    else
    {
        m_curPawn = none;
    }
}

exec function string SetPawnPace( INT i, OPTIONAL bool bHelp )
{
    local string text;

    if ( !CanExec() ) return "";
    
    if ( bHelp )
    {
        return "Set m_eMovementPace 0=none 1=prone 2=crouchwalk 3=crouchrun 4=walk 5=run";    
    }

    if ( m_curPawn == none )
    {
        Player.Console.Message( "no pawn", 6.0 );
    }

    switch ( i )
    {
        case 0: m_curPawn.m_eMovementPace = m_curPawn.eMovementPace.PACE_None;       text = "none";         break;
        case 1: m_curPawn.m_eMovementPace = m_curPawn.eMovementPace.PACE_Prone;      text = "prone";        break;
        case 2: m_curPawn.m_eMovementPace = m_curPawn.eMovementPace.PACE_CrouchWalk; text = "crouchwalk";   break;
        case 3: m_curPawn.m_eMovementPace = m_curPawn.eMovementPace.PACE_CrouchRun;  text = "crouchrun";    break;
        case 4: m_curPawn.m_eMovementPace = m_curPawn.eMovementPace.PACE_Walk;       text = "walk";         break;
        case 5: m_curPawn.m_eMovementPace = m_curPawn.eMovementPace.PACE_Run;        text = "run";          break;
    }

    Player.Console.Message( "eMovementPace="$text, 6.0 );

    return "";
}

exec function SeeCurPawn()
{
    if ( !CanExec() ) return;

    if ( m_curPawn == none )
        return;

    if ( CanSee( m_curPawn ) ) 
    {
        log( "SeePawn: success" );
    }
    else
    {
        log( "SeePawn: fail" );
    }
}


//------------------------------------------------------------------
// UsePath
//------------------------------------------------------------------
function exec UsePath( int i )
{
    local R6Pawn.eMovementPace ePace;

    if ( !CanExec() ) return;
    
    if ( m_curPawn == none )
    {
        Player.Console.Message( "no pawn" , 6.0 );
        return;
    }
 
    Player.Console.Message( "Use path" , 6.0 );
    
    if ( i == 1 )
    {
        if ( m_curPawn.bIsCrouched )
            ePace = m_curPawn.eMovementPace.PACE_CrouchRun;
        else
            ePace = m_curPawn.eMovementPace.PACE_Run;

    }
    else
    {
        if ( m_curPawn.bIsCrouched )
            ePace = m_curPawn.eMovementPace.PACE_CrouchWalk;
        else
            ePace = m_curPawn.eMovementPace.PACE_Walk;
    }
    
    R6AIController(m_curPawn.controller).SetStateTestMakePath( pawn, ePace );
}


//------------------------------------------------------------------
// CanWalk
//------------------------------------------------------------------
function exec CanWalk()
{
    if ( !CanExec() ) return;

    if ( m_curPawn == none )
    {
        Player.Console.Message( "no pawn" , 6.0 );
        return;
    }

    if ( R6AIController( m_curPawn.controller ).CanWalkTo( pawn.location, TRUE ) )
    {
        Player.Console.Message( "CanWalkTo: true" , 6.0 );
        log( "CanWalkTo: true" );
    }
    else
    {
        Player.Console.Message( "CanWalkTo: false" , 6.0 );
        log( "CanWalkTo: false" );
    }
}


//------------------------------------------------------------------
// TestFindPathToMe
//------------------------------------------------------------------
function exec TestFindPathToMe()
{
    if ( !CanExec() ) return;

    if ( m_curPawn == none )
    {
        Player.Console.Message( "no pawn" , 6.0 );
        return;
    }

    if ( R6AIController( m_curPawn.controller ).FindPathToward( pawn, TRUE ) == none )
    {
        Player.Console.Message( "FindPathToward: failed" , 6.0 );
        //log( "CanWalkTo: true" );
    }
    else
    {
        Player.Console.Message( "FindPathToward: ok" , 6.0 );
    }

    if ( R6AIController( m_curPawn.controller ).FindPathTo( pawn.location, TRUE ) == none )
    {
        Player.Console.Message( "FindPathTo: failed" , 6.0 );
        //log( "CanWalkTo: true" );
    }
    else
    {
        Player.Console.Message( "FindPathTo: ok" , 6.0 );
    }

}

//------------------------------------------------------------------
// MoveEscort
//------------------------------------------------------------------
function exec MoveEscort()
{
    local vector    vHit;

    if ( !CanExec() ) return;

    if ( m_curPawn == none )
    {
        Player.Console.Message( "no pawn" , 6.0 );
        return;
    }


    if ( R6Hostage(m_curPawn) != none )
    {
        GetPointedActor( false, true, vHit );
        vHit.Z += m_curPawn.CollisionHeight/2; 
            
        R6HostageAI(m_curPawn.controller).SetStateEscorted( R6Pawn(pawn), vHit, false ); 
        
        if ( R6Hostage(m_curPawn).m_bEscorted )
        {
            Player.Console.Message( "MOVE ESCORT" , 6.0 );
        }
    }

    Player.Console.Message( "MOVE FAILED" , 6.0 );

}

//------------------------------------------------------------------
// SetPState: set the pawn's state
//	
//------------------------------------------------------------------
exec function SetPState( name stateToGo )
{
    if ( m_curPawn == none )
        return;

    if ( !CanExec() ) return;

    m_curPawn.gotoState( stateToGo );
}


//------------------------------------------------------------------
// SetCState: set the controller's state
//------------------------------------------------------------------
exec function SetCState( name stateToGo )
{
    if ( m_curPawn == none )
        return;

    if ( !CanExec() ) return;

    m_curPawn.gotoState( stateToGo );
}

//------------------------------------------------------------------
// SetHPos: set hostage position
//------------------------------------------------------------------
exec function SetHPos( INT iPos )
{
    local R6Hostage.EStartingPosition ePos;
    
    if ( !CanExec() ) return;

    if ( R6Hostage( m_curPawn ) == none )
        return;

    switch ( iPos )
    {
        case 1: ePos = POS_Kneel;  break;
        case 2: ePos = POS_Prone;  break;
        case 3: ePos = POS_Foetus; break;
        case 4: ePos = POS_Crouch; break;        
        case 5: ePos = POS_Random; break;        
        default:ePos = POS_Stand;
    }

    R6HostageAI( m_curPawn.controller ).SetPawnPosition( ePos );
}


exec function SetHRoll( INT iRoll )
{
    local R6Hostage h;

    if ( !CanExec() ) return;

    if ( iRoll == 0 )
    {
        Player.Console.Message( "Roll disable ", 6.0 );
    }
    else
    {
        Player.Console.Message( "Roll: " $iRoll, 6.0 );
    }

    foreach AllActors( class'R6Hostage', h )
    {
        R6HostageAI(h.controller).m_bDbgRoll = (iRoll != 0);
        R6HostageAI(h.controller).m_iDbgRoll = iRoll;
        log( "SetHRoll:" $R6HostageAI(h.controller).m_bDbgRoll$ " iRoll: " $R6HostageAI(h.controller).m_iDbgRoll );
    }        
}

//------------------------------------------------------------------
// Shake Parameters Cheats
//------------------------------------------------------------------
exec function DesignSF(FLOAT NewSpeedFactor)
{
    if ( !CanExec() ) return;

    R6PlayerController(pawn.Controller).m_fDesignerSpeedFactor = NewSpeedFactor;
}
exec function DesignJF(FLOAT NewJumpFactor)
{
    if ( !CanExec() ) return;

    R6PlayerController(pawn.Controller).m_fDesignerJumpFactor = NewJumpFactor;
}
exec function SetShake(BOOL bSet)
{
    if ( !CanExec() ) return;

    R6PlayerController(pawn.Controller).m_bShakeActive = bSet;
}

exec function DesignMaxRand(INT NewMax)
{
    local R6Pawn CurrentPawn;

    if ( !CanExec() ) return;

    foreach AllActors( class'R6Pawn', CurrentPawn )
    {
        CurrentPawn.m_iDesignRandomTweak = NewMax;
    }
}

exec function DesignArmor(INT Light, INT Medium, INT Heavy)
{
    local R6Pawn CurrentPawn;

    if ( !CanExec() ) return;

    foreach AllActors( class'R6Pawn', CurrentPawn )
    {
        CurrentPawn.m_iDesignLightTweak = Light;
        CurrentPawn.m_iDesignMediumTweak = Medium;
        CurrentPawn.m_iDesignHeavyTweak = Heavy;
    }
}

exec function DesignToggleLog()
{
    local R6Pawn CurrentPawn;

    if ( !CanExec() ) return;

    foreach AllActors( class'R6Pawn', CurrentPawn )
    {
        CurrentPawn.m_bDesignToggleLog = !CurrentPawn.m_bDesignToggleLog;
    }
}

//------------------------------------------------------------------
// Weapon offset Functions
//------------------------------------------------------------------
#ifdefDEBUG
exec function WOX(FLOAT X)
{
    Pawn.EngineWeapon.m_vPositionOffset.X += X;
}
exec function WOY(FLOAT Y)
{
    Pawn.EngineWeapon.m_vPositionOffset.Y += Y;
}
exec function WOZ(FLOAT Z)
{
    Pawn.EngineWeapon.m_vPositionOffset.Z += Z;
}
exec function ShowWO()
{
    log("WeaponOffset for weapon "$pawn.EngineWeapon$" is "$Pawn.EngineWeapon.m_vPositionOffset);
}
#endif


exec function DesignHBS(FLOAT fRange)
{
    if ( !CanExec() ) return;

    Pawn.EngineWeapon.SetHeartBeatRange(fRange);
}

#ifdefDEBUG
exec function HandDown()
{
    R6AbstractWeapon(Pawn.EngineWeapon).m_FPHands.GotoState('HandsDown');
}
exec function HandUp()
{

    R6AbstractWeapon(Pawn.EngineWeapon).m_FPHands.GotoState('Waiting');
}

exec function DeployBP()
{
    Pawn.EngineWeapon.GotoState('DeployBipod');
}
exec function CloseBP()
{
    Pawn.EngineWeapon.GotoState('CloseBipod');
}
#endif

//------------------------------------------------------------------
// Hostage / Civilian debugger
//	
//------------------------------------------------------------------
exec function hHelp()
{
    if ( !CanExec() ) return;

    log( "Hostage / Civ Debugger" );
    log( "======================" );
    log( "  hReset.......: reset current hostage ptr" );
    log( "  hLog.........: log hostage" );
    log( "  hCiv.........: set to civilian" );
    log( "  hHostage.....: set to hostage 0=Stand 1=Kneel" );
    log( "  hPos.........: set position: 0=Stand, 1=Kneel, 2=Prone, 3=Foetus, 4=Crouch, 5=Random" );
    log( "  hReact.......: react (Civ: 0=CivProne, 1=CivRunTowardRainbow, 2=CivRunForCover");
    log( "  hReact.......: react (hostage: anim index from 0 to 2 ");
    log( "  hFreeze......: go freeze" );
    log( "  hHurt........: set health to hurt " );
    log( "  hWalkAnim....: set walk anim: 0=default 1=scared" );
    log( "  hGre.........: play grenade reaction anim: 0=reset 1=blinded 2=gas" );
}

function hDebugLog( string sz )
{
    log( "hDebug: " $sz );
}

//------------------------------------------------------------------
// 
//------------------------------------------------------------------
exec function hReset()
{
    if ( !CanExec() ) return;

    m_hostage = none;
}

//------------------------------------------------------------------
// 
//------------------------------------------------------------------
exec function hLog()
{
    if ( !CanExec() ) return;

    if ( !hInit() )
        return;
 
    LogHostage( m_hostage );
}

//------------------------------------------------------------------
// 
//------------------------------------------------------------------
exec function bool hInit()
{
    local INT iClosest;
    local R6Hostage h;
    local R6Hostage hostage;

    if ( !CanExec() ) return false;

    if ( m_hostage != none )
        return true;

    // get the closest hostage
    iClosest = 999999;
    hostage = none;

    foreach AllActors( class'R6Hostage', h )
    {
        if ( VSize( pawn.Location - h.Location ) < iClosest )
        {
            iClosest = VSize( pawn.Location - h.Location );
            hostage = h;
        }
    }

    if ( hostage == none )
    {
        Player.Console.Message( "no hostage found", 6 );
        return false;
    }
    Player.Console.Message( "found: " $hostage.name, 6 );

    m_hostage = hostage;
    // topod: should be commented outm_hostage.m_controller.logX( "**** hDebug mode ****" );
    m_hostage.m_controller.m_bDbgIgnoreThreat = true;
    m_hostage.m_controller.m_bDbgIgnoreRainbow = true;
    return true;
}

//------------------------------------------------------------------
// 
//------------------------------------------------------------------
exec function hCiv()
{
    if ( !CanExec() ) return;

    if ( !hInit() )
        return;

    hDebugLog( "CivInit" );
    m_hostage.m_controller.CivInit();
}

//------------------------------------------------------------------
// 
//------------------------------------------------------------------
exec function hHostage( INT iPos )
{
    if ( !CanExec() ) return;

    if ( !hInit() )
        return;

    if ( iPos == 1 )
    {
        hDebugLog( "Hostage: kneel" );
        m_hostage.m_controller.SetStateGuarded( POS_Kneel, m_hostage.m_mgr.HSTSNDEvent_AskedToStayPut );
    }
    else
    {
        hDebugLog( "Hostage: standing" );
        m_hostage.m_controller.SetStateGuarded( POS_Stand, m_hostage.m_mgr.HSTSNDEvent_AskedToStayPut );
    }
}

//------------------------------------------------------------------
// 
//------------------------------------------------------------------
exec function hPos( INT iPos )
{
    local R6Hostage.EStartingPosition ePos;
 
    if ( !CanExec() ) return;
    
    if ( !hInit() )
        return;

    switch ( iPos )
    {
        case 1: ePos = POS_Kneel;  hDebugLog( "SetPawnPosition: kneeling" ); break;
        case 2: ePos = POS_Prone;  hDebugLog( "SetPawnPosition: prone"    ); break;
        case 3: ePos = POS_Foetus; hDebugLog( "SetPawnPosition: foetus"   ); break;
        case 4: ePos = POS_Crouch; hDebugLog( "SetPawnPosition: crouch"   ); break;        
        case 5: ePos = POS_Random; hDebugLog( "SetPawnPosition: random"   ); break;        
        default:ePos = POS_Stand;  hDebugLog( "SetPawnPosition: standing" ); 
    }

    m_hostage.m_controller.SetPawnPosition( ePos );
}

exec function hGre( INT iGrenade )
{
    if ( !CanExec() ) return;

    if ( !hInit() )
        return;

    switch ( iGrenade )
    {
        case 1:  m_hostage.playBlinded();   break;
        case 2:  m_hostage.playCoughing();  break;
        default: m_hostage.endOfGrenadeEffect( Pawn.EGrenadeType.GTYPE_TearGas );
    }
    
}

//------------------------------------------------------------------
// 
//------------------------------------------------------------------
exec function hReact( INT iReact )
{
    if ( !CanExec() ) return;
    
    if ( !hInit() )
        return;

    if ( m_hostage.m_controller.isInState( 'Civilian' ) )
    {
        m_hostage.m_controller.m_threatInfo.m_pawn = pawn;

        if ( iReact == 1 )
        {
            hDebugLog( "CivRunTowardRainbow" );
            m_hostage.m_controller.GotoState( 'CivRunTowardRainbow' );
        }
        else if ( iReact == 2 )
        {
            hDebugLog( "CivRunForCover" );
            m_hostage.m_controller.GotoState( 'CivRunForCover' );
        }
        else
        {
            hDebugLog( "CivProne" );
            m_hostage.m_controller.GotoState( 'CivProne' );
        }
    }
    else if ( m_hostage.isStandingHandUp() )
    {
        if ( iReact == 1 )
        {
            hDebugLog( "ANIM_eStandHandUpReact02" );
            m_hostage.SetAnimInfo( m_hostage.m_controller.m_mgr.ANIM_eStandHandUpReact02 );
        }
        else if ( iReact == 2 )
        {
            hDebugLog( "ANIM_eStandHandUpReact03" );
            m_hostage.SetAnimInfo( m_hostage.m_controller.m_mgr.ANIM_eStandHandUpReact03 );
        }
        else 
        {
            hDebugLog( "ANIM_eStandHandUpReact01" );
            m_hostage.SetAnimInfo( m_hostage.m_controller.m_mgr.ANIM_eStandHandUpReact01 );
        }
    }
    else if ( m_hostage.m_ePosition == POS_Kneel )
    {
        if ( iReact == 1 )
        {
            hDebugLog( "ANIM_eKneelReact02" );
            m_hostage.SetAnimInfo( m_hostage.m_controller.m_mgr.ANIM_eKneelReact02 );
        }
        else if ( iReact == 2 )
        {
            hDebugLog( "ANIM_eKneelReact03" );
            m_hostage.SetAnimInfo( m_hostage.m_controller.m_mgr.ANIM_eKneelReact03 );
        }
        else 
        {
            hDebugLog( "ANIM_eKneelReact01" );
            m_hostage.SetAnimInfo( m_hostage.m_controller.m_mgr.ANIM_eKneelReact01 );
        }
    }
    else
    {
        Player.Console.Message( "can't play react", 6 );
    }
}

//------------------------------------------------------------------
// hFreeze: 
//------------------------------------------------------------------
exec function hFreeze()
{
    if ( !CanExec() ) return;

    if ( !hInit() )
        return;

    if ( m_hostage.isStandingHandUp() || m_hostage.m_ePosition == POS_Kneel )
    {
        hDebugLog( "State: Guarded_frozen" );
        m_hostage.m_controller.gotoState( 'Guarded_frozen' );
    }
    else
    {
        Player.Console.Message( "can't go freeze", 6 );
    }
}

//------------------------------------------------------------------
// hHurt
//------------------------------------------------------------------
exec function hHurt()
{
    if ( !CanExec() ) return;

    if ( !hInit() )
        return;

    m_hostage.m_eHealth = HEALTH_Wounded;
    hWalkAnim( 1 );
}

//------------------------------------------------------------------
// hWalkAnim
//------------------------------------------------------------------
exec function hWalkAnim( INT i )
{
    if ( !CanExec() ) return;

    if ( !hInit() )
        return;

    if ( i == 1 )
    {
        m_hostage.SetStandWalkingAnim( m_hostage.EStandWalkingAnim.eStandWalkingAnim_scared, true );
    }
    else
    {
        m_hostage.SetStandWalkingAnim( m_hostage.EStandWalkingAnim.eStandWalkingAnim_default, true );
    }
}

//============================================================================
// function DrawRoute - 
//============================================================================
simulated function DrawRoute( R6AIController r6con, Canvas canvas )
{
	local int i;
	local vector vTemp;
    
    if ( !CanExec() ) return;

    // Draw route cache in yellow
    if( r6con.RouteCache[0]!=none )
    {
	    for ( i=1; i<16 && r6con.RouteCache[i]!=none; i++ )
	    {
            canvas.Draw3DLine( r6con.RouteCache[i-1].Location, r6con.RouteCache[i].Location, class'Canvas'.Static.MakeColor(255,255,0));
	    }
    }

	// Draw destination in white
	if ( (r6con.Destination != vect(0,0,0)) )
	{
		canvas.Draw3DLine( r6con.Pawn.Location, r6con.Destination, class'Canvas'.Static.MakeColor(255,255,255));
	}

	// show where pawn is looking in red
	if ( r6con.Focus != None )
		vTemp = r6con.Focus.Location;
	else
		vTemp = r6con.FocalPoint;

    canvas.Draw3DLine( r6con.Pawn.Location + r6con.Pawn.EyePosition(), vTemp, class'Canvas'.Static.MakeColor(255,0,0));
    //canvas.Draw3DLine( r6con.Pawn.Location, r6con.LastSeenPos, class'Canvas'.Static.MakeColor(0,0,255));
}


// RotateMe "R6 Spine" pitch yaw roll
exec function RotateMe(name boneName, int pitch, int yaw, int roll, float inTime)
{
    local rotator rOffset;

    if ( !CanExec() ) return;

    rOffset.pitch = pitch;
    rOffset.yaw = yaw;
    rOffset.roll = roll;
    R6Pawn(pawn).SetBoneRotation(boneName, rOffset,, 1.0, inTime);
    log( "RotateMe" $boneName );
}

exec function ResetMeAll()
{
    if ( !CanExec() ) return;

    R6Pawn(pawn).ResetBoneRotation();

    R6Pawn(pawn).SetBoneRotation('R6 Head', rot(0,0,0),, 1.0, 0.4);  // add later if necessary...
	R6Pawn(pawn).SetBoneRotation('R6 Neck', rot(0,0,0),, 1.0, 0.4);
    R6Pawn(pawn).SetBoneRotation('R6 Spine', rot(0,0,0),, 1.0, 0.4);
    R6Pawn(pawn).SetBoneRotation('R6 Spine1', rot(0,0,0),, 1.0, 0.4);
    R6Pawn(pawn).SetBoneRotation('R6 Pelvis', rot(0,0,0),, 1.0, 0.4);

    // reset bone rotations
#ifdefDEBUG    
    R6Pawn(pawn).UpdateBones();
#endif
}

//------------------------------------------------------------------
// toggleNav
//	
//------------------------------------------------------------------
exec function toggleNav()
{
    if ( !CanExec() ) return;

    m_bEnableNavDebug = !m_bEnableNavDebug;

    Player.Console.Message( "EnableNavPointDebug = " $m_bEnableNavDebug, 6.0 );
    
    if ( m_bEnableNavDebug )
    {
        ToggleRadius();
    }
}

//------------------------------------------------------------------
// processNavDebug: when enabled, it check if there's a nav point
//  accessible from the player location.
//------------------------------------------------------------------
function processNavDebug( Canvas c )
{
    local Actor path;
    local bool bFound;
    local string szName;
    local int i;
    local vector vLoc;
    
    if ( !CanExec() ) return;

    if ( Pawn == none || Pawn.Physics != PHYS_Walking )
        return;

    path = FindRandomDest( true );

    if ( path == none )
    {
        // search for a close NavPoint
        for (  i = 0; i < m_aNavPointLocation.Length; ++i )
        {
            vLoc = m_aNavPointLocation[i];

            if ( FastTrace( vLoc, Pawn.Location ) && VSize( Pawn.Location - vLoc) < m_fNavPointDistance  )
            {
                bFound = true;
                break;
            }
        }

        if ( !bFound )
        {
            m_aNavPointLocation[m_iCurNavPoint] = Pawn.Location;
            szName = "Need NavPoint: "$m_iCurNavPoint;
            // start index at c_iNavPointIndex
            Pawn.DbgVectorAdd( Pawn.Location, vect(40,40,80), c_iNavPointIndex+m_iCurNavPoint, szName ); 
            log( szName );
            Player.Console.Message( "**** " $ szName, 10 );
            m_iCurNavPoint++;    
        }
    }
}

//============================================================================
// function KillThemAll - 
//============================================================================
exec function KillThemAll()
{
	local R6Pawn p;

    if ( !CanExec() ) return;

	foreach AllActors( class 'R6Pawn', p )
    {
        if(!p.m_bIsPlayer)
        {
            p.ServerForceKillResult(4);
            p.R6TakeDamage( 1000, 1000, Pawn, p.Location, vect(0,0,0), 0);
        }
    }
}

exec function dbgPeek()
{
    if ( !CanExec() ) return;

    m_bTogglePeek = !m_bTogglePeek;

    Player.Console.Message( "DbgPeek = " $m_bTogglePeek, 6.0 );
}

function processDebugPeek( Canvas canvas )
{
    local int YPos;
    local int YL;
    local R6Pawn p;
    local string szPeek;
    local rotator rRotator;

    if ( Pawn == none || Pawn.Physics != PHYS_Walking )
        return;

	
    Canvas.SetDrawColor(0,255,0);

    p = R6Pawn( ViewTarget );

    YPos = 350;
    YL = 10;
	
    Canvas.SetPos(4,YPos);
    Canvas.DrawText("IsPeeking:  "$p.IsPeeking()$" Left: "$p.IsPeekingLeft() );
	YPos += YL;

    Canvas.SetPos(4,YPos);
    Canvas.DrawText("   m_fCrouchBlendRate= "$p.m_fCrouchBlendRate);
    YPos += YL;

    Canvas.SetPos(4,YPos);
    Canvas.DrawText("   GetPeekingRate()= "$p.GetPeekingRate());
    YPos += YL;

    if ( p.m_ePeekingMode == PEEK_fluid )
    {
        szPeek = "fluid";
    }
    else if ( p.m_ePeekingMode == PEEK_full )
    {
        szPeek = "full";
    }
    
    Canvas.SetPos(4,YPos); 
    Canvas.DrawText("   m_ePeekingMode= "$szPeek );
    YPos += YL;

    Canvas.SetPos(4,YPos);
    Canvas.DrawText("   m_fPeekingGoal= "$p.m_fPeekingGoal );
    YPos += YL;

    Canvas.SetPos(4,YPos);
    Canvas.DrawText("   m_fPeeking= "$p.m_fPeeking );
    YPos += YL;

    Canvas.SetPos(4,YPos);
    Canvas.DrawText("   m_fLastValidPeeking= "$p.m_fLastValidPeeking );
    YPos += YL;

    Canvas.SetPos(4,YPos);
    Canvas.DrawText("   m_bPeekingReturnToCenter= "$p.m_bPeekingReturnToCenter );
    YPos += YL;

    Canvas.SetPos(4,YPos);
    Canvas.DrawText("   bIsCrouched= "$p.bIsCrouched);
    YPos += YL;

    Canvas.SetPos(4,YPos);
    Canvas.DrawText("   PrepivotZ= "$p.PrePivot.Z);
    YPos += YL;

    Canvas.SetPos(4,YPos);
    Canvas.DrawText("   PrePivotProneBackupZ= "$p.m_vPrePivotProneBackup.Z);
    YPos += YL;

    Canvas.SetPos(4,YPos);
    rRotator = p.GetBoneRotation('R6');
    Canvas.DrawText("   r6 bone y= "$rRotator.Yaw$ " p=" $rRotator.pitch );
    YPos += YL;
    
    Canvas.SetPos(4,YPos);
    //Canvas.DrawText("   r6 bone y= "$p.m_rRotationOffset.yaw$ " p=" $p.m_rRotationOffset.pitch );
    Canvas.DrawText("   m_rRotationOffset= "$p.m_rRotationOffset );
    YPos += YL;

    Canvas.SetPos(4,YPos);
    Canvas.DrawText("   m_bPostureTransition= "$p.m_bPostureTransition );
    YPos += YL;

    Canvas.SetPos(4,YPos);
    Canvas.DrawText("   m_bPeekLeft= "$R6PlayerController(Pawn.Controller).m_bPeekLeft$ " m_bPeekRight=" $R6PlayerController(Pawn.Controller).m_bPeekRight  );
    YPos += YL;

    
}

exec function resetThreat( )
{
    local R6HostageAI ai;
    local R6Hostage h;

    if ( !CanExec() ) return;

    foreach AllActors( class 'R6Hostage', h )
    {
        ai = R6HostageAI( h.controller );
        ai.m_threatInfo = ai.m_mgr.getDefaulThreatInfo();
    }

}

exec function toggleThreatInfo()
{
    if ( !CanExec() ) return;

    m_bToggleThreatInfo = !m_bToggleThreatInfo;
}

function processThreatInfo( Canvas Canvas )
{
    local int YPos;
    local int YL;
    local R6Pawn p;
    local R6HostageAI ai;
    local R6Hostage h;

    Canvas.SetDrawColor(0,255,0);

    YPos = 100;
    YL = 16;

    foreach AllActors( class 'R6Hostage', h )
    {
        ai = R6HostageAI( h.controller );
        canvas.SetPos(4,YPos);
        Canvas.DrawText("" $ai$ " " $ai.m_mgr.GetThreatInfoLog( ai.m_threatInfo ) );
        YPos += YL;
    }
}

function processDebugPG( Canvas Canvas )
{
    local int YPos;
    local int YL;
    local R6Pawn p;
    local R6HostageAI ai;
    local R6Hostage h;

    if ( Pawn == none )
        return;
	
    Canvas.SetDrawColor(0,255,0);

    p = R6Pawn( pawn );

    YPos = 300;
    YL = 16;

    foreach AllActors( class 'R6Hostage', h )
    {
        ai = R6HostageAI( h.controller );
        canvas.SetPos(4,YPos);
        Canvas.DrawText("" $ai$ " " $ai.m_mgr.GetThreatInfoLog( ai.m_threatInfo ) );
        YPos += YL;
    }

    /* // bidop & body / head rotation
    Canvas.SetPos(4,YPos);
    Canvas.DrawText("   RotationPitch= "$p.Controller.Rotation.Pitch );
    YPos += YL;

    Canvas.SetPos(4,YPos);
    Canvas.DrawText("   RotationYaw= "$p.Controller.Rotation.Yaw );
    YPos += YL;

    Canvas.SetPos(4,YPos);
    Canvas.DrawText("   desiredRotation.yaw = "$p.Controller.desiredRotation.yaw );
    YPos += YL;

    Canvas.SetPos(4,YPos);
    Canvas.DrawText("   m_rRotationOffset.yaw = "$p.m_rRotationOffset.Yaw );
    YPos += YL;

    Canvas.SetPos(4,YPos);
    Canvas.DrawText("   m_fBipodRotation = "$p.m_fBipodRotation );
    YPos += YL;*/
}

exec function sgi( int iLevel )
{
    if ( !CanExec() ) return;

    ShowGameInfo( iLevel );
}

exec function ShowGameInfo( int iLevel )
{
    if ( !CanExec() ) return;

    m_bToggleGameInfo = !m_bToggleGameInfo;
    m_iGameInfoLevel = iLevel;
}

//------------------------------------------------------------------
// displayMissionObjective
//	
//------------------------------------------------------------------
function displayMissionObjective( int iVerbose, Canvas C, int YL, int XPos, OUT int YPos, OUT int iLine, 
                                  R6MissionObjectiveBase mo, OUT int iSubGroup )
{
    local int i;
    local int iSubLine;
    local string szIndent;
    local string szDesc;
    local string szDescID;
    local bool   bDisplay;
    local bool   bDisplayFailure;

    if ( iSubGroup > 0 )
    {
        szIndent = "   (" $iSubGroup$ ") ";   
    }
    else
    {
        szIndent = "   ";
    }

    if ( iVerbose >= 1 )                        // like if in the menu
    {
        if ( mo.m_bVisibleInMenu )              // shown in the menu
        {
            bDisplay = true;
            if ( mo.m_szDescriptionInMenu == "" )
            {
                szDesc = "warning: m_szDescriptionInMenu is empty";
            }
            else
            {
                szDesc = "" $mo.m_szDescriptionInMenu$ "= " $Localize("Game", mo.m_szDescriptionInMenu, Level.GetMissionObjLocFile( mo ) );
            }
        }
    }
    else                                        // debug mode
    {
        bDisplay = true;
        szDesc = mo.getDescription();
    }

    if ( bDisplay )
    {
        C.SetPos(XPos,YPos);
        if ( mo.isCompleted() )
        {
            C.SetDrawColor(0,255,0);
            C.DrawText( "" $szIndent$ "" $iLine$ "- " $szDesc$ " : completed" );
        }
        else if ( mo.isFailed() )
        {
            C.SetDrawColor(255,0,0);
            C.DrawText( "" $szIndent$ "" $iLine$ "- " $szDesc$ " : failed" );
        }
        else
        {
            C.SetDrawColor(255,255,255);
            C.DrawText( "" $szIndent$ "" $iLine$ "- " $szDesc );
        }
        YPos += YL;
    }

    if ( iVerbose >= 2 )
    {
        C.SetPos(XPos,YPos);
        if ( mo.m_szDescriptionFailure != "" )
        {
            C.SetDrawColor(0,255,0);
            C.DrawText( "" $szIndent$ "" $iLine$ " (" $mo.m_szDescriptionFailure$ "= " $Localize("Game", 
                        mo.m_szDescriptionFailure, Level.GetMissionObjLocFile(mo) )$ ")" );
            YPos += YL;
            bDisplay = true;
        }
    }

    if ( bDisplay )
    {
        ++iLine;
    }

    if ( mo.GetNumSubMission() > 0 )
    {
        iSubGroup++; 
        for ( i = 0; i < mo.GetNumSubMission(); ++i )
        {
            iSubLine = i + 1;
            displayMissionObjective( iVerbose, C, YL, XPos, YPos, iSubLine, mo.GetSubMissionObjective( i ), iSubGroup );
        }
    }
}

function displayGameInfo(Canvas C)
{
    local int XPos;
    local int YPos;
    local int YL;
    local R6MissionObjectiveMgr moMgr;
    local int i;
    local int iLine;
    local bool bMoralityObj;
    local int iSubGroup;
    local int iDiffLevel;

    YPos = 90;
    XPos = 10;
    YL = 13;
    
    C.Font = C.MedFont;
    C.SetPos(XPos,YPos);
    C.DrawText("GameMode = " $ Level.GetGameTypeClassName( R6AbstractGameInfo(Level.Game).m_szGameTypeFlag)$ " m_bGameOver=" $R6AbstractGameInfo(Level.Game).m_bGameOver );
    YPos += YL;

    iDiffLevel = -1;
    if ( R6AbstractGameInfo(Level.Game) != none )
    {
        iDiffLevel = R6AbstractGameInfo(Level.Game).m_iDiffLevel;
    }
    else if ( GameReplicationInfo != none )
    {
        iDiffLevel = R6GameReplicationInfo(GameReplicationInfo).m_iDiffLevel;
    }

    if ( iDiffLevel != -1 )
    {

        C.SetPos(XPos,YPos);

        switch ( iDiffLevel )
        {
        case 1 : C.DrawText("Diffilculty level: recruit " );    break;
        case 2 : C.DrawText("Diffilculty level: veteran " );    break;
        case 3 : C.DrawText("Diffilculty level: elite" );       break;
        default: C.DrawText("Diffilculty level: unknown" );
        }
        
        YPos += YL;
    }

    // list all mission objective
    moMgr = R6AbstractGameInfo(Level.Game).m_missionMgr;

    if ( moMgr == none )
        return;

    if ( moMgr.m_eMissionObjectiveStatus == eMissionObjStatus_success )
    {
        C.SetDrawColor(0,255,0);
        C.SetPos(XPos,YPos);
        C.DrawText("-- MISSION OBJECTIVE: COMPLETED");
        YPos += YL;
    }
    else if ( moMgr.m_eMissionObjectiveStatus == eMissionObjStatus_failed )
    {
        C.SetDrawColor(255,0,0);
        C.SetPos(XPos,YPos);
        C.DrawText("-- MISSION OBJECTIVE: FAILED");
        YPos += YL;
    }
    else
    {
        C.SetDrawColor(255,255,255);
        C.SetPos(XPos,YPos);
        C.DrawText("-- MISSION OBJECTIVE: in progress ");
        YPos += YL;
    }

    for ( i = 0; i < moMgr.m_aMissionObjectives.Length; ++i )
    {
        if ( !moMgr.m_aMissionObjectives[i].m_bMoralityObjective )
        {
            iSubGroup = 0;
            displayMissionObjective( m_iGameInfoLevel, C, YL, XPos, YPos, 
                                     iLine, moMgr.m_aMissionObjectives[i], iSubGroup );
        }
        else
        {
            bMoralityObj = true;
        }
    }

    if ( bMoralityObj )
    {
        C.SetDrawColor(255,255,255);
        C.SetPos(XPos,YPos);
        C.DrawText("-- MISSION OBJECTIVE: morality ");
        YPos += YL;
    }

    iLine = 0;
    for ( i = 0; i < moMgr.m_aMissionObjectives.Length; ++i )
    {
        if ( moMgr.m_aMissionObjectives[i].m_bMoralityObjective )
        {
            displayMissionObjective( m_iGameInfoLevel, C, YL, XPos, YPos, 
                                     iLine, moMgr.m_aMissionObjectives[i], iSubGroup );
        }        
    }
}

exec function RendPawnState()
{
    if ( !CanExec() ) return;

    m_bRendPawnState = !m_bRendPawnState;
    Player.Console.Message( "RendPawnState " $ m_bRendPawnState, 6.0 );
}

exec function RendFocus()
{
    if ( !CanExec() ) return;

    m_bRendFocus = !m_bRendFocus;;
    Player.Console.Message( "RendFocus " $ m_bRendFocus, 6.0 );
}

exec function SetRoundTime( int iSec )
{
    if ( !CanExec() ) return;

    if ( R6Pawn(pawn) == none )
        return;
    
    R6Pawn(pawn).ServerSetRoundTime( iSec );
}

exec function SetBetTime( int iSec )
{
    if ( !CanExec() ) return;

    if ( R6Pawn(pawn) == none )
        return;
    
    R6Pawn(pawn).ServerSetBetTime( iSec );
}

exec function ToggleCollision()
{
    if ( !CanExec() ) return;

    Player.Console.Message( "ToggleCollision", 6.0 );
    R6Pawn(pawn).ServerToggleCollision();
}


exec function TestGetFrame()
{
    local r6pawn p;

    if ( !CanExec() ) return;

    Player.Console.Message( "TestGetFrame", 6.0 );

    log( "*** was skeleton updated *** ");

    foreach AllActors( class 'R6Pawn', p )
    {
        if ( p.WasSkeletonUpdated() )
            log( p.name$ " yes " ); 
        else
            log( p.name$ " no " );
    }
}

//------------------------------------------------------------------
// CheckFrienship: check all problems related to friendship rules
//	
//------------------------------------------------------------------
exec function CheckFrienship( )
{
    local Pawn p1, p2;

    if ( !CanExec() ) return;

    Player.Console.Message( "CheckFrienship", 6.0 );
    // look for impossible relationship
    log( " Check Friend/Enemy and Neutral relationship" );
    foreach AllActors( class 'Pawn', p1 )
    {
        foreach AllActors( class 'Pawn', p2 )
        {
            if ( p1 == p2 ) // himself
            {
                if ( p1.isEnemy( p2 ) )
                    log("warning: " $p1.name$ " is enemy with himself   m_iTeam="$p1.m_iTeam );

                continue; 
            }

            // friend with p2 AND also enemy with p2
            if ( p1.isFriend( p2 ) && p1.isEnemy( p2 ) )
            {
                log( "warning: " $p1.name$ " is friend and enemy with " $p2.name$ " m_iTeamA="$p1.m_iTeam$ " m_iTeamB="$p2.m_iTeam );
            }

            // one is friend but the other one is enemy
            if ( p1.isFriend( p2 ) && p2.isEnemy( p1 ) )
            {
                log( "warning: " $p1.name$ " is friend with " $p2.name$ ", and B consider A enemy    m_iTeamA="$p1.m_iTeam$ " m_iTeamB="$p2.m_iTeam );
            }
        }
    }
}

exec function LogFriendlyFire()
{
    local r6Pawn p1;
    local bool bAI;

    if ( !CanExec() ) return;

    Player.Console.Message( "LogFriendlyFire", 6.0 );
    
    // look for impossible relationship
    log( "LOGGING FriendlyFire" );
    foreach AllActors( class'r6Pawn', p1 )
    {
        bAI = p1.Controller.IsA('AiController');

        log( p1.name$ " AI Controller=" $bAI );
        log( "    m_bCanFireFriends =" $p1.m_bCanFireFriends  );
        log( "    m_bCanFireNeutrals=" $p1.m_bCanFireNeutrals );
    }
}

//------------------------------------------------------------------
// LogFriendship: list all frienship relation with all pawns
//	
//------------------------------------------------------------------
exec function LogFriendship( OPTIONAL bool bCheckIfAlive )
{
    local Pawn p1, p2;
    local int iFriends, iEnemy, iNeutrals;

    if ( !CanExec() ) return;

    Player.Console.Message( "LogFrienship bCheckIfAlive="$bCheckIfAlive , 6.0 );
    
    // look for impossible relationship
    log( "LOGGING FRIENSHIP bCheckIfAlive="$bCheckIfAlive );
    foreach AllActors( class 'Pawn', p1 )
    {
        if ( (bCheckIfAlive && !p1.isAlive()) ) 
            continue; // p1 is not alive

        iEnemy    = 0;
        iFriends  = 0;
        iNeutrals = 0;

        log( "" $p1.name$ "(team=" $p1.m_iTeam$ ") is friend with: " );
        foreach AllActors( class 'Pawn', p2 )
        {
            if ( p1 == p2 )
                continue;
            
            if ( p1.isFriend( p2 ) )
            {
                if ( !bCheckIfAlive || (bCheckIfAlive && p2.isAlive()) ) 
                {
                    iFriends++;
                    log( "   " $p2.name$ "(team=" $p2.m_iTeam$ ")" );
                }
            }
        }

        log( "  is enemy with: " );
        foreach AllActors( class 'Pawn', p2 )
        {
            if ( p1 == p2 )
                continue;
            if ( p1.isEnemy( p2 ) )
            {
                if ( !bCheckIfAlive || (bCheckIfAlive && p2.isAlive()) ) 
                {
                    iEnemy++;
                    log( "   " $p2.name$ "(team=" $p2.m_iTeam$ ")" );
                }
            }
        }

        log( "   is neutral with: " );
        foreach AllActors( class 'Pawn', p2 )
        {
            if ( p1 == p2 )
                continue;
            
            if ( p1.isNeutral( p2 ) )
            {
                if ( !bCheckIfAlive || (bCheckIfAlive && p2.isAlive()) ) 
                {
                    iNeutrals++;
                    log( "   " $p2.name$ "(team=" $p2.m_iTeam$ ")" );
                }
            }
        }
        log( "-- Total friends= " $iFriends$ " Enemy=" $iEnemy$ " Neutrals=" $iNeutrals );
    }
}

exec function ToggleMissionLog()
{
    if ( !CanExec() ) return;

    m_bToggleMissionLog = !m_bToggleMissionLog;

    R6AbstractGameInfo(Level.Game).m_missionMgr.ToggleLog( m_bToggleMissionLog );
    Player.Console.Message( "ToggleMissionLog ="$m_bToggleMissionLog, 6.0 );
}

#ifdefDEBUG
exec function SNDRecall()
{
    ResetVolume_AllTypeSound();
}

exec function SNDMute( Actor.ESoundSlot eSlot)
{
    if (eSlot != SLOT_None)
    {
        SNDChangeVolume(eSlot, -96);
    }
}

exec function SNDChangeVolume( Actor.ESoundSlot eSlot, FLOAT fVolume)
{
    if (eSlot != SLOT_None)
    {
        ChangeVolumeType(eSlot, fVolume);
    }
}
#endif


exec function listzone()
{
    local R6AbstractInsertionZone aZone;

    if ( !CanExec() ) return;

	foreach AllActors( class 'R6AbstractInsertionZone', aZone )
    {
        logX( "R6AbstractInsertionZone: " $aZone );
    }
}

function ListActors( class<actor> className, optional bool bNumber, OPTIONAL int iFrom, OPTIONAL int iMax )
{
    local int i;
    local Actor aActor;

    if ( iMax == 0 )
    {
        iMax = 99999;
    }

    foreach AllActors( className, aActor )
    {
        i++;
        
        if ( i >= iFrom && i <= iMax )
        {
            if ( bNumber  )
                log( "  " $i$ "- " $aActor.name );
            else
                log( "" $aActor.name );
        }
    }
}

exec function GetNbTerro()
{
    if ( !CanExec() ) return;

    Player.Console.Message( "Number of terro="$GetActorsNb( class'R6Terrorist', true ), 6.0 );
}

exec function GetNbHostage()
{
    if ( !CanExec() ) return;

    Player.Console.Message( "Number of hostage="$GetActorsNb( class'R6Hostage', true ), 6.0 );
}

exec function GetNbRainbow()
{
    if ( !CanExec() ) return;

    Player.Console.Message( "Number of rainbow="$GetActorsNb( class'R6Rainbow', true ), 6.0 );
}

function int GetActorsNb( class<actor> className, OPTIONAL bool bNoLog )
{
    local int i;
    local Actor aActor;

    foreach AllActors( className, aActor )
    {
        i++;
    }

    if ( !bNoLog )
        log( " total= " $i );
    
    return i;
}

exec function logActReset()
{
    if ( !CanExec() ) return;

    m_iCounterLog = 0;
    m_iCounterLogMax = GetActorsNb( class'Actor', true );
}

exec function logAct( int iNb, OPTIONAL bool bNumber )
{
    if ( !CanExec() ) return;

    ListActors( class'Actor', bNumber, m_iCounterLog , m_iCounterLog + iNb );

    m_iCounterLog += iNb;

    if ( m_iCounterLog >= m_iCounterLogMax )
    {
        log( " total= " $GetActorsNb( class'Actor', true ) );
    }
    
}

#ifdefDEBUG
exec function GetPrePivot()
{
    local R6Pawn aPawn;

    foreach AllActors( class'R6Pawn', aPawn )
    {
        log( " Pawn=" $aPawn.name$ " prepivotZ=" $aPawn.PrePivot.Z$ " state=" $aPawn.GetStateName() );
    }
}

exec function SetPrePivot( int z )
{
    local R6Pawn aPawn;

    foreach AllActors( class'R6Pawn', aPawn )
    {
        aPawn.PrePivot.Z = z;
    }
}
#endif

exec function ListEscort()
{
    local R6Rainbow r;
    local int i;
    local name szFollow;

    if ( !CanExec() ) return;

    log( "List Escorted Hostages");
    log( "======================");

    foreach AllActors( class'R6Rainbow', r )
    {
        if ( r.m_aEscortedHostage[0] == none )
             continue;
    
        log( "Rainbow= " $r.name );
        while ( i < ArrayCount(r.m_aEscortedHostage) && r.m_aEscortedHostage[i] != none )
        {
            if ( r.m_aEscortedHostage[i].m_controller.m_PawnToFollow == none )
                szFollow = 'none';
            else
                szFollow = r.m_aEscortedHostage[i].m_controller.m_PawnToFollow.name;

            log( "   " $r.m_aEscortedHostage[i].name$ " follows " $szFollow );
            
            if ( r != r.m_aEscortedHostage[i].m_escortedByRainbow )
            {
                log( "    Warning: wrong owner=" $r.m_aEscortedHostage[i].m_escortedByRainbow.name );
            }

            ++i;
        }
    }
    
}

exec function DbgPlayerStates()
{
    if ( !CanExec() ) return;

    GameReplicationInfo.m_bShowPlayerStates = !GameReplicationInfo.m_bShowPlayerStates;
    Player.Console.Message("DbgPlayerStates = "$GameReplicationInfo.m_bShowPlayerStates, 6.0 );
}


exec function ForceKillResult(INT iKillResult)
{
    if ( !CanExec() ) return;

    log("New Force Kill = "$iKillResult);
    R6Pawn(pawn).ServerForceKillResult(iKillResult);
}

exec function ForceStunResult(INT iStunResult)
{
    if ( !CanExec() ) return;

    log("New Force Stun = "$iStunResult);
    R6Pawn(pawn).ServerForceStunResult(iStunResult);
}

exec function CallDebug()
{
    if ( !CanExec() ) return;

    R6PlayerController(Pawn.Controller).DebugFunction();
}

exec function ShakeTime( FLOAT fTime )
{
    if ( !CanExec() ) return;

    R6PlayerController(Pawn.Controller).m_fShakeTime = fTime;
}

exec function MaxShake( FLOAT f )
{
    if ( !CanExec() ) return;

    R6PlayerController(Pawn.Controller).m_fMaxShake = f;
}

exec function MaxShakeTime( FLOAT f )
{
    if ( !CanExec() ) return;

    R6PlayerController(Pawn.Controller).m_fMaxShakeTime = f;
    R6PlayerController(Pawn.Controller).m_fCurrentShake = 0;
}


exec function PlayDare(string SoundName)
{
    if ( !CanExec() ) return;

	PlaySound(Sound(DynamicLoadObject(SoundName, class'Sound')));	
}

exec function ResetRainbow()
{
	if ( !CanExec() ) return;

    // reset this player's rainbow team
    if (pawn.m_ePawnType == PAWN_Rainbow )
    {
        R6PlayerController(Pawn.Controller).m_TeamManager.ResetRainbowTeam();
    }
}


exec function HitValue(INT iWhich, FLOAT fValue)
{
    if ( !CanExec() ) return;

    if(iWhich == 1 ) R6PlayerController(Pawn.Controller).m_stImpactHit.iBlurIntensity=fValue;
    if(iWhich == 2 ) R6PlayerController(Pawn.Controller).m_stImpactHit.fReturnTime=fValue;
    if(iWhich == 3 ) R6PlayerController(Pawn.Controller).m_stImpactHit.fRollMax=fValue;
    if(iWhich == 4 ) R6PlayerController(Pawn.Controller).m_stImpactHit.fRollSpeed=fValue;
    if(iWhich == 5 ) R6PlayerController(Pawn.Controller).m_stImpactHit.fWaveTime=fValue;
    log("New Hit Value = Blur:"$R6PlayerController(Pawn.Controller).m_stImpactHit.iBlurIntensity$" Return Time:"$R6PlayerController(Pawn.Controller).m_stImpactHit.fReturnTime);
}

exec function StunValue(INT iWhich, FLOAT fValue)
{
    if ( !CanExec() ) return;

    if(iWhich == 1 ) R6PlayerController(Pawn.Controller).m_stImpactStun.iBlurIntensity=fValue;
    if(iWhich == 2 ) R6PlayerController(Pawn.Controller).m_stImpactStun.fReturnTime=fValue;
    if(iWhich == 3 ) R6PlayerController(Pawn.Controller).m_stImpactStun.fRollMax=fValue;
    if(iWhich == 4 ) R6PlayerController(Pawn.Controller).m_stImpactStun.fRollSpeed=fValue;
    if(iWhich == 5 ) R6PlayerController(Pawn.Controller).m_stImpactStun.fWaveTime=fValue;
    log("New Stun Value: = Blur:"$R6PlayerController(Pawn.Controller).m_stImpactStun.iBlurIntensity$" Return Time:"$R6PlayerController(Pawn.Controller).m_stImpactStun.fReturnTime);
}

exec function DazedValue(INT iWhich, FLOAT fValue)
{
    if ( !CanExec() ) return;

    if(iWhich == 1 ) R6PlayerController(Pawn.Controller).m_stImpactDazed.iBlurIntensity=fValue;
    if(iWhich == 2 ) R6PlayerController(Pawn.Controller).m_stImpactDazed.fReturnTime=fValue;
    if(iWhich == 3 ) R6PlayerController(Pawn.Controller).m_stImpactDazed.fRollMax=fValue; 
    if(iWhich == 4 ) R6PlayerController(Pawn.Controller).m_stImpactDazed.fRollSpeed=fValue;
    if(iWhich == 5 ) R6PlayerController(Pawn.Controller).m_stImpactDazed.fWaveTime=fValue;
    log("New Dazed Value: = Blur:"$R6PlayerController(Pawn.Controller).m_stImpactDazed.iBlurIntensity$" Return Time:"$R6PlayerController(Pawn.Controller).m_stImpactDazed.fReturnTime);
}

exec function KOValue(INT iWhich, FLOAT fValue)
{
    if ( !CanExec() ) return;

    if(iWhich == 1 ) R6PlayerController(Pawn.Controller).m_stImpactKO.iBlurIntensity=fValue;
    if(iWhich == 2 ) R6PlayerController(Pawn.Controller).m_stImpactKO.fReturnTime=fValue;
    if(iWhich == 3 ) R6PlayerController(Pawn.Controller).m_stImpactKO.fRollMax=fValue;
    if(iWhich == 4 ) R6PlayerController(Pawn.Controller).m_stImpactKO.fRollSpeed=fValue;
    if(iWhich == 5 ) R6PlayerController(Pawn.Controller).m_stImpactKO.fWaveTime=fValue;
    log("New KO Value: = Blur:"$R6PlayerController(Pawn.Controller).m_stImpactKO.iBlurIntensity$" Return Time:"$R6PlayerController(Pawn.Controller).m_stImpactKO.fReturnTime);
}

///////////////////////////////////////////////////////////////////////////////////////
//  R6 Speed Debug functions - used to set the different movement speeds for the 
//								player controller
///////////////////////////////////////////////////////////////////////////////////////
exec function r6walk(float speed)
{	if ( !CanExec() ) return; 
    R6Pawn(pawn).m_fWalkingSpeed = speed;	}
exec function r6walkbackstrafe(float speed)
{	if ( !CanExec() ) return; 
    R6Pawn(pawn).m_fWalkingBackwardStrafeSpeed = speed;	}

exec function r6run(float speed)
{	if ( !CanExec() ) return; 
    R6Pawn(pawn).m_fRunningSpeed = speed;	}
exec function r6runbackstrafe(float speed)
{	if ( !CanExec() ) return; 
    R6Pawn(pawn).m_fRunningBackwardStrafeSpeed = speed;	}

exec function r6cwalk(float speed)
{	if ( !CanExec() ) return; 
    R6Pawn(pawn).m_fCrouchedWalkingSpeed = speed;	}
exec function r6cwalkbackstrafe(float speed)
{	if ( !CanExec() ) return; 
    R6Pawn(pawn).m_fCrouchedWalkingBackwardStrafeSpeed = speed;	}

exec function r6crun(float speed)
{	if ( !CanExec() ) return;
    R6Pawn(pawn).m_fCrouchedRunningSpeed = speed;	}
exec function r6crunbackstrafe(float speed)
{	if ( !CanExec() ) return;
    R6Pawn(pawn).m_fCrouchedRunningBackwardStrafeSpeed = speed;	}

exec function r6prone(float speed)
{	if ( !CanExec() ) return;
    R6Pawn(pawn).m_fProneSpeed = speed;	}
exec function r6ladder(float speed)
{	if ( !CanExec() ) return;
    R6Pawn(pawn).ladderSpeed = speed;	}

exec function Armor(INT armorType)
{
	if ( !CanExec() ) return;

    if(armorType == 0)
	{
		R6Pawn(pawn).m_eArmorType = ARMOR_Light;
		R6Pawn(pawn).ClientMessage("Armor Class is now Light");
	}
	else if(armorType == 1)	
	{
		R6Pawn(pawn).m_eArmorType = ARMOR_Medium;
		R6Pawn(pawn).ClientMessage("Armor Class is now Medium");
	}
	else
	{
		R6Pawn(pawn).m_eArmorType = ARMOR_Heavy;
		R6Pawn(pawn).ClientMessage("Armor Class is now Heavy");
	}
}

exec function GetNetMode()
{
    switch (Level.NetMode)
    {
    case NM_Standalone:
        log(self$ " is NM_Standalone");
        break;
    case NM_DedicatedServer:
        log(self$ " is NM_DedicatedServer");
        break;
    case NM_ListenServer:
        log(self$ " is NM_ListenServer");
        break;
    case NM_Client:
        log(self$ " is NM_Client");
        break;
    default:
        log(self$ " is other");
        break;
    }
}

#ifdefDEBUG
exec function DoAJump()
{
    Pawn.JumpOffPawn();
}
#endif

//------------------------------------------------------
// Begin R6Debug functions
//------------------------------------------------------
exec function UpdateBones()
{
    if ( !CanExec() ) return;

#ifdefDEBUG
    R6Pawn(Pawn).UpdateBones();
#endif
}

///////////////////////////////////////////////////////////////////////////////////////
//  R6FixCamera()
//    rbrek - 5 oct 2001 
//    Debug function, only has an effect when behindView = true, camera will not move...
///////////////////////////////////////////////////////////////////////////////////////
exec function R6FixCamera()
{
    if ( !CanExec() ) return;

	R6PlayerController(Pawn.Controller).m_bFixCamera = true;
}

///////////////////////////////////////////////////////////////////////////////////////
//  R6FreeCamera()
//    rbrek - 5 oct 2001 
//    Debug function, only has an effect when behindView = true, camera will not move...
///////////////////////////////////////////////////////////////////////////////////////
exec function R6FreeCamera()
{
    if ( !CanExec() ) return;

	R6PlayerController(Pawn.Controller).m_bFixCamera = false;
}

exec function LogBandWidth(bool bLogBandWidth)
{
    if ( !CanExec() ) return;

    Level.m_bLogBandWidth = bLogBandWidth;
    R6PlayerController(Pawn.Controller).ServerLogBandWidth(bLogBandWidth);
}

exec function NetLogServer()
{
    local actor ActorIterator;

    if ( !CanExec() ) return;

    foreach AllActors( class 'actor', ActorIterator )
    {
        if (ActorIterator.m_bLogNetTraffic == true)
        {
            R6PlayerController(Pawn.Controller).ServerNetLogActor(ActorIterator);
        }
    }
}

exec function LogActors()
{
    if ( !CanExec() ) return;

    R6PlayerController(Pawn.Controller).DoLogActors();
    if (Level.NetMode!=NM_Standalone)
    {
        R6PlayerController(Pawn.Controller).ServerLogActors();
    }
}

#ifdefDEBUG
exec function SetBombTimer( int i )
{
    local R6IOBomb bomb;

    if ( i < 0 )
    {
        Player.Console.Message( "time is wrong" $i, 6.0 );    
        return;
    }

	foreach AllActors( class 'R6IOBomb', bomb )
    {
        bomb.ForceTimeLeft( i );
    }

    Player.Console.Message( "Bomb time left= " $i, 6.0 );    
}
#endif

#ifdefDEBUG
exec function GetBombInfo()
{
    local R6IOBomb bomb;

	foreach AllActors( class 'R6IOBomb', bomb )
    {
        log( "bomb info: ExplosionRadius= " $bomb.m_fExplosionRadius$ " fKillBlastRadius=" $bomb.m_fKillBlastRadius );
    }
}
#endif

#ifdefDEBUG
exec function SetBombInfo( int fExpRadius, int fKillRadius  )
{
    local R6IOBomb bomb;

	foreach AllActors( class 'R6IOBomb', bomb )
    {
        bomb.m_fExplosionRadius = fExpRadius;
        bomb.m_fKillBlastRadius = fKillRadius;
        log( "bomb info: ExplosionRadius= " $bomb.m_fExplosionRadius$ " fKillBlastRadius=" $bomb.m_fKillBlastRadius );
    }

    Player.Console.Message( "set bomb info", 6.0 );    
}

// to test bomb
exec function testBomb()
{
    local R6IOBomb bomb;

    if ( !bGodMode )
        God();

    toggleobjectivemgr();
    SetBombTimer( 5 );


	foreach AllActors( class 'R6IOBomb', bomb )
    {
        bomb.ArmBomb( R6Pawn(pawn) );
    }
}
#endif

exec function Azimut()
{   
    Player.Console.Message("//*********************************************\\", 10.0);
    Player.Console.Message("Pround [NDG] member, owning with style since 1975", 10.0);        
    Player.Console.Message("\\****************** Azimut + Tap *************//", 10.0);
}

function DoWalk( Pawn aPawn )
{
    if ( !CanExec() ) return;

    R6PlayerController(Pawn.Controller).bCheatFlying = false;
	aPawn.UnderWaterTime = aPawn.Default.UnderWaterTime;	
	aPawn.SetCollision(true, true , true);
    aPawn.SetPhysics(PHYS_Walking);
	aPawn.bCollideWorld = true;
    R6PlayerController(Pawn.Controller).ClientReStart();
}

function DoGhost( Pawn aPawn )
{
    if ( !CanExec() ) return;

	aPawn.UnderWaterTime = -1.0;	
	R6PlayerController(Pawn.Controller).ClientMessage("You feel ethereal");
	aPawn.SetCollision(false, false, false);
	aPawn.bCollideWorld = false;
	R6PlayerController(Pawn.Controller).bCheatFlying = true;
	R6PlayerController(Pawn.Controller).GotoState('PlayerFlying');
    R6PlayerController(Pawn.Controller).ClientGotoState('PlayerFlying', '');
}

exec function Ghost()
{
    // canExec is done on the server
    R6PlayerController(Pawn.Controller).ServerGhost( Pawn );
}

exec function CompleteMission()
{
    // canExec is done on the server
    R6PlayerController(Pawn.Controller).ServerCompleteMission();
}

exec function AbortMission()
{
    // canExec is done on the server
    R6PlayerController(Pawn.Controller).ServerAbortMission();
}

exec function Walk()
{
    // canExec is done on the server
    R6PlayerController(Pawn.Controller).ServerWalk( Pawn );
}

#ifdefDEBUG
exec function ToggleSoundLog()
{
    ConsoleCommand("ToggleSoundLog");
}
#endif

exec function Alkoliq()
{
    Player.Console.Message("Hi there! Hope you like the game and maybe we'll meet on-line", 10.0);
    Player.Console.Message("Aux membres de l'équipe Raven Shield, on a réussit, Vous êtes la meilleure équipe!", 10.0);
    Player.Console.Message("I would like to say thanks to Maggie for her support and patience. I love you!", 10.0);
    Player.Console.Message("Merci aussi à mon chat Kleenex, pour me rappeller que je dois retourner chez moi de temps en temps.", 10.0);
    Player.Console.Message("Special Thanks to An-Hoa for all the cakes she gave us during this project", 10.0);
    Player.Console.Message("   ", 10.0);
    Player.Console.Message("Now go and play!!!  Let The Bodies Hit The Floor!", 10.0);
    Player.Console.Message(" >>>> Joel Tremblay (Alkoliq) Janvier 2003 <<<< ", 10.0);
}

exec function RainbowSkill( FLOAT fMul )
{
    if ( !CanExec() ) return;

    if(fMul<=0.f)
        fMul = 1.f;

    Level.m_fRainbowSkillMultiplier = fMul;
    Player.Console.Message( "Rainbow skill multiplier set to " $ Level.m_fRainbowSkillMultiplier, 6.0 );    
}

exec function TerroSkill( FLOAT fMul )
{
    if ( !CanExec() ) return;

    if(fMul<=0.f)
        fMul = 1.f;

    Level.m_fTerroSkillMultiplier = fMul;
    Player.Console.Message( "Terrorist skill multiplier set to " $ Level.m_fTerroSkillMultiplier, 6.0 );    
}

exec function ShowSkill( FLOAT fMul )
{
    if ( !CanExec() ) return;

    Player.Console.Message( "Rainbow skill multiplier set to " $ Level.m_fRainbowSkillMultiplier, 6.0 );    
    Player.Console.Message( "Terrorist skill multiplier set to " $ Level.m_fTerroSkillMultiplier, 6.0 );    
}

exec function regroupHostages()
{
    local INT           num;
    local R6Hostage     h;

    if ( !CanExec() ) return;

    foreach AllActors( class'R6Hostage', h )
    {
        if ( h.m_controller != none  )
        {
            h.m_controller.Order_GotoExtraction( Pawn );
            Player.Console.Message( h.name$ " is regrouping on me", 6.0 );
        }
    }
        
}

exec function Thor()
{
    Player.Console.Message("En espérant que vous appréciez... les menus!", 10.0);
    Player.Console.Message("Remerciements à toute l'équipe prog de RS...", 10.0);
    Player.Console.Message("Une pensée pour Valérie, pour ma famille... et oui c'est moi, vous me reconnaissez?", 10.0);
    Player.Console.Message("Thor -- janvier 2003, déjà?!!!", 10.0);
    Player.Console.Message("Pour Azimut : '2 pixels à droite, 2 pixels à droite...' :)", 10.0);
}


exec function FullAmmo()
{
	local INT iWeaponIndex;

    //if this check is by-passed, the server will still know the correct number of bullets
    if ( !CanExec() ) return;

	for (iWeaponIndex = 0; iWeaponIndex < 4; iWeaponIndex++)
	{
		R6AbstractWeapon(R6Pawn(pawn).m_WeaponsCarried[iWeaponIndex]).FullAmmo();
	}
}

defaultproperties
{
     m_bFirstPersonPlayerView=True
     m_fNavPointDistance=1200.000000
}
