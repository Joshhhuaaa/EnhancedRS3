//=============================================================================
//  R6WindowJoinIP.uc : This class handles the logic and pop up windows
//                      associated with the user joining a server by using
//                      the Join IP button
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/10/02 * Created by John Bennett
//=============================================================================
class R6WindowJoinIP extends UWindowWindow;


// ASE DEVELOPMENT - Eric Begin - May 11th, 2003
//
// Added a new state 'EJOINIP_WAITING_FOR_UBICOMLOGIN' to make sure the ubi.com process is finished before logging in
// on the game server
//
enum eJoinIPState
{
    EJOINIP_ENTER_IP,               // User needs to enter an IP
    EJOINIP_WAITING_FOR_BEACON,     // Waiting for response from the server
    EJOINIP_BEACON_FAIL,            // no response from server
	EJOINIP_WAITING_FOR_UBICOMLOGIN // Waiting to be logged in on Ubi.Com
};

const K_MAX_TIME_BEACON  = 5.0;                     // Maximum 5 second delay before timing out.  

var R6WindowPopUpBox    m_pEnterIP;                 // The enter IP window
var R6WindowPopUpBox    m_pPleaseWait;              // Ask user to wait while we get authorization ID (pop up window)
var R6WindowPopUpBox    m_pError;                   // Error pop up window
var R6GSServers         m_GameService;              // Manages servers from game service
var UWindowWindow       m_pSendMessageDest;         // Window to which the send message function will communicate
var string              m_szIP;                     // IP address entered by user
var eJoinIPState        eState;                     // Enumeration used in state machine for JOIN IO procedure
var FLOAT               m_fBeaconTime;              // Time at which beacon was sent to query server
var BOOL                m_bRoomValid;               // ubi.com room valid

// ASE DEVELOPMENT - Eric Begin - May 11th, 2003
//
// This variable is set locally to prevent hidding and showing windows for nothing.
var BOOL				m_bStartByCmdLine;

//=======================================================================
// StartJoinIPProcedure - Called from the menus when the user should
// enter an IP of the server he wishes to join
//=======================================================================
function StartJoinIPProcedure( UWindowWindow _pCurrentWidget, string _szLastIP )
{
    // 
    m_pSendMessageDest = _pCurrentWidget;
    ShowWindow();
    eState = EJOINIP_ENTER_IP;
    m_pEnterIP.ShowWindow();
    R6WindowEditBox(m_pEnterIP.m_ClientArea).SetValue( _szLastIP );
	m_bStartByCmdLine = false;
}

// ASE DEVELOPMENT - Eric Begin - May 11th, 2003
//
// Add a new function to deal with the fact that when the player connect to a server via the
// command line, chances are that he won't be connect on ubi.com.
function StartCmdLineJoinIPProcedure( UWindowWindow _pCurrentWidget, string _szLastIP )
{
	log("R6WindowJoinIP::StartCmdLineJoinIPProcedure");
    m_pSendMessageDest = _pCurrentWidget;
    ShowWindow();
    eState = EJOINIP_WAITING_FOR_UBICOMLOGIN;
    m_pPleaseWait.ShowWindow();
	log("R6WindowJoinIP::SetValue");
    R6WindowEditBox(m_pEnterIP.m_ClientArea).SetValue( _szLastIP );
	m_bStartByCmdLine = true;
}

//=======================================================================
// Manager - Should be called regularly by the parent window whenever
// a request is in progress
//=======================================================================

function Manager( UWindowWindow _pCurrentWidget )
{
    local FLOAT elapsedTime;       // Elapsed time waiting for response from server

    switch ( eState )
    {
		// ASE DEVELOPMENT - Eric Begin - May 11th, 2003
		//
		// We have to add a new state for waiting the ubi.com login process to finish
		//
		case EJOINIP_WAITING_FOR_UBICOMLOGIN:
			if ( m_GameService.m_bLoggedInUbiDotCom )
			{
				PopUpBoxDone(MR_OK, EPopUpID_EnterIP);
			}
			break;

        case EJOINIP_WAITING_FOR_BEACON:
            // Response has been received from the server
            if ( m_GameService.m_ClientBeacon.PreJoinInfo.bResponseRcvd )
            {
                // Verify that the server is the same version as the game
                if ( Root.Console.ViewportOwner.Actor.GetGameVersion(false, !class'Actor'.static.GetModMgr().IsRavenShield()) != m_GameService.m_ClientBeacon.PreJoinInfo.szGameVersion )
                {
                    eState = EJOINIP_BEACON_FAIL;
                    m_pPleaseWait.HideWindow();
                    m_pError.ShowWindow();
	                R6WindowTextLabel(m_pError.m_ClientArea).SetNewText(Localize("MultiPlayer","PopUp_Error_BadVersion","R6Menu"), true);
                }
                else if (R6Console(Root.console).m_bNonUbiMatchMaking)
                {
                    _pCurrentWidget.SendMessage( MWM_UBI_JOINIP_SUCCESS );
					if (!m_bStartByCmdLine)
						HideWindow();
                }
                // Only allow user to join internet servers using the Join IP button
                else if ( !m_GameService.m_ClientBeacon.PreJoinInfo.bInternetServer )
                {
                    eState = EJOINIP_BEACON_FAIL;
                    m_pPleaseWait.HideWindow();
                    m_pError.ShowWindow();
	                R6WindowTextLabel(m_pError.m_ClientArea).SetNewText(Localize("MultiPlayer","PopUp_Error_LanServer","R6Menu"), true);
                }
                else
                {
                    m_bRoomValid = ( m_GameService.m_ClientBeacon.PreJoinInfo.iLobbyID != 0 &&
                                     m_GameService.m_ClientBeacon.PreJoinInfo.iGroupID != 0    );
                    _pCurrentWidget.SendMessage( MWM_UBI_JOINIP_SUCCESS );
                    HideWindow();
                }
            }
            else
            {
                // Check if beacon has timed out, if so put up error message
                elapsedTime = m_GameService.NativeGetSeconds() - m_fBeaconTime;
                if ( elapsedTime > K_MAX_TIME_BEACON )
                {
                    eState = EJOINIP_BEACON_FAIL;
                    m_pPleaseWait.HideWindow();
                    m_pError.ShowWindow();
	                R6WindowTextLabel(m_pError.m_ClientArea).SetNewText(Localize("MultiPlayer","PopUp_Error_NoServer","R6Menu"), true);
                }
            }

            break;
//        case EJOINIP_BEACON_FAIL:
//            break;
    }
}

//=======================================================================
// PopUpBoxCreate - Creates the pop up windows
//=======================================================================

function PopUpBoxCreate()
{
    local R6WindowEditBox pR6EditBoxTemp;
    local R6WindowTextLabel    pR6TextLabelTemp;

    // Create PopUp frame for the Enter IP window

    m_pEnterIP = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480));
    m_pEnterIP.CreateStdPopUpWindow( Localize("MultiPlayer","PopUp_Join","R6Menu"), 30, 205, 170, 230, 50);
    m_pEnterIP.CreateClientWindow( class'R6WindowEditBox');
    m_pEnterIP.m_ePopUpID = EPopUpID_EnterIP;
    pR6EditBoxTemp = R6WindowEditBox(m_pEnterIP.m_ClientArea);
    pR6EditBoxTemp.TextColor = Root.Colors.BlueLight;
    pR6EditBoxTemp.SetFont(F_PopUpTitle);
	pR6EditBoxTemp.MaxLength = 21;
    m_pEnterIP.HideWindow();

    // Create PopUp frame for error window

    m_pError = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480));
    m_pError.CreateStdPopUpWindow( Localize("MultiPlayer","PopUp_Error_Title","R6Menu"), 30, 205, 170, 230, 50, MessageBoxButtons.MB_OK);
    m_pError.CreateClientWindow( class'R6WindowTextLabel');
    m_pError.m_ePopUpID = EPopUpID_JoinIPError;
    pR6TextLabelTemp = R6WindowTextLabel(m_pError.m_ClientArea);
	pR6TextLabelTemp.Text = Localize("MultiPlayer","PopUp_Error_NoServer","R6Menu");
	pR6TextLabelTemp.Align = TA_Center;
	pR6TextLabelTemp.m_Font = Root.Fonts[F_VerySmallTitle];
	pR6TextLabelTemp.TextColor = Root.Colors.BlueLight;
	pR6TextLabelTemp.m_BGTexture = None;
	pR6TextLabelTemp.m_HBorderTexture = None;
	pR6TextLabelTemp.m_VBorderTexture = None;
    pR6TextLabelTemp.m_TextDrawstyle  = ERenderStyle.STY_Alpha;
    m_pError.HideWindow();

    // Create PopUp frame for please wait window

    m_pPleaseWait = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480));
    m_pPleaseWait.CreateStdPopUpWindow( Localize("MultiPlayer","PopUp_Wait","R6Menu"), 30, 205, 170, 230, 50, MessageBoxButtons.MB_OK);
    m_pPleaseWait.CreateClientWindow( class'R6WindowTextLabel');
    m_pPleaseWait.m_ePopUpID = EPopUpID_JoinIPWait;
    pR6TextLabelTemp = R6WindowTextLabel(m_pPleaseWait.m_ClientArea);
	pR6TextLabelTemp.Text = Localize("MultiPlayer","PopUp_Cancel","R6Menu");
	pR6TextLabelTemp.Align = TA_Center;
	pR6TextLabelTemp.m_Font = Root.Fonts[F_VerySmallTitle];
	pR6TextLabelTemp.TextColor = Root.Colors.BlueLight;
	pR6TextLabelTemp.m_BGTexture = None;
	pR6TextLabelTemp.m_HBorderTexture = None;
	pR6TextLabelTemp.m_VBorderTexture = None;
    pR6TextLabelTemp.m_TextDrawstyle  = ERenderStyle.STY_Alpha;
    m_pPleaseWait.HideWindow();
}

//==============================================================================
// PopUpBoxDone -  receive the result of the popup box  
//==============================================================================
function PopUpBoxDone( MessageBoxResult Result, ePopUpID _ePopUpID)
{
    if (Result == MR_OK)
    {
        switch ( _ePopUpID )
        {
            case EPopUpID_EnterIP:
				m_szIP = R6WindowEditBox(m_pEnterIP.m_ClientArea).GetValue();
				if (m_GameService.m_ClientBeacon.PreJoinQuery( m_szIP, 0 )==false)
				{ // handle invalid ip string format here
					PopUpBoxDone(MR_OK,EPopUpID_JoinIPError);
					log("Invalid IP string entered");
					break;
				}
				if (!m_bStartByCmdLine)
					m_pPleaseWait.ShowWindow();
				m_fBeaconTime =  m_GameService.NativeGetSeconds();
				eState = EJOINIP_WAITING_FOR_BEACON;

                break;
            case EPopUpID_JoinIPWait:
                m_pPleaseWait.HideWindow();
                m_pError.HideWindow();
                m_pSendMessageDest.SendMessage( MWM_UBI_JOINIP_FAIL );
                HideWindow();
                break;
            case EPopUpID_JoinIPError:
                m_pPleaseWait.HideWindow();
                m_pError.HideWindow();
                m_pEnterIP.ShowWindow();
                eState = EJOINIP_ENTER_IP;
                break;
            default:
                break;
       }
    }
    else if (Result == MR_Cancel)
    {
        switch ( _ePopUpID )
        {
            case EPopUpID_EnterIP:
                m_pEnterIP.HideWindow();
                m_pSendMessageDest.SendMessage( MWM_UBI_JOINIP_FAIL );
                HideWindow();
                break;
            default:
                break;
        }
    }
}

defaultproperties
{
}
