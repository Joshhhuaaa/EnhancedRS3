//=============================================================================
//  R6MenuTimeLineNext.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/03 * Created by Chaouky Garram
//=============================================================================

class R6MenuTimeLineNext extends R6WindowButton;

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
#ifndefMPDEMO    
    R6PlanningCtrl(GetPlayerOwner()).GotoNextNode();
    
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
     UpRegion=(X=70,Y=92,W=25,H=23)
     DownRegion=(X=70,Y=138,W=25,H=23)
     DisabledRegion=(X=70,Y=161,W=25,H=23)
     OverRegion=(X=70,Y=115,W=25,H=23)
}
