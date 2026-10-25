//=============================================================================
//  R6MenuMPServerOption.uc : Display the server option depending if you are an admin or a client
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/09  * Create by Yannick Joly
//=============================================================================
class R6MenuMPServerOption extends R6MenuMPCreateGameTabOptions;

var UWindowWindow                       m_pServerOptFakeW;      // fake window to hide all access buttons
var UWindowWindow                       m_pServerOptFakeW2;     // fake window to hide all access buttons
var R6WindowTextLabel                   m_InTheReleaseLabel;

var BOOL								m_bServerSettingsChange;// at least one of the server settings change
var BOOL								m_bImAnAdmin;			// if the client can change the settings

function Created()
{
	Super.Created();

	// create a fake window over all these things
	m_pServerOptFakeW  = CreateWindow( class'UWindowWindow', 0, 0, WinWidth * 0.5, WinHeight, self);
	m_pServerOptFakeW.bAlwaysOnTop = true;
	m_pServerOptFakeW2 = CreateWindow( class'UWindowWindow', 310, 136, WinWidth * 0.5, WinHeight - 136, self);
	m_pServerOptFakeW2.bAlwaysOnTop = true;

	InitOptionsTab( true);

#ifdefMPDEMO
	m_bImAnAdmin = false;

    m_InTheReleaseLabel = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel',20, 265, 600, 50, self));
    m_InTheReleaseLabel.Text = "Modification to these options will be available in the full version";
    m_InTheReleaseLabel.m_Font = font'R6Font.Rainbow6_22pt';
	m_InTheReleaseLabel.TextColor = Root.Colors.White;
    m_InTheReleaseLabel.m_bDrawBorders = false;
    return;
#endif

    /////////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////////////////////////////////////
	Refresh();
}

//=======================================================================================
// Refresh : Verify is the client is now an admin
//=======================================================================================
function Refresh()
{
	if ( R6PlayerController(GetPlayerOwner()).CheckAuthority(R6PlayerController(GetPlayerOwner()).Authority_Admin))
	{
        // we just became an administrator
#ifndefMPDEMO
        if (m_bImAnAdmin == false)
        {
		    m_bImAnAdmin = true;
            R6PlayerController(GetPlayerOwner()).ServerPausePreGameRoundTime();
        }
#endif
		m_pServerOptFakeW.HideWindow();
		m_pServerOptFakeW2.HideWindow();
	}
	else
	{
		m_bImAnAdmin = false;

		m_pServerOptFakeW.ShowWindow();
		m_pServerOptFakeW2.ShowWindow();
    }
}

//=======================================================================================
// RefreshServerOpt : Update server info menu with the values of the server
//=======================================================================================
function RefreshServerOpt( optional BOOL _bNewServerProfile)
{
	local INT iIndex;
	local R6GameReplicationInfo pGameRepInfo;
	local R6MenuMapList pCurrentMapList;

	Refresh();

	pGameRepInfo = R6GameReplicationInfo(R6MenuInGameMultiPlayerRootWindow(Root).m_R6GameMenuCom.m_GameRepInfo);

	if(m_bInitComplete)
	{
		UpdateAllMapList();
	}

	pCurrentMapList = R6MenuMapList( GetList( GetCurrentGameMode(), eCGW_MapList));
	m_pOptionsGameMode.SetValue( m_pOptionsGameMode.GetValue(), pCurrentMapList.GetNewServerProfileGameMode( true));
	ManageComboControlNotify(m_pOptionsGameMode);

	pCurrentMapList = R6MenuMapList( GetList( GetCurrentGameMode(), eCGW_MapList));
	iIndex = m_pOptionsGameMode.FindItemIndex2( pCurrentMapList.FillFinalMapListInGame( )); // refresh final map list
	m_pOptionsGameMode.SetSelectedIndex( iIndex);
    m_pOptionsGameMode.SetDisableButton(true);

	m_pServerNameEdit.SetValue( pGameRepInfo.ServerName);

	SetButtonAndEditBox( eCGW_Password, "*******", pGameRepInfo.m_bPasswordReq);
	R6WindowButtonAndEditBox(GetList(GetCurrentGameMode(), eCGW_Password)).SetDisableButtonAndEditBox(true);

	SetButtonAndEditBox( eCGW_AdminPassword, "*******", pGameRepInfo.m_bAdminPasswordReq);
	R6WindowButtonAndEditBox(GetList(GetCurrentGameMode(), eCGW_AdminPassword)).SetDisableButtonAndEditBox(true);

	m_szMsgOfTheDay = pGameRepInfo.MOTDLine1;

	RefreshCGButtons();
}

function UpdateButtons( Actor.EGameModeInfo _eGameMode, eCreateGameWindow_ID _eCGWindowID, optional BOOL _bUpdateValue)
{
	local R6WindowListGeneral pTempList; 
	local R6GameReplicationInfo pR6GameRepInfo;

	pTempList = R6WindowListGeneral(GetList( _eGameMode, _eCGWindowID));

#ifdefDEBUG
	if (m_bShowLog)
		log("UpdateButtons pTempList"@pTempList@"for _eCGWindowID"@_eCGWindowID);
#endif

	if (pTempList == None)
		return;

	if (_bUpdateValue)
		pR6GameRepInfo = R6GameReplicationInfo(R6MenuInGameMultiPlayerRootWindow(Root).m_R6GameMenuCom.m_GameRepInfo);

	switch(_eGameMode)
	{
		//===============================================================================================================
		//===============================================================================================================
		//=============================== ADVERSARIAL ===================================================================
		//===============================================================================================================
		//===============================================================================================================
		case m_ANbOfGameMode[0]: 
			switch(_eCGWindowID)
			{
				case eCGW_Opt:
					if (_bUpdateValue)
					{
						m_pButtonsDef.ChangeButtonComboValue(EButtonName.EBN_InternetServer,   string(pR6GameRepInfo.m_bInternetSvr), pTempList, true);
						m_pButtonsDef.ChangeButtonCounterValue( EButtonName.EBN_RoundPerMatch, pR6GameRepInfo.m_iRoundsPerMatch, pTempList, !m_bImAnAdmin);
						m_pButtonsDef.ChangeButtonCounterValue( EButtonName.EBN_RoundTime,	   pR6GameRepInfo.TimeLimit / 60,	 pTempList, !m_bImAnAdmin);
						m_pButtonsDef.ChangeButtonCounterValue( EButtonName.EBN_TimeBetRound,  pR6GameRepInfo.m_fTimeBetRounds,	 pTempList, !m_bImAnAdmin);
						m_pButtonsDef.ChangeButtonCounterValue( EButtonName.EBN_NB_Players,	   pR6GameRepInfo.m_MaxPlayers,		 pTempList, !m_bImAnAdmin);
#ifndefMPDEMO
						m_pButtonsDef.ChangeButtonCounterValue( EButtonName.EBN_BombTimer,	   pR6GameRepInfo.m_fBombTime,		 pTempList, !m_bImAnAdmin);
#endif
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_DedicatedServer,   pR6GameRepInfo.m_bDedicatedSvr,	pTempList, true);
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_FriendlyFire,	   pR6GameRepInfo.m_bFriendlyFire,	pTempList);
						m_bBkpTKPenalty = pR6GameRepInfo.m_bMenuTKPenaltySetting;
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_TKPenalty,		   pR6GameRepInfo.m_bMenuTKPenaltySetting, pTempList);
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_AllowRadar,		   pR6GameRepInfo.m_bRepAllowRadarOption, pTempList);
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_AllowTeamNames,    pR6GameRepInfo.m_bShowNames,		 pTempList);
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_ForceFPersonWp,    pR6GameRepInfo.m_bFFPWeapon,    	 pTempList);
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_AutoBalTeam,       pR6GameRepInfo.m_bAutoBalance,		pTempList);

						UpdateMenuOptions(EButtonName.EBN_FriendlyFire, pR6GameRepInfo.m_bFriendlyFire, pTempList);
					}
					else
					{
						Super.UpdateButtons( _eGameMode, _eCGWindowID, _bUpdateValue);
					}
					break;
				case eCGW_Camera:
					if (_bUpdateValue)
					{
//#ifdefR6PUNKBUSTER
						if (class'Actor'.static.GetGameOptions().m_bPBInstalled)
							m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_PunkBuster,   pR6GameRepInfo.m_bPunkBuster,		 pTempList, true);
						else
							m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_PunkBuster,   false,							 pTempList, true);
//#endif
						UpdateCamera( EButtonName.EBN_CamFadeToBk	, ( ( pR6GameRepInfo.m_iDeathCameraMode & 0x10) > 0 ), false, pTempList);
						UpdateCamera( EButtonName.EBN_CamFirstPerson, ( ( pR6GameRepInfo.m_iDeathCameraMode & 0x01) > 0 ), false, pTempList, true);
						UpdateCamera( EButtonName.EBN_CamThirdPerson, ( ( pR6GameRepInfo.m_iDeathCameraMode & 0x02) > 0 ), false, pTempList, true);
						UpdateCamera( EButtonName.EBN_CamFreeThirdP	, ( ( pR6GameRepInfo.m_iDeathCameraMode & 0x04) > 0 ), false, pTempList, true);
						UpdateCamera( EButtonName.EBN_CamGhost		, ( ( pR6GameRepInfo.m_iDeathCameraMode & 0x08) > 0 ), false, pTempList, true);
						UpdateCamera( EButtonName.EBN_CamTeamOnly	, ( ( pR6GameRepInfo.m_iDeathCameraMode & 0x20) > 0 ), false, pTempList, true);

						UpdateCamSpecialCase( ( ( pR6GameRepInfo.m_iDeathCameraMode & 0x20) > 0 ), false);
						UpdateCamSpecialCase( ( ( pR6GameRepInfo.m_iDeathCameraMode & 0x10) > 0 ), true);
					}
					else
					{
						Super.UpdateButtons( _eGameMode, _eCGWindowID, _bUpdateValue);
//#ifdefR6PUNKBUSTER
						m_pButtonsDef.AddButtonBool( EButtonName.EBN_PunkBuster, false, pTempList, self);
//#endif
					}
					break;
				default:
					break;
			}
			break;
		//===============================================================================================================
		//===============================================================================================================
		//=============================== COOPERATIVE ===================================================================
		//===============================================================================================================
		//===============================================================================================================
		case m_ANbOfGameMode[1]:
			switch(_eCGWindowID)
			{
				case eCGW_Opt:
					if (_bUpdateValue)
					{
						m_pButtonsDef.ChangeButtonComboValue(EButtonName.EBN_InternetServer,     string(pR6GameRepInfo.m_bInternetSvr), pTempList, true);
						m_pButtonsDef.ChangeButtonComboValue(EButtonName.EBN_DiffLevel,			 string(pR6GameRepInfo.m_iDiffLevel),	pTempList);
						m_pButtonsDef.ChangeButtonCounterValue( EButtonName.EBN_RoundPerMission, pR6GameRepInfo.m_iRoundsPerMatch,		pTempList);
						m_pButtonsDef.ChangeButtonCounterValue( EButtonName.EBN_RoundTime,       pR6GameRepInfo.TimeLimit / 60,			pTempList);
						m_pButtonsDef.ChangeButtonCounterValue( EButtonName.EBN_TimeBetRound,	 pR6GameRepInfo.m_fTimeBetRounds,		pTempList);
						m_pButtonsDef.ChangeButtonCounterValue( EButtonName.EBN_NB_Players,		 pR6GameRepInfo.m_MaxPlayers,			pTempList);
						m_pButtonsDef.ChangeButtonCounterValue( EButtonName.EBN_NB_of_Terro,	 pR6GameRepInfo.m_iNbOfTerro,		    pTempList);
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_DedicatedServer,     pR6GameRepInfo.m_bDedicatedSvr,		pTempList, true);
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_AIBkp,				 pR6GameRepInfo.m_bAIBkp,				pTempList);
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_RotateMap,			 pR6GameRepInfo.m_bRotateMap,			pTempList);
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_FriendlyFire,		 pR6GameRepInfo.m_bFriendlyFire,	    pTempList);
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_AllowRadar,			 pR6GameRepInfo.m_bRepAllowRadarOption, pTempList);
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_AllowTeamNames,		 pR6GameRepInfo.m_bShowNames,		    pTempList);
						m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_ForceFPersonWp,      pR6GameRepInfo.m_bFFPWeapon,			pTempList);
					}
					else
					{
						Super.UpdateButtons( _eGameMode, _eCGWindowID, _bUpdateValue);
					}
					break;
				case eCGW_Camera:
					if (_bUpdateValue)
					{
//#ifdefR6PUNKBUSTER
						if (class'Actor'.static.GetGameOptions().m_bPBInstalled)
							m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_PunkBuster,		 pR6GameRepInfo.m_bPunkBuster,			pTempList, true);
						else
							m_pButtonsDef.ChangeButtonBoxValue( EButtonName.EBN_PunkBuster,		 false,									pTempList, true);
//#endif					
						UpdateCamera( EButtonName.EBN_CamFirstPerson, ( ( pR6GameRepInfo.m_iDeathCameraMode & 0x01) > 0 ), false, pTempList);
						UpdateCamera( EButtonName.EBN_CamThirdPerson, ( ( pR6GameRepInfo.m_iDeathCameraMode & 0x02) > 0 ), false, pTempList);
						UpdateCamera( EButtonName.EBN_CamFreeThirdP	, ( ( pR6GameRepInfo.m_iDeathCameraMode & 0x04) > 0 ), false, pTempList);
						UpdateCamera( EButtonName.EBN_CamGhost		, ( ( pR6GameRepInfo.m_iDeathCameraMode & 0x08) > 0 ), false, pTempList);
					}
					else
					{
						Super.UpdateButtons( _eGameMode, _eCGWindowID, _bUpdateValue);
//#ifdefR6PUNKBUSTER
						m_pButtonsDef.AddButtonBool( EButtonName.EBN_PunkBuster, false, pTempList, self);
//#endif
					}
					break;
				default:
					break;
			}
			break;
		default:
			log("UpdateButtons not a valid game mode");
			break;
	}
}

//=================================================================================
// SendNewServerSettings: Send the new server settings to the server, only the change values. 
//						  If no modification was made return false 
//=================================================================================
function BOOL SendNewServerSettings()
{
	local R6GameReplicationInfo pGameRepInfo;
	local R6PlayerController    pPlayContr;
	local R6WindowListGeneral   pTempButList, pTempCamList; 
	local INT  iTempValue;
	local BOOL bTempValue,
			   bSettingsChange, 
			   bLogSettingsChange;

#ifdefDEBUG
	bLogSettingsChange = false;
#endif

	if (!m_bServerSettingsChange)
		return false;

	pTempButList = R6WindowListGeneral(GetList( GetCurrentGameMode(), eCGW_Opt));
	pTempCamList = R6WindowListGeneral(GetList( GetCurrentGameMode(), eCGW_Camera));
	pGameRepInfo = R6GameReplicationInfo(R6MenuInGameMultiPlayerRootWindow(Root).m_R6GameMenuCom.m_GameRepInfo);
	pPlayContr	 = R6PlayerController(GetPlayerOwner());

	if ((pTempButList == None) || (pTempCamList == None) || (pGameRepInfo == None) || (pPlayContr == None))
		return false;

	iTempValue = m_pButtonsDef.GetButtonCounterValue( EButtonName.EBN_RoundTime, pTempButList);
	if ( iTempValue != (pGameRepInfo.TimeLimit / 60))
    {
        bSettingsChange = true;
        pPlayContr.ServerNewGeneralSettings( EBN_RoundTime, , iTempValue * 60);
#ifdefDEBUG
		if (bLogSettingsChange) log("EBN_RoundTime change");
#endif
    }

	iTempValue = m_pButtonsDef.GetButtonCounterValue( EButtonName.EBN_TimeBetRound, pTempButList);
	if ( iTempValue != pGameRepInfo.m_fTimeBetRounds)
    {
        bSettingsChange = true;
		pPlayContr.ServerNewGeneralSettings( EBN_TimeBetRound, , iTempValue) || bSettingsChange;	
#ifdefDEBUG
		if (bLogSettingsChange) log("EBN_TimeBetRound change");
#endif
    }

	iTempValue = m_pButtonsDef.GetButtonCounterValue( EButtonName.EBN_NB_Players, pTempButList);
	if ( (iTempValue>-1) && iTempValue != pGameRepInfo.m_MaxPlayers)
    {
        bSettingsChange = true;
		pPlayContr.ServerNewGeneralSettings( EBN_NB_Players, , iTempValue);
#ifdefDEBUG
		if (bLogSettingsChange) log("EBN_NB_Players change");
#endif
    }
/*
	if (m_pButtonsDef.FindButtonItem( EButtonName.EBN_InternetServer, pTempButList) != None)
	{
		bTempValue = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_InternetServer, pTempButList);
		if ( bTempValue != pGameRepInfo.m_bInternetSvr)
    	{
	        bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings( EBN_InternetServer, bTempValue,);
#ifdefDEBUG
			if (bLogSettingsChange) log("EBN_InternetServer change");
#endif
    	}
	}

	bTempValue = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_DedicatedServer, pTempButList);
	if ( bTempValue != pGameRepInfo.m_bDedicatedSvr)
    {
        bSettingsChange = true;
		pPlayContr.ServerNewGeneralSettings( EBN_DedicatedServer, bTempValue, );
#ifdefDEBUG
		if (bLogSettingsChange) log("EBN_DedicatedServer change");
#endif
    }
*/

	bTempValue = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_FriendlyFire, pTempButList);
	if ( bTempValue != pGameRepInfo.m_bFriendlyFire)
    {
        bSettingsChange = true;
		pPlayContr.ServerNewGeneralSettings( EBN_FriendlyFire, bTempValue, );
#ifdefDEBUG
		if (bLogSettingsChange) log("EBN_FriendlyFire change");
#endif
    }

	if (m_pButtonsDef.FindButtonItem( EButtonName.EBN_TKPenalty, pTempButList) != None)
	{
    if (m_pButtonsDef.IsButtonBoxDisabled( EButtonName.EBN_TKPenalty, pTempButList))
        bTempValue = m_bBkpTKPenalty; 
    else
        bTempValue = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_TKPenalty, pTempButList);

	if ( bTempValue != pGameRepInfo.m_bMenuTKPenaltySetting)
    {
        bSettingsChange = true;
		pPlayContr.ServerNewGeneralSettings( EBN_TKPenalty, bTempValue, );
#ifdefDEBUG
			if (bLogSettingsChange) log("EBN_TKPenalty change");
#endif
		}
    }

	if (m_pButtonsDef.FindButtonItem( EButtonName.EBN_AllowRadar, pTempButList) != None)
	{
		bTempValue = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_AllowRadar, pTempButList);
		if ( bTempValue != pGameRepInfo.m_bRepAllowRadarOption)
  	  {
   	     bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings( EBN_AllowRadar, bTempValue, );
#ifdefDEBUG
			if (bLogSettingsChange) log("EBN_AllowRadar change");
#endif
   	 }
	}

	if (m_pButtonsDef.FindButtonItem( EButtonName.EBN_AllowTeamNames, pTempButList) != None)
	{
		bTempValue = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_AllowTeamNames, pTempButList);
		if ( bTempValue != pGameRepInfo.m_bShowNames)
  	  	{
        	bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings( EBN_AllowTeamNames, bTempValue, );
#ifdefDEBUG
			if (bLogSettingsChange) log("EBN_AllowTeamNames change");
#endif
    	}
	}

	if (m_pButtonsDef.FindButtonItem( EButtonName.EBN_ForceFPersonWp, pTempButList) != None)
	{
		bTempValue = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_ForceFPersonWp, pTempButList);
		if ( bTempValue != pGameRepInfo.m_bFFPWeapon)
    	{
	        bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings( EBN_ForceFPersonWp, bTempValue, );
#ifdefDEBUG
			if (bLogSettingsChange) log("EBN_ForceFPersonWp change");
#endif
    	}
	}

	bTempValue =  GetCameraSelection( EButtonName.EBN_CamFirstPerson, pTempCamList);
	if ( bTempValue != ( ( pGameRepInfo.m_iDeathCameraMode & 0x01) > 0 ))
    {
        bSettingsChange = true;
		pPlayContr.ServerNewGeneralSettings( EBN_CamFirstPerson, bTempValue, );
#ifdefDEBUG
		if (bLogSettingsChange) log("EBN_CamFirstPerson change");
#endif
    }

	bTempValue = GetCameraSelection( EButtonName.EBN_CamThirdPerson, pTempCamList);
	if ( bTempValue != ( ( pGameRepInfo.m_iDeathCameraMode & 0x02) > 0 ))
    {
        bSettingsChange = true;
		pPlayContr.ServerNewGeneralSettings( EBN_CamThirdPerson, bTempValue, );    
#ifdefDEBUG
		if (bLogSettingsChange) log("EBN_CamThirdPerson change");
#endif
    }

	bTempValue = GetCameraSelection( EButtonName.EBN_CamFreeThirdP, pTempCamList);
	if ( bTempValue != ( ( pGameRepInfo.m_iDeathCameraMode & 0x04) > 0 ))
    {
        bSettingsChange = true;
		pPlayContr.ServerNewGeneralSettings( EBN_CamFreeThirdP, bTempValue, );
#ifdefDEBUG
		if (bLogSettingsChange) log("EBN_CamFreeThirdP change");
#endif
    }
    
	bTempValue = GetCameraSelection( EButtonName.EBN_CamGhost, pTempCamList);
	if ( bTempValue != ( ( pGameRepInfo.m_iDeathCameraMode & 0x08) > 0 ))
    {
        bSettingsChange = true;
		pPlayContr.ServerNewGeneralSettings( EBN_CamGhost, bTempValue, );
#ifdefDEBUG
		if (bLogSettingsChange) log("EBN_CamGhost change");
#endif
    }
    

	if (m_pOptionsGameMode.GetValue2() == string(m_ANbOfGameMode[0]))
	{
		bTempValue = GetCameraSelection( EButtonName.EBN_CamFadeToBk, pTempCamList);
		if ( bTempValue != ( ( pGameRepInfo.m_iDeathCameraMode & 0x10) > 0 ))
        {
            bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings( EBN_CamFadeToBk, bTempValue, );
#ifdefDEBUG
			if (bLogSettingsChange) log("EBN_CamFadeToBk change");
#endif
        }
    
		bTempValue = GetCameraSelection( EButtonName.EBN_CamTeamOnly, pTempCamList);
		if ( bTempValue != ( ( pGameRepInfo.m_iDeathCameraMode & 0x20) > 0 ))
        {
            bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings( EBN_CamTeamOnly, bTempValue, );
#ifdefDEBUG
			if (bLogSettingsChange) log("EBN_CamTeamOnly change");
#endif
        }
        
#ifndefMPDEMO
		iTempValue = m_pButtonsDef.GetButtonCounterValue( EButtonName.EBN_BombTimer, pTempButList);
		if ( iTempValue != pGameRepInfo.m_fBombTime)
        {
            bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings( EBN_BombTimer, , iTempValue);

			if (bLogSettingsChange) log("EBN_BombTimer change");
        }
#endif
		iTempValue = m_pButtonsDef.GetButtonCounterValue( EButtonName.EBN_RoundPerMatch, pTempButList);
		if ( iTempValue != pGameRepInfo.m_iRoundsPerMatch)
        {
            bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings( EBN_RoundPerMatch, , iTempValue);
#ifdefDEBUG
			if (bLogSettingsChange) log("EBN_RoundPerMatch change");
#endif
        }

		bTempValue = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_AutoBalTeam, pTempButList);
		if ( bTempValue != pGameRepInfo.m_bAutoBalance)
        {
            bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings( EBN_AutoBalTeam, bTempValue, );
#ifdefDEBUG
			if (bLogSettingsChange) log("EBN_RoundTime change");
#endif
        }
	}
	else
	{
		iTempValue = m_pButtonsDef.GetButtonCounterValue( EButtonName.EBN_RoundPerMission, pTempButList);
		if ( iTempValue != pGameRepInfo.m_iRoundsPerMatch)
        {
            bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings( EBN_RoundPerMission, , iTempValue);
#ifdefDEBUG
			if (bLogSettingsChange) log("EBN_RoundPerMission change");
#endif
        }

		iTempValue = m_pButtonsDef.GetButtonCounterValue( EButtonName.EBN_NB_of_Terro, pTempButList);
		if ( iTempValue != pGameRepInfo.m_iNbOfTerro)
        {
            bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings( EBN_NB_of_Terro, , iTempValue);
#ifdefDEBUG
			if (bLogSettingsChange) log("EBN_NB_of_Terro change");
#endif
        }

		bTempValue = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_AIBkp, pTempButList);
		if ( bTempValue != pGameRepInfo.m_bAIBkp)
        {
            bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings( EBN_AIBkp, bTempValue, );
#ifdefDEBUG
			if (bLogSettingsChange) log("EBN_AIBkp change");
#endif
        }

		bTempValue = m_pButtonsDef.GetButtonBoxValue( EButtonName.EBN_RotateMap, pTempButList);
		if ( bTempValue != pGameRepInfo.m_bRotateMap)
        {
            bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings( EBN_RotateMap, bTempValue, );
#ifdefDEBUG
			if (bLogSettingsChange) log("EBN_RotateMap change");
#endif
        }

		iTempValue = INT(m_pButtonsDef.GetButtonComboValue( EButtonName.EBN_DiffLevel, pTempButList));
		if ( iTempValue != pGameRepInfo.m_iDiffLevel)
        {
            bSettingsChange = true;
			pPlayContr.ServerNewGeneralSettings( EBN_DiffLevel, , iTempValue);
#ifdefDEBUG
			if (bLogSettingsChange) log("EBN_DiffLevel change");
#endif
        }

	}

	return bSettingsChange;
}

//=================================================================================
// SendNewMapSettings: Send the new map server settings to the server, only the change values. 
//					   If no modification was made return false 
//=================================================================================
function BOOL SendNewMapSettings(OUT BYTE _bMapCount)
{
    local R6MenuInGameMultiPlayerRootWindow R6Root;
	local R6GameReplicationInfo				R6GameRepInfo;
	local R6PlayerController				pPlayContr;
	local string szCurrentSrvMap, szMenuMap, szCurrentSrvGameType, szMenuGameType;
	local INT i, iTotFinalListItem, iTotGameRepItem, iTotalMax, iLastValidItem, iUpdate;
	local BOOL bSettingsChange;


	if (!m_bServerSettingsChange)
		return false;

	R6Root		  = R6MenuInGameMultiPlayerRootWindow(Root);
	R6GameRepInfo = R6GameReplicationInfo(R6Root.m_R6GameMenuCom.m_GameRepInfo);
	pPlayContr	  = R6PlayerController(GetPlayerOwner());

	// Create list of selected maps
    _bMapCount = FillSelectedMapList();
    if (_bMapCount==0)
        return true;

	// assign the total item find for server list and menu list
    for ( i = 0; (i < R6GameRepInfo.m_MapLength) && (R6GameRepInfo.m_mapArray[i] != ""); i++ )
	{
	}

	iTotGameRepItem   = i;
	iTotFinalListItem = m_SelectedMapList.length;	

    if (iTotFinalListItem>32)
        iTotFinalListItem = 32;
	iTotalMax = iTotFinalListItem; //Max( iTotGameRepItem, iTotFinalListItem) - 1; // - 1 --> array start at 0


	// do comparison and send the one that was modify
	// the original list and the final list could have different sizes
	for( i =0; i < iTotalMax; i++)
	{
		szCurrentSrvMap = R6GameRepInfo.m_mapArray[i];
		szMenuMap = m_SelectedMapList[i];
		szCurrentSrvGameType = GetLevel().GetGameTypeFromClassName(R6GameRepInfo.m_gameModeArray[i]);
		szMenuGameType = m_SelectedModeList[i];


		iUpdate = 0;
		if(szCurrentSrvMap != szMenuMap)
			iUpdate += 1;

		if(szCurrentSrvGameType != szMenuGameType)
			iUpdate += 2;

		if (iUpdate != 0)
		{
//			log("Map / Game type change!!!!"@szTempMenu@szR6TempMenu@"iUpdate ="@iUpdate);
			pPlayContr.ServerNewMapListSettings(i, iUpdate, GetLevel().GetGameTypeClassName(szMenuGameType), szMenuMap);
			bSettingsChange = true;
		}
	}

	// remove the map and gametype that was not in the menu list (on srv side)
	if ( iTotGameRepItem > iTotFinalListItem)
	{
//		log("Map / Game type was remove");
		pPlayContr.ServerNewMapListSettings(i, 0, GetLevel().GetGameTypeClassName(szMenuGameType), szMenuMap, i);
		bSettingsChange = true;
	}

	return bSettingsChange;
}


//=================================================================================
// Notify: Overload parent notify to avoid button selection, except for the host of the game
//=================================================================================
function Notify(UWindowDialogControl C, byte E)
{
//    log("Notify from class: "$C);
//    log("Notify msg: "$E);

	if (!m_bImAnAdmin)
	{
		if (E == DE_Change)
		{
			// the value of a combo control change?
			if (C.IsA('UWindowComboControl'))
			{
				ManageComboControlNotify(C); // this is set the current game mode buttons, map list, etc
			}
		}
		return;
	}

	if (C.IsA('R6WindowButton'))
    {
        ManageR6ButtonNotify(C, E);
    }
	else if(E == DE_Click)
	{
        // Change Current Selected Button
        if ( C.IsA('R6WindowButtonBox'))
        {
            ManageR6ButtonBoxNotify(C);
        }
        else if (C.IsA('R6WindowButtonAndEditBox'))
        {
            ManageR6ButtonAndEditBoxNotify(C);
        }
    }
    else if (E == DE_Change)
    {
        // the value of a combo control change?
        if (C.IsA('UWindowComboControl'))
        {
            ManageComboControlNotify(C); 
        }
    }

	if (m_bInitComplete)
		m_bServerSettingsChange = true;
}

defaultproperties
{
}
