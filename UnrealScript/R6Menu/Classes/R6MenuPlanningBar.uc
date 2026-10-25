//=============================================================================
//  R6MenuPlanningBar.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/28 * Created by Chaouky Garram
//=============================================================================

class R6MenuPlanningBar extends UWindowWindow;

var Color               m_iColor;
var R6MenuTeamBar       m_TeamBar;
var R6MenuDelNodeBar    m_DelNodeBar;
var R6MenuViewCamBar    m_ViewCamBar;
var R6MenuTimeLineBar   m_TimeLine;

function Created()
{
    local INT i;
    local FLOAT fCurrentW;

   
    fCurrentW = 0;
    m_TeamBar = R6MenuTeamBar(CreateWindow(class'R6MenuTeamBar', fCurrentW, 0, 10, 25,self));

    fCurrentW += (m_TeamBar.WinWidth - 1); //-1 removes the double borders
    m_DelNodeBar = R6MenuDelNodeBar(CreateWindow(class'R6MenuDelNodeBar', fCurrentW, 0, 10, 25, self));

    fCurrentW += (m_DelNodeBar.WinWidth -1);
    m_ViewCamBar = R6MenuViewCamBar(CreateWindow(class'R6MenuViewCamBar', fCurrentW, 0, 10, 25, self));

    fCurrentW += (m_ViewCamBar.WinWidth -1);
    m_TimeLine = R6MenuTimeLineBar(CreateWindow(class'R6MenuTimeLineBar', fCurrentW, 0, 10, 25, self));
}

function Reset()
{
    m_TeamBar.Reset();
    m_TimeLine.Reset();
}

function ResetTeams(INT iWhatToReset)
{
    m_TeamBar.ResetTeams(iWhatToReset);
}

defaultproperties
{
     m_iColor=(B=238,G=209,R=129)
}
