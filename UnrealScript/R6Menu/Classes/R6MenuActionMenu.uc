//=============================================================================
//  R6MenuActionMenu : ActionPoint Popup menu
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/20 * Created by Chaouky Garram
//=============================================================================

class R6MenuActionMenu extends R6MenuFramePopup;

function Created()
{
	Super.Created();
    
    m_szWindowTitle = Localize("Order","Action","R6Menu");

    m_ButtonList = R6MenuListActionButton(CreateWindow(class'R6MenuListActionButton', 1, m_fTitleBarHeight,100,100, self));
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
     m_iNbButton=7
}
