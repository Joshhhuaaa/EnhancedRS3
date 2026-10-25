//=============================================================================
//  R6WindowRightClickMenu.uc : This class is used to create a "right-click"
//  menu at a given position.  A drop down menu will appear and the user
//  can select from the list of choices
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/24 * Created by John Bennett
//=============================================================================

class R6WindowRightClickMenu extends R6WindowComboControl;

//------------------------------------------------------------
// Once the user has selected an item from the list, hide this
// menu.
//------------------------------------------------------------
function CloseUp()
{

    Super.CloseUp();
    HideWindow();

    if ( GetValue() != "" )
        Notify( DE_Enter );
}

//------------------------------------------------------------
// Display the menu at the position indicated by the function
// arguments
//------------------------------------------------------------
function DisplayMenuHere( float fXPos, float fYPos )
{
    // Clear the previous selection

    SetValue( "" );
    List.Selected = None;

    // Make sure the menu does appear outside the dimensions fo the screen

    if ( fXPos + WinWidth > 640 )
        WinLeft = 640 - WinWidth - 12;  // 12 to move menu away from screen edge
    else
        WinLeft = fXPos;

    WinTop  = fYPos;

    ShowWindow();
    BringToFront();
    DropDown();
}

//------------------------------------------------------------
// Called when the window is first created.
//------------------------------------------------------------
function Created()
{
    // PATCH - A window of this type usually has a permanent box
    // and button at the top, we do not want this so set the
    // height to 0 so it won't be displayed - need a cleaner
    // way to do this

    WinHeight = 0;
	Super.Created();	
}

defaultproperties
{
}
