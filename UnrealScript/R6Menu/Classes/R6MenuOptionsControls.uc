//=============================================================================
//  R6MenuOptionsControls.uc : For mapping key, this class is specific, work with R6MenuOptionsTab
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/08/13 * Created by Yannick Joly
//============================================================================

class R6MenuOptionsControls extends R6MenuOptionsTab;

var int m_iKeyToAssign;

var R6WindowListControls m_pListControls;

var UWindowListBoxItem m_pCurItem;

var R6MenuOptionsMapKeys m_pOptControls;

var R6WindowPopUpBox m_pPopUpKeyBG;

var R6WindowPopUpBox m_pKeyMenuReAssignPopUp;

var string m_szOldActionKey;

function InitPageOptions()
{
    local float fXOffset, fYOffset;

    fXOffset = 0.0;
    fYOffset = 0.0;
    m_pListControls = R6WindowListControls(CreateControl(Class'R6Window.R6WindowListControls', fXOffset, fYOffset, WinWidth - fXOffset, (WinHeight - float(14)) - fYOffset, self));
    m_pListControls.m_fItemHeight = 15.0;
    m_pListControls.m_fXOffSet = 5.0;
    CreateKeyPopUp();
    AddTitleItem("", m_pListControls);
    AddTitleItem(Localize("Keys", "Title_Move", "R6Menu"), m_pListControls);
    AddKeyItem(Localize("Keys", "K_MoveForward", "R6Menu"), Localize("Keys", "K_MoveForward", "R6Menu"), "MoveForward", m_pListControls);
    AddKeyItem(Localize("Keys", "K_MoveBackward", "R6Menu"), Localize("Keys", "K_MoveBackward", "R6Menu"), "MoveBackward", m_pListControls);
    AddKeyItem(Localize("Keys", "K_StrafeLeft", "R6Menu"), Localize("Keys", "K_StrafeLeft", "R6Menu"), "StrafeLeft", m_pListControls);
    AddKeyItem(Localize("Keys", "K_StrafeRight", "R6Menu"), Localize("Keys", "K_StrafeRight", "R6Menu"), "StrafeRight", m_pListControls);
    AddKeyItem(Localize("Keys", "K_PeekLeft", "R6Menu"), Localize("Keys", "K_PeekLeft", "R6Menu"), "PeekLeft", m_pListControls);
    AddKeyItem(Localize("Keys", "K_PeekRight", "R6Menu"), Localize("Keys", "K_PeekRight", "R6Menu"), "PeekRight", m_pListControls);
    AddKeyItem(Localize("Keys", "K_RaisePosture", "R6Menu"), Localize("Keys", "K_RaisePosture", "R6Menu"), "RaisePosture", m_pListControls);
    AddKeyItem(Localize("Keys", "K_LowerPosture", "R6Menu"), Localize("Keys", "K_LowerPosture", "R6Menu"), "LowerPosture", m_pListControls);
    AddKeyItem(Localize("Keys", "K_Run", "R6Menu"), Localize("Keys", "K_Run", "R6Menu"), "Run", m_pListControls);
    AddKeyItem(Localize("Keys", "K_FluidPosture", "R6Menu"), Localize("Keys", "K_FluidPosture", "R6Menu"), "FluidPosture", m_pListControls);
    AddLineItem(m_pListControls);
    AddTitleItem(Localize("Keys", "Title_Weapon", "R6Menu"), m_pListControls);
    AddKeyItem(Localize("Keys", "K_Reload", "R6Menu"), Localize("Keys", "K_Reload", "R6Menu"), "Reload", m_pListControls);
    AddKeyItem(Localize("Keys", "K_PrimaryWeapon", "R6Menu"), Localize("Keys", "K_PrimaryWeapon", "R6Menu"), "PrimaryWeapon", m_pListControls);
    AddKeyItem(Localize("Keys", "K_SecondaryWeapon", "R6Menu"), Localize("Keys", "K_SecondaryWeapon", "R6Menu"), "SecondaryWeapon", m_pListControls);
    AddKeyItem(Localize("Keys", "K_GadgetOne", "R6Menu"), Localize("Keys", "K_GadgetOne", "R6Menu"), "GadgetOne", m_pListControls);
    AddKeyItem(Localize("Keys", "K_GadgetTwo", "R6Menu"), Localize("Keys", "K_GadgetTwo", "R6Menu"), "GadgetTwo", m_pListControls);
    AddKeyItem(Localize("Keys", "K_ChangeRateOfFire", "R6Menu"), Localize("Keys", "K_ChangeRateOfFire", "R6Menu"), "ChangeRateOfFire", m_pListControls);
    AddKeyItem(Localize("Keys", "K_PrimaryFire", "R6Menu"), Localize("Keys", "K_PrimaryFire", "R6Menu"), "PrimaryFire", m_pListControls);
    AddKeyItem(Localize("Keys", "K_SecondaryFire", "R6Menu"), Localize("Keys", "K_SecondaryFire", "R6Menu"), "SecondaryFire", m_pListControls);
    AddKeyItem(Localize("Keys", "K_Zoom", "R6Menu"), Localize("Keys", "K_Zoom", "R6Menu"), "Zoom", m_pListControls);
    AddKeyItem(Localize("Keys", "K_InventoryMenu", "R6Menu"), Localize("Keys", "K_InventoryMenu", "R6Menu"), "InventoryMenu", m_pListControls);
    AddLineItem(m_pListControls);
    AddTitleItem(Localize("Keys", "Title_Orders", "R6Menu"), m_pListControls);
    AddKeyItem(Localize("Keys", "K_GoCodeAlpha", "R6Menu"), Localize("Keys", "K_GoCodeAlpha", "R6Menu"), "GoCodeAlpha", m_pListControls);
    AddKeyItem(Localize("Keys", "K_GoCodeBravo", "R6Menu"), Localize("Keys", "K_GoCodeBravo", "R6Menu"), "GoCodeBravo", m_pListControls);
    AddKeyItem(Localize("Keys", "K_GoCodeCharlie", "R6Menu"), Localize("Keys", "K_GoCodeCharlie", "R6Menu"), "GoCodeCharlie", m_pListControls);
    AddKeyItem(Localize("Keys", "K_GoCodeZulu", "R6Menu"), Localize("Keys", "K_GoCodeZulu", "R6Menu"), "GoCodeZulu", m_pListControls);
    AddKeyItem(Localize("Keys", "K_RulesOfEngagement", "R6Menu"), Localize("Keys", "K_RulesOfEngagement", "R6Menu"), "RulesOfEngagement", m_pListControls);
    AddKeyItem(Localize("Keys", "K_SkipDestination", "R6Menu"), Localize("Keys", "K_SkipDestination", "R6Menu"), "SkipDestination", m_pListControls);
    AddKeyItem(Localize("Keys", "K_ToggleAllTeamsHold", "R6Menu"), Localize("Keys", "K_ToggleAllTeamsHold", "R6Menu"), "ToggleAllTeamsHold", m_pListControls);
    AddKeyItem(Localize("Keys", "K_ToggleTeamHold", "R6Menu"), Localize("Keys", "K_ToggleTeamHold", "R6Menu"), "ToggleTeamHold", m_pListControls);
    AddKeyItem(Localize("Keys", "K_ToggleSniperControl", "R6Menu"), Localize("Keys", "K_ToggleSniperControl", "R6Menu"), "ToggleSniperControl", m_pListControls);
    AddLineItem(m_pListControls);
    AddTitleItem(Localize("Keys", "Title_Actions", "R6Menu"), m_pListControls);
    AddKeyItem(Localize("Keys", "K_GraduallyOpenDoor", "R6Menu"), Localize("Keys", "K_GraduallyOpenDoor", "R6Menu"), "GraduallyOpenDoor", m_pListControls);
    AddKeyItem(Localize("Keys", "K_GraduallyCloseDoor", "R6Menu"), Localize("Keys", "K_GraduallyCloseDoor", "R6Menu"), "GraduallyCloseDoor", m_pListControls);
    AddKeyItem(Localize("Keys", "K_SpeedUpDoor", "R6Menu"), Localize("Keys", "K_SpeedUpDoor", "R6Menu"), "SpeedUpDoor", m_pListControls);
    AddKeyItem(Localize("Keys", "K_Action", "R6Menu"), Localize("Keys", "K_Action", "R6Menu"), "Action", m_pListControls);
    AddKeyItem(Localize("Keys", "K_ToggleNightVision", "R6Menu"), Localize("Keys", "K_ToggleNightVision", "R6Menu"), "ToggleNightVision", m_pListControls);
    AddKeyItem(Localize("Keys", "K_NextTeam", "R6Menu"), Localize("Keys", "K_NextTeam", "R6Menu"), "NextTeam", m_pListControls);
    AddKeyItem(Localize("Keys", "K_PreviousTeam", "R6Menu"), Localize("Keys", "K_PreviousTeam", "R6Menu"), "PreviousTeam", m_pListControls);
    AddKeyItem(Localize("Keys", "K_NextMember", "R6Menu"), Localize("Keys", "K_NextMember", "R6Menu"), "NextMember", m_pListControls);
    AddKeyItem(Localize("Keys", "K_PreviousMember", "R6Menu"), Localize("Keys", "K_PreviousMember", "R6Menu"), "PreviousMember", m_pListControls);
    AddKeyItem(Localize("Keys", "K_ToggleMap", "R6Menu"), Localize("Keys", "K_ToggleMap", "R6Menu"), "ToggleMap", m_pListControls);
    AddKeyItem(Localize("Keys", "K_MapZoomIn", "R6Menu"), Localize("Keys", "K_MapZoomIn", "R6Menu"), "MapZoomIn", m_pListControls);
    AddKeyItem(Localize("Keys", "K_MapZoomOut", "R6Menu"), Localize("Keys", "K_MapZoomOut", "R6Menu"), "MapZoomOut", m_pListControls);
    AddKeyItem(Localize("Keys", "K_OperativeSelector", "R6Menu"), Localize("Keys", "K_OperativeSelector", "R6Menu"), "OperativeSelector", m_pListControls);
    AddLineItem(m_pListControls);
    AddTitleItem(Localize("Keys", "Title_MP", "R6Menu"), m_pListControls);
    AddKeyItem(Localize("Keys", "K_ToggleGameStats", "R6Menu"), Localize("Keys", "K_ToggleGameStats", "R6Menu"), "ToggleGameStats", m_pListControls);
    AddKeyItem(Localize("Keys", "K_Talk", "R6Menu"), Localize("Keys", "K_Talk", "R6Menu"), "Talk", m_pListControls);
    AddKeyItem(Localize("Keys", "K_TeamTalk", "R6Menu"), Localize("Keys", "K_TeamTalk", "R6Menu"), "TeamTalk", m_pListControls);
    AddKeyItem(Localize("Keys", "K_DrawingTool", "R6Menu"), Localize("Keys", "K_DrawingTool", "R6Menu"), "DrawingTool", m_pListControls);
    AddKeyItem(Localize("Keys", "K_PreRecMessages", "R6Menu"), Localize("Keys", "K_PreRecMessages", "R6Menu"), "PreRecMessages", m_pListControls);
    AddKeyItem(Localize("Keys", "K_VotingMenu", "R6Menu"), Localize("Keys", "K_VotingMenu", "R6Menu"), "VotingMenu", m_pListControls);
    AddLineItem(m_pListControls);
    AddTitleItem(Localize("Keys", "Title_Others", "R6Menu"), m_pListControls);
    AddKeyItem(Localize("Keys", "K_Console", "R6Menu"), Localize("Keys", "K_Console", "R6Menu"), "Console", m_pListControls);
    AddKeyItem(Localize("Keys", "K_ToggleAutoAim", "R6Menu"), Localize("Keys", "K_ToggleAutoAim", "R6Menu"), "ToggleAutoAim", m_pListControls);
    AddKeyItem(Localize("Keys", "K_Shot", "R6Menu"), Localize("Keys", "K_Shot", "R6Menu"), "Shot", m_pListControls);
    AddKeyItem(Localize("Keys", "K_ShowCompleteHud", "R6Menu"), Localize("Keys", "K_ShowCompleteHud", "R6Menu"), "ShowCompleteHud", m_pListControls);
    AddLineItem(m_pListControls);
    AddTitleItem(Localize("Keys", "Title_Planning", "R6Menu"), m_pListControls);
    AddKeyItem(Localize("Keys", "K_MoveUp", "R6Menu"), Localize("Keys", "K_MoveUp", "R6Menu"), "MoveUp", m_pListControls, true);
    AddKeyItem(Localize("Keys", "K_MoveDown", "R6Menu"), Localize("Keys", "K_MoveDown", "R6Menu"), "MoveDown", m_pListControls, true);
    AddKeyItem(Localize("Keys", "K_MoveLeft", "R6Menu"), Localize("Keys", "K_MoveLeft", "R6Menu"), "MoveLeft", m_pListControls, true);
    AddKeyItem(Localize("Keys", "K_MoveRight", "R6Menu"), Localize("Keys", "K_MoveRight", "R6Menu"), "MoveRight", m_pListControls, true);
    AddKeyItem(Localize("Keys", "K_ZoomIn", "R6Menu"), Localize("Keys", "K_ZoomIn", "R6Menu"), "ZoomIn", m_pListControls, true);
    AddKeyItem(Localize("Keys", "K_ZoomOut", "R6Menu"), Localize("Keys", "K_ZoomOut", "R6Menu"), "ZoomOut", m_pListControls, true);
    AddKeyItem(Localize("Keys", "K_LevelUp", "R6Menu"), Localize("Keys", "K_LevelUp", "R6Menu"), "LevelUp", m_pListControls, true);
    AddKeyItem(Localize("Keys", "K_LevelDown", "R6Menu"), Localize("Keys", "K_LevelDown", "R6Menu"), "LevelDown", m_pListControls, true);
    AddKeyItem(Localize("Keys", "K_RotateClockWise", "R6Menu"), Localize("Keys", "K_RotateClockWise", "R6Menu"), "RotateClockWise", m_pListControls, true);
    AddKeyItem(Localize("Keys", "K_RotateCounterClockWise", "R6Menu"), Localize("Keys", "K_RotateCounterClockWise", "R6Menu"), "RotateCounterClockWise", m_pListControls, true);
    AddKeyItem(Localize("Keys", "K_DeleteWaypoint", "R6Menu"), Localize("Keys", "K_DeleteWaypoint", "R6Menu"), "DeleteWaypoint", m_pListControls, true);
    AddKeyItem(Localize("Keys", "K_NextWaypoint", "R6Menu"), Localize("Keys", "K_NextWaypoint", "R6Menu"), "NextWaypoint", m_pListControls, true);
    AddKeyItem(Localize("Keys", "K_PrevWaypoint", "R6Menu"), Localize("Keys", "K_PrevWaypoint", "R6Menu"), "PrevWaypoint", m_pListControls, true);
    AddKeyItem(Localize("Keys", "K_FirstWaypoint", "R6Menu"), Localize("Keys", "K_FirstWaypoint", "R6Menu"), "FirstWaypoint", m_pListControls, true);
    AddKeyItem(Localize("Keys", "K_LastWaypoint", "R6Menu"), Localize("Keys", "K_LastWaypoint", "R6Menu"), "LastWaypoint", m_pListControls, true);
    AddKeyItem(Localize("Keys", "K_AngleUp", "R6Menu"), Localize("Keys", "K_AngleUp", "R6Menu"), "AngleUp", m_pListControls, true);
    AddKeyItem(Localize("Keys", "K_AngleDown", "R6Menu"), Localize("Keys", "K_AngleDown", "R6Menu"), "AngleDown", m_pListControls, true);
    AddKeyItem(Localize("Keys", "K_RedTeam", "R6Menu"), Localize("Keys", "K_RedTeam", "R6Menu"), "SwitchToRedTeam", m_pListControls, true);
    AddKeyItem(Localize("Keys", "K_GreenTeam", "R6Menu"), Localize("Keys", "K_GreenTeam", "R6Menu"), "SwitchToGreenTeam", m_pListControls, true);
    AddKeyItem(Localize("Keys", "K_GoldTeam", "R6Menu"), Localize("Keys", "K_GoldTeam", "R6Menu"), "SwitchToGoldTeam", m_pListControls, true);
    AddKeyItem(Localize("Keys", "K_ViewRed", "R6Menu"), Localize("Keys", "K_ViewRed", "R6Menu"), "ViewRedTeam", m_pListControls, true);
    AddKeyItem(Localize("Keys", "K_ViewGreen", "R6Menu"), Localize("Keys", "K_ViewGreen", "R6Menu"), "ViewGreenTeam", m_pListControls, true);
    AddKeyItem(Localize("Keys", "K_ViewGold", "R6Menu"), Localize("Keys", "K_ViewGold", "R6Menu"), "ViewGoldTeam", m_pListControls, true);
    InitResetButton();
    m_bInitComplete = true;
}

//===============================================================================
// AddLineItem: add a line item in the list
//===============================================================================
function AddLineItem( R6WindowListControls _pR6WindowListControls)
{
	local UWindowListBoxItem NewItem;

    NewItem = UWindowListBoxItem(_pR6WindowListControls.Items.Append(_pR6WindowListControls.ListClass));
    NewItem.HelpText				= "";
	NewItem.m_bImALine				= true;
	NewItem.m_vItemColor			= Root.Colors.White;
	NewItem.m_bNotAffectByNotify	= true;
}

//===============================================================================
// AddTitleItem: Add a title item only
//===============================================================================
function AddTitleItem( string _szTitle, R6WindowListControls _pR6WindowListControls)
{
	local UWindowListBoxItem NewItem;

    NewItem = UWindowListBoxItem(_pR6WindowListControls.Items.Append(_pR6WindowListControls.ListClass));
    NewItem.HelpText				= _szTitle;
	NewItem.m_vItemColor			= Root.Colors.White;
	NewItem.m_bNotAffectByNotify	= true;
}

//===============================================================================
// AddKeyItem: Add a key item
//===============================================================================
function AddKeyItem( string _szTitle, string _szToolTip, string _szActionKey, R6WindowListControls _pR6WindowListControls, optional BOOL _bPlanningInput)
{
	local UWindowListBoxItem NewItem;

    NewItem = UWindowListBoxItem(_pR6WindowListControls.Items.Append(_pR6WindowListControls.ListClass));
    NewItem.HelpText				= _szTitle;
	NewItem.m_szToolTip				= _szToolTip;
	NewItem.m_vItemColor			= Root.Colors.White;
	NewItem.m_szActionKey			= _szActionKey;

	NewItem.m_szFakeEditBoxValue	= GetLocKeyNameByActionKey( _szActionKey, _bPlanningInput); // value to display "the key name"
	
	NewItem.m_fXFakeEditBox			= 220;
	NewItem.m_fWFakeEditBox			= WinWidth - NewItem.m_fXFakeEditBox - 40; // 40 is the space between the end of the fake edit box and the scroll bar

	if (_bPlanningInput)
		NewItem.m_iItemID			= 1; // PLANNING INPUT
	else
		NewItem.m_iItemID			= 0; // GAME INPUT
}

function UpdateOptionsInPage()
{
    local UWindowList ListItem;
    local string szTemp;


    for(ListItem = m_pListControls.Items.Next; ListItem != none; ListItem = ListItem.Next)
    {
        if(!UWindowListBoxItem(ListItem).m_bNotAffectByNotify)
        {
            if(UWindowListBoxItem(ListItem).m_iItemID == 0)
            {
                UWindowListBoxItem(ListItem).m_szFakeEditBoxValue = GetLocKeyNameByActionKey(UWindowListBoxItem(ListItem).m_szActionKey, false);                
            }
            else
            {
                UWindowListBoxItem(ListItem).m_szFakeEditBoxValue = GetLocKeyNameByActionKey(UWindowListBoxItem(ListItem).m_szActionKey, true);
            }
        }
    }
}

//===============================================================================
// GetLocKeyNameByActionKey: Get the localization name of the key to display
//===============================================================================
function string GetLocKeyNameByActionKey( string _szActionKey, optional BOOL _bPlanningInput)
{
	local string szTemp;
	local BYTE Key;

	Key = GetPlayerOwner().GetKey(_szActionKey, _bPlanningInput);
	szTemp = GetPlayerOwner().GetEnumName( Key, _bPlanningInput);
	szTemp = GetPlayerOwner().Player.Console.ConvertKeyToLocalisation( Key, szTemp);

	return szTemp;
}

function CreateKeyPopUp()
{
    local R6WindowTextLabelExt pR6TextLabelExt;
	local FLOAT fPopUpWidth;

	fPopUpWidth = 380;

	// Create Map Key PopUp
	m_pPopUpKeyBG = R6WindowPopUpBox( OwnerWindow.CreateWindow( class'R6WindowPopUpBox', 0, 0, OwnerWindow.WinWidth, OwnerWindow.WinHeight, self));
	m_pPopUpKeyBG.CreatePopUpFrameWindow( Localize("Options", "Opt_ControlsMapKey", "R6Menu"), 30, 130, 150, fPopUpWidth, 70);
	m_pPopUpKeyBG.CreateClientWindow( class'R6WindowTextLabelExt');
	m_pPopUpKeyBG.m_bForceButtonLine = true;
	pR6TextLabelExt = R6WindowTextLabelExt(m_pPopUpKeyBG.m_ClientArea);
	pR6TextLabelExt.SetNoBorder();
	// text part
	pR6TextLabelExt.m_Font = Root.Fonts[F_SmallTitle]; 
	pR6TextLabelExt.m_vTextColor = Root.Colors.White;
	pR6TextLabelExt.AddTextLabel( "", 0, 3, fPopUpWidth, TA_Center, false);
	pR6TextLabelExt.AddTextLabel( "", 0, 15, fPopUpWidth, TA_Center, false);
	pR6TextLabelExt.AddTextLabel( Localize("Options", "Key_Map", "R6Menu"), 0, 27, fPopUpWidth, TA_Center, false);

	m_pPopUpKeyBG.Close();

    // Create Reassign PopUp
    m_pKeyMenuReAssignPopUp = R6WindowPopUpBox( OwnerWindow.CreateWindow( class'R6WindowPopUpBox', 0, 0, OwnerWindow.WinWidth, OwnerWindow.WinHeight, self));
    m_pKeyMenuReAssignPopUp.CreatePopUpFrameWindow( Localize("Options", "Opt_ControlsReMapKey", "R6Menu"), 30, 140, 150, fPopUpWidth, 70);
    m_pKeyMenuReAssignPopUp.CreateClientWindow( class'R6WindowTextLabelExt');
	m_pKeyMenuReAssignPopUp.m_bForceButtonLine = true;
    pR6TextLabelExt = R6WindowTextLabelExt(m_pKeyMenuReAssignPopUp.m_ClientArea);
	pR6TextLabelExt.SetNoBorder();
	// text part
	pR6TextLabelExt.m_Font = Root.Fonts[F_SmallTitle]; 
	pR6TextLabelExt.m_vTextColor = Root.Colors.White;
	pR6TextLabelExt.AddTextLabel( "", 0, 3, fPopUpWidth, TA_Center, false);
	pR6TextLabelExt.AddTextLabel( Localize("Options", "Key_Press", "R6Menu"), 0, 27, fPopUpWidth, TA_Center, false);

	m_pKeyMenuReAssignPopUp.Close();
}

function ManagePopUpKey(UWindowDialogControl C)
{
    local R6WindowTextLabelExt pR6TextLabelExt;

    m_pCurItem = R6WindowListControls(C).GetSelectedItem();
    if(!m_pCurItem.m_bNotAffectByNotify)
    {
        pR6TextLabelExt = R6WindowTextLabelExt(m_pPopUpKeyBG.m_ClientArea);
        if((GetCurKeyName()) == "")
        {
            pR6TextLabelExt.ChangeTextLabel((((m_pCurItem.HelpText $ " ") $ (Localize("Options", "Key_Advice", "R6Menu"))) $ " ") $ (Localize("Options", "Key_Nothing", "R6Menu")), 0);
            pR6TextLabelExt.ChangeTextLabel(" ", 1);            
        }
        else
        {
            pR6TextLabelExt.ChangeTextLabel((m_pCurItem.HelpText $ " ") $ (Localize("Options", "Key_Advice", "R6Menu")), 0);
            pR6TextLabelExt.ChangeTextLabel(GetCurKeyName(), 1);
        }
        m_pPopUpKeyBG.ShowWindow();
        m_pOptControls = R6MenuOptionsMapKeys(OwnerWindow.CreateWindow(Class'R6Menu.R6MenuOptionsMapKeys', 0.0, 0.0, OwnerWindow.WinWidth, OwnerWindow.WinHeight, self, true));
        m_pOptControls.Register(self);
    }
}

function CloseAllKeyPopUp( optional BOOL _bCloseKeyControlTo)
{
	if (m_pPopUpKeyBG.bWindowVisible)
	{
		m_pPopUpKeyBG.Close();
	}
	else if (m_pKeyMenuReAssignPopUp.bWindowVisible)
	{
		m_pKeyMenuReAssignPopUp.Close();
	}

	if (_bCloseKeyControlTo)
	{
		m_pOptControls.HideWindow();
	}
}

function UWindowListBoxItem GetCurrentKeyItem()
{
	return m_pCurItem;
}

function string GetCurActionKey()
{
	return GetCurrentKeyItem().m_szActionKey;
}

function string GetCurKeyName()
{
	return GetCurrentKeyItem().m_szFakeEditBoxValue;
}

function INT GetCurKeyInputClass()
{
	return GetCurrentKeyItem().m_iItemID;
}

function RefreshKeyItem( string _szNewKeyValue)
{
	local UWindowListBoxItem pItem;
	pItem = m_pListControls.GetSelectedItem();

	if ( pItem != None)
	{
		pItem.m_szFakeEditBoxValue = _szNewKeyValue;
	}
}

function KeyPressed(int Key)
{
    local R6WindowTextLabelExt pR6TextLabelExt;
    local string szTemp, szKeyName;
    local bool bUpdate, bPlanningInput;

    if((GetCurKeyInputClass()) == 1)
    {
        bPlanningInput = true;
    }
    if(m_iKeyToAssign != -1)
    {
        bUpdate = true;        
    }
    else
    {
        if(!IsKeyValid(Key))
        {
            CloseAllKeyPopUp(true);
            Root.SimplePopUp(Localize("Options", "Key_Invalid_Title", "R6Menu"), Localize("Options", "Key_Invalid", "R6Menu"), EPopUpID_None, MessageBoxButtons.MB_OK, false, self);
            return;
        }
        m_szOldActionKey = GetPlayerOwner().GetActionKey(byte(Key), bPlanningInput);
        szTemp = Localize("Keys", "K_" $ m_szOldActionKey, "R6Menu", true);
        m_iKeyToAssign = Key;
        if((m_szOldActionKey != "") && szTemp != "")
        {
            szKeyName = GetPlayerOwner().Player.Console.ConvertKeyToLocalisation(byte(m_iKeyToAssign), GetPlayerOwner().GetEnumName(byte(m_iKeyToAssign), bPlanningInput));
            pR6TextLabelExt = R6WindowTextLabelExt(m_pKeyMenuReAssignPopUp.m_ClientArea);
            pR6TextLabelExt.ChangeTextLabel((((szKeyName $ " ") $ (Localize("Options", "Key_Assign", "R6Menu"))) $ " ") $ (Localize("Keys", "K_" $ m_szOldActionKey, "R6Menu")), 0);
            m_pKeyMenuReAssignPopUp.ShowWindow();
            m_pOptControls.ShowWindow();            
        }
        else
        {
            bUpdate = true;
        }
    }
    if(bUpdate)
    {
        szTemp = "INPUT";
        if(bPlanningInput)
        {
            szTemp = "INPUTPLANNING";
        }
        szKeyName = GetPlayerOwner().GetEnumName(byte(m_iKeyToAssign), bPlanningInput);
        GetPlayerOwner().SetKey((szTemp @ szKeyName) @ (GetCurActionKey()));
        UpdateOptionsInPage();
        m_szOldActionKey = "";
        m_iKeyToAssign = -1;
    }
}

//=======================================================================================
// IsKeyValid: Check is the key is valid -- ex windows key, pop-up key are not valid for mapping controls
//=======================================================================================
function BOOL IsKeyValid( INT _Key)
{
	local BOOL bValidKey;

	bValidKey = true;

	switch( _Key)
	{
		case Root.Console.EInputKey.IK_Unknown5B: // LEFT WINDOW KEY
		case Root.Console.EInputKey.IK_Unknown5C: // RIGHT WINDOW KEY
		case Root.Console.EInputKey.IK_Unknown5D: // POP-UP WINDOW KEY
			bValidKey = false;
			break;
		case Root.Console.EInputKey.IK_LeftMouse:
			// check if you're mapping the console
			if (GetCurKeyInputClass() != 1) // we're are not in planning
			{
				if (GetCurActionKey() == "Console") // it's the console?
				{
					bValidKey = false;
				}
			}
			break;
		// IK_MouseWheelDown and IK_MouseWheelUp have some problem with Aliases buttons. A press and a release
		// are send in the same frame and the state of the button never change (always erase by the release)
		case Root.Console.EInputKey.IK_MouseWheelDown:
		case Root.Console.EInputKey.IK_MouseWheelUp:
			if (GetCurKeyInputClass() == 1)
			{
				switch(GetCurActionKey())
				{
					case "MoveUp":
					case "MoveDown":
					case "MoveLeft":
					case "MoveRight":
					case "ZoomIn":
					case "ZoomOut":
					case "LevelUp":
					case "LevelDown":
					case "RotateClockWise":
					case "RotateCounterClockWise":
					case "AngleUp":
					case "AngleDown":
						bValidKey = false;
						break;
				}
			}
			else
			{
				switch(GetCurActionKey())
				{
					case "PrimaryFire":
					case "SecondaryFire":
					case "Reload":
					case "Run":
					case "SpeedUpDoor":
					case "FluidPosture":
					case "PeekLeft":
					case "PeekRight":
					case "MoveForward":
					case "RunForward":
					case "MoveBackward":
					case "StrafeLeft":
					case "StrafeRight":
					case "TurningX":
					case "TurningY":
						bValidKey = false;
						break;
				}
			}
			break;
		default:
			bValidKey = true;
			break;
	}

	return bValidKey;
}

function RestoreDefaultValue()
{
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    GetPlayerOwner().ResetKeyboard();
    UpdateOptionsInPage();
}

function Notify(UWindowDialogControl C, byte E)
{
    local R6MenuOptionsWidget OptionsWidget;
    local bool bUpdateGameOptions;
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    OptionsWidget = R6MenuOptionsWidget(OwnerWindow);
    if(E == DE_Click)
    {
        if(C.IsA('R6WindowButton'))
        {
            if(C == m_pGeneralButUse)
            {
                if(C == m_pGeneralButUse)
                {
                    Root.SimplePopUp(Localize("Options", "ResetToDefault", "R6Menu"), Localize("Options", "ResetToDefaultConfirm", "R6Menu"), EPopUpID_OptionsResetDefault, 0, false, self);
                }                
            }
            else
            {
                m_iKeyToAssign = -1;
                CloseAllKeyPopUp(true);
            }            
        }
        else
        {
            if(C.IsA('R6WindowListControls'))
            {
                ManagePopUpKey(C);                
            }
            else
            {
                if(C.IsA('R6MenuOptionsMapKeys'))
                {
                    CloseAllKeyPopUp(true);
                    if(m_pOptControls.m_iLastKeyPressed == GetPlayerOwner().Player.Console.EInputKey.IK_Escape)
                    {
                        m_iKeyToAssign = -1;                        
                    }
                    else
                    {
                        KeyPressed(m_pOptControls.m_iLastKeyPressed);
                    }
                }
            }
        }
    }
}

defaultproperties
{
     m_iKeyToAssign=-1
}
