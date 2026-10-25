//=============================================================================
//  R6WindowPopUpButton.uc : PopUp button with specific border texture
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6WindowPopUpButton extends UWindowButton;

var Texture         m_TButBorderTex;
var Region          m_RButBorder;

var BOOL			m_bDrawRedBG;
var BOOL			m_bDrawGreenBG;

function Paint(Canvas C, float X, float Y)
{
	C.Style = ERenderStyle.STY_Alpha;

	if (m_bDrawRedBG)
	{
		C.SetDrawColor( Root.Colors.TeamColorLight[0].R, Root.Colors.TeamColorLight[0].G, Root.Colors.TeamColorLight[0].B);
	}
	else if (m_bDrawGreenBG)
	{
		C.SetDrawColor( Root.Colors.TeamColorLight[1].R, Root.Colors.TeamColorLight[1].G, Root.Colors.TeamColorLight[1].B);
	}
	else 
		C.SetDrawColor( Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);

    Super.Paint( C, X, Y);

	if (Text == "")
	{
		// draw button border -- appear on accept/cancel texture
		DrawStretchedTextureSegment( C, 0, 0, WinWidth, WinHeight, 
     								 m_RButBorder.X, m_RButBorder.Y, 
									 m_RButBorder.W, m_RButBorder.H, m_TButBorderTex );
	}
}

defaultproperties
{
     m_TButBorderTex=Texture'R6MenuTextures.Gui_BoxScroll'
     m_RButBorder=(X=26,Y=40,W=23,H=17)
     m_bWaitSoundFinish=True
}
