//=============================================================================
//  R6MenuMultiPlayerWidget.uc : The first multi player menu window
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//    2002/03/7  * Modify by Yannick Joly
//=============================================================================
class R6MenuMultiPlayerWidget extends R6MenuWidget
    Config(User);

enum MultiPlayerTabID
{
    TAB_Lan_Server,
    TAB_Internet_Server,
    TAB_Game_Mode,
    TAB_Tech_Filter,
    TAB_Server_Info
};

enum eServerInfoID
{
    eServerInfoID_DeathMatch,
    eServerInfoID_TeamDeathMatch,
	eServerInfoID_Bomb,
    eServerInfoID_HostageAdv,
    eServerInfoID_Escort,
    eServerInfoID_Mission,
    eServerInfoID_Terrorist,
    eServerInfoID_HostageCoop,
    eServerInfoID_Defend,
    eServerInfoID_Recon,
    eServerInfoID_Unlocked,
    eServerInfoID_Favorites,
    eServerInfoID_Dedicated,
//#ifdefR6PUNKBUSTER
    eServerInfoID_PunkBuster,
//#endif
    eServerInfoID_NotEmpty,
    eServerInfoID_NotFull,
    eServerInfoID_Responding,
    eServerInfoID_HasPlayer,
    eServerInfoID_SameVersion
};

enum eLoginSuccessAction
{
    eLSAct_None,
    eLSAct_JoinIP,
    eLSAct_Join,
    eLSAct_InternetTab,
    eLSAct_LaunchServer,
    eLSAct_CloseWindow,
    eLSAct_SwitchToInternetTab
};

const K_XSTARTPOS                     = 10;                      // the start pos of window LAN SERVER INFO and GameMode
const K_WINDOWWIDTH                   = 620;                     // the size of window LAN SERVER INFO and GameMode
const K_XSTARTPOS_NOBORDER            = 12;                      // the start pos of window LAN SERVER INFO and GameMode
const K_WINDOWWIDTH_NOBORDER          = 616;                     // the size of window LAN SERVER INFO and GameMode
const K_XTABOFFSET                    = 5;                       // the first tab offset in X
const K_FIRST_TABWINDOW_WIDTH         = 500;                     // in relation with K_WINDOWWIDTH and K_XTABOFFSET
const K_SEC_TABWINDOW_WIDTH			  = 600;
const K_FFIRST_WINDOWHEIGHT           = 154;                     // the height of the first window under the tab
const K_FSECOND_WINDOWHEIGHT          = 90;                      // the height of the second window under the tab
const K_YPOS_FIRST_TABWINDOW          = 126;
const K_YPOS_SECOND_TABWINDOW         = 296;                     // the y pos of the second tab window (start with the curved frame window)
const K_YPOS_HELPTEXT_WINDOW          = 430;                     // the y pos of help text window
const C_fDIST_BETWEEN_BUTTON		  = 30;
const K_LIST_UPDATE_TIME              = 1000;                    // time in ms beween between updates of the server list
const K_REFRESH_TIMEOUT               = 2.0;

const K_UPDATE_FILTER_INTERVAL = 0.3;

var R6WindowTextLabel			      m_LMenuTitle; 
//var R6WindowTextLabel           m_LServerName;

var R6WindowButton	      m_ButtonMainMenu;
var R6WindowButton	      m_ButtonOptions;

var R6WindowPageSwitch                m_PageCount;

var R6WindowButtonMultiMenu           m_ButtonLogInOut;
var R6WindowButtonMultiMenu           m_ButtonJoin;
var R6WindowButtonMultiMenu           m_ButtonJoinIP;
var R6WindowButtonMultiMenu           m_ButtonRefresh;
var R6WindowButtonMultiMenu           m_ButtonCreate;

var R6WindowTextLabelCurved           m_FirstTabWindow;          // First tab window (on a simple curved frame)
var R6WindowTextLabelCurved           m_SecondTabWindow;         // Second tab window ( on a simple curved frame)
var R6WindowTextLabelExt              m_ServerDescription;       // the info bar description

var R6MenuMPButServerList			  m_pButServerList;			 // the buttons for sorting

var R6MenuMPManageTab                 m_pFirstTabManager;        // creation of the tab manager for the first tab window
var R6MenuMPManageTab                 m_pSecondTabManager;       // creation of the tab manager for the second tab window

var R6MenuMPMenuTab                   m_pSecondWindow;  
var R6MenuMPMenuTab                   m_pSecondWindowGameMode;  
var R6MenuMPMenuTab                   m_pSecondWindowFilter;  
var R6MenuMPMenuTab                   m_pSecondWindowServerInfo;  

var R6WindowSimpleFramedWindowExt     m_pFirstWindowBorder;
var R6WindowSimpleFramedWindowExt     m_pSecondWindowBorder;

var R6MenuHelpWindow                  m_pHelpTextWindow;

var R6WindowServerListBox             m_ServerListBox;           // List of servers with scroll bar

var R6WindowServerInfoPlayerBox       m_ServerInfoPlayerBox;     // List of information for selected server
var R6WindowServerInfoMapBox          m_ServerInfoMapBox;        // List of information for selected server
var R6WindowServerInfoOptionsBox      m_ServerInfoOptionsBox;    // List of information for selected server

var R6GSServers                       m_GameService;             // Manages servers from game service
var R6LanServers                      m_LanServers;              // Manages servers on the LAN
var INT                               m_FrameCounter;            // Counter to schedule slower processes
var UWindowListBoxItem                m_oldSelItem;              // Used to detect when selected server has changed

var MultiPlayerTabID                  m_ConnectionTab;
var MultiPlayerTabID                  m_FilterTab;

var R6WindowUbiLogIn                  m_pLoginWindow;            // Windows and logic for ubi.com login
var R6WindowJoinIp                    m_pJoinIPWindow;           // Windows and login for Join IP steps
var R6WindowQueryServerInfo           m_pQueryServerInfo;        // Windows and login for logic to query a server for information
var string                            m_szGamePwd;
var config string                     m_szPopUpIP;               // IP adress entered in pop up
var R6WindowRightClickMenu            m_pRightClickMenu;         // Used when user right clicks on a server

var string                            m_szServerIP;              // IP of server
var string							  m_szMultiLoc[2];			 // array of text localization

var FLOAT                             m_fMouseX;                 // X position of mouse
var FLOAT                             m_fMouseY;                 // Y position of mouse

var eLoginSuccessAction               m_LoginSuccessAction;      // Action to take after login procedure succeeds
                                                                 // keeps a history of pop up to return to./
var INT                               m_iTimeLastUpdate;         // Time in ms of the last server list update
var INT								  m_iLastSortCategory;		 // the last sort we did
var config INT						  m_iLastTabSel;			 // The last tab selected between Internet and LAN
var INT								  m_iTotalPlayers;			 // total players

var config int m_iFilterFasterThan;

var BOOL                              m_bListUpdateReq;          // the server list needs to be updated
var BOOL							  m_bLastTypeOfSort;
var BOOL                              m_bFPassWindowActv;        // First pass flag used for when window is first activated
var BOOL                              m_bJoinIPInProgress;
var BOOL                              m_bQueryServerInfoInProgress;
var FLOAT                             m_fRefeshDeltaTime;        // Time since refresh button last hit

var float m_fLastUpdateServerFilterTime;
var BOOL                              m_bGetServerInfo;          // Need to get the server info for the selected server
var BOOL                              m_bLanRefreshFPass;        // First pass flag for LAN server refresh
var BOOL                              m_bIntRefreshFPass;        // First pass flag for Internet server refresh

var bool m_bNeedUpdateServerFilter;

var config bool m_bFilterDeathMatch;

var config bool m_bFilterTeamDeathMatch;

var config bool m_bFilterDisarmBomb;

var config bool m_bFilterHostageRescueAdv;

var config bool m_bFilterEscortPilot;

var config bool m_bFilterMission;

var config bool m_bFilterTerroristHunt;

var config bool m_bFilterHostageRescueCoop;

var config bool m_bFilterUnlockedOnly;

var config bool m_bFilterFavoritesOnly;

var config bool m_bFilterDedicatedServersOnly;

var config bool m_bFilterServersNotEmpty;

var config bool m_bFilterServersNotFull;

var config bool m_bFilterResponding;

var config bool m_bFilterSameVersion;

var config bool m_bFilterPunkBusterServerOnly;

function Created()
{
    m_GameService = R6Console(Root.console).m_GameService;
//    m_LanServers  = R6Console(Root.console).m_LanServers;

    // display
    InitText();   // init the text
    InitButton(); // init the necessary buttons

	m_FirstTabWindow = R6WindowTextLabelCurved(CreateWindow(class'R6WindowTextLabelCurved', K_XSTARTPOS, 85, K_WINDOWWIDTH, 30, self));
    m_FirstTabWindow.bAlwaysBehind = true;
	m_FirstTabWindow.Text = "";    
    m_FirstTabWindow.m_BGTexture = None; // no background

    m_pFirstTabManager = R6MenuMPManageTab(CreateWindow(class'R6MenuMPManageTab', K_XSTARTPOS + K_XTABOFFSET, 90, K_FIRST_TABWINDOW_WIDTH , 25, self));
    m_pFirstTabManager.AddTabInControl(Localize("MultiPlayer","Tab_InternetServer","R6Menu"), Localize("Tip","Tab_InternetServer","R6Menu"),
                                       MultiPlayerTabID.TAB_Internet_Server);
    m_pFirstTabManager.AddTabInControl(Localize("MultiPlayer","Tab_LanServer","R6Menu"), Localize("Tip","Tab_LanServer","R6Menu"),
                                       MultiPlayerTabID.TAB_Lan_Server);

    InitInfoBar();
    InitFirstTabWindow();
//    InitServerList();
    InitServerInfoPlayer();
    InitServerInfoMap();
    InitServerInfoOptions();
    InitRightClickMenu();
 
	m_SecondTabWindow = R6WindowTextLabelCurved(CreateWindow(class'R6WindowTextLabelCurved', K_XSTARTPOS, K_YPOS_SECOND_TABWINDOW, K_WINDOWWIDTH, 30, self));
    m_SecondTabWindow.bAlwaysBehind = true;
	m_SecondTabWindow.Text = "";
    m_SecondTabWindow.m_BGTexture = None; // no background

    m_pSecondTabManager = R6MenuMPManageTab(CreateWindow(class'R6MenuMPManageTab', K_XSTARTPOS + K_XTABOFFSET, K_YPOS_SECOND_TABWINDOW + 5, K_SEC_TABWINDOW_WIDTH, 25, self));
    m_pSecondTabManager.AddTabInControl(Localize("MultiPlayer","Tab_GameFilter","R6Menu"), Localize("Tip","Tab_GameFilter","R6Menu"),
                                        MultiPlayerTabID.TAB_Game_Mode);
    m_pSecondTabManager.AddTabInControl(Localize("MultiPlayer","Tab_TechFilter","R6Menu"), Localize("Tip","Tab_TechFilter","R6Menu"),
                                        MultiPlayerTabID.TAB_Tech_Filter);
    m_pSecondTabManager.AddTabInControl(Localize("MultiPlayer","Tab_ServerInfo","R6Menu"), Localize("Tip","Tab_ServerInfo","R6Menu"),
                                        MultiPlayerTabID.TAB_Server_Info);

//    InitSecondTabWindow(); // GameMode, Tech Filter, ServerInfo;

    // create the help window
    m_pHelpTextWindow = R6MenuHelpWindow(CreateWindow(class'R6MenuHelpWindow', 150, 429, 340, 42, self)); //std param is set in help window    
	m_pHelpTextWindow.m_bForceRefreshOnSameTip = true;

	m_pLoginWindow = R6WindowUbiLogIn(CreateWindow( Root.MenuClassDefines.ClassUbiLogIn, 0, 0, 640, 480, self, TRUE));
    m_pLoginWindow.m_GameService = m_GameService;
    m_pLoginWindow.PopUpBoxCreate();
    m_pLoginWindow.HideWindow();


	m_pJoinIPWindow = R6WindowJoinIP(CreateWindow(Root.MenuClassDefines.ClassMultiJoinIP, 0, 0, 640, 480, self, TRUE));
    m_pJoinIPWindow.m_GameService = m_GameService;
    m_pJoinIPWindow.PopUpBoxCreate();
    m_pJoinIPWindow.HideWindow();

	m_pQueryServerInfo = R6WindowQueryServerInfo(CreateWindow(Root.MenuClassDefines.ClassQueryServerInfo, 0, 0, 640, 480, self, TRUE));
    m_pQueryServerInfo.m_GameService = m_GameService;
    m_pQueryServerInfo.PopUpBoxCreate();
    m_pQueryServerInfo.HideWindow();

    m_bFPassWindowActv = TRUE;

    if ( m_GameService.m_bLoggedInUbiDotCom )
        m_ButtonLogInOut.SetButLogInOutState( EBN_LogOut );
    else
        m_ButtonLogInOut.SetButLogInOutState( EBN_LogIn );

    m_fRefeshDeltaTime   = K_REFRESH_TIMEOUT;

    // If refresh was in progress when we exited the menu system,
    // set flags to false so that it will not be active when the player
    // returns to the menus.
	m_GameService.StopRefreshServers();

	m_szMultiLoc[0] = Localize("MultiPlayer","NbOfServers","R6Menu");
	m_szMultiLoc[1] = Localize("MultiPlayer","NbOfPlayers","R6Menu");

    m_PageCount = R6WindowPageSwitch(CreateWindow(class'R6WindowPageSwitch', 530, 90, 90, 25, self));    

    m_fLastUpdateServerFilterTime = GetTime();
    m_bNeedUpdateServerFilter = false;
    
}

/////////////////////////////////////////////////////////////////
// display the background
/////////////////////////////////////////////////////////////////
function Paint(Canvas C, float X, float Y)
{
    local R6WindowTextLabel pR6TextLabelTemp;

    Root.PaintBackground(C, self);
    m_fMouseX = X;
    m_fMouseY = Y;
    if(m_ConnectionTab == TAB_Lan_Server)
    {
        m_LanServers.LANSeversManager();
    }
    if((m_LanServers.m_bServerListChanged || m_GameService.m_bServerListChanged) && (m_GameService.NativeGetMilliSeconds() - m_iTimeLastUpdate) > 1000)
    {
        m_iTimeLastUpdate = m_GameService.NativeGetMilliSeconds();
        m_GameService.m_bServerListChanged = false;
        m_LanServers.m_bServerListChanged = false;
        if(m_ConnectionTab == TAB_Lan_Server)
        {
            ResortServerList(m_iLastSortCategory, m_bLastTypeOfSort);
            UpdateFilters();
            GetLanServers();            
        }
        else
        {
            UpdateFilters();
            GetGSServers();
        }
    }
    if(m_ConnectionTab == TAB_Internet_Server)
    {
        if(m_GameService.m_bRefreshFinished)
        {
            m_GameService.m_bRefreshFinished = false;
            ResortServerList(m_iLastSortCategory, m_bLastTypeOfSort);
            GetGSServers();
            m_bGetServerInfo = true;
        }
        if(m_GameService.IsRefreshServersInProgress())
        {
            SetCursor(Root.WaitCursor);            
        }
        else
        {
            SetCursor(Root.NormalCursor);
        }        
    }
    else
    {
        SetCursor(Root.NormalCursor);
    }
    if(m_ServerListBox.m_SelectedItem != m_oldSelItem)
    {
        m_oldSelItem = m_ServerListBox.m_SelectedItem;
        if(m_ConnectionTab == TAB_Lan_Server)
        {
            if(m_ServerListBox.m_SelectedItem != none)
            {
                m_LanServers.SetSelectedServer(R6WindowListServerItem(m_ServerListBox.m_SelectedItem).iMainSvrListIdx);
            }
            GetServerInfo(m_LanServers);            
        }
        else
        {
            if(m_ServerListBox.m_SelectedItem != none)
            {
                m_GameService.SetSelectedServer(R6WindowListServerItem(m_ServerListBox.m_SelectedItem).iMainSvrListIdx);
            }
            m_bGetServerInfo = true;
        }
    }
    if(((m_bGetServerInfo && !m_GameService.IsRefreshServersInProgress()) && m_ConnectionTab == TAB_Internet_Server) && m_FilterTab == TAB_Server_Info)
    {
        if(m_GameService.m_GameServerList.Length > 0)
        {
            m_GameService.NativeMSClientReqAltInfo(m_GameService.m_GameServerList[m_GameService.m_iSelSrvIndex].iLobbySrvID, m_GameService.m_GameServerList[m_GameService.m_iSelSrvIndex].iGroupID);
        }
        ClearServerInfo();
        m_bGetServerInfo = false;
    }
    if(m_GameService.m_bServerInfoChanged && m_ConnectionTab == TAB_Internet_Server)
    {
        GetServerInfo(m_GameService);
        m_GameService.m_bServerInfoChanged = false;
    }
    if(m_GameService.NativeIsRouterDisconnect())
    {
        m_LoginSuccessAction = eLSAct_CloseWindow;
        m_pLoginWindow.LogInAfterDisconnect(self);
    }
    if(m_LoginSuccessAction != eLSAct_None)
    {
        m_pLoginWindow.Manager(self);
    }
    if(m_bJoinIPInProgress)
    {
        m_pJoinIPWindow.Manager(self);
    }
    if(m_bQueryServerInfoInProgress)
    {
        m_pQueryServerInfo.Manager(self);
    }
    if(m_ServerListBox.m_SelectedItem == none)
    {
        m_ButtonJoin.bDisabled = true;        
    }
    else
    {
        if(!R6WindowListServerItem(m_ServerListBox.m_SelectedItem).bSameVersion)
        {
            m_ButtonJoin.bDisabled = true;            
        }
        else
        {
            m_ButtonJoin.bDisabled = false;
        }
    }
}

function ShowWindow()
{
    local string _szIpAddress;
    // Since the client beacon is an actor, it will get
    // destroyed every time we change levels.  Check here
    // if the beacon exists and re-spawn when needed.

	R6MenuRootWindow(Root).m_pMenuCDKeyManager.SetWindowUser(Root.eGameWidgetID.MultiPlayerWidgetID, self);
    if (m_LanServers == none)
    {
		m_LanServers  = new(none) class<R6LanServers>(Root.MenuClassDefines.ClassLanServer);
        R6Console(Root.console).m_LanServers = m_LanServers;
        m_LanServers.Created();
        InitServerList();
        InitSecondTabWindow(); // GameMode, Tech Filter, ServerInfo;
    }
    if(m_LanServers.m_ClientBeacon == none)
        m_LanServers.m_ClientBeacon  = Root.Console.ViewportOwner.Actor.Spawn( class'ClientBeaconReceiver' );
    m_GameService.m_ClientBeacon = m_LanServers.m_ClientBeacon;

	m_iLastSortCategory = m_LanServers.eSortCategory.eSG_PingTime;
	m_bLastTypeOfSort   = true;
    
	Super.ShowWindow();

    R6Console(Root.console).m_GameService.initGSCDKey();
    
	// randomly update the background texture
	Root.SetLoadRandomBackgroundImage("Multiplayer");
    if (R6Console(Root.console).m_bNonUbiMatchMaking)
    {
        class'Actor'.static.NativeNonUbiMatchMakingAddress(_szIpAddress);
		// ASE DEVELOPMENT - Eric Begin - May 11th, 2003
		//
		// In orfer to simplify the code, I added a new function "StartCmdLineJoinIPProcedure"
		// This functoin make sure that the player is connected on Ubi.Com before login in on the 
		// game server

        m_pJoinIPWindow.StartCmdLineJoinIPProcedure(m_ButtonJoinIP, _szIpAddress);
        m_bJoinIPInProgress = TRUE;
    }   

}

/////////////////////////////////////////////////////////////////
// display the help text in the m_pHelpTextWindow (derivate for uwindowwindow
/////////////////////////////////////////////////////////////////
function ToolTip(string strTip) 
{
	ManageToolTip( strTip);
}

function ManageToolTip( string _strTip, optional BOOL _bForceATip)
{
	local string szTemp1, szTemp2;
	local INT iNbOfServers;

	if ((m_pHelpTextWindow == None) || !bWindowVisible)
		return;

	szTemp1 = _strTip;
	szTemp2 = "";
	if (_bForceATip)
	{
		if (m_ConnectionTab == TAB_Internet_Server)
			m_iTotalPlayers = m_GameService.GetTotalPlayers();
		else
        {
            m_iTotalPlayers = m_LanServers.GetTotalPlayers();
        }
    }

	if (_strTip == "")
	{
		if (m_ConnectionTab == TAB_Internet_Server)
			iNbOfServers = m_GameService.m_GameServerList.Length;
		else
        {

            iNbOfServers = m_LanServers.m_GameServerList.Length;
        }

		szTemp1 = m_szMultiLoc[0] $ " " $ string(iNbOfServers);
		szTemp2 = m_szMultiLoc[1] $ " " $ string(m_iTotalPlayers);
	}

	m_pHelpTextWindow.ToolTip( szTemp1);

	if (szTemp2 != "")
		m_pHelpTextWindow.AddTipText(szTemp2);
}

/////////////////////////////////////////////////////////////////
// manage the tab selection (the call of the fct come from R6MenuMPManageTab
/////////////////////////////////////////////////////////////////
function ManageTabSelection( INT _MPTabChoiceID)
{
    // Clear the information in the server info tab everytime we change tabs
//    ClearServerInfo();

    switch(_MPTabChoiceID)
    {
        case MultiPlayerTabID.TAB_Lan_Server:
            m_ConnectionTab = TAB_Lan_Server;
            if ( m_LanServers.m_GameServerList.length == 0 )
                Refresh( FALSE );
            GetLanServers();
            GetServerInfo( m_LanServers );
            UpdateServerFilters();
			m_iLastTabSel = MultiPlayerTabID.TAB_Lan_Server;
			SaveConfig();
            break;
        case MultiPlayerTabID.TAB_Internet_Server:
            m_ConnectionTab = TAB_Internet_Server;
            m_LoginSuccessAction = eLSAct_InternetTab;
            m_pLoginWindow.StartLogInProcedure(self);
            if ( m_GameService.m_GameServerList.length == 0 )
                Refresh( FALSE );
            GetGSServers();
            UpdateServerFilters();
			m_iLastTabSel = MultiPlayerTabID.TAB_Internet_Server;
			SaveConfig();
            break;
        case MultiPlayerTabID.TAB_Game_Mode:
            m_FilterTab = TAB_Game_Mode;
            m_ServerInfoPlayerBox.HideWindow();
            m_ServerInfoMapBox.HideWindow();
            m_ServerInfoOptionsBox.HideWindow();
            m_pSecondWindow.HideWindow();
            m_pSecondWindowGameMode.ShowWindow();
            m_pSecondWindow = m_pSecondWindowGameMode;
            break;
        case MultiPlayerTabID.TAB_Tech_Filter:
            m_FilterTab = TAB_Tech_Filter;
            m_ServerInfoPlayerBox.HideWindow();
            m_ServerInfoMapBox.HideWindow();
            m_ServerInfoOptionsBox.HideWindow();
            m_pSecondWindow.HideWindow();
            m_pSecondWindowFilter.ShowWindow();
            m_pSecondWindow = m_pSecondWindowFilter;
            break;
        case MultiPlayerTabID.TAB_Server_Info:
//			m_oldSelItem = None; // update the selection info
            m_FilterTab = TAB_Server_Info;
			m_pSecondWindow.HideWindow();
			m_pSecondWindowServerInfo.ShowWindow();
			m_ServerInfoPlayerBox.ShowWindow();
			m_ServerInfoMapBox.ShowWindow();
			m_ServerInfoOptionsBox.ShowWindow();
			m_pSecondWindow = m_pSecondWindowServerInfo;
            break;
        default:
            log("This tab was not supported (R6MenuMultiPlayerWidget)");
            break;
    }
}

/////////////////////////////////////////////////////////////////
// set the button choice from game mode, tech filters
/////////////////////////////////////////////////////////////////
function SetServerFilterBooleans(int _iServerInfoID, bool _bNewChoice)
{
    switch(_iServerInfoID)
    {
        case eServerInfoID.eServerInfoID_DeathMatch:
            m_bFilterDeathMatch = _bNewChoice;
            break;
        case eServerInfoID.eServerInfoID_TeamDeathMatch:
            m_bFilterTeamDeathMatch = _bNewChoice;
            break;
        case eServerInfoID.eServerInfoID_Bomb:
            m_bFilterDisarmBomb = _bNewChoice;
            break;
        case eServerInfoID.eServerInfoID_HostageAdv:
            m_bFilterHostageRescueAdv = _bNewChoice;
            break;
        case eServerInfoID.eServerInfoID_Escort:
            m_bFilterEscortPilot = _bNewChoice;
            break;
        case eServerInfoID.eServerInfoID_Mission:
            m_bFilterMission = _bNewChoice;
            break;
        case eServerInfoID.eServerInfoID_Terrorist:
            m_bFilterTerroristHunt = _bNewChoice;
            break;
        case eServerInfoID.eServerInfoID_HostageCoop:
            m_bFilterHostageRescueCoop = _bNewChoice;
            break;
        case eServerInfoID.eServerInfoID_Unlocked:
            m_bFilterUnlockedOnly = _bNewChoice;
            break;
        case eServerInfoID.eServerInfoID_Favorites:
            m_bFilterFavoritesOnly = _bNewChoice;
            break;
        case eServerInfoID.eServerInfoID_Dedicated:
            m_bFilterDedicatedServersOnly = _bNewChoice;
            break;
        case eServerInfoID.eServerInfoID_PunkBuster:
            m_bFilterPunkBusterServerOnly = _bNewChoice;
            break;
        case eServerInfoID.eServerInfoID_NotEmpty:
            m_bFilterServersNotEmpty = _bNewChoice;
            break;
        case eServerInfoID.eServerInfoID_NotFull:
            m_bFilterServersNotFull = _bNewChoice;
            break;
        case eServerInfoID.eServerInfoID_Responding:
            m_bFilterResponding = _bNewChoice;
            break;
        case eServerInfoID.eServerInfoID_SameVersion:
            m_bFilterSameVersion = _bNewChoice;
            break;
        default:
            log("Sorry, no server info associate with this button");
            break;
    }
    if(GetTime() < (m_fLastUpdateServerFilterTime + 0.3))
    {
        m_bNeedUpdateServerFilter = true;
        return;
    }
    m_bNeedUpdateServerFilter = false;
    UpdateServerFilters();
}

//-------------------------------------------------------
// SetServerFilterFasterThan - Set the "Faster Than" filter
// setting (ping time)
//-------------------------------------------------------
function SetServerFilterFasterThan( INT iFasterThan )
{

    m_iFilterFasterThan = iFasterThan;

    UpdateServerFilters();
}

//-------------------------------------------------------
// UpdateServerFilters - Call this every time one of the
// filter settings changes, it we check the list of servers
// to see whcih ones should be displayed.
//-------------------------------------------------------
function UpdateServerFilters()
{
    m_pSecondWindowGameMode.UpdateGameTypeFilter();
    m_pSecondWindowFilter.UpdateGameTypeFilter();

    if ( m_ConnectionTab == TAB_Lan_Server )
    {
		UpdateFilters();
		SaveConfig();
		
        
        GetLanServers();
    }
    else
    {
		UpdateFilters();
		SaveConfig();
		
        
        GetGSServers();
    }

    m_fLastUpdateServerFilterTime = GetTime();
}

function UpdateFilters()
{
    local R6ModMgr pModMgr;
    local int i, j, iNbOfServers;
    local bool bFound, bIsRavenShield, bIsLanServers;
    local string szCurrentMod, szTempGDGameType;
    local R6ServerList.stGameServer stTempGameServerItem;

    pModMgr = class'Actor'.static.GetModMgr();
    szCurrentMod = pModMgr.m_pCurrentMod.m_szKeyWord;
    bIsLanServers = m_ConnectionTab == TAB_Lan_Server;
    if(bIsLanServers)
    {
        iNbOfServers = m_LanServers.m_GameServerList.Length;        
    }
    else
    {
        iNbOfServers = m_GameService.m_GameServerList.Length;
    }

    for(i = 0; i < iNbOfServers; i++)
    {
        if(bIsLanServers)
        {
            m_LanServers.m_GameServerList[i].bDisplay = false;
            stTempGameServerItem = m_LanServers.m_GameServerList[i];            
        }
        else
        {
            m_GameService.m_GameServerList[i].bDisplay = false;
            stTempGameServerItem = m_GameService.m_GameServerList[i];
        }
        szTempGDGameType = stTempGameServerItem.sGameData.szGameDataGameType;
        if(!m_bFilterDeathMatch && szTempGDGameType == "RGM_DeathmatchMode")
        {
            continue;
        }
        if(!m_bFilterTeamDeathMatch && szTempGDGameType == "RGM_TeamDeathmatchMode")
        {
            continue;
        }
        if(!m_bFilterDisarmBomb && szTempGDGameType == "RGM_BombAdvMode")
        {
            continue;
        }
        if(!m_bFilterHostageRescueAdv && szTempGDGameType == "RGM_HostageRescueAdvMode")
        {
            continue;
        }
        if(!m_bFilterEscortPilot && szTempGDGameType == "RGM_EscortAdvMode")
        {
            continue;
        }
        if(!m_bFilterMission && szTempGDGameType == "RGM_MissionMode")
        {
            continue;
        }
        if(!m_bFilterTerroristHunt && szTempGDGameType == "RGM_TerroristHuntCoopMode")
        {
            continue;
        }
        if(!m_bFilterHostageRescueCoop && szTempGDGameType == "RGM_HostageRescueCoopMode")
        {
            continue;
        }
        if((stTempGameServerItem.sGameData.szModName != "") && !(stTempGameServerItem.sGameData.szModName ~= szCurrentMod))
        {
            log(("UpdateFilters() szModName is different than current MOD " @ stTempGameServerItem.sGameData.szModName) @ szCurrentMod);
            continue;
        }
        if(m_bFilterUnlockedOnly && stTempGameServerItem.sGameData.bUsePassword)
        {
            continue;
        }
        if(m_bFilterFavoritesOnly && !stTempGameServerItem.bFavorite)
        {
            continue;
        }
        if(m_bFilterDedicatedServersOnly && !stTempGameServerItem.sGameData.bDedicatedServer)
        {
            continue;
        }
        if(m_bFilterServersNotEmpty && stTempGameServerItem.sGameData.iNbrPlayer == 0)
        {
            continue;
        }
        if(bIsLanServers)
        {
            if(m_bFilterServersNotFull && stTempGameServerItem.sGameData.iNbrPlayer >= m_LanServers.m_GameServerList[i].sGameData.iMaxPlayer)
            {
                continue;
            }            
        }
        else
        {
            if(m_bFilterServersNotFull && stTempGameServerItem.sGameData.iNbrPlayer >= m_GameService.m_GameServerList[i].sGameData.iMaxPlayer)
            {
                continue;
            }
        }
        if(m_bFilterPunkBusterServerOnly && !stTempGameServerItem.sGameData.bPunkBuster)
        {
            continue;
        }
        if(m_bFilterResponding && stTempGameServerItem.iPing >= 1000)
        {
            continue;
        }
        if((m_iFilterFasterThan > 0) && stTempGameServerItem.iPing > m_iFilterFasterThan)
        {
            continue;
        }
        if(m_bFilterSameVersion && !stTempGameServerItem.bSameVersion)
        {
            continue;
        }
        if(bIsLanServers)
        {
            m_LanServers.m_GameServerList[i].bDisplay = true;
            continue;
        }
        m_GameService.m_GameServerList[i].bDisplay = true;
    }
}

//==============================================================================
// Refresh -  Refresh the list of servers.  CLears the list then calls the
// appropriate function to completetly rebuild the list of servers with 
// fresh data.
//==============================================================================
function Refresh( BOOL bActivatedByUser )
{
    local INT i;

    // Protection against someone hitting the refresh button
    // many times, add a timeout.
    

    if ( bActivatedByUser )
    {
        if ( m_fRefeshDeltaTime > K_REFRESH_TIMEOUT )
            m_fRefeshDeltaTime = 0;
        else
            return;
    }


    // Update the server info
    m_oldSelItem = None;

    if ( m_ConnectionTab == TAB_Lan_Server )
    {
        m_LanServers.RefreshServers();
        ResortServerList( m_iLastSortCategory, m_bLastTypeOfSort);
        GetLanServers();


        // Clear all the information in the client beacon 

        for ( i = 0; i < m_LanServers.m_ClientBeacon.GetBeaconListSize(); i++ )
           m_LanServers.m_ClientBeacon.ClearBeacon(i);
    }
    else
    {
        if ( m_GameService.m_bLoggedInUbiDotCom )
            m_GameService.RefreshServers();
    }

}

//==============================================================================
// GetLanServers - This functions gets the current list of servers from the 
// Lan server code, it does not refresh this list, it is simply used for
// passing a list that has already been built.  It will only get the elements
// in the list that have been flagged to be displayed.
//==============================================================================

function GetLanServers()
{

	local R6WindowListServerItem NewItem;
    local INT                    i, j;
    local INT                    iNumServers;
    local INT                    iNumServersDisplay;
        local string                 szSelSvrIP;
    local BOOL                   bFirstSvr;
    local string			     szGameType;
	local LevelInfo				 pLevel;

    local R6Console console;
    local int iNbPages;
    local int iStartingIndex, iEndIndex;

	local R6ServerList.stGameServer _stGameServer;

    console = R6Console(Root.Console);
	pLevel = GetLevel();

    // Remember IP of selected server, we sill keep this server highlighted
    // in the list if it is still there after the list has been rebuilt.

    if ( m_ServerListBox.m_SelectedItem != None )
        szSelSvrIP = R6WindowListServerItem(m_ServerListBox.m_SelectedItem).szIPAddr;
    else
        szSelSvrIP = "";

	m_ServerListBox.ClearListOfItems(); // Clear current list of servers
    m_ServerListBox.m_SelectedItem = None;

    iNumServers        = m_LanServers.m_GameServerList.length;
    iNumServersDisplay = m_LanServers.GetDisplayListSize();    

    bFirstSvr = TRUE;

    // nb of page
    iNbPages = iNumServersDisplay / console.iBrowserMaxNbServerPerPage;
    iNbPages += 1; // start at page 1
    
    // cap the page number
    // set current page / set max page
    if ( m_PageCount.m_iCurrentPages > iNbPages )
        m_PageCount.SetCurrentPage( iNbPages );
   
    if ( iNbPages != m_PageCount.m_iTotalPages )
        m_PageCount.SetTotalPages( iNbPages );

    iStartingIndex = console.iBrowserMaxNbServerPerPage * (m_PageCount.m_iCurrentPages - 1);
    iEndIndex      = iStartingIndex + console.iBrowserMaxNbServerPerPage;

    if ( iEndIndex > iNumServersDisplay )
        iEndIndex = iNumServersDisplay;

	j =0;
    i = iStartingIndex;
    
    while ( iNumServersDisplay > 0 )
    {
        if ( m_LanServers.m_GameServerList[m_LanServers.m_GSLSortIdx[i]].bDisplay )
        {
			NewItem = R6WindowListServerItem(m_ServerListBox.GetNextItem(j, NewItem));
			NewItem.Created();
            NewItem.iMainSvrListIdx = i;

			m_LanServers.getServerListItem( i, _stGameServer);

            NewItem.bFavorite    = _stGameServer.bFavorite;
            NewItem.bSameVersion = _stGameServer.bSameVersion;
			NewItem.szIPAddr = _stGameServer.szIPAddress;
			NewItem.iPing = _stGameServer.iPing;

			NewItem.szName = _stGameServer.sGameData.szName;
			NewItem.szMap = _stGameServer.sGameData.szCurrentMap;
			NewItem.iMaxPlayers = _stGameServer.sGameData.iMaxPlayer;
			NewItem.iNumPlayers = _stGameServer.sGameData.iNbrPlayer;
			szGameType = _stGameServer.sGameData.szGameDataGameType;
            NewItem.bLocked      = _stGameServer.sGameData.bUsePassword;
            NewItem.bDedicated   = _stGameServer.sGameData.bDedicatedServer;
//#ifdefR6PUNKBUSTER
			NewItem.bPunkBuster = _stGameServer.sGameData.bPunkBuster;
//#endif

			Root.GetMapNameLocalisation( NewItem.szMap, NewItem.szMap, true);

            // PATCH: The game mode (as displayed in the menus) is
            // either "adversarial" or "Cooperative" and depends entirely
            // on which game the user selected.  In the rest of the code
            // the game mode actually refers to what is called "Game Type"
            // in the menus.  

            NewItem.szGameType =  pLevel.GetGameNameLocalization(szGameType);

            if ( pLevel.IsGameTypeAdversarial(szGameType) )
                NewItem.szGameMode = Localize("MultiPlayer","GameMode_Adversarial","R6Menu");
            else if ( pLevel.IsGameTypeCooperative(szGameType) )
                NewItem.szGameMode = Localize("MultiPlayer","GameMode_Cooperative","R6Menu");
            else 
                NewItem.szGameMode = "";

            // If selected server is still in list, reset this item
            // to be the selcted server

            if ( NewItem.szIPAddr == szSelSvrIP || bFirstSvr )
            {
                m_ServerListBox.SetSelectedItem( NewItem );
                m_LanServers.SetSelectedServer( i );
            }

//            if ( m_GameService.m_GameServerList[i].szIPAddress == szSelSvrIP )
//                m_oldSelItem = m_ServerListBox.m_SelectedItem;
//            if ( NewItem.szIPAddr == szSelSvrIP )
//                m_oldSelItem = m_ServerListBox.m_SelectedItem;

            bFirstSvr = FALSE;
			j++;
        }

        i++;

        // we have filled the scroll bar
        if ( iStartingIndex + j >= iEndIndex )
            break;

        // we are at the end of the list
        if ( i >= iNumServers )
            break;

    }

	ManageToolTip( "", true);
}


//==============================================================================
// GetGSServers - This functions gets the current list of servers from the 
// game service code, it does not refresh this list, it is simply used for
// passing a list that has already been built.  It will only get the elements
// in the list that have been flagged to be displayed.
//==============================================================================
function GetGSServers()
{
	local R6WindowListServerItem NewItem;
    local INT                    i, j;
    local INT                    iNumServers;
    local INT                    iNumServersDisplay;
        local string                 szSelSvrIP;
    local BOOL                   bFirstSvr;
    local string			     szGameType;
	local LevelInfo				 pLevel;

    local R6Console console;
    local int iNbPages;
    local int iStartingIndex, iEndIndex;

	local R6ServerList.stGameServer _stGameServer;

    console = R6Console(Root.Console);
	pLevel  = GetLevel();

    // Remember IP of selected server, we sill keep this server highlighted
    // in the list if it is still there after the list has been rebuilt.

    if ( m_ServerListBox.m_SelectedItem != None )
        szSelSvrIP = R6WindowListServerItem(m_ServerListBox.m_SelectedItem).szIPAddr;
    else
        szSelSvrIP = "";

    m_ServerListBox.ClearListOfItems();  // Clear current list of servers
    m_ServerListBox.m_SelectedItem = None;

    iNumServers        = m_GameService.m_GameServerList.length;
    iNumServersDisplay = m_GameService.GetDisplayListSize();    

    bFirstSvr = TRUE;

    // nb of page
    iNbPages = iNumServersDisplay / console.iBrowserMaxNbServerPerPage;
    iNbPages += 1; // start at page 1
    
    // cap the page number
    // set current page / set max page
    if ( m_PageCount.m_iCurrentPages > iNbPages )
        m_PageCount.SetCurrentPage( iNbPages );
   
    if ( iNbPages != m_PageCount.m_iTotalPages )
        m_PageCount.SetTotalPages( iNbPages );

    iStartingIndex = console.iBrowserMaxNbServerPerPage * (m_PageCount.m_iCurrentPages - 1);
    iEndIndex      = iStartingIndex + console.iBrowserMaxNbServerPerPage;

    if ( iEndIndex > iNumServersDisplay )
        iEndIndex = iNumServersDisplay;

	j = 0;
    i = iStartingIndex;
    
    while ( iNumServersDisplay > 0 )
    {
        if ( m_GameService.m_GameServerList[m_GameService.m_GSLSortIdx[i]].bDisplay )
        {
            NewItem = R6WindowListServerItem(m_ServerListBox.GetNextItem(j, NewItem));
			NewItem.Created();
            NewItem.iMainSvrListIdx = i;

			m_GameService.getServerListItem( i, _stGameServer);
 
            NewItem.bFavorite    = _stGameServer.bFavorite;
            NewItem.bSameVersion = _stGameServer.bSameVersion;
			NewItem.szIPAddr = _stGameServer.szIPAddress;
			NewItem.iPing = _stGameServer.iPing;

			NewItem.szName = _stGameServer.sGameData.szName;
			NewItem.szMap = _stGameServer.sGameData.szCurrentMap;
			NewItem.iMaxPlayers = _stGameServer.sGameData.iMaxPlayer;
			NewItem.iNumPlayers = _stGameServer.sGameData.iNbrPlayer;
			szGameType = _stGameServer.sGameData.szGameDataGameType;
            NewItem.bLocked      = _stGameServer.sGameData.bUsePassword;
            NewItem.bDedicated   = _stGameServer.sGameData.bDedicatedServer;
//#ifdefR6PUNKBUSTER
			NewItem.bPunkBuster = _stGameServer.sGameData.bPunkBuster;
//#endif

			Root.GetMapNameLocalisation( NewItem.szMap, NewItem.szMap, true);

            NewItem.szGameType =  pLevel.GetGameNameLocalization(szGameType);

            if ( pLevel.IsGameTypeAdversarial(szGameType) )
                NewItem.szGameMode = Localize("MultiPlayer","GameMode_Adversarial","R6Menu");
            else if ( pLevel.IsGameTypeCooperative(szGameType) )
                NewItem.szGameMode = Localize("MultiPlayer","GameMode_Cooperative","R6Menu");

            // If selected server is still in list, reset this item
            // to be the selcted server.  By default the selected server will
            // be the first server in the list.

            if ( NewItem.szIPAddr == szSelSvrIP || bFirstSvr )
            {
                m_ServerListBox.SetSelectedItem( NewItem );
                m_GameService.SetSelectedServer( i );
            }

//            if ( m_GameService.m_GameServerList[i].szIPAddress == szSelSvrIP )
//                m_oldSelItem = m_ServerListBox.m_SelectedItem;
//            if ( NewItem.szIPAddr == szSelSvrIP )
//                m_oldSelItem = m_ServerListBox.m_SelectedItem;

            bFirstSvr = FALSE;
			j++;
        }

        i++;

        // we have filled the scroll bar
        if ( iStartingIndex + j >= iEndIndex )
            break;

        // we are at the end of the list
        if ( i >= iNumServers )
            break;

    }

	ManageToolTip( "", true);
}

//==============================================================================
// GetServerInfo - This functions gets the detailed information for the 
// current selected servers from the 
// game service code, it does not refresh this information, it is simply used for
// passing a list that has already been built.
//==============================================================================

function GetServerInfo( R6ServerList pServerList)
{

	local R6WindowListInfoPlayerItem  NewItemPlayer;
	local R6WindowListInfoMapItem     NewItemMap;
	local R6WindowListInfoOptionsItem NewItemOptions;
	local R6MenuButtonsDefines		  pButtonsDef;
    local INT                    i;
    local INT                    iNum;

    ClearServerInfo();

    if ( pServerList.m_GameServerList.length == 0 )
        return;

    iNum = pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.gameMapList.length;

    for ( i = 0; i < iNum; i++ )
    {
        NewItemMap  = R6WindowListInfoMapItem (m_ServerInfoMapBox.GetItemAtIndex(i));
        NewItemMap.szMap       = pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.gameMapList[i].szMap;
		Root.GetMapNameLocalisation( NewItemMap.szMap, NewItemMap.szMap, true);
        NewItemMap.szType = GetLevel().GetGameNameLocalization(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.gameMapList[i].szGameType);
    }


    iNum = pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.playerList.length;

    pServerList.SortPlayersByKills( FALSE, pServerList.m_iSelSrvIndex );
    for ( i = 0; i < iNum; i++ )
    {
        NewItemPlayer  = R6WindowListInfoPlayerItem (m_ServerInfoPlayerBox.GetItemAtIndex(i));
        NewItemPlayer.szPlName    = pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.playerList[i].szAlias;
        NewItemPlayer.iSkills     = pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.playerList[i].iSkills;
        NewItemPlayer.szTime      = pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.playerList[i].szTime;
        NewItemPlayer.iPing       = pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.playerList[i].iPing;
        NewItemPlayer.iRank       = 0;        // TODO
    }

	pButtonsDef = R6MenuButtonsDefines(GetButtonsDefinesUnique(Root.MenuClassDefines.ClassButtonsDefines));

	i = 0;
    NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(i++));
    NewItemOptions.szOptions   = pButtonsDef.GetButtonLoc( EButtonName.EBN_RoundPerMatch) $ " = "$ string(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.iRoundsPerMatch);

    NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(i++));
    NewItemOptions.szOptions   = pButtonsDef.GetButtonLoc( EButtonName.EBN_RoundTime) $ " = "$class'Actor'.static.ConvertIntTimeToString(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.iRoundTime );

    NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(i++));
    NewItemOptions.szOptions   = pButtonsDef.GetButtonLoc( EButtonName.EBN_TimeBetRound) $ " = "$pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.iBetTime;

#ifndefMPDEMO
    if (pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bAdversarial )
    {
        NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(i++));
        NewItemOptions.szOptions   = pButtonsDef.GetButtonLoc( EButtonName.EBN_BombTimer) $ " = "$pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.iBombTime;
    }
    else
    {
        NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(i++));
        NewItemOptions.szOptions   = pButtonsDef.GetButtonLoc( EButtonName.EBN_NB_of_Terro) $ " = "$ string(pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.iNumTerro );

        if ( pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bAIBkp )
        {
            NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(i++));
            NewItemOptions.szOptions   = pButtonsDef.GetButtonLoc( EButtonName.EBN_AIBkp);
        }

        if ( pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bRotateMap )
        {
            NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(i++));
            NewItemOptions.szOptions   = pButtonsDef.GetButtonLoc( EButtonName.EBN_RotateMap);
        }
    }
#endif
    
    if ( pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bShowNames )
    {
        NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(i++));
        NewItemOptions.szOptions   = pButtonsDef.GetButtonLoc( EButtonName.EBN_AllowTeamNames);
    }

//    if ( pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bInternetServer )
//    {
//        NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(i));
//        NewItemOptions.szOptions   = pButtonsDef.GetButtonLoc( EButtonName.EBN_InternetServer);
//    }

    if ( pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bFriendlyFire )
    {
        NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(i++));
        NewItemOptions.szOptions   = pButtonsDef.GetButtonLoc( EButtonName.EBN_FriendlyFire);
    }

    if ( pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bAutoBalTeam )
    {
        NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(i++));
        NewItemOptions.szOptions   = pButtonsDef.GetButtonLoc( EButtonName.EBN_AutoBalTeam);
    }

    if ( pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bTKPenalty )
    {
        NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(i++));
        NewItemOptions.szOptions   = pButtonsDef.GetButtonLoc( EButtonName.EBN_TKPenalty);
    }

    if ( pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bRadar )
    {
        NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(i++));
        NewItemOptions.szOptions   = pButtonsDef.GetButtonLoc( EButtonName.EBN_AllowRadar);
    }

    if ( pServerList.m_GameServerList[pServerList.m_iSelSrvIndex].sGameData.bForceFPWeapon )
    {
        NewItemOptions = R6WindowListInfoOptionsItem(m_ServerInfoOptionsBox.GetItemAtIndex(i++));
        NewItemOptions.szOptions   = pButtonsDef.GetButtonLoc( EButtonName.EBN_ForceFPersonWp);
    }
}

//==============================================================================
// ClearServerInfo - clear all of the information in the server info tab.
//==============================================================================
function ClearServerInfo()
{
    m_ServerInfoPlayerBox.ClearListOfItems();  // Clear current list
    m_ServerInfoMapBox.ClearListOfItems();
    m_ServerInfoOptionsBox.ClearListOfItems();
}

//==============================================================================
// QuickJoin -  Join the first server in the server list.
//==============================================================================

function QuickJoin()
{

// This function is no longer needed (removed from the design of the game)

//
//	local R6WindowListServerItem NewItem;
//
//    NewItem = R6WindowListServerItem(m_ServerListBox.Items.FindEntry(0));  // 0 for first entry in list
//    PreJoin( NewItem.szIPAddr, FALSE );
}

//==============================================================================
// JoinSelectedServerRequested -  The user has requested to join the selected
// server (in the server list).  Determine the IP to join and Start the procedure
// to Query the server for information before joining.
//==============================================================================

function JoinSelectedServerRequested()
{
    local INT iBeaconPort;
    
    if ( m_ServerListBox.m_SelectedItem == None )
        return;

    if ( R6WindowListServerItem(m_ServerListBox.m_SelectedItem).bSameVersion )
    {
        if ( m_ConnectionTab == TAB_Internet_Server )
        {
            m_szServerIP = m_GameService.GetSelectedServerIP();
            iBeaconPort  = m_GameService.m_GameServerList[m_GameService.m_iSelSrvIndex].iBeaconPort;
        }
            
        else
        {
            m_szServerIP = m_LanServers.m_GameServerList[m_LanServers.m_iSelSrvIndex].szIPAddress;
            iBeaconPort  = m_LanServers.m_GameServerList[m_LanServers.m_iSelSrvIndex].iBeaconPort;
//            iBeaconPort  = 0;
        }

        m_pQueryServerInfo.StartQueryServerInfoProcedure( OwnerWindow, m_szServerIP, iBeaconPort );
        m_bQueryServerInfoInProgress = TRUE;
    }
}

//==============================================================================
// QueryReceivedStartPreJoin -  The query to the server has completed successfully,
// start the prejoin procedure which will check the CD Key validation and join
// a ubi.com room if necessary)
//==============================================================================

function QueryReceivedStartPreJoin()
{
    local BOOL                                  bRoomValid;

    bRoomValid = ( m_GameService.m_ClientBeacon.PreJoinInfo.iLobbyID != 0 &&
                   m_GameService.m_ClientBeacon.PreJoinInfo.iGroupID != 0    );

    if (( m_ConnectionTab == TAB_Internet_Server ) && !bRoomValid)
    {
        R6MenuRootWindow(Root).SimplePopUp(Localize("MultiPlayer","PopUp_Error_RoomJoin","R6Menu"),Localize("MultiPlayer","PopUp_Error_NoServer","R6Menu"), EPopUpID_RefreshServerList, MessageBoxButtons.MB_OK);
        Refresh( false);
        return;
    }

    if ( bRoomValid )
    {
        R6MenuRootWindow(Root).m_pMenuCDKeyManager.StartCDKeyProcess(EJRC_BY_LOBBY_AND_ROOM_ID, m_GameService.m_ClientBeacon.PreJoinInfo);
    }
    else
    {
        R6MenuRootWindow(Root).m_pMenuCDKeyManager.StartCDKeyProcess(EJRC_NO, m_GameService.m_ClientBeacon.PreJoinInfo);
    }



}

function Tick(float deltaTime)
{

    // If desired, log in automatically the first time the user
    // goes to the multi player pages.
    // If ubi.com username and password are both valid and the flag is set, 
    // try to log in to ubi.com automatically

    if ( R6Console(Root.Console).m_bAutoLoginFirstPass )
    {
        R6Console(Root.Console).m_bAutoLoginFirstPass = FALSE;
		// ASE DEVELOPMENT - Eric Begin - May 11th, 2003
		// !R6Console(Root.Console).m_bNonUbiMatchMaking doesn't need to be checked
		// *
		// * At the end, When I was modifying this code, Ubi.com wasn't responding... TO CHECK
		// *
        if ( !R6Console(Root.Console).m_bStartedByGSClient)
		{
            m_GameService.StartAutoLogin();
		}
    }

    // m_bFPassWindowActv is used as a first pass flag when the window is first 
    // activated in the game.

    if ( m_bFPassWindowActv )
    {
	    if (m_iLastTabSel == MultiPlayerTabID.TAB_Internet_Server)
            m_pFirstTabManager.m_pMainTabControl.GotoTab( m_pFirstTabManager.m_pMainTabControl.GetTab(Localize("MultiPlayer","Tab_InternetServer","R6Menu")));
	    else
            m_pFirstTabManager.m_pMainTabControl.GotoTab( m_pFirstTabManager.m_pMainTabControl.GetTab(Localize("MultiPlayer","Tab_LanServer","R6Menu")));

        m_bFPassWindowActv = FALSE;
    }

    // Incremant timer for refresh button
    m_fRefeshDeltaTime += deltaTime;
    

    // Set LogIn/LogOut toggle button to the correct setting
    if ( m_GameService.m_bLoggedInUbiDotCom )
    {
        if ( m_ButtonLogInOut.m_eButton_Action != EBN_LogOut )
            m_ButtonLogInOut.SetButLogInOutState( EBN_LogOut );
    }
    else
    {
        if ( m_ButtonLogInOut.m_eButton_Action != EBN_LogIn )
            m_ButtonLogInOut.SetButLogInOutState( EBN_LogIn );
    }

    if ( m_GameService.m_bAutoLoginFailed )
    {
        m_GameService.m_bAutoLoginFailed = FALSE;
        if ( m_ConnectionTab == TAB_Internet_Server )
            ManageTabSelection( MultiPlayerTabID.TAB_Internet_Server );
    }

    // Refresh the server list automatically the first time we
    // enter either the lan or internet tab

    if ( m_bLanRefreshFPass )
    {
        if ( m_ConnectionTab == TAB_Lan_Server )
        {
            Refresh( FALSE );
            m_bLanRefreshFPass = FALSE;
        }
    }

    if ( m_bIntRefreshFPass )
    {
        if ( m_ConnectionTab == TAB_Internet_Server && m_GameService.m_bLoggedInUbiDotCom )
        {
            Refresh( FALSE );
            m_bIntRefreshFPass = FALSE;
        }
    }

    if (m_bNeedUpdateServerFilter && GetTime() > m_fLastUpdateServerFilterTime + 0.3)
    {
        m_bNeedUpdateServerFilter = false;
        UpdateServerFilters();
    }
}


//==============================================================================
// AddServerToFavorites -  Add the selected server to the list of favorites.  
//==============================================================================

function AddServerToFavorites()
{
    if ( m_ConnectionTab == TAB_Lan_Server )
        m_LanServers.AddToFavorites(R6WindowListServerItem(m_ServerListBox.m_SelectedItem).iMainSvrListIdx);
    else
        m_GameService.AddToFavorites(R6WindowListServerItem(m_ServerListBox.m_SelectedItem).iMainSvrListIdx); 
}



//==============================================================================
// DelServerFromFavorites -  Remove the selected server from the list of favorites.  
//==============================================================================

function DelServerFromFavorites()
{
    if ( m_ConnectionTab == TAB_Lan_Server )
        m_LanServers.DelFromFavorites(R6WindowListServerItem(m_ServerListBox.m_SelectedItem).iMainSvrListIdx);
    else
        m_GameService.DelFromFavorites(R6WindowListServerItem(m_ServerListBox.m_SelectedItem).iMainSvrListIdx); 
}


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
}


//---------------------------------------------------------------------------------
// DisplayRightClickMenu - Called when the user has right clicked on a server, the
// right click menu is displayed at the current mouse position 
//---------------------------------------------------------------------------------
function DisplayRightClickMenu()
{
    m_pRightClickMenu.DisplayMenuHere( m_fMouseX, m_fMouseY );
/*
    m_pRightClickMenu.SetValue( "" );
    m_pRightClickMenu.WinLeft = m_fMouseX;
    m_pRightClickMenu.WinTop  = m_fMouseY;
    m_pRightClickMenu.ShowWindow();
    m_pRightClickMenu.BringToFront();
    m_pRightClickMenu.DropDown();
*/
}

//---------------------------------------------------------------------------------
// UpdateFavorites - Called when the user has used the "right-click" menu to
// add or delete a server from his list of favorites.  This function update the file
// where the list is saved and update the displayed list of servers.
//---------------------------------------------------------------------------------

function UpdateFavorites()
{
    if ( m_pRightClickMenu.GetValue() == Localize("MultiPlayer","RightClick_AddFav","R6Menu") )
        AddServerToFavorites();
    else if ( m_pRightClickMenu.GetValue() == Localize("MultiPlayer","RightClick_SubFav","R6Menu") )
        DelServerFromFavorites();
    else if ( m_pRightClickMenu.GetValue() == Localize("MultiPlayer","RightClick_Refr","R6Menu") )
    {
        if ( m_ConnectionTab == TAB_Lan_Server )
            m_LanServers.RefreshOneServer( R6WindowListServerItem(m_ServerListBox.m_SelectedItem).iMainSvrListIdx );
        else
            m_GameService.RefreshOneServer( R6WindowListServerItem(m_ServerListBox.m_SelectedItem).iMainSvrListIdx );
    }
    
    if ( m_ConnectionTab == TAB_Lan_Server )
    {
        UpdateFilters();
        GetLanServers();
    }
    else
    {
        UpdateFilters();
        GetGSServers();
    }
}

//---------------------------------------------------------------------------------
// ResortServerList - Resort the list of servers based on a category and
// a flag indicating ascending or descending
//---------------------------------------------------------------------------------

function ResortServerList( INT iCategory, BOOL _bAscending )
{
	m_iLastSortCategory = iCategory;
	m_bLastTypeOfSort = _bAscending;

	m_GameService.SortServers( iCategory, _bAscending);
	m_LanServers.SortServers( iCategory, _bAscending);

    if ( m_ConnectionTab == TAB_Lan_Server )
        GetLanServers();
    else
        GetGSServers();
}

//*********************************
//      INIT CREATE FUNCTION
//*********************************
function InitText()
{
    // define Title
	m_LMenuTitle = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 0, 18, WinWidth - 8, 25, self));
	m_LMenuTitle.Text = Localize("MultiPlayer","Title","R6Menu");
	m_LMenuTitle.Align = TA_Right;
	m_LMenuTitle.m_Font = Root.Fonts[F_MenuMainTitle];
	m_LMenuTitle.TextColor = Root.Colors.White;
	m_LMenuTitle.m_BGTexture = None;
	m_LMenuTitle.m_HBorderTexture = None;
	m_LMenuTitle.m_VBorderTexture = None;
}


function InitButton()
{
	local Font  buttonFont;
    local FLOAT fXOffset, fYOffset, fWidth;
	local R6MenuButtonsDefines pButtonsDef;

    // define Main Menu Button
    m_ButtonMainMenu = R6WindowButton(CreateControl( class'R6WindowButton', K_XSTARTPOS, 425, 250, 25, self));
    m_ButtonMainMenu.ToolTipString      = Localize("Tip","ButtonMainMenu","R6Menu");
	m_ButtonMainMenu.Text               = Localize("SinglePlayer","ButtonMainMenu","R6Menu");	
	m_ButtonMainMenu.Align              = TA_LEFT;
	m_ButtonMainMenu.m_fFontSpacing     = 0;
	m_ButtonMainMenu.m_buttonFont       = Root.Fonts[F_MainButton];
	m_ButtonMainMenu.ResizeToText();

    // define option Button
	m_ButtonOptions = R6WindowButton(CreateControl( class'R6WindowButton', K_XSTARTPOS, 447, 250, 25, self));
    m_ButtonOptions.ToolTipString       = Localize("Tip","ButtonOptions","R6Menu");
	m_ButtonOptions.Text                = Localize("SinglePlayer","ButtonOptions","R6Menu");	
	m_ButtonOptions.Align               = TA_LEFT;	
	m_ButtonOptions.m_fFontSpacing      = 0;
	m_ButtonOptions.m_buttonFont        = Root.Fonts[F_MainButton];

    buttonFont		= Root.Fonts[F_PrincipalButton];

	pButtonsDef = R6MenuButtonsDefines(GetButtonsDefinesUnique(Root.MenuClassDefines.ClassButtonsDefines));

    fXOffset = K_XSTARTPOS; 
    fYOffset = 50;
    fWidth	 = 124;  // this is from 620 / 5 buttons = 124

    // define LOG IN/OUT button
	m_ButtonLogInOut = R6WindowButtonMultiMenu(CreateWindow( class'R6WindowButtonMultiMenu', fXOffset, fYOffset, 400, 25, self));
    m_ButtonLogInOut.ToolTipString		= pButtonsDef.GetButtonLoc( EButtonName.EBN_LogIn, True); 
    m_ButtonLogInOut.Text				= pButtonsDef.GetButtonLoc( EButtonName.EBN_LogIn); 
	m_ButtonLogInOut.m_eButton_Action	= EBN_LogIn;
	m_ButtonLogInOut.Align				= TA_Left;
	m_ButtonLogInOut.m_fFontSpacing		= 0;
	m_ButtonLogInOut.m_buttonFont		= buttonFont;
	m_ButtonLogInOut.ResizeToText();

	fXOffset += fWidth;

    // define JOIN button
	m_ButtonJoin = R6WindowButtonMultiMenu(CreateWindow( class'R6WindowButtonMultiMenu', fXOffset, fYOffset, 400, 25, self));
    m_ButtonJoin.ToolTipString			= pButtonsDef.GetButtonLoc( EButtonName.EBN_Join, True);
    m_ButtonJoin.Text					= pButtonsDef.GetButtonLoc( EButtonName.EBN_Join); 
	m_ButtonJoin.m_eButton_Action		= EBN_Join;
	m_ButtonJoin.Align					= TA_Left;
	m_ButtonJoin.m_fFontSpacing			= 0;
	m_ButtonJoin.m_buttonFont			= buttonFont;
	m_ButtonJoin.ResizeToText();
	m_ButtonJoin.m_pPreviousButtonPos	= m_ButtonLogInOut;
	m_ButtonJoin.m_pRefButtonPos		= m_ButtonLogInOut;

	fXOffset += fWidth;

    // define JOIN IP button
   	m_ButtonJoinIP = R6WindowButtonMultiMenu(CreateWindow( class'R6WindowButtonMultiMenu', fXOffset, fYOffset, 400, 25, self));
    m_ButtonJoinIP.ToolTipString		= pButtonsDef.GetButtonLoc( EButtonName.EBN_JoinIP, True);
    m_ButtonJoinIP.Text					= pButtonsDef.GetButtonLoc( EButtonName.EBN_JoinIP);
	m_ButtonJoinIP.m_eButton_Action		= EBN_JoinIP;
	m_ButtonJoinIP.Align				= TA_Left;
	m_ButtonJoinIP.m_fFontSpacing		= 0;
	m_ButtonJoinIP.m_buttonFont			= buttonFont;
	m_ButtonJoinIP.ResizeToText();
	m_ButtonJoinIP.m_pPreviousButtonPos = m_ButtonJoin;
	m_ButtonJoinIP.m_pRefButtonPos		= m_ButtonLogInOut;
	
	fXOffset += fWidth;
	
    // define Refresh button
   	m_ButtonRefresh = R6WindowButtonMultiMenu(CreateWindow( class'R6WindowButtonMultiMenu', fXOffset, fYOffset, 400, 25, self));
    m_ButtonRefresh.ToolTipString		= pButtonsDef.GetButtonLoc( EButtonName.EBN_Refresh, True);
    m_ButtonRefresh.Text				= pButtonsDef.GetButtonLoc( EButtonName.EBN_Refresh);
	m_ButtonRefresh.m_eButton_Action	= EBN_Refresh;
	m_ButtonRefresh.Align				= TA_Left;
	m_ButtonRefresh.m_fFontSpacing		= 0;
	m_ButtonRefresh.m_buttonFont		= buttonFont;
	m_ButtonRefresh.ResizeToText();
	m_ButtonRefresh.m_pPreviousButtonPos = m_ButtonJoinIP;
	m_ButtonRefresh.m_pRefButtonPos		 = m_ButtonLogInOut;
	
	fXOffset += fWidth;
	
    // define Create button
   	m_ButtonCreate = R6WindowButtonMultiMenu(CreateWindow( class'R6WindowButtonMultiMenu', fXOffset, fYOffset, fWidth, 25, self));
    m_ButtonCreate.ToolTipString		= pButtonsDef.GetButtonLoc( EButtonName.EBN_Create, True);
    m_ButtonCreate.Text					= pButtonsDef.GetButtonLoc( EButtonName.EBN_Create);
	m_ButtonCreate.m_eButton_Action		= EBN_Create;
	m_ButtonCreate.Align				= TA_Right;//TA_Left;
	m_ButtonCreate.m_fFontSpacing		= 0;
	m_ButtonCreate.m_buttonFont			= buttonFont;
	m_ButtonCreate.ResizeToText();
//	m_ButtonCreate.m_pPreviousButtonPos = m_ButtonRefresh;
	m_ButtonCreate.m_pRefButtonPos		= m_ButtonLogInOut;
}


function InitInfoBar()
{
    local FLOAT fWidth, fPreviousPos;

    fWidth = 15;
    fPreviousPos = 0; // at the beginning of the window

	m_pButServerList = R6MenuMPButServerList( CreateWindow(class'R6MenuMPButServerList', K_XSTARTPOS + 1, 114, K_WINDOWWIDTH - 2, 12, self));
}


function InitFirstTabWindow()
{
    local FLOAT fWidth;
    fWidth = 1;

    // create the border window under the tab
    m_pFirstWindowBorder = R6WindowSimpleFramedWindowExt(CreateWindow(class'R6WindowSimpleFramedWindowExt', K_XSTARTPOS, K_YPOS_FIRST_TABWINDOW, K_WINDOWWIDTH, K_FFIRST_WINDOWHEIGHT, self));
    m_pFirstWindowBorder.bAlwaysBehind = true;
//    m_pFirstWindowBorder.SetBorderParam( 0, 1, 0, fWidth, Root.Colors.Yellow);     // Top border
	m_pFirstWindowBorder.ActiveBorder( 0, false);									  // Top Border
    m_pFirstWindowBorder.SetBorderParam( 1, 7, 0, fWidth, Root.Colors.White);         // Bottom border
    m_pFirstWindowBorder.SetBorderParam( 2, 1, 0, fWidth, Root.Colors.White);		  // Left border
    m_pFirstWindowBorder.SetBorderParam( 3, 1, 0, fWidth, Root.Colors.White);		  // Rigth border
    
    m_pFirstWindowBorder.m_eCornerType = Bottom_Corners;
    m_pFirstWindowBorder.SetCornerColor( 2, Root.Colors.White);

	m_pFirstWindowBorder.ActiveBackGround( true, Root.Colors.Black);                  // draw background
}


function InitServerList()
{
	local Font buttonFont;		
	local INT iFiles, i, j;

    // Create window for serever list
    if (m_ServerListBox!=none)
        return;

 	m_ServerListBox = R6WindowServerListBox(CreateWindow( class'R6WindowServerListBox', K_XSTARTPOS_NOBORDER, K_YPOS_FIRST_TABWINDOW, K_WINDOWWIDTH_NOBORDER, K_FFIRST_WINDOWHEIGHT, self));
    m_ServerListBox.Register(  m_pFirstTabManager );
	m_ServerListBox.SetCornerType(No_Borders);


    // TODO might need to add something for specific fonts, textures, etc.

    m_ServerListBox.m_Font = Root.Fonts[F_ListItemSmall]; 	
    m_ServerListBox.m_iPingTimeOut = m_LanServers.NativeGetPingTimeOut();
}
function InitServerInfoPlayer()
{
	local Font buttonFont;	
	local INT iFiles, i, j;

    // Create window for serever list
 	m_ServerInfoPlayerBox = R6WindowServerInfoPlayerBox(CreateWindow( class'R6WindowServerInfoPlayerBox', K_XSTARTPOS, 336, 245, 79, self));
	m_ServerInfoPlayerBox.ToolTipString = Localize("Tip","InfoBar_ServerInfo_Player","R6Menu");
	m_ServerInfoPlayerBox.SetCornerType(No_Borders);

    // TODO might need to add something for specific fonts, textures, etc.

    m_ServerInfoPlayerBox.m_Font = Root.Fonts[F_ListItemSmall]; 
    m_ServerInfoPlayerBox.HideWindow();

}
function InitServerInfoMap()
{
	local Font buttonFont;		
	local INT iFiles, i, j;

    // Create window for serever list
 	m_ServerInfoMapBox = R6WindowServerInfoMapBox(CreateWindow( class'R6WindowServerInfoMapBox', 255, 336, 174, 79, self));
	m_ServerInfoMapBox.ToolTipString = Localize("Tip","InfoBar_ServerInfo_Map","R6Menu");
	m_ServerInfoMapBox.SetCornerType(No_Corners);


    // TODO might need to add something for specific fonts, textures, etc.

    m_ServerInfoMapBox.m_Font = Root.Fonts[F_ListItemSmall]; 
    m_ServerInfoMapBox.HideWindow();

}
function InitServerInfoOptions()
{
	local Font buttonFont;	
	local INT iFiles, i, j;

    // Create window for serever list
 	m_ServerInfoOptionsBox = R6WindowServerInfoOptionsBox(CreateWindow( class'R6WindowServerInfoOptionsBox', 429, 336, 200, 79, self));
	m_ServerInfoOptionsBox.ToolTipString = Localize("Tip","InfoBar_ServerInfo_Opt","R6Menu");
	m_ServerInfoOptionsBox.SetCornerType(No_Corners);

    // TODO might need to add something for specific fonts, textures, etc.

    m_ServerInfoOptionsBox.m_Font = Root.Fonts[F_ListItemSmall];
	m_ServerInfoOptionsBox.HideWindow();

}

function InitSecondTabWindow()
{
    local FLOAT fWidth;
    fWidth = 1;

    // create the border window under the tab
    if (m_pSecondWindowBorder==none)
    {
        m_pSecondWindowBorder = R6WindowSimpleFramedWindowExt(CreateWindow(class'R6WindowSimpleFramedWindowExt', K_XSTARTPOS, K_YPOS_SECOND_TABWINDOW + 29, K_WINDOWWIDTH, K_FSECOND_WINDOWHEIGHT, self));
        m_pSecondWindowBorder.bAlwaysBehind = true;
        m_pSecondWindowBorder.ActiveBorder( 0, false);                         // Top border
        m_pSecondWindowBorder.SetBorderParam( 1, 7, 0, fWidth, Root.Colors.White);         // Bottom border
        m_pSecondWindowBorder.SetBorderParam( 2, 1, 1, fWidth, Root.Colors.White);		   // Left border
        m_pSecondWindowBorder.SetBorderParam( 3, 1, 1, fWidth, Root.Colors.White);         // Rigth border
    
        m_pSecondWindowBorder.m_eCornerType = Bottom_Corners;
        m_pSecondWindowBorder.SetCornerColor( 2, Root.Colors.White);

	    m_pSecondWindowBorder.ActiveBackGround( true, Root.Colors.Black);                  // draw background
    ////////////////////
        // create one window under the second tab window
		m_pSecondWindowGameMode = R6MenuMPMenuTab(CreateWindow(Root.MenuClassDefines.ClassMPMenuTabGameModeFilters, K_XSTARTPOS, K_YPOS_SECOND_TABWINDOW + 29, K_WINDOWWIDTH, K_FSECOND_WINDOWHEIGHT, self));
        m_pSecondWindowGameMode.InitGameModeTab();
    ///////////////////    
        m_pSecondWindowFilter = R6MenuMPMenuTab(CreateWindow(class'R6MenuMPMenuTab', K_XSTARTPOS, K_YPOS_SECOND_TABWINDOW + 29, K_WINDOWWIDTH, K_FSECOND_WINDOWHEIGHT, self));
        m_pSecondWindowFilter.InitFilterTab();
        m_pSecondWindowFilter.HideWindow();
    ///////////////////    
        m_pSecondWindowServerInfo = R6MenuMPMenuTab(CreateWindow(class'R6MenuMPMenuTab', K_XSTARTPOS, K_YPOS_SECOND_TABWINDOW + 29, K_WINDOWWIDTH, K_FSECOND_WINDOWHEIGHT, self));
	    m_pSecondWindowServerInfo.bAlwaysBehind= true;
        m_pSecondWindowServerInfo.InitServerTab();
        m_pSecondWindowServerInfo.HideWindow();
    ///////////////////    

        // choose the one to display
        m_pSecondWindow = m_pSecondWindowGameMode;
    }
}

///////////////////////////////////////////////////////////////
// Initialize values for right-click menu, used in the server list
///////////////////////////////////////////////////////////////

function InitRightClickMenu()
{
    m_pRightClickMenu = R6WindowRightClickMenu(CreateControl( class'R6WindowRightClickMenu', 100, 150, 140, 14));
    m_pRightClickMenu.Register(  m_pFirstTabManager );
    m_pRightClickMenu.EditBoxWidth = 140;
    m_pRightClickMenu.SetFont( F_VerySmallTitle);
    m_pRightClickMenu.SetValue( "" );
    m_pRightClickMenu.AddItem( Localize("MultiPlayer","RightClick_AddFav","R6Menu") );
    m_pRightClickMenu.AddItem( Localize("MultiPlayer","RightClick_SubFav","R6Menu") );
    m_pRightClickMenu.AddItem( Localize("MultiPlayer","RightClick_Refr"  ,"R6Menu") );

    m_pRightClickMenu.HideWindow();
}

///////////////////////////////////////////////////////////////
// Initialize values for all pop up menus
///////////////////////////////////////////////////////////////

function SendMessage( eR6MenuWidgetMessage eMessage )
{
    switch ( eMessage )
    {

        ////////////////////////////////////////////////////
        // Messages received from R6WindowUbiLogIn.uc class

        // user has logged in to ubi.com, proceed to next step 
        // according to m_LoginSuccessAction flag
        case MWM_UBI_LOGIN_SUCCESS:
            switch ( m_LoginSuccessAction )
            {
                // User is joining a server using the join Ip button,
                // continue to the password check phase of this procedure
                case eLSAct_JoinIP:
                    m_szServerIP = m_pJoinIPWindow.m_szIP;
                    QueryReceivedStartPreJoin();                    
                    break;
                // User is joining a server using the join button ot by double clicking
                // on a server, continue to the password check phase of this procedure
                case eLSAct_Join:
                    QueryReceivedStartPreJoin();                    
                    break;
                // User has selected the internet tab, allow tab to be displayed
                case eLSAct_InternetTab:
                    Refresh( FALSE );
                    break;
                // Switch to Internet TAB
                case eLSAct_SwitchToInternetTab:
                    m_pFirstTabManager.m_pMainTabControl.GotoTab( m_pFirstTabManager.m_pMainTabControl.GetTab(Localize("MultiPlayer","Tab_InternetServer","R6Menu")));
                    break;
                // Nothing to do after login, simply close the log in window and
                // refresh the internet servers.
                case eLSAct_CloseWindow:
                    if ( m_ConnectionTab == TAB_Internet_Server )
                        Refresh( FALSE );
            }
            m_LoginSuccessAction = eLSAct_None;
            break;
        // user was not able to log in to ubi.com, make sure the LAN
        // tab is displayed.
        case MWM_UBI_LOGIN_FAIL:
            m_pFirstTabManager.m_pMainTabControl.GotoTab( m_pFirstTabManager.m_pMainTabControl.GetTab(Localize("MultiPlayer","Tab_LanServer","R6Menu")));
            m_LoginSuccessAction = eLSAct_None;
            break;
        // Procedure to log in was skipped (because user is already logged in), proceed to next step 
        // according to m_LoginSuccessAction flag
        case MWM_UBI_LOGIN_SKIPPED:
            switch ( m_LoginSuccessAction )
            {
                // User is joining a server using the join Ip button,
                // continue to the password check phase of this procedure
                case eLSAct_JoinIP:
                    m_szServerIP = m_pJoinIPWindow.m_szIP;
                    QueryReceivedStartPreJoin();                    
                    break;
                // User is joining a server using the join button ot by double clicking
                // on a server, continue to the password check phase of this procedure
                case eLSAct_Join:
                    QueryReceivedStartPreJoin();                    
                    break;
           }
            m_LoginSuccessAction = eLSAct_None;
            break;

        /////////////////////////////////////////////////
        // Messages received from R6WindowUbiCDKeyCheck.uc class

        case MWM_CDKEYVAL_SKIPPED:
        // CD KEY has been checked successfully, allow user to join the server
        case MWM_CDKEYVAL_SUCCESS:
        // CD KEY check has failed, do not join a server
        case MWM_CDKEYVAL_FAIL:
            log("R6MenuMultiplayerWidget SendMessage() not supposed to arrive here (should be in R6MenuCDKeyManager)!!!!");
            break;
        // The user has entered an IP and the server has responded,
        // continue with the next step in the procedure

        /////////////////////////////////////////////////
        // Messages received from R6WindowJoinIP.uc class

        case MWM_UBI_JOINIP_SUCCESS:
            m_bJoinIPInProgress = FALSE;
            // Save the IP
            m_szPopUpIP = m_pJoinIPWindow.m_szIP;
            SaveConfig();
            // If server is registrered on ubi.com, force client to log in
            if ( m_pJoinIPWindow.m_bRoomValid )
            {
                m_LoginSuccessAction = eLSAct_JoinIP;
                m_pLoginWindow.StartLogInProcedure(Self);
            }
            // continue to the password check phase of this procedure
            else
            {
                m_szServerIP = m_pJoinIPWindow.m_szIP;
                QueryReceivedStartPreJoin();                    
            }
            break;
        // The user has entered an IP and the server did not responded,
        // or the user cancelled, return to the menu
        case MWM_UBI_JOINIP_FAIL:
            m_bJoinIPInProgress = FALSE;
            break;

        //////////////////////////////////////////////////////////////
        // Messages received from R6WindowQueryServerInfo.uc class

        case MWM_QUERYSERVER_SUCCESS:
            if ( m_pQueryServerInfo.m_bRoomValid )
            {
                m_LoginSuccessAction = eLSAct_Join;
                m_pLoginWindow.StartLogInProcedure(Self);
            }
            else
            {
                QueryReceivedStartPreJoin();                    
            }

            m_bQueryServerInfoInProgress = FALSE;
            break;
        case MWM_QUERYSERVER_FAIL:
            m_bQueryServerInfoInProgress = FALSE;
            break;
    }
}
    


//*********************************
//    END OF INIT CREATE FUNCTION
//*********************************


function Notify(UWindowDialogControl C, byte E)
{ 

    if( E == DE_Click )
    {
        switch(C)
        {
        case m_ButtonMainMenu:
            Root.ChangeCurrentWidget(MainMenuWidgetID);
            break;
        case m_ButtonOptions:
            Root.ChangeCurrentWidget(OptionsWidgetID);
            break; 
        case m_PageCount.m_pNextButton:
            m_PageCount.NextPage();
            m_GameService.m_bServerListChanged = true;
            m_iTimeLastUpdate  = 0;
            break;
        case m_PageCount.m_pPreviousButton:
            m_PageCount.PreviousPage();
            m_GameService.m_bServerListChanged = true;
            m_iTimeLastUpdate  = 0;
            break;
        }
    }    
}

function BackToMainMenu()
{
    local ClientBeaconReceiver _BeaconReceiver;

	ResetMultiplayerMenu();
}

function ResetMultiplayerMenu()
{
    local ClientBeaconReceiver _BeaconReceiver;

	if (m_LanServers != None)
	{
		_BeaconReceiver = m_LanServers.m_ClientBeacon;
		m_LanServers.m_ClientBeacon  = none;
	}
	if (m_GameService != None)
	{
	    m_GameService.m_ClientBeacon = none;
	}

	if (_BeaconReceiver != None)
	{
	    _BeaconReceiver.Destroy();
	}

    m_LanServers = none;
    R6Console(Root.console).m_LanServers = none;
}

defaultproperties
{
     m_iLastTabSel=1
     m_bLanRefreshFPass=True
     m_bIntRefreshFPass=True
     m_szPopUpIP="211.177.19.52"
     m_bFilterDeathMatch=True
     m_bFilterTeamDeathMatch=True
     m_bFilterDisarmBomb=True
     m_bFilterHostageRescueAdv=True
     m_bFilterEscortPilot=True
     m_bFilterMission=True
     m_bFilterTerroristHunt=True
     m_bFilterHostageRescueCoop=True
}
