//=============================================================================
//  R6MenuListActionTypeButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/22 * Created by Chaouky Garram
//=============================================================================

class R6MenuListActionTypeButton extends R6MenuPopupListButton;

var R6MenuActionMenu        m_WinAction;
var bool    m_bAutoSelect;

function Created()
{
    Super.Created();

    m_FontForButtons=Root.Fonts[F_HelpWindow];

    m_fItemHeight = R6MenuRSLookAndFeel(LookAndFeel).m_BLTitleL.Up.H;
    //---------------------------------------------
    m_ButtonItem[EPlanActionType.PACTTYP_Normal] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuActionTypeButtonItem(m_ButtonItem[EPlanActionType.PACTTYP_Normal]).m_eActionType = PACTTYP_Normal;
    m_ButtonItem[EPlanActionType.PACTTYP_Normal].m_Button = R6WindowButton(CreateWindow( class'R6MenuPopUpStayDownButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[EPlanActionType.PACTTYP_Normal].m_Button.SetText( Localize("Order","Type_Normal","R6Menu"));
    R6MenuPopUpStayDownButton(m_ButtonItem[EPlanActionType.PACTTYP_Normal].m_Button).m_bSubMenu=true;
    m_ButtonItem[EPlanActionType.PACTTYP_Normal].m_Button.m_buttonFont=m_FontForButtons;
    //---------------------------------------------
    m_ButtonItem[EPlanActionType.PACTTYP_Milestone] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuActionTypeButtonItem(m_ButtonItem[EPlanActionType.PACTTYP_Milestone]).m_eActionType = PACTTYP_Milestone;
    m_ButtonItem[EPlanActionType.PACTTYP_Milestone].m_Button = R6WindowButton(CreateWindow( class'R6MenuPopUpStayDownButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[EPlanActionType.PACTTYP_Milestone].m_Button.SetText( Localize("Order","Type_Milestone","R6Menu"));
    R6MenuPopUpStayDownButton(m_ButtonItem[EPlanActionType.PACTTYP_Milestone].m_Button).m_bSubMenu=true;
    m_ButtonItem[EPlanActionType.PACTTYP_Milestone].m_Button.m_buttonFont=m_FontForButtons;
    //---------------------------------------------
    m_ButtonItem[EPlanActionType.PACTTYP_GoCodeA] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuActionTypeButtonItem(m_ButtonItem[EPlanActionType.PACTTYP_GoCodeA]).m_eActionType = PACTTYP_GoCodeA;
    m_ButtonItem[EPlanActionType.PACTTYP_GoCodeA].m_Button = R6WindowButton(CreateWindow( class'R6MenuPopUpStayDownButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[EPlanActionType.PACTTYP_GoCodeA].m_Button.SetText( Localize("Order","Type_GoCode_Alpha","R6Menu"));
    R6MenuPopUpStayDownButton(m_ButtonItem[EPlanActionType.PACTTYP_GoCodeA].m_Button).m_bSubMenu=true;
    m_ButtonItem[EPlanActionType.PACTTYP_GoCodeA].m_Button.m_buttonFont=m_FontForButtons;
    //---------------------------------------------
    m_ButtonItem[EPlanActionType.PACTTYP_GoCodeB] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuActionTypeButtonItem(m_ButtonItem[EPlanActionType.PACTTYP_GoCodeB]).m_eActionType = PACTTYP_GoCodeB;
    m_ButtonItem[EPlanActionType.PACTTYP_GoCodeB].m_Button = R6WindowButton(CreateWindow( class'R6MenuPopUpStayDownButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[EPlanActionType.PACTTYP_GoCodeB].m_Button.SetText( Localize("Order","Type_GoCode_Bravo","R6Menu"));
    R6MenuPopUpStayDownButton(m_ButtonItem[EPlanActionType.PACTTYP_GoCodeB].m_Button).m_bSubMenu=true;
    m_ButtonItem[EPlanActionType.PACTTYP_GoCodeB].m_Button.m_buttonFont=m_FontForButtons;
    //---------------------------------------------
    m_ButtonItem[EPlanActionType.PACTTYP_GoCodeC] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuActionTypeButtonItem(m_ButtonItem[EPlanActionType.PACTTYP_GoCodeC]).m_eActionType = PACTTYP_GoCodeC;
    m_ButtonItem[EPlanActionType.PACTTYP_GoCodeC].m_Button = R6WindowButton(CreateWindow( class'R6MenuPopUpStayDownButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[EPlanActionType.PACTTYP_GoCodeC].m_Button.SetText( Localize("Order","Type_GoCode_Charlie","R6Menu"));
    R6MenuPopUpStayDownButton(m_ButtonItem[EPlanActionType.PACTTYP_GoCodeC].m_Button).m_bSubMenu=true;
    m_ButtonItem[EPlanActionType.PACTTYP_GoCodeC].m_Button.m_buttonFont=m_FontForButtons;
    //---------------------------------------------
    m_ButtonItem[EPlanActionType.PACTTYP_Delete] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuActionTypeButtonItem(m_ButtonItem[EPlanActionType.PACTTYP_Delete]).m_eActionType = PACTTYP_Delete;
    m_ButtonItem[EPlanActionType.PACTTYP_Delete].m_Button = R6WindowButton(CreateWindow( class'R6MenuPopUpStayDownButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[EPlanActionType.PACTTYP_Delete].m_Button.SetText( Localize("Order","Type_Delete","R6Menu"));
    m_ButtonItem[EPlanActionType.PACTTYP_Delete].m_Button.m_buttonFont=m_FontForButtons;
}

function SetSelectedItem(UWindowListBoxItem NewSelected)
{
    local R6PlanningInfo    Planning;

    Planning = R6PlanningCtrl(GetPlayerOwner()).m_pTeamInfo[R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam];
    
    HidePopup();

    Super.SetSelectedItem( NewSelected);

    if(m_bAutoSelect != true)
    {
        if(R6MenuActionTypeButtonItem(m_SelectedItem).m_eActionType == PACTTYP_Delete)
        {
            Planning.DeleteNode();
#ifndefMPDEMO            
            R6MenuRootWindow(Root).m_PlanningWidget.m_bClosePopup = true;
#endif
        }
        else
        {
            Planning.SetActionType(R6MenuActionTypeButtonItem(m_SelectedItem).m_eActionType);
            ShowPopup();
        }
    }
}

function DisplayMilestoneButton()
{
    local BOOL bDoIDisplay;
        
    bDoIDisplay = R6PlanningCtrl(GetPlayerOwner()).m_pTeamInfo[R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam].m_iNbMilestone < 9 ;

    R6MenuActionTypeButtonItem(m_ButtonItem[EPlanActionType.PACTTYP_Milestone]).m_Button.bDisabled=!bDoIDisplay;
}

function HidePopup()
{
    if(m_WinAction!=None)
    {
        m_WinAction.HideWindow();
    }
}

function ShowWindow()
{
    local EPlanActionType   eType;

    eType = R6PlanningCtrl(GetPlayerOwner()).GetCurrentActionType();

    Super.ShowWindow();

    m_bAutoSelect=true;
    if(m_ButtonItem[eType] != m_SelectedItem)
    {
        SetSelectedItem(m_ButtonItem[eType]);
    }
    m_bAutoSelect=false;
}

function ShowPopup()
{
    local FLOAT fGlobalLeft, fGlobalTop;
    
    WindowToGlobal(ParentWindow.WinLeft, ParentWindow.WinTop, fGlobalLeft, fGlobalTop);
    fGlobalLeft = ParentWindow.WinLeft + ParentWindow.WinWidth;

#ifndefMPDEMO
    if(m_WinAction==None)
    {
        m_WinAction = R6MenuActionMenu(R6MenuRootWindow(Root).m_PlanningWidget.CreateWindow(class'R6MenuActionMenu', fGlobalLeft, ParentWindow.WinTop, 150, 100, OwnerWindow));
    }
    else
    {
#endif
        m_WinAction.WinLeft = fGlobalLeft;
        m_WinAction.WinTop  = ParentWindow.WinTop;
        m_WinAction.ShowWindow();
#ifndefMPDEMO
    }
#endif
    // display sniping only on go codes
    R6MenuListActionButton(m_WinAction.m_ButtonList).DisplaySnipeButton(R6MenuActionTypeButtonItem(m_SelectedItem).m_eActionType > PACTTYP_Milestone);
    // display breach door only on go codes and when a door is close
    R6MenuListActionButton(m_WinAction.m_ButtonList).DisplayBreachDoor(R6PlanningCtrl(GetPlayerOwner()).GetCurrentPoint().m_bDoorInRange);

    m_WinAction.AjustPosition(R6MenuFramePopup(OwnerWindow).m_bDisplayUp, R6MenuFramePopup(OwnerWindow).m_bDisplayLeft);
    if(R6MenuFramePopup(ParentWindow).m_bDisplayLeft == true)
    {
        m_WinAction.WinLeft -= (ParentWindow.WinWidth - 6);
    }
    if(R6MenuFramePopup(ParentWindow).m_bDisplayUp == true)
    {
        m_WinAction.WinTop -= (m_WinAction.WinHeight - ParentWindow.WinHeight);
    }
}

defaultproperties
{
     m_iNbButton=6
     ListClass=Class'R6Menu.R6MenuActionTypeButtonItem'
}
