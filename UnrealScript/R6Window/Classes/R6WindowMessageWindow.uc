//=============================================================================
//  R6WindowMessageWindow.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6WindowMessageWindow extends R6WindowFramedWindow;

var string	    m_szMessage;
var TextAlign   m_MessageAlign;
var TextAlign   m_MessageAlignY;
var Color       m_MessageColor;
var FLOAT       m_fMessageX, m_fMessageY;
var FLOAT       m_fMessageTab;

function BeforePaint(Canvas C, FLOAT X, FLOAT Y)
{	
	local FLOAT W, H;

	Super.BeforePaint(C, X, Y);

    if(m_szMessage != "")
    {
        C.Font = Root.Fonts[F_Normal];
    	TextSize(C, m_szMessage, W, H);

        if(m_MessageAlignY==TA_Center)
        {
            m_fMessageY = LookAndFeel.FrameT.H + (WinHeight - LookAndFeel.FrameT.H - LookAndFeel.FrameB.H - H) / 2;
        }
        else
        {
            m_fMessageY = LookAndFeel.FrameT.H;
        }

	    switch(m_MessageAlign)
	    {
	    case TA_Left:
		    m_fMessageX = LookAndFeel.FrameL.W + m_fMessageTab;
		    break;
	    case TA_Right:
		    m_fMessageX = WinWidth - W - LookAndFeel.FrameL.W;
		    break;
	    case TA_Center:
		    m_fMessageX = (WinWidth - W) / 2;
		    break;
	    }
    }
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
	Super.Paint(C,X,Y);

	if(m_szMessage!="")
	{
		
		C.SetDrawColor(m_MessageColor.R,m_MessageColor.G,m_MessageColor.B);
		
		ClipText(C, m_fMessageX, m_fMessageY, m_szMessage, true);

		C.SetDrawColor(255,255,255);		
	}
}

defaultproperties
{
     m_MessageColor=(B=255,G=255,R=255)
}
