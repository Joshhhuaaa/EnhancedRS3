class ASMenuMPServerOption extends ASMenuMPCreateGameTabOptions;

var bool m_bServerSettingsChange;
var bool m_bImAnAdmin;
var UWindowWindow m_pServerOptFakeW;
var UWindowWindow m_pServerOptFakeW2;
var R6WindowTextLabel m_InTheReleaseLabel;

function Created()
{
    super(R6MenuMPCreateGameTabOptions).Created();
    m_pServerOptFakeW = CreateWindow(Class'UWindow.UWindowWindow', 0.0, 0.0, WinWidth * 0.5, WinHeight, self);
    m_pServerOptFakeW.bAlwaysOnTop = true;
    m_pServerOptFakeW2 = CreateWindow(Class'UWindow.UWindowWindow', 310.0, 136.0, WinWidth * 0.5, WinHeight - float(136), self);
    m_pServerOptFakeW2.bAlwaysOnTop = true;
    InitOptionsTab(true);
    Refresh();
}

function Refresh()
{
    if(R6PlayerController(GetPlayerOwner()).CheckAuthority(R6PlayerController(GetPlayerOwner()).Authority_Admin))
    {
        if(m_bImAnAdmin == false)
        {
            m_bImAnAdmin = true;
            R6PlayerController(GetPlayerOwner()).ServerPausePreGameRoundTime();
        }
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

function RefreshServerOpt(optional bool _bNewServerProfile)
{
    local int iIndex;
    local R6GameReplicationInfo pGameRepInfo;
    local R6MenuMapList pCurrentMapList;

    Refresh();
    pGameRepInfo = R6GameReplicationInfo(R6MenuInGameMultiPlayerRootWindow(Root).m_R6GameMenuCom.m_GameRepInfo);
    if(m_bInitComplete)
    {
        UpdateAllMapList();
    }
    pCurrentMapList = R6MenuMapList(GetList(GetCurrentGameMode(), eCGW_MapList));
    m_pOptionsGameMode.SetValue(m_pOptionsGameMode.GetValue(), pCurrentMapList.GetNewServerProfileGameMode(true));
    ManageComboControlNotify(m_pOptionsGameMode);
    pCurrentMapList = R6MenuMapList(GetList(GetCurrentGameMode(), eCGW_MapList));
    iIndex = m_pOptionsGameMode.FindItemIndex2(pCurrentMapList.FillFinalMapListInGame());
    m_pOptionsGameMode.SetSelectedIndex(iIndex);
    m_pOptionsGameMode.SetDisableButton(true);
    m_pServerNameEdit.SetValue(pGameRepInfo.ServerName);
    SetButtonAndEditBox(eCGW_Password, "*******", pGameRepInfo.m_bPasswordReq);
    R6WindowButtonAndEditBox(GetList(GetCurrentGameMode(), eCGW_Password)).SetDisableButtonAndEditBox(true);
    SetButtonAndEditBox(eCGW_AdminPassword, "*******", pGameRepInfo.m_bAdminPasswordReq);
    R6WindowButtonAndEditBox(GetList(GetCurrentGameMode(), eCGW_AdminPassword)).SetDisableButtonAndEditBox(true);
    m_szMsgOfTheDay = pGameRepInfo.MOTDLine1;
    RefreshCGButtons();
}

function UpdateButtons(Actor.EGameModeInfo _eGameMode, R6MenuMPCreateGameTab.eCreateGameWindow_ID _eCGWindowID, optional bool _bUpdateValue)
{
    local R6WindowListGeneral pTempList;
    local R6GameReplicationInfo pR6GameRepInfo;

    if(_bUpdateValue)
    {
        pTempList = R6WindowListGeneral(GetList(_eGameMode, _eCGWindowID));
        if(pTempList == none)
        {
            return;
        }
        pR6GameRepInfo = R6GameReplicationInfo(R6MenuInGameMultiPlayerRootWindow(Root).m_R6GameMenuCom.m_GameRepInfo);
        switch(_eGameMode)
        {
            case m_ANbOfGameMode[0]:
                switch(_eCGWindowID)
                {
                    case eCGW_Opt:
                        m_pButtonsDef.ChangeButtonComboValue(EButtonName.EBN_InternetServer, string(pR6GameRepInfo.m_bInternetSvr), pTempList, true);
                        m_pButtonsDef.ChangeButtonComboValue(EButtonName.EBN_DiffLevel, string(pR6GameRepInfo.m_iDiffLevel), pTempList, !m_bImAnAdmin);
                        m_pButtonsDef.ChangeButtonCounterValue(EButtonName.EBN_RoundPerMatch, pR6GameRepInfo.m_iRoundsPerMatch, pTempList, !m_bImAnAdmin);
                        m_pButtonsDef.ChangeButtonCounterValue(EButtonName.EBN_RoundTime, pR6GameRepInfo.TimeLimit / 60, pTempList, !m_bImAnAdmin);
                        m_pButtonsDef.ChangeButtonCounterValue(EButtonName.EBN_TimeBetRound, int(pR6GameRepInfo.m_fTimeBetRounds), pTempList, !m_bImAnAdmin);
                        m_pButtonsDef.ChangeButtonCounterValue(EButtonName.EBN_NB_Players, pR6GameRepInfo.m_MaxPlayers, pTempList, !m_bImAnAdmin);
                        m_pButtonsDef.ChangeButtonCounterValue(EButtonName.EBN_NB_of_Terro, pR6GameRepInfo.m_iNbOfTerro, pTempList, !m_bImAnAdmin);
                        m_pButtonsDef.ChangeButtonCounterValue(EButtonName.EBN_BombTimer, int(pR6GameRepInfo.m_fBombTime), pTempList, !m_bImAnAdmin);
                        m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_DedicatedServer, pR6GameRepInfo.m_bDedicatedSvr, pTempList, true);
                        m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_FriendlyFire, pR6GameRepInfo.m_bFriendlyFire, pTempList);
                        m_bBkpTKPenalty = pR6GameRepInfo.m_bMenuTKPenaltySetting;
                        m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_TKPenalty, pR6GameRepInfo.m_bMenuTKPenaltySetting, pTempList);
                        m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_AutoBalTeam, pR6GameRepInfo.m_bAutoBalance, pTempList);
                        UpdateMenuOptions(EButtonName.EBN_FriendlyFire, pR6GameRepInfo.m_bFriendlyFire, pTempList);
                        break;
                    case eCGW_Camera:
                        UpdateCamera(EButtonName.EBN_CamFadeToBk, (pR6GameRepInfo.m_iDeathCameraMode & 16) > 0, false, pTempList);
                        UpdateCamera(EButtonName.EBN_CamFirstPerson, (pR6GameRepInfo.m_iDeathCameraMode & 1) > 0, false, pTempList, true);
                        UpdateCamera(EButtonName.EBN_CamThirdPerson, (pR6GameRepInfo.m_iDeathCameraMode & 2) > 0, false, pTempList, true);
                        UpdateCamera(EButtonName.EBN_CamFreeThirdP, (pR6GameRepInfo.m_iDeathCameraMode & 4) > 0, false, pTempList, true);
                        UpdateCamera(EButtonName.EBN_CamGhost, (pR6GameRepInfo.m_iDeathCameraMode & 8) > 0, false, pTempList, true);
                        UpdateCamera(EButtonName.EBN_CamTeamOnly, (pR6GameRepInfo.m_iDeathCameraMode & 32) > 0, false, pTempList, true);
                        UpdateCamSpecialCase((pR6GameRepInfo.m_iDeathCameraMode & 32) > 0, false);
                        UpdateCamSpecialCase((pR6GameRepInfo.m_iDeathCameraMode & 16) > 0, true);
                        break;
                    default:
                        break;
                }
                break;
            case m_ANbOfGameMode[1]:
                switch(_eCGWindowID)
                {
                    case eCGW_Opt:
                        m_pButtonsDef.ChangeButtonComboValue(EButtonName.EBN_InternetServer, string(pR6GameRepInfo.m_bInternetSvr), pTempList, true);
                        m_pButtonsDef.ChangeButtonComboValue(EButtonName.EBN_DiffLevel, string(pR6GameRepInfo.m_iDiffLevel), pTempList);
                        m_pButtonsDef.ChangeButtonCounterValue(EButtonName.EBN_RoundPerMission, pR6GameRepInfo.m_iRoundsPerMatch, pTempList);
                        m_pButtonsDef.ChangeButtonCounterValue(EButtonName.EBN_RoundTime, pR6GameRepInfo.TimeLimit / 60, pTempList);
                        m_pButtonsDef.ChangeButtonCounterValue(EButtonName.EBN_TimeBetRound, int(pR6GameRepInfo.m_fTimeBetRounds), pTempList);
                        m_pButtonsDef.ChangeButtonCounterValue(EButtonName.EBN_NB_Players, pR6GameRepInfo.m_MaxPlayers, pTempList);
                        m_pButtonsDef.ChangeButtonCounterValue(EButtonName.EBN_NB_of_Terro, pR6GameRepInfo.m_iNbOfTerro, pTempList);
                        m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_DedicatedServer, pR6GameRepInfo.m_bDedicatedSvr, pTempList, true);
                        m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_AIBkp, pR6GameRepInfo.m_bAIBkp, pTempList);
                        m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_RotateMap, pR6GameRepInfo.m_bRotateMap, pTempList);
                        m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_FriendlyFire, pR6GameRepInfo.m_bFriendlyFire, pTempList);
                        break;
                    case eCGW_Camera:
                        UpdateCamera(EButtonName.EBN_CamFirstPerson, (pR6GameRepInfo.m_iDeathCameraMode & 1) > 0, false, pTempList);
                        UpdateCamera(EButtonName.EBN_CamThirdPerson, (pR6GameRepInfo.m_iDeathCameraMode & 2) > 0, false, pTempList);
                        UpdateCamera(EButtonName.EBN_CamFreeThirdP, (pR6GameRepInfo.m_iDeathCameraMode & 4) > 0, false, pTempList);
                        UpdateCamera(EButtonName.EBN_CamGhost, (pR6GameRepInfo.m_iDeathCameraMode & 8) > 0, false, pTempList);
                        break;
                    default:
                        break;
                }
                break;
            default:
                break;
        }
    }
    else
    {
        super.UpdateButtons(_eGameMode, _eCGWindowID, _bUpdateValue);
    }
}

function bool SendNewServerSettings()
{
    local R6GameReplicationInfo pGameRepInfo;
    local R6PlayerController pPlayContr;
    local R6WindowListGeneral pTempButList, pTempCamList;
    local int iTempValue;
    local bool bTempValue, bSettingsChange;

    if(!m_bServerSettingsChange)
    {
        return false;
    }
    pTempButList = R6WindowListGeneral(GetList(GetCurrentGameMode(), eCGW_Opt));
    pTempCamList = R6WindowListGeneral(GetList(GetCurrentGameMode(), eCGW_Camera));
    pGameRepInfo = R6GameReplicationInfo(R6MenuInGameMultiPlayerRootWindow(Root).m_R6GameMenuCom.m_GameRepInfo);
    pPlayContr = R6PlayerController(GetPlayerOwner());
    if((((pTempButList == none) || pTempCamList == none) || pGameRepInfo == none) || pPlayContr == none)
    {
        return false;
    }
    iTempValue = m_pButtonsDef.GetButtonCounterValue(EButtonName.EBN_RoundTime, pTempButList);
    if(iTempValue != (pGameRepInfo.TimeLimit / 60))
    {
        bSettingsChange = true;
        pPlayContr.ServerNewGeneralSettings(EBN_RoundTime,, iTempValue * 60);
    }
    iTempValue = m_pButtonsDef.GetButtonCounterValue(EButtonName.EBN_TimeBetRound, pTempButList);
    if(float(iTempValue) != pGameRepInfo.m_fTimeBetRounds)
    {
        bSettingsChange = true;
        pPlayContr.ServerNewGeneralSettings(EBN_TimeBetRound,, iTempValue) || bSettingsChange;
    }
    iTempValue = m_pButtonsDef.GetButtonCounterValue(EButtonName.EBN_NB_Players, pTempButList);
    if((iTempValue > -1) && iTempValue != pGameRepInfo.m_MaxPlayers)
    {
        bSettingsChange = true;
        pPlayContr.ServerNewGeneralSettings(EBN_NB_Players,, iTempValue);
    }
    if(m_pButtonsDef.FindButtonItem(EButtonName.EBN_InternetServer, pTempButList) != none)
    {
        bTempValue = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_InternetServer, pTempButList);
        if(bTempValue != pGameRepInfo.m_bInternetSvr)
        {
            bSettingsChange = true;
            pPlayContr.ServerNewGeneralSettings(EBN_InternetServer, bTempValue);
        }
    }
    bTempValue = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_DedicatedServer, pTempButList);
    if(bTempValue != pGameRepInfo.m_bDedicatedSvr)
    {
        bSettingsChange = true;
        pPlayContr.ServerNewGeneralSettings(EBN_DedicatedServer, bTempValue);
    }
    bTempValue = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_FriendlyFire, pTempButList);
    if(bTempValue != pGameRepInfo.m_bFriendlyFire)
    {
        bSettingsChange = true;
        pPlayContr.ServerNewGeneralSettings(EBN_FriendlyFire, bTempValue);
    }
    if(m_pButtonsDef.IsButtonBoxDisabled(EButtonName.EBN_TKPenalty, pTempButList))
    {
        bTempValue = m_bBkpTKPenalty;
    }
    else
    {
        bTempValue = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_TKPenalty, pTempButList);
    }
    if(bTempValue != pGameRepInfo.m_bMenuTKPenaltySetting)
    {
        bSettingsChange = true;
        pPlayContr.ServerNewGeneralSettings(EBN_TKPenalty, bTempValue);
    }
    if(m_pButtonsDef.FindButtonItem(EButtonName.EBN_AllowRadar, pTempButList) != none)
    {
        bTempValue = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_AllowRadar, pTempButList);
        if(bTempValue != pGameRepInfo.m_bRepAllowRadarOption)
        {
            bSettingsChange = true;
            pPlayContr.ServerNewGeneralSettings(EBN_AllowRadar, bTempValue);
        }
    }
    if(m_pButtonsDef.FindButtonItem(EButtonName.EBN_AllowTeamNames, pTempButList) != none)
    {
        bTempValue = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_AllowTeamNames, pTempButList);
        if(bTempValue != pGameRepInfo.m_bShowNames)
        {
            bSettingsChange = true;
            pPlayContr.ServerNewGeneralSettings(EBN_AllowTeamNames, bTempValue);
        }
    }
    if(m_pButtonsDef.FindButtonItem(EButtonName.EBN_ForceFPersonWp, pTempButList) != none)
    {
        bTempValue = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_ForceFPersonWp, pTempButList);
        if(bTempValue != pGameRepInfo.m_bFFPWeapon)
        {
            bSettingsChange = true;
            pPlayContr.ServerNewGeneralSettings(EBN_ForceFPersonWp, bTempValue);
        }
    }
    bTempValue = GetCameraSelection(EButtonName.EBN_CamFirstPerson, pTempCamList);
    if(bTempValue != ((pGameRepInfo.m_iDeathCameraMode & 1) > 0))
    {
        bSettingsChange = true;
        pPlayContr.ServerNewGeneralSettings(EBN_CamFirstPerson, bTempValue);
    }
    bTempValue = GetCameraSelection(EButtonName.EBN_CamThirdPerson, pTempCamList);
    if(bTempValue != ((pGameRepInfo.m_iDeathCameraMode & 2) > 0))
    {
        bSettingsChange = true;
        pPlayContr.ServerNewGeneralSettings(EBN_CamThirdPerson, bTempValue);
    }
    bTempValue = GetCameraSelection(EButtonName.EBN_CamFreeThirdP, pTempCamList);
    if(bTempValue != ((pGameRepInfo.m_iDeathCameraMode & 4) > 0))
    {
        bSettingsChange = true;
        pPlayContr.ServerNewGeneralSettings(EBN_CamFreeThirdP, bTempValue);
    }
    bTempValue = GetCameraSelection(EButtonName.EBN_CamGhost, pTempCamList);
    if(bTempValue != ((pGameRepInfo.m_iDeathCameraMode & 8) > 0))
    {
        bSettingsChange = true;
        pPlayContr.ServerNewGeneralSettings(EBN_CamGhost, bTempValue);
    }
    if(m_pOptionsGameMode.GetValue2() == string(m_ANbOfGameMode[0]))
    {
        bTempValue = GetCameraSelection(EButtonName.EBN_CamFadeToBk, pTempCamList);
        if(bTempValue != ((pGameRepInfo.m_iDeathCameraMode & 16) > 0))
        {
            bSettingsChange = true;
            pPlayContr.ServerNewGeneralSettings(EBN_CamFadeToBk, bTempValue);
        }
        bTempValue = GetCameraSelection(EButtonName.EBN_CamTeamOnly, pTempCamList);
        if(bTempValue != ((pGameRepInfo.m_iDeathCameraMode & 32) > 0))
        {
            bSettingsChange = true;
            pPlayContr.ServerNewGeneralSettings(EBN_CamTeamOnly, bTempValue);
        }
        iTempValue = m_pButtonsDef.GetButtonCounterValue(EButtonName.EBN_BombTimer, pTempButList);
        if(float(iTempValue) != pGameRepInfo.m_fBombTime)
        {
            bSettingsChange = true;
            pPlayContr.ServerNewGeneralSettings(EBN_BombTimer,, iTempValue);
        }
        iTempValue = m_pButtonsDef.GetButtonCounterValue(EButtonName.EBN_RoundPerMatch, pTempButList);
        if(iTempValue != pGameRepInfo.m_iRoundsPerMatch)
        {
            bSettingsChange = true;
            pPlayContr.ServerNewGeneralSettings(EBN_RoundPerMatch,, iTempValue);
        }
        bTempValue = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_AutoBalTeam, pTempButList);
        if(bTempValue != pGameRepInfo.m_bAutoBalance)
        {
            bSettingsChange = true;
            pPlayContr.ServerNewGeneralSettings(EBN_AutoBalTeam, bTempValue);
        }
        iTempValue = m_pButtonsDef.GetButtonCounterValue(EButtonName.EBN_NB_of_Terro, pTempButList);
        if(iTempValue != pGameRepInfo.m_iNbOfTerro)
        {
            bSettingsChange = true;
            pPlayContr.ServerNewGeneralSettings(EBN_NB_of_Terro,, iTempValue);
        }
        iTempValue = int(m_pButtonsDef.GetButtonComboValue(EButtonName.EBN_DiffLevel, pTempButList));
        if(iTempValue != pGameRepInfo.m_iDiffLevel)
        {
            bSettingsChange = true;
            pPlayContr.ServerNewGeneralSettings(EBN_DiffLevel,, iTempValue);
        }
    }
    else
    {
        iTempValue = m_pButtonsDef.GetButtonCounterValue(EButtonName.EBN_RoundPerMission, pTempButList);
        if(iTempValue != pGameRepInfo.m_iRoundsPerMatch)
        {
            bSettingsChange = true;
            pPlayContr.ServerNewGeneralSettings(EBN_RoundPerMission,, iTempValue);
        }
        iTempValue = m_pButtonsDef.GetButtonCounterValue(EButtonName.EBN_NB_of_Terro, pTempButList);
        if(iTempValue != pGameRepInfo.m_iNbOfTerro)
        {
            bSettingsChange = true;
            pPlayContr.ServerNewGeneralSettings(EBN_NB_of_Terro,, iTempValue);
        }
        bTempValue = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_AIBkp, pTempButList);
        if(bTempValue != pGameRepInfo.m_bAIBkp)
        {
            bSettingsChange = true;
            pPlayContr.ServerNewGeneralSettings(EBN_AIBkp, bTempValue);
        }
        bTempValue = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_RotateMap, pTempButList);
        if(bTempValue != pGameRepInfo.m_bRotateMap)
        {
            bSettingsChange = true;
            pPlayContr.ServerNewGeneralSettings(EBN_RotateMap, bTempValue);
        }
        iTempValue = int(m_pButtonsDef.GetButtonComboValue(EButtonName.EBN_DiffLevel, pTempButList));
        if(iTempValue != pGameRepInfo.m_iDiffLevel)
        {
            bSettingsChange = true;
            pPlayContr.ServerNewGeneralSettings(EBN_DiffLevel,, iTempValue);
        }
    }
    return bSettingsChange;
}

function bool SendNewMapSettings(out byte _bMapCount)
{
    local R6MenuInGameMultiPlayerRootWindow r6Root;
    local R6GameReplicationInfo R6GameRepInfo;
    local R6PlayerController pPlayContr;
    local string szCurrentSrvMap, szMenuMap, szCurrentSrvGameType, szMenuGameType;
    local int i, iTotFinalListItem, iTotGameRepItem, iTotalMax, iLastValidItem, iUpdate;

    local bool bSettingsChange;

    if(!m_bServerSettingsChange)
    {
        return false;
    }
    r6Root = R6MenuInGameMultiPlayerRootWindow(Root);
    R6GameRepInfo = R6GameReplicationInfo(r6Root.m_R6GameMenuCom.m_GameRepInfo);
    pPlayContr = R6PlayerController(GetPlayerOwner());
    _bMapCount = FillSelectedMapList();
    if(int(_bMapCount) == 0)
    {
        return true;
    }

    for(i = 0; (i < R6GameRepInfo.m_MapLength) && R6GameRepInfo.m_mapArray[i] != ""; i++)
    {
    }
    iTotGameRepItem = i;
    iTotFinalListItem = m_SelectedMapList.Length;
    if(iTotFinalListItem > 32)
    {
        iTotFinalListItem = 32;
    }
    iTotalMax = iTotFinalListItem;

    for(i = 0; i < iTotalMax; i++)
    {
        szCurrentSrvMap = R6GameRepInfo.m_mapArray[i];
        szMenuMap = m_SelectedMapList[i];
        szCurrentSrvGameType = GetLevel().GetGameTypeFromClassName(R6GameRepInfo.m_gameModeArray[i]);
        szMenuGameType = m_SelectedModeList[i];
        iUpdate = 0;
        if(szCurrentSrvMap != szMenuMap)
        {
            iUpdate += 1;
        }
        if(szCurrentSrvGameType != szMenuGameType)
        {
            iUpdate += 2;
        }
        if(iUpdate != 0)
        {
            pPlayContr.ServerNewMapListSettings(i, iUpdate, GetLevel().GetGameTypeClassName(szMenuGameType), szMenuMap);
            bSettingsChange = true;
        }
    }
    if(iTotGameRepItem > iTotFinalListItem)
    {
        pPlayContr.ServerNewMapListSettings(i, 0, GetLevel().GetGameTypeClassName(szMenuGameType), szMenuMap, i);
        bSettingsChange = true;
    }
    return bSettingsChange;
}

function Notify(UWindowDialogControl C, byte E)
{
    if(!m_bImAnAdmin)
    {
        if(int(E) == 1)
        {
            if(C.IsA('UWindowComboControl'))
            {
                ManageComboControlNotify(C);
            }
        }
        return;
    }
    if(C.IsA('R6WindowButton'))
    {
        ManageR6ButtonNotify(C, E);
    }
    else
    {
        if(int(E) == DE_Click)
        {
            if(C.IsA('R6WindowButtonBox'))
            {
                ManageR6ButtonBoxNotify(C);
            }
            else
            {
                if(C.IsA('R6WindowButtonAndEditBox'))
                {
                    ManageR6ButtonAndEditBoxNotify(C);
                }
            }
        }
        else
        {
            if(int(E) == DE_Change)
            {
                if(C.IsA('UWindowComboControl'))
                {
                    ManageComboControlNotify(C);
                }
            }
        }
    }
    if(m_bInitComplete)
    {
        m_bServerSettingsChange = true;
    }
}
