//=============================================================================
//  R6WindowMPManager.uc : Manage all the windows to be display when you join a game/create a server/valid CD-Key
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/05/12 * Created by Yannick Joly
//=============================================================================
class R6WindowMPManager extends UWindowWindow;

var BOOL bShowLog;

var R6WindowPopUpBox                  m_pError;                  // Error pop-up
var R6WindowPopUpBox                  m_pLongError;              // Wrapped Error Pop-Up (for long messages)
var ClientBeaconReceiver.PreJoinResponseInfo m_preJoinRespInfo;			// Server info
var R6WindowPopUpBox						m_pPassword;				// Pop up to select a password
var R6WindowEditBox							m_pPasswordEditBox;

function PopUpBoxCreate()
{
    local FLOAT fX, fY;
    local FLOAT fWidth, fHeight;
    local FLOAT fTextHeight;
    local R6WindowTextLabel         pR6TextLabelTemp;
  	local R6WindowWrappedTextArea   pR6WrapLabelTemp;

    // Create PopUp frame for error window

    fTextHeight = 30;
    fX          = 205;
    fY          = 170;
    fWidth      = 230;
    fHeight     = 50;

    m_pError = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480));
    m_pError.CreateStdPopUpWindow( Localize("MultiPlayer","PopUp_Error_Title","R6Menu"), fTextHeight, fX, fY, fWidth, fHeight, MessageBoxButtons.MB_OK);
    m_pError.CreateClientWindow( class'R6WindowTextLabel');
    m_pError.m_ePopUpID = EPopUpID_None;
    m_pError.SetPopUpResizable(true);
    pR6TextLabelTemp = R6WindowTextLabel(m_pError.m_ClientArea);
    pR6TextLabelTemp.Text = "- UNREGISTERED ERROR -";
    pR6TextLabelTemp.Align = TA_Center;
    pR6TextLabelTemp.m_Font = Root.Fonts[F_VerySmallTitle];
    pR6TextLabelTemp.TextColor = Root.Colors.BlueLight;
    pR6TextLabelTemp.m_BGTexture = None;
    pR6TextLabelTemp.m_HBorderTexture = None;
    pR6TextLabelTemp.m_VBorderTexture = None;
    pR6TextLabelTemp.m_TextDrawstyle  = ERenderStyle.STY_Alpha;
    m_pError.HideWindow();

    // Create PopUp frame for long error messages

    fTextHeight = 30;
    fX          = 205;
    fY          = 170;
    fWidth      = 230;
    fHeight     = 77;

    m_pLongError = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480));
    m_pLongError.CreateStdPopUpWindow( Localize("MultiPlayer","PopUp_Error_Title","R6Menu"), fTextHeight, fX, fY, fWidth, fHeight, MessageBoxButtons.MB_OK );
    m_pLongError.CreateClientWindow( class'R6WindowWrappedTextArea', false, true);
    m_pLongError.m_ePopUpID = EPopUpID_None;
    pR6WrapLabelTemp = R6WindowWrappedTextArea(m_pLongError.m_ClientArea);
    pR6WrapLabelTemp.SetScrollable(true);			
    pR6WrapLabelTemp.m_fXOffset = 5;
    pR6WrapLabelTemp.m_fYOffset = 5;
    pR6WrapLabelTemp.AddText("- UNREGISTERED ERROR -", Root.Colors.BlueLight, Root.Fonts[F_VerySmallTitle]);
    pR6WrapLabelTemp.m_bDrawBorders = false;
    m_pLongError.HideWindow();
}

function DisplayErrorMsg( string _szErrorMsg, ePopUpID _ePopUpID )
{
  	local R6WindowWrappedTextArea pR6WrapLabelTemp;
    const                         k_CharsForSwitchToWrapped = 30;

#ifdefDEBUG
	log("DisplayErrorMsg: " $ GetEPopUpID(_ePopUpID) $ "; Msg = *" $ _szErrorMsg $ "*" );
#endif

    if (Len(_szErrorMsg) < k_CharsForSwitchToWrapped)
    {
        m_pError.m_ePopUpID = _ePopUpID;

        R6WindowTextLabel(m_pError.m_ClientArea).SetNewText(_szErrorMsg, true);

	m_pError.ShowWindow();
}    
else
    {
        m_pLongError.m_ePopUpID = _ePopUpID;

        pR6WrapLabelTemp = R6WindowWrappedTextArea(m_pLongError.m_ClientArea);

        pR6WrapLabelTemp.Clear(true, true);		
        pR6WrapLabelTemp.AddText( _szErrorMsg, Root.Colors.BlueLight, Root.Fonts[F_VerySmallTitle]);


	    m_pLongError.ShowWindow();
    }
}
//==============================================================================
// HandlePunkBusterSvrSituation -  handle the punk buster server situation  
//==============================================================================
function HandlePunkBusterSvrSituation()
{
	local BOOL bHandlePBSrvSituation;
	local R6GameManager pGameMgr;

	// check for PB
	pGameMgr = R6GameManager(class'Actor'.static.GetGameManager());
	bHandlePBSrvSituation = m_preJoinRespInfo.bResponseRcvd || (R6Console(Root.Console).m_bStartedByGSClient && !pGameMgr.IsGSCreateUbiServer());

	if (bHandlePBSrvSituation && (class'Actor'.static.IsPBClientEnabled()==false) && (m_preJoinRespInfo.iPunkBusterEnabled == 1))
	{
		DisplayErrorMsg( Localize("MultiPlayer", "PopUp_Error_PunkBuster_Only", "R6Menu"), EPopUpID_PunkBusterOnlyError);
	}
	else if (bHandlePBSrvSituation && (class'Actor'.static.IsPBClientEnabled()==true) && (m_preJoinRespInfo.iPunkBusterEnabled == 0))
	{
		R6WindowRootWindow(Root).m_RSimplePopUp.X = 140;
		R6WindowRootWindow(Root).m_RSimplePopUp.Y = 170;
		R6WindowRootWindow(Root).m_RSimplePopUp.W = 360;
		R6WindowRootWindow(Root).m_RSimplePopUp.H = 77;

		Root.SimplePopUp( Localize("MultiPlayer","Popup_Warning_Title","R6Menu"),
						  Localize("MultiPlayer","PopUp_Warning_PunkBuster_Disabled","R6Menu"), 
						  EPopUpID_PunkBusterDisabledServerWarn, MessageBoxButtons.MB_OKCancel, false, self); 
	}
	else
	{
		HandleLockedServerPopUp();
	}
}

function HandleLockedServerPopUp()
{
    local string _GamePassword;
    
    // check for password
    if ( m_preJoinRespInfo.bLocked && !R6Console(Root.Console).m_bStartedByGSClient )
    {
        m_pPassword.ShowWindow(); 
        if (R6Console(Root.console).m_bNonUbiMatchMaking)
        {
            class'Actor'.static.NativeNonUbiMatchMakingPassword(_GamePassword);
            if (_GamePassword == "")
            {
                m_pPasswordEditBox.SelectAll();   
            }
            else
            {
            m_pPasswordEditBox.SetValue(_GamePassword);
                // simulate a click on ok button to close pop-up properly
                m_pPassword.Result = MR_OK;
                m_pPassword.Close();
            }
        }
        else
        {
            m_pPasswordEditBox.SelectAll();
        }
    }                
    else
        PopUpBoxDone( MR_OK, EPopUpID_Password ); // it's not the good way to do that YJ
    
}

defaultproperties
{
}
