//=============================================================================
//  R6WindowTextLabelCurved.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/02 * Created by Alexandre Dionne
//=============================================================================
class R6WindowTextLabelCurved extends R6WindowTextLabel;

var texture m_TLeftcurve, m_TBetweenCurveBG, m_TUnderLeftCurveBG;
var texture m_TopLeftCornerT;

var Region  m_RLeftcurve , m_RBetweenCurveBG, m_RUnderLeftCurveBG;
var Region  m_TopLeftCornerR;

var FLOAT   m_RightCurveLineWidth;
var FLOAT   m_fVBorderOffset;
var FLOAT   m_fRightCurveLineX, m_fLeftCurveLineX;

function Created()
{	
	m_fRightCurveLineX = WinWidth - m_fVBorderWidth - m_TopLeftCornerR.W - m_RightCurveLineWidth;    
	m_fLeftCurveLineX = m_fRightCurveLineX -  (2* m_RLeftcurve.W) - m_RBetweenCurveBG.W;

}

function Paint(Canvas C, float X, float Y)
{

	//Background
	if(m_BGTexture != NONE)
	{
		C.Style = ERenderStyle.STY_Modulated;
        
		//Left of curves
		DrawStretchedTextureSegment( C, m_fVBorderWidth, m_fHBorderHeight, m_fLeftCurveLineX - m_fVBorderWidth, 
											WinHeight - 2 * m_fHBorderHeight, m_BGTextureRegion.X, 
											m_BGTextureRegion.Y, m_BGTextureRegion.W, 
											m_BGTextureRegion.H, m_BGTexture );			

        

        
		//Right of curves
		DrawStretchedTextureSegment( C, m_fRightCurveLineX, m_fHBorderHeight, WinWidth - m_fVBorderWidth - m_fRightCurveLineX, 
											WinHeight - 2 * m_fHBorderHeight, m_BGTextureRegion.X, 
											m_BGTextureRegion.Y, m_BGTextureRegion.W, 
											m_BGTextureRegion.H, m_BGTexture );
        
		//Under the line between curves		
		DrawStretchedTextureSegment( C, m_fRightCurveLineX - m_RLeftcurve.W - m_RBetweenCurveBG.W, m_RLeftcurve.H, 
											m_RBetweenCurveBG.W , WinHeight - m_fHBorderHeight - m_RLeftcurve.H,
											m_RBetweenCurveBG.X, m_RBetweenCurveBG.Y, m_RBetweenCurveBG.W, 
											m_RBetweenCurveBG.H, m_TBetweenCurveBG );
        
        
		//Under Left Curve
		DrawStretchedTextureSegment( C,		m_fLeftCurveLineX, m_fHBorderHeight, 
											m_RUnderLeftCurveBG.W, m_RUnderLeftCurveBG.H, m_RUnderLeftCurveBG.X, 
											m_RUnderLeftCurveBG.Y, m_RUnderLeftCurveBG.W, 
											m_RUnderLeftCurveBG.H, m_TUnderLeftCurveBG );
		
		
		//Under Right Curve	
		DrawStretchedTextureSegment( C,		m_fRightCurveLineX - m_RLeftcurve.W, m_fHBorderHeight, 
											m_RUnderLeftCurveBG.W, m_RUnderLeftCurveBG.H, 
											m_RUnderLeftCurveBG.X + m_RUnderLeftCurveBG.W, 
											m_RUnderLeftCurveBG.Y, -m_RUnderLeftCurveBG.W, 
											m_RUnderLeftCurveBG.H, m_TUnderLeftCurveBG );
	}
	
	C.SetDrawColor(m_BorderColor.R,m_BorderColor.G,m_BorderColor.B);

	if(m_HBorderTexture != NONE)
	{
		
	//Lines for the curves and the top border	

        C.Style = ERenderStyle.STY_Alpha;

		//top Left line
		DrawStretchedTextureSegment( C, m_fHBorderPadding, 0, m_fLeftCurveLineX - m_fHBorderPadding, 
											m_fHBorderHeight, m_HBorderTextureRegion.X, m_HBorderTextureRegion.Y, 
											m_HBorderTextureRegion.W, m_HBorderTextureRegion.H, m_HBorderTexture );
		
		//Right of curve line
		DrawStretchedTextureSegment( C, m_fRightCurveLineX, 0, 
											m_RightCurveLineWidth, m_fHBorderHeight, 
											m_HBorderTextureRegion.X, m_HBorderTextureRegion.Y, 
											m_HBorderTextureRegion.W, m_HBorderTextureRegion.H, m_HBorderTexture );
		//Line between the 2 curves
		DrawStretchedTextureSegment( C, m_fRightCurveLineX - m_RLeftcurve.W - m_RBetweenCurveBG.W, 
											m_RLeftcurve.H - m_HBorderTextureRegion.H, 
											m_RBetweenCurveBG.W, m_fHBorderHeight, 
											m_HBorderTextureRegion.X, m_HBorderTextureRegion.Y, 
											m_HBorderTextureRegion.W, m_HBorderTextureRegion.H, m_HBorderTexture );
	
		//Bottom		
		DrawStretchedTextureSegment( C, m_fVBorderOffset, WinHeight - m_fHBorderHeight, WinWidth - (2 * m_fVBorderOffset), 
											m_fHBorderHeight, m_HBorderTextureRegion.X, m_HBorderTextureRegion.Y, 
											m_HBorderTextureRegion.W, m_HBorderTextureRegion.H, m_HBorderTexture );
	}
		
	if( m_TLeftcurve != NONE)
	{
		C.Style = ERenderStyle.STY_Alpha;
		//Right Curve
		DrawStretchedTextureSegment( C, m_fRightCurveLineX - m_RLeftcurve.W, 0, 
											m_RLeftcurve.W, m_RLeftcurve.H, 
											m_RLeftcurve.X + m_RLeftcurve.W, m_RLeftcurve.Y, 
											-m_RLeftcurve.W, m_RLeftcurve.H, m_TLeftcurve );
		

		//Left Curve
		DrawStretchedTextureSegment( C, m_fRightCurveLineX -  (2* m_RLeftcurve.W) - m_RBetweenCurveBG.W, 0, 
											m_RLeftcurve.W, m_RLeftcurve.H, 
											m_RLeftcurve.X, m_RLeftcurve.Y, 
											m_RLeftcurve.W, m_RLeftcurve.H, m_TLeftcurve );
	}

	if(m_VBorderTexture != NONE)
	{
        C.Style = ERenderStyle.STY_Alpha;
		//Left
		DrawStretchedTextureSegment( C, m_fVBorderOffset, m_fHBorderHeight + m_fVBorderPadding, m_fVBorderWidth, 
											WinHeight - (2 * m_fHBorderHeight) - m_fVBorderPadding , 
											m_VBorderTextureRegion.X, m_VBorderTextureRegion.Y, 
											m_VBorderTextureRegion.W, m_VBorderTextureRegion.H, m_VBorderTexture );
		//Right
		DrawStretchedTextureSegment( C, WinWidth - m_fVBorderWidth - m_fVBorderOffset, m_fHBorderHeight + m_fVBorderPadding, m_fVBorderWidth, 
											WinHeight - (2 * m_fHBorderHeight) - m_fVBorderPadding, 
											m_VBorderTextureRegion.X, m_VBorderTextureRegion.Y, 
											m_VBorderTextureRegion.W, m_VBorderTextureRegion.H, m_VBorderTexture );		
	}
	
	if(m_TopLeftCornerT != NONE) //Corners
	{
		C.Style = ERenderStyle.STY_Alpha;
		//Left
		DrawStretchedTextureSegment( C, 0, 0, m_TopLeftCornerR.W, m_TopLeftCornerR.H,
											m_TopLeftCornerR.X, m_TopLeftCornerR.Y, 
											m_TopLeftCornerR.W, m_TopLeftCornerR.H, m_TopLeftCornerT );
		//Right
		DrawStretchedTextureSegment( C, WinWidth - m_TopLeftCornerR.W,0, m_TopLeftCornerR.W, 
											m_TopLeftCornerR.H,	m_TopLeftCornerR.X + m_TopLeftCornerR.W, m_TopLeftCornerR.Y, 
											- m_TopLeftCornerR.W, m_TopLeftCornerR.H, m_TopLeftCornerT );
	}
	
	if(Text != "")
	{
		C.Style = ERenderStyle.STY_Normal;
		C.Font = m_Font;
		C.SpaceX = m_fFontSpacing;		
		C.SetDrawColor(TextColor.R,TextColor.G,TextColor.B);		

		ClipText(C, TextX, TextY, Text, True);
	}
}

defaultproperties
{
     m_RightCurveLineWidth=11.000000
     m_fVBorderOffset=1.000000
     m_TLeftcurve=Texture'R6MenuTextures.Gui_BoxScroll'
     m_TBetweenCurveBG=Texture'R6MenuTextures.Gui_BoxScroll'
     m_TUnderLeftCurveBG=Texture'R6MenuTextures.Gui_BoxScroll'
     m_topLeftCornerT=Texture'R6MenuTextures.Gui_BoxScroll'
     m_RLeftcurve=(X=18,Y=57,W=9,H=7)
     m_RBetweenCurveBG=(X=97,W=33,H=23)
     m_RUnderLeftCurveBG=(X=84,W=9,H=29)
     m_topLeftCornerR=(X=12,Y=56,W=6,H=8)
     m_fHBorderPadding=7.000000
     m_fVBorderPadding=6.000000
     m_BGTextureRegion=(X=77,W=4,H=29)
}
