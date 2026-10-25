//=============================================================================
//  R6MenuTimeLineLock.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/03 * Created by Chaouky Garram
//=============================================================================

class R6MenuTimeLineLock extends R6WindowButton;

var BOOL         m_bLocked;
var Region       m_ButtonRegions[8];

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

    m_bLocked = !m_bLocked;
    R6PlanningCtrl(GetPlayerOwner()).m_bLockCamera = m_bLocked;

    if(m_bLocked == true)
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
#ifndefMPDEMO    
    R6MenuRootWindow(Root).m_PlanningWidget.CloseAllPopup();
#endif
}

function ResetCameraLock()
{
    m_bLocked = false;
    UpRegion=m_ButtonRegions[4];
    OverRegion=m_ButtonRegions[5];
    DownRegion=m_ButtonRegions[6];
    DisabledRegion=m_ButtonRegions[7];
}

defaultproperties
{
     m_ButtonRegions(0)=(X=163,Y=92,W=26,H=23)
     m_ButtonRegions(1)=(X=163,Y=115,W=26,H=23)
     m_ButtonRegions(2)=(X=163,Y=138,W=26,H=23)
     m_ButtonRegions(3)=(X=163,Y=161,W=26,H=23)
     m_ButtonRegions(4)=(X=117,Y=92,W=26,H=23)
     m_ButtonRegions(5)=(X=117,Y=115,W=26,H=23)
     m_ButtonRegions(6)=(X=117,Y=138,W=26,H=23)
     m_ButtonRegions(7)=(X=117,Y=161,W=26,H=23)
     m_iDrawStyle=5
     bUseRegion=True
     UpTexture=Texture'R6MenuTextures.Gui_03'
     DownTexture=Texture'R6MenuTextures.Gui_03'
     DisabledTexture=Texture'R6MenuTextures.Gui_03'
     OverTexture=Texture'R6MenuTextures.Gui_03'
     UpRegion=(X=117,Y=92,W=26,H=23)
     DownRegion=(X=117,Y=138,W=26,H=23)
     DisabledRegion=(X=117,Y=161,W=26,H=23)
     OverRegion=(X=117,Y=115,W=26,H=23)
}
