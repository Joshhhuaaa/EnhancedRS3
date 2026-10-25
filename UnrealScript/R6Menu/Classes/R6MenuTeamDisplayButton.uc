//=============================================================================
//  R6MenuTeamDisplayButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6MenuTeamDisplayButton extends R6WindowButton;//R6WindowStayDownButton;

var INT     m_iTeamColor;
var Region  m_ActiveRegion;
var Texture m_ActiveTexture;

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
    //Draw the button inside.
    if(m_bSelected == true)
    {
        C.SetDrawColor(m_vButtonColor.R, m_vButtonColor.G, m_vButtonColor.B);
        DrawStretchedTextureSegment( C, 0, 0, WinWidth, WinHeight, m_ActiveRegion.X, m_ActiveRegion.Y, m_ActiveRegion.W, m_ActiveRegion.H, m_ActiveTexture );
    }
}

function LMouseDown(FLOAT X, FLOAT Y)
{
    local FLOAT fGlobalX;
    local FLOAT fGlobalY;

#ifndefMPDEMO            
    if(!bDisabled && (m_iTeamColor !=  R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam))
    {
        Super.LMouseDown(X, Y);
    
        m_bSelected = !m_bSelected;
        R6PlanningCtrl(GetPlayerOwner()).m_pTeamInfo[m_iTeamColor].SetPathDisplay(m_bSelected);


        R6MenuRootWindow(Root).m_PlanningWidget.CloseAllPopup();

    }
#endif
}

defaultproperties
{
     m_ActiveTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     m_ActiveRegion=(X=172,Y=43,W=28,H=23)
     m_iDrawStyle=5
     bUseRegion=True
     m_bSelected=True
     UpTexture=Texture'R6MenuTextures.Gui_03'
     DownTexture=Texture'R6MenuTextures.Gui_03'
     DisabledTexture=Texture'R6MenuTextures.Gui_03'
     OverTexture=Texture'R6MenuTextures.Gui_03'
     UpRegion=(X=189,Y=92,W=28,H=23)
     DownRegion=(X=189,Y=138,W=28,H=23)
     DisabledRegion=(X=189,Y=161,W=28,H=23)
     OverRegion=(X=189,Y=115,W=28,H=23)
}
