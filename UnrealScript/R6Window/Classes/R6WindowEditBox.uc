//=============================================================================
//  R6WindowEditBox.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6WindowEditBox extends UWindowEditBox;

var string		m_szCurValue;				// the current value equal to value of the edit box
var string		m_szValueToDisplay;			// what's displaying

var FLOAT		m_fYTextPos;					// the position of the text in y
var FLOAT		m_fTextHeight;

var bool		bCaps;

#ifdefDEBUG
var BOOL		m_bDisplayEditBoxProperties;
var bool		m_bOldShowCaret;
var bool	    m_bOldCanEdit;
var bool		m_bOldAllSelected;
var BOOL        m_bOldCurrentlyEditing;
var bool		m_bOldHasKeyboardFocus;
#endif

var Region  m_RBGEditTexture;       // BackGround texture Region
var Texture m_TBGEditTexture;
var FLOAT   m_fYBGPos;




function BeforePaint( Canvas C, FLOAT X, FLOAT Y)
{
	local FLOAT W, H;
	local INT i;

	C.Font = Root.Fonts[Font];

	if (m_szCurValue != Value)
	{
		m_szCurValue = Value;

		Super.BeforePaint(C, X, Y); // only assign font

		// If this is a password, replace the text by "*"'s
		if ( bPassword )
		{
			m_szValueToDisplay = "";
			for ( i = 0; i < len(Value); i++ )
				m_szValueToDisplay = m_szValueToDisplay $ "*";
		}
		else
		{
			if (bCaps)
				m_szValueToDisplay = Caps(Value);
			else
				m_szValueToDisplay = Value;
		}

		TextSize(C, "W", W, H);
		m_fTextHeight = H;
		m_fYTextPos = (WinHeight - H) / 2;
		m_fYTextPos = FLOAT(INT(m_fYTextPos + 0.5));
	}
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
	local FLOAT fStringLeftOfCaretW, H;

#ifdefDEBUG
	if (m_bDisplayEditBoxProperties)
	{
		if ( (m_bOldShowCaret != bShowCaret) ||
			 (m_bOldCanEdit != bCanEdit) ||
			 (m_bOldAllSelected != bAllSelected) ||
			 (m_bOldCurrentlyEditing != m_CurrentlyEditing) ||
			 (m_bOldHasKeyboardFocus != bHasKeyboardFocus) )
		{
			log("===================================================");
			log("m_CurrentlyEditing"@m_CurrentlyEditing);
			log("bHasKeyboardFocus"@bHasKeyboardFocus);
			log("bShowCaret"@bShowCaret);
			log("bCanEdit"@bCanEdit);
			log("bAllSelected"@bAllSelected);
			m_bOldShowCaret			= bShowCaret;
			m_bOldCanEdit			= bCanEdit;
			m_bOldAllSelected		= bAllSelected;
			m_bOldCurrentlyEditing	= m_CurrentlyEditing;
			m_bOldHasKeyboardFocus	= bHasKeyboardFocus;
		}
	}
#endif

    TextSize(C, Left(m_szValueToDisplay, CaretOffset), fStringLeftOfCaretW, H);

	if (m_bDrawEditBoxBG)
	{
		PaintEditBoxBG( C);
	}

	if(fStringLeftOfCaretW + Offset < 0)
    {
		Offset = -fStringLeftOfCaretW;
    }

    if(fStringLeftOfCaretW + Offset > (WinWidth - 2))
	{
		Offset = (WinWidth - 2) - fStringLeftOfCaretW;
		if(Offset > 0)
        {
            Offset = 0;
        }
	}

        
    if(bShowLog)
    {
        log("Offset After"@Offset);
        bShowLog = false;
    }
    

	C.SetDrawColor(TextColor.R,TextColor.G,TextColor.B);
	

	if(m_CurrentlyEditing && bAllSelected)
	{
    
        C.Style = ERenderStyle.STY_Alpha;
        C.SetDrawColor(Root.Colors.m_LisBoxSelectionColor.R, Root.Colors.m_LisBoxSelectionColor.G, Root.Colors.m_LisBoxSelectionColor.B,Root.Colors.EditBoxSelectAllAlpha);
		
        DrawStretchedTexture(C, Offset + 1, m_fYBGPos, fStringLeftOfCaretW, m_RBGEditTexture.H, Texture'UWindow.WhiteTexture');

        // Invert Colors
		//C.SetDrawColor(255 ^ C.DrawColor.R, 255 ^ C.DrawColor.G, 255 ^ C.DrawColor.B);
        
        C.Style = ERenderStyle.STY_Alpha;        
        C.SetDrawColor(Root.Colors.m_LisBoxSelectedTextColor.R, Root.Colors.m_LisBoxSelectedTextColor.G, Root.Colors.m_LisBoxSelectedTextColor.B);

	}

	ClipText(C, Offset + 1, m_fYTextPos,  m_szValueToDisplay);

	if( (!m_CurrentlyEditing) || (!bHasKeyboardFocus) || (!bCanEdit) )
    {
		bShowCaret = False;
    }
	else
	{
		if((GetTime() > LastDrawTime + 0.3) || (GetTime() < LastDrawTime))
		{
			LastDrawTime = GetLevel().GetTime();
			bShowCaret = !bShowCaret;
		}
	}
    

	if(bShowCaret)
	    ClipText(C, Offset + fStringLeftOfCaretW - 1, m_fYTextPos, "|");
}

function PaintEditBoxBG( Canvas C)
{
	C.Style = ERenderStyle.STY_Alpha;

	if (m_fTextHeight > m_RBGEditTexture.H)
	{
//		log("Your font for BG of editbox is too big"@m_fTextHeight@"suppose to be less than 13"@m_szValueToDisplay);
		m_fYBGPos = m_fYTextPos;
	}
	else
	{
		m_fYBGPos = (m_RBGEditTexture.H - m_fTextHeight) * 0.5;
		m_fYBGPos = INT(m_fYBGPos + 0.5);

		m_fYBGPos = m_fYTextPos - m_fYBGPos;
	}

    DrawStretchedTextureSegment( C, 0, m_fYBGPos, WinWidth, m_RBGEditTexture.H, // this part of texture should not be stretched in H
                                    m_RBGEditTexture.X, m_RBGEditTexture.Y, m_RBGEditTexture.W, m_RBGEditTexture.H, m_TBGEditTexture);
}

defaultproperties
{
     m_TBGEditTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     m_RBGEditTexture=(X=114,Y=47,W=2,H=13)
     m_szCurValue="//N"
     bSelectOnFocus=True
     m_bDrawEditBoxBG=True
}
