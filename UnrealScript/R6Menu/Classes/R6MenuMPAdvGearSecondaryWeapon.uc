//=============================================================================
//  R6MenuMPAdvGearSecondaryWeapon.uc : This will display the current 2D model
//                        of the secondary weapon for the current multiplayer adverserial
//                        operative
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/14 * Created by Alexandre Dionne
//=============================================================================


class R6MenuMPAdvGearSecondaryWeapon extends R6MenuGearSecondaryWeapon;


var     FLOAT                       m_fWeaponWidth;
var     FLOAT                       m_fBulletWidth;

function Created()
{
    m_2DWeapon = R6WindowButtonGear(CreateWindow(class'R6WindowButtonGear', 0, 0, m_fWeaponWidth, WinHeight, self));
    m_2DWeapon.bUseRegion               = true;
    m_2DWeapon.m_iDrawStyle             = 5;

    m_2DBullet = R6WindowButtonGear(CreateWindow(class'R6WindowButtonGear', m_fWeaponWidth, 0, m_fBulletWidth, WinHeight, self));
    m_2DBullet.bUseRegion               = true;
    m_2DBullet.m_iDrawStyle             = 5;
    
    m_2DWeaponGadget = R6WindowButtonGear(CreateWindow(class'R6WindowButtonGear', m_fWeaponWidth + m_2DBullet.WinWidth, 0, WinWidth - m_2DBullet.WinWidth - m_2DWeapon.WinWidth, WinHeight, self));
    m_2DWeaponGadget.bUseRegion               = true;
    m_2DWeaponGadget.m_iDrawStyle             = 5;   

    m_BorderColor	   = Root.Colors.GrayLight;	
    m_InsideLinesColor = Root.Colors.GrayLight;
 
}


function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    
   DrawSimpleBorder(C);

   //Draw Lines between elements

    C.Style = ERenderStyle.STY_Alpha;
    C.SetDrawColor(m_InsideLinesColor.R, m_InsideLinesColor.G, m_InsideLinesColor.B);

    DrawStretchedTextureSegment(C, m_2DWeapon.WinWidth , 0 ,  m_LinesRegion.W, WinHeight, m_LinesRegion.X, m_LinesRegion.Y, m_LinesRegion.W, m_LinesRegion.H, m_LinesTexture);
    DrawStretchedTextureSegment(C, m_2DBullet.WinLeft + m_2DBullet.WinWidth , 0 ,  m_LinesRegion.W, WinHeight , m_LinesRegion.X, m_LinesRegion.Y, m_LinesRegion.W, m_LinesRegion.H, m_LinesTexture);
    
 
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
     m_fWeaponWidth=86.000000
     m_fBulletWidth=73.000000
     m_bAssignAllButton=False
     m_bCenterTexture=True
}
