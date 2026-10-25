//=============================================================================
//  R6WindowServerInfoBox.uc : Class used to manage the "list box" of 
//  server information.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/03 * Created by John Bennett
//=============================================================================

class R6WindowServerInfoPlayerBox extends R6WindowListBox;

var color   TextColor;          // color for text            N.B. var already define in class UWindowDialogControl
var Color   m_SelTextColor;     // color for selected text

var Font    m_Font;

var bool    m_bDrawBorderAndBkg;// draw the border and the background

function Created()
{
	Super.Created();
	
    m_VertSB.SetHideWhenDisable(false);

    TextColor           = Root.Colors.m_LisBoxNormalTextColor;
    m_SelTextColor      = Root.Colors.m_LisBoxSelectedTextColor;
}


function BeforePaint(Canvas C, FLOAT fMouseX, FLOAT fMouseY)
{
	local float TW,TH;
	C.Font = m_Font;//Root.Fonts[F_Normal];

	TextSize(C, "TEST", TW, TH);

    m_fItemHeight = TH + 2;  // 1 pixel each side

    
    m_VertSB.SetBorderColor(m_BorderColor);
    
    Super.BeforePaint(C, fMouseX, fMouseY);
}

function Paint(Canvas C, FLOAT fMouseX, FLOAT fMouseY)
{
    if (m_bDrawBorderAndBkg)
    {  
        R6WindowLookAndFeel(LookAndFeel).R6List_DrawBackground(self,C);    
    }

    Super.Paint( C, fMouseX, fMouseY);
}

function DrawItem(Canvas C, UWindowList Item, FLOAT X, FLOAT Y, FLOAT W, FLOAT H)
{
	local float TextY, TW,TH;
	local R6WindowListInfoPlayerItem pListInfoPlayerItem;

	pListInfoPlayerItem = R6WindowListInfoPlayerItem(Item);
    
	C.Style = ERenderStyle.STY_Alpha;

	C.Font = m_Font;//Root.Fonts[F_Normal];

	TextSize(C, "TEST", TW, TH);
	

	TextY = (H - TH) / 2;
    TextY = FLOAT(INT(TextY+0.5));

    // Draw the text


    X += pListInfoPlayerItem.fNameXOff;
    C.SetPos( X, Y+TextY );
    ClipTextWidth( C, X, Y+TextY, pListInfoPlayerItem.szPlName, pListInfoPlayerItem.fNameWidth );
//    C.DrawText(pListInfoPlayerItem.szPlName);

    X += pListInfoPlayerItem.fSkillsXOff;
    C.SetPos( X, Y+TextY );
    C.DrawText(pListInfoPlayerItem.iSkills);

    X += pListInfoPlayerItem.fTimeXOff;
    C.SetPos( X, Y+TextY );
    C.DrawText(pListInfoPlayerItem.szTime);
  
    X += pListInfoPlayerItem.fPingXOff;
    C.SetPos( X, Y+TextY );
    C.DrawText(pListInfoPlayerItem.iPing);
    
//    X += pListInfoPlayerItem.fRankXOff;
//    C.SetPos( X, Y+TextY );
//    C.DrawText(pListInfoPlayerItem.iRank);
    

}

defaultproperties
{
     m_SelTextColor=(B=255,G=255,R=255)
     m_fItemHeight=16.000000
     ListClass=Class'R6Window.R6WindowListInfoPlayerItem'
}
