//=============================================================================
//  R6MenuLegendPageWPDesc.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/29 * Created by Joel Tremblay
//=============================================================================

class R6MenuLegendPageWPDesc extends R6MenuLegendPage;

#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning

function Created()
{
    Super.Created();

    m_szPageTitle = Localize("PlanningLegend","WP","R6Menu");
    //---------------------------------------------
    m_ButtonItem[0] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuLegendItem(m_ButtonItem[0]).m_pObjectIcon = Texture'R6Planning.Icons.PlanIcon_Alpha';
    m_ButtonItem[0].m_Button = R6WindowButton(CreateWindow( class'R6WindowButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[0].m_Button.SetText( Localize("PlanningLegend","WPAlpha","R6Menu"));
    m_ButtonItem[0].m_Button.ToolTipString = Localize("PlanningLegend","WPAlphaTip","R6Menu");
    m_ButtonItem[0].m_Button.m_buttonFont=m_FontForButtons;
    m_ButtonItem[0].m_Button.m_bPlayButtonSnd=false;
    //---------------------------------------------
    m_ButtonItem[1] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuLegendItem(m_ButtonItem[1]).m_pObjectIcon = Texture'R6Planning.Icons.PlanIcon_Bravo';
    m_ButtonItem[1].m_Button = R6WindowButton(CreateWindow( class'R6WindowButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[1].m_Button.SetText( Localize("PlanningLegend","WPBravo","R6Menu"));
    m_ButtonItem[1].m_Button.ToolTipString = Localize("PlanningLegend","WPBravoTip","R6Menu");
    m_ButtonItem[1].m_Button.m_buttonFont=m_FontForButtons;
    m_ButtonItem[1].m_Button.m_bPlayButtonSnd=false;
    //---------------------------------------------
    m_ButtonItem[2] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuLegendItem(m_ButtonItem[2]).m_pObjectIcon = Texture'R6Planning.Icons.PlanIcon_Charlie';
    m_ButtonItem[2].m_Button = R6WindowButton(CreateWindow( class'R6WindowButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[2].m_Button.SetText( Localize("PlanningLegend","WPCharlie","R6Menu"));
    m_ButtonItem[2].m_Button.ToolTipString = Localize("PlanningLegend","WPCharlieTip","R6Menu");
    m_ButtonItem[2].m_Button.m_buttonFont=m_FontForButtons;
    m_ButtonItem[2].m_Button.m_bPlayButtonSnd=false;
    //---------------------------------------------
    m_ButtonItem[3] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuLegendItem(m_ButtonItem[3]).m_pObjectIcon = Texture'R6Planning.Legend.PlanIcon_Milestone19';
    m_ButtonItem[3].m_Button = R6WindowButton(CreateWindow( class'R6WindowButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[3].m_Button.SetText( Localize("PlanningLegend","WPMilestone","R6Menu"));
    m_ButtonItem[3].m_Button.ToolTipString = Localize("PlanningLegend","WPMilestoneTip","R6Menu");
    m_ButtonItem[3].m_Button.m_buttonFont=m_FontForButtons;
    m_ButtonItem[3].m_Button.m_bPlayButtonSnd=false;
    //---------------------------------------------
    m_ButtonItem[4] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuLegendItem(m_ButtonItem[4]).m_pObjectIcon = Texture'R6Planning.Icons.PlanIcon_ActionPoint';
    m_ButtonItem[4].m_Button = R6WindowButton(CreateWindow( class'R6WindowButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[4].m_Button.SetText( Localize("PlanningLegend","WPWaypoint","R6Menu"));
    m_ButtonItem[4].m_Button.ToolTipString = Localize("PlanningLegend","WPWaypointTip","R6Menu");
    m_ButtonItem[4].m_Button.m_buttonFont=m_FontForButtons;
    m_ButtonItem[4].m_Button.m_bPlayButtonSnd=false;
    //---------------------------------------------
    m_ButtonItem[5] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuLegendItem(m_ButtonItem[5]).m_pObjectIcon = Texture'R6Planning.Icons.PlanIcon_SelectedPoint';
    m_ButtonItem[5].m_Button = R6WindowButton(CreateWindow( class'R6WindowButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[5].m_Button.SetText( Localize("PlanningLegend","WPSelectedWaypoint","R6Menu"));
    m_ButtonItem[5].m_Button.ToolTipString = Localize("PlanningLegend","WPSelectedWaypointTip","R6Menu");
    m_ButtonItem[5].m_Button.m_buttonFont=m_FontForButtons;
    m_ButtonItem[5].m_Button.m_bPlayButtonSnd=false;
}

defaultproperties
{
}
