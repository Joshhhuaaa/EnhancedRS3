//=============================================================================
//  R6MenuListActionButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6MenuListActionButton extends R6MenuPopupListButton;

var bool    m_bAutoSelect;

function Created()
{
    Super.Created();

    m_FontForButtons=Root.Fonts[F_HelpWindow];

    m_fItemHeight = R6MenuRSLookAndFeel(LookAndFeel).m_BLTitleL.Up.H;
    //m_bCanBeUnselected=true;
    //---------------------------------------------
    m_ButtonItem[EPlanAction.PACT_None] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuActionButtonItem(m_ButtonItem[EPlanAction.PACT_None]).m_eAction = PACT_None;
    m_ButtonItem[EPlanAction.PACT_None].m_Button = R6WindowButton(CreateWindow( class'R6MenuPopUpStayDownButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[EPlanAction.PACT_None].m_Button.SetText( Localize("Order","Action_None","R6Menu"));
    m_ButtonItem[EPlanAction.PACT_None].m_Button.m_buttonFont=m_FontForButtons;
    //---------------------------------------------
    m_ButtonItem[EPlanAction.PACT_Frag] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuActionButtonItem(m_ButtonItem[EPlanAction.PACT_Frag]).m_eAction = PACT_Frag;
    m_ButtonItem[EPlanAction.PACT_Frag].m_Button = R6WindowButton(CreateWindow( class'R6MenuPopUpStayDownButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[EPlanAction.PACT_Frag].m_Button.SetText( Localize("Order","Action_FragRoom","R6Menu"));
    m_ButtonItem[EPlanAction.PACT_Frag].m_Button.m_buttonFont=m_FontForButtons;
    //---------------------------------------------
    m_ButtonItem[EPlanAction.PACT_Flash] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuActionButtonItem(m_ButtonItem[EPlanAction.PACT_Flash]).m_eAction = PACT_Flash;
    m_ButtonItem[EPlanAction.PACT_Flash].m_Button = R6WindowButton(CreateWindow( class'R6MenuPopUpStayDownButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[EPlanAction.PACT_Flash].m_Button.SetText( Localize("Order","Action_FlashRoom","R6Menu"));
    m_ButtonItem[EPlanAction.PACT_Flash].m_Button.m_buttonFont=m_FontForButtons;
    //---------------------------------------------
    m_ButtonItem[EPlanAction.PACT_Gas] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuActionButtonItem(m_ButtonItem[EPlanAction.PACT_Gas]).m_eAction = PACT_Gas;
    m_ButtonItem[EPlanAction.PACT_Gas].m_Button = R6WindowButton(CreateWindow( class'R6MenuPopUpStayDownButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[EPlanAction.PACT_Gas].m_Button.SetText( Localize("Order","Action_Gas","R6Menu"));
    m_ButtonItem[EPlanAction.PACT_Gas].m_Button.m_buttonFont=m_FontForButtons;
    //---------------------------------------------
    m_ButtonItem[EPlanAction.PACT_Smoke] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuActionButtonItem(m_ButtonItem[EPlanAction.PACT_Smoke]).m_eAction = PACT_Smoke;
    m_ButtonItem[EPlanAction.PACT_Smoke].m_Button = R6WindowButton(CreateWindow( class'R6MenuPopUpStayDownButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[EPlanAction.PACT_Smoke].m_Button.SetText( Localize("Order","Action_Smoke","R6Menu"));
    m_ButtonItem[EPlanAction.PACT_Smoke].m_Button.m_buttonFont=m_FontForButtons;
    //---------------------------------------------
    m_ButtonItem[EPlanAction.PACT_SnipeGoCode] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuActionButtonItem(m_ButtonItem[EPlanAction.PACT_SnipeGoCode]).m_eAction = PACT_SnipeGoCode;
    m_ButtonItem[EPlanAction.PACT_SnipeGoCode].m_Button = R6WindowButton(CreateWindow( class'R6MenuPopUpStayDownButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[EPlanAction.PACT_SnipeGoCode].m_Button.SetText( Localize("Order","Action_Snipe","R6Menu"));
    R6MenuActionButtonItem(m_ButtonItem[EPlanAction.PACT_SnipeGoCode]).m_Button.bDisabled=TRUE;
    m_ButtonItem[EPlanAction.PACT_SnipeGoCode].m_Button.m_buttonFont=m_FontForButtons;

    //---------------------------------------------
    m_ButtonItem[EPlanAction.PACT_Breach] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuActionButtonItem(m_ButtonItem[EPlanAction.PACT_Breach]).m_eAction = PACT_Breach;
    m_ButtonItem[EPlanAction.PACT_Breach].m_Button = R6WindowButton(CreateWindow( class'R6MenuPopUpStayDownButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[EPlanAction.PACT_Breach].m_Button.SetText( Localize("Order","Action_BreachDoor","R6Menu"));
    R6MenuActionButtonItem(m_ButtonItem[EPlanAction.PACT_Breach]).m_Button.bDisabled=TRUE;
    m_ButtonItem[EPlanAction.PACT_Breach].m_Button.m_buttonFont=m_FontForButtons;
}

function SetSelectedItem(UWindowListBoxItem NewSelected)
{
    local R6PlanningInfo    Planning;
    local R6PlanningCtrl OwnerCtrl;
    local R6MenuActionButtonItem SelectedItem;

    Super.SetSelectedItem( NewSelected);

    OwnerCtrl = R6PlanningCtrl(GetPlayerOwner());
    SelectedItem = R6MenuActionButtonItem(m_SelectedItem);
    
    if(m_SelectedItem == None)
    {
        log("NoSelected Item in action button menu? that's weird!");
        return;
    }

    Planning = OwnerCtrl.m_pTeamInfo[OwnerCtrl.m_iCurrentTeam];

    if(!m_bAutoSelect)
    {
        Planning.SetCurrentPointAction(SelectedItem.m_eAction);
        if((SelectedItem.m_eAction == PACT_Frag)||
           (SelectedItem.m_eAction == PACT_Flash)||
           (SelectedItem.m_eAction == PACT_Gas)||
           (SelectedItem.m_eAction == PACT_Smoke))
        {
            OwnerCtrl.m_bClickToFindLocation = true;
            OwnerCtrl.m_bClickedOnRange = false;
            R6MenuRootWindow(Root).m_bUseAimIcon = true;
        }

        if(SelectedItem.m_eAction == PACT_SnipeGoCode)
        {
            OwnerCtrl.m_bSetSnipeDirection = true;
            R6MenuRootWindow(Root).m_bUseAimIcon = true;
        }
#ifndefMPDEMO
        R6MenuRootWindow(Root).m_PlanningWidget.m_bClosePopup = true;
#endif
    }
}

function DisplaySnipeButton(BOOL bDoIDisplay)
{
    R6MenuActionButtonItem(m_ButtonItem[EPlanAction.PACT_SnipeGoCode]).m_Button.bDisabled=!bDoIDisplay;
}

function DisplayBreachDoor(BOOL bDoIDisplay)
{
    R6MenuActionButtonItem(m_ButtonItem[EPlanAction.PACT_Breach]).m_Button.bDisabled=!bDoIDisplay;
}

function ShowWindow()
{
    local EPlanAction   eAction;

    Super.ShowWindow();

    eAction = R6PlanningCtrl(GetPlayerOwner()).m_pTeamInfo[R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam].GetAction();

    m_bAutoSelect=true;
    if(m_ButtonItem[eAction] != m_SelectedItem)
    {
        SetSelectedItem(m_ButtonItem[eAction]);
    }
    m_bAutoSelect=false;
}

defaultproperties
{
     m_iNbButton=7
     ListClass=Class'R6Menu.R6MenuActionButtonItem'
}
