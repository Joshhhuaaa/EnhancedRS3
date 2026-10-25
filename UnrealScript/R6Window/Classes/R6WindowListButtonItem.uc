//=============================================================================
//  R6WindowListButtonItem.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6WindowListButtonItem extends UWindowListBoxItem;

var R6WindowButton  m_Button;

function SetFront()
{
    if(m_Button!=NONE)
    {
        m_Button.BringToFront();
    }
}


function SetBack()
{
    if(m_Button!=NONE)
    {
        m_Button.SendToBack();
    }
}

defaultproperties
{
}
