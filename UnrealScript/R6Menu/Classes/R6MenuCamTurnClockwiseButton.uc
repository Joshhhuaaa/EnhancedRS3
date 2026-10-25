//=============================================================================
//  R6MenuCamTurnClockwiseButton.uc : Button to turn the 2d map clockwise
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/13 * Created by Joel Tremblay
//=============================================================================

class R6MenuCamTurnClockwiseButton extends R6WindowButton;

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
        R6PlanningCtrl(GetPlayerOwner()).m_bRotateCCW = 1;
        R6MenuRootWindow(Root).m_PlanningWidget.CloseAllPopup();
    }
#endif

}

function LMouseUp(FLOAT X, FLOAT Y)
{
    Super.LMouseUp(X, Y);

	if(bDisabled)
		return;
    
    if(GetPlayerOwner().IsA('R6PlanningCtrl'))
    {
        R6PlanningCtrl(GetPlayerOwner()).m_bRotateCCW = 0;
    }
}

function MouseLeave()
{
    Super.MouseLeave();

    if(GetPlayerOwner().IsA('R6PlanningCtrl'))
    {
        R6PlanningCtrl(GetPlayerOwner()).m_bRotateCCW = 0;
    }
}

defaultproperties
{
     m_iDrawStyle=5
     bUseRegion=True
     UpTexture=Texture'R6MenuTextures.Gui_03'
     DownTexture=Texture'R6MenuTextures.Gui_03'
     DisabledTexture=Texture'R6MenuTextures.Gui_03'
     OverTexture=Texture'R6MenuTextures.Gui_03'
     UpRegion=(X=117,W=33,H=23)
     DownRegion=(X=117,Y=46,W=33,H=23)
     DisabledRegion=(X=117,Y=69,W=33,H=23)
     OverRegion=(X=117,Y=23,W=33,H=23)
}
