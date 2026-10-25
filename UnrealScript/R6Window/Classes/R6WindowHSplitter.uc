//=============================================================================
//  R6WindowHSplitter.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

//=============================================================================
// R6WindowHSplitter - a horizontal splitter component
//=============================================================================
class R6WindowHSplitter extends UWindowLabelControl;

enum ESplitterType
{
    ST_TopWin,
    ST_SplitterTop,
    ST_SplitterBottom
};

var ESplitterType       m_eSplitterType;


function BeforePaint(Canvas C, FLOAT X, FLOAT Y)
{
	local FLOAT W, H;
    
    C.Font = Root.Fonts[Font];
	
	TextSize(C, Text, W, H);
	//WinHeight = H+1;
	//WinWidth = W+1;
	TextY = (WinHeight - H) / 2;
	switch (Align)
	{
		case TA_Left:
			break;
		case TA_Center:
			TextX = (WinWidth - W)/2;
			break;
		case TA_Right:
			TextX = WinWidth - W;
			break;
	}
}

function Paint(Canvas C, FLOAT X, FLOAT Y) 
{
	
    switch(m_eSplitterType)
    {
    case ST_TopWin:
        R6WindowLookAndFeel(LookAndFeel).DrawWinTop(self,C);
        break;
    case ST_SplitterTop:
        R6WindowLookAndFeel(LookAndFeel).DrawHSplitterT(self,C);
        break;
    case ST_SplitterBottom:
        R6WindowLookAndFeel(LookAndFeel).DrawHSplitterB(self,C);
    }
    
    	
    Super.Paint(C,X,Y);
}

defaultproperties
{
}
