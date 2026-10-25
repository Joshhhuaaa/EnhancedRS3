//=============================================================================
//  R6MenuCamZoomOutButton.uc : Button to zoom in
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/13 * Created by Joel Tremblay
//=============================================================================

class R6MenuCamZoomOutButton extends R6WindowButton;


function Created()
{
	bNoKeyboard = True;
}


function BeforePaint(Canvas C, FLOAT X, FLOAT Y){}
function Tick(FLOAT fDelta){}

function LMouseDown(FLOAT X, FLOAT Y)
{
    Super.LMouseDown(X, Y);
	if(bDisabled)
		return;

#ifndefMPDEMO        
    if(GetPlayerOwner().IsA('R6PlanningCtrl'))
    {
        R6PlanningCtrl(GetPlayerOwner()).m_bZoomOut = 1;
        R6MenuRootWindow(Root).m_PlanningWidget.CloseAllPopup();
    }
#endif

}

function LMouseUp(FLOAT X, FLOAT Y)
{
    local R6PlanningCtrl PlanningCtrl;

    Super.LMouseUp(X, Y);
	if(bDisabled)
		return;

    if(GetPlayerOwner().IsA('R6PlanningCtrl'))
    {
        R6PlanningCtrl(GetPlayerOwner()).m_bZoomOut = 0;
    }
}

function MouseLeave()
{
    Super.MouseLeave();

    if(GetPlayerOwner().IsA('R6PlanningCtrl'))
    {
        R6PlanningCtrl(GetPlayerOwner()).m_bZoomOut = 0;
    }
}

defaultproperties
{
     m_iDrawStyle=5
     bUseRegion=True
     ImageX=2.000000
     UpTexture=Texture'R6MenuTextures.Gui_03'
     DownTexture=Texture'R6MenuTextures.Gui_03'
     DisabledTexture=Texture'R6MenuTextures.Gui_03'
     OverTexture=Texture'R6MenuTextures.Gui_03'
     UpRegion=(X=150,W=28,H=23)
     DownRegion=(X=150,Y=46,W=28,H=23)
     DisabledRegion=(X=150,Y=69,W=28,H=23)
     OverRegion=(X=150,Y=23,W=28,H=23)
}
