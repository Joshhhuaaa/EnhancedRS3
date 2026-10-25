//=============================================================================
//  R6MenuButtonsDefines.uc : This is the definiton of all the buttons and some function to create it
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/09  * Create by Yannick Joly
//=============================================================================
class R6MenuButtonsDefines extends UWindowWindow;

// buttons localisation extension
enum eButLocalizationExt
{
	eBLE_None,
	eBLE_DisableToolTip
};

struct STButton
{
	var string		szButtonName;
	var string		szTip;
	var FLOAT		fWidth;
	var FLOAT		fHeight;
	var INT			iButtonID;
};

// buttons parameters
var FLOAT												m_fWidth;
var FLOAT												m_fHeight;

function SetButtonsSizes( FLOAT _fWidth, FLOAT _fHeight)
{
	m_fWidth  = _fWidth;
	m_fHeight = _fHeight;
}

function string GetButtonLoc( INT _iButtonID, optional BOOL _bTip, optional eButLocalizationExt _eBLE)
{
	local string szName;
	local string szTip;
	local string szExt;

	switch( _iButtonID)
	{
		// TIME MAP
		case EButtonName.EBN_RoundPerMatch:
			szName = Localize("MPCreateGame","Options_RoundMatch","R6Menu");
//			szTip  = Localize("Tip","Options_RoundMatch","R6Menu");
			break;

		// ROUND TIME 
		case EButtonName.EBN_RoundTime:
			szName = Localize("MPCreateGame","Options_Round","R6Menu");
//			szTip  = Localize("Tip","Options_Round","R6Menu");
			break;

	    // NUMBER OF PLAYERS
		case EButtonName.EBN_NB_Players:
			szName = Localize("MPCreateGame","Options_NbOfPlayers","R6Menu");
//			szTip  = Localize("Tip","Options_NbOfPlayers","R6Menu");
			break;

	    // BOMB TIMER
		case EButtonName.EBN_BombTimer:
			szName = Localize("MPCreateGame","Options_BombTimer","R6Menu");
//			szTip  = Localize("Tip","Options_BombTimer","R6Menu");
			break;

	    // SPECTATOR
		case EButtonName.EBN_Spectator:
			szName = Localize("MPCreateGame","Options_Spectator","R6Menu");
//			szTip  = Localize("Tip","Options_Spectator","R6Menu");
			break;

	    // ROUND PER MISSION
		case EButtonName.EBN_RoundPerMission:
			szName = Localize("MPCreateGame","Options_RoundMission","R6Menu");
//			szTip  = Localize("Tip","Options_RoundMission","R6Menu");
			break;

	    // TIME BETWEEN ROUND
		case EButtonName.EBN_TimeBetRound:
			szName = Localize("MPCreateGame","Options_BetRound","R6Menu");
//			szTip  = Localize("Tip","Options_BetRound","R6Menu");
			break;

	    // NUMBER OF TERRORIST
		case EButtonName.EBN_NB_of_Terro: 
			szName = Localize("MPCreateGame","Options_NbOfTerro","R6Menu");
//			szTip  = Localize("Tip","Options_NbOfTerro","R6Menu");
			break;

	    // PUBLIC SERVER
		case EButtonName.EBN_InternetServer:
			szName = Localize("MPCreateGame","Options_ServerLocation","R6Menu");
			szTip  = Localize("Tip","Options_ServerLocation","R6Menu");
			break;

	    // DEDICATED SERVER
		case EButtonName.EBN_DedicatedServer:
			szName = Localize("MPCreateGame","Options_Dedicated","R6Menu");
			szTip  = Localize("Tip","Options_Dedicated","R6Menu");
			break;

	    // FRIENDLY SERVER
		case EButtonName.EBN_FriendlyFire:
			szName = Localize("MPCreateGame","Options_Friendly","R6Menu");
			szTip  = Localize("Tip","Options_Friendly","R6Menu");
			break;

	    // SHOW ENNEMY NAMES
		case EButtonName.EBN_AllowTeamNames:
			szName = Localize("MPCreateGame","Options_AllowTeamNames","R6Menu");
			szTip  = Localize("Tip","Options_AllowTeamNames","R6Menu");
			break;

	    // AUTO BALANCE TEAM
		case EButtonName.EBN_AutoBalTeam:
			szName = Localize("MPCreateGame","Options_Auto","R6Menu");
			szTip  = Localize("Tip","Options_Auto","R6Menu");
			break;

	    // TK PENALTY
		case EButtonName.EBN_TKPenalty:
			szName = Localize("MPCreateGame","Options_TK","R6Menu");
			szTip  = Localize("Tip","Options_TK","R6Menu");
			break;

	    // SHOW RADAR
		case EButtonName.EBN_AllowRadar:
			szName = Localize("MPCreateGame","Options_AllowRadar","R6Menu");
			szTip  = Localize("Tip","Options_AllowRadar","R6Menu");
			break;

	    // ROTATE MAP WHEN SUCCEED
		case EButtonName.EBN_RotateMap:
			szName = Localize("MPCreateGame","Options_RotateMap","R6Menu");
			szTip  = Localize("Tip","Options_RotateMap","R6Menu");
			break;

	    // AI BACKUP
		case EButtonName.EBN_AIBkp:
			szName = Localize("MPCreateGame","Options_AIBackup","R6Menu");
			szTip  = Localize("Tip","Options_AIBackup","R6Menu");
			break;

	    // SHOW FIRST PERSON WEAPON
		case EButtonName.EBN_ForceFPersonWp:
			szName = Localize("MPCreateGame","Options_ForceFPersonWp","R6Menu");
			szTip  = Localize("Tip","Options_ForceFPersonWp","R6Menu");
			break;

	    // FIRST PERSON
		case EButtonName.EBN_CamFirstPerson:
			szName = Localize("MPCreateGame","Options_FirstP","R6Menu");
			szTip  = Localize("Tip","Options_FirstP","R6Menu");
			break;

	    // THIRD PERSON
		case EButtonName.EBN_CamThirdPerson:
			szName = Localize("MPCreateGame","Options_ThirdP","R6Menu");
			szTip  = Localize("Tip","Options_ThirdP","R6Menu");
			break;

	    // FREE THIRD PERSON
		case EButtonName.EBN_CamFreeThirdP:
			szName = Localize("MPCreateGame","Options_FreeThirdP","R6Menu");
			szTip  = Localize("Tip","Options_FreeThirdP","R6Menu");
			break;

	    // GHOST CAMERA
		case EButtonName.EBN_CamGhost:
			szName = Localize("MPCreateGame","Options_Ghost","R6Menu");
			szTip  = Localize("Tip","Options_Ghost","R6Menu");
			break;

	    // FADE TO BLACK
		case EButtonName.EBN_CamFadeToBk:
			szName = Localize("MPCreateGame","Options_Fade","R6Menu");
			szTip  = Localize("Tip","Options_Fade","R6Menu");
			break;

	    // TEAM ONLY
		case EButtonName.EBN_CamTeamOnly:
			szName = Localize("MPCreateGame","Options_TeamOnly","R6Menu");
			szTip  = Localize("Tip","Options_TeamOnly","R6Menu");
			break;

//#ifdefR6PUNKBUSTER
		// PUNKBUSTER
		case EButtonName.EBN_PunkBuster:
			szName = Localize("MPCreateGame","Options_PunkBuster","R6Menu");
			szTip  = Localize("Tip","Options_PunkBuster","R6Menu");
			if (_eBLE == eBLE_DisableToolTip)
				szExt = Localize("MPCreateGame","Options_PunkBuster","R6Menu");
			break;
//#endif

		// LOG IN
		case EButtonName.EBN_LogIn:
			szName = Localize("MultiPlayer","ButtonLogIn","R6Menu");
			szTip  = Localize("Tip","ButtonLogIn","R6Menu");
			break;

		// LOG OUT
		case EButtonName.EBN_LogOut:
			szName = Localize("MultiPlayer","ButtonLogOut","R6Menu");
			szTip  = Localize("Tip","ButtonLogOut","R6Menu");
			break;

		// JOIN
		case EButtonName.EBN_Join:
			szName = Localize("MultiPlayer","ButtonJoin","R6Menu");
			szTip  = Localize("Tip","ButtonJoin","R6Menu");
			break;

		// JOIN IP
		case EButtonName.EBN_JoinIP:
			szName = Localize("MultiPlayer","ButtonJoinIP","R6Menu");
			szTip  = Localize("Tip","ButtonJoinIP","R6Menu");
			break;

		// REFRESH
		case EButtonName.EBN_Refresh:
			szName = Localize("MultiPlayer","ButtonRefresh","R6Menu");
			szTip  = Localize("Tip","ButtonRefresh","R6Menu");
			break;

		// CREATE
		case EButtonName.EBN_Create:
			szName = Localize("MultiPlayer","ButtonCreate","R6Menu");
			szTip  = Localize("Tip","ButtonCreate","R6Menu");
			break;

		// DIFFICULTY LEVEL
		case EButtonName.EBN_DiffLevel:
			szName = Localize("MPCreateGame","Options_DiffLev","R6Menu");
			szTip  = Localize("Tip","Options_DiffLev","R6Menu");
			break;

		// RECRUIT LEVEL
		case EButtonName.EBN_Recruit:
			szName = Localize("SinglePlayer","Difficulty1","R6Menu");
			szTip  = Localize("Tip","Diff_Recruit","R6Menu");
			break;

		// VETERAN LEVEL
		case EButtonName.EBN_Veteran:
			szName = Localize("SinglePlayer","Difficulty2","R6Menu");
			szTip  = Localize("Tip","Diff_Veteran","R6Menu");
			break;

		// ELITE LEVEL
		case EButtonName.EBN_Elite:
			szName = Localize("SinglePlayer","Difficulty3","R6Menu");
			szTip  = Localize("Tip","Diff_Elite","R6Menu");
			break;

		case EButtonName.EBN_None:
			szName = "";
			break;

		default: log("Button not supported");
			break;
	}

	if (_eBLE != eBLE_None)
	{
		return szExt;
	}
	else if ( _bTip)
	{
		return szTip;
	}
	else
	{
		return szName;
	}
}

function GetCounterTipLoc( INT _iButtonID, out string _szLeftTip, out string _szRightTip)
{
	switch( _iButtonID)
	{
		// TIME MAP
		case EButtonName.EBN_RoundPerMatch:
			_szLeftTip  = Localize("Tip","Options_RoundMatch","R6Menu");
			_szRightTip = Localize("Tip","Options_RoundMatch","R6Menu");
			break;

		// ROUND TIME 
		case EButtonName.EBN_RoundTime:
			_szLeftTip  = Localize("Tip","Options_RoundMin","R6Menu");
			_szRightTip = Localize("Tip","Options_RoundMax","R6Menu");
			break;

	    // NUMBER OF PLAYERS
		case EButtonName.EBN_NB_Players:
			_szLeftTip  = Localize("Tip","Options_NbOfPlayersMin","R6Menu");
			_szRightTip = Localize("Tip","Options_NbOfPlayersMax","R6Menu");
			break;

	    // BOMB TIMER
		case EButtonName.EBN_BombTimer:
			_szLeftTip  = Localize("Tip","Options_BombTimer","R6Menu");
			_szRightTip = Localize("Tip","Options_BombTimer","R6Menu");
			break;

	    // SPECTATOR
		case EButtonName.EBN_Spectator:
			_szLeftTip  = Localize("Tip","Options_Spectator","R6Menu");
			_szRightTip = Localize("Tip","Options_Spectator","R6Menu");
			break;

	    // TIME PER MISSION
		case EButtonName.EBN_RoundPerMission:
			_szLeftTip  = Localize("Tip","Options_RoundMission","R6Menu");
			_szRightTip = Localize("Tip","Options_RoundMission","R6Menu");
			break;

	    // TIME BETWEEN ROUND
		case EButtonName.EBN_TimeBetRound:
			_szLeftTip  = Localize("Tip","Options_BetRound","R6Menu");
			_szRightTip = Localize("Tip","Options_BetRound","R6Menu");
			break;

	    // NUMBER OF TERRORIST
		case EButtonName.EBN_NB_of_Terro: 
			_szLeftTip  = Localize("Tip","Options_NbOfTerro","R6Menu");
			_szRightTip = Localize("Tip","Options_NbOfTerro","R6Menu");
			break;
		default: log("Button not supported");
			break;
	}
}

//===================================================================================
//===================================================================================
//===================================================================================
// THE SECTION ABOVE IS FOR BUTTON THAT WE HAVE IN A LIST

//===============================================================
// AddButtonCombo: Add a buttoncombo with item values in a list
//===============================================================
function AddButtonCombo( INT _iButtonID, R6WindowListGeneral _R6WindowListGeneral, optional UWindowWindow _OwnerWindow)
{
	local STButton stButtonTemp;

	if (m_fWidth == 0)
		m_fWidth = _R6WindowListGeneral.WinWidth;

	if (m_fHeight == 0)
		m_fHeight = _R6WindowListGeneral.WinHeight;

	stButtonTemp.szButtonName   = GetButtonLoc(_iButtonID); 
	stButtonTemp.szTip			= GetButtonLoc(_iButtonID, true);
	stButtonTemp.fWidth			= m_fWidth;
	stButtonTemp.fHeight		= m_fHeight;
	stButtonTemp.iButtonID		= _iButtonID;

	AddCombo( stButtonTemp, _R6WindowListGeneral, UWindowDialogClientWindow(_OwnerWindow));
}

//===============================================================================================================
// 
//===============================================================================================================
function AddCombo( STButton _stButton, R6WindowListGeneral _R6WindowListGeneral, UWindowDialogClientWindow _pParentWindow)
{
	local R6WindowComboControl pR6WindowComboControl;
	local R6WindowListGeneralItem GeneralItem;

	GeneralItem = R6WindowListGeneralItem(_R6WindowListGeneral.Items.Append(_R6WindowListGeneral.ListClass));
	pR6WindowComboControl = R6WindowComboControl(_pParentWindow.CreateControl(class'R6WindowComboControl', 0, 0, _stButton.fWidth, LookAndFeel.Size_ComboHeight, _R6WindowListGeneral));
	pR6WindowComboControl.AdjustTextW( _stButton.szButtonName, 0, 0, _stButton.fWidth * 0.5 , LookAndFeel.Size_ComboHeight);
	pR6WindowComboControl.AdjustEditBoxW( 0, 120, LookAndFeel.Size_ComboHeight);
	pR6WindowComboControl.SetEditBoxTip( _stButton.szTip);
	pR6WindowComboControl.SetValue( "", "");
	pR6WindowComboControl.SetFont( F_VerySmallTitle); // overwrite the default font in AdjustTextW
	pR6WindowComboControl.m_iButtonID = _stButton.iButtonID;

	GeneralItem.m_pR6WindowComboControl = pR6WindowComboControl;
	GeneralItem.m_iItemID				= _stButton.iButtonID;
}

//===============================================================================================================
// 
//===============================================================================================================
function AddItemInComboButton(INT _iButtonID, string _NewItem, string _SecondValue, R6WindowListGeneral _pListToUse)
{
    local R6WindowListGeneralItem TempItem;

	TempItem = R6WindowListGeneralItem(FindButtonItem( _iButtonID, _pListToUse));

	if (TempItem.m_pR6WindowComboControl != None)
	{
		if (TempItem.m_pR6WindowComboControl.m_iButtonID == _iButtonID)
		{
			TempItem.m_pR6WindowComboControl.AddItem( _NewItem, _SecondValue);
		}
	}
#ifdefDEBUG
	else
	{
		log("AddItemInComboButton --> This button "@GetButtonLoc(_iButtonID)@"is not in the list");
	}
#endif
}

//===============================================================================================================
// 
//===============================================================================================================
function ChangeButtonComboValue( INT _iButtonID, string _szNewValue, R6WindowListGeneral _pListToUse, optional BOOL _bDisabled)
{
	local INT iTemFind;
    local R6WindowListGeneralItem TempItem;

	TempItem = R6WindowListGeneralItem(FindButtonItem( _iButtonID, _pListToUse));

	if ((TempItem != None) && (TempItem.m_pR6WindowComboControl != None))
	{
		if (TempItem.m_pR6WindowComboControl.m_iButtonID == _iButtonID)
		{
			//change the value if this value exist?
			iTemFind = TempItem.m_pR6WindowComboControl.FindItemIndex2( _szNewValue, true);
			if (iTemFind != -1)
			{
				TempItem.m_pR6WindowComboControl.SetSelectedIndex( iTemFind);
			}

			TempItem.m_pR6WindowComboControl.SetDisableButton( _bDisabled);
		}
	}
#ifdefDEBUG
	else
	{
		log("ChangeButtonComboValue --> This button "@GetButtonLoc(_iButtonID)@"is not in the list");
	}
#endif
}

//===============================================================================================================
// GetButtonComboValue: get the value of the combo
//===============================================================================================================
function string GetButtonComboValue( INT _iButtonID, R6WindowListGeneral _pListToUse)
{
    local R6WindowListGeneralItem TempItem;

	TempItem = R6WindowListGeneralItem(FindButtonItem( _iButtonID, _pListToUse));

	if ((TempItem != None) && (TempItem.m_pR6WindowComboControl != None))
	{
		if (TempItem.m_pR6WindowComboControl.m_iButtonID == _iButtonID)
		{
			return TempItem.m_pR6WindowComboControl.GetValue2();
		}
	}

#ifdefDEBUG
	log("GetButtonComboValue --> This button "@GetButtonLoc(_iButtonID)@"is not in the list");
#endif

	return "";
}




//===================================================================================
//====================== BUTTON COUNTER SECTION =====================================
//===================================================================================

//===============================================================
// AddButtonInt: Add a button with int values in a list
//===============================================================
function AddButtonInt( INT _iButtonID, INT _iMin, INT _iMax, INT _iInitialValue, R6WindowListGeneral _R6WindowListGeneral, optional UWindowWindow _OwnerWindow)
{
	local STButton stButtonTemp;

	if (m_fWidth == 0)
		m_fWidth = _R6WindowListGeneral.WinWidth;

	if (m_fHeight == 0)
		m_fHeight = _R6WindowListGeneral.WinHeight;

	stButtonTemp.szButtonName   = GetButtonLoc(_iButtonID); 
	stButtonTemp.szTip			= GetButtonLoc(_iButtonID, true);
	stButtonTemp.fWidth			= m_fWidth;
	stButtonTemp.fHeight		= m_fHeight;
	stButtonTemp.iButtonID		= _iButtonID;

	AddCounterButton( stButtonTemp, _iMin, _iMax, _iInitialValue, _R6WindowListGeneral, _OwnerWindow);
}

//===============================================================================================================
//
//===============================================================================================================
function AddCounterButton( STButton _stButton, INT _iMinValue, INT _iMaxValue, INT _iDefaultValue, R6WindowListGeneral _R6WindowListGeneral, UWindowWindow _pParentWindow)
{
	local R6WindowCounter pR6WindowCounter;
	local R6WindowListGeneralItem GeneralItem;
	local string szLeftTip, szRightTip;

	GeneralItem = R6WindowListGeneralItem(_R6WindowListGeneral.Items.Append(_R6WindowListGeneral.ListClass));
	pR6WindowCounter = R6WindowCounter(_pParentWindow.CreateWindow( class'R6WindowCounter', 0, 0, _stButton.fWidth, _stButton.fHeight, _R6WindowListGeneral)); 
    pR6WindowCounter.bAlwaysBehind = true;
    pR6WindowCounter.ToolTipString = _stButton.szTip; // all the buttons tooltip
    pR6WindowCounter.m_iButtonID   = _stButton.iButtonID;
    pR6WindowCounter.SetAdviceParent(true);
    pR6WindowCounter.CreateLabelText( 0, 0, _stButton.fWidth, _stButton.fHeight);
    pR6WindowCounter.SetLabelText( _stButton.szButtonName, Root.Fonts[F_SmallTitle], Root.Colors.White);
    pR6WindowCounter.CreateButtons( _stButton.fWidth - 53, 0, 53);
    pR6WindowCounter.SetDefaultValues( _iMinValue, _iMaxValue, _iDefaultValue);
	// tip of each button
	GetCounterTipLoc( _stButton.iButtonID, szLeftTip, szRightTip);
	pR6WindowCounter.SetButtonToolTip( szLeftTip, szRightTip);

	GeneralItem.m_pR6WindowCounter = pR6WindowCounter;
	GeneralItem.m_iItemID		   = _stButton.iButtonID;
}

//===============================================================================================================
// 
//===============================================================================================================
function ChangeButtonCounterValue( INT _iButtonID, INT _iNewValue, R6WindowListGeneral _pListToUse, optional BOOL _bNotAcceptClick)
{
    local R6WindowListGeneralItem TempItem;

	TempItem = R6WindowListGeneralItem(FindButtonItem( _iButtonID, _pListToUse));

	if ((TempItem != None) && (TempItem.m_pR6WindowCounter != None))
		{
			if (TempItem.m_pR6WindowCounter.m_iButtonID == _iButtonID)
			{
				TempItem.m_pR6WindowCounter.SetCounterValue( _iNewValue);
				TempItem.m_pR6WindowCounter.m_bNotAcceptClick= _bNotAcceptClick;
			}
		}
#ifdefDEBUG
	else
	{
		log("ChangeButtonCounterValue --> This button "@GetButtonLoc(_iButtonID)@"is not in the list");
	}
#endif
}

//===============================================================================================================
// 
//===============================================================================================================
function INT GetButtonCounterValue( INT _iButtonID, R6WindowListGeneral _pListToUse)
{
    local R6WindowListGeneralItem TempItem;

	TempItem = R6WindowListGeneralItem(FindButtonItem( _iButtonID, _pListToUse));

	if ((TempItem != None) && (TempItem.m_pR6WindowCounter != None))
	{
		if (TempItem.m_pR6WindowCounter.m_iButtonID == _iButtonID)
		{
//			log("CounterValue: "$R6WindowListGeneralItem(ListItem).m_pR6WindowCounter.m_iCounter);
			return TempItem.m_pR6WindowCounter.m_iCounter;
		}
	}

#ifdefDEBUG
	log("GetButtonCounterValue --> This button "@GetButtonLoc(_iButtonID)@"is not in the list");
#endif

	return -1;
}

//===============================================================================================================
// SetButtonCounterUnlimited: set a counter button to use unlimited value
//===============================================================================================================
function SetButtonCounterUnlimited( INT _iButtonID, BOOL _bUnlimitedCounterOnZero, R6WindowListGeneral _pListToUse)
{
    local R6WindowListGeneralItem TempItem;

	TempItem = R6WindowListGeneralItem(FindButtonItem( _iButtonID, _pListToUse));

	if ((TempItem != None) && (TempItem.m_pR6WindowCounter != None))
	{
		if (TempItem.m_pR6WindowCounter.m_iButtonID == _iButtonID)
		{
			TempItem.m_pR6WindowCounter.m_bUnlimitedCounterOnZero = _bUnlimitedCounterOnZero;
		}
	}
#ifdefDEBUG
	else
	{
		log("SetButtonCounterUnlimited --> This button "@GetButtonLoc(_iButtonID)@"is not in the list");
	}
#endif
}


//===================================================================================
//========================BUTTON BOX SECTION ========================================
//===================================================================================

//===============================================================
// AddButtonInt: Add a button with int values in a list
//===============================================================
function AddButtonBool( INT _iButtonID, BOOL _bInitialValue, R6WindowListGeneral _R6WindowListGeneral, optional UWindowWindow _OwnerWindow)
{
	local STButton stButtonTemp;
	local INT	   iInitialValue;

	if (m_fWidth == 0)
		m_fWidth = _R6WindowListGeneral.WinWidth;

	if (m_fHeight == 0)
		m_fHeight = _R6WindowListGeneral.WinHeight;

	stButtonTemp.szButtonName   = GetButtonLoc(_iButtonID); 
	stButtonTemp.szTip			= GetButtonLoc(_iButtonID, true);
	stButtonTemp.fWidth			= m_fWidth;
	stButtonTemp.fHeight		= m_fHeight;
	stButtonTemp.iButtonID		= _iButtonID;

	AddButtonBox( stButtonTemp, _bInitialValue, _R6WindowListGeneral, UWindowDialogClientWindow(_OwnerWindow));
}

//===============================================================================================================
// 
//===============================================================================================================
function AddButtonBox( STButton _stButton, bool _bSelected, R6WindowListGeneral _R6WindowListGeneral, UWindowDialogClientWindow _pParentWindow)
{
	local R6WindowButtonBox pR6WindowButtonBox;
	local R6WindowListGeneralItem GeneralItem;

	GeneralItem = R6WindowListGeneralItem(_R6WindowListGeneral.Items.Append(_R6WindowListGeneral.ListClass));
	pR6WindowButtonBox = R6WindowButtonBox(_pParentWindow.CreateControl( class'R6WindowButtonBox', 0, 0, _stButton.fWidth, _stButton.fHeight, _R6WindowListGeneral)); 
    pR6WindowButtonBox.m_TextFont = Root.Fonts[F_SmallTitle];
    pR6WindowButtonBox.m_vTextColor = Root.Colors.White;
    pR6WindowButtonBox.m_vBorder = Root.Colors.White;
    pR6WindowButtonBox.m_bSelected = _bSelected;
    pR6WindowButtonBox.CreateTextAndBox( _stButton.szButtonName, _stButton.szTip, 0, _stButton.iButtonID);

	GeneralItem.m_pR6WindowButtonBox = pR6WindowButtonBox;
	GeneralItem.m_iItemID		     = _stButton.iButtonID;
}

//===============================================================================================================
// ChangeButtonBoxValue: Change the value of the button box
//===============================================================================================================
function ChangeButtonBoxValue( INT _iButtonID, BOOL _bNewValue, R6WindowListGeneral _pListToUse, optional BOOL _bDisabled)
{
	local R6WindowListGeneralItem TempItem;

	TempItem = R6WindowListGeneralItem(FindButtonItem( _iButtonID, _pListToUse));

	if ((TempItem != None) && (TempItem.m_pR6WindowButtonBox != None))
    {
		TempItem.m_pR6WindowButtonBox.m_bSelected = _bNewValue;
		TempItem.m_pR6WindowButtonBox.bDisabled   = _bDisabled;

		if (_bDisabled)
			TempItem.m_pR6WindowButtonBox.m_szToolTipWhenDisable = GetButtonLoc(_iButtonID, false, eBLE_DisableToolTip);
    }
#ifdefDEBUG
	else
	{
		log("ChangeButtonBoxValue --> This button "@GetButtonLoc(_iButtonID)@"is not in the list");
	}
#endif
}

//===============================================================================================================
// GetButtonBoxValue: Get the value of a button box
//===============================================================================================================
function bool GetButtonBoxValue( INT _iButtonID, R6WindowListGeneral _pListToUse)
{
	local R6WindowListGeneralItem TempItem;

	TempItem = R6WindowListGeneralItem(FindButtonItem( _iButtonID, _pListToUse));

	if ((TempItem != None) && (TempItem.m_pR6WindowButtonBox != None))
	{
		return TempItem.m_pR6WindowButtonBox.m_bSelected;
	}

#ifdefDEBUG
	log("GetButtonBoxValue --> This button "@GetButtonLoc(_iButtonID)@"is not in the list");
#endif

	return false;
}

//===============================================================================================================
// IsButtonBoxDisabled: The button is disable?
//===============================================================================================================
function BOOL IsButtonBoxDisabled( INT _iButtonID, R6WindowListGeneral _pListToUse)
{
	local R6WindowListGeneralItem TempItem;

	TempItem = R6WindowListGeneralItem(FindButtonItem( _iButtonID, _pListToUse));

	if ((TempItem != None) && (TempItem.m_pR6WindowButtonBox != None))
    {
		return TempItem.m_pR6WindowButtonBox.bDisabled;
    }
#ifdefDEBUG
	else
	{
		log("IsButtonBoxDisabled --> This button "@GetButtonLoc(_iButtonID)@"is not in the list");
    }
#endif

	return false;
}

function AddFakeButton(R6WindowListGeneral _R6WindowListGeneral, optional UWindowWindow _OwnerWindow)
{
    local R6WindowListGeneralItem GeneralItem;

    GeneralItem = R6WindowListGeneralItem(_R6WindowListGeneral.Items.Append(_R6WindowListGeneral.ListClass));
    GeneralItem.m_bFakeItem = true;
    GeneralItem.m_iItemID = EButtonName.EBN_None;
}








function UWindowList FindButtonItem( INT _iButtonID, R6WindowListGeneral _pListToUse)
{
	local UWindowList ListItem;
    local R6WindowListGeneralItem TempItem;

    if ( _pListToUse != None)
    {
	    for ( ListItem = _pListToUse.Items.Next; ListItem != None ; ListItem = ListItem.Next)
	    {
            TempItem = R6WindowListGeneralItem(ListItem);
			if (TempItem.m_iItemID == _iButtonID)
		    {
			    break;
		    }
	    }
    }

	return ListItem;
}






//===============================================================================================================
// 
//===============================================================================================================
function AssociateButtons( INT _iButtonID1, INT _iButtonID2, INT _iAssociateButCase, R6WindowListGeneral _R6WindowListGeneral)
{
	// find the second button and associate it the first one 
	local UWindowList ListItem;
	local R6WindowListGeneralItem pItem1, pItem2;
    local R6WindowListGeneralItem TempItem;

	for ( ListItem = _R6WindowListGeneral.Items.Next; ListItem != None ; ListItem = ListItem.Next)
	{
        TempItem = R6WindowListGeneralItem(ListItem);

		if (TempItem.m_pR6WindowCounter != None)
		{
			if (TempItem.m_pR6WindowCounter.m_iButtonID == _iButtonID1)
			{
				pItem1 = TempItem;

				if ( pItem2 != None)
				{
					break;
				}
			}

			if (TempItem.m_pR6WindowCounter.m_iButtonID == _iButtonID2)
			{
				pItem2 = TempItem;

				if ( pItem1 != None)
				{
					break;
				}
			}
		}
	}

	if ( (pItem1 != None) && (pItem2 != None) )
	{
		pItem1.m_pR6WindowCounter.m_pAssociateButton  = pItem2.m_pR6WindowCounter;
		pItem1.m_pR6WindowCounter.m_iAssociateButCase = _iAssociateButCase;
	}
}

defaultproperties
{
}
