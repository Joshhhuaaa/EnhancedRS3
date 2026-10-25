//=============================================================================
//  R6MenuListSpeedButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6MenuListSpeedButton extends R6MenuPopupListButton;

var bool    m_bAutoSelect;

function Created()
{
    Super.Created();

    m_FontForButtons=Root.Fonts[F_HelpWindow];

    m_fItemHeight = R6MenuRSLookAndFeel(LookAndFeel).m_BLTitleL.Up.H;
    //---------------------------------------------
    m_ButtonItem[EMovementSpeed.SPEED_Blitz] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuSpeedButtonItem(m_ButtonItem[EMovementSpeed.SPEED_Blitz]).m_eSpeed = SPEED_Blitz;
    m_ButtonItem[EMovementSpeed.SPEED_Blitz].m_Button = R6WindowButton(CreateWindow( class'R6MenuPopUpStayDownButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[EMovementSpeed.SPEED_Blitz].m_Button.SetText( Localize("Order","Speed_Blitz","R6Menu"));
    m_ButtonItem[EMovementSpeed.SPEED_Blitz].m_Button.m_buttonFont=m_FontForButtons;
    //---------------------------------------------
    m_ButtonItem[EMovementSpeed.SPEED_Normal] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuSpeedButtonItem(m_ButtonItem[EMovementSpeed.SPEED_Normal]).m_eSpeed = SPEED_Normal;
    m_ButtonItem[EMovementSpeed.SPEED_Normal].m_Button = R6WindowButton(CreateWindow( class'R6MenuPopUpStayDownButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[EMovementSpeed.SPEED_Normal].m_Button.SetText( Localize("Order","Speed_Normal","R6Menu"));
    m_ButtonItem[EMovementSpeed.SPEED_Normal].m_Button.m_buttonFont=m_FontForButtons;
    //---------------------------------------------
    m_ButtonItem[EMovementSpeed.SPEED_Cautious] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuSpeedButtonItem(m_ButtonItem[EMovementSpeed.SPEED_Cautious]).m_eSpeed = SPEED_Cautious;
    m_ButtonItem[EMovementSpeed.SPEED_Cautious].m_Button = R6WindowButton(CreateWindow( class'R6MenuPopUpStayDownButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[EMovementSpeed.SPEED_Cautious].m_Button.SetText( Localize("Order","Speed_Cautious","R6Menu"));
    m_ButtonItem[EMovementSpeed.SPEED_Cautious].m_Button.m_buttonFont=m_FontForButtons;
}

function SetSelectedItem(UWindowListBoxItem NewSelected)
{
    local R6PlanningInfo    Planning;

    Super.SetSelectedItem( NewSelected);
    
    if(m_SelectedItem == None)
    {
        log("NoSelected Item in action button menu? that's weird!");
        return;
    }

    Planning = R6PlanningCtrl(GetPlayerOwner()).m_pTeamInfo[R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam];

#ifndefMPDEMO        
    if(!m_bAutoSelect)
    {
        Planning.SetMovementSpeed(R6MenuSpeedButtonItem(m_SelectedItem).m_eSpeed);
        R6MenuRootWindow(Root).m_PlanningWidget.m_bClosePopup = true;
    }
#endif

}


function ShowWindow()
{
    local EMovementSpeed    eSpeed;

    Super.ShowWindow();

    eSpeed = R6PlanningCtrl(GetPlayerOwner()).m_pTeamInfo[R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam].GetMovementSpeed();

    m_bAutoSelect=true;
    if(m_ButtonItem[eSpeed] != m_SelectedItem)
    {
        SetSelectedItem(m_ButtonItem[eSpeed]);
    }
    m_bAutoSelect=false;
}

defaultproperties
{
     m_iNbButton=3
     ListClass=Class'R6Menu.R6MenuSpeedButtonItem'
}
