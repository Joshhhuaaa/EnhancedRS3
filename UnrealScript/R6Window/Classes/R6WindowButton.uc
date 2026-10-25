//=============================================================================
//  R6WindowButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6WindowButton extends UWindowButton;

// Load Menu Sound Package
//#exec OBJ LOAD FILE=..\Sounds\R6SoundProto.uax PACKAGE=R6SoundProto

var enum eButtonType
{
    eNormalButton,
    eCounterButton
} m_eButtonType;

var R6WindowButton  m_pRefButtonPos;		 // the button that store size of all buttons
var R6WindowButton	m_pPreviousButtonPos;	 // If we have a previous button pos to positioning your current button

var FONT			m_buttonFont;
var FONT            m_DownSizeFont;          //Font to downsize to if text doesn't fit

var Color			m_vButtonColor;

var Texture			m_BGSelecTexture;        // The background texture when you selected the button

var FLOAT			m_fLMarge;              //Usefull for text aligned left or to keep space at left of the text when we resize button to text
var FLOAT			m_fRMarge;              //Usefull for text aligned right or to keep space at right of the text when we resize button to text

var FLOAT			m_fFontSpacing;
var FLOAT			m_fDownSizeFontSpacing;

var FLOAT			m_textSize;
var FLOAT			m_fTotalButtonsSize;	 // this work with previous button pos

var INT				m_iDrawStyle;

var FLOAT           m_fMaxWinWidth;         // When we ask a button to resize make sure he doesn't grow to big
var FLOAT			m_fOrgWinLeft;			// When we ask for resize text with different text size and the align is not TA_left, use org winleft
var bool			m_bResizeToText;

var bool			m_bDrawBorders;
var bool			m_bDrawSimpleBorder;
var bool            m_bDrawSpecialBorder;

var bool			m_bSetParam;             // Use to set the param in before paint one time
var bool			m_bDefineBorderColor;

var BOOL            m_bCheckForDownSizeFont;  //Switch to m_DownSizeFont is text doesn't fit the button

function Created()
{
    Super.Created();
    m_fMaxWinWidth = WinWidth;  //Default value
	m_fOrgWinLeft = WinLeft;
}

function BeforePaint(Canvas C, FLOAT X, FLOAT Y)
{
	local FLOAT W, H, TextWidth;	
	

    if (m_bSetParam)
    {
	    m_bSetParam = false;

		if(Text != "")
		{
	        if(m_buttonFont != NONE)
		        C.Font = m_buttonFont;
	        else
		        C.Font = Root.Fonts[Font];

	        TextSize(C, Text, W, H );

            TextWidth = W + (Len(Text) * m_fFontSpacing);
	        
	        switch(Align)
	        {
	        case TA_Left:
		        TextX = m_fLMarge;
		        break;
	        case TA_Right:
		        TextX = WinWidth - m_fRMarge - TextWidth;
		        break;
	        case TA_Center:
		        TextX = (WinWidth - TextWidth) / 2;
		        break;
	        }
	        
	        TextY = (WinHeight - H) / 2;
            TextY = FLOAT(INT(TextY+0.5));
	        
	        //This Allows Button to resize to the text size
	        //and keep the position where the button was
	        //Created
	        
            if(m_bCheckForDownSizeFont)
            {
                //This will let the button first check if he needs to 
                //change font and resize at next frame if desired
                m_bCheckForDownSizeFont = false;                
                
                if(  (m_DownSizeFont != None) && (TextX + TextWidth > WinWidth) )
                {
                    m_buttonFont = m_DownSizeFont;
                    m_fFontSpacing = m_fDownSizeFontSpacing;
                }             
                
                m_bSetParam = m_bResizeToText;
            }
	        else if( m_bResizeToText )
	        {
		        m_textSize = TextWidth;

		        WinWidth = FMin(m_textSize + m_fLMarge + m_fRMarge, m_fMaxWinWidth);
				
		        if (Align != TA_LEFT)
				{
					WinLeft = m_fOrgWinLeft;
			        WinLeft += TextX - m_fLMarge;
				}
		        
		        TextX = m_fLMarge;
//		        Align = TA_LEFT; 
		        m_bResizeToText = false;
	        }

			m_fTotalButtonsSize = WinWidth;

			if (m_pRefButtonPos != None) // add the size of the buttons to the reference button
			{
				m_pRefButtonPos.m_fTotalButtonsSize += WinWidth;
			}            

        }	
    }
}


function Paint(Canvas C, FLOAT X, FLOAT Y)
{
	local float tempSpace;
    local Color vBorderColor;    
	
	C.Style = m_iDrawStyle;
    C.SetDrawColor(m_vButtonColor.R,m_vButtonColor.G,m_vButtonColor.B);

	if(bDisabled) {
		if(DisabledTexture != None)
		{
            if(bUseRegion && bStretched)
                DrawStretchedTextureSegment( C, ImageX, ImageY, DisabledRegion.W*RegionScale, DisabledRegion.H*RegionScale, 
											DisabledRegion.X, DisabledRegion.Y, 
											DisabledRegion.W, DisabledRegion.H, DisabledTexture );

			else if(bUseRegion)
				DrawStretchedTextureSegment( C, ImageX, ImageY, DisabledRegion.W*RegionScale, DisabledRegion.H*RegionScale, 
											DisabledRegion.X, DisabledRegion.Y, 
											DisabledRegion.W, DisabledRegion.H, DisabledTexture );
			else if(bStretched)
				DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, DisabledTexture );
			else
				DrawClippedTexture( C, ImageX, ImageY, DisabledTexture);
		}
	} else {
		if(bMouseDown)
		{
			if(DownTexture != None)
			{
                if(bUseRegion && bStretched)
                    DrawStretchedTextureSegment( C, ImageX, ImageY, WinWidth, WinHeight, 
												DownRegion.X, DownRegion.Y, 
												DownRegion.W, DownRegion.H, DownTexture );
				else if(bUseRegion)
					DrawStretchedTextureSegment( C, ImageX, ImageY, DownRegion.W*RegionScale, DownRegion.H*RegionScale, 
												DownRegion.X, DownRegion.Y, 
												DownRegion.W, DownRegion.H, DownTexture );
				else if(bStretched)
					DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, DownTexture );
				else
					DrawClippedTexture( C, ImageX, ImageY, DownTexture);
			}
		} else {
			if(MouseIsOver()) {
				if(OverTexture != None)
				{
					if(bUseRegion && bStretched)

						DrawStretchedTextureSegment( C, ImageX, ImageY, WinWidth, WinHeight, 
													OverRegion.X, OverRegion.Y, 
													OverRegion.W, OverRegion.H, OverTexture );
                    else if(bUseRegion)
                        DrawStretchedTextureSegment( C, ImageX, ImageY, OverRegion.W*RegionScale, OverRegion.H*RegionScale, 
													OverRegion.X, OverRegion.Y, 
													OverRegion.W, OverRegion.H, OverTexture );

					else if(bStretched)
						DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, OverTexture );
					else
						DrawClippedTexture( C, ImageX, ImageY, OverTexture);
				}
			} else {
				if(UpTexture != None)
				{
                    if(bUseRegion && bStretched)
                        DrawStretchedTextureSegment( C, ImageX, ImageY, WinWidth, WinHeight, 
													UpRegion.X, UpRegion.Y, 
													UpRegion.W, UpRegion.H, UpTexture );
					
                     else if(bUseRegion)
						DrawStretchedTextureSegment( C, ImageX, ImageY, UpRegion.W*RegionScale, UpRegion.H*RegionScale, 
													UpRegion.X, UpRegion.Y, 
													UpRegion.W, UpRegion.H, UpTexture );
					else if(bStretched)
						DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, UpTexture );
					else
						DrawClippedTexture( C, ImageX, ImageY, UpTexture);
				}
			}
		}
	}

	if(Text != "")
	{
	    if(m_buttonFont != NONE)
		    C.Font = m_buttonFont;
	    else
		    C.Font = Root.Fonts[Font];

      	C.Style = ERenderStyle.STY_Normal;
		tempSpace = C.SpaceX;
		C.SpaceX = m_fFontSpacing;		
		
        if(Text != "")
	    {		
	        if( bDisabled )
			{
			    C.SetDrawColor(m_DisabledTextColor.R,m_DisabledTextColor.G,m_DisabledTextColor.B);		
				m_BorderColor = m_DisabledTextColor;
			}
            else if (m_bSelected)
			{
                C.SetDrawColor(m_SelectedTextColor.R,m_SelectedTextColor.G,m_SelectedTextColor.B);
				m_BorderColor = m_SelectedTextColor;
			}
            else if(MouseIsOver())
			{
                C.SetDrawColor(m_OverTextColor.R,m_OverTextColor.G,m_OverTextColor.B);
				m_BorderColor = m_OverTextColor;
			}
		    else
			{
			    C.SetDrawColor(TextColor.R,TextColor.G,TextColor.B);	
				m_BorderColor = TextColor;
			}

            ClipText(C, TextX, TextY, Text, True);        
		    C.SpaceX = tempSpace;
	    }	
	}

	if(m_bDrawBorders)
    {
        if(m_bDrawSpecialBorder)
        {
            R6WindowLookAndFeel(LookAndFeel).DrawSpecialButtonBorder(Self , C , X, Y);
        }
        else if(m_bDrawSimpleBorder)
        {
            DrawSimpleBorder(C);
        }
        else
    	    R6WindowLookAndFeel(LookAndFeel).DrawButtonBorder(Self, C, m_bDefineBorderColor);
    }
}

//This function Allow a button to to change to a fall back
//Font if the current text doesn't fit in it's size;
function CheckToDownSizeFont(Font _FallBackFont, FLOAT _FallBackFontSpacing)
{
    m_DownSizeFont = _FallBackFont;
    m_fDownSizeFontSpacing = _FallBackFontSpacing;
    m_bCheckForDownSizeFont = true;
    m_bSetParam=true;
}


//===========================================================================================================
// This function indicate if text fits in the button width
//===========================================================================================================
function BOOL IsFontDownSizingNeeded()
{
    local FLOAT W, H, TextWidth, TextXPos;	
    local Canvas C;

    C = class'Actor'.static.GetCanvas();

    if(m_buttonFont != NONE)
		C.Font = m_buttonFont;
	else
		C.Font = Root.Fonts[Font];

	TextSize(C, Text, W, H );

    TextWidth = W + (Len(Text) * m_fFontSpacing);
	
	switch(Align)
	{
	case TA_Left:
		TextXPos = m_fLMarge;
		break;
	case TA_Right:
		TextXPos = WinWidth - m_fRMarge - TextWidth;
		break;
	case TA_Center:
		TextXPos = (WinWidth - TextWidth) / 2;
		break;
	}		
	
    return TextXPos + TextWidth > WinWidth;                  
    
}


function ResizeToText()
{
	WinWidth = m_fMaxWinWidth;
	m_bResizeToText=true;
    m_bSetParam=true;
}

function SetButtonBorderColor( Color _vButtonBorderColor)
{
    m_bDefineBorderColor = true;
    m_BorderColor = _vButtonBorderColor;
}

function INT GetButtonType()
{
    return m_eButtonType;
}

defaultproperties
{
     m_iDrawStyle=1
     m_bSetParam=True
     m_fLMarge=2.000000
     m_vButtonColor=(B=255,G=255,R=255)
     m_iButtonID=-1
}
