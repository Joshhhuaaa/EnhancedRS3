//=============================================================================
//  R6MenuTeamButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6MenuTeamButton extends R6WindowButton;

var INT     m_iTeamColor;
var Region  m_DotRegion;
var Texture m_DotTexture;

function Created()
{
	bNoKeyboard = True;
}

function BeforePaint(Canvas C, FLOAT X, FLOAT Y){}
function Tick(FLOAT fDelta){}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    Super.Paint(C,X,Y);
    //Draw the button inside.
    if(m_bSelected == true)
    {
        C.SetDrawColor(m_vButtonColor.R, m_vButtonColor.G, m_vButtonColor.B);
        DrawStretchedTextureSegment( C, 0, 0, WinWidth, WinHeight, m_DotRegion.X, m_DotRegion.Y, m_DotRegion.W, m_DotRegion.H, m_DotTexture );
    }
}

function LMouseDown(FLOAT X, FLOAT Y)
{
    local FLOAT fGlobalX;
    local FLOAT fGlobalY;
    
    Super.LMouseDown(X, Y);

#ifndefMPDEMO        
	if(!bDisabled && OwnerWindow.IsA('R6MenuTeamBar'))
    {
        R6MenuTeamBar(OwnerWindow).SetTeamActive(m_iTeamColor);

        R6MenuRootWindow(Root).m_PlanningWidget.CloseAllPopup();
    }
#endif
}

defaultproperties
{
     m_DotTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     m_DotRegion=(X=200,Y=43,W=14,H=23)
     m_iDrawStyle=5
     bUseRegion=True
     UpTexture=Texture'R6MenuTextures.Gui_03'
     DownTexture=Texture'R6MenuTextures.Gui_03'
     DisabledTexture=Texture'R6MenuTextures.Gui_03'
     OverTexture=Texture'R6MenuTextures.Gui_03'
     UpRegion=(X=217,Y=92,W=14,H=23)
     DownRegion=(X=217,Y=138,W=14,H=23)
     DisabledRegion=(X=217,Y=161,W=14,H=23)
     OverRegion=(X=217,Y=115,W=14,H=23)
}
