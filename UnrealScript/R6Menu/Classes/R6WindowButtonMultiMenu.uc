class R6WindowButtonMultiMenu extends R6WindowButton;

var Texture                 m_TOverButton;

var Region                  m_ROverButtonFade;   
var Region                  m_ROverButton;

var EButtonName				m_eButton_Action;

var BOOL					m_bButtonIsReady;

function BeforePaint(Canvas C, FLOAT X, FLOAT Y)
{
	if (m_pPreviousButtonPos != None) // if we have a previous button association for position
	{
		if (!m_bSetParam)
		{
			WinLeft = m_pPreviousButtonPos.WinLeft + m_pPreviousButtonPos.m_textSize + ((620 - m_pRefButtonPos.m_fTotalButtonsSize) * 0.25);
			m_pPreviousButtonPos = None;
			m_bButtonIsReady	 = true;
		}
	}
	else
		m_bButtonIsReady	 = true;
	
	Super.BeforePaint( C, X, Y);
}

function Paint(Canvas C, float X, float Y)
{
	if (m_bButtonIsReady)
	{
		Super.Paint( C, X, Y);
	}
}

//=================================================================================
// Process the click
//=================================================================================
simulated function Click(float X, float Y)
{
    local R6MenuMPCreateGameTabOptions pCreateTabOptions;
    local R6MenuRootWindow r6Root;
    local R6MenuMPManageTab pFirstTabManager;
    local R6LanServers pLanServers;
    local R6GSServers pGameService;
    local R6WindowListGeneral pListGen;
    local R6MenuMPCreateGameWidget pCreateGW;
    local bool bInternetServer;
    local R6ServerInfo _ServerSettings;

    super(UWindowButton).Click(X, Y);
    r6Root = R6MenuRootWindow(Root);
    if(bDisabled)
    {
        return;
    }
    switch(m_eButton_Action)
    {
        case EBN_LogIn:
            R6MenuMultiPlayerWidget(OwnerWindow).m_LoginSuccessAction = eLSAct_SwitchToInternetTab;
            R6MenuMultiPlayerWidget(OwnerWindow).m_pLoginWindow.StartLogInProcedure(OwnerWindow);
            SetButLogInOutState(EBN_LogOut);
            break;
        case EBN_LogOut:
            R6MenuMultiPlayerWidget(OwnerWindow).m_GameService.UnInitializeMSClient();
            pFirstTabManager = R6MenuMultiPlayerWidget(OwnerWindow).m_pFirstTabManager;
            pFirstTabManager.m_pMainTabControl.GotoTab(pFirstTabManager.m_pMainTabControl.GetTab(Localize("MultiPlayer", "Tab_LanServer", "R6Menu")));
            R6MenuMultiPlayerWidget(OwnerWindow).m_GameService.m_GameServerList.Remove(0, R6MenuMultiPlayerWidget(OwnerWindow).m_GameService.m_GameServerList.Length);
            R6MenuMultiPlayerWidget(OwnerWindow).m_GameService.m_GSLSortIdx.Remove(0, R6MenuMultiPlayerWidget(OwnerWindow).m_GameService.m_GSLSortIdx.Length);
            SetButLogInOutState(EBN_LogIn);
            break;
        case EBN_Join:
            R6MenuMultiPlayerWidget(OwnerWindow).JoinSelectedServerRequested();
            break;
        case EBN_JoinIP:
            R6MenuMultiPlayerWidget(OwnerWindow).m_pJoinIPWindow.StartJoinIPProcedure(self, R6MenuMultiPlayerWidget(OwnerWindow).m_szPopUpIP);
            R6MenuMultiPlayerWidget(OwnerWindow).m_bJoinIPInProgress = true;
            break;
        case EBN_Refresh:
            R6MenuMultiPlayerWidget(OwnerWindow).Refresh(true);
            break;
        case EBN_Create:
            r6Root.ChangeCurrentWidget(MPCreateGameWidgetID);
            break;
        case EBN_Cancel:
            if(R6Console(Root.Console).m_bNonUbiMatchMakingHost)
            {
                r6Root.ChangeCurrentWidget(MenuQuitID);                
            }
            else
            {
                r6Root.ChangeCurrentWidget(MultiPlayerWidgetID);
            }
            break;
        case EBN_Launch:
            pCreateGW = R6MenuMPCreateGameWidget(OwnerWindow);
            pCreateTabOptions = pCreateGW.m_pCreateTabOptions;
            pListGen = R6WindowListGeneral(pCreateTabOptions.GetList(pCreateTabOptions.GetCurrentGameMode(), pCreateTabOptions.eCreateGameWindow_ID.eCGW_Opt));
            if(R6Console(Root.Console).m_bStartedByGSClient)
            {
                _ServerSettings = class'Actor'.static.GetServerOptions();
                if((_ServerSettings.MaxPlayers > 8) && pCreateTabOptions.GetCurrentGameMode() == GetLevel().EGameModeInfo.GMI_Cooperative)
                {
                    r6Root.SimplePopUp(Localize("MultiPlayer", "Popup_Error_Title", "R6Menu"), Localize("MultiPlayer", "PopUp_Error_InvalidGSCoOpMaxPlayer", "R6Menu"), EPopUp_ID_GSCoOpMaxError, MessageBoxButtons.MB_OK);
                    return;
                }
            }
            if(!pCreateTabOptions.IsAdminPasswordValid())
            {
                r6Root.SimplePopUp(Localize("MultiPlayer", "Popup_Error_Title", "R6Menu"), Localize("MultiPlayer", "PopUp_Error_InvalidAdminPwrd", "R6Menu"), EPopUpID_InvalidPassword, MessageBoxButtons.MB_OK);
                return;
            }
            pCreateTabOptions.FillSelectedMapList();
            if(pCreateTabOptions.m_SelectedMapList.Length <= 0)
            {
                r6Root.SimplePopUp(Localize("MultiPlayer", "Popup_Error_Title", "R6Menu"), Localize("MultiPlayer", "PopUp_Error_NoMapSelected", "R6Menu"), EPopUpID_InvalidPassword, MessageBoxButtons.MB_OK);                
            }
            else
            {
                if(!R6Console(Root.Console).m_bStartedByGSClient && pCreateTabOptions.m_pServerNameEdit.GetValue() == "")
                {
                    r6Root.SimplePopUp(Localize("MultiPlayer", "Popup_Error_Title", "R6Menu"), Localize("MultiPlayer", "PopUp_Error_NoServerName", "R6Menu"), EPopUpID_InvalidPassword, MessageBoxButtons.MB_OK);                    
                }
                else
                {
                    if(R6Console(Root.Console).m_bStartedByGSClient || R6Console(Root.Console).m_bNonUbiMatchMakingHost)
                    {
                        r6Root.m_pMenuCDKeyManager.StartCDKeyProcess();                        
                    }
                    else
                    {
                        if(bool(pCreateTabOptions.m_pButtonsDef.GetButtonComboValue(int(pCreateTabOptions.EButtonName.EBN_InternetServer), pListGen)) && !pCreateTabOptions.m_pButtonsDef.GetButtonBoxValue(int(pCreateTabOptions.EButtonName.EBN_DedicatedServer), pListGen))
                        {
                            R6Console(Root.Console).szStoreGamePassWd = pCreateTabOptions.GetCreateGamePassword();
                            pCreateGW.m_pLoginWindow.StartLogInProcedure(OwnerWindow);
                            pCreateGW.m_bLoginInProgress = true;                            
                        }
                        else
                        {
                            if(!pCreateTabOptions.m_pButtonsDef.GetButtonBoxValue(int(pCreateTabOptions.EButtonName.EBN_DedicatedServer), pListGen))
                            {
                                r6Root.m_pMenuCDKeyManager.StartCDKeyProcess();                                
                            }
                            else
                            {
                                r6Root.m_pMenuCDKeyManager.LaunchServer();
                            }
                        }
                    }
                }
            }
            break;
        case EBN_CancelUbiCom:
            r6Root.ChangeCurrentWidget(UbiComWidgetID);
            class'Actor'.static.GetGameManager().StopGSClientProcedure();
            break;
        default:
            log("Button not supported");
            break;
    }
}

function SetButLogInOutState( EButtonName _eNewButtonState)
{
	Text			 = R6MenuButtonsDefines(GetButtonsDefinesUnique(Root.MenuClassDefines.ClassButtonsDefines)).GetButtonLoc(_eNewButtonState);
	ToolTipString    = R6MenuButtonsDefines(GetButtonsDefinesUnique(Root.MenuClassDefines.ClassButtonsDefines)).GetButtonLoc(_eNewButtonState, True);
	m_eButton_Action = _eNewButtonState;
	ResizeToText();
}

defaultproperties
{
     m_TOverButton=Texture'R6MenuTextures.Gui_BoxScroll'
     m_ROverButtonFade=(X=248,W=6,H=13)
     m_ROverButton=(X=253,W=2,H=13)
     bStretched=True
}
