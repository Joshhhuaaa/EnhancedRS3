//=============================================================================
//  R6WindowStayDownButton.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6WindowStayDownButton extends R6WindowButton;

var     BOOL    m_bCanBeUnselected;
var     bool    m_bCheckSelectState;
var     bool    m_bUseOnlyNotifyMsg; // the state of button selection is change outside, by a notify msg to button creator

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
	local float tempSpace;
	
	if(m_buttonFont != NONE)
		C.Font = m_buttonFont;
	else
	C.Font = Root.Fonts[Font];

    C.Style =m_iDrawStyle;
	if(bDisabled) {
		if(DisabledTexture != None)
		{
			if(bUseRegion)
            {
				DrawStretchedTextureSegment( C, ImageX, ImageY, DisabledRegion.W*RegionScale, DisabledRegion.H*RegionScale, 
											DisabledRegion.X, DisabledRegion.Y, 
											DisabledRegion.W, DisabledRegion.H, DisabledTexture );
            }
			else if(bStretched)
            {
				DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, DisabledTexture );
            }
			else
            {
				DrawClippedTexture( C, ImageX, ImageY, DisabledTexture);
            }
		}
	} else {
		if(bMouseDown || m_bSelected)
		{
			if(DownTexture != None)
			{
				if(bUseRegion)
                {
					DrawStretchedTextureSegment( C, ImageX, ImageY, DownRegion.W*RegionScale, DownRegion.H*RegionScale, 
												DownRegion.X, DownRegion.Y, 
												DownRegion.W, DownRegion.H, DownTexture );
                }
				else if(bStretched)
                {
					DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, DownTexture );
                }
				else
                {
					DrawClippedTexture( C, ImageX, ImageY, DownTexture);
                }
			}
		} else {
			if(MouseIsOver()) {
				if(OverTexture != None)
				{
					if(bUseRegion)
                    {
						DrawStretchedTextureSegment( C, ImageX, ImageY, OverRegion.W*RegionScale, OverRegion.H*RegionScale, 
													OverRegion.X, OverRegion.Y, 
													OverRegion.W, OverRegion.H, OverTexture );
                    }
					else if(bStretched)
                    {
						DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, OverTexture );
                    }
					else
                    {
						DrawClippedTexture( C, ImageX, ImageY, OverTexture);
                    }
				}
			} else {
				if(UpTexture != None)
				{
					if(bUseRegion)
                    {
						DrawStretchedTextureSegment( C, ImageX, ImageY, UpRegion.W*RegionScale, UpRegion.H*RegionScale, 
													UpRegion.X, UpRegion.Y, 
													UpRegion.W, UpRegion.H, UpTexture );
                    }
					else if(bStretched)
                    {
						DrawStretchedTexture( C, ImageX, ImageY, WinWidth, WinHeight, UpTexture );
                    }
					else
                    {
						DrawClippedTexture( C, ImageX, ImageY, UpTexture);
                    }
				}
			}
		}
	}
    C.Style =1;
	if(Text != "")
	{
/*
        if( (m_bSelected) && (!bDisabled))
			C.SetDrawColor(m_SelectedTextColor.R,m_SelectedTextColor.G,m_SelectedTextColor.B);		
		else
			C.SetDrawColor(TextColor.R,TextColor.G,TextColor.B);		
*/
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
		
		tempSpace = C.SpaceX;
		C.SpaceX = m_fFontSpacing;	
		ClipText(C, TextX, TextY, Text, True);		
		C.SpaceX = tempSpace;
		
	}
}

function LMouseDown(FLOAT X, FLOAT Y)
{
    local bool bChangeSelection;

	Super.LMouseDown(X, Y);
	if(bDisabled)
		return;

    if ( !m_bUseOnlyNotifyMsg)
    {
        if(m_bCanBeUnselected)
        {
            bChangeSelection = true;

            //if it's already selected don't change the display
            if (m_bCheckSelectState)
            {
                bChangeSelection = !m_bSelected;
            }

            if (bChangeSelection)
                m_bSelected = !m_bSelected;
        }
    }
}

defaultproperties
{
     m_bCanBeUnselected=True
}
