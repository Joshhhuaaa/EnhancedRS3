//=============================================================================
//  R6MPGameMenuCom.uc : the interface between server and menu 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/29 * Created by Yannick Joly
//=============================================================================
class R6MPGameMenuCom extends R6GameMenuCom;

var R6MenuInGameMultiPlayerRootWindow m_pCurrentRoot;

#ifdefDEBUG
var byte m_eLogOldCurrectServerState; 
#endif

simulated function SelectTeam()
{
    if (bShowLog) log("SelectTeam: currently m_TeamSelection=" $ m_PlayerController.m_TeamSelection$" m_PlayerController = "$m_PlayerController);

    if ((m_PlayerController.m_TeamSelection == PTS_UnSelected) || (GetGameType() != m_szPreviousGameType) ||
        (m_iOldMapIndex!=m_GameRepInfo.m_iMapIndex)) 
    {
        m_iOldMapIndex=m_GameRepInfo.m_iMapIndex;
        SetStatMenuState(CMS_Initial);
        m_PlayerController.m_TeamSelection = PTS_UnSelected;   // we need to wait for a team selection
        //m_eStatMenuState=CMS_Initial;
        //m_pCurrentRoot.m_pJoinTeamWidget.m_bMenuCreate=false;
        // player have to choose is team        
    }
}


function PlayerSelection(ePlayerTeamSelection newTeam)
{
#ifdefDEBUG
	if (bShowLog)
		log("R6MPGameMenuCom PlayerSelection newTeam"@newTeam);
#endif

	// advice root that player choose something
	m_pCurrentRoot.m_bPlayerDidASelection = true; 

	Super.PlayerSelection( newTeam);
}

function ePlayerTeamSelection GetPlayerSelection()
{
	if (m_PlayerController != None)
	{
#ifdefDEBUG
	if (bShowLog)
		log("R6MPGameMenuCom GetPlayerSelection():"@m_PlayerController.m_TeamSelection);
#endif
		return m_PlayerController.m_TeamSelection;
	}

	return PTS_UnSelected;
}

function BOOL IsAPlayerSelection()
{
	return ((GetPlayerSelection() == PTS_Alpha) || (GetPlayerSelection() == PTS_Bravo));
}

//=====================================================================
// SetStatMenuState : Overloaded from Parent. Set the new client menu state
//=====================================================================
function SetStatMenuState(R6GameMenuCom.eClientMenuState _eNewClientMenuState)
{
    local bool bCloseSimplePopUpBox;

    bCloseSimplePopUpBox = true;
    m_pCurrentRoot.m_bActiveBar = false;
    if(m_pCurrentRoot.m_bPlayerDidASelection != true)
    {
        if(_eNewClientMenuState == CMS_Initial)
        {
            if(int(m_pCurrentRoot.m_eCurWidgetInUse) == int(m_pCurrentRoot.eGameWidgetID.InGameMPWID_TeamJoin))
            {
                return;
            }            
        }
        else
        {
            if(_eNewClientMenuState == CMS_DisplayForceStatLocked)
            {                
            }
            else
            {
                return;
            }
        }
    }
    switch(_eNewClientMenuState)
    {
        case CMS_Initial:
            m_pCurrentRoot.m_bPreventMenuSwitch = false;
            if(m_PlayerController.m_TeamSelection == PTS_UnSelected)
            {
                m_pCurrentRoot.m_bPlayerDidASelection = false;
            }
            m_pCurrentRoot.ChangeCurrentWidget(InGameMPWID_TeamJoin);
            break;
        case CMS_PlayerDead:
            if(m_pCurrentRoot.m_pSimplePopUp != none)
            {
                if(m_pCurrentRoot.m_pSimplePopUp.bWindowVisible)
                {
                    if(m_pCurrentRoot.m_pSimplePopUp.m_ePopUpID == EPopUpID_TKPenalty)
                    {
                        m_pCurrentRoot.m_iWidgetKA = m_pCurrentRoot.C_iWKA_NONE;
                        return;
                    }
                }
            }
            m_pCurrentRoot.m_pIntermissionMenuWidget.m_pInGameNavBar.SetNavBarState(false, true);
            if(m_eStatMenuState == CMS_DisplayForceStat)
            {
                return;
            }
        case CMS_SpecMenu:
            m_pCurrentRoot.m_bActiveBar = true;
            m_pCurrentRoot.m_pIntermissionMenuWidget.m_pInGameNavBar.SetNavBarState(false, true);
            m_pCurrentRoot.ChangeWidget(WidgetID_None, false, true);
            break;
        case CMS_BetRoundmenu:
            m_pCurrentRoot.m_bActiveBar = true;
            m_pCurrentRoot.GetLevel().SetBankSound(BANK_UnloadGun);
            if(m_GameRepInfo.IsInAGameState())
            {
                m_pCurrentRoot.ChangeCurrentWidget(InGameMPWID_Intermission);
                _eNewClientMenuState = CMS_SpecMenu;                
            }
            else
            {
                m_pCurrentRoot.ChangeCurrentWidget(InGameMPWID_InterEndRound);
                bCloseSimplePopUpBox = false;
            }
            break;
        case CMS_DisplayStat:
            break;
        case CMS_DisplayForceStat:
            if((m_PlayerController.m_TeamSelection == PTS_Alpha) || m_PlayerController.m_TeamSelection == PTS_Bravo)
            {
                SetReadyButton(false);
            }
            m_pCurrentRoot.ChangeCurrentWidget(InGameMPWID_InterEndRound);
            m_pCurrentRoot.GetLevel().SetBankSound(BANK_UnloadGun);
            break;
        case CMS_DisplayForceStatLocked:
            m_pCurrentRoot.ChangeCurrentWidget(InGameMPWID_InterEndRound);
            m_pCurrentRoot.m_bPreventMenuSwitch = true;
            class'Actor'.static.EnableLoadingScreen(false);
            m_pCurrentRoot.GetLevel().SetBankSound(BANK_UnloadGun);
            m_pCurrentRoot.m_pIntermissionMenuWidget.m_pInGameNavBar.SetNavBarState(true);
            break;
        case CMS_InPreGameState:
            m_pCurrentRoot.m_pIntermissionMenuWidget.ForceClosePopUp();
            break;
        default:
            bCloseSimplePopUpBox = false;
            break;
    }
    if(bCloseSimplePopUpBox)
    {
        m_pCurrentRoot.CloseSimplePopUpBox();
    }
    m_eStatMenuState = _eNewClientMenuState;
}

function SetupPlayerPrefs()
{
    local string Tag;
    local Class<R6PrimaryWeaponDescription> PrimaryWeaponClass;
    local Class<R6SecondaryWeaponDescription> SecondaryWeaponClass;
    local Class<R6BulletDescription> PrimaryWeaponBulletClass, SecondaryWeaponBulletClass;
    local Class<R6GadgetDescription> PrimaryGadgetClass, SecondaryGadgetClass;
    local Class<R6WeaponGadgetDescription> PrimaryWeaponGadgetClass, SecondaryWeaponGadgetClass;
    local Class<R6ArmorDescription> ArmorDescriptionClass;
    local bool Found;
    local int k;
    local Class<R6GadgetDescription> replaceGadgetClass;

    PrimaryWeaponClass = Class<R6PrimaryWeaponDescription>(DynamicLoadObject(m_szPrimaryWeapon, Class'Core.Class'));
    PrimaryWeaponBulletClass = class'R6DescriptionManager'.static.GetPrimaryBulletDesc(PrimaryWeaponClass, m_szPrimaryWeaponBullet);
    PrimaryWeaponGadgetClass = class'R6DescriptionManager'.static.GetPrimaryWeaponGadgetDesc(PrimaryWeaponClass, m_szPrimaryWeaponGadget);
    SecondaryWeaponClass = Class<R6SecondaryWeaponDescription>(DynamicLoadObject(m_szSecondaryWeapon, Class'Core.Class'));
    SecondaryWeaponBulletClass = class'R6DescriptionManager'.static.GetSecondaryBulletDesc(SecondaryWeaponClass, m_szSecondaryWeaponBullet);
    SecondaryWeaponGadgetClass = class'R6DescriptionManager'.static.GetSecondaryWeaponGadgetDesc(SecondaryWeaponClass, m_szSecondaryWeaponGadget);
    PrimaryGadgetClass = Class<R6GadgetDescription>(DynamicLoadObject(m_szPrimaryGadget, Class'Core.Class'));
    SecondaryGadgetClass = Class<R6GadgetDescription>(DynamicLoadObject(m_szSecondaryGadget, Class'Core.Class'));
    if(class'R6MenuMPAdvGearWidget'.static.CheckGadget(string(PrimaryGadgetClass), m_pCurrentRoot, false, replaceGadgetClass))
    {
        PrimaryGadgetClass = replaceGadgetClass;
    }
    if(class'R6MenuMPAdvGearWidget'.static.CheckGadget(string(SecondaryGadgetClass), m_pCurrentRoot, false, replaceGadgetClass, string(PrimaryGadgetClass)))
    {
        SecondaryGadgetClass = replaceGadgetClass;
    }
    if(m_szArmor != "")
    {
        ArmorDescriptionClass = Class<R6ArmorDescription>(DynamicLoadObject(m_szArmor, Class'Core.Class'));
        m_PlayerPrefInfo.m_ArmorName = ArmorDescriptionClass.default.m_ClassName;
    }
    m_PlayerPrefInfo.m_WeaponGadgetName[0] = PrimaryWeaponGadgetClass.default.m_ClassName;
    m_PlayerPrefInfo.m_WeaponGadgetName[1] = SecondaryWeaponGadgetClass.default.m_ClassName;
    m_PlayerPrefInfo.m_GadgetName[0] = PrimaryGadgetClass.default.m_ClassName;
    m_PlayerPrefInfo.m_GadgetName[1] = SecondaryGadgetClass.default.m_ClassName;
    Found = false;

    for(k = 0; (k < PrimaryWeaponClass.default.m_WeaponTags.Length) && Found == false; k++)
    {
        if(PrimaryWeaponClass.default.m_WeaponTags[k] == PrimaryWeaponGadgetClass.default.m_NameTag)
        {
            Found = true;
            m_PlayerPrefInfo.m_WeaponName[0] = PrimaryWeaponClass.default.m_WeaponClasses[k];
            Tag = PrimaryWeaponClass.default.m_WeaponTags[k];
            continue;
        }
        if(PrimaryWeaponClass.default.m_WeaponTags[k] == PrimaryWeaponBulletClass.default.m_NameTag)
        {
            Found = true;
            m_PlayerPrefInfo.m_WeaponName[0] = PrimaryWeaponClass.default.m_WeaponClasses[k];
            Tag = PrimaryWeaponClass.default.m_WeaponTags[k];
        }
    }
    if(Found == false)
    {
        if(InStr(string(PrimaryWeaponClass), "PrimaryWeaponNone") != -1)
        {
            m_PlayerPrefInfo.m_WeaponName[0] = "R6Description.R6DescPrimaryWeaponNone";
            Tag = "NONE";            
        }
        else
        {
            m_PlayerPrefInfo.m_WeaponName[0] = PrimaryWeaponClass.default.m_WeaponClasses[0];
            Tag = PrimaryWeaponClass.default.m_WeaponTags[0];
        }
    }
    if(Tag == "SILENCED")
    {
        m_PlayerPrefInfo.m_BulletType[0] = PrimaryWeaponBulletClass.default.m_SubsonicClassName;        
    }
    else
    {
        m_PlayerPrefInfo.m_BulletType[0] = PrimaryWeaponBulletClass.default.m_ClassName;
    }
    Found = false;

    for(k = 0; (k < SecondaryWeaponClass.default.m_WeaponTags.Length) && Found == false; k++)
    {
        if(SecondaryWeaponClass.default.m_WeaponTags[k] == SecondaryWeaponGadgetClass.default.m_NameTag)
        {
            Found = true;
            m_PlayerPrefInfo.m_WeaponName[1] = SecondaryWeaponClass.default.m_WeaponClasses[k];
            Tag = SecondaryWeaponClass.default.m_WeaponTags[k];
            continue;
        }
        if(SecondaryWeaponClass.default.m_WeaponTags[k] == SecondaryWeaponBulletClass.default.m_NameTag)
        {
            Found = true;
            m_PlayerPrefInfo.m_WeaponName[1] = SecondaryWeaponClass.default.m_WeaponClasses[k];
            Tag = SecondaryWeaponClass.default.m_WeaponTags[k];
        }
    }
    if(Found == false)
    {
        m_PlayerPrefInfo.m_WeaponName[1] = SecondaryWeaponClass.default.m_WeaponClasses[0];
        Tag = SecondaryWeaponClass.default.m_WeaponTags[0];
    }
    if(Tag == "SILENCED")
    {
        m_PlayerPrefInfo.m_BulletType[1] = SecondaryWeaponBulletClass.default.m_SubsonicClassName;        
    }
    else
    {
        m_PlayerPrefInfo.m_BulletType[1] = SecondaryWeaponBulletClass.default.m_ClassName;
    }
}



//====================================================================================
// DisconnectClient: Disconnect the client from the server
//====================================================================================
function DisconnectClient( LevelInfo _Level )
{
    local UdpBeacon aBeacon;
    // For non dedicated server, log the server out from ubi.com
    // when the client exits the game
	m_bImCurrentlyDisconnect = true;

    if (_Level.NetMode == NM_ListenServer)
    {
		R6MultiPlayerGameInfo(_Level.Game).m_GameService.NativeLogOutServer(m_GameRepInfo);
        R6GameInfo(_Level.Game).DestroyBeacon();
    }

//    m_pCurrentRoot.CloseSimplePopUpBox();
    //m_pCurrentRoot.GetLevel().ConsoleCommand("DISCONNECT");
}

//====================================================================================
// SetPlayerReadyStatus: Set the ready button status of the player
//====================================================================================
function SetPlayerReadyStatus( BOOL _bPlayerReady)
{
#ifdefDEBUG
	LogServerState(); 
#endif

	Super.SetPlayerReadyStatus(_bPlayerReady);

	if (m_pCurrentRoot != None)
	{
		m_pCurrentRoot.m_pIntermissionMenuWidget.m_pInGameNavBar.m_pPlayerReady.m_bSelected = _bPlayerReady;
	}
}

function RefreshReadyButtonStatus()
{
#ifdefDEBUG
	LogServerState(); 
#endif

    if ( (m_GameRepInfo.m_eCurrectServerState==m_GameRepInfo.RSS_CountDownStage) ||
        (m_GameRepInfo.m_eCurrectServerState==m_GameRepInfo.RSS_PlayersConnectingStage))
    {
        if (m_PlayerController.IsPlayerPassiveSpectator() || ((m_PlayerController.bOnlySpectator) && (m_GameRepInfo.m_eCurrectServerState!=m_GameRepInfo.RSS_CountDownStage)))
            SetReadyButton(true);
        else
            SetReadyButton(false);
    }
    else if ( (m_GameRepInfo.m_eCurrectServerState==m_GameRepInfo.RSS_InPreGameState) ||
        (m_GameRepInfo.m_eCurrectServerState==m_GameRepInfo.RSS_InGameState) ||
        (m_GameRepInfo.m_eCurrectServerState==m_GameRepInfo.RSS_EndOfMatch) )
    {
        SetReadyButton(true);
    }
}
//====================================================================================
// SetReadyButton: Set the ready button state in the menu (disable when the player play, or enable -- spectator)
//====================================================================================
function SetReadyButton( BOOL _bDisable)
{
#ifdefDEBUG
	LogServerState(); 
#endif

	if (m_pCurrentRoot != None)
	{
		if (_bDisable)
		{
			m_pCurrentRoot.m_pIntermissionMenuWidget.m_pInGameNavBar.m_pPlayerReady.bDisabled = true;
		}
		else
		{
			m_pCurrentRoot.m_pIntermissionMenuWidget.m_pInGameNavBar.m_pPlayerReady.bDisabled   = false;			
//			m_pCurrentRoot.m_pIntermissionMenuWidget.m_pInGameNavBar.m_pPlayerReady.m_bSelected = false;
		}
	}
}

function BOOL IsInBetweenRoundMenu( optional BOOL _bIncludeCMSInit)
{
#ifdefDEBUG
	LogServerState(); 
#endif

	if (_bIncludeCMSInit)
		if (m_eStatMenuState == CMS_Initial)
			return true;
        
    if (m_GameRepInfo == none)
        return false;

	if (m_GameRepInfo.m_eCurrectServerState == m_GameRepInfo.RSS_CountDownStage)
		return true;

//	if ((m_eStatMenuState == CMS_BetRoundmenu) || (m_eStatMenuState == CMS_DisplayForceStat) ||
//		(m_eStatMenuState == CMS_DisplayForceStatLocked))
//	{
//		return true;
//	}

	return false;
}

// this returns an INT so that we can know where to display the player on
// the tab menu page
function INT GeTTeamSelection( INT _iIndex)
{
    local Actor.PlayerMenuInfo _PlayerMenuInfo;
    
    if (GetGameType() == "RGM_DeathmatchMode")
        return PTSToInt(PTS_Alpha);
    else 
    {
        m_pCurrentRoot.GetLevel().GetFPlayerMenuInfo(_iIndex, _PlayerMenuInfo);
        if (IntToPTS(_PlayerMenuInfo.iTeamSelection) == PTS_Alpha || IntToPTS(_PlayerMenuInfo.iTeamSelection) ==  PTS_Bravo )
            return _PlayerMenuInfo.iTeamSelection;
        else
            return PTSToInt(PTS_Spectator);
    }
}

simulated function SavePlayerSetupInfo()
{    
	if (m_PlayerController == None)
		return;

    m_pCurrentRoot.GetLevel().SetPlayerSetupInfo(
        m_PlayerPrefInfo.m_CharacterName,
        m_szArmor,
        m_szPrimaryWeapon,
        m_szPrimaryWeaponGadget,
        m_szPrimaryWeaponBullet,
        m_szSecondaryWeapon,
        m_szSecondaryWeaponGadget,
        m_szSecondaryWeaponBullet,
        m_szPrimaryGadget, 
        m_szSecondaryGadget);

    SetupPlayerPrefs();
  
    m_PlayerController.m_PlayerPrefs.m_CharacterName = m_PlayerPrefInfo.m_CharacterName;
    m_PlayerController.m_PlayerPrefs.m_ArmorName = m_PlayerPrefInfo.m_ArmorName;
    m_PlayerController.m_PlayerPrefs.m_WeaponName1 = m_PlayerPrefInfo.m_WeaponName[0];
    m_PlayerController.m_PlayerPrefs.m_WeaponGadgetName1 = m_PlayerPrefInfo.m_WeaponGadgetName[0];
    m_PlayerController.m_PlayerPrefs.m_BulletType1 = m_PlayerPrefInfo.m_BulletType[0];
    m_PlayerController.m_PlayerPrefs.m_WeaponName2 = m_PlayerPrefInfo.m_WeaponName[1];
    m_PlayerController.m_PlayerPrefs.m_WeaponGadgetName2 = m_PlayerPrefInfo.m_WeaponGadgetName[1];
    m_PlayerController.m_PlayerPrefs.m_BulletType2 = m_PlayerPrefInfo.m_BulletType[1];
    m_PlayerController.m_PlayerPrefs.m_GadgetName1 = m_PlayerPrefInfo.m_GadgetName[0];
    m_PlayerController.m_PlayerPrefs.m_GadgetName2 = m_PlayerPrefInfo.m_GadgetName[1];
    m_PlayerController.ServerPlayerPref(m_PlayerController.m_PlayerPrefs);

#ifdefDEBUG
	if (bShowLog)
	{
		log("R6MPGameMenuCom SavePlayerSetupInfo");
		log("m_PlayerController.m_PlayerPrefs.m_WeaponName1			"@m_PlayerController.m_PlayerPrefs.m_WeaponName1);
		log("m_PlayerController.m_PlayerPrefs.m_WeaponGadgetName1	"@m_PlayerController.m_PlayerPrefs.m_WeaponGadgetName1);
		log("m_PlayerController.m_PlayerPrefs.m_BulletType1			"@m_PlayerController.m_PlayerPrefs.m_BulletType1);
		log("m_PlayerController.m_PlayerPrefs.m_GadgetName1			"@m_PlayerController.m_PlayerPrefs.m_GadgetName1);
		log("m_PlayerController.m_PlayerPrefs.m_WeaponName2			"@m_PlayerController.m_PlayerPrefs.m_WeaponName2);
		log("m_PlayerController.m_PlayerPrefs.m_WeaponGadgetName2	"@m_PlayerController.m_PlayerPrefs.m_WeaponGadgetName2);
		log("m_PlayerController.m_PlayerPrefs.m_BulletType2			"@m_PlayerController.m_PlayerPrefs.m_BulletType2);
		log("m_PlayerController.m_PlayerPrefs.m_GadgetName2			"@m_PlayerController.m_PlayerPrefs.m_GadgetName2);
		log("m_PlayerController.m_PlayerPrefs.m_ArmorName			"@m_PlayerController.m_PlayerPrefs.m_ArmorName);
	}
#endif
}

simulated function InitialisePlayerSetupInfo()
{
    if (bShowLog)
    {
        log("In "$self$"::InitialisePlayerSetupInfo()");
    }
    m_pCurrentRoot.GetLevel().GetPlayerSetupInfo(m_PlayerPrefInfo.m_CharacterName,
        m_szArmor,
        m_szPrimaryWeapon,
        m_szPrimaryWeaponGadget,
        m_szPrimaryWeaponBullet,
        m_szSecondaryWeapon,
        m_szSecondaryWeaponGadget,
        m_szSecondaryWeaponBullet,
        m_szPrimaryGadget,
        m_szSecondaryGadget);
    SetupPlayerPrefs();       
}

simulated function string GetGameType()
{
    if (m_GameRepInfo == none)
        return "RGM_NoRulesMode";
    else
        return m_GameRepInfo.m_szGameTypeFlagRep;
}

//this function is called when team killer options are on and I have been killed by my team mate
function TKPopUpBox(string _KillerName)
{
    if (R6PlayerController(m_PlayerController).m_bAlreadyPoppedTKPopUpBox == false)
    {
        if (!m_pCurrentRoot.Console.IsInState('Game'))
            m_pCurrentRoot.Console.GotoState('Game');

        //do I want to penalize my mate, display dialog box with question
        m_pCurrentRoot.SimplePopUp(Localize("MPMiscMessages", "TKPopUpBoxTitle", "R6GameInfo"), 
							       _KillerName@Localize("MPMiscMessages", "DoYouWantToPenalize", "R6GameInfo"),
							       EPopUpID_TKPenalty);
        R6PlayerController(m_PlayerController).m_bAlreadyPoppedTKPopUpBox = true;
    }
}

function TKPopUpDone(BOOL _bApplyTeamKillerPenalty)
{
    m_PlayerController.ServerTKPopUpDone(_bApplyTeamKillerPenalty);
    R6PlayerController(m_PlayerController).m_bProcessingRequestTKPopUp=false;
}

event CountDownPopUpBox()
{

    m_pCurrentRoot.Console.ViewportOwner.u8WaitLaunchStatingSound = 0;

    if( m_PlayerController.m_TeamSelection==PTS_Alpha || m_PlayerController.m_TeamSelection==PTS_Bravo )
    {
#ifdefDEBUG
	    if (bShowLog)
			log("Count down START CountDownPopUpBox");
#endif
	    m_pCurrentRoot.ChangeCurrentWidget( InGameMPWID_CountDown);
    }
}

function CountDownPopUpBoxDone()
{
	if (m_pCurrentRoot.m_eCurWidgetInUse != m_pCurrentRoot.eGameWidgetID.InGameMPWID_CountDown)
	{
#ifdefDEBUG
		if (bShowLog) 
			log("CountDownPopUpBoxDone is call but you never call CountDownPopUpBox() before");
#endif
        if ((m_pCurrentRoot.GetPlayerOwner().Pawn != None) && (m_pCurrentRoot.GetPlayerOwner().Pawn.IsAlive()))
        {
#ifdefDEBUG
            //log("Bingo!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
#endif
        }
        else
    		return;
	}

#ifdefDEBUG
	if (bShowLog) 
		log("Count down END CountDownPopUpBoxDone");
#endif
    m_pCurrentRoot.ChangeWidget(WidgetID_None, false, true);
}

//============================================================================================
// ActiveVoteMenu: Active the vote menu -- kick or not the player
//============================================================================================
function ActiveVoteMenu( BOOL _bActiveMenu, optional string _szPlayerNameToKick)
{
	m_pCurrentRoot.VoteMenu( _szPlayerNameToKick, _bActiveMenu);
}

//============================================================================================
// SetVoteResult: Set the vote result
//============================================================================================
function SetVoteResult( BOOL _bKickPlayer)
{
	if (_bKickPlayer)
	{
        R6PlayerController(m_PlayerController).Vote(1);
		// TODO
		log("KICK PLAYER YES");
	}
	else
	{
        R6PlayerController(m_PlayerController).Vote(2);
		// TODO
		log("KICK PLAYER NO");
	}
}

function NewServerState()
{
    local R6PlayerController _localPlayer;
    if (m_GameRepInfo == none)
        return;
    Super.NewServerState();

    if (m_GameRepInfo.m_eCurrectServerState==m_GameRepInfo.RSS_EndOfMatch)
        m_pCurrentRoot.m_pIntermissionMenuWidget.m_pMPInterHeader.RefreshRoundInfo();

#ifdefDEBUG
	LogServerState(); 
#endif
}

#ifdefDEBUG
function LogServerState()
{
	if (bShowLog)
	{    
		if(m_GameRepInfo == None)
		{
			log("Could not log Server state m_GameRepInfo == None");
			return;
		}

		if (m_eLogOldCurrectServerState != m_GameRepInfo.m_eCurrectServerState)
		{
			if( m_GameRepInfo.m_eCurrectServerState==m_GameRepInfo.RSS_PlayersConnectingStage)
				log("Server state RSS_PlayersConnectingStage");
			else if (m_GameRepInfo.m_eCurrectServerState==m_GameRepInfo.RSS_CountDownStage)
				log("Server state RSS_CountDownStage");
			else if (m_GameRepInfo.m_eCurrectServerState==m_GameRepInfo.RSS_InPreGameState)
				log("Server state RSS_InPreGameState");
			else if (m_GameRepInfo.m_eCurrectServerState==m_GameRepInfo.RSS_InGameState)
				log("Server state RSS_InGameState");
			else if (m_GameRepInfo.m_eCurrectServerState==m_GameRepInfo.RSS_EndOfMatch)
				log("Server state RSS_EndOfMatch");
			else
				log(" Server state not defined");

			m_eLogOldCurrectServerState = m_GameRepInfo.m_eCurrectServerState;
		}
	}
}
#endif

	
function SetClientServerSettings(bool _bCanChangeOptions)
{
    m_pCurrentRoot.m_pIntermissionMenuWidget.SetClientServerSettings(_bCanChangeOptions);
}

//===========================================================================================
// GetNbOfTeamPlayer: get the number of player of a specific team, spectator include
//===========================================================================================
function INT GetNbOfTeamPlayer( BOOL _bGreenTeam)
{
	local INT i, iGreenTeam, iRedTeam, iNbOfPlayer, iIndex;

	RefreshMPlayerInfo(); // refresh info

	iGreenTeam  = ePlayerTeamSelection.PTS_Alpha;
	iRedTeam    = ePlayerTeamSelection.PTS_Bravo;

	iNbOfPlayer = 0;

    for ( i = 0; i < m_iLastValidIndex ; i++ )
    {
		iIndex   = GeTTeamSelection(i);

		if (_bGreenTeam)
		{
			if (iIndex == iGreenTeam)
				iNbOfPlayer += 1;
		}
		else
		{
			if (iIndex == iRedTeam)
				iNbOfPlayer += 1;
		}

		// if it's a spectator, nothing to do, is already manage in R6MenuMPTeamBar depending of active player
	}

	return Min(iNbOfPlayer, 8); // 8 is the max of player in a list
}

simulated function bool IsInGame()
{
    return m_pCurrentRoot.m_eCurWidgetInUse == WidgetID_None;
}

//====================================================================================
// GetPlayerDidASelection: 
//====================================================================================
function BOOL GetPlayerDidASelection()
{
    return m_pCurrentRoot.m_bPlayerDidASelection;
}

defaultproperties
{
}
