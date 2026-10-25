//=============================================================================
//  R6Menu3DViewOnOffButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/15 * Created by 
//=============================================================================

class R6Menu3DViewOnOffButton extends R6WindowStayDownButton;


function Created()
{
	bNoKeyboard = True;	
    ToolTipString = Localize("PlanningMenu","3DView","R6Menu");

    ImageX = (WinWidth - UpRegion.W) / 2;
    ImageY = (WinHeight - UpRegion.H) / 2;

    m_BorderColor=Root.Colors.GrayLight;
}

function BeforePaint(Canvas C, FLOAT X, FLOAT Y){}
function Tick(FLOAT fDeltaTime){}


function LMouseDown(FLOAT X, FLOAT Y)
{
    local R6MenuRootWindow R6Root;

	Super.LMouseDown(X, Y);
    R6Root = R6MenuRootWindow(Root);

#ifndefMPDEMO
    R6Root.Set3dView(!m_bSelected);
    R6Root.m_PlanningWidget.m_3DWindow.Toggle3DWindow();
    R6Root.m_PlanningWidget.CloseAllPopup();
    R6PlanningCtrl(GetPlayerOwner()).Toggle3DView();

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
     UpRegion=(Y=184,W=33,H=14)
     DownRegion=(Y=212,W=33,H=14)
     DisabledRegion=(Y=226,W=33,H=14)
     OverRegion=(Y=198,W=33,H=14)
}
