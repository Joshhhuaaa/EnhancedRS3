//=============================================================================
//  R6MenuTimeLineBar.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/03 * Created by Chaouky Garram
//=============================================================================

class R6MenuTimeLineBar extends UWindowWindow;

var R6WindowButton m_Button[6];

function Created()
{
    local INT xPosition;

  
    xPosition=2;
    m_Button[0] = R6WindowButton(CreateWindow(class'R6MenuTimeLineGotoFirst', xPosition,1, class'R6MenuTimeLineGotoFirst'.default.UpRegion.W, 23, self));
    m_Button[0].ToolTipString = Localize("PlanningMenu","GotoFirst","R6Menu");
    xPosition += class'R6MenuTimeLineGotoFirst'.default.UpRegion.W;
    m_Button[1] = R6WindowButton(CreateWindow(class'R6MenuTimeLinePrevious', xPosition,1, class'R6MenuTimeLinePrevious'.default.UpRegion.W, 23, self));
    m_Button[1].ToolTipString = Localize("PlanningMenu","Previous","R6Menu");
    xPosition += class'R6MenuTimeLinePrevious'.default.UpRegion.W;
    m_Button[2] = R6WindowButton(CreateWindow(class'R6MenuTimeLinePlay', xPosition,1, class'R6MenuTimeLinePlay'.default.UpRegion.W, 23, self));
    m_Button[2].ToolTipString = Localize("PlanningMenu","PlayStop","R6Menu");
    xPosition += class'R6MenuTimeLinePlay'.default.UpRegion.W;
    m_Button[3] = R6WindowButton(CreateWindow(class'R6MenuTimeLineNext', xPosition,1, class'R6MenuTimeLineNext'.default.UpRegion.W, 23, self));
    m_Button[3].ToolTipString = Localize("PlanningMenu","Next","R6Menu");
    xPosition += class'R6MenuTimeLineNext'.default.UpRegion.W;
    m_Button[4] = R6WindowButton(CreateWindow(class'R6MenuTimeLineGotoLast', xPosition,1, class'R6MenuTimeLineGotoLast'.default.UpRegion.W, 23, self));
    m_Button[4].ToolTipString = Localize("PlanningMenu","GotoLast","R6Menu");
    xPosition += class'R6MenuTimeLineGotoLast'.default.UpRegion.W;
    m_Button[5] = R6WindowButton(CreateWindow(class'R6MenuTimeLineLock', xPosition,1, class'R6MenuTimeLineLock'.default.UpRegion.W, 23, self));
    m_Button[5].ToolTipString = Localize("PlanningMenu","Lock","R6Menu");
    xPosition += class'R6MenuTimeLineLock'.default.UpRegion.W;
    
    WinWidth = xPosition + 1;
    
    m_BorderColor=Root.Colors.GrayLight;
}

function Reset()
{
    if(R6PlanningCtrl(GetPlayerOwner()) != none)
    {
        //Reset playmode.
        R6PlanningCtrl(GetPlayerOwner()).m_bPlayMode = FALSE;
        //Tell the Planning controller to stop
        R6PlanningCtrl(GetPlayerOwner()).StopPlayingPlanning();
        StopPlayMode();
    }
    R6MenuTimeLineLock(m_Button[5]).ResetCameraLock();
}


function ActivatePlayMode()
{
    local R6MenuPlanningBar PlanningBarWindow;
    PlanningBarWindow = R6MenuPlanningBar(OwnerWindow);

    m_Button[0].bDisabled = true;
    m_Button[1].bDisabled = true;
    m_Button[3].bDisabled = true;
    m_Button[4].bDisabled = true;
    PlanningBarWindow.m_ViewCamBar.m_Button[4].bDisabled = true;
    PlanningBarWindow.m_ViewCamBar.m_Button[5].bDisabled = true;
    PlanningBarWindow.m_DelNodeBar.m_Button[0].bDisabled = true;
    PlanningBarWindow.m_DelNodeBar.m_Button[1].bDisabled = true;
    PlanningBarWindow.m_DelNodeBar.m_Button[2].bDisabled = true;
    PlanningBarWindow.m_TeamBar.m_DisplayList[0].bDisabled = true;
    PlanningBarWindow.m_TeamBar.m_ActiveList[0].bDisabled = true;
    PlanningBarWindow.m_TeamBar.m_DisplayList[1].bDisabled = true;
    PlanningBarWindow.m_TeamBar.m_ActiveList[1].bDisabled = true;
    PlanningBarWindow.m_TeamBar.m_DisplayList[2].bDisabled = true;
    PlanningBarWindow.m_TeamBar.m_ActiveList[2].bDisabled = true;
}

function StopPlayMode()
{
    local R6MenuPlanningBar PlanningBarWindow;
    PlanningBarWindow = R6MenuPlanningBar(OwnerWindow);

    m_Button[0].bDisabled = false;
    m_Button[1].bDisabled = false;
    m_Button[3].bDisabled = false;
    m_Button[4].bDisabled = false;
    PlanningBarWindow.m_ViewCamBar.m_Button[4].bDisabled = false;
    PlanningBarWindow.m_ViewCamBar.m_Button[5].bDisabled = false;
    PlanningBarWindow.m_DelNodeBar.m_Button[0].bDisabled = false;
    PlanningBarWindow.m_DelNodeBar.m_Button[1].bDisabled = false;
    PlanningBarWindow.m_DelNodeBar.m_Button[2].bDisabled = false;
    PlanningBarWindow.m_TeamBar.m_DisplayList[0].bDisabled = false;
    PlanningBarWindow.m_TeamBar.m_ActiveList[0].bDisabled = false;
    PlanningBarWindow.m_TeamBar.m_DisplayList[1].bDisabled = false;
    PlanningBarWindow.m_TeamBar.m_ActiveList[1].bDisabled = false;
    PlanningBarWindow.m_TeamBar.m_DisplayList[2].bDisabled = false;
    PlanningBarWindow.m_TeamBar.m_ActiveList[2].bDisabled = false;
    R6MenuTimeLinePlay(m_Button[2]).m_bPlaying = false;
    
    //Tell the Planning controller to stop
    if ( R6PlanningCtrl(GetPlayerOwner()) != none )
        R6PlanningCtrl(GetPlayerOwner()).StopPlayingPlanning();
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    DrawSimpleBorder(C);
}

defaultproperties
{
}
