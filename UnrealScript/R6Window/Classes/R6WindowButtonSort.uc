//=============================================================================
//  R6WindowButtonSort.uc : Text buttons with triangle for type of sort
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/09/16 Created by Yannick Joly
//=============================================================================

class R6WindowButtonSort extends UWindowButton;

var Texture			m_TSortIcon;			// The icon for sort

var Region			m_RSortIcon;			// The region of the triangle -- representation of ascending--descending

var font			m_buttonFont;

var FLOAT			m_fLMarge;
var FLOAT			m_fXSortIconPos;		// pos in X of the icon
var FLOAT			m_fYSortIconPos;		// pos in Y of the icon

var bool			m_bDrawSimpleBorder;
var bool			m_bSetParam;            // Use to set the param in before paint one time
var BOOL			m_bAscending;			// The selection is ascending or descending
var BOOL			m_bDrawSortIcon;		// This button have to draw the sort icon
var BOOL			m_bAbleToDrawSortIcon;	// If the button have enought space to draw the sort icon



function BeforePaint(Canvas C, FLOAT X, FLOAT Y)
{
	local FLOAT W, H, fWidth;	
	
    if (m_bSetParam)
    {
	    m_bSetParam = false;

		if(Text != "")
		{
	        if(m_buttonFont != NONE)
		        C.Font = m_buttonFont;
	        else
		        C.Font = Root.Fonts[Font];

	        TextSize(C, Text, W, H);

			fWidth = WinWidth;
			// verify if you have enougth space to place the triangle, at the end of the button
			if ( W + m_RSortIcon.W + 5 < WinWidth) // 5 --> 2 for borders and 3 for SortIcon space to the end
			{
				m_bAbleToDrawSortIcon = true;
				fWidth = WinWidth - m_RSortIcon.W - 5; // Left and right borders

				m_fXSortIconPos = WinWidth - m_RSortIcon.W - 4; // 4 is an offset (1 for the border)

				m_fYSortIconPos = (WinHeight - m_RSortIcon.H) / 2;
				m_fYSortIconPos = FLOAT(INT(m_fYSortIconPos + 0.5));
			}
	        
	        switch(Align)
	        {
	        case TA_Left:
		        TextX = m_fLMarge;
		        break;
	        case TA_Right:
		        TextX = fWidth - W; // - (Len(Text) * m_fFontSpacing);
		        break;
	        case TA_Center:
		        TextX = ((fWidth - W) / 2) + 0.5; // - (Len(Text) * m_fFontSpacing)) / 2;
		        break;
	        }
	        
	        TextY = (WinHeight - H) / 2;
            TextY = FLOAT(INT(TextY+0.5));
        }	
    }
}


function Paint(Canvas C, float X, float Y)
{
	if(Text != "")
	{
      	C.Style = ERenderStyle.STY_Normal;
		C.SpaceX = 0; // no space between letter
        C.Font = m_buttonFont;

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
	    }	
	}

	// Draw the sort icon
	if (m_bDrawSortIcon)
	{
		if (m_bAbleToDrawSortIcon)
		{
			C.Style = ERenderStyle.STY_Alpha;

			if (m_bAscending)
			{
				DrawStretchedTextureSegmentRot( C, m_fXSortIconPos, m_fYSortIconPos, m_RSortIcon.W, m_RSortIcon.H, 
												m_RSortIcon.X, m_RSortIcon.Y, m_RSortIcon.W, m_RSortIcon.H, m_TSortIcon, -1.57);		
			}
			else
			{
				DrawStretchedTextureSegmentRot( C, m_fXSortIconPos, m_fYSortIconPos, m_RSortIcon.W, m_RSortIcon.H, 
												m_RSortIcon.X, m_RSortIcon.Y, m_RSortIcon.W, m_RSortIcon.H, m_TSortIcon, 1.57);		
			}
		}
	}

    if(m_bDrawSimpleBorder)
    {
        DrawSimpleBorder(C);
    }
}

defaultproperties
{
     m_bDrawSimpleBorder=True
     m_bSetParam=True
     m_fLMarge=2.000000
     m_TSortIcon=Texture'R6MenuTextures.Gui_BoxScroll'
     m_RSortIcon=(X=80,Y=53,W=6,H=7)
     m_iButtonID=-1
}
