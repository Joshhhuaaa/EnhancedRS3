//=============================================================================
//  R6WindowWrappedTextArea.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/04 * Created by Alexandre Dionne
//=============================================================================
class R6WindowWrappedTextArea extends UWindowWrappedTextArea;

//var R6WindowVScrollBar VertSB;
var class<UWindowVScrollBar>	m_SBClass;
var Texture m_HBorderTexture, m_VBorderTexture;
var Region m_HBorderTextureRegion, m_VBorderTextureRegion;
var bool                        m_bDrawBorders;

var float m_fHBorderHeight, m_fVBorderWidth;
var float m_fHBorderPadding, m_fVBorderPadding;
//var color m_BorderColor;

/////////////// BACK GROUND /////////////////////
var Texture m_BGTexture;
var Region  m_BGRegion;
var color   m_BGColor;
var int     m_BGDrawStyle;
var bool    m_bUseBGColor;
var bool    m_bUseBGTexture;


function SetBorderColor(Color _NewColor)
{
    m_BorderColor = _NewColor;
    if(VertSB != None)
        VertSB.SetBorderColor(_NewColor);
}

function SetScrollable(bool newScrollable)
{
	bScrollable = newScrollable;
	if(newScrollable)
	{
		VertSB = R6WindowVScrollbar(CreateWindow(m_SBClass, WinWidth-LookAndFeel.Size_ScrollbarWidth, 0, LookAndFeel.Size_ScrollbarWidth, WinHeight));
		VertSB.bAlwaysOnTop = True;
        VertSB.SetHideWhenDisable(true);
        VertSB.m_BorderColor = m_BorderColor;
	}
	else
	{
		if (VertSB != None)
		{
			VertSB.Close();
			VertSB = None;
		}
	}
}


function Resize()
{
    if (VertSB != None)
    {
      VertSB.WinLeft   = WinWidth-LookAndFeel.Size_ScrollbarWidth;          
      VertSB.WinTop    = 0;
      VertSB.WinWidth  = LookAndFeel.Size_ScrollbarWidth;
      VertSB.WinHeight = WinHeight;
    }           
}

function Paint( Canvas C, float X, float Y )
{

    if(m_bUseBGTexture)
    {
        if(m_bUseBGColor)
        {
            C.SetDrawColor(m_BGColor.R,m_BGColor.G,m_BGColor.B, m_BGColor.A);	
        }
        C.Style = m_BGDrawStyle;

        DrawStretchedTextureSegment( C, 0, 0, WinWidth, WinHeight, m_BGRegion.X, m_BGRegion.Y, 
											m_BGRegion.W, m_BGRegion.H, m_BGTexture );
		
    }
	
	Super.Paint(C,X,Y);

    C.SetDrawColor(m_BorderColor.R,m_BorderColor.G,m_BorderColor.B);	
    C.Style = m_BorderStyle;
	
    if(m_bDrawBorders)
    {

        if(m_HBorderTexture != NONE)
        {
	        //top
	        DrawStretchedTextureSegment( C, m_fHBorderPadding, 0, WinWidth - (2* m_fHBorderPadding),
										        m_fHBorderHeight, m_HBorderTextureRegion.X, m_HBorderTextureRegion.Y, 
										        m_HBorderTextureRegion.W, m_HBorderTextureRegion.H, m_HBorderTexture );
	        //Bottom
	        DrawStretchedTextureSegment( C, m_fHBorderPadding, WinHeight - m_fHBorderHeight, 
										        WinWidth  - (2* m_fHBorderPadding), 
										        m_fHBorderHeight, m_HBorderTextureRegion.X, m_HBorderTextureRegion.Y, 
										        m_HBorderTextureRegion.W, m_HBorderTextureRegion.H, m_HBorderTexture );
        }

        if(m_VBorderTexture != NONE)
        {
	        //Left
	        DrawStretchedTextureSegment( C, 0, m_fHBorderHeight + m_fVBorderPadding, m_fVBorderWidth, 
										        WinHeight - (2 * m_fHBorderHeight) - (2 * m_fVBorderPadding) , 
										        m_VBorderTextureRegion.X, m_VBorderTextureRegion.Y, 
										        m_VBorderTextureRegion.W, m_VBorderTextureRegion.H, m_VBorderTexture );
	        //Right
	        DrawStretchedTextureSegment( C, WinWidth - m_fVBorderWidth, m_fHBorderHeight + m_fVBorderPadding, m_fVBorderWidth, 
										        WinHeight - (2 * m_fHBorderHeight) - (2 * m_fVBorderPadding), 
										        m_VBorderTextureRegion.X, m_VBorderTextureRegion.Y, 
										        m_VBorderTextureRegion.W, m_VBorderTextureRegion.H, m_VBorderTexture );		
        }

    }
	
}

function MouseWheelDown(FLOAT X, FLOAT Y)
{
	if (VertSB != None)
	{
		VertSB.MouseWheelDown( X, Y);
	}
}

function MouseWheelUp(FLOAT X, FLOAT Y)
{
	if (VertSB != None)
	{
		VertSB.MouseWheelUp( X, Y);
	}
}

defaultproperties
{
     m_BGDrawStyle=5
     m_bDrawBorders=True
     m_fHBorderHeight=1.000000
     m_fVBorderWidth=1.000000
     m_HBorderTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     m_VBorderTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     m_BGTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     m_SBClass=Class'R6Window.R6WindowVScrollbar'
     m_HBorderTextureRegion=(X=30,Y=28,W=2,H=2)
     m_VBorderTextureRegion=(X=30,Y=28,W=2,H=2)
     m_BGRegion=(X=97,W=33,H=23)
}
