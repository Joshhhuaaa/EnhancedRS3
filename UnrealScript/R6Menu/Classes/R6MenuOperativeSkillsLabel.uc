//=============================================================================
//  R6MenuOperativeSkillsLabel.uc : Set Default Properties for the labels on the 
//                                  skills page
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/19 * Created by Alexandre Dionne
//=============================================================================

class R6MenuOperativeSkillsLabel extends R6WindowTextLabel;

var Color					m_NumericValueColor;					// the color of the numeric value

var string					m_szNumericValue;						// the numeric value

var FLOAT					m_fWidthOfFixArea;						// use a fix area width for the numeric value

function Created()
{
    m_Font = Root.Fonts[F_VerySmallTitle];    
}

function Paint(Canvas C, float X, float Y)
{
#ifdefDEBUG
//	m_BorderColor = Root.Colors.Red;
//	DrawSimpleBorder(C);
#endif

	if(Text != "")
	{
		C.Font = m_Font;
		C.SpaceX = m_fFontSpacing;		
		C.SetDrawColor(TextColor.R,TextColor.G,TextColor.B);		
        C.Style =m_TextDrawstyle;

		ClipText(C, TextX, TextY, Text, True);
	}

	if (m_szNumericValue != "")
	{
		DrawNumericValue(C);
	}
}

function DrawNumericValue( Canvas C)
{
	local FLOAT fX, fW, fH, fSizeOfBG;

	C.Font   = m_Font;
	C.SpaceX = m_fFontSpacing;		
    C.Style  = ERenderStyle.STY_Alpha;
	C.SetDrawColor(Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);		

	TextSize(C, m_szNumericValue, fW, fH);

	if (m_fWidthOfFixArea == 0)
	{
		fSizeOfBG = fW + 6; // 3 pixels left on each side

		DrawStretchedTextureSegment( C, WinWidth - fSizeOfBG, 0, fSizeOfBG, WinHeight,  
										m_BGTextureRegion.X, m_BGTextureRegion.Y, m_BGTextureRegion.W, m_BGTextureRegion.H, m_BGTexture );

		C.SetPos( WinWidth - fSizeOfBG + 3, m_fHBorderHeight); // + 3 to put the text inside the texture area
	}
	else
	{
		DrawStretchedTextureSegment( C, WinWidth - m_fWidthOfFixArea, 0, m_fWidthOfFixArea, WinHeight,  
										m_BGTextureRegion.X, m_BGTextureRegion.Y, m_BGTextureRegion.W, m_BGTextureRegion.H, m_BGTexture );

		// center the text
		fX = WinWidth - m_fWidthOfFixArea + ((m_fWidthOfFixArea - fW) / 2);

		C.SetPos( fX, m_fHBorderHeight);
	}

	C.SetDrawColor(m_NumericValueColor.R, m_NumericValueColor.G, m_NumericValueColor.B);
	C.DrawText( m_szNumericValue);
}

function SetNumericValue( INT _iOriginalValue, INT _iLastValue)
{
	local INT iTemp, iOriginalValue;

	iOriginalValue = Min(_iOriginalValue, 100);
	m_szNumericValue = string( Max(iOriginalValue, 0));

	iTemp = Min(_iLastValue, 100) - iOriginalValue;

	if ( iTemp != 0)
	{
		if (iTemp > 0)
		{
			m_szNumericValue = m_szNumericValue $ "(+" $ string(Min(iTemp, 100)) $ ")";
		}
		else
		{
			m_szNumericValue = m_szNumericValue $ "(-" $ string(Min(Abs(iTemp), 100)) $ ")";
		}
	}
}



	
		

defaultproperties
{
     m_bDrawBorders=False
     m_BGTextureRegion=(X=113,Y=47,W=2,H=13)
}
