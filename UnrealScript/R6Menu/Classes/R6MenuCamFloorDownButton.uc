//=============================================================================
//  R6MenuCamFloorDownButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6MenuCamFloorDownButton extends R6WindowButton;


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
        R6PlanningCtrl(GetPlayerOwner()).m_bLevelDown = 1;
        R6PlanningCtrl(GetPlayerOwner()).m_bGoLevelDown = 1;
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
        R6PlanningCtrl(GetPlayerOwner()).m_bLevelDown = 0; 
        R6PlanningCtrl(GetPlayerOwner()).m_bGoLevelDown = 1;
    }
}

defaultproperties
{
     m_iDrawStyle=5
     bUseRegion=True
     ImageX=3.000000
     UpTexture=Texture'R6MenuTextures.Gui_03'
     DownTexture=Texture'R6MenuTextures.Gui_03'
     DisabledTexture=Texture'R6MenuTextures.Gui_03'
     OverTexture=Texture'R6MenuTextures.Gui_03'
     UpRegion=(X=229,W=27,H=23)
     DownRegion=(X=229,Y=46,W=27,H=23)
     DisabledRegion=(X=229,Y=69,W=27,H=23)
     OverRegion=(X=229,Y=23,W=27,H=23)
}
