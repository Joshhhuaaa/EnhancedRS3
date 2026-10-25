//=============================================================================
//  R6WindowUbiLogIn.uc : This is used to pop up a window that will ask the user
//                  to input his ubi.com account info.
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/01/08 * Created by John Bennett
//=============================================================================
class R6WindowUbiLogIn extends R6WindowMPManager;

var R6WindowPopUpBox                  m_pR6UbiAccount;           // Pop up for ubi account
var R6WindowPopUpBox                  m_pDisconnected;           // Disconnected from ubi.com
var R6GSServers                       m_GameService;             // Manages servers from game service
var UWindowWindow                     m_pSendMessageDest;

var string                            m_szInitError;             // message received while the MSClient is initialising

//=======================================================================
// StartLogInProcedure - Called from the menus when the user should
// enter his ubi.com userID/password
//=======================================================================
function StartLogInProcedure( UWindowWindow _pCurrentWidget )
{
    m_pSendMessageDest = _pCurrentWidget;

    // the game manager answers through ProcessGSMsg
    Root.RegisterMsgWindow(self);
    class'Actor'.static.GetGameManager().StartLogInProcedure();
}

//=======================================================================
// LogInAfterDisconnect - Called from the menus when the connection
// to ubi.com has been lost
//=======================================================================
function LogInAfterDisconnect( UWindowWindow _pCurrentWidget )
{
    m_pSendMessageDest = _pCurrentWidget;
    ShowWindow();
    m_pDisconnected.ShowWindow();
}

//=======================================================================
// Manager - Should be called regularly by the parent window whenever
// a reques is in progress
//=======================================================================

function Manager( UWindowWindow _pCurrentWidget )
{
    m_pSendMessageDest = _pCurrentWidget;
}

//=======================================================================
// ProcessGSMsg - messages sent by the game service through the root window
//=======================================================================
function ProcessGSMsg( string _szMsg )
{
    if (bShowLog) log("R6WindowUbiLogIn ProcessGSMsg msg = "@_szMsg);

    // keep the message until InitializeMSClient returns
    if (m_szInitError == "INITIALIZEMSCLIENT")
    {
        m_szInitError = _szMsg;
        return;
    }

    switch( _szMsg )
    {
        case "LOGIN_START":
            m_pR6UbiAccount.HideWindow();
            m_pDisconnected.HideWindow();
            m_pError.HideWindow();
            ShowWindow();
            R6WindowUbiLoginClient(m_pR6UbiAccount.m_ClientArea).m_pPassword.SetValue( m_GameService.m_szSavedPwd );
            R6WindowUbiLoginClient(m_pR6UbiAccount.m_ClientArea).m_pUserName.SetValue( m_GameService.m_szUserID );
            m_pR6UbiAccount.ShowWindow();
            // force the cursor on the edit box
            R6WindowUbiLoginClient(m_pR6UbiAccount.m_ClientArea).m_pUserName.EditBox.LMouseDown(0,0);
            break;
        case "LOGIN_SKIPPED":
            m_pR6UbiAccount.HideWindow();
            m_pDisconnected.HideWindow();
            m_pError.HideWindow();
            m_pSendMessageDest.SendMessage( MWM_UBI_LOGIN_SKIPPED );
            break;
        case "LOGIN_ALREADY_IN_PROGRESS":
            Root.UnRegisterMsgWindow();
            break;
        case "LOGIN_SUCCESS":
            m_pR6UbiAccount.HideWindow();
            m_pDisconnected.HideWindow();
            HideWindow();
            m_GameService.SaveConfig();
            m_pSendMessageDest.SendMessage( MWM_UBI_LOGIN_SUCCESS );
            break;
        case "LOGIN_FAIL_PASSWORDNOTCORRECT":
            DisplayErrorMsg( Localize("MultiPlayer","PopUp_Error_PassWd","R6Menu"), EPopUpID_LoginError);
            break;
        case "LOGIN_FAIL_NOTREGISTERED":
            DisplayErrorMsg( Localize("MultiPlayer","PopUp_Error_UserID","R6Menu"), EPopUpID_LoginError);
            break;
        case "LOGIN_FAIL_ALREADYCONNECTED":
            DisplayErrorMsg( Localize("MultiPlayer","PopUp_Error_IdInUse","R6Menu"), EPopUpID_LoginError);
            break;
        case "LOGIN_FAIL_DATABASEFAILED":
            DisplayErrorMsg( Localize("MultiPlayer","PopUp_Error_DataBase","R6Menu"), EPopUpID_LoginError);
            break;
        case "LOGIN_FAIL_BANNEDACCOUNT":
            DisplayErrorMsg( Localize("MultiPlayer","PopUp_Error_Banned","R6Menu"), EPopUpID_LoginError);
            break;
        case "LOGIN_FAIL_BLOCKEDACCOUNT":
            DisplayErrorMsg( Localize("MultiPlayer","PopUp_Error_Blocked","R6Menu"), EPopUpID_LoginError);
            break;
        case "LOGIN_FAIL_LOCKEDACCOUNT":
            DisplayErrorMsg( Localize("MultiPlayer","PopUp_Error_Locked","R6Menu"), EPopUpID_LoginError);
            break;
        case "LOGIN_FAIL_DEFAULT":
            DisplayErrorMsg( Localize("MultiPlayer","PopUp_Error_Default","R6Menu"), EPopUpID_LoginError);
            break;
        default:
            break;
    }
}
//=======================================================================
// PopUpBoxCreate - Creates the pop up windows
//=======================================================================

function PopUpBoxCreate()
{
    local R6WindowUbiLoginClient pR6LoginClientTemp;
    local R6WindowWrappedTextArea pTextZone;
    local FLOAT fX, fY;
    local FLOAT fWidth, fHeight;
    local FLOAT fTextHeight;

    Super.PopUpBoxCreate();

    // Create PopUp frame for ubi login name password

    fTextHeight = 30;
    fX          = 160;
    fY          = 140;
    fWidth      = 300;
    fHeight     = 118;

    m_pR6UbiAccount = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480));
    m_pR6UbiAccount.CreateStdPopUpWindow( Localize("MultiPlayer","PopUp_UbiComUser","R6Menu"), fTextHeight, fX, fY, fWidth, fHeight );
    m_pR6UbiAccount.CreateClientWindow( Root.MenuClassDefines.ClassUbiLoginClient);
    m_pR6UbiAccount.m_ePopUpID = EPopUpID_UbiAccount;
    pR6LoginClientTemp = R6WindowUbiLoginClient(m_pR6UbiAccount.m_ClientArea);
    pR6LoginClientTemp.SetupClientWindow( fWidth );
    pR6LoginClientTemp.m_pPassword.SetValue( m_GameService.m_szSavedPwd );
    pR6LoginClientTemp.m_pUserName.SetValue( m_GameService.m_szUserID );
    pR6LoginClientTemp.m_pSavePassword.SetButtonBox( m_GameService.m_bSavePWSave );
    pR6LoginClientTemp.m_pAutoLogIn.SetButtonBox( m_GameService.m_bAutoLISave );
    pR6LoginClientTemp.m_pAutoLogIn.bDisabled = !pR6LoginClientTemp.m_pSavePassword.m_bSelected;

    m_pR6UbiAccount.HideWindow();

    fTextHeight = 30;
    fX          = 205;
    fY          = 170;
    fWidth      = 230;
    fHeight     = 77;

    // Create PopUp frame for window indicating a disconnectgion from ubi.com

    m_pDisconnected = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480));
    m_pDisconnected.CreateStdPopUpWindow( Localize("MultiPlayer","PopUp_Error_Title","R6Menu"), fTextHeight, fX, fY, fWidth, fHeight );
    m_pDisconnected.CreateClientWindow( class'R6WindowWrappedTextArea');
    m_pDisconnected.m_ePopUpID = EPopUpID_UbiComDisconnected;
	pTextZone = R6WindowWrappedTextArea(m_pDisconnected.m_ClientArea);
	pTextZone.SetScrollable(true);			
	pTextZone.m_fXOffset = 5;
	pTextZone.m_fYOffset = 5;
	pTextZone.AddText(Localize("MultiPlayer","PopUp_Reconnect","R6Menu"), Root.Colors.BlueLight, Root.Fonts[F_VerySmallTitle]);
    pTextZone.m_bDrawBorders = false;
    m_pDisconnected.HideWindow();
}

//==============================================================================
// PopUpBoxDone -  receive the result of the popup box  
//==============================================================================
function PopUpBoxDone( MessageBoxResult Result, ePopUpID _ePopUpID)
{
    local R6WindowUbiLoginClient pUbiLoginClient;

    if (Result == MR_OK)
    {
        switch ( _ePopUpID )
        {
            case EPopUpID_UbiAccount:
                pUbiLoginClient = R6WindowUbiLoginClient(m_pR6UbiAccount.m_ClientArea);
                m_GameService.SetUbiAccount( pUbiLoginClient.m_pUserName.GetValue(),
                                             pUbiLoginClient.m_pPassword.GetValue() );
                m_GameService.m_bUbiAccntInfoEntered = TRUE;

                if ( pUbiLoginClient.m_pSavePassword.m_bSelected )
                    m_GameService.m_szSavedPwd = m_GameService.m_szPassword;
                else
                    m_GameService.m_szSavedPwd = "";

                // Save values of button boxes
                m_GameService.m_bSavePWSave = pUbiLoginClient.m_pSavePassword.m_bSelected;
                m_GameService.m_bAutoLISave = pUbiLoginClient.m_pAutoLogIn.m_bSelected;

                // Initialise the MSClient SDK
                if ( !m_GameService.NativeGetMSClientInitialized() )
                {
                    m_szInitError = "INITIALIZEMSCLIENT";
                    m_GameService.InitializeMSClient();
                }

                // If required, get an activation ID from ubi.com
//                if ( !m_GameService.m_bValidActivationID  && m_GameService.m_bGameServiceInit )
//                    m_GameService.requestGSCDKeyActID();
                m_pR6UbiAccount.ShowWindow();
                if ((m_szInitError != "") && (m_szInitError != "INITIALIZEMSCLIENT"))
                    ProcessGSMsg(m_szInitError);
                m_szInitError = "";
                break;
            case EPopUpID_LoginError:
                break;
            case EPopUpID_UbiComDisconnected:
                // Initialise the MSClient SDK
                if ( !m_GameService.NativeGetMSClientInitialized() )
                {
                    m_szInitError = "INITIALIZEMSCLIENT";
                    m_GameService.InitializeMSClient();
                }
                m_pDisconnected.ShowWindow();
                if ((m_szInitError != "") && (m_szInitError != "INITIALIZEMSCLIENT"))
                    ProcessGSMsg(m_szInitError);
                m_szInitError = "";
                break;
        }
    }
    else if (Result == MR_Cancel)
    {
        switch ( _ePopUpID )
        {
            case EPopUpID_LoginError:
                m_pError.HideWindow();
                break;
            case EPopUpID_UbiAccount:
            case EPopUpID_UbiComDisconnected:
                HideWindow();
                m_pSendMessageDest.SendMessage( MWM_UBI_LOGIN_FAIL );
                break;
        }
    }
}

function ShowWindow()
{
	bAlwaysAcceptsFocus = true;
	Super.ShowWindow();
}

function HideWindow()
{
	Root.UnRegisterMsgWindow();
	bAlwaysAcceptsFocus = false;
	Super.HideWindow();
}

defaultproperties
{
}
