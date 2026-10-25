//=============================================================================
//  R6MenuMPAdvGearGadget.uc : This will display the current 2D model
//                        of one of the 2 gadgets selected for the current 
//                        operative in adversial
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/14 * Created by Alexandre Dionne
//=============================================================================


class R6MenuMPAdvGearGadget extends R6MenuGearGadget;

function Created()
{
    m_2DGadgetWidth = WinWidth;
    Super.Created();     
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
