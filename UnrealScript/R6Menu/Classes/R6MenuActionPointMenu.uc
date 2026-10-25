//=============================================================================
//  R6MenuActionPointMenu : ActionPoint Popup menu
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/20 * Created by Chaouky Garram
//=============================================================================

class R6MenuActionPointMenu extends R6MenuFramePopup;

function Created()
{
	Super.Created();
    
    m_szWindowTitle = Localize("Order","Type","R6Menu");
    
    m_ButtonList = R6MenuListActionTypeButton(CreateWindow(class'R6MenuListActionTypeButton', m_iFrameWidth, m_fTitleBarHeight,100,100, self));
}

function HideWindow()
{
    Super.HideWindow();
    
    R6MenuListActionTypeButton(m_ButtonList).HidePopup();
}

defaultproperties
{
     m_iNbButton=6
}
