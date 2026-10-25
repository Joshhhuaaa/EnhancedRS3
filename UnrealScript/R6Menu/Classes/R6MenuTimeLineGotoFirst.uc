//=============================================================================
//  R6MenuTimeLineGotoFirst.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/03 * Created by Chaouky Garram
//=============================================================================

class R6MenuTimeLineGotoFirst extends R6WindowButton;

function Created()
{
	bNoKeyboard = True;
}

function BeforePaint(Canvas C, FLOAT X, FLOAT Y){}
function Tick(FLOAT fDeltaTime){}

function LMouseDown(FLOAT X, FLOAT Y)
{
    Super.LMouseDown(X, Y);
	if(bDisabled)
		return;
    R6PlanningCtrl(GetPlayerOwner()).GotoFirstNode();

#ifndefMPDEMO    
    R6MenuRootWindow(Root).m_PlanningWidget.CloseAllPopup();
#endif

}

defaultproperties
{
     m_iDrawStyle=5
     bUseRegion=True
     UpTexture=Texture'R6MenuTextures.Gui_03'
     DownTexture=Texture'R6MenuTextures.Gui_03'
     DisabledTexture=Texture'R6MenuTextures.Gui_03'
     OverTexture=Texture'R6MenuTextures.Gui_03'
     UpRegion=(Y=92,W=22,H=23)
     DownRegion=(Y=138,W=22,H=23)
     DisabledRegion=(Y=161,W=22,H=23)
     OverRegion=(Y=115,W=22,H=23)
}
