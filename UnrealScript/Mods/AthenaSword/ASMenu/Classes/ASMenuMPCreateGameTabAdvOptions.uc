class ASMenuMPCreateGameTabAdvOptions extends R6MenuMPCreateGameTabAdvOptions;

var R6WindowTextLabelExt m_pOptionsTextAdv;

function Created()
{
    super.Created();
}

function InitAdvOptionsTab(optional bool _bInGame)
{
    local float fXOffset, fYOffset, fWidth, fHeight;
    local int i;

    m_pOptionsTextAdv = R6WindowTextLabelExt(CreateWindow(Class'R6Window.R6WindowTextLabelExt', 0.0, 0.0, 2.0 * float(310), WinHeight, self));
    m_pOptionsTextAdv.bAlwaysBehind = true;
    m_pOptionsTextAdv.ActiveBorder(0, false);
    m_pOptionsTextAdv.ActiveBorder(1, false);
    m_pOptionsTextAdv.SetBorderParam(2, 310.0, 1.0, 1.0, Root.Colors.White);
    m_pOptionsTextAdv.ActiveBorder(3, false);
    m_pOptionsTextAdv.m_Font = Root.Fonts[5];
    m_pOptionsTextAdv.m_vTextColor = Root.Colors.White;
    fXOffset = 310.0 + float(5);
    fYOffset = 5.0;
    fWidth = 310.0;
    m_pOptionsTextAdv.AddTextLabel(Localize("MPCreateGame", "Options_DeathCam", "R6Menu"), fXOffset, fYOffset, fWidth, TA_Left, false);
    fXOffset = 5.0;
    fYOffset = 5.0;
    fWidth = (310.0 - fXOffset) - float(10);
    fHeight = WinHeight - fYOffset;

    for(i = 0; i < m_ANbOfGameMode.Length; i++)
    {
        CreateListOfButtons(fXOffset, fYOffset, fWidth, fHeight, m_ANbOfGameMode[i], eCGW_LeftAdvOpt);
    }
    fXOffset = 5.0 + float(310);
    fHeight = 100.0;

    for(i = 0; i < m_ANbOfGameMode.Length; i++)
    {
        CreateListOfButtons(fXOffset, fYOffset, fWidth, fHeight, m_ANbOfGameMode[i], eCGW_Camera);
    }
    m_bInitComplete = true;
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
        case GetPlayerOwner().EGameModeInfo.GMI_Adversarial:
            switch(_eCGWindowID)
            {
                case eCGW_LeftAdvOpt:
                    if(_bUpdateValue)
                    {
                        if(class'Actor'.static.GetGameOptions().m_bPBInstalled)
                        {
                            m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_PunkBuster, GetLevel().iPBEnabled > 0, pTempList);
                        }
                        else
                        {
                            m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_PunkBuster, false, pTempList, true);
                        }
                        m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_AllowRadar, pServerInfo.AllowRadar, pTempList);
                        m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_AllowTeamNames, pServerInfo.ShowNames, pTempList);
                        m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_ForceFPersonWp, pServerInfo.ForceFPersonWeapon, pTempList);
                    }
                    else
                    {
                        m_pButtonsDef.AddButtonBool(EButtonName.EBN_PunkBuster, false, pTempList, self);
                        m_pButtonsDef.AddButtonBool(EButtonName.EBN_AllowRadar, true, pTempList, self);
                        m_pButtonsDef.AddButtonBool(EButtonName.EBN_AllowTeamNames, true, pTempList, self);
                        m_pButtonsDef.AddButtonBool(EButtonName.EBN_ForceFPersonWp, true, pTempList, self);
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
                        m_pButtonsDef.AddFakeButton(pTempList, self);
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
        case GetPlayerOwner().EGameModeInfo.GMI_Cooperative:
            switch(_eCGWindowID)
            {
                case eCGW_LeftAdvOpt:
                    if(_bUpdateValue)
                    {
                        if(class'Actor'.static.GetGameOptions().m_bPBInstalled)
                        {
                            m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_PunkBuster, GetLevel().iPBEnabled > 0, pTempList, false);
                        }
                        else
                        {
                            m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_PunkBuster, false, pTempList, true);
                        }
                        m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_AllowRadar, pServerInfo.AllowRadar, pTempList);
                        m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_AllowTeamNames, pServerInfo.ShowNames, pTempList);
                        m_pButtonsDef.ChangeButtonBoxValue(EButtonName.EBN_ForceFPersonWp, pServerInfo.ForceFPersonWeapon, pTempList);
                    }
                    else
                    {
                        m_pButtonsDef.AddButtonBool(EButtonName.EBN_PunkBuster, false, pTempList, self);
                        m_pButtonsDef.AddButtonBool(EButtonName.EBN_AllowRadar, false, pTempList, self);
                        m_pButtonsDef.AddButtonBool(EButtonName.EBN_AllowTeamNames, false, pTempList, self);
                        m_pButtonsDef.AddButtonBool(EButtonName.EBN_ForceFPersonWp, false, pTempList, self);
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
                        m_pButtonsDef.AddFakeButton(pTempList, self);
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

function UpdateCamera(int _iButtonID, bool _bValue, bool _bDisable, R6WindowListGeneral _pCamList, optional bool _bBackupValue)
{
    switch(_iButtonID)
    {
        case EButtonName.EBN_CamFadeToBk:
            m_pButtonsDef.ChangeButtonBoxValue(_iButtonID, _bValue, _pCamList);
            break;
        case EButtonName.EBN_CamFirstPerson:
            m_pButtonsDef.ChangeButtonBoxValue(_iButtonID, _bValue, _pCamList, _bDisable);
            if(_bBackupValue)
            {
                m_bBkpCamFirstPerson = _bValue;
            }
            break;
        case EButtonName.EBN_CamThirdPerson:
            m_pButtonsDef.ChangeButtonBoxValue(_iButtonID, _bValue, _pCamList, _bDisable);
            if(_bBackupValue)
            {
                m_bBkpCamThirdPerson = _bValue;
            }
            break;
        case EButtonName.EBN_CamFreeThirdP:
            m_pButtonsDef.ChangeButtonBoxValue(_iButtonID, _bValue, _pCamList, _bDisable);
            if(_bBackupValue)
            {
                m_bBkpCamFreeThirdP = _bValue;
            }
            break;
        case EButtonName.EBN_CamGhost:
            m_pButtonsDef.ChangeButtonBoxValue(_iButtonID, _bValue, _pCamList, _bDisable);
            if(_bBackupValue)
            {
                m_bBkpCamGhost = _bValue;
            }
            break;
        case EButtonName.EBN_CamTeamOnly:
            m_pButtonsDef.ChangeButtonBoxValue(_iButtonID, _bValue, _pCamList, _bDisable);
            if(_bBackupValue)
            {
                m_bBkpCamTeamOnly = _bValue;
            }
            break;
    }
}

function bool GetCameraSelection(int _iButtonID, R6WindowListGeneral _pCameraList)
{
    local bool bSelection;

    if(m_pButtonsDef.IsButtonBoxDisabled(_iButtonID, _pCameraList))
    {
        switch(_iButtonID)
        {
            case EButtonName.EBN_CamFirstPerson:
                bSelection = m_bBkpCamFirstPerson;
                break;
            case EButtonName.EBN_CamThirdPerson:
                bSelection = m_bBkpCamThirdPerson;
                break;
            case EButtonName.EBN_CamFreeThirdP:
                bSelection = m_bBkpCamFreeThirdP;
                break;
            case EButtonName.EBN_CamGhost:
                bSelection = m_bBkpCamGhost;
                break;
            case EButtonName.EBN_CamTeamOnly:
                bSelection = m_bBkpCamTeamOnly;
                break;
            default:
        }
    }
    else
    {
        bSelection = m_pButtonsDef.GetButtonBoxValue(_iButtonID, _pCameraList);
    }
    return bSelection;
}

function UpdateCamSpecialCase(bool _bButtonSel, bool _bUpdateDeathCam)
{
    local bool bCamState, bCamFirstPerson, bCamThirdPerson, bCamFreeThPerson, bCamGhost, bCanTeamOnly,
	    bCamGhostDis;

    local R6WindowListGeneral pCamList;

    pCamList = R6WindowListGeneral(GetList(GetCurrentGameMode(), eCGW_Camera));
    if(_bUpdateDeathCam)
    {
        bCamState = _bButtonSel;
        bCamFirstPerson = false;
        bCamThirdPerson = false;
        bCamFreeThPerson = false;
        bCamGhost = false;
        bCanTeamOnly = false;
        if(bCamState)
        {
            m_bBkpCamFirstPerson = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_CamFirstPerson, pCamList);
            m_bBkpCamThirdPerson = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_CamThirdPerson, pCamList);
            m_bBkpCamFreeThirdP = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_CamFreeThirdP, pCamList);
            bCamGhostDis = m_pButtonsDef.IsButtonBoxDisabled(EButtonName.EBN_CamGhost, pCamList);
            if(!bCamGhostDis)
            {
                m_bBkpCamGhost = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_CamGhost, pCamList);
            }
            if(int(GetCurrentGameMode()) == int(m_ANbOfGameMode[0]))
            {
                m_bBkpCamTeamOnly = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_CamTeamOnly, pCamList);
            }
        }
        else
        {
            bCamFirstPerson = m_bBkpCamFirstPerson;
            bCamThirdPerson = m_bBkpCamThirdPerson;
            bCamFreeThPerson = m_bBkpCamFreeThirdP;
            bCamGhost = m_bBkpCamGhost;
            if(int(GetCurrentGameMode()) == int(m_ANbOfGameMode[0]))
            {
                bCamGhostDis = m_bBkpCamTeamOnly;
            }
            else
            {
                bCamGhostDis = false;
            }
            bCanTeamOnly = m_bBkpCamTeamOnly;
        }
        UpdateCamera(EButtonName.EBN_CamFadeToBk, bCamState, false, pCamList);
        UpdateCamera(EButtonName.EBN_CamFirstPerson, bCamFirstPerson, bCamState, pCamList);
        UpdateCamera(EButtonName.EBN_CamThirdPerson, bCamThirdPerson, bCamState, pCamList);
        UpdateCamera(EButtonName.EBN_CamFreeThirdP, bCamFreeThPerson, bCamState, pCamList);
        if(!bCamGhostDis)
        {
            UpdateCamera(EButtonName.EBN_CamGhost, bCamGhost, bCamState, pCamList);
        }
        if(int(GetCurrentGameMode()) == int(m_ANbOfGameMode[0]))
        {
            UpdateCamera(EButtonName.EBN_CamTeamOnly, bCanTeamOnly, bCamState, pCamList);
        }
    }
    else
    {
        bCamState = _bButtonSel;
        bCamGhost = false;
        if(bCamState)
        {
            m_bBkpCamGhost = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_CamGhost, pCamList);
        }
        else
        {
            bCamGhost = m_bBkpCamGhost;
        }
        UpdateCamera(EButtonName.EBN_CamGhost, bCamGhost, bCamState, pCamList);
    }
}

function UpdateMenuOptions(int _iButID, bool _bNewValue, R6WindowListGeneral _pOptionsList, optional bool _bChangeByUserClick)
{
    local bool bButState;

    switch(_iButID)
    {
        case EButtonName.EBN_CamFadeToBk:
            UpdateCamSpecialCase(_bNewValue, true);
            break;
        case EButtonName.EBN_CamTeamOnly:
            UpdateCamSpecialCase(_bNewValue, false);
            break;
        default:
            break;
    }
}

function SetServerOptions()
{
    local R6ServerInfo _ServerSettings;
    local R6WindowListGeneral pListGen;
    local bool bPBButtonValue;

    _ServerSettings = class'Actor'.static.GetServerOptions();
    pListGen = R6WindowListGeneral(GetList(GetCurrentGameMode(), eCGW_Camera));
    _ServerSettings.CamFirstPerson = GetCameraSelection(EButtonName.EBN_CamFirstPerson, pListGen);
    _ServerSettings.CamThirdPerson = GetCameraSelection(EButtonName.EBN_CamThirdPerson, pListGen);
    _ServerSettings.CamFreeThirdP = GetCameraSelection(EButtonName.EBN_CamFreeThirdP, pListGen);
    _ServerSettings.CamGhost = GetCameraSelection(EButtonName.EBN_CamGhost, pListGen);
    if(m_pButtonsDef.FindButtonItem(EButtonName.EBN_CamFadeToBk, pListGen) == none)
    {
        _ServerSettings.CamFadeToBlack = false;
    }
    else
    {
        _ServerSettings.CamFadeToBlack = GetCameraSelection(EButtonName.EBN_CamFadeToBk, pListGen);
    }
    if(m_pButtonsDef.FindButtonItem(EButtonName.EBN_CamTeamOnly, pListGen) == none)
    {
        _ServerSettings.CamTeamOnly = false;
    }
    else
    {
        _ServerSettings.CamTeamOnly = GetCameraSelection(EButtonName.EBN_CamTeamOnly, pListGen);
    }
    pListGen = R6WindowListGeneral(GetList(GetCurrentGameMode(), eCGW_LeftAdvOpt));
    if(pListGen == none)
    {
        return;
    }
    bPBButtonValue = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_PunkBuster, pListGen);
    class'Actor'.static.SetPBStatus(!bPBButtonValue, true);
    if(bPBButtonValue == true)
    {
        class'Actor'.static.SetPBStatus(false, false);
    }
    _ServerSettings.ShowNames = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_AllowTeamNames, pListGen);
    _ServerSettings.ForceFPersonWeapon = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_ForceFPersonWp, pListGen);
    _ServerSettings.AllowRadar = m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_AllowRadar, pListGen);
}
