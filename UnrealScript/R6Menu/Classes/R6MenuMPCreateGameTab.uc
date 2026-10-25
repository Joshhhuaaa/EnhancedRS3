//=============================================================================
//  R6MenuMPMenuTab.uc : All the create game tab menu were define overhere
//                       You can choose only one of the 3 possible settings!!!!
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/15  * Create by Yannick Joly
//=============================================================================
class R6MenuMPCreateGameTab extends UWindowDialogClientWindow;

enum eCreateGameWindow_ID
{
	eCGW_NotDefine,
	eCGW_Opt,							// regular options
	eCGW_Camera,						// camera options
	eCGW_MapList,						// map list
	eCGW_Password,						// password
	eCGW_AdminPassword,					// admin password
	eCGW_LeftAdvOpt,					// left advanced options list
	eCGW_RightAdvOpt					// right advanced options list
};

struct stServerGameOpt
{
	var UWindowWindow					pGameOptList;
	var Actor.EGameModeInfo				eGameMode;					// the gamemode with list was associate
	var eCreateGameWindow_ID			eCGWindowID;
};

const K_HALFWINDOWWIDTH                 = 310;                    // the half size of window LAN SERVER INFO and GameMode see K_WINDOWWIDTH in MenuMultiplyerWidget

var R6MenuButtonsDefines				m_pButtonsDef;

var Array<R6MenuMPCreateGameTab>		m_ALinkWindow;
var Array<stServerGameOpt>				m_AServerGameOpt;			// an array of all buttons list and their associate gamemode
var Actor.EGameModeInfo					m_eCurrentGameMode;			// the current game mode

//temp until you can get the info from modmanager
var Array<Actor.EGameModeInfo>			m_ANbOfGameMode;
var Array<string>						m_ALocGameMode;

var BOOL								m_bInitComplete;			// the init is complete or not
var BOOL								m_bNewServerProfile;
var BOOL								m_bInGame;					// temp

#ifdefDEBUG
var BOOL								m_bShowLog;
#endif

//*******************************************************************************************
// INIT
//*******************************************************************************************
function Created()
{
	// temp
	m_ANbOfGameMode[0] = GetPlayerOwner().EGameModeInfo.GMI_Adversarial;
	m_ANbOfGameMode[1] = GetPlayerOwner().EGameModeInfo.GMI_Cooperative;
	m_ALocGameMode[0] = Localize("MultiPlayer","GameMode_Adversarial","R6Menu");
	m_ALocGameMode[1] = Localize("MultiPlayer","GameMode_Cooperative","R6Menu");
	// end of temp

	Super.Created();
	m_pButtonsDef = R6MenuButtonsDefines(GetButtonsDefinesUnique(Root.MenuClassDefines.ClassButtonsDefines));
	m_pButtonsDef.SetButtonsSizes( K_HALFWINDOWWIDTH - 15, 15);
}

//===============================================================
// CreateListOfButtons: create the stServerGameOpt for this list of buttons
//===============================================================
function CreateListOfButtons( FLOAT _fX, FLOAT _fY, FLOAT _fW, FLOAT _fH, Actor.EGameModeInfo _eGameMode, eCreateGameWindow_ID _eCGWindowID)
{
	local stServerGameOpt stNewSGOItem;
	local R6WindowListGeneral pTempList;

	pTempList = R6WindowListGeneral(CreateWindow( class'R6WindowListGeneral', _fX, _fY, _fW, _fH, self));
	pTempList.bAlwaysBehind = true;

	stNewSGOItem.pGameOptList = pTempList;
	stNewSGOItem.eGameMode	  = _eGameMode;
	stNewSGOItem.eCGWindowID  = _eCGWindowID;
	
	AddWindowInCreateGameArray(stNewSGOItem);
	UpdateButtons( stNewSGOItem.eGameMode, stNewSGOItem.eCGWindowID);
}

//===============================================================
// UpdateButtons: do the init of the buttons you need
//===============================================================
function UpdateButtons( Actor.EGameModeInfo _eGameMode, eCreateGameWindow_ID _eCGWindowID, optional BOOL _bUpdateValue)
{
	// Implemented in a child class	
}

function R6WindowButtonAndEditBox CreateButAndEditBox( FLOAT _X, FLOAT _Y, FLOAT _W, FLOAT _H, string _szButName, string _szButTip, string _szCheckBoxTip)
{
	local R6WindowButtonAndEditBox pNewBut;

    pNewBut = R6WindowButtonAndEditBox(CreateControl(class'R6WindowButtonAndEditBox', _X, _Y, _W, _H, self));
    pNewBut.m_TextFont   = Root.Fonts[F_SmallTitle];
    pNewBut.m_vTextColor = Root.Colors.White;
    pNewBut.m_vBorder	 = Root.Colors.White;
    pNewBut.m_bSelected  = false;
    pNewBut.CreateTextAndBox( _szButName, _szButTip, 0, 1);
    pNewBut.CreateEditBox( (K_HALFWINDOWWIDTH * 0.5) - 36 );
	pNewBut.m_pEditBox.EditBox.bPassword = true;
	pNewBut.m_pEditBox.EditBox.MaxLength = 16;
    pNewBut.SetEditBoxTip(_szCheckBoxTip);

	return pNewBut;
}

function SetButtonAndEditBox( eCreateGameWindow_ID _eCGW_ID, string _szEditBoxValue, BOOL _bSelected)
{
	local R6WindowButtonAndEditBox pBut;

	pBut = R6WindowButtonAndEditBox(GetList( GetCurrentGameMode(), _eCGW_ID));

	if (pBut != None)
	{
		pBut.m_pEditBox.SetValue( _szEditBoxValue);
		pBut.m_bSelected = _bSelected;
	}
}

//*******************************************************************************************
// UTILITIES FUNCTIONS
//*******************************************************************************************
function AddLinkWindow( R6MenuMPCreateGameTab _pLinkWindow)
{
	m_ALinkWindow[m_ALinkWindow.Length] = _pLinkWindow;
}

//===============================================================
// AddWindowInCreateGameArray: add Window object in creategame array window. 
//===============================================================
function AddWindowInCreateGameArray( stServerGameOpt _NewList)
{
	m_AServerGameOpt[m_AServerGameOpt.Length] = _NewList;
}

//===============================================================
// GetList: get list base on his gamemode and ID
//===============================================================
function UWindowWindow GetList( Actor.EGameModeInfo _eGameMode, eCreateGameWindow_ID _eCGWindowID)
{
	local INT i;

	for ( i = 0; i < m_AServerGameOpt.Length; i++)
	{
		if ((m_AServerGameOpt[i].eGameMode == _eGameMode) && (m_AServerGameOpt[i].eCGWindowID == _eCGWindowID))
		{
			return m_AServerGameOpt[i].pGameOptList;
		}
	}

	return None;
}


function UpdateMenuOptions( INT _iButID, BOOL _bNewValue, R6WindowListGeneral _pOptionsList, optional BOOL _bChangeByUserClick)
{

}

//===============================================================
// SetCurrentGameMode: set the new game mode
//===============================================================
function SetCurrentGameMode( Actor.EGameModeInfo _eGameMode, optional BOOL _bAdviceLinkWindow)
{
	local INT i;

#ifdefDEBUG
	if (m_bShowLog)
	{
		log("R6MenuMPCreateGameTab SetCurrentGameMode");

		if (m_AServerGameOpt.Length == 0)
		{
			log("You need to have at least one list to set the game mode");
		}
	}
#endif
	
	if (_bAdviceLinkWindow)
	{
		for ( i = 0; i < m_ALinkWindow.Length; i++)
		{
			m_ALinkWindow[i].SetCurrentGameMode( _eGameMode);
		}
	}

	// hide all current list	
	for ( i = 0; i < m_AServerGameOpt.Length; i++)
	{
		if (m_AServerGameOpt[i].eGameMode != _eGameMode)
		{
			if (m_AServerGameOpt[i].pGameOptList.IsA('R6WindowListGeneral'))
			{
				R6WindowListGeneral(m_AServerGameOpt[i].pGameOptList).ChangeVisualItems( false);
			}

			m_AServerGameOpt[i].pGameOptList.HideWindow();
		}
	}

	// show all the new window list
	for ( i = 0; i < m_AServerGameOpt.Length; i++)
	{
		if (m_AServerGameOpt[i].eGameMode == _eGameMode)
		{
			m_AServerGameOpt[i].pGameOptList.ShowWindow();

			if (m_AServerGameOpt[i].pGameOptList.IsA('R6WindowListGeneral'))
			{
				R6WindowListGeneral(m_AServerGameOpt[i].pGameOptList).ChangeVisualItems( true);
			}

			m_eCurrentGameMode = _eGameMode;
		}
	}

	RefreshCGButtons(); // update buttons 
}

//===============================================================
// GetCurrentGameMode: Get the current game mode
//===============================================================
function Actor.EGameModeInfo GetCurrentGameMode()
{
	return m_eCurrentGameMode;
}

//*******************************************************************************************
// IN-GAME FUNCTIONS
//*******************************************************************************************
function Refresh()
{
	// implemented in child class
}

function BOOL SendNewMapSettings(OUT BYTE _bMapCount)
{
	// implemented in child class
	return false;
}

function BOOL SendNewServerSettings()
{
	// implemented in child class
	return false;
}

//*******************************************************************************************
// SERVER OPTIONS FUNCTIONS
//*******************************************************************************************
//=======================================================================
// RefreshServerOpt: Refresh the creategame options according the value find in class R6ServerInfo (init from server.ini)
//=======================================================================
function RefreshServerOpt( optional BOOL _bNewServerProfile)
{
	RefreshCGButtons();
}

function RefreshCGButtons()
{
	local INT i;

	// parse all the active window and update button

	for (i = 0; i < m_AServerGameOpt.Length; i++)
	{
		if (m_AServerGameOpt[i].eGameMode == GetCurrentGameMode())
		{
			UpdateButtons( m_AServerGameOpt[i].eGameMode, m_AServerGameOpt[i].eCGWindowID, true);
		}
	}
}

function SetServerOptions()
{
	// Implemented in a child class
}


//*******************************************************************************************
// NOTIFY FUNCTIONS
//*******************************************************************************************
//=================================================================
// notify the parent window by using the appropriate parent function
//=================================================================
function Notify(UWindowDialogControl C, byte E)
{
    local BOOL bProcessNotify;

	if(E == DE_Click)
	{
        // Change Current Selected Button
        if ( C.IsA('R6WindowButtonBox'))
        {
            ManageR6ButtonBoxNotify(C);
            bProcessNotify = true;
        }
    }

    if ((bProcessNotify) && (m_bInitComplete) && (!m_bNewServerProfile))
    {
        SetServerOptions();
    }
}

//=================================================================
// manage the R6WindowButton notify message
//=================================================================
function ManageR6ButtonNotify( UWindowDialogControl C, byte E)
{
    switch (E)
    {
        case DE_MouseLeave:
            R6WindowButton(C).SetButtonBorderColor(Root.Colors.White);
            R6WindowButton(C).TextColor = Root.Colors.White;
            break;
        case DE_MouseEnter:
            R6WindowButton(C).SetButtonBorderColor(Root.Colors.BlueLight);
            R6WindowButton(C).TextColor = Root.Colors.BlueLight;
            break;
    }
}

/////////////////////////////////////////////////////////////////
// manage the R6WindowButtonBox notify message
/////////////////////////////////////////////////////////////////
function ManageR6ButtonBoxNotify( UWindowDialogControl C)
{
    // for DE_Click msg
    if (R6WindowButtonBox(C).GetSelectStatus())
    {
        R6WindowButtonBox(C).m_bSelected = !R6WindowButtonBox(C).m_bSelected; // change the boolean state

		UpdateMenuOptions( R6WindowButtonBox(C).m_iButtonID, R6WindowButtonBox(C).m_bSelected, R6WindowListGeneral(GetList(GetCurrentGameMode(), eCGW_Opt)),true);
    }
}

/////////////////////////////////////////////////////////////////
// manage the R6WindowButtonAndEditBox notify message
/////////////////////////////////////////////////////////////////
function ManageR6ButtonAndEditBoxNotify( UWindowDialogControl C)
{
    // for DE_Click msg
    if (R6WindowButtonAndEditBox(C).GetSelectStatus())
    {
        R6WindowButtonAndEditBox(C).m_bSelected = !R6WindowButtonAndEditBox(C).m_bSelected; // change the boolean state
    }

}

defaultproperties
{
}
