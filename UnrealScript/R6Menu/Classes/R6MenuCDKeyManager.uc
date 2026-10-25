class R6MenuCDKeyManager extends UWindowWindow;

var UWindowRootWindow.eGameWidgetID m_eCurrentWID;

var BOOL                              m_bPreJoinInProgress;

var bool m_bShowManagerCDKeyLog;

var R6WindowUbiCDKeyCheck             m_pCDKeyCheckWindow;       // Windows and logic for cdkey validation

var UWindowWindow m_pProcedureOwner;

function Created()
{
    m_pCDKeyCheckWindow = R6WindowUbiCDKeyCheck(CreateWindow(Root.MenuClassDefines.ClassUbiCDKeyCheck, 0.0, 0.0, 640.0, 480.0, self, true));
    m_pCDKeyCheckWindow.m_GameService = R6Console(Root.Console).m_GameService;
    m_pCDKeyCheckWindow.PopUpBoxCreate();
    m_pCDKeyCheckWindow.HideWindow();
}

function StartCDKeyProcess(optional R6WindowUbiCDKeyCheck.eJoinRoomChoice _eJoinUbiComRoom, optional ClientBeaconReceiver.PreJoinResponseInfo _preJResponseInfo)
{
    if(m_bShowManagerCDKeyLog)
    {
        log("StartCDKeyProcess()");
    }
    Root.RegisterMsgWindow(m_pCDKeyCheckWindow);
    m_pCDKeyCheckWindow.m_pSendMessageDest = self;
    m_pCDKeyCheckWindow.m_eJoinRoomChoice = _eJoinUbiComRoom;
    m_pCDKeyCheckWindow.m_preJoinRespInfo = _preJResponseInfo;
    class'Actor'.static.GetGameManager().StartPreJoinProcedure();
    m_bPreJoinInProgress = true;
    ShowWindow();
}

function FinishCDKeyProcess()
{
    Root.UnRegisterMsgWindow();
    HideWindow();
}

function ProcessCDKeyMessage(UWindowWindow.eR6MenuWidgetMessage eMessage)
{
    local string _szIPAddress;

    switch(eMessage)
    {
        case MWM_CDKEYVAL_SKIPPED:
        case MWM_CDKEYVAL_SUCCESS:
            m_bPreJoinInProgress = false;
            switch(m_eCurrentWID)
            {
                case Root.eGameWidgetID.MPCreateGameWidgetID:
                    LaunchServer();
                    break;
                case Root.eGameWidgetID.MultiPlayerWidgetID:
                    JoinServer(R6MenuMultiPlayerWidget(m_pProcedureOwner).m_szServerIP, m_pCDKeyCheckWindow.m_szPassword);
                    break;
                case Root.eGameWidgetID.UbiComWidgetID:
                    JoinServer(R6MenuUbiComWidget(m_pProcedureOwner).m_szIPAddress, m_pCDKeyCheckWindow.m_GameService.m_szGSPassword);
                    break;
                case Root.eGameWidgetID.NonUbiWidgetID:
                    class'Actor'.static.NativeNonUbiMatchMakingAddress(_szIPAddress);
                    JoinServer(_szIPAddress, m_pCDKeyCheckWindow.m_szPassword);
                    break;
                default:
                    if(R6Console(Root.Console).m_bNonUbiMatchMakingHost)
                    {
                        LaunchServer();
                    }
                    break;
            }
            break;
        case MWM_CDKEYVAL_FAIL:
            m_bPreJoinInProgress = false;
            FinishCDKeyProcess();
            if(R6Console(Root.Console).m_bStartedByGSClient)
            {
                class'Actor'.static.GetGameManager().StopGSClientProcedure();
            }
            if(R6Console(Root.Console).m_bNonUbiMatchMaking == true)
            {
                Root.DoQuitGame();
            }
            break;
        default:
            break;
    }
}

function SetWindowUser(UWindowRootWindow.eGameWidgetID _eGameWID, UWindowWindow _ProcedureOwner)
{
    m_pProcedureOwner = _ProcedureOwner;
    m_eCurrentWID = _eGameWID;
}

function SendMessage(UWindowWindow.eR6MenuWidgetMessage eMessage)
{
    switch(eMessage)
    {
        case MWM_CDKEYVAL_SKIPPED:
        case MWM_CDKEYVAL_SUCCESS:
        case MWM_CDKEYVAL_FAIL:
            ProcessCDKeyMessage(eMessage);
            break;
        default:
            log("WARNING CDKeyManager SendMessage not supported" @ string(eMessage));
            break;
    }
}

function LaunchServer()
{
    local Console pConsole;
    local R6Console pR6Console;
    local R6MenuMPCreateGameTabOptions pMPCreateGTOpt;
    local InternetLink.IpAddr _localAddr;

    pConsole = Root.Console;
    pR6Console = R6Console(pConsole);
    pMPCreateGTOpt = R6MenuMPCreateGameWidget(m_pProcedureOwner).m_pCreateTabOptions;
    pMPCreateGTOpt.SetServerOptions();
    class'Actor'.static.SaveServerOptions();
    if((!pR6Console.m_bStartedByGSClient && !pR6Console.m_bNonUbiMatchMakingHost) && pMPCreateGTOpt.m_pButtonsDef.GetButtonBoxValue(EButtonName.EBN_DedicatedServer, R6WindowListGeneral(pMPCreateGTOpt.GetList(pMPCreateGTOpt.GetCurrentGameMode(), pMPCreateGTOpt.eCreateGameWindow_ID.eCGW_Opt))))
    {
        pConsole.ConsoleCommand("SERVER mod=" $ class'Actor'.static.GetModMgr().m_pCurrentMod.m_szKeyWord);        
    }
    else
    {
        if(!class'Actor'.static.IsPBClientEnabled() && GetLevel().iPBEnabled != 0)
        {
            class'Actor'.static.SetPBStatus(false, false);
        }
        class'Actor'.static.GetGameManager().LaunchListenSrv(pMPCreateGTOpt.m_SelectedMapList[0], pMPCreateGTOpt.m_SelectedModeList[0]);
        pR6Console.m_LanServers.m_ClientBeacon.GetLocalIP(_localAddr);
        pR6Console.szStoreIP = pR6Console.m_LanServers.m_ClientBeacon.IpAddrToString(_localAddr);
        pR6Console.LaunchR6MultiPlayerGame();
        GetLevel().Game.SetCurrentMapNum(0);
    }
}

function JoinServer(string _szIPAddress, optional string _szPassword)
{
    local R6Console pR6Console;
    local string szOptions, szCharacterName, m_ArmorName, m_WeaponNameOne, m_WeaponGadgetNameOne, m_BulletTypeOne,
	    m_WeaponNameTwo, m_WeaponGadgetNameTwo, m_BulletTypeTwo, m_GadgetNameOne, m_GadgetNameTwo,
	    szAllAuthID;

    local int iPlayerSpawnNumber;

    pR6Console = R6Console(Root.Console);
    iPlayerSpawnNumber = pR6Console.GetSpawnNumber();
    szOptions = "";
    if(_szPassword != "")
    {
        szOptions = (szOptions $ "?Password=") $ _szPassword;
    }
    Root.Console.ViewportOwner.Actor.GetPlayerSetupInfo(szCharacterName, m_ArmorName, m_WeaponNameOne, m_WeaponGadgetNameOne, m_BulletTypeOne, m_WeaponNameTwo, m_WeaponGadgetNameTwo, m_BulletTypeTwo, m_GadgetNameOne, m_GadgetNameTwo);
    ReplaceText(szCharacterName, "?", "~");
    ReplaceText(szCharacterName, ",", "~");
    ReplaceText(szCharacterName, "#", "~");
    ReplaceText(szCharacterName, "/", "~");
    szOptions = (szOptions $ "?Name=") $ szCharacterName;
    ReplaceText(szOptions, " ", "~");
    szOptions = (szOptions $ "?UbiUserID=") $ R6Console(Root.Console).m_GameService.m_szUserID;
    szOptions = (szOptions $ "?iPB=") $ string(class'PlayerController'.static.IsPBEnabled());
    SaveGameServiceConfig();
    class'Actor'.static.GetGameManager().StartJoinServer(_szIPAddress, szOptions, iPlayerSpawnNumber);
    pR6Console.szStoreIP = _szIPAddress;
    pR6Console.szStoreGamePassWd = _szPassword;
    R6MenuRootWindow(Root).m_bJoinServerProcess = true;
}

function SaveGameServiceConfig()
{
    R6Console(Root.Console).m_GameService.SaveInfo();
}

defaultproperties
{
    m_bShowManagerCDKeyLog=true
}
