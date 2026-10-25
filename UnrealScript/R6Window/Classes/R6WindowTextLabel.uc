//=============================================================================
//  R6WindowTextLabel.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/30 * Created by Alexandre Dionne
//=============================================================================

class R6WindowTextLabel extends UWindowWindow;

var string      Text;
var font        m_Font;
var TextAlign   Align;

var float       TextX, 
                TextY;		            // changed by BeforePaint functions
var float       m_fFontSpacing;		    // Space between characters
var float       m_fLMarge;			    // Left Text Margin
var float       m_fHBorderHeight, 
                m_fVBorderWidth;        // Border size
var float       m_fHBorderPadding, 
                m_fVBorderPadding;      // Allow the borders not to start in corners

var Texture     m_BGTexture;		    //Put = None when no background is needed
var Texture     m_HBorderTexture, 
                m_VBorderTexture;
var Region      m_BGTextureRegion;
var Region      m_HBorderTextureRegion, 
                m_VBorderTextureRegion;
var Region		m_BGExtRegion;			// use extremeties region (left and rigth arre the same)

var color       TextColor;
var color       m_BGColor;

var int         m_TextDrawstyle;
var int         m_Drawstyle;

var bool        m_bDrawBorders;         // Draw the borders?
var bool        m_bRefresh;
var bool        m_bUseBGColor;          // Color BG texture
var bool        m_bDrawBG;              // Draw the backGround??
var bool		m_bUseExtRegion;		// use extremeties region for the background with m_BGTextureRegion
var bool		m_bResizeToText;		// Resize the window to the text
var bool        m_bFixedYPos;           //To force the y pos of the text

function BeforePaint(Canvas C, FLOAT X, FLOAT Y)
{
	local FLOAT W, H;
	
//	Super.BeforePaint(C, X, Y);

    if (m_bRefresh)
    {
        m_bRefresh = false;

		if(Text != "")
		{
			C.Font = m_Font;

			TextSize(C, Text, W, H);
			
			switch(Align)
			{
			case TA_Left:
				TextX = m_fLMarge;
				break;
			case TA_Right:
				TextX = WinWidth - W - (Len(Text) * m_fFontSpacing) - m_fVBorderWidth;
				break;
			case TA_Center:
				TextX = (WinWidth - W) / 2;
				break;
			}
            
            if(!m_bFixedYPos)
            {
                TextY = (WinHeight - H) / 2;
			    TextY = FLOAT(INT(TextY+0.5));
            }
			

	        if( m_bResizeToText)
	        {
		        WinWidth = W + (Len(Text) * m_fFontSpacing) + m_fLMarge;
		        
		        if (Align != TA_LEFT)
			        WinLeft += TextX - m_fLMarge;
		        
		        TextX = m_fLMarge;
		        Align = TA_LEFT; 
		        m_bResizeToText = false;
	        }
		}	
    }
}

function Paint(Canvas C, float X, float Y)
{
	local Region RTemp;
	local float tempSpace;

    C.Style = m_Drawstyle;

    if( (m_BGTexture != NONE) && m_bDrawBG)
	{
        if(m_bUseBGColor)
            C.SetDrawColor(m_BGColor.R,m_BGColor.G,m_BGColor.B, m_BGColor.A);
		    
		if( m_bUseExtRegion) // use extremeties region
		{
			RTemp.X = m_fVBorderWidth;
			RTemp.Y = m_fHBorderHeight;
			RTemp.W = m_BGExtRegion.W;
			RTemp.H = WinHeight - (2 * m_fHBorderHeight);
			// left
			DrawStretchedTextureSegment( C, RTemp.X, RTemp.Y, RTemp.W, RTemp.H,
											m_BGExtRegion.X, m_BGExtRegion.Y, m_BGExtRegion.W, m_BGExtRegion.H, m_BGTexture );

			RTemp.X += RTemp.W;
			RTemp.W = WinWidth - (2 * RTemp.X);
			// center
			DrawStretchedTextureSegment( C, RTemp.X, RTemp.Y, RTemp.W, RTemp.H,
											m_BGTextureRegion.X, m_BGTextureRegion.Y, m_BGTextureRegion.W, m_BGTextureRegion.H, m_BGTexture );

			RTemp.X += RTemp.W;
			RTemp.W = m_BGExtRegion.W;

			// right
			DrawStretchedTextureSegment( C, RTemp.X, RTemp.Y, RTemp.W, RTemp.H,
											m_BGExtRegion.X + m_BGExtRegion.W, m_BGExtRegion.Y, -m_BGExtRegion.W, m_BGExtRegion.H, m_BGTexture );

		}
		else
		{
			DrawStretchedTextureSegment( C, m_fVBorderWidth, m_fHBorderHeight, WinWidth - 2 * m_fVBorderWidth, 
											WinHeight - 2 * m_fHBorderHeight, m_BGTextureRegion.X, 
											m_BGTextureRegion.Y, m_BGTextureRegion.W, 
											m_BGTextureRegion.H, m_BGTexture );					
		}
	}

    
    if (m_bDrawBorders)
    {	    
	    
	    C.SetDrawColor(m_BorderColor.R,m_BorderColor.G,m_BorderColor.B);
	    
	    if(m_HBorderTexture != NONE)
	    {
		    //top
		    DrawStretchedTextureSegment( C, m_fHBorderPadding, 0, WinWidth  - (2* m_fHBorderPadding),
											    m_fHBorderHeight, m_HBorderTextureRegion.X, m_HBorderTextureRegion.Y, 
											    m_HBorderTextureRegion.W, m_HBorderTextureRegion.H, m_HBorderTexture );
		    //Bottom
		    DrawStretchedTextureSegment( C, m_fHBorderPadding, WinHeight - m_fHBorderHeight, 
											    WinWidth - (2* m_fHBorderPadding), 
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
	
	if(Text != "")
	{
        tempSpace = C.SpaceX;		
		C.Font = m_Font;
		C.SpaceX = m_fFontSpacing;		
		C.SetDrawColor(TextColor.R,TextColor.G,TextColor.B);		
        
        C.Style =m_TextDrawstyle;
		ClipText(C, TextX, TextY, Text, True);
//		C.SetDrawColor(255,255,255);				
//		C.SpaceX = tempSpace;
//        C.Style =1;
	}
}

function SetProperties( string _text, TextAlign _Align, font _TypeOfFont, Color _TextColor, bool _bDrawBorders)
{
    Text = _text;
	Align = _Align;
	m_Font = _TypeOfFont;
	TextColor = _TextColor;    
    m_bDrawBorders = _bDrawBorders;
	m_bRefresh = true;
}


/////////////////////////////////////////////////////////////////
// set a new text and update the position or not depending of _bRefresh
/////////////////////////////////////////////////////////////////
function SetNewText( string _szNewText, bool _bRefresh)
{
    Text = _szNewText;
    m_bRefresh = _bRefresh;
}

defaultproperties
{
     m_TextDrawstyle=3
     m_DrawStyle=5
     m_bDrawBorders=True
     m_bRefresh=True
     m_fLMarge=2.000000
     m_fHBorderHeight=1.000000
     m_fVBorderWidth=1.000000
     m_BGTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     m_HBorderTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     m_VBorderTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     m_BGTextureRegion=(X=97,W=33,H=23)
     m_HBorderTextureRegion=(X=64,Y=56,W=1,H=1)
     m_VBorderTextureRegion=(X=64,Y=56,W=1,H=1)
     TextColor=(B=255,G=255,R=255)
     m_BGColor=(B=255,G=255,R=255)
}
