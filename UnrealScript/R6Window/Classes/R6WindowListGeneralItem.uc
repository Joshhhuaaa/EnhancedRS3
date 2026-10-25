//=============================================================================
//  R6WindowListBoxItem.uc : Class used to hold the values for the entries
//  in the list of servers in the multi player menu.
//
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/28 * Created by Yannick Joly
//=============================================================================
class R6WindowListGeneralItem extends UWindowListBoxItem;

//type of button to create?
var R6WindowCounter				m_pR6WindowCounter;
var R6WindowButtonBox			m_pR6WindowButtonBox;
var R6WindowComboControl		m_pR6WindowComboControl;
var bool						m_bFakeItem;				// placeholder item, not drawn

defaultproperties
{
}
