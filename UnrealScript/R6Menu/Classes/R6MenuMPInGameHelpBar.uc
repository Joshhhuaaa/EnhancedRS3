//=============================================================================
//  R6MenuMPInGameHelpBar.uc : The help text bar for in game menu
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/28 * Created by Yannick Joly
//=============================================================================
class R6MenuMPInGameHelpBar extends R6MenuHelpTextBar;

var string	m_szExternTip;
var BOOL	m_bUseExternSetTip;

function BeforePaint(Canvas C, FLOAT X, FLOAT Y)
{
    local FLOAT W,H;
   
    C.Font = Root.Fonts[F_SmallTitle];// TODO: see why I need to do that after click on a button
    
	if (m_bUseExternSetTip)
	{
		m_szText = GetToolTip();

		if (m_szText == "")
		    m_szText = m_szDefaultText;
	}
	else
	{
	    m_szText = m_szDefaultText;

		if (Root.MouseWindow!=None)
		{
			if(Root.MouseWindow.ToolTipString!="")
			{     
				m_szText = Root.MouseWindow.ToolTipString;
			}        
		}
	}

    if(m_szText != "")
    {
        TextSize(C, m_szText, W, H);
        m_fTextX = (WinWidth - W) / 2;
	    m_fTextY = (WinHeight - H) / 2;
        m_fTextY = FLOAT(INT(m_fTextY+0.5));
    }
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    DrawSimpleBorder(C);

    C.Style = ERenderStyle.STY_Alpha; //.STY_Normal;
    C.Font = Root.Fonts[F_SmallTitle];// TODO: see why I need to do that after click on a button
    ClipText(C, m_fTextX, m_fTextY, m_szText);
}

function SetToolTip( string _szToolTip)
{
	m_szExternTip = _szToolTip;
}

function string GetToolTip()
{
	return m_szExternTip;
}

defaultproperties
{
}
