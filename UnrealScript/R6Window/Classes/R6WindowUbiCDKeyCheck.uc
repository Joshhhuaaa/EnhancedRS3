//=============================================================================
//  R6WindowUbiLogIn.uc : This is used to pop up a window that will ask the user
//                  to input his ubi.com account info.
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/01/08 * Created by John Bennett
//=============================================================================
class R6WindowUbiCDKeyCheck extends R6WindowMPManager;


enum eJoinRoomChoice
{
    EJRC_NO,
//    EJRC_BY_MSCLIENT_ID,
    EJRC_BY_LOBBY_AND_ROOM_ID
};

var R6GSServers                       m_GameService;             // Manages servers from game service
var UWindowWindow                     m_pSendMessageDest;
var R6WindowPopUpBox                  m_pPleaseWait;             // Ask user to wait while we get authorization ID 
var R6WindowPopUpBox                  m_pR6EnterCDKey;           // Menu to enter a cd key.
var eJoinRoomChoice                   m_eJoinRoomChoice;         // Need to join the ubi.com room
var string                            m_szPassword;              // Game Password

var string                            m_szLocMod;                // mod name prefix for the error messages

//=======================================================================
// Created - Creates the pop up windows
//=======================================================================
function Created()
{
    local R6WindowEditBox pR6EditBoxTemp;
    local R6WindowTextLabel pR6TextLabelTemp;
    
    // Create PopUp frame for please wait window
    
    PopUpBoxCreate();
    
    m_pPleaseWait = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480));
    m_pPleaseWait.CreateStdPopUpWindow( Localize("MultiPlayer","PopUp_Wait","R6Menu"), 30, 205, 170, 230, 50, MessageBoxButtons.MB_Cancel);
    m_pPleaseWait.CreateClientWindow( class'R6WindowTextLabel');
    m_pPleaseWait.m_ePopUpID = EPopUpID_CDKeyPleaseWait;
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
    
    // Create PopUp frame for cdkey window
    
    m_pR6EnterCDKey = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480));
    m_pR6EnterCDKey.CreateStdPopUpWindow( Localize("MultiPlayer","PopUp_EnterCDKey","R6Menu"), 30, 205, 170, 230, 50);
    m_pR6EnterCDKey.CreateClientWindow( class'R6WindowEditBox');
    m_pR6EnterCDKey.m_ePopUpID = EPopUpID_EnterCDKey;
    pR6EditBoxTemp = R6WindowEditBox(m_pR6EnterCDKey.m_ClientArea);
    pR6EditBoxTemp.TextColor = Root.Colors.BlueLight;
    pR6EditBoxTemp.SetFont(F_PopUpTitle);
    //pR6EditBoxTemp.bPassword = TRUE;
    m_pR6EnterCDKey.HideWindow();
    
    // Create PopUp frame for password
    
    m_pPassword = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480));
    m_pPassword.CreateStdPopUpWindow( Localize("MultiPlayer","PopUp_Password","R6Menu"), 30, 205, 170, 230, 50);
    m_pPassword.CreateClientWindow( class'R6WindowEditBox');
    m_pPassword.m_ePopUpID = EPopUpID_Password;
    m_pPasswordEditBox = R6WindowEditBox(m_pPassword.m_ClientArea);
    m_pPasswordEditBox.TextColor = Root.Colors.BlueLight;
    m_pPasswordEditBox.SetFont(F_PopUpTitle);
    m_pPasswordEditBox.MaxLength = 16;
    m_pPasswordEditBox.bCaps = FALSE;
    m_pPasswordEditBox.bPassword = TRUE;
    m_pPassword.HideWindow();
    
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
        case EPopUpID_Password:
            m_szPassword = R6WindowEditBox(m_pPassword.m_ClientArea).GetValue();
            switch ( m_eJoinRoomChoice )
            {
//            case EJRC_BY_MSCLIENT_ID:
//                m_GameService.NativeMSCLientJoinServer( m_preJoinRespInfo.iGroupID, m_szPassword );
//                m_GameService.m_eMenuCDKeyAuthorization = EMENU_REQ_NONE;
//                m_pPleaseWait.ShowWindow();
//                break;
            case EJRC_BY_LOBBY_AND_ROOM_ID:
                m_GameService.NativeMSCLientJoinServer(m_preJoinRespInfo.iLobbyID, m_preJoinRespInfo.iGroupID, m_szPassword );
                m_pPleaseWait.ShowWindow();
                break;
                // If we do not need to join a ubi.com room, continue with the pre-login procedure
            case EJRC_NO:
                m_pPleaseWait.ShowLockPopUp();
                m_pSendMessageDest.SendMessage( MWM_CDKEYVAL_SUCCESS );
                //                        HideWindow();
                break;
            }
            break;
            case EPopUpID_JoinRoomErrorPassWd:
                m_pPassword.ShowWindow();
                m_pPasswordEditBox.SelectAll();
                break;
            case EPopUpID_PunkBusterOnlyError:
                if ( R6Console(Root.console).m_bNonUbiMatchMaking ||
                    R6Console(Root.console).m_bStartedByGSClient )
                {
                    Root.ChangeCurrentWidget(MenuQuitID);
                }
                // fall through
            case EPopUpID_CDKeyPleaseWait:
            case EPopUpID_JoinRoomError:
            case EPopUpID_JoinRoomErrorCDKeyInUse:
            case EPopUpID_JoinRoomErrorCDKeySrvNotResp:
            case EPopUpID_JoinRoomErrorSrvFull:
                m_pSendMessageDest.SendMessage( MWM_CDKEYVAL_FAIL );
                HideWindow();
                break;
            case EPopUpID_EnterCDKey:
                m_GameService.EnterCDKey(R6WindowEditBox(m_pR6EnterCDKey.m_ClientArea).GetValue());
                m_pPleaseWait.ShowWindow();
                break;
            case EPopUpID_PunkBusterDisabledServerWarn:
                HandleLockedServerPopUp();
                break;                                
        }
    }
    else if (Result == MR_Cancel)
    {
        switch ( _ePopUpID )
        {
        case EPopUpID_CDKeyPleaseWait:
        case EPopUpID_EnterCDKey:
        case EPopUpID_JoinRoomError:
        case EPopUpID_JoinRoomErrorCDKeyInUse:
        case EPopUpID_JoinRoomErrorCDKeySrvNotResp:
        case EPopUpID_JoinRoomErrorPassWd:
        case EPopUpID_JoinRoomErrorSrvFull:
            m_pSendMessageDest.SendMessage( MWM_CDKEYVAL_FAIL );
            break;
        case EPopUpID_Password:
            case EPopUpID_PunkBusterDisabledServerWarn:
            case EPopUpID_PunkBusterOnlyError:
            m_pSendMessageDest.SendMessage( MWM_CDKEYVAL_FAIL );
            // quit game for m_bNonUbiMatchMaking
            if (R6Console(Root.console).m_bNonUbiMatchMaking)
            {
                Root.ChangeCurrentWidget(MenuQuitID);
            }
            break;
        }
        HideWindow();
    }
}

function SelectCDKeyBox( BOOL _bClearEditBox )
{
    local R6WindowEditBox pR6EditBoxTemp;

    pR6EditBoxTemp = R6WindowEditBox(m_pR6EnterCDKey.m_ClientArea);
    if (_bClearEditBox)
        pR6EditBoxTemp.Clear();
    pR6EditBoxTemp.SelectAll();
}

//==============================================================================
// ProcessGSMsg - messages sent by the game service through the root window
//==============================================================================
function ProcessGSMsg( string _szMsg )
{
    if (bShowLog) log("R6WindowUbiCDKeyCheck ProcessGSMsg msg = "@_szMsg);

    switch (_szMsg)
    {
    case "UP_HANDLE_PB_SRV_SITUATION":
        ShowWindow();
        HandlePunkBusterSvrSituation();
        break;
    case "UP_ENTER_CD_KEY":
        m_pR6EnterCDKey.ModifyTextWindow(Localize("MultiPlayer","PopUp_EnterCDKey","R6Menu"), 205, 170, 230, 30);
        m_pR6EnterCDKey.ShowWindow();
        SelectCDKeyBox(false);
        ShowWindow();
        break;
    case "UP_MOD_ENTER_CD_KEY":
        m_pR6EnterCDKey.ModifyTextWindow(Localize("MultiPlayer","PopUp_ModEnterCDKey","R6Menu"), 205, 170, 230, 30);
        m_pR6EnterCDKey.ShowWindow();
        SelectCDKeyBox(true);
        break;
    case "UP_REQUEST_AUTHID":
        ShowWindow();
        break;
    case "UP_MOD_REQUEST_AUTHID":
        m_pPleaseWait.ShowLockPopUp();
        break;
    case "ACT_ID_REQ_TIMEOUT_ERROR":
        m_pPleaseWait.HideWindow();
        m_pR6EnterCDKey.ModifyTextWindow(m_szLocMod $ Localize("Errors","CDKeyServerNotResponding","R6ENGINE"), 205, 170, 230, 30);
        m_pR6EnterCDKey.ShowWindow();
        break;
    case "ACT_ID_REQ_SUCCESS":
        m_GameService.SaveInfo();
        break;
    case "ACT_ID_REQ_FAIL_INVALIDCDKEY":
        m_pPleaseWait.HideWindow();
        m_pR6EnterCDKey.ModifyTextWindow(m_szLocMod $ Localize("Errors","INVALIDCDKEY","R6ENGINE"), 205, 170, 230, 30);
        m_pR6EnterCDKey.ShowWindow();
        break;
    case "ACT_ID_REQ_FAIL_CDKEYUSED":
        m_pPleaseWait.HideWindow();
        DisplayErrorMsg(m_szLocMod $ Localize("Errors","CDKeyAlreadyInUse","R6ENGINE"), EPopUpID_JoinRoomErrorCDKeyInUse);
        break;
    case "ACT_ID_REQ_FAIL_DEFAULT":
        m_pPleaseWait.HideWindow();
        m_pR6EnterCDKey.ModifyTextWindow(m_szLocMod $ Localize("Errors","CDKeyTryLater","R6ENGINE"), 205, 170, 230, 30);
        m_pR6EnterCDKey.ShowWindow();
        break;
    case "AUTH_ID_REQ_TIMEOUT_ERROR":
        m_pPleaseWait.HideWindow();
        DisplayErrorMsg(m_szLocMod $ Localize("Errors","CDKeyServerNotResponding","R6ENGINE"), EPopUpID_JoinRoomErrorCDKeySrvNotResp);
        break;
    case "AUTH_ID_REQ_INUSE_ERROR":
        m_pPleaseWait.HideWindow();
        DisplayErrorMsg(m_szLocMod $ Localize("Errors","CDKeyAlreadyInUse","R6ENGINE"), EPopUpID_JoinRoomErrorCDKeyInUse);
        break;
    case "AUTH_ID_REQ_TIMEOUT":
    case "AUTH_ID_REQ_SUCCESS":
        m_pPleaseWait.HideWindow();
        HandlePunkBusterSvrSituation();
        break;
    case "AUTH_ID_REQ_NOTCHALLENGED":
        m_pPleaseWait.HideWindow();
        m_pPleaseWait.ModifyTextWindow(m_szLocMod $ Localize("Errors","CDKeyTryLater","R6ENGINE") $ ": 3", 205, 170, 230, 30);
        m_pPleaseWait.ShowWindow();
        break;
    case "AUTH_ID_REQ_INT_ERROR":
        m_pPleaseWait.HideWindow();
        m_pPleaseWait.ModifyTextWindow(m_szLocMod $ Localize("Errors","CDKeyTryLater","R6ENGINE") $ ": 5", 205, 170, 230, 30);
        m_pPleaseWait.ShowWindow();
        break;
    case "AUTH_ID_REQ_FAILURE":
        m_pPleaseWait.HideWindow();
        m_pR6EnterCDKey.ModifyTextWindow(m_szLocMod $ Localize("Errors","INVALIDCDKEY","R6ENGINE"), 205, 170, 230, 30);
        m_pR6EnterCDKey.ShowWindow();
        break;
    case "AUTH_ID_REQ_FAILURE_DBG":
        m_pPleaseWait.HideWindow();
        break;
    case "JOIN_SERVER_REQ_SUCCESS":
        m_pSendMessageDest.SendMessage( MWM_CDKEYVAL_SUCCESS );
        break;
    case "JOIN_SERVER_FAIL_PASSWORDNOTCORRECT":
        m_pPleaseWait.HideWindow();
        DisplayErrorMsg(Localize("MultiPlayer","PopUp_Error_PassWd","R6Menu"), EPopUpID_JoinRoomErrorPassWd);
        break;
    case "JOIN_SERVER_FAIL_ROOMFULL":
        m_pPleaseWait.HideWindow();
        DisplayErrorMsg(Localize("MultiPlayer","PopUp_Error_ServerFull","R6Menu"), EPopUpID_JoinRoomErrorSrvFull);
        break;
    case "JOIN_SERVER_FAIL_DEFAULT":
        m_pPleaseWait.HideWindow();
        DisplayErrorMsg(Localize("MultiPlayer","PopUp_Error_RoomJoin","R6Menu"), EPopUpID_JoinRoomError);
        break;
    default:
        break;
    }
}

function DisplayErrorMsg( string _szErrorMsg, ePopUpID _ePopUpID )
{
    BringToFront();
    Super.DisplayErrorMsg(_szErrorMsg, _ePopUpID);
}
