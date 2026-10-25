//=============================================================================
//  R6MenuUbiComWidget.uc : Game Main Menu when the game is start by Ubi.com
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//	Main Menu
//
//  Revision history:
//    2002/09/18 * Created by Yannick Joly
//=============================================================================
class R6MenuUbiComWidget extends R6MenuWidget;

var bool m_bQueryServerInfoInProgress;

var bool m_bIsACustomMod;

var bool m_bIsAnOfficialMod;
var R6GSServers                       m_GameService;             // Manages servers from game service
var string							  m_szIPAddress;

var R6WindowButtonMainMenu            m_ButtonQuit;
var R6WindowButtonMainMenu            m_ButtonReturn;

var R6MenuUbiComModsWidget m_UbiComModsWidget;

var R6WindowQueryServerInfo m_pQueryServerInfo;

function Created()
{
    local float fButtonXpos, fButtonWidth, fButtonHeight, fFirstButtonYpos, fButtonOffset;

    fButtonXpos = 350.0;
    fButtonWidth = 250.0;
    fFirstButtonYpos = 225.0;
    fButtonOffset = 35.0;
    fButtonHeight = 35.0;
    Root.SetLoadRandomBackgroundImage("");
    m_GameService = R6Console(Root.Console).m_GameService;
    m_ButtonQuit = R6WindowButtonMainMenu(CreateControl(Class'R6Menu.R6WindowButtonMainMenu', fButtonXpos, fFirstButtonYpos, fButtonWidth, fButtonHeight, self));
    m_ButtonQuit.ToolTipString = Localize("UbiCom", "ButtonQuit", "R6Menu");
    m_ButtonQuit.Text = Localize("UbiCom", "ButtonQuit", "R6Menu");
    m_ButtonQuit.Align = TA_Right;
    m_ButtonQuit.m_buttonFont = Root.Fonts[14];
    m_ButtonQuit.m_eButton_Action = Button_UbiComQuit;
    m_ButtonQuit.ResizeToText();
    m_ButtonReturn = R6WindowButtonMainMenu(CreateControl(Class'R6Menu.R6WindowButtonMainMenu', fButtonXpos, fFirstButtonYpos + fButtonOffset, fButtonWidth, fButtonHeight, self));
    m_ButtonReturn.ToolTipString = Localize("UbiCom", "ButtonReturn", "R6Menu");
    m_ButtonReturn.Text = Localize("UbiCom", "ButtonReturn", "R6Menu");
    m_ButtonReturn.Align = TA_Right;
    m_ButtonReturn.m_buttonFont = Root.Fonts[14];
    m_ButtonReturn.m_eButton_Action = Button_UbiComReturn;
    m_ButtonReturn.ResizeToText();
    m_pQueryServerInfo = R6WindowQueryServerInfo(CreateWindow(Root.MenuClassDefines.ClassQueryServerInfo, 0.0, 0.0, 640.0, 480.0, self, true));
    m_pQueryServerInfo.m_GameService = m_GameService;
    m_pQueryServerInfo.PopUpBoxCreate();
    m_pQueryServerInfo.HideWindow();
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
	Root.PaintBackground( C, self);

    // Only display the Quit/Return buttons if the game has been
    // maximized manually by the player, that is if we are in the
    // EGS_WAITING_FOR_GS_INIT state.

	if(m_GameService.NativeIsWaitingForGSInit())
    {
        if ( !m_ButtonQuit.bWindowVisible )
            m_ButtonQuit.ShowWindow();
        if ( !m_ButtonReturn.bWindowVisible )
            m_ButtonReturn.ShowWindow();
    }
    else
    {
        if ( m_ButtonQuit.bWindowVisible )
            m_ButtonQuit.HideWindow();
        if ( m_ButtonReturn.bWindowVisible )
            m_ButtonReturn.HideWindow();
    }
}

function ShowWindow()
{
    if(R6MenuRootWindow(Root).m_pMenuCDKeyManager != none)
    {
        R6MenuRootWindow(Root).m_pMenuCDKeyManager.SetWindowUser(Root.eGameWidgetID.UbiComWidgetID, self);
    }
    Root.SetLoadRandomBackgroundImage("");
    Root.RegisterMsgWindow(self);
    super(UWindowWindow).ShowWindow();
}

function HideWindow()
{
    Root.UnRegisterMsgWindow();
    super(UWindowWindow).HideWindow();
}

//===============================================================
// Tick: Overload this fct in mod to bypass CheckForGSClientStart or change empty CheckForGSClientStart 
//===============================================================
function Tick(float Delta)
{
    local R6ModMgr pModManager;
    local R6GameManager pGameMgr;
    local bool bRequestSrvInfo;

    pGameMgr = R6GameManager(class'Actor'.static.GetGameManager());
    pModManager = class'Actor'.static.GetModMgr();
    if(Root.Console.m_bChangeModInProgress)
    {
        return;
    }
    if(pModManager.m_szPendingModName != "")
    {
        if(pGameMgr.m_bGSJoinUbiServer)
        {
            if(m_bIsAnOfficialMod || !pModManager.IsRavenShield() && pModManager.IsOfficialMod(pModManager.m_pCurrentMod.m_szKeyWord))
            {
                if(pModManager.m_szPendingModName ~= pModManager.m_pCurrentMod.m_szKeyWord)
                {
                    if(pGameMgr.m_bQueryServerInfoDone)
                    {
                        pGameMgr.m_bGSJoinUbiServer = false;
                        log("UbiComWidget Ready to Join server");
                        m_szIPAddress = m_GameService.m_szGSClientIP;
                        R6MenuRootWindow(Root).m_pMenuCDKeyManager.StartCDKeyProcess(EJRC_NO, m_GameService.m_ClientBeacon.PreJoinInfo);
                        return;
                    }                    
                }
                else
                {
                    SwitchToAppropriateMod();
                    return;
                }                
            }
            else
            {
                if(pGameMgr.m_bQueryServerInfoDone)
                {
                    if(pModManager.m_szPendingModName ~= pModManager.m_pCurrentMod.m_szKeyWord)
                    {
                        pGameMgr.m_bGSJoinUbiServer = false;
                        m_szIPAddress = m_GameService.m_szGSClientIP;
                        R6MenuRootWindow(Root).m_pMenuCDKeyManager.StartCDKeyProcess(EJRC_NO, m_GameService.m_ClientBeacon.PreJoinInfo);                        
                    }
                    else
                    {
                        SwitchToAppropriateMod();
                    }
                    return;
                }
            }
            if(m_bQueryServerInfoInProgress)
            {
                m_pQueryServerInfo.Manager(self);                
            }
            else
            {
                log("UbiComWidget Join a srv query info");
                m_bQueryServerInfoInProgress = true;
                R6MenuRootWindow(Root).InitBeaconService();
                m_pQueryServerInfo.StartQueryServerInfoProcedure(self, m_GameService.m_szGSClientIP, 0);
            }            
        }
        else
        {
            if(pGameMgr.IsGSCreateUbiServer())
            {
                if(pModManager.m_szPendingModName ~= pModManager.m_pCurrentMod.m_szKeyWord)
                {
                    Root.Console.ViewportOwner.Actor.PlaySound(Sound'Music.Play_theme_Musicsilence', SLOT_Music);
                    Root.ChangeCurrentWidget(MPCreateGameWidgetID);
                    R6MenuRootWindow(Root).InitBeaconService();
                    return;
                }
                if(m_bIsACustomMod)
                {
                    Root.ChangeCurrentWidget(UbiComModWidgetID);                    
                }
                else
                {
                    SwitchToAppropriateMod();
                }
            }
        }
    }
}

function bool SwitchToAppropriateMod()
{
    local array<UWindowRootWindow.eGameWidgetID> AWIDList;
    local R6ModMgr pModManager;
    local string szTemp;
    local int i;
    local bool bModExist;

    if(m_bIsAnOfficialMod || m_bIsACustomMod)
    {
        pModManager = class'Actor'.static.GetModMgr();
        bModExist = false;
        i = 0;

        while(i < pModManager.m_aMods.Length)
        {
            if(pModManager.m_aMods[i].m_szKeyWord ~= pModManager.m_szPendingModName)
            {
                bModExist = true;
            }
            ++i;
        }
        if(bModExist)
        {
            pModManager.SetCurrentMod(pModManager.m_szPendingModName, GetLevel(), true, Root.Console, GetPlayerOwner().XLevel);
            AWIDList[AWIDList.Length] = UbiComWidgetID;
            R6Console(Root.Console).CleanAndChangeMod(AWIDList);            
        }
        else
        {
            szTemp = Localize("MultiPlayer", "PopUp_Error_InvalidMod", "R6Menu");
            R6MenuRootWindow(Root).SimplePopUp(Localize("MultiPlayer", "Popup_Error_Title", "R6Menu"), pModManager.m_szPendingModName @ szTemp, EPopUpID_InvalidMod, MessageBoxButtons.MB_OK, false, self);
            m_bIsAnOfficialMod = false;
            m_bIsACustomMod = false;
        }        
    }
    else
    {
        bModExist = true;
    }
    return bModExist;
}

function ProcessGSMsg(string _szMsg)
{
    switch(_szMsg)
    {
        case "IsACustomMod":
            m_bIsACustomMod = true;
            break;
        case "IsAnOfficialMod":
            m_bIsAnOfficialMod = true;
            break;
        case "IsRavenShield":
        default:
            break;
    }
}

function SendMessage(UWindowWindow.eR6MenuWidgetMessage eMessage)
{
    local R6WindowUbiCDKeyCheck.eJoinRoomChoice eJoinRoom;
    local bool bRoomValid;
    local string _szIPAddress;

    switch(eMessage)
    {
        case MWM_QUERYSERVER_SUCCESS:
            m_bQueryServerInfoInProgress = false;
            class'Actor'.static.GetModMgr().m_szPendingModName = m_GameService.m_ClientBeacon.PreJoinInfo.szPreJoinModName;
            class'Actor'.static.GetGameManager().m_bQueryServerInfoDone = true;
            break;
        case MWM_QUERYSERVER_FAIL:
            m_bQueryServerInfoInProgress = false;
            class'Actor'.static.GetGameManager().StopGSClientProcedure();
            break;
        default:
            log("Msg not supported");
            break;
    }
}

//==============================================================================
// PromptConnectionError -  A connection error has occured, put up a pop
// up menu.
//==============================================================================
function PromptConnectionError()
{
	local R6MenuRootWindow R6Root;
	local string szTemp;

    // A connection error to the server has occured, display the pop up menu
    // with the appropriate message.

	R6Root = R6MenuRootWindow(Root);

	R6Root.m_RSimplePopUp.X = 140;
	R6Root.m_RSimplePopUp.Y = 170;
	R6Root.m_RSimplePopUp.W = 360;
	R6Root.m_RSimplePopUp.H = 77;

    if(R6Console(Root.console).m_szLastError!="")
    {
		szTemp = Localize("Multiplayer",  R6Console(Root.console).m_szLastError, "R6Menu", true);

        if (szTemp == "")
            szTemp = Localize("Errors",  R6Console(Root.console).m_szLastError, "R6Engine", true);

		if (szTemp == "")
			szTemp = R6Console(Root.console).m_szLastError;

	    R6Root.SimplePopUp( Localize("MultiPlayer","Popup_Error_Title","R6Menu"),
							szTemp, EPopUpID_ErrorConnect, MessageBoxButtons.MB_OK, false, self);

        R6Console(Root.console).m_szLastError = "";
    }
    else
	{
	    R6Root.SimplePopUp( Localize("MultiPlayer","Popup_Error_Title","R6Menu"),
							Localize("MultiPlayer","Popup_ConnectionError","R6Menu"), 
							EPopUpID_ErrorConnect, MessageBoxButtons.MB_OK, false, self);
	}
}

//==============================================================================
// PopUpBoxDone -  receive the result of the popup box  
//==============================================================================
function PopUpBoxDone( MessageBoxResult Result, ePopUpID _ePopUpID)
{
	// don't forget to resize popup to original value
	R6WindowRootWindow(Root).m_RSimplePopUp = R6WindowRootWindow(Root).Default.m_RSimplePopUp;
	
    // Minimize game and return to ubi.com client.
	class'Actor'.static.GetGameManager().StopGSClientProcedure();
}

//==============================================================================
// Notify -  Called when the player presses on a button (quit or return).
//==============================================================================
function Notify(UWindowDialogControl C, byte E)
{
	if (C.IsA('R6WindowButtonMainMenu'))
    {
        if(E == DE_Click)
        {
            // Quit button, quit the game.
            if (C == m_ButtonQuit)
                Root.DoQuitGame();

            // Return to ubi.com button, Minimize the game.
            else if (C == m_ButtonReturn)
                class'Actor'.static.GetGameManager().m_bReturnToGSClient = TRUE;
        }
    }
}

defaultproperties
{
}
