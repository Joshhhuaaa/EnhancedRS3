class ASMenuMPCreateGameTabOptions extends R6MenuMPCreateGameTabOptions;

function string GetCreateGamePassword()
{
    local UWindowWindow pButton;

    pButton = GetList(GetCurrentGameMode(), eCGW_Password);
    if((pButton != none) && R6WindowButtonAndEditBox(pButton).m_pEditBox != none)
    {
        return R6WindowButtonAndEditBox(pButton).m_pEditBox.GetValue();
    }
    return "";
}

function UpdateButtons(Actor.EGameModeInfo _eGameMode, R6MenuMPCreateGameTab.eCreateGameWindow_ID _eCGWindowID, optional bool _bUpdateValue)
{
    local R6WindowListGeneral pTempList;
    local R6ServerInfo pServerInfo;

    pTempList = R6WindowListGeneral(GetList(_eGameMode, _eCGWindowID));
    if(pTempList == none)
    {
        return;
    }
    if(_bUpdateValue)
    {
        pServerInfo = class'Actor'.static.GetServerOptions();
    }
    switch(_eGameMode)
    {
        case m_ANbOfGameMode[0]:
            switch(_eCGWindowID)
            {
                case eCGW_Opt:
                    if(_bUpdateValue)
                    {
                        m_pButtonsDef.ChangeButtonComboValue(EButtonName.EBN_InternetServer, string(pServerInfo.InternetServer), pTempList);
                        m_pButtonsDef.ChangeButtonComboValue(EButtonName.EBN_DiffLevel, string(pServerInfo.DiffLevel), pTempList);
                        m_pButtonsDef.ChangeButtonCounterValue(EButtonName.EBN_RoundPerMatch, pServerInfo.RoundsPerMatch, pTempList);
                        m_pButtonsDef.ChangeButtonCounterValue(EButtonName.EBN_RoundTime, pServerInfo.RoundTime / 60, pTempList);
                        m_pButtonsDef.ChangeButtonCounterValue(EButtonName.EBN_TimeBetRound, pServerInfo.BetweenRoundTime, pTempList);
                        m_pButtonsDef.ChangeButtonCounterValue(EButtonName.EBN_NB_Players, pServerInfo.MaxPlayers, pTempList);
                        m_pButtonsDef.ChangeButtonCounterValue(EButtonName.EBN_BombTimer, pServerInfo.BombTime, pTempList);
                        m_pButtonsDef.ChangeButtonCounterValue(EButtonName.EBN_NB_of_Terro, pServerInfo.NbTerro, pTempList);
                        m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_DedicatedServer, pServerInfo.DedicatedServer, pTempList);
                        m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_FriendlyFire, pServerInfo.FriendlyFire, pTempList);
                        m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_TKPenalty, pServerInfo.TeamKillerPenalty, pTempList);
                        m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_AutoBalTeam, pServerInfo.Autobalance, pTempList);
                        UpdateMenuOptions(EButtonName.EBN_FriendlyFire, pServerInfo.FriendlyFire, pTempList);
                    }
                    else
                    {
                        if(!R6Console(Root.Console).m_bStartedByGSClient && !R6Console(Root.Console).m_bNonUbiMatchMakingHost)
                        {
                            m_pButtonsDef.AddButtonCombo(EButtonName.EBN_InternetServer, pTempList, self);
                            m_pButtonsDef.AddItemInComboButton(EButtonName.EBN_InternetServer, Localize("MPCreateGame", "Options_ServerLocationINT", "R6Menu"), string(true), pTempList);
                            m_pButtonsDef.AddItemInComboButton(EButtonName.EBN_InternetServer, Localize("MPCreateGame", "Options_ServerLocationLAN", "R6Menu"), string(false), pTempList);
                        }
                        m_pButtonsDef.AddButtonCombo(EButtonName.EBN_DiffLevel, pTempList, self);
                        m_pButtonsDef.AddItemInComboButton(EButtonName.EBN_DiffLevel, Localize("SinglePlayer", "Difficulty1", "R6Menu"), string(1), pTempList);
                        m_pButtonsDef.AddItemInComboButton(EButtonName.EBN_DiffLevel, Localize("SinglePlayer", "Difficulty2", "R6Menu"), string(2), pTempList);
                        m_pButtonsDef.AddItemInComboButton(EButtonName.EBN_DiffLevel, Localize("SinglePlayer", "Difficulty3", "R6Menu"), string(3), pTempList);
                        m_pButtonsDef.ChangeButtonComboValue(EButtonName.EBN_DiffLevel, "1", pTempList);
                        m_pButtonsDef.AddButtonInt(EButtonName.EBN_RoundPerMatch, 1, 20, 10, pTempList, self);
                        m_pButtonsDef.AddButtonInt(EButtonName.EBN_RoundTime, 1, 15, 3, pTempList, self);
                        m_pButtonsDef.AddButtonInt(EButtonName.EBN_TimeBetRound, 10, 99, 15, pTempList, self);
                        m_pButtonsDef.SetButtonCounterUnlimited(EButtonName.EBN_TimeBetRound, true, pTempList);
                        m_pButtonsDef.AddButtonInt(EButtonName.EBN_BombTimer, 30, 60, 35, pTempList, self);
                        m_pButtonsDef.AddButtonInt(EButtonName.EBN_NB_of_Terro, 5, 40, 32, pTempList, self);
                        if(!R6Console(Root.Console).m_bStartedByGSClient)
                        {
                            m_pButtonsDef.AddButtonInt(EButtonName.EBN_NB_Players, 1, 16, 16, pTempList, self);
                            if(!R6Console(Root.Console).m_bNonUbiMatchMakingHost)
                            {
                                m_pButtonsDef.AddButtonBool(EButtonName.EBN_DedicatedServer, false, pTempList, self);
                            }
                        }
                        m_pButtonsDef.AddButtonBool(EButtonName.EBN_FriendlyFire, true, pTempList, self);
                        m_pButtonsDef.AddButtonBool(EButtonName.EBN_TKPenalty, true, pTempList, self);
                        m_pButtonsDef.AddButtonBool(EButtonName.EBN_AutoBalTeam, true, pTempList, self);
                    }
                    break;
                case eCGW_Camera:
                    if(_bUpdateValue)
                    {
                        UpdateCamera(EButtonName.EBN_CamFadeToBk, pServerInfo.CamFadeToBlack, false, pTempList);
                        UpdateCamera(EButtonName.EBN_CamFirstPerson, pServerInfo.CamFirstPerson, false, pTempList, true);
                        UpdateCamera(EButtonName.EBN_CamThirdPerson, pServerInfo.CamThirdPerson, false, pTempList, true);
                        UpdateCamera(EButtonName.EBN_CamFreeThirdP, pServerInfo.CamFreeThirdP, false, pTempList, true);
                        UpdateCamera(EButtonName.EBN_CamGhost, pServerInfo.CamGhost, false, pTempList, true);
                        UpdateCamera(EButtonName.EBN_CamTeamOnly, pServerInfo.CamTeamOnly, false, pTempList, true);
                        UpdateCamSpecialCase(pServerInfo.CamTeamOnly, false);
                        UpdateCamSpecialCase(pServerInfo.CamFadeToBlack, true);
                    }
                    else
                    {
                        m_pButtonsDef.AddButtonBool(EButtonName.EBN_CamFadeToBk, false, pTempList, self);
                        m_pButtonsDef.AddButtonBool(EButtonName.EBN_CamFirstPerson, true, pTempList, self);
                        m_pButtonsDef.AddButtonBool(EButtonName.EBN_CamThirdPerson, true, pTempList, self);
                        m_pButtonsDef.AddButtonBool(EButtonName.EBN_CamFreeThirdP, true, pTempList, self);
                        m_pButtonsDef.AddButtonBool(EButtonName.EBN_CamGhost, true, pTempList, self);
                        m_pButtonsDef.AddButtonBool(EButtonName.EBN_CamTeamOnly, true, pTempList, self);
                    }
                    break;
                default:
                    break;
            }
            break;
        case m_ANbOfGameMode[1]:
            switch(_eCGWindowID)
            {
                case eCGW_Opt:
                    if(_bUpdateValue)
                    {
                        m_pButtonsDef.ChangeButtonComboValue(EButtonName.EBN_InternetServer, string(pServerInfo.InternetServer), pTempList);
                        m_pButtonsDef.ChangeButtonComboValue(EButtonName.EBN_DiffLevel, string(pServerInfo.DiffLevel), pTempList);
                        m_pButtonsDef.ChangeButtonCounterValue(EButtonName.EBN_RoundPerMission, pServerInfo.RoundsPerMatch, pTempList);
                        m_pButtonsDef.ChangeButtonCounterValue(EButtonName.EBN_RoundTime, pServerInfo.RoundTime / 60, pTempList);
                        m_pButtonsDef.ChangeButtonCounterValue(EButtonName.EBN_TimeBetRound, pServerInfo.BetweenRoundTime, pTempList);
                        m_pButtonsDef.ChangeButtonCounterValue(EButtonName.EBN_NB_Players, pServerInfo.MaxPlayers, pTempList);
                        m_pButtonsDef.ChangeButtonCounterValue(EButtonName.EBN_NB_of_Terro, pServerInfo.NbTerro, pTempList);
                        m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_DedicatedServer, pServerInfo.DedicatedServer, pTempList);
                        m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_AIBkp, pServerInfo.AIBkp, pTempList);
                        m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_RotateMap, pServerInfo.RotateMap, pTempList);
                        m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_FriendlyFire, pServerInfo.FriendlyFire, pTempList);
                    }
                    else
                    {
                        if(!R6Console(Root.Console).m_bStartedByGSClient && !R6Console(Root.Console).m_bNonUbiMatchMakingHost)
                        {
                            m_pButtonsDef.AddButtonCombo(EButtonName.EBN_InternetServer, pTempList, self);
                            m_pButtonsDef.AddItemInComboButton(EButtonName.EBN_InternetServer, Localize("MPCreateGame", "Options_ServerLocationINT", "R6Menu"), string(true), pTempList);
                            m_pButtonsDef.AddItemInComboButton(EButtonName.EBN_InternetServer, Localize("MPCreateGame", "Options_ServerLocationLAN", "R6Menu"), string(false), pTempList);
                        }
                        m_pButtonsDef.AddButtonCombo(EButtonName.EBN_DiffLevel, pTempList, self);
                        m_pButtonsDef.AddItemInComboButton(EButtonName.EBN_DiffLevel, Localize("SinglePlayer", "Difficulty1", "R6Menu"), string(1), pTempList);
                        m_pButtonsDef.AddItemInComboButton(EButtonName.EBN_DiffLevel, Localize("SinglePlayer", "Difficulty2", "R6Menu"), string(2), pTempList);
                        m_pButtonsDef.AddItemInComboButton(EButtonName.EBN_DiffLevel, Localize("SinglePlayer", "Difficulty3", "R6Menu"), string(3), pTempList);
                        m_pButtonsDef.ChangeButtonComboValue(EButtonName.EBN_DiffLevel, "1", pTempList);
                        m_pButtonsDef.AddButtonInt(EButtonName.EBN_RoundPerMission, 1, 20, 10, pTempList, self);
                        m_pButtonsDef.AddButtonInt(EButtonName.EBN_RoundTime, 1, 60, 3, pTempList, self);
                        m_pButtonsDef.AddButtonInt(EButtonName.EBN_TimeBetRound, 10, 99, 15, pTempList, self);
                        m_pButtonsDef.SetButtonCounterUnlimited(EButtonName.EBN_TimeBetRound, true, pTempList);
                        m_pButtonsDef.AddButtonInt(EButtonName.EBN_NB_of_Terro, 5, 40, 32, pTempList, self);
                        if(!R6Console(Root.Console).m_bStartedByGSClient)
                        {
                            m_pButtonsDef.AddButtonInt(EButtonName.EBN_NB_Players, 1, 8, 8, pTempList, self);
                            if(!R6Console(Root.Console).m_bNonUbiMatchMakingHost)
                            {
                                m_pButtonsDef.AddButtonBool(EButtonName.EBN_DedicatedServer, false, pTempList, self);
                            }
                        }
                        m_pButtonsDef.AddButtonBool(EButtonName.EBN_AIBkp, true, pTempList, self);
                        m_pButtonsDef.AddButtonBool(EButtonName.EBN_RotateMap, true, pTempList, self);
                        m_pButtonsDef.AddButtonBool(EButtonName.EBN_FriendlyFire, true, pTempList, self);
                    }
                    break;
                case eCGW_Camera:
                    if(_bUpdateValue)
                    {
                        UpdateCamera(EButtonName.EBN_CamFirstPerson, pServerInfo.CamFirstPerson, false, pTempList);
                        UpdateCamera(EButtonName.EBN_CamThirdPerson, pServerInfo.CamThirdPerson, false, pTempList);
                        UpdateCamera(EButtonName.EBN_CamFreeThirdP, pServerInfo.CamFreeThirdP, false, pTempList);
                        UpdateCamera(EButtonName.EBN_CamGhost, pServerInfo.CamGhost, false, pTempList);
                    }
                    else
                    {
                        m_pButtonsDef.AddButtonBool(EButtonName.EBN_CamFirstPerson, true, pTempList, self);
                        m_pButtonsDef.AddButtonBool(EButtonName.EBN_CamThirdPerson, true, pTempList, self);
                        m_pButtonsDef.AddButtonBool(EButtonName.EBN_CamFreeThirdP, true, pTempList, self);
                        m_pButtonsDef.AddButtonBool(EButtonName.EBN_CamGhost, true, pTempList, self);
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

function SetServerOptions()
{
    local UWindowWindow pCGWWindow;
    local R6WindowListGeneral pListGen;
    local int iCounter;
    local R6StartGameInfo StartGameInfo;
    local string szSvrName, szGameType;
    local R6ServerInfo _ServerSettings;
    local R6MapList myList;
    local int iButtonValue;

    _ServerSettings = class'Actor'.static.GetServerOptions();
    if(_ServerSettings.m_ServerMapList == none)
    {
        _ServerSettings.m_ServerMapList = GetLevel().Spawn(Class'Engine.R6MapList');
    }
    if(R6Console(Root.Console).m_bStartedByGSClient)
    {
        szSvrName = R6Console(Root.Console).m_GameService.m_szGSServerName;
    }
    else
    {
        szSvrName = m_pServerNameEdit.GetValue();
    }
    _ServerSettings.ServerName = szSvrName;
    if(R6Console(Root.Console).m_bStartedByGSClient)
    {
        _ServerSettings.UsePassword = R6Console(Root.Console).m_GameService.m_szGSPassword != "";
        if(_ServerSettings.UsePassword)
        {
            _ServerSettings.GamePassword = R6Console(Root.Console).m_GameService.m_szGSPassword;
        }
    }
    else
    {
        pCGWWindow = GetList(GetCurrentGameMode(), eCGW_Password);
        _ServerSettings.UsePassword = R6WindowButtonAndEditBox(pCGWWindow).m_bSelected;
        _ServerSettings.GamePassword = R6WindowButtonAndEditBox(pCGWWindow).m_pEditBox.GetValue();
    }
    pCGWWindow = GetList(GetCurrentGameMode(), eCGW_AdminPassword);
    _ServerSettings.UseAdminPassword = R6WindowButtonAndEditBox(pCGWWindow).m_bSelected;
    _ServerSettings.AdminPassword = R6WindowButtonAndEditBox(pCGWWindow).m_pEditBox.GetValue();
    if(m_bInGame)
    {
        pListGen = R6WindowListGeneral(GetList(GetCurrentGameMode(), eCGW_Camera));
        _ServerSettings.CamFirstPerson = GetCameraSelection(EButtonName.EBN_CamFirstPerson, pListGen);
        _ServerSettings.CamThirdPerson = GetCameraSelection(EButtonName.EBN_CamThirdPerson, pListGen);
        _ServerSettings.CamFreeThirdP = GetCameraSelection(EButtonName.EBN_CamFreeThirdP, pListGen);
        _ServerSettings.CamGhost = GetCameraSelection(EButtonName.EBN_CamGhost, pListGen);
        if(m_pButtonsDef.FindButtonItem(EButtonName.EBN_CamFadeToBk, pListGen) != none)
        {
            _ServerSettings.CamFadeToBlack = GetCameraSelection(EButtonName.EBN_CamFadeToBk, pListGen);
        }
        if(m_pButtonsDef.FindButtonItem(EButtonName.EBN_CamTeamOnly, pListGen) != none)
        {
            _ServerSettings.CamTeamOnly = GetCameraSelection(EButtonName.EBN_CamTeamOnly, pListGen);
        }
    }
    pListGen = R6WindowListGeneral(GetList(GetCurrentGameMode(), eCGW_Opt));
    if(R6Console(Root.Console).m_bStartedByGSClient)
    {
        iButtonValue = R6Console(Root.Console).m_GameService.m_iGSNumPlayers;
    }
    else
    {
        iButtonValue = m_pButtonsDef.GetButtonCounterValue(EButtonName.EBN_NB_Players, pListGen);
    }
    if(iButtonValue > 0)
    {
        _ServerSettings.MaxPlayers = iButtonValue;
    }
    else
    {
        _ServerSettings.MaxPlayers = 1;
    }
    if(m_pButtonsDef.FindButtonItem(EButtonName.EBN_NB_of_Terro, pListGen) != none)
    {
        _ServerSettings.NbTerro = m_pButtonsDef.GetButtonCounterValue(EButtonName.EBN_NB_of_Terro, pListGen);
    }
    _ServerSettings.MOTD = m_szMsgOfTheDay;
    _ServerSettings.RoundTime = m_pButtonsDef.GetButtonCounterValue(EButtonName.EBN_RoundTime, pListGen) * 60;
    if(int(GetCurrentGameMode()) == int(m_ANbOfGameMode[0]))
    {
        _ServerSettings.RoundsPerMatch = m_pButtonsDef.GetButtonCounterValue(EButtonName.EBN_RoundPerMatch, pListGen);
    }
    else
    {
        _ServerSettings.RoundsPerMatch = m_pButtonsDef.GetButtonCounterValue(EButtonName.EBN_RoundPerMission, pListGen);
    }
    _ServerSettings.BetweenRoundTime = m_pButtonsDef.GetButtonCounterValue(EButtonName.EBN_TimeBetRound, pListGen);
    if(m_pButtonsDef.FindButtonItem(EButtonName.EBN_BombTimer, pListGen) != none)
    {
        _ServerSettings.BombTime = m_pButtonsDef.GetButtonCounterValue(EButtonName.EBN_BombTimer, pListGen);
    }
    if(R6Console(Root.Console).m_bStartedByGSClient || R6Console(Root.Console).m_bNonUbiMatchMakingHost)
    {
        _ServerSettings.InternetServer = true;
    }
    else
    {
        _ServerSettings.InternetServer = bool(m_pButtonsDef.GetButtonComboValue(EButtonName.EBN_InternetServer, pListGen));
    }
    _ServerSettings.DedicatedServer = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_DedicatedServer, pListGen);
    _ServerSettings.FriendlyFire = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_FriendlyFire, pListGen);
    if(m_pButtonsDef.FindButtonItem(EButtonName.EBN_TKPenalty, pListGen) != none)
    {
        _ServerSettings.TeamKillerPenalty = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_TKPenalty, pListGen);
    }
    if(m_pButtonsDef.FindButtonItem(EButtonName.EBN_AIBkp, pListGen) != none)
    {
        _ServerSettings.AIBkp = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_AIBkp, pListGen);
    }
    if(m_pButtonsDef.FindButtonItem(EButtonName.EBN_RotateMap, pListGen) != none)
    {
        _ServerSettings.RotateMap = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_RotateMap, pListGen);
    }
    if(m_pButtonsDef.FindButtonItem(EButtonName.EBN_AutoBalTeam, pListGen) != none)
    {
        _ServerSettings.Autobalance = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_AutoBalTeam, pListGen);
    }
    if(m_pButtonsDef.FindButtonItem(EButtonName.EBN_DiffLevel, pListGen) != none)
    {
        _ServerSettings.DiffLevel = int(m_pButtonsDef.GetButtonComboValue(EButtonName.EBN_DiffLevel, pListGen));
    }
    FillSelectedMapList();
    if(m_SelectedMapList.Length != 0)
    {
        szGameType = m_SelectedModeList[0];
        StartGameInfo = R6Console(Root.Console).Master.m_StartGameInfo;
        StartGameInfo.m_GameMode = szGameType;
        myList = _ServerSettings.m_ServerMapList;

        for(iCounter = 0; iCounter < 32; iCounter++)
        {
            myList.Maps[iCounter] = "";
            myList.GameType[iCounter] = "";
        }

        for(iCounter = 0; iCounter < m_SelectedMapList.Length; iCounter++)
        {
            myList.Maps[iCounter] = m_SelectedMapList[iCounter];
            myList.GameType[iCounter] = m_SelectedModeList[iCounter];
        }
    }
}
