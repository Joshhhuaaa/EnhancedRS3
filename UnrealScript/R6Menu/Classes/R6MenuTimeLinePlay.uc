//=============================================================================
//  R6MenuTimeLinePlay.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/03 * Created by Chaouky Garram
//=============================================================================

class R6MenuTimeLinePlay extends R6WindowButton;

var BOOL        m_bPlaying;
var Region      m_ButtonRegions[8];

function Created()
{
	bNoKeyboard = True;	
}

function BeforePaint(Canvas C, FLOAT X, FLOAT Y)
{
    if(m_bPlaying)
    {
        UpRegion=m_ButtonRegions[0];
        OverRegion=m_ButtonRegions[1];
        DownRegion=m_ButtonRegions[2];
        DisabledRegion=m_ButtonRegions[3];
    }
    else
    {
        UpRegion=m_ButtonRegions[4];
        OverRegion=m_ButtonRegions[5];
        DownRegion=m_ButtonRegions[6];
        DisabledRegion=m_ButtonRegions[7];
    }
}

function LMouseDown(FLOAT X, FLOAT Y)
{
    local R6PlanningCtrl OwnerCtrl;
    OwnerCtrl = R6PlanningCtrl(GetPlayerOwner());

    Super.LMouseDown(X, Y);
#ifndefMPDEMO    
	if(bDisabled || (OwnerCtrl.m_pTeamInfo[OwnerCtrl.m_iCurrentTeam].GetNbActionPoint() <= 1) )
		return;

    if(m_bPlaying == false)
    {
        if((OwnerCtrl.m_pTeamInfo[OwnerCtrl.m_iCurrentTeam].GetNbActionPoint() - 1) == OwnerCtrl.m_pTeamInfo[OwnerCtrl.m_iCurrentTeam].m_iCurrentNode)
        {
            OwnerCtrl.GotoFirstNode();
        }

        m_bPlaying = true;
        
        StartPlaying();
    }
    else
    {
        m_bPlaying = false;

        StopPlaying();
    }
    R6MenuRootWindow(Root).m_PlanningWidget.CloseAllPopup();
#endif
}

function StartPlaying()
{
    //Tell the Planning controller to start following the path
    R6PlanningCtrl(GetPlayerOwner()).StartPlayingPlanning();

    //disable buttons
    R6MenuTimeLineBar(OwnerWindow).ActivatePlayMode();
}

function StopPlaying()
{
    //Tell the Planning controller to stop
    R6PlanningCtrl(GetPlayerOwner()).StopPlayingPlanning();

    //Enable the buttons
    R6MenuTimeLineBar(OwnerWindow).StopPlayMode();
}

defaultproperties
{
     m_ButtonRegions(0)=(X=47,Y=92,W=20,H=23)
     m_ButtonRegions(1)=(X=47,Y=115,W=20,H=23)
     m_ButtonRegions(2)=(X=47,Y=138,W=20,H=23)
     m_ButtonRegions(3)=(X=47,Y=161,W=20,H=23)
     m_ButtonRegions(4)=(X=143,Y=92,W=20,H=23)
     m_ButtonRegions(5)=(X=143,Y=115,W=20,H=23)
     m_ButtonRegions(6)=(X=143,Y=138,W=20,H=23)
     m_ButtonRegions(7)=(X=143,Y=161,W=20,H=23)
     m_iDrawStyle=5
     bUseRegion=True
     UpTexture=Texture'R6MenuTextures.Gui_03'
     DownTexture=Texture'R6MenuTextures.Gui_03'
     DisabledTexture=Texture'R6MenuTextures.Gui_03'
     OverTexture=Texture'R6MenuTextures.Gui_03'
     UpRegion=(X=47,Y=92,W=20,H=23)
     DownRegion=(X=47,Y=138,W=20,H=23)
     DisabledRegion=(X=47,Y=161,W=20,H=23)
     OverRegion=(X=47,Y=115,W=20,H=23)
}
