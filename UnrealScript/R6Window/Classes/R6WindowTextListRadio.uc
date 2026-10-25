//=============================================================================
//  R6WindowTextListRadio.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6WindowTextListRadio extends R6WindowListRadio;

//var color   TextColor;           color for text            N.B. var already define in class UWindowDialogControl
var Color   m_SelTextColor;     // color for selected text

function Paint(Canvas C, FLOAT fMouseX, FLOAT fMouseY)
{
    R6WindowLookAndFeel(LookAndFeel).List_DrawBackground(self,C);

    Super.Paint( C, fMouseX, fMouseY);
}

function DrawItem(Canvas C, UWindowList Item, FLOAT X, FLOAT Y, FLOAT W, FLOAT H)
{
	local FLOAT fWidth, fHeight, fTextX, fTextY;
	local UWindowListBoxItem pListBoxItem;

	pListBoxItem = UWindowListBoxItem(Item);

	if(pListBoxItem.bSelected)
	{		
		C.SetDrawColor(m_SelTextColor.R,m_SelTextColor.G,m_SelTextColor.B);		
	}
	else
	{		
		C.SetDrawColor(TextColor.R,TextColor.G,TextColor.B);		
	}

	C.Font = Root.Fonts[F_Normal];

	if(pListBoxItem.HelpText!="")
    {
        TextSize(C, pListBoxItem.HelpText, W, H);
	    
        fTextY = (m_fItemHeight - H) / 2;
        
	    switch(Align)
	    {
	    case TA_Left:
		    fTextX = 2;
		    break;
	    case TA_Right:
		    fTextX = WinWidth - W;
		    break;
	    case TA_Center:
		    fTextX = (WinWidth - W) / 2;
		    break;
	    }

        ClipText(C, X+fTextX, Y+fTextY, pListBoxItem.HelpText);
    }
    
	C.SetDrawColor(255,255,255);		
}

defaultproperties
{
     m_SelTextColor=(B=255,G=255,R=255)
     m_fItemHeight=16.000000
     ListClass=Class'UWindow.UWindowListBoxItem'
     Align=TA_Center
}
