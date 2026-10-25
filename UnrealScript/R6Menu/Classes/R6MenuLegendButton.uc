//=============================================================================
//  R6MenuLegendButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/15 * Created by Chaouky Garram
//=============================================================================

class R6MenuLegendButton extends R6WindowStayDownButton;


function Created()
{
	bNoKeyboard = True;
    ToolTipString = Localize("PlanningMenu","Legend","R6Menu");
    
    ImageX = (WinWidth - UpRegion.W) / 2;
    ImageY = (WinHeight - UpRegion.H) / 2;
    
    m_BorderColor=Root.Colors.GrayLight; 
}

function BeforePaint(Canvas C, FLOAT X, FLOAT Y){}
function Tick(FLOAT fDeltaTime){}

function LMouseDown(FLOAT X, FLOAT Y)
{
#ifndefMPDEMO    
	Super.LMouseDown(X, Y);

    R6MenuRootWindow(Root).m_bPlayerWantLegend = m_bSelected;
    R6MenuRootWindow(Root).m_PlanningWidget.m_LegendWindow.ToggleLegend();
#endif
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    C.SetDrawColor(Root.Colors.GrayDark.R,Root.Colors.GrayDark.G,Root.Colors.GrayDark.B);
    //Draw Dark BackGround 
    DrawStretchedTextureSegment( C, 0, 0, WinWidth, WinHeight, 
                                    0, 0, WinWidth, WinHeight, Texture'R6MenuTextures.LaptopTileBG' );
    C.SetDrawColor(Root.Colors.White.R,Root.Colors.White.G,Root.Colors.White.B);
    
    Super.Paint(C,X,Y);
    DrawSimpleBorder(C);
}

defaultproperties
{
     m_iDrawStyle=5
     bStretched=True
     bUseRegion=True
     UpTexture=Texture'R6MenuTextures.Gui_03'
     DownTexture=Texture'R6MenuTextures.Gui_03'
     DisabledTexture=Texture'R6MenuTextures.Gui_03'
     OverTexture=Texture'R6MenuTextures.Gui_03'
     UpRegion=(X=231,Y=92,W=20,H=14)
     DownRegion=(X=231,Y=120,W=20,H=14)
     DisabledRegion=(X=231,Y=134,W=20,H=14)
     OverRegion=(X=231,Y=106,W=20,H=14)
}
