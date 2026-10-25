//=============================================================================
//  R6MenuHelpWindow.uc : This is the help window where the tooltip is suppose to be display
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/11 * Created by Yannick Joly
//=============================================================================
class R6MenuHelpWindow extends R6WindowSimpleFramedWindowExt;

var BOOL			m_bForceRefreshOnSameTip;			// force to clear wrapped text area for a same tip

function Created()
{
    local UWindowWrappedTextArea pHelpZone;
    local FLOAT fWidth;
    fWidth = 1;

    /* Std position and size of this window in the menu
    WinTop    = 125;
    WinLeft   = 430;
    WinWidth  = 394;
    WinHeight = 40;
    */

    m_ClientArea = CreateWindow(class'UWindowWrappedTextArea', 0, 0, WinWidth, WinHeight, OwnerWindow);

    SetBorderParam( 0, 7, 0, fWidth, Root.Colors.White);         // Top border
    SetBorderParam( 1, 7, 0, fWidth, Root.Colors.White);         // Bottom border
    ActiveBorder( 2, false);                         // Left border
    ActiveBorder( 3, false);                         // Rigth border
    ActiveBackGround( true, Root.Colors.Black);                  // draw background

    m_eCornerType = All_Corners;
    SetCornerColor( 3, Root.Colors.White);   // 3 = all corners

    //create the tooltip text window zone
	pHelpZone = UWindowWrappedTextArea(m_ClientArea);
	pHelpZone.SetScrollable(false);
}


/////////////////////////////////////////////////////////////////
// display the help text in the m_pHelpTextWindow (derivate for uwindowwindow
/////////////////////////////////////////////////////////////////
function ToolTip(string strTip) 
{
	if ((strTip != ToolTipString) || (m_bForceRefreshOnSameTip))
	{
		ToolTipString = strTip;
		UWindowWrappedTextArea(m_ClientArea).Clear();

        if (ToolTipString != "")
        {
            UWindowWrappedTextArea(m_ClientArea).m_fXOffset = 5;
            UWindowWrappedTextArea(m_ClientArea).m_fYOffset = 5;
		    UWindowWrappedTextArea(m_ClientArea).AddText(ToolTipString, Root.Colors.ToolTipColor, Root.Fonts[F_HelpWindow]);					
        }
	}
}

//==========================================================================
// AddTipText: Call this after a new tooltip. Force to put the next on the next line
//==========================================================================
function AddTipText( string _szNewText)
{
	UWindowWrappedTextArea(m_ClientArea).AddText( _szNewText, Root.Colors.ToolTipColor, Root.Fonts[F_HelpWindow]);
}

defaultproperties
{
}
