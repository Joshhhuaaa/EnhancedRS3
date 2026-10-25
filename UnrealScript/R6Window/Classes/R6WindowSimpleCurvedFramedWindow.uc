//=============================================================================
//  R6WindowSimpleCurvedFramedWindow.uc : This provides a simple frame for a window
//										 with the curved style
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/19 * Created by Alexandre Dionne
//=============================================================================


class R6WindowSimpleCurvedFramedWindow extends R6WindowSimpleFramedWindow;

var R6WindowTextLabelCurved m_topLabel;
var String					m_title;
var TextAlign               m_TitleAlign;
var font					m_Font;
var color					m_TextColor;
var float					m_fFontSpacing;		//Space between characters
var float					m_fLMarge;			// Left Text Margin



function Created()
{	
	m_topLabel = R6WindowTextLabelCurved(CreateWindow(class'R6WindowTextLabelCurved', 0, 0, WinWidth, 31, self));
	m_fVBorderOffset = m_topLabel.m_fVBorderOffset;
	m_fHBorderPadding = m_topLabel.m_TopLeftCornerR.W +1;
	m_fVBorderPadding = m_topLabel.m_TopLeftCornerR.H +1;
}

//Just Pass any Control to this function to get it to show in the frame
function CreateClientWindow( class<UWindowWindow> clientClass)
{
	m_ClientClass = clientClass;
	m_ClientArea = CreateWindow(m_ClientClass, m_fVBorderWidth + m_fVBorderOffset, m_fHBorderHeight +m_fHBorderOffset + m_topLabel.WinHeight, 
										WinWidth - ( 2* m_fVBorderWidth) - ( 2* m_fVBorderOffset), 
										WinHeight -  (2* m_fHBorderHeight) - ( 2* m_fHBorderOffset) - m_topLabel.WinHeight, OwnerWindow);   
} 

function BeforePaint(Canvas C, float X, float Y)
{    
	m_topLabel.Text = m_title;
	m_topLabel.Align = m_TitleAlign;
	m_topLabel.m_Font = m_Font;
	m_topLabel.TextColor = m_TextColor;
	m_topLabel.m_fFontSpacing = m_fFontSpacing;
	m_topLabel.m_fLMarge = m_fLMarge;
    m_topLabel.m_BorderColor = m_BorderColor;
}

function SetCornerType(eCornerType _eCornerType)
{
    switch(_eCornerType)
	{
		case Top_Corners:
            m_fHBorderOffset  = 0;
            m_fHBorderPadding = m_fVBorderOffset;
            m_fVBorderPadding = m_fHBorderHeight;
            break;
		case Bottom_Corners:			
		case All_Corners:
            m_fHBorderOffset  = default.m_fHBorderOffset;
            m_fHBorderPadding = default.m_fHBorderPadding;
            m_fVBorderPadding = default.m_fVBorderPadding;
    }

    m_eCornerType = _eCornerType;
}


function AfterPaint(Canvas C, float X, float Y)
{
	local float tempSpace;


	
	C.SetDrawColor(m_BorderColor.R,m_BorderColor.G,m_BorderColor.B);

	C.Style = m_DrawStyle;

	if(m_HBorderTexture != NONE)
	{
			
		//Bottom
		DrawStretchedTextureSegment( C, m_fHBorderPadding, WinHeight - m_fHBorderHeight -m_fHBorderOffset, 
											WinWidth - (2* m_fHBorderPadding), 
											m_fHBorderHeight, m_HBorderTextureRegion.X, m_HBorderTextureRegion.Y, 
											m_HBorderTextureRegion.W, m_HBorderTextureRegion.H, m_HBorderTexture );
	}
	

	if(m_VBorderTexture != NONE)
	{
		//Left
		DrawStretchedTextureSegment( C, m_fVBorderOffset, m_topLabel.WinHeight, m_fVBorderWidth, 
											WinHeight - m_fVBorderPadding - m_topLabel.WinHeight, 
											m_VBorderTextureRegion.X, m_VBorderTextureRegion.Y, 
											m_VBorderTextureRegion.W, m_VBorderTextureRegion.H, m_VBorderTexture );
		//Right
		DrawStretchedTextureSegment( C, WinWidth - m_fVBorderWidth - m_fVBorderOffset, m_topLabel.WinHeight, m_fVBorderWidth, 
											WinHeight - m_fVBorderPadding - m_topLabel.WinHeight, 
											m_VBorderTextureRegion.X, m_VBorderTextureRegion.Y, 
											m_VBorderTextureRegion.W, m_VBorderTextureRegion.H, m_VBorderTexture );		
	}
	

	switch(m_eCornerType)
	{
		case Top_Corners:
            break;
		case Bottom_Corners:			
		case All_Corners:
			//Corners
			DrawStretchedTextureSegment(C, 0, WinHeight -  m_topLeftCornerR.H, m_topLeftCornerR.W, m_topLeftCornerR.H, m_topLeftCornerR.X, 
													m_topLeftCornerR.Y + m_topLeftCornerR.H, 
													m_topLeftCornerR.W, -m_topLeftCornerR.H, m_topLeftCornerT);		
			DrawStretchedTextureSegment(C, WinWidth - m_topLeftCornerR.W, WinHeight -  m_topLeftCornerR.H, m_topLeftCornerR.W, m_topLeftCornerR.H, 
													m_topLeftCornerR.X + m_topLeftCornerR.W, m_topLeftCornerR.Y + m_topLeftCornerR.H, 
													-m_topLeftCornerR.W, -m_topLeftCornerR.H, m_topLeftCornerT);
			break;
	}
	
}

defaultproperties
{
     m_fLMarge=2.000000
}
