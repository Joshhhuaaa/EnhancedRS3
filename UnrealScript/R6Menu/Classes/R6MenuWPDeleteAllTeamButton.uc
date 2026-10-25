//=============================================================================
//  R6MenuWPDeleteAllTeamButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6MenuWPDeleteAllTeamButton extends R6WindowButton;


function Created()
{
	bNoKeyboard = True;	
}

function BeforePaint(Canvas C, FLOAT X, FLOAT Y){}
function Tick(FLOAT fDeltaTime){}

function LMouseDown(FLOAT X, FLOAT Y)
{
    local R6PlanningCtrl OwnerCtrl;
    OwnerCtrl = R6PlanningCtrl(GetPlayerOwner());

    Super.LMouseDown(X, Y);
	if(bDisabled)
		return;
#ifndefMPDEMO
    if((OwnerCtrl.m_pTeamInfo[0].GetNbActionPoint() != 0) ||
       (OwnerCtrl.m_pTeamInfo[1].GetNbActionPoint() != 0) ||
       (OwnerCtrl.m_pTeamInfo[2].GetNbActionPoint() != 0))
    {
        R6MenuRootWindow(Root).m_PlanningWidget.Hide3DAndLegend();
        R6MenuRootWindow(Root).SimplePopUp(Localize("PlanningMenu","WAYPOINTS","R6Menu"),Localize("PlanningMenu","DeleteAllTeam","R6Menu"),EPopUpID_DelAllTeamsWayPoints);
    }
#endif
}

simulated function Click(float X, float Y) 
{
    Super.Click(X, Y);
    GetPlayerOwner().PlaySound(R6PlanningCtrl(GetPlayerOwner()).m_PlanningBadClickSnd, SLOT_Menu);
}

defaultproperties
{
     m_iDrawStyle=5
     bUseRegion=True
     m_bPlayButtonSnd=False
     UpTexture=Texture'R6MenuTextures.Gui_03'
     DownTexture=Texture'R6MenuTextures.Gui_03'
     DisabledTexture=Texture'R6MenuTextures.Gui_03'
     OverTexture=Texture'R6MenuTextures.Gui_03'
     UpRegion=(X=56,W=28,H=23)
     DownRegion=(X=56,Y=46,W=28,H=23)
     DisabledRegion=(X=56,Y=69,W=28,H=23)
     OverRegion=(X=56,Y=23,W=28,H=23)
}
