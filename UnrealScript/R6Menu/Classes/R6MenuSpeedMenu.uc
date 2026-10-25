//=============================================================================
//  R6MenuSpeedMenu : ActionPoint Popup menu
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/30 * Created by Chaouky Garram
//=============================================================================

class R6MenuSpeedMenu extends R6MenuFramePopup;

function Created()
{
	Super.Created();
    
    m_szWindowTitle = Localize("Order","Speed","R6Menu");
    
    m_ButtonList = R6MenuListSpeedButton(CreateWindow(class'R6MenuListSpeedButton', m_iFrameWidth, m_fTitleBarHeight, 100, 100, self));
}

function AjustPosition(BOOL bDisplayUp, BOOL bDisplayLeft)
{
    m_bDisplayUp = bDisplayUp;
    m_bDisplayLeft = bDisplayLeft;
    
    if(m_bDisplayLeft == TRUE)
    {
        WinLeft -= (WinWidth + 6);
    }
}

defaultproperties
{
     m_iNbButton=3
}
