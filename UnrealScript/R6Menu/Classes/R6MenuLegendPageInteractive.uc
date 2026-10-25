//=============================================================================
//  R6MenuLegendPageInteractive.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/29 * Created by Joel Tremblay
//=============================================================================

class R6MenuLegendPageInteractive extends R6MenuLegendPage;

#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning

function Created()
{
    Super.Created();

    m_szPageTitle = Localize("PlanningLegend","Interactive","R6Menu");
    //---------------------------------------------
    m_ButtonItem[0] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuLegendItem(m_ButtonItem[0]).m_pObjectIcon = Texture'R6Planning.Icons.PlanIcon_Door';
    R6MenuLegendItem(m_ButtonItem[0]).m_bOtherTextureHeight = true;
    m_ButtonItem[0].m_Button = R6WindowButton(CreateWindow( class'R6WindowButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[0].m_Button.SetText( Localize("PlanningLegend","InteractiveDoor","R6Menu"));
    m_ButtonItem[0].m_Button.ToolTipString = Localize("PlanningLegend","InteractiveDoorTip","R6Menu");
    m_ButtonItem[0].m_Button.m_buttonFont=m_FontForButtons;
    m_ButtonItem[0].m_Button.m_bPlayButtonSnd=false;
    //---------------------------------------------
    m_ButtonItem[1] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuLegendItem(m_ButtonItem[1]).m_pObjectIcon = Texture'R6Planning.Icons.PlanIcon_DoorLocked';
    R6MenuLegendItem(m_ButtonItem[1]).m_bOtherTextureHeight = true;
    m_ButtonItem[1].m_Button = R6WindowButton(CreateWindow( class'R6WindowButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[1].m_Button.SetText( Localize("PlanningLegend","InteractiveLockedDoor","R6Menu"));
    m_ButtonItem[1].m_Button.ToolTipString = Localize("PlanningLegend","InteractiveLockedDoorTip","R6Menu");
    m_ButtonItem[1].m_Button.m_buttonFont=m_FontForButtons;
    m_ButtonItem[1].m_Button.m_bPlayButtonSnd=false;
    //---------------------------------------------
    m_ButtonItem[2] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuLegendItem(m_ButtonItem[2]).m_pObjectIcon = Texture'R6Planning.Legend.PlanIcon_Window';
    m_ButtonItem[2].m_Button = R6WindowButton(CreateWindow( class'R6WindowButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[2].m_Button.SetText( Localize("PlanningLegend","InteractiveWindow","R6Menu"));
    m_ButtonItem[2].m_Button.ToolTipString = Localize("PlanningLegend","InteractiveWindowTip","R6Menu");
    m_ButtonItem[2].m_Button.m_buttonFont=m_FontForButtons;
    m_ButtonItem[2].m_Button.m_bPlayButtonSnd=false;
    //---------------------------------------------
    m_ButtonItem[3] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuLegendItem(m_ButtonItem[3]).m_pObjectIcon = Texture'R6Planning.Icons.PlanIcon_Stairs';
    m_ButtonItem[3].m_Button = R6WindowButton(CreateWindow( class'R6WindowButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[3].m_Button.SetText( Localize("PlanningLegend","InteractiveStairs","R6Menu"));
    m_ButtonItem[3].m_Button.ToolTipString = Localize("PlanningLegend","InteractiveStairsTip","R6Menu");
    m_ButtonItem[3].m_Button.m_buttonFont=m_FontForButtons;
    m_ButtonItem[3].m_Button.m_bPlayButtonSnd=false;
    //---------------------------------------------
    m_ButtonItem[4] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuLegendItem(m_ButtonItem[4]).m_pObjectIcon = Texture'R6Planning.Icons.PlanIcon_Ladder';
    m_ButtonItem[4].m_Button = R6WindowButton(CreateWindow( class'R6WindowButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[4].m_Button.SetText( Localize("PlanningLegend","InteractiveLadder","R6Menu"));
    m_ButtonItem[4].m_Button.ToolTipString = Localize("PlanningLegend","InteractiveLadderTip","R6Menu");
    m_ButtonItem[4].m_Button.m_buttonFont=m_FontForButtons;
    m_ButtonItem[4].m_Button.m_bPlayButtonSnd=false;
    //---------------------------------------------
    m_ButtonItem[5] = R6WindowListButtonItem(Items.Append( ListClass));
    R6MenuLegendItem(m_ButtonItem[5]).m_pObjectIcon = Texture'R6Planning.Legend.PlanIcon_CamDirection';
    m_ButtonItem[5].m_Button = R6WindowButton(CreateWindow( class'R6WindowButton', 0, 0, WinWidth, m_fItemHeight, self));
    m_ButtonItem[5].m_Button.SetText( Localize("PlanningLegend","InteractiveCameraView","R6Menu"));
    m_ButtonItem[5].m_Button.ToolTipString = Localize("PlanningLegend","InteractiveCameraViewTip","R6Menu");
    m_ButtonItem[5].m_Button.m_buttonFont=m_FontForButtons;
    m_ButtonItem[5].m_Button.m_bPlayButtonSnd=false;
}

defaultproperties
{
}
