//=============================================================================
//  R6MenuNonUbiWidget.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//	Main Menu
//
//  Revision history:
//    2003/07/03 * Created by Yannick Joly
//=============================================================================
class R6MenuNonUbiWidget extends R6MenuWidget;

var R6GSServers                       m_GameService;

var R6WindowUbiLogIn                  m_pLoginWindow;
var R6WindowJoinIp                    m_pJoinIPWindow;           // Windows and login for Join IP steps
var R6WindowQueryServerInfo           m_pQueryServerInfo;        // Windows and login for logic to query a server for information

var string                            m_szGamePwd;

var BOOL                              m_bLoginInProgress;        // procedure to login to ubi.com in progress
var BOOL                              m_bJoinIPInProgress;
var BOOL                              m_bQueryServerInfoInProgress;

var BOOL                              m_bNonUbiMatchMakingClient;

function Created()
{
    m_GameService = R6Console(Root.console).m_GameService;

	m_pLoginWindow = R6WindowUbiLogIn(CreateWindow(Root.MenuClassDefines.ClassUbiLogIn, 0, 0, 640, 480, self, TRUE));
    m_pLoginWindow.m_GameService = R6Console(Root.console).m_GameService;
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

    m_bNonUbiMatchMakingClient = R6Console(Root.console).m_bNonUbiMatchMaking;
}

function ShowWindow()
{
    R6MenuRootWindow(Root).m_pMenuCDKeyManager.SetWindowUser(Root.eGameWidgetID.NonUbiWidgetID, self);
    if(m_bNonUbiMatchMakingClient || R6Console(Root.Console).m_bAutoLoginFirstPass)
    {
        R6Console(Root.Console).m_bAutoLoginFirstPass = false;
        R6MenuRootWindow(Root).InitBeaconService();
        R6Console(Root.Console).m_GameService.StartAutoLogin();
        if(!R6Console(Root.Console).m_GameService.m_bAutoLoginInProgress)
        {
            R6Console(Root.Console).szStoreGamePassWd = R6Console(Root.Console).m_GameService.m_szSavedPwd;
            m_pLoginWindow.StartLogInProcedure(self);
            m_bLoginInProgress = true;            
        }
        else
        {
            m_pLoginWindow.m_pSendMessageDest = self;
            m_bLoginInProgress = true;
        }
    }
    super(UWindowWindow).ShowWindow();
}

function Paint(Canvas C, float X, float Y)
{
	local string szTemp;
	local FLOAT W, H;

	// DrawBackGround
	C.Style = ERenderStyle.STY_Alpha;

	C.SetDrawColor( Root.Colors.Black.R, Root.Colors.Black.G, Root.Colors.Black.B);        

	DrawStretchedTextureSegment( C, 0, 0, WinWidth, WinHeight, 0, 0, 10, 10, Texture'UWindow.WhiteTexture' );
	//
}

function Tick(float Delta)
{
    if ( m_bLoginInProgress )
        m_pLoginWindow.Manager( self );


    if ( m_bJoinIPInProgress )
        m_pJoinIPWindow.Manager( self );

    if ( m_bQueryServerInfoInProgress )
        m_pQueryServerInfo.Manager( self );
}

function SendMessage(UWindowWindow.eR6MenuWidgetMessage eMessage)
{
    local string _szIPAddress;

    switch(eMessage)
    {
        case MWM_QUERYSERVER_TRYAGAIN:
            m_bQueryServerInfoInProgress = false;
        case MWM_UBI_LOGIN_SUCCESS:
        case MWM_UBI_LOGIN_SKIPPED:
            m_bLoginInProgress = false;
            class'Actor'.static.NativeNonUbiMatchMakingAddress(_szIPAddress);
            if(m_bNonUbiMatchMakingClient)
            {
                m_pQueryServerInfo.StartQueryServerInfoProcedure(self, _szIPAddress, 0);
                m_bQueryServerInfoInProgress = true;
            }
            break;
        case MWM_UBI_LOGIN_FAIL:
            m_bLoginInProgress = false;
            Root.ChangeCurrentWidget(MenuQuitID);
            break;
        case MWM_UBI_JOINIP_SUCCESS:
            m_bJoinIPInProgress = false;
            R6MenuRootWindow(Root).m_pMenuCDKeyManager.JoinServer(m_pJoinIPWindow.m_szIP);
            break;
        case MWM_QUERYSERVER_SUCCESS:
            QueryReceivedStartPreJoin();
            log("m_bRoomValid =" @ string(m_pQueryServerInfo.m_bRoomValid));
            m_bQueryServerInfoInProgress = false;
            break;
        case MWM_QUERYSERVER_FAIL:
            m_bQueryServerInfoInProgress = false;
            break;
    }
}

function QueryReceivedStartPreJoin()
{
    local R6WindowUbiCDKeyCheck.eJoinRoomChoice eJoinRoom;
    local BOOL                                  bRoomValid;

    bRoomValid = ( m_GameService.m_ClientBeacon.PreJoinInfo.iLobbyID != 0 &&
                   m_GameService.m_ClientBeacon.PreJoinInfo.iGroupID != 0    );

    if ( bRoomValid )
        eJoinRoom = EJRC_BY_LOBBY_AND_ROOM_ID;
    else
        eJoinRoom = EJRC_NO;

    R6MenuRootWindow(Root).m_pMenuCDKeyManager.StartCDKeyProcess(eJoinRoom, m_GameService.m_ClientBeacon.PreJoinInfo);


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

    if (Result == MR_OK)
    {
        Root.ChangeCurrentWidget(MenuQuitID);
    }
}

defaultproperties
{
}
