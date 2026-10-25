//=============================================================================
//  R6MenuDelNodeBar.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/03 * Created by Chaouky Garram
//=============================================================================

class R6MenuDelNodeBar extends UWindowWindow;

var R6WindowButton m_Button[3];

const PosX=4;

function Created()
{
    local INT xPosition;    
    
    xPosition = 1;
    m_Button[0] = R6WindowButton(CreateWindow(class'R6MenuWPDeleteButton', xPosition,1, class'R6MenuWPDeleteButton'.default.UpRegion.W, 23, self));
    m_Button[0].ToolTipString = Localize("PlanningMenu","Delete","R6Menu");

    xPosition += m_Button[0].WinWidth - PosX;
    m_Button[1] = R6WindowButton(CreateWindow(class'R6MenuWPDeleteAllButton', xPosition,1, class'R6MenuWPDeleteAllButton'.default.UpRegion.W, 23, self));
    m_Button[1].ToolTipString = Localize("PlanningMenu","DeleteAll","R6Menu");

    xPosition += m_Button[1].WinWidth - PosX;
    m_Button[2] = R6WindowButton(CreateWindow(class'R6MenuWPDeleteAllTeamButton', xPosition,1, class'R6MenuWPDeleteAllTeamButton'.default.UpRegion.W, 23, self));
    m_Button[2].ToolTipString = Localize("PlanningMenu","DeleteAllTeam","R6Menu");

    xPosition += m_Button[1].WinWidth;
    WinWidth=xPosition;
    
    m_BorderColor=Root.Colors.GrayLight;
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    DrawSimpleBorder(C);
}

defaultproperties
{
}
