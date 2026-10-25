//=============================================================================
//  R6MenuMPAdvGearPrimaryWeapon.uc : This will display the current 2D model
//                        of the Primary weapon for the current 
//                        operative in adversial mode
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/14 * Created by Alexandre Dionne
//=============================================================================


class R6MenuMPAdvGearPrimaryWeapon extends R6MenuGearPrimaryWeapon;

                
function Created()
{
    
    m_2DWeapon = R6WindowButtonGear(CreateWindow(class'R6WindowButtonGear', 0, 0, m_2DWeaponWidth, WinHeight /*m_2DWeaponHeight*/, self));
    m_2DWeapon.bUseRegion               = true;
    m_2DWeapon.m_iDrawStyle             = 5;
    
    m_2DBullet = R6WindowButtonGear(CreateWindow(class'R6WindowButtonGear', m_2DWeaponWidth, 0, WinWidth - m_2DWeaponWidth, WinHeight/2, self));
    m_2DBullet.bUseRegion               = true;
    m_2DBullet.m_iDrawStyle             = 5;
    
    m_2DWeaponGadget = R6WindowButtonGear(CreateWindow(class'R6WindowButtonGear', m_2DWeaponWidth, m_2DBullet.WinTop + m_2DBullet.WinHeight, m_2DBullet.WinWidth, WinHeight/2, self));
    m_2DWeaponGadget.bUseRegion               = true;
    m_2DWeaponGadget.m_iDrawStyle             = 5;   
    
    m_BorderColor	   = Root.Colors.GrayLight;	
    m_InsideLinesColor = Root.Colors.GrayLight;
    
}

//=================================================================
// SetBorderColor: set the border color
//=================================================================
function SetBorderColor( Color _NewColor)
{
	m_BorderColor = _NewColor;
}

defaultproperties
{
     m_bAssignAllButton=False
     m_bCenterTexture=True
}
