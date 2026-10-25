//=============================================================================
//  R6WindowTabControl.uc : Manage, display tab menu
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/02 * Created by Yannick Joly
//=============================================================================
class R6WindowTabControl extends UWindowTabControl;

function Created()
{
	Super.Created();

    m_bNotDisplayBkg = True;
}

function GotoTab( UWindowTabControlItem NewSelected, optional bool bByUser )
{
    local FLOAT fGlobalX;
    local FLOAT fGlobalY;

	if(SelectedTab != NewSelected && bByUser)
		LookAndFeel.PlayMenuSound(Self, MS_ChangeTab);
	SelectedTab = NewSelected;
	TabArea.bShowSelected = True;

    // we advice the manager
    Notify(DE_Click);
}

function INT GetSelectedTabID()
{
	local UWindowTabControlItem I;
	for(I = UWindowTabControlItem(Items.Next); I != None; I = UWindowTabControlItem(I.Next))
	{
        if (I == SelectedTab)
            return I.m_iItemID;
	}

	return 0;		
}


// why we overwrite tooltip string overhere, to transmit the string to the parent window where the management of
// this string is done
function ToolTip(string strTip) 
{
    ParentWindow.Tooltip(strTip);
}

defaultproperties
{
}
