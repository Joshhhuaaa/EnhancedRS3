//============================================================================//
// R6HUD.uc : Rainbow 6 HUD Base Class
// Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//    2001/09/11 * Modified by Lysanne Martin
//    2002/01/07 * Modified by Sebastien Lussier			
//============================================================================//
class R6Hud extends R6AbstractHUD
    Config(User)
	native;

#exec OBJ LOAD FILE=..\Textures\Inventory_t.utx
#exec OBJ LOAD FILE=..\Textures\R6HUD.utx PACKAGE=R6HUD

var     R6GameReplicationInfo	m_GameRepInfo;
var     R6PlayerController      m_PlayerOwner;

var     Texture                 m_FlashbangFlash;
var     Texture                 m_TexNightVision;
var     Texture                 m_TexHeatVision;
var     Material                m_TexHeatVisionActor;
var     Material                m_TexHUDElements;
var     Material				m_pCurrentMaterial;
var     Texture                 m_HeartBeatMaskMul;
var     Texture                 m_HeartBeatMaskAdd;
var     Texture                 m_Waypoint;
var     Texture                 m_WaypointArrow;

var     Texture                 m_InGamePlanningPawnIcon;

var     Texture                 m_LoadingScreen;

var     Texture                 m_TexNoise;

var     Material                m_TexProneTrail;

var     Color                   m_iCurrentTeamColor;
 
var		FLOAT			        m_fPosX;
var		FLOAT			        m_fPosY;
var     FLOAT                   m_fScaleX;
var     FLOAT                   m_fScaleY;

// Current Weapon Info
var     INT                     m_iBulletCount;
var     INT                     m_iMaxBulletCount;
var     INT                     m_iMagCount;
var     INT                     m_iCurrentMag;

// game stats
var(Debug) bool                 m_bDrawHUDinScript;

// Game Mode HUD Filters
var     bool                    m_bGMIsSinglePlayer;
var     bool                    m_bGMIsCoop;
var     bool                    m_bGMIsTeamAdverserial;

// User HUD Filters  
var     bool                    m_bShowCharacterInfo;
var     bool                    m_bShowCurrentTeamInfo;
var     bool                    m_bShowOtherTeamInfo;
var     bool                    m_bShowWeaponInfo;
var     bool                    m_bShowFPWeapon;
var     bool                    m_bShowWaypointInfo;
var     bool                    m_bShowActionIcon;
var     bool                    m_bShowMPRadar;
var     bool                    m_bShowTeamMatesNames;

var     bool                    m_bUpdateHUDInTraining; // For training, update only once

var FinalBlend					m_pAlphaBlend;
var FLOAT						m_fScale;

var Actor                       m_pNextWayPoint;

//R6RADAR
var     Material                m_TexRadarTextures[10];

// Training Box Color

// Upper Left
var Color m_CharacterInfoBoxColor;
var Color m_CharacterInfoOutlineColor;
                    

// Lower Left
var Color m_WeaponBoxColor;
var Color m_WeaponOutlineColor;

// Upper Right
var Color m_TeamBoxColor;
var Color m_TeamBoxOutlineColor;

// Lower Right;
var Color m_OtherTeamBoxColor;
var Color m_OtherTeamOutlineColor;

// Other
var Color m_WPIconBox;
var Color m_WPIconOutlineColor;


var R6HUDState m_HUDElements[16];

var Array<R6IOBomb> m_aIOBombs;
var bool            m_bDisplayTimeBomb;
var bool            m_bDisplayRemainingTime;
var bool            m_bNoDeathCamera;

var R6RainbowTeam               m_pLastRainbowTeam;
var BOOL                        m_bLastSniperHold;
var EMovementMode               m_eLastMovementMode;
var string                      m_szMovementMode;
var R6RainbowTeam.eTeamState    m_eLastTeamState;
var string                      m_szTeamState;

var R6RainbowTeam.eTeamState    m_eLastOtherTeamState[2];
var string                      m_szOtherTeamState[2];
var string                      m_aszOtherTeamName[2];
var EPlanAction                 m_eLastPlayerAPAction;
var string                      m_szLastPlayerAPAction;
var string                      m_szPressGoCode; 
var EGoCode                     m_eLastGoCode;
var     bool                    m_bShowPressGoCode;
var     bool                    m_bPressGoCodeCanBlink;
var string                      m_szTeam;

native(1605) final function DrawNativeHUD(Canvas C);
native(1609) final function HudStep(INT iBox, INT iIDStep, optional BOOL bFlash);


//===========================================================================//
// PostBeginPlay()                                                           //
//===========================================================================//
function PostBeginPlay()
{
    Super.PostBeginPlay();
    
    if( Owner == None )
       return;

    m_PlayerOwner = R6PlayerController(Owner);
    
    if ( Level.NetMode == NM_Standalone )
        m_bDisplayRemainingTime = false;

    m_bUpdateHUDInTraining = true;
    SetTimer(0.25, true);
    
    StopFadeToBlack();
}

simulated function ResetOriginalData()
{
    Super.ResetOriginalData();

    m_iCycleHUDLayer = default.m_iCycleHUDLayer;
    m_bToggleHelmet = default.m_bToggleHelmet;

    m_bNoDeathCamera = false;
    m_pLastRainbowTeam = none;

    if ( m_bDisplayTimeBomb )
        InitBombTimer( m_bDisplayTimeBomb );

    StopFadeToBlack();
}

//------------------------------------------------------------------
// FUCKING WORKAROUND FOR THE GAME TYPE
//	
//------------------------------------------------------------------
function Timer()
{
    if (Level != none &&
        m_PlayerOwner != none &&
        m_PlayerOwner.GameReplicationInfo != none &&
        m_PlayerOwner.GameReplicationInfo.m_bReceivedGameType == 1 )
    {
        m_GameRepInfo = R6GameReplicationInfo(m_PlayerOwner.GameReplicationInfo);
        m_PlayerOwner.HidePlanningActors( );
        UpdateHudFilter();

        SetTimer(0, false);
    }
}


simulated function InitBombTimer( bool bDisplayTimeBomb )
{
    local R6IOBomb ioBomb;

    m_bDisplayTimeBomb = bDisplayTimeBomb;
    m_aIOBombs.Remove( 0, m_aIOBombs.length );

    // use for disarm bomb
    if ( m_bDisplayTimeBomb )
    {
        foreach AllActors( class'R6IOBomb', ioBomb )
        {
            m_aIOBombs[m_aIOBombs.length] = ioBomb;
        }
    }
}

function UpdateHudFilter()
{ 
    local R6GameOptions GameOptions;
    local INT           iStepCount;
    local BOOL          bDisplayFPWeapon;

    GameOptions = GetGameOptions();	
    m_bGMIsSinglePlayer = true;

    bDisplayFPWeapon = GameOptions.HUDShowFPWeapon;

    if (Level.IsGameTypeMultiplayer(m_PlayerOwner.GameReplicationInfo.m_szGameTypeFlagRep))
    {
        m_bGMIsSinglePlayer = false;
        bDisplayFPWeapon = bDisplayFPWeapon || R6GameReplicationInfo(m_PlayerOwner.GameReplicationInfo).m_bFFPWeapon;
    }

    m_bGMIsCoop = Level.IsGameTypeCooperative(m_PlayerOwner.GameReplicationInfo.m_szGameTypeFlagRep);
    m_bGMIsTeamAdverserial = Level.IsGameTypeTeamAdversarial(m_PlayerOwner.GameReplicationInfo.m_szGameTypeFlagRep);

    if ( Level.Game == none || // client
        (Level.Game != none && R6GameInfo(Level.Game).GetTrainingMgr(R6Pawn(m_PlayerOwner.Pawn)) == None)) // Training?
    {
        // Priority goes to the Game Mode restrictions
        m_bShowCharacterInfo = GameOptions.HUDShowCharacterInfo;
        m_bShowCurrentTeamInfo = (m_bGMIsSinglePlayer || m_bGMIsCoop) && GameOptions.HUDShowCurrentTeamInfo;
        m_bShowOtherTeamInfo = m_bGMIsSinglePlayer && GameOptions.HUDShowOtherTeamInfo;
        m_bShowWeaponInfo = GameOptions.HUDShowWeaponInfo;
        m_bShowWaypointInfo = m_bGMIsSinglePlayer && GameOptions.HUDShowWaypointInfo;
        m_PlayerOwner.Set1stWeaponDisplay(bDisplayFPWeapon);
        m_bShowActionIcon = GameOptions.HUDShowActionIcon;

        if ( m_GameRepInfo.m_iDiffLevel == 1 && Level.Game != none ) // rookie / recruit
        {
            // special hard coded case: we only want to have this feature in story mode / practice mode
            // and when in recruit 
            if ( Level.Game.m_szGameTypeFlag == "RGM_PracticeMode" || Level.Game.m_szGameTypeFlag == "RGM_StoryMode" )
            {
                m_bShowPressGoCode     = true;
                m_bPressGoCodeCanBlink = false;
            }
        }
    }
    else
    {
        m_bShowPressGoCode     = true;
        m_bPressGoCodeCanBlink = true;

        if (m_bUpdateHUDInTraining)
        {
            // force the training element
            m_bShowCharacterInfo = true;
            m_bShowCurrentTeamInfo = true;
            m_bShowOtherTeamInfo = true;
            m_bShowWeaponInfo = true;
            m_bShowWaypointInfo = true;
            m_PlayerOwner.Set1stWeaponDisplay(true);    
            m_PlayerOwner.m_bHideReticule = false;
            m_bShowActionIcon = true;
            m_bUpdateHUDInTraining = true;
        }
    }
    
    // Set autoaim
    if( Level.NetMode == NM_Standalone )
        m_PlayerOwner.m_wAutoAim = GameOptions.AutoTargetSlider;
    else
        m_PlayerOwner.m_wAutoAim = 0;

    if ( Level.IsGameTypeDisplayBombTimer(m_PlayerOwner.GameReplicationInfo.m_szGameTypeFlagRep) )
    {
        InitBombTimer( true );
    }
}

//===========================================================================//
// Tick()                                                                    //
//===========================================================================//
simulated function Tick( float fDelta )
{
    Super.Tick(fDelta);
    
    m_PlayerOwner = R6PlayerController(Owner);	
	if( m_PlayerOwner == none || m_PlayerOwner.GameReplicationInfo == none )
        return;

    // spectator need the gameRepInfo
    m_GameRepInfo = R6GameReplicationInfo(m_PlayerOwner.GameReplicationInfo);

}


//===========================================================================//
// PostRender()                                                              //
//  Render HUD and call post render on the player controller                 //
//===========================================================================//
simulated event PostRender( Canvas C )
{
	if (m_bDrawHUDinScript)
	{
        C.UseVirtualSize(true);
    
        Super.PostRender( C );

        if( m_PlayerOwner!= none )
            m_PlayerOwner.PostRender( C );

        C.UseVirtualSize(false);
    }
    else
    {
        Super.PostRender( C );
        if( m_PlayerOwner!= none )
            m_PlayerOwner.PostRender( C );
    }
}

//===========================================================================//
// DrawHUD()                                                                 //
//===========================================================================//
function DrawHUD( Canvas C )
{
	local vector viewLocation;	
	local rotator viewRotation;	
	local INT flashBangCoefficient;
    local R6Pawn aPlayerPawn;
 
    if(Level.m_bInGamePlanningActive == true)
        return;

    if( m_PlayerOwner != none)
        aPlayerPawn = R6Pawn(m_PlayerOwner.Pawn);

    // Set the next Waypoint and Milestone.  This is needed to display it in the native code.
    if( m_PlayerOwner != none && m_PlayerOwner.m_TeamManager != none )
    {
        if (R6PlanningInfo( m_PlayerOwner.m_TeamManager.m_TeamPlanning ) != none)
        {
            m_pNextWayPoint = R6PlanningInfo( m_PlayerOwner.m_TeamManager.m_TeamPlanning).GetNextActionPoint();
        }
    }

    DrawNativeHUD(C);

    if (m_PlayerOwner!=none)
    {   
        if (m_PlayerOwner.m_InteractionCA != None)
            m_PlayerOwner.m_InteractionCA.m_Color = m_iCurrentTeamColor;

        if (m_PlayerOwner.m_InteractionInventory != None)
            m_PlayerOwner.m_InteractionInventory.m_Color = m_iCurrentTeamColor;
    }


    if ( m_bDisplayTimeBomb )
    {
        DisplayBombTimer( C );
    }
}

simulated event PostFadeRender( canvas Canvas )
{
    if ( m_bDisplayRemainingTime )
    {
        DisplayRemainingTime( Canvas );
    }

    if ( m_bNoDeathCamera )
    {
        DisplayNoDeathCamera( Canvas );
    }
}


function ActivateNoDeathCameraMsg( bool bToggleOn  )
{
    m_bNoDeathCamera = bToggleOn;
}

function DisplayNoDeathCamera( Canvas C  )
{
    local string    szText;
    local float     w, h, f;
 
    if ( Level.NetMode == NM_Standalone )
        return;

    if ( m_GameRepInfo == none || m_PlayerOwner == none  )
        return;

    if ( m_GameRepInfo.m_eCurrectServerState != m_GameRepInfo.RSS_InGameState )
        return;
    
    // another menu is shown
    if ( m_GameRepInfo.m_menuCommunication != none && !m_GameRepInfo.m_menuCommunication.isInGame() )
        return;

    C.UseVirtualSize(true, 640, 480);

    C.Style = ERenderStyle.STY_Alpha;
    C.Font = m_FontRainbow6_17pt;    
    C.SetDrawColor(255,255,255);    // white
    
    szText = Localize("Game", "NoDeathCamera", "R6GameInfo" );
    C.TextSize( szText, w, h  );

    f = (640 - w)/2;
    if ( f < 0 )
        f = 0;

    C.SetClip(640, 480);
    C.SetOrigin(0, 0);
    C.SetPos( f, 220 );
    C.DrawText( szText );

    C.UseVirtualSize( false );
}

//------------------------------------------------------------------
// DisplayRemainingTime
//	
//------------------------------------------------------------------
function DisplayRemainingTime( Canvas C )
{
	local FLOAT fBkpOrigX, fBkpOrigY;
    local float fPosX, fPosY, w, h;
    local float fDefaultNamePosX;
    local string szTime;

    if ( m_GameRepInfo == none || m_PlayerOwner == none  )
        return;

    // not in game, not in spectator 
    if ( !m_PlayerOwner.bOnlySpectator || 
          m_GameRepInfo.m_eCurrectServerState != m_GameRepInfo.RSS_InGameState ||
          m_GameRepInfo.m_bInPostBetweenRoundTime )
        return;

    // another menu is shown
    if ( m_GameRepInfo.m_menuCommunication != none && !m_GameRepInfo.m_menuCommunication.isInGame() )
        return;

	fBkpOrigX = C.OrgX;
	fBkpOrigY = C.OrgY;

	C.OrgX = 0;
	C.OrgY = 0;

	C.UseVirtualSize(true, 640, 480);

    fDefaultNamePosX = 600;
    fPosY = 394;

    C.Style = ERenderStyle.STY_Alpha;
    C.Font = m_FontRainbow6_14pt;    
    C.SetDrawColor(255,255,255);    // white
    
    szTime = Localize("MPInGame","Round","R6Menu")$ " "; 
    C.TextSize( szTime, w, h  );
    C.SetPos( fDefaultNamePosX - w, fPosY );
    C.DrawText( szTime );
    
    
    C.SetPos( fDefaultNamePosX, fPosY );
    C.DrawText( ConvertIntTimeToString( int(m_GameRepInfo.GetRoundTime()), true ) );

    C.UseVirtualSize(false);

	C.SetOrigin( fBkpOrigX, fBkpOrigY);
}

//------------------------------------------------------------------
// 
//	
//------------------------------------------------------------------
function DisplayBombTimer( Canvas C )
{
    local int   i, j;
    local float fPosX, fPosY, fPosYDelta, w, h;
    local float fDefaultNamePosX;
    local string szTime, szBomb;
    local R6IOBomb pBomb;
    
	C.UseVirtualSize(true, 640, 480);

    fDefaultNamePosX = 600;
    fPosYDelta = 16;
    fPosY = 380;

    C.Style = ERenderStyle.STY_Alpha;
    C.Font = m_FontRainbow6_14pt;    

    // sort the bomb in order of time left (if more than 1 element)
    i = 0;
    while ( i < m_aIOBombs.length - 1 )
    {
        if ( m_aIOBombs[i].m_bIsActivated )
        {
            j = 0;
            while ( j < m_aIOBombs.length )
            {
                if ( m_aIOBombs[j].m_bIsActivated && 
                     m_aIOBombs[j].GetTimeLeft() < m_aIOBombs[i].GetTimeLeft() )
                {
                    // swap element
                    pBomb         = m_aIOBombs[i];
                    m_aIOBombs[i] = m_aIOBombs[j];
                    m_aIOBombs[j] = pBomb;
                }
                ++j;
            }
        }
        ++i;
    }   

    // draw fromt bottom of the screen to top
    i = m_aIOBombs.length - 1;
    while ( i >= 0  )
    {
        if ( m_aIOBombs[i].m_bIsActivated )
        {
            if ( m_aIOBombs[i].GetTimeLeft() > 20 )
                C.SetDrawColor(255,255,255);    // white
            else if ( m_aIOBombs[i].GetTimeLeft() > 10 )
                C.SetDrawColor(255,255,0);      // yellow
            else
                C.SetDrawColor(255,0,0);        // red

            szBomb = m_aIOBombs[i].m_szIdentity$ " ";
            C.TextSize( szBomb, w, h  );
            C.SetPos( fDefaultNamePosX - w, fPosY );
            C.DrawText( szBomb );
            C.SetPos( fDefaultNamePosX, fPosY );
            
            C.DrawText( ConvertIntTimeToString( m_aIOBombs[i].GetTimeLeft(), true ) );
            fPosY -= fPosYDelta;
        }

        --i;
    }
    C.UseVirtualSize(false);
}

//------------------------------------------------------------------
// StartFadeToBlack
//	
//------------------------------------------------------------------
function StartFadeToBlack( int iSec, int iPercentageOfBlack )
{
    local Canvas C;
    local int iBlack;
    local float fAlpha;

    C = class'Actor'.static.GetCanvas();

    if(C.m_bFading)
    {
        fAlpha = C.m_fFadeCurrentTime / C.m_fFadeTotalTime;
        fAlpha = Clamp(fAlpha, 0.0f, 1.0f);
        C.m_FadeStartColor.R = C.m_FadeEndColor.R * fAlpha + C.m_FadeStartColor.R * (1.0f - fAlpha);
        C.m_FadeStartColor.G = C.m_FadeEndColor.G * fAlpha + C.m_FadeStartColor.G * (1.0f - fAlpha);
        C.m_FadeStartColor.B = C.m_FadeEndColor.B * fAlpha + C.m_FadeStartColor.B * (1.0f - fAlpha);
    }
    else
    {
        C.m_FadeStartColor = C.MakeColor(255,255,255);
    }

    iBlack               = 255 * (100-iPercentageOfBlack) / 100;
    C.m_bFading          = true;
    C.m_fFadeCurrentTime = 0.0f;
    C.m_fFadeTotalTime   = iSec;
    C.m_FadeEndColor     = C.MakeColor(iBlack,iBlack,iBlack);
    C.m_bFadeAutoStop    = false;
}

//------------------------------------------------------------------
// StopFadeToBlack
//	
//------------------------------------------------------------------
function StopFadeToBlack()
{
    local Canvas C;

    C = class'Actor'.static.GetCanvas();
	C.m_bFading = true;
    C.m_fFadeCurrentTime = 0.0f;
    C.m_fFadeTotalTime = 0;
    C.m_FadeStartColor = C.MakeColor(0,0,0);
    C.m_FadeEndColor = C.MakeColor(255,255,255);
    C.m_bFadeAutoStop = true;
}



//===========================================================================//
// Message()                                                                 //
//  Parse recieved msg - inherited                                           //
//===========================================================================//
simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name MsgType )
{
    // exception for console say and console teamsay, remove temp
    if ( MsgType == 'Console' &&
         ("SAY"     == caps(left(Msg, Len("Say"))) ||
          "TEAMSAY" == caps(left(Msg, Len("TeamSay"))) ))
    {
        return;
    }

    super.Message( PRI, Msg, MsgType );
}


//===========================================================================//
// DisplayMessages()                                                         //
//  Inherited                                                                //
//===========================================================================//
simulated function DisplayMessages( Canvas C )
{
    C.SetDrawColor(m_iCurrentTeamColor.R, m_iCurrentTeamColor.G, m_iCurrentTeamColor.B, m_iCurrentTeamColor.A);
    C.Style = ERenderStyle.STY_Alpha;
    C.Font = m_FontRainbow6_14pt;    
    Super.DisplayMessages( C );
}


//===========================================================================//
// SetDefaultFontSettings()                                                  //
//===========================================================================//
function SetDefaultFontSettings( Canvas C )
{
    C.SetDrawColor(m_iCurrentTeamColor.R, m_iCurrentTeamColor.G, m_iCurrentTeamColor.B, m_iCurrentTeamColor.A);
    C.Style = ERenderStyle.STY_Alpha;
    C.Font = m_FontRainbow6_22pt;
}

defaultproperties
{
     m_bDisplayRemainingTime=True
     m_FlashbangFlash=Texture'Inventory_t.Flash.Flash'
     m_TexNightVision=Texture'Inventory_t.NightVision.NightVisionTex'
     m_TexHeatVision=Texture'Inventory_t.HeatVision.HeatVision'
     m_TexHeatVisionActor=FinalBlend'Inventory_t.HeatVision.HeatVisionActorMat'
     m_TexHUDElements=Texture'R6HUD.HUDElements'
     m_HeartBeatMaskMul=Texture'Inventory_t.HeartBeat.HeartBeatMaskMul'
     m_HeartBeatMaskAdd=Texture'Inventory_t.HeartBeat.HeartBeatMaskAdd'
     m_Waypoint=Texture'R6HUD.WayPoint'
     m_WaypointArrow=Texture'R6HUD.WayPointArrow'
     m_InGamePlanningPawnIcon=Texture'R6Planning.InGamePlanning.PawnIcon'
     m_TexNoise=Texture'Inventory_t.Misc.Noise'
     m_TexRadarTextures(0)=Texture'Inventory_t.Radar.RadarBack'
     m_TexRadarTextures(1)=Texture'Inventory_t.Radar.RadarTop'
     m_TexRadarTextures(2)=Texture'Inventory_t.Radar.RadarOutline'
     m_TexRadarTextures(3)=Texture'Inventory_t.Radar.RadarDead'
     m_TexRadarTextures(4)=Texture'Inventory_t.Radar.RadarSameFloor'
     m_TexRadarTextures(5)=Texture'Inventory_t.Radar.RadarHigherFloor'
     m_TexRadarTextures(6)=Texture'Inventory_t.Radar.RadarLowerFloor'
     m_TexRadarTextures(7)=Texture'Inventory_t.Radar.RadarPilotSameFloor'
     m_TexRadarTextures(8)=Texture'Inventory_t.Radar.RadarPilotHigherFloor'
     m_TexRadarTextures(9)=Texture'Inventory_t.Radar.RadarPilotLowerFloor'
     m_bToggleHelmet=True
     m_ConsoleBackground=Texture'Inventory_t.Console.ConsoleBack'
}
