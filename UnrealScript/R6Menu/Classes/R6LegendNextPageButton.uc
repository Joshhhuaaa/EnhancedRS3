//=============================================================================
//  R6LegendNextPageButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/30 * Created by Joel Tremblay
//=============================================================================

class R6LegendNextPageButton extends UWindowButton;

function Created()
{
	bNoKeyboard = True;
   ToolTipString = Localize("PlanningLegend","MainNext","R6Menu");
}

function BeforePaint(Canvas C, FLOAT X, FLOAT Y){}

function LMouseDown(FLOAT X, FLOAT Y)
{
	Super.LMouseDown(X, Y);

    R6WindowLegend(ParentWindow).NextPage();
}

defaultproperties
{
     bStretched=True
     bUseRegion=True
     UpTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     DownTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     OverTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     UpRegion=(X=252,W=-12,H=12)
     DownRegion=(X=252,Y=24,W=-12,H=12)
     OverRegion=(X=252,Y=12,W=-12,H=12)
}
