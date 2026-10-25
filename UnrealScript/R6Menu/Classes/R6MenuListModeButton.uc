//=============================================================================
//  R6MenuListModeButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6MenuListModeButton extends R6MenuPopupListButton;

var R6MenuSpeedMenu         m_WinSpeed;
var bool                    m_bAutoSelect;

function Created()
{
    Super.Created();

    m_FontForButtons=Root.Fonts[F_HelpWindow];

    m_fItemHeight = R6MenuRSLookAndFeel(LookAndFeel).m_BLTitleL.Up.H;
    //---------------------------------------------
    m_ButtonItem[EMovementMode.MOVE_Assault] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuModeButtonItem(m_ButtonItem[EMovementMode.MOVE_Assault]).m_eMode = MOVE_Assault;
    m_ButtonItem[EMovementMode.MOVE_Assault].m_Button = R6WindowButton(CreateWindow( class'R6MenuPopUpStayDownButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[EMovementMode.MOVE_Assault].m_Button.SetText( Localize("Order","Mode_Assault","R6Menu"));
    R6MenuPopUpStayDownButton(m_ButtonItem[EMovementMode.MOVE_Assault].m_Button).m_bSubMenu=true;
    m_ButtonItem[EMovementMode.MOVE_Assault].m_Button.m_buttonFont=m_FontForButtons;
    //---------------------------------------------
    m_ButtonItem[EMovementMode.MOVE_Infiltrate] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuModeButtonItem(m_ButtonItem[EMovementMode.MOVE_Infiltrate]).m_eMode = MOVE_Infiltrate;
    m_ButtonItem[EMovementMode.MOVE_Infiltrate].m_Button = R6WindowButton(CreateWindow( class'R6MenuPopUpStayDownButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[EMovementMode.MOVE_Infiltrate].m_Button.SetText( Localize("Order","Mode_Infiltrate","R6Menu"));
    R6MenuPopUpStayDownButton(m_ButtonItem[EMovementMode.MOVE_Infiltrate].m_Button).m_bSubMenu=true;
    m_ButtonItem[EMovementMode.MOVE_Infiltrate].m_Button.m_buttonFont=m_FontForButtons;
    //---------------------------------------------
    m_ButtonItem[EMovementMode.MOVE_Recon] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuModeButtonItem(m_ButtonItem[EMovementMode.MOVE_Recon]).m_eMode = MOVE_Recon;
    m_ButtonItem[EMovementMode.MOVE_Recon].m_Button = R6WindowButton(CreateWindow( class'R6MenuPopUpStayDownButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[EMovementMode.MOVE_Recon].m_Button.SetText( Localize("Order","Mode_Recon","R6Menu"));
    R6MenuPopUpStayDownButton(m_ButtonItem[EMovementMode.MOVE_Recon].m_Button).m_bSubMenu=true;
    m_ButtonItem[EMovementMode.MOVE_Recon].m_Button.m_buttonFont=m_FontForButtons;
}

function SetSelectedItem(UWindowListBoxItem NewSelected)
{
    local R6PlanningInfo    Planning;

    Planning = R6PlanningCtrl(GetPlayerOwner()).m_pTeamInfo[R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam];

    HidePopup();

    Super.SetSelectedItem( NewSelected);

    if(m_bAutoSelect != true)
    {
        Planning.SetMovementMode(R6MenuModeButtonItem(m_SelectedItem).m_eMode);
        ShowPopup();
    }
}

function HidePopup()
{
    if(m_WinSpeed!=None)
    {
        m_WinSpeed.HideWindow();
    }
}

function ShowWindow()
{
    local EMovementMode     eMode;

    eMode = R6PlanningCtrl(GetPlayerOwner()).GetMovementMode();

    Super.ShowWindow();

    m_bAutoSelect=true;
    if(m_ButtonItem[eMode] != m_SelectedItem)
    {
        SetSelectedItem(m_ButtonItem[eMode]);
    }
    m_bAutoSelect=false;
}

function ShowPopup()
{
    local FLOAT fGlobalLeft, fGlobalTop;

#ifndefMPDEMO        
    WindowToGlobal(ParentWindow.WinLeft, ParentWindow.WinTop, fGlobalLeft, fGlobalTop);
    fGlobalLeft = ParentWindow.WinLeft + ParentWindow.WinWidth;

    if(m_WinSpeed==None)
    {
        m_WinSpeed = R6MenuSpeedMenu(R6MenuRootWindow(Root).m_PlanningWidget.CreateWindow(class'R6MenuSpeedMenu', fGlobalLeft, ParentWindow.WinTop, 150, 100, OwnerWindow));
    }
    else
    {
        m_WinSpeed.WinLeft = fGlobalLeft;
        m_WinSpeed.WinTop  = ParentWindow.WinTop;
        m_WinSpeed.ShowWindow();
    }

    m_WinSpeed.AjustPosition(R6MenuFramePopup(OwnerWindow).m_bDisplayUp, R6MenuFramePopup(OwnerWindow).m_bDisplayLeft);
    if(R6MenuFramePopup(ParentWindow).m_bDisplayLeft == true)
    {
        m_WinSpeed.WinLeft -= (ParentWindow.WinWidth - 6);
    }
    if(R6MenuFramePopup(ParentWindow).m_bDisplayUp == true)
    {
        m_WinSpeed.WinTop -= (m_WinSpeed.WinHeight - ParentWindow.WinHeight);
    }
#endif

}

defaultproperties
{
     m_iNbButton=3
     ListClass=Class'R6Menu.R6MenuModeButtonItem'
}
