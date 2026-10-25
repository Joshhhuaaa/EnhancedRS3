//=============================================================================
//  R6MenuTeamBar.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/28 * Created by Chaouky Garram
//=============================================================================

class R6MenuTeamBar extends UWindowWindow;

var R6MenuTeamDisplayButton m_DisplayList[3];
var R6MenuTeamButton        m_ActiveList[3];

const PosX2=2;
const ButtonWidth=28;
const SmallWidth=14;

function Created()
{
    local INT i;
    local INT xPosition;

   
    xPosition=4;

    for(i=0;i<3;i++)
    {
        m_ActiveList[i] = R6MenuTeamButton(CreateWindow( class'R6MenuTeamButton' , xPosition, 1, class'R6MenuTeamButton'.default.UpRegion.W, 23, self));
        m_ActiveList[i].m_iTeamColor = i;
        m_ActiveList[i].ToolTipString = Localize("PlanningMenu","TeamActive","R6Menu");
        m_ActiveList[i].m_vButtonColor=Root.Colors.TeamColorLight[i];

        xPosition += SmallWidth;
    }
    
    for(i=0;i<3;i++)
    {
        m_DisplayList[i] = R6MenuTeamDisplayButton(CreateWindow( class'R6MenuTeamDisplayButton', xPosition, 1, class'R6MenuTeamDisplayButton'.default.UpRegion.W, 23, self));
        m_DisplayList[i].m_iTeamColor = i;
        m_DisplayList[i].m_vButtonColor=Root.Colors.TeamColorLight[i];
        m_DisplayList[i].ToolTipString = Localize("PlanningMenu","TeamDisplay","R6Menu");

        xPosition += ButtonWidth - PosX2;
    }

	WinWidth = xPosition+4;
    // Init
    SetTeamActive(0);

     m_BorderColor=Root.Colors.GrayLight;
}

function Reset()
{
    local R6PlanningCtrl OwnerCtrl;
    OwnerCtrl = R6PlanningCtrl(GetPlayerOwner());

    //Reset the active team.
    m_ActiveList[0].m_bSelected = true;
    m_ActiveList[1].m_bSelected = false;
    m_ActiveList[2].m_bSelected = false;

    //Display All Team    
    m_DisplayList[0].m_bSelected = true;
    m_DisplayList[1].m_bSelected = true;
    m_DisplayList[2].m_bSelected = true;

    if(OwnerCtrl != none)
    {
        OwnerCtrl.m_pTeamInfo[0].SetPathDisplay(true);
        OwnerCtrl.m_pTeamInfo[1].SetPathDisplay(true);
        OwnerCtrl.m_pTeamInfo[2].SetPathDisplay(true);
    }
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    DrawSimpleBorder(C);
}

function EscClose()
{
}

function SetTeamActive(INT iActive)
{
    local R6PlanningCtrl OwnerCtrl;
    OwnerCtrl = R6PlanningCtrl(GetPlayerOwner());

    m_ActiveList[0].m_bSelected = false;
    m_ActiveList[1].m_bSelected = false;
    m_ActiveList[2].m_bSelected = false;
    m_ActiveList[iActive].m_bSelected = true;

    if(OwnerCtrl != none)
    {
        switch(iActive)
        {
        case 0:
            OwnerCtrl.SwitchToRedTeam(true);
            m_DisplayList[0].m_bSelected = true;
            break;
        case 1:
            OwnerCtrl.SwitchToGreenTeam(true);
            m_DisplayList[1].m_bSelected = true;
            break;
        case 2:
            OwnerCtrl.SwitchToGoldTeam(true);
            m_DisplayList[2].m_bSelected = true;
            break;
        }
    }
}

function ResetTeams(INT iWhatToReset)
{
    //Take the information from the planning controller to change the menu.
    local R6PlanningCtrl OwnerCtrl;
    OwnerCtrl = R6PlanningCtrl(GetPlayerOwner());

    //New team selected
    if((iWhatToReset < 3) && (m_ActiveList[OwnerCtrl.m_iCurrentTeam].m_bSelected != true))
    {
        m_ActiveList[0].m_bSelected = false;
        m_ActiveList[1].m_bSelected = false;
        m_ActiveList[2].m_bSelected = false;
        m_ActiveList[OwnerCtrl.m_iCurrentTeam].m_bSelected = true;
        if(!m_DisplayList[OwnerCtrl.m_iCurrentTeam].m_bSelected)
        {
            m_DisplayList[OwnerCtrl.m_iCurrentTeam].m_bSelected = true;
        }
    }
    else if( iWhatToReset > 2)
    {
        m_DisplayList[iWhatToReset - 3].m_bSelected = !m_DisplayList[iWhatToReset - 3].m_bSelected;
    }

}

defaultproperties
{
}
