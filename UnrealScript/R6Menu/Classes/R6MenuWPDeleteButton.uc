//=============================================================================
//  R6MenuWPDeleteButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6MenuWPDeleteButton extends R6WindowButton;

#exec OBJ LOAD FILE=..\Textures\R6MenuTextures.utx PACKAGE=R6MenuTextures

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
}

simulated function Click(float X, float Y) 
{
    Super.Click(X, Y);

#ifndefMPDEMO
    R6PlanningCtrl(GetPlayerOwner()).DeleteOneNode();
    R6MenuRootWindow(Root).m_PlanningWidget.CloseAllPopup();
#endif
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
     UpRegion=(W=28,H=23)
     DownRegion=(Y=46,W=28,H=23)
     DisabledRegion=(Y=69,W=28,H=23)
     OverRegion=(Y=23,W=28,H=23)
}
