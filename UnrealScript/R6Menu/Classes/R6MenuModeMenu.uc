//=============================================================================
//  R6MenuModeMenu : ActionPoint Popup menu
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/30 * Created by Chaouky Garram
//=============================================================================

class R6MenuModeMenu extends R6MenuFramePopup;

function Created()
{
	Super.Created();
    
    m_szWindowTitle = Localize("Order","Mode","R6Menu");
    
    m_ButtonList = R6MenuListModeButton(CreateWindow(class'R6MenuListModeButton', m_iFrameWidth, m_fTitleBarHeight, 100, 100, self));
}

function HideWindow()
{
    Super.HideWindow();
    
    R6MenuListModeButton(m_ButtonList).HidePopup();
}

defaultproperties
{
     m_iNbButton=3
}
