//=============================================================================
//  R6MenuViewCamBar.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/03 * Created by Chaouky Garram
//=============================================================================

class R6MenuViewCamBar extends UWindowWindow;

var R6WindowButton m_Button[6];

const XPos=8;
const ButtonSize=33;

function Created()
{
    local INT xPosition;    
    
    xPosition = XPos+5;
    m_Button[0] = R6WindowButton(CreateWindow(class'R6MenuCamTurnCounterClockwiseButton', xPosition,1, class'R6MenuCamTurnCounterClockwiseButton'.default.UpRegion.W, 23, self));
    m_Button[0].ToolTipString = Localize("PlanningMenu","RotateCClock","R6Menu");
    xPosition += ButtonSize + XPos;

    m_Button[1] = R6WindowButton(CreateWindow(class'R6MenuCamTurnClockwiseButton', xPosition,1, class'R6MenuCamTurnClockwiseButton'.default.UpRegion.W, 23, self));
    m_Button[1].ToolTipString = Localize("PlanningMenu","RotateClock","R6Menu");
    xPosition += ButtonSize + XPos;

    m_Button[2] = R6WindowButton(CreateWindow(class'R6MenuCamZoomInButton', xPosition,1, class'R6MenuCamZoomInButton'.default.UpRegion.W, 23, self));
    m_Button[2].ToolTipString = Localize("PlanningMenu","ZoomIn","R6Menu");
    xPosition += ButtonSize + XPos;

    m_Button[3] = R6WindowButton(CreateWindow(class'R6MenuCamZoomOutButton', xPosition,1, class'R6MenuCamZoomOutButton'.default.UpRegion.W, 23, self));
    m_Button[3].ToolTipString = Localize("PlanningMenu","ZoomOut","R6Menu");
    xPosition += ButtonSize + XPos;

    m_Button[4] = R6WindowButton(CreateWindow(class'R6MenuCamFloorUpButton', xPosition,1, class'R6MenuCamFloorUpButton'.default.UpRegion.W, 23, self));
    m_Button[4].ToolTipString = Localize("PlanningMenu","LevelUp","R6Menu");
    xPosition += ButtonSize + XPos;

    m_Button[5] = R6WindowButton(CreateWindow(class'R6MenuCamFloorDownButton', xPosition,1, class'R6MenuCamFloorDownButton'.default.UpRegion.W, 23, self));
    m_Button[5].ToolTipString = Localize("PlanningMenu","LevelDown","R6Menu");
    xPosition += ButtonSize + 2;

    WinWidth = xPosition;

    m_BorderColor=Root.Colors.GrayLight;
}
 
function KeepActive(int iActive)
{
    m_Button[0].m_bSelected=false;
    m_Button[1].m_bSelected=false;
    m_Button[2].m_bSelected=false;

    if((iActive>-1) && (iActive<3))
    {
        m_Button[iActive].m_bSelected=true;
    }
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    DrawSimpleBorder(C);
}

defaultproperties
{
}
