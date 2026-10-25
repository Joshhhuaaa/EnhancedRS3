//=============================================================================
//  R6TrainingMgr.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/09/19 * Created by Guillaume Borgia
//=============================================================================

class R6TrainingMgr extends R6PracticeModeGame;

enum ETrainingWeapons
{
    TW_SMG,
    TW_Pistol,
    TW_Sniper,
    TW_HBSensor,
    TW_Assault,
    TW_AssaultSilenced,
    TW_LMG,
    TW_Shotgun,
    TW_Grenades,
    TW_BreachCharge,
    TW_RemoteCharge,
    TW_Claymore,
    TW_MAX
};

const C_NbWeapons = 12;

var ETrainingWeapons    m_eCurrentWeapon;

var R6EngineWeapon      m_Weapons[C_NbWeapons];
var string              m_WeaponsName[C_NbWeapons];
var INT                 m_WeaponsSlot[C_NbWeapons];
var bool                m_bInitialized;


function bool IsBasicMap()
{
    local string szMapName;
    
    szMapName = class'Actor'.static.GetCanvas().Viewport.Console.Master.m_StartGameInfo.m_MapName;
    szMapName = Caps( szMapName );

    if ( szMapName == "TRAINING_BASICS" )
        return true;

    return false;
}

//------------------------------------------------------------------
// 
//	
//------------------------------------------------------------------
function float GetEndGamePauseTime()
{
    if ( IsBasicMap() )
        return 20;
    
    return Super.GetEndGamePauseTime();
}

//============================================================================
// BOOL CanChangeText - 
//============================================================================
function BOOL CanChangeText( INT iBoxNumber )
{
    // can be used to keep the last message on screen

    return true;
}

//============================================================================
// Object GetTrainingMgr - 
//============================================================================
function R6TrainingMgr GetTrainingMgr( R6Pawn p )
{
    return Self;
} 

//============================================================================
// DeployCharacters - 
//============================================================================
function DeployCharacters(PlayerController ControlledByPlayer)
{
    local R6RainbowAI aRainbowAI;
    local INT i;
    local R6PlayerController aPC;
    local R6Pawn pPawn;
    local string                szMapName;
    local R6StartGameInfo       startGameInfo;

    Super.DeployCharacters( ControlledByPlayer );

    startGameInfo = class'Actor'.static.GetCanvas().Viewport.Console.Master.m_StartGameInfo;

    szMapName = StartGameInfo.m_MapName;
    szMapName = caps( szMapName  );
    if ( !(szMapName == "TRAINING_BASICS"    ||
           szMapName == "TRAINING_SHOOTING"  ||
           szMapName == "TRAINING_EXPLOSIVES" ))
    {
        return; // it will use the default planning
    }

    // so the player can play with explosives without dying.
    m_Player.bGodMode = true;     

    // load special weapon
    pPawn = R6Pawn(m_Player.Pawn);
    aPC = R6PlayerController(m_Player);

    // Load all weapon sounds
    for(i=0; i<C_NbWeapons; i++)
        R6PlayerController(m_Player).SetWeaponSound(m_Player.m_PawnRepInfo, m_WeaponsName[i], 0);

    R6PlayerController(m_Player).ClientFinalizeLoading(pPawn.Region.Zone);
    
    LoadWeapons();
    
}


//============================================================================
// LoadWeapons - 
//============================================================================
function LoadWeapons()
{
    local INT i;
    local R6Pawn pPawn;

    pPawn = R6Pawn(m_Player.Pawn);

    for(i=0; i<C_NbWeapons; i++)
    {
        if(i==0) // TW_SMG
            pPawn.ServerGivesWeaponToClient( m_WeaponsName[i], 1, "", "R6WeaponGadgets.R6MiniScopeGadget" );
        else if(i==2) // TW_Sniper
            pPawn.ServerGivesWeaponToClient( m_WeaponsName[i], 1, "", "R6WeaponGadgets.R6ThermalScopeGadget" );
        else if (i==4) // TW_Assault
            pPawn.ServerGivesWeaponToClient( m_WeaponsName[i], 1, "", "R6WeaponGadgets.R6MiniScopeGadget" );
        else if (i==5) // TW_AssaultSilenced
            pPawn.ServerGivesWeaponToClient( m_WeaponsName[i], 1, "", "R6WeaponGadgets.R6SilencerGadget" );
        else
            pPawn.ServerGivesWeaponToClient( m_WeaponsName[i], 1, "", "" );

        m_Weapons[i] = pPawn.m_WeaponsCarried[0];
        pPawn.m_WeaponsCarried[0] = none;
        ShowWeaponAndAttachment( m_Weapons[i], false );
        m_Weapons[i].WeaponInitialization( pPawn );
        m_Weapons[i].LoadFirstPersonWeapon();
    }
}

//============================================================================
// ResetGunAmmo - 
//============================================================================
function ResetGunAmmo()
{
    local INT i;

    for(i=0; i<4; i++)
    {
        if(R6Pawn(m_Player.Pawn).m_WeaponsCarried[i]!=none)
            R6Pawn(m_Player.Pawn).m_WeaponsCarried[i].FillClips();
    }
}

//============================================================================
// ShowWeaponAndAttachment - 
//============================================================================
function ShowWeaponAndAttachment( R6EngineWeapon aWeapon, BOOL bShow )
{
    local R6AbstractWeapon pWeapon;

    pWeapon = R6AbstractWeapon(aWeapon);
    if(pWeapon==none)
        return;

    pWeapon.bHidden = !bShow;

    if( pWeapon.m_SelectedWeaponGadget != none )
        pWeapon.m_SelectedWeaponGadget.bHidden = !bShow;

    if( pWeapon.m_MuzzleGadget != none )
        pWeapon.m_MuzzleGadget.bHidden = !bShow;

    if( pWeapon.m_ScopeGadget != none )
        pWeapon.m_ScopeGadget.bHidden = !bShow;

    if( pWeapon.m_BipodGadget != none )
        pWeapon.m_BipodGadget.bHidden = !bShow;

    if( pWeapon.m_MagazineGadget != none )
        pWeapon.m_MagazineGadget.bHidden = !bShow;
}

//============================================================================
// SwitchToWeapon - 
//============================================================================
function SwitchToWeapon( ETrainingWeapons eWT, BOOL bSwitch )
{
    local R6Pawn pPawn;
    local R6DemolitionsGadget pGadget;
    local R6EngineWeapon      wpn;

    pPawn = R6Pawn(m_Player.Pawn);

    if( R6PlayerController(m_Player).m_TeamManager.m_iRainbowTeamName!=0 || pPawn.m_iPermanentID!=0 )
        return;

    //Cancel Zoom Here!
    R6PlayerController(m_Player).DoZoom(true);
    
    if( eWT>= TW_Grenades )
    {
        pGadget = R6DemolitionsGadget(m_Weapons[eWT]);
        if (pGadget != none && !pGadget.IsInState('ChargeArmed'))
        {
            pGadget.UpdateHands();
        }
        
        if (!m_Weapons[eWT].HasAmmo())
        {
            pPawn.EngineWeapon.GotoState('RaiseWeapon');
        }
        
        m_Weapons[eWT].FullAmmo();
    }
    else
    {
        R6AbstractWeapon(m_Weapons[eWT]).m_FPHands.ResetNeutralAnim();
        wpn = R6Pawn(m_Player.Pawn).m_WeaponsCarried[m_WeaponsSlot[eWT]];
        if ( wpn != none ) // the first time this function is called, there's no wpn
            wpn.FillClips();
    }


    if( m_eCurrentWeapon == eWT )
        return;

    //log("SwitchToWeapon " $ eWT $ " from " $ m_eCurrentWeapon @ m_Weapons[eWT] @ m_WeaponsSlot[eWT] );

    ShowWeaponAndAttachment( pPawn.m_WeaponsCarried[m_WeaponsSlot[eWT]], false );
    ShowWeaponAndAttachment( m_Weapons[eWT], true );

    StopAllSoundsActor(pPawn.m_SoundRepInfo);
    pPawn.m_WeaponsCarried[m_WeaponsSlot[eWT]] = m_Weapons[eWT];
    R6PlayerController(m_Player).SetWeaponSound(m_Player.m_PawnRepInfo, m_WeaponsName[eWT], m_WeaponsSlot[eWT]);
    if (pPawn.m_SoundRepInfo != none)
        pPawn.m_SoundRepInfo.m_CurrentWeapon = m_WeaponsSlot[eWT];

    m_eCurrentWeapon = eWT;
    if(bSwitch)
    {
        if(pPawn.EngineWeapon!=none)
        {
            pPawn.EngineWeapon.bHidden=true;
	        pPawn.EngineWeapon.GotoState('PutWeaponDown');
        }
        pPawn.ServerChangedWeapon( pPawn.EngineWeapon, m_Weapons[eWT] );
        
        if(pPawn.EngineWeapon!=none)
            pPawn.EngineWeapon.GotoState('RaiseWeapon');
    }
    else
    {
        m_Weapons[eWT].bHidden = true;
    }
}

function LoadPlanningInTraining()
{
    local R6FileManagerPlanning pFileManager;
    local R6StartGameInfo       startGameInfo;
    local string                szLoadErrorMsgMapName;
    local string                szLoadErrorMsgGameType;
    local string                szMapName;
    local string                szGameTypeDirName;
    local string                szEnglishGTDirectory;
    local R6MissionDescription  missionDescription;
    local INT                   i,j;

    startGameInfo = class'Actor'.static.GetCanvas().Viewport.Console.Master.m_StartGameInfo;
    pFileManager = new(None) class'R6FileManagerPlanning';

    missionDescription = R6MissionDescription(startGameInfo.m_CurrentMission);

    szMapName = Localize( missionDescription.m_MapName, "ID_MENUNAME", missionDescription.LocalizationFile, true );
    if( szMapName == "" ) // failed to find the name, use the map filename
    {
        szMapName = StartGameInfo.m_MapName;
    }

    Level.GetGameTypeSaveDirectories( szGameTypeDirName, szEnglishGTDirectory );

    if ( pFileManager.LoadPlanning( missionDescription.m_MapName, 
                                    szMapName,
                                    szEnglishGTDirectory,
                                    szGameTypeDirName,
                                    missionDescription.m_ShortName$ "" $m_szDefaultActionPlan ,
                                    startGameInfo,
                                    szLoadErrorMsgMapName, szLoadErrorMsgGameType ) )
    {
        log( "LoadPlanningInTraining failed  map=" $StartGameInfo.m_MapName$ " filename=" $missionDescription.m_ShortName$ "" $m_szDefaultActionPlan );
        log( "Planning Was Created for : "$szLoadErrorMsgMapName$" : "$szLoadErrorMsgGameType);
    }
    

    for(i=0; i<3; i++)
    {
        R6PlanningInfo(startGameInfo.m_TeamInfo[i].m_pPlanning).InitPlanning(i,none);
        if(R6PlanningInfo(startGameInfo.m_TeamInfo[i].m_pPlanning).GetNbActionPoint() > 0)
            R6PlanningInfo(startGameInfo.m_TeamInfo[i].m_pPlanning).m_iCurrentNode = 0;
        else
            R6PlanningInfo(startGameInfo.m_TeamInfo[i].m_pPlanning).m_iCurrentNode = -1;

        for(j=0; j<startGameInfo.m_TeamInfo[i].m_iNumberOfMembers; j++)
        {
            startGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_CharacterName   = Localize( "Training", "ROOKIE", "R6Menu", true );
            startGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_FaceTexture          =  class'R6RookieAssault'.default.m_TMenuFaceSmall;
            startGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_FaceCoords.X         =  class'R6RookieAssault'.default.m_RMenuFaceSmallX;
            startGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_FaceCoords.Y         =  class'R6RookieAssault'.default.m_RMenuFaceSmallY;
            startGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_FaceCoords.Z         =  class'R6RookieAssault'.default.m_RMenuFaceSmallW;
            startGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_FaceCoords.W         =  class'R6RookieAssault'.default.m_RMenuFaceSmallH;
            if((i==2) && (j==0))
				startGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_szSpecialityID  = "ID_SNIPER";
            else
				startGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_szSpecialityID  = "ID_ASSAULT";

			startGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_fSkillAssault = 0.85f;
			startGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_fSkillDemolitions = 0.85f;
			startGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_fSkillElectronics = 0.85f;
			startGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_fSkillSniper = 0.85f;
			startGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_fSkillStealth = 0.85f;
			startGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_fSkillSelfControl = 0.85f;
			startGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_fSkillLeadership = 0.85f;
			startGameInfo.m_TeamInfo[i].m_CharacterInTeam[j].m_fSkillObservation = 0.85f;  
        }
    }
}

//============================================================================
// LaunchAction - 
//============================================================================
function LaunchAction( INT iBoxNb, INT iSoundIndex )
{
    local R6GameReplicationInfo aGRI;

    if(m_Player==none || R6Pawn(m_Player.Pawn)==none)
        return;

    aGRI = R6GameReplicationInfo(GameReplicationInfo);

    if(iSoundIndex==0)
    {
        switch(iBoxNb)
        {
            case 1:
                break;

            case 8:
                SwitchToWeapon( TW_Pistol, false );
                SwitchToWeapon( TW_SMG, true ); // needed for rate of fire
                break;
            case 9:
                SwitchToWeapon( TW_SMG, true ); 
                break;
            case 10:
                SwitchToWeapon( TW_Pistol, true );
                break;
            case 11:
                SwitchToWeapon( TW_SMG, true );
                break;
            case 12:
                SwitchToWeapon( TW_Assault, true );
                break;
            case 13:
                SwitchToWeapon( TW_Shotgun, true );
                break;
            case 14:
                SwitchToWeapon( TW_Sniper, true );
                break;
            case 15:
                SwitchToWeapon( TW_LMG, true );
                break;
            case 16:
                SwitchToWeapon( TW_Claymore, false );
                SwitchToWeapon( TW_Grenades, true  );
                break;
            case 17:
                SwitchToWeapon( TW_Grenades, true );
                break;
            case 18:
                SwitchToWeapon( TW_BreachCharge, true );
                break;
            case 19:
                SwitchToWeapon( TW_Claymore, true );
                break;
            case 20:
                SwitchToWeapon( TW_RemoteCharge, true );
                break;
            
            case 21: // RoomClearing1Box1
            case 24: // RoomClearing2Box1
            case 25: // RoomClearing3Box1
            case 26: // HostageRescue1
            case 27: // HostageRescue2
            case 28: // HostageRescue3
                break;
        }
    }
}

function string GetIntelVideoName( R6MissionDescription desc )
{
    return "";
}

function EndGame( PlayerReplicationInfo Winner, string Reason ) 
{
    if ( m_bGameOver )
        return;

    class'Actor'.static.GetCanvas().Viewport.Console.Master.m_StartGameInfo.m_SkipPlanningPhase = false;
    class'Actor'.static.GetCanvas().Viewport.Console.Master.m_StartGameInfo.m_ReloadPlanning = false;
    class'Actor'.static.GetCanvas().Viewport.Console.Master.m_StartGameInfo.m_ReloadActionPointOnly = false;    

    if ( IsBasicMap() )
        Level.m_sndMissionComplete = none;

    Super.EndGame( Winner, Reason );
}

defaultproperties
{
     m_eCurrentWeapon=TW_MAX
     m_WeaponsSlot(1)=1
     m_WeaponsSlot(3)=2
     m_WeaponsSlot(8)=2
     m_WeaponsSlot(9)=2
     m_WeaponsSlot(10)=2
     m_WeaponsSlot(11)=3
     m_WeaponsName(0)="R63rdWeapons.NormalSubMP5A4"
     m_WeaponsName(1)="R63rdWeapons.NormalPistolUSP"
     m_WeaponsName(2)="R63rdWeapons.NormalSniperM82A1"
     m_WeaponsName(3)="R6Weapons.R6HBSGadget"
     m_WeaponsName(4)="R63rdWeapons.NormalAssaultM4"
     m_WeaponsName(5)="R63rdWeapons.SilencedAssaultM4"
     m_WeaponsName(6)="R63rdWeapons.NormalLMGM60E4"
     m_WeaponsName(7)="R63rdWeapons.BuckShotgunM1"
     m_WeaponsName(8)="R6Weapons.R6FragGrenadeGadget"
     m_WeaponsName(9)="R6Weapons.R6BreachingChargeGadget"
     m_WeaponsName(10)="R6Weapons.R6RemoteChargeGadget"
     m_WeaponsName(11)="R6Weapons.R6ClaymoreGadget"
     m_bUsingCampaignBriefing=False
     m_szDefaultActionPlan="_MISSION_DEFAULT"
     m_bUseClarkVoice=False
     m_bPlayIntroVideo=False
     m_bPlayOutroVideo=False
}
