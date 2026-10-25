//=============================================================================
//  R6WindowListAreaItem.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6WindowListAreaItem extends UWindowListBoxItem;

var R6WindowArea        m_Area;



function SetFront()
{
    if(m_Area!=NONE)
    {
        m_Area.BringToFront();
    }
}


function SetBack()
{
    if(m_Area!=NONE)
    {
        m_Area.SendToBack();
    }
}

defaultproperties
{
}
