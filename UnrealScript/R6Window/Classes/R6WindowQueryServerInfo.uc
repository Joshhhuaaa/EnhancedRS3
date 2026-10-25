//=============================================================================
//  R6WindowQueryServerInfo.uc : Used to get some basic information
//  from a server before allowing the user to join the server.
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/10/15 * Created by John Bennett
//=============================================================================
class R6WindowQueryServerInfo extends R6WindowMPManager;


const K_MAX_TIME_BEACON  = 5.0;                     // Maximum 5 second delay before timing out.  

var R6WindowPopUpBox        m_pPleaseWait;              // Ask user to wait
var R6GSServers             m_GameService;              // Manages servers from game service
var UWindowWindow           m_pSendMessageDest;         // Window to which the send message function will communicate
var FLOAT                   m_fBeaconTime;              // Time at which beacon was sent to query server
var BOOL                    m_bWaitingForBeacon;        // Waiting for the beacon response from the server
var BOOL                    m_bRoomValid;               // ubi.com room valid

//=======================================================================
// StartQueryServerInfoProcedure - Called from  the menus when the 
// query procedure is started
//=======================================================================
function StartQueryServerInfoProcedure( UWindowWindow _pCurrentWidget, string _szServerIP, INT _iBeaconPort )
{
    // If necessary, remove the port number from the IP address string (10.10.10.10:1111 -> 10.10.10.10)
    if ( InStr(_szServerIP, ":") != -1 )
        _szServerIP = left( _szServerIP, InStr(_szServerIP, ":") );

    m_pSendMessageDest = _pCurrentWidget;

    // Send message to server asking for pre-join information
    m_GameService.SetLastServerQueried(_szServerIP);
    m_GameService.m_ClientBeacon.PreJoinQuery( _szServerIP, _iBeaconPort );

    ShowWindow();
    m_bWaitingForBeacon = TRUE;
    m_pPleaseWait.ShowWindow();
    m_fBeaconTime =  m_GameService.NativeGetSeconds();

}


//=======================================================================
// Manager - Should be called regularly by the parent window whenever
// a request is in progress
//=======================================================================

function Manager( UWindowWindow _pCurrentWidget )
{
    local FLOAT elapsedTime;       // Elapsed time waiting for response from server

    if ( m_bWaitingForBeacon )
    {
        // Response has been received from the server
        if ( m_GameService.m_ClientBeacon.PreJoinInfo.bResponseRcvd )
        {

            m_bWaitingForBeacon = FALSE;

            // Verify that the server is the same version as the game
            if ( !IsSameGameVersion(m_GameService.m_ClientBeacon.PreJoinInfo.szPreJoinModName, m_GameService.m_ClientBeacon.PreJoinInfo.szGameVersion) )
            {
                m_pPleaseWait.HideWindow();
				DisplayErrorMsg( Localize("MultiPlayer","PopUp_Error_BadVersion","R6Menu"), EPopUpID_QueryServerError);
            }
            else if ( m_GameService.m_ClientBeacon.PreJoinInfo.iNumPlayers >= m_GameService.m_ClientBeacon.PreJoinInfo.iMaxPlayers)
            {
                m_pPleaseWait.HideWindow();
				DisplayErrorMsg( Localize("MultiPlayer","PopUp_Error_ServerFull","R6Menu"), EPopUpID_QueryServerError);
            }
            else
            {
                m_bRoomValid = ( m_GameService.m_ClientBeacon.PreJoinInfo.iLobbyID != 0 &&
                                 m_GameService.m_ClientBeacon.PreJoinInfo.iGroupID != 0    );
                _pCurrentWidget.SendMessage( MWM_QUERYSERVER_SUCCESS );
                // If the server is not locked, this is the last popup to be displayed before
                // joining the server.  If it is the lat menu, leave it active to avoid popping.
//                if ( m_GameService.m_ClientBeacon.PreJoinInfo.bLocked )
                HideWindow();
            }
        }
        else
        {
            // Check if beacon has timed out, if so put up error message
            elapsedTime = m_GameService.NativeGetSeconds() - m_fBeaconTime;
            if ( elapsedTime > K_MAX_TIME_BEACON )
            {
                m_bWaitingForBeacon = FALSE;
                
                if (R6Console(Root.console).m_bNonUbiMatchMaking)
                {
                    _pCurrentWidget.SendMessage( MWM_QUERYSERVER_TRYAGAIN );
                }
                else
                {
                m_pPleaseWait.HideWindow();
				DisplayErrorMsg( Localize("MultiPlayer","PopUp_Error_NoServer","R6Menu"), EPopUpID_QueryServerError);
            }
        }
    }
}
}

//=============================================================================
// IsSameGameVersion: compare with the server version, using the mod the
// server runs when a mod change is pending
//=============================================================================
function BOOL IsSameGameVersion( string _szPreJoinModName, string _szPreJoinInfoGameVer )
{
    local R6ModMgr pModMgr;
    local R6Mod    pTempCurrentMod;
    local R6Mod    pBkpMod;
    local string   szTemp;
    local INT      i;
    local BOOL     bSameGameVersion;

    pModMgr = class'Actor'.static.GetModMgr();

    if ((pModMgr.m_szPendingModName != "") && !(pModMgr.m_szPendingModName ~= pModMgr.m_pCurrentMod.m_szKeyWord))
    {
        pTempCurrentMod = pModMgr.GetModInstance(_szPreJoinModName);
        if (pTempCurrentMod != none)
        {
            pBkpMod = pModMgr.m_pCurrentMod;
            pModMgr.m_pCurrentMod = pTempCurrentMod;
            szTemp = Root.Console.ViewportOwner.Actor.GetGameVersion(false, !class'Actor'.static.GetModMgr().IsRavenShield());
            bSameGameVersion = (szTemp ~= _szPreJoinInfoGameVer);
            pModMgr.m_pCurrentMod = pBkpMod;
        }
    }
    else
    {
        szTemp = Root.Console.ViewportOwner.Actor.GetGameVersion(false, !class'Actor'.static.GetModMgr().IsRavenShield());
        bSameGameVersion = (szTemp ~= _szPreJoinInfoGameVer);
    }

    return bSameGameVersion;
}

//=======================================================================
// PopUpBoxCreate - Creates the pop up windows
//=======================================================================

function PopUpBoxCreate()
{
    local R6WindowEditBox pR6EditBoxTemp;
    local R6WindowTextLabel    pR6TextLabelTemp;

    Super.PopUpBoxCreate();

    // Create PopUp frame for please wait window

    m_pPleaseWait = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480));
    m_pPleaseWait.CreateStdPopUpWindow( Localize("MultiPlayer","PopUp_Wait","R6Menu"), 30, 205, 170, 230, 50, 2);
    m_pPleaseWait.CreateClientWindow( class'R6WindowTextLabel');
    m_pPleaseWait.m_ePopUpID = EPopUpID_QueryServerWait;
    m_pPleaseWait.SetPopUpResizable(true);
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
            // Query not successfull or cancelled by user, Return to multi-player menu
            case EPopUpID_QueryServerWait:
            case EPopUpID_QueryServerError:
                // quit game for m_bNonUbiMatchMaking
                if (R6Console(Root.console).m_bNonUbiMatchMaking)
                {
                    Root.ChangeCurrentWidget(MenuQuitID);
                }
                else
                {
                m_pPleaseWait.HideWindow();
                m_pError.HideWindow();
                m_pSendMessageDest.SendMessage( MWM_QUERYSERVER_FAIL );
                m_GameService.SetLastServerQueried("0");
                HideWindow();
                }
                break;
            default:
                break;
       }
    }
}

defaultproperties
{
}
