//=============================================================================
//  R6MenuMPManageTab.uc : Manage Tab for multiplayer menu
//                                         
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/03 * Created by Yannick Joly
//=============================================================================
class R6MenuMPManageTab extends UWindowDialogClientWindow;

var R6WindowTabControl                m_pMainTabControl;

function Created()
{
    m_pMainTabControl = R6WindowTabControl(CreateControl(class'R6WindowTabControl', 0, 0, WinWidth, WinHeight));
    m_pMainTabControl.SetFont( F_TabMainTitle);

    LookAndFeel.Size_TabXOffset = 0;
    LookAndFeel.Size_TabAreaHeight = WinHeight - LookAndFeel.Size_TabAreaOverhangHeight;
}

/////////////////////////////////////////////////////////////////
// this method add tab in a list use by UWindowTabControlTabArea
/////////////////////////////////////////////////////////////////
function AddTabInControl( string _Caption, string _TabToolTip, INT _ItemID)
{
    local UWindowTabControlItem pItem;

    if (m_pMainTabControl != NONE)
    {
        // the return item is not use for now...
        pItem = m_pMainTabControl.AddTab(_Caption, _ItemID);
        pItem.HelpText = _TabToolTip;
//        pItem.SetFixTabSize( 160);
        pItem.SetItemColor( Root.Colors.White, Root.Colors.GrayLight);
    }
}


/////////////////////////////////////////////////////////////////
// this method receive a "msg" sent by ? dialogclientwindow or uwindowwindow
/////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
    local R6LanServers          pLanServers;
    local R6GSServers           pGameService;

	if(E == DE_Click)
	{
        // Advise Parent window
        if( R6MenuMultiPlayerWidget(OwnerWindow) != None)
        {
//            log("R6MenuMultiPlayerWidget");
            R6MenuMultiPlayerWidget(OwnerWindow).ManageTabSelection( m_pMainTabControl.GetSelectedTabID());
        }
        else // R6MenuMPCreateGameWidget
        {
//            log("R6MenuMPCreateGameWidget");
            R6MenuMPCreateGameWidget(OwnerWindow).ManageTabSelection( m_pMainTabControl.GetSelectedTabID());
        }
	}

    // If the user right clicks on a server, the right click menu
    // will appear, used to add or delete a favorite server

    if ( E == DE_RClick && C.IsA('R6WindowServerListBox') )
    {
        if( R6MenuMultiPlayerWidget(OwnerWindow) != None)
            R6MenuMultiPlayerWidget(OwnerWindow).DisplayRightClickMenu();
    }

    // Double click on server -> Join that server

    if ( E == DE_DoubleClick && C.IsA('R6WindowServerListBox') )
    {
         R6MenuMultiPlayerWidget(OwnerWindow).JoinSelectedServerRequested();
    }

    // If the user add or delete a favorites, call the 
    // UpdateFavorites function to perform the operation

    if ( E == DE_Enter && C.IsA('R6WindowRightClickMenu') )
    {
        if( R6MenuMultiPlayerWidget(OwnerWindow) != None)
            R6MenuMultiPlayerWidget(OwnerWindow).UpdateFavorites();
    }

}

defaultproperties
{
}
