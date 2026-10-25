//=============================================================================
//  R6WindowListBox.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6WindowListBox extends UWindowListControl;

var R6WindowVScrollbar	        m_VertSB;
var class<R6WindowVScrollBar>	m_SBClass;
var UWindowListBoxItem	        m_SelectedItem;

var Texture m_TIcon;			// where are the icon tex

var FLOAT				        m_fItemHeight;       // the size of each item
var FLOAT                       m_fSpaceBetItem;     // the space in between item
var FLOAT				        m_fDragY;
var FLOAT						m_fXItemOffset;		 // the item X offset pos
var FLOAT						m_fXItemRightPadding;	// Padding on the right of an item

var R6WindowListBox		        m_DoubleClickList;	 // list to send items to on double-click
var UWindowWindow				m_DoubleClickClient; // on double click send info to this specific client

var Color                       m_vMouseOverWindow;  // the mouseover window border color
var Color                       m_vInitBorderColor;  // the initial border color (use setbordercolor fct)

var string				        m_szDefaultHelpText;

var INT							m_iTotItemsDisplayed;// the number of items displayed on the window

var bool				        m_bDragging;
var bool				        m_bCanDrag;
var bool				        m_bCanDragExternal;
var bool                        m_bActiveOverEffect;

var bool                        m_bIgnoreUserClicks;  // If you only want the code to determine selected elements
var BOOL						m_bForceCaps;		  // force to capital letter in draw item

var BOOL                        m_bSkipDrawBorders;

var enum eCornerType
{
	No_Corners,
    No_Borders,
    Top_Corners,
	Bottom_Corners,       
	All_Corners
} m_eCornerType;

function Created()
{
	Super.Created();
	m_VertSB = R6WindowVScrollbar(CreateWindow(m_SBClass, WinWidth-LookAndFeel.Size_ScrollbarWidth, 0, LookAndFeel.Size_ScrollbarWidth, WinHeight));
}

function SetHelpText(string T)
{
	Super.SetHelpText(T);
	m_szDefaultHelpText = T;
}

function Sort()
{
	Items.Sort();
}

function Paint(Canvas C, FLOAT fMouseX, FLOAT fMouseY)
{
	local R6WindowLookAndFeel LAF;
	local UWindowList CurItem;
	local FLOAT y, fdrawWidth, fListHeight, fItemHeight;
	local INT i;
    	
	LAF = R6WindowLookAndFeel(LookAndFeel);
	CurItem = Items.Next;

	if (CurItem != None)
	{
		fItemHeight = GetSizeOfAnItem( CurItem); // THIS SUPPOSE THAT ALL YOUR ITEM HAVE THE SAME HEIGHT IN THE LIST
	}

	fListHeight = GetSizeOfList();

    if(m_VertSB != None)
    {
		m_VertSB.SetRange(0, Items.CountShown(), INT(fListHeight/fItemHeight)); 

        while((CurItem != None) && (i < m_VertSB.Pos)) 
	    {
//		    if(CurItem.ShowThisItem()) // TODO
//            {
				i++;
//            }

		    CurItem = CurItem.Next;
	    }
    }

	// check the width of the list box
    if( (m_VertSB == None) || (m_VertSB.isHidden()))
        fdrawWidth = WinWidth - m_fXItemRightPadding - m_fXItemOffset;    
    else
        fdrawWidth = WinWidth - m_VertSB.WinWidth - m_fXItemRightPadding - m_fXItemOffset;

	m_iTotItemsDisplayed = 0;

    for(y = LAF.m_SBHBorder.H; (y + fItemHeight <= fListHeight + LAF.m_SBHBorder.H) && (CurItem != None); CurItem = CurItem.Next)
	{
		if(CurItem.ShowThisItem())
		{	
            DrawItem(C, CurItem, m_fXItemOffset, y, fdrawWidth, fItemHeight);
			
			y = y + fItemHeight;

			m_iTotItemsDisplayed++;
		}
	}
}

function FLOAT GetSizeOfAnItem( UWindowList _pItem)
{
	local FLOAT fTotalItemHeigth;

	fTotalItemHeigth = m_fItemHeight + m_fSpaceBetItem;

	if ( UWindowListBoxItem(_pItem).m_bUseSubText)
	{
		fTotalItemHeigth += UWindowListBoxItem(_pItem).m_stSubText.fHeight;
	}

	return fTotalItemHeigth;
}

function FLOAT GetSizeOfList()
{
	return (WinHeight - (2*(R6WindowLookAndFeel(LookAndFeel).m_SBHBorder.H)));
}

/////////////////////////////////////////////////////////////////////////////
//***************************************************************************
//
//  This is important for the scroll bar to be the right size so make sure you call
//  SetSize(W, H) to resize this control
//***************************************************************************
//////////////////////////////////////////////////////////////////////////////

function Resized()
{
	Super.Resized();

    if(m_VertSB != None)
    {
        switch(m_eCornerType)
        {
        case No_Corners :
        case No_Borders :
            m_VertSB.WinLeft = WinWidth-LookAndFeel.Size_ScrollbarWidth;
                break;
        case Top_Corners :
        case Bottom_Corners :
        case All_Corners :
            m_VertSB.WinLeft = WinWidth - m_VertSB.WinWidth - R6WindowLookAndFeel(LookAndFeel).m_iListVPadding;
            break;
        }
	    
	    m_VertSB.WinTop = 0;
	    m_VertSB.SetSize(LookAndFeel.Size_ScrollbarWidth, WinHeight);
    }
}

function SetCornerType(eCornerType _NewCornerType)
{
    m_eCornerType = _NewCornerType;
    
    Resized();
}

function UWindowListBoxItem GetItemAt(FLOAT fMouseX, FLOAT fMouseY)
{
	local R6WindowLookAndFeel LAF;
	local UWindowList CurItem;
	local FLOAT y, fdrawWidth, fListHeight, fItemHeight;
	local INT i;
	
	LAF = R6WindowLookAndFeel(LookAndFeel);
	
	// check the width of the list box
    if( (m_VertSB == None) || (m_VertSB.isHidden()))
        fdrawWidth = WinWidth;    
    else
        fdrawWidth = WinWidth - m_VertSB.WinWidth;

	// if the mouse pos is outside the listbox
	if(fMouseX < 0 || fMouseX > fdrawWidth)
		return None;

	CurItem = Items.Next;

	if (CurItem != None)
	{
		fItemHeight = GetSizeOfAnItem( CurItem); // THIS SUPPOSE THAT ALL YOUR ITEM HAVE THE SAME HEIGHT IN THE LIST
	}

	fListHeight = GetSizeOfList();

    if(m_VertSB != None)
    {
	    while((CurItem != None) && (i < m_VertSB.Pos)) 
	    {
		    if(CurItem.ShowThisItem())
			    i++;
		    CurItem = CurItem.Next;
	    }
    }

	// parse all the item, and find the good one if exist
    for(y = LAF.m_SBHBorder.H; (y + fItemHeight <= fListHeight + LAF.m_SBHBorder.H) && (CurItem != None); CurItem = CurItem.Next)
	{
		if(CurItem.ShowThisItem())
		{	
			if(fMouseY >= y && fMouseY <= (y + fItemHeight - m_fSpaceBetItem))
				return UWindowListBoxItem(CurItem);
			
			y = y + fItemHeight;
		}
	}

	return None;
}

function MakeSelectedVisible()
{
	local UWindowList CurItem;
	local INT i;
	
    if( m_VertSB == None)
        return;
         
	m_VertSB.SetRange(0, Items.CountShown(), INT(GetSizeOfList()/GetSizeOfAnItem(Items.Next)));

	if(m_SelectedItem == None)
		return;

	for(CurItem=Items.Next; CurItem != None; CurItem = CurItem.Next)
	{
		if(CurItem == m_SelectedItem)
        {
			break;
        }
		if(CurItem.ShowThisItem())
        {
			i++;
        }
	}

	m_VertSB.Show(i);
}

function SetSelectedItem(UWindowListBoxItem NewSelected)
{
	if(NewSelected != None && m_SelectedItem != NewSelected)
	{
		if(m_SelectedItem != None)
        {
			m_SelectedItem.bSelected = False;
        }

		m_SelectedItem = NewSelected;

		if(m_SelectedItem != None)
        {
			m_SelectedItem.bSelected = True;
        }
		
		Notify(DE_Click);
	}
}


function SetSelected(FLOAT X, FLOAT Y)
{
	local UWindowListBoxItem NewSelected;

	NewSelected = GetItemAt(X, Y);
    
    if(NewSelected != m_SelectedItem)
        ClickTime = 0;


	SetSelectedItem(NewSelected);
}

function LMouseDown(FLOAT X, FLOAT Y)
{
    if(m_bIgnoreUserClicks)
            return;

	Super.LMouseDown(X, Y);

	SetAcceptsFocus();

	SetSelected(X, Y);

	if(m_bCanDrag || m_bCanDragExternal)
	{
		m_bDragging = True;
		Root.CaptureMouse();
		m_fDragY = Y;
	}
}

function DoubleClick(FLOAT X, FLOAT Y)
{
//	Super.DoubleClick(X, Y);

    if ((m_bIgnoreUserClicks) || (m_SelectedItem == None))
            return;

	if(GetItemAt(X, Y) == m_SelectedItem)
	{
		DoubleClickItem(m_SelectedItem);
	}	
}

function ReceiveDoubleClickItem(R6WindowListBox L, UWindowListBoxItem I)
{
	I.Remove();
	Items.AppendItem(I);
	SetSelectedItem(I);
	L.m_SelectedItem = None;
	L.Notify(DE_Change);
	Notify(DE_Change);
}

function DoubleClickItem(UWindowListBoxItem I)
{
    
    if(m_bIgnoreUserClicks)
            return;

    //log("DoubleClickItem");
	Notify(DE_DoubleClick);

	if (m_DoubleClickClient != None)
	{
		m_DoubleClickClient.NotifyWindow( self, DE_DoubleClick);
	}

	if(m_DoubleClickList != None && I != None)
    {
        //log("DoubleClickItem ReceiveDoubleClickItem");
		m_DoubleClickList.ReceiveDoubleClickItem(Self, I);
    }
}

// overwrite UWindowWindow Mouse Enter
function MouseEnter()
{
    Super.MouseEnter();

    if (m_bActiveOverEffect)
    {
        m_BorderColor = m_vMouseOverWindow;
    }
}

// overwrite UWindowWindow Mouse Leave
function MouseLeave()
{
    Super.MouseLeave();

    if (m_bActiveOverEffect)
    {
        m_BorderColor = m_vInitBorderColor;
    }
}

function MouseMove(FLOAT X, FLOAT Y)
{
	local UWindowListBoxItem OverItem;
	Super.MouseMove(X, Y);

	if(m_bDragging && bMouseDown)
	{
		OverItem = GetItemAt(X, Y);
		if(m_bCanDrag && OverItem != m_SelectedItem && OverItem != None && m_SelectedItem != None)
		{
			m_SelectedItem.Remove();
			if(Y < m_fDragY)
            {
				OverItem.InsertItemBefore(m_SelectedItem);
            }
			else
            {
				OverItem.InsertItemAfter(m_SelectedItem, True);
            }

			Notify(DE_Change);

			m_fDragY = Y;
		}
		else
		{
			if(m_bCanDragExternal && CheckExternalDrag(X, Y) != None)
            {
				m_bDragging = False;
            }
		}
	}
	else
    {
		m_bDragging = False;
    }
}

function MouseWheelDown(FLOAT X, FLOAT Y)
{
	if (m_VertSB != None)
	{
		m_VertSB.MouseWheelDown( X, Y);
	}
}

function MouseWheelUp(FLOAT X, FLOAT Y)
{
	if (m_VertSB != None)
	{
		m_VertSB.MouseWheelUp( X, Y);
	}
}

function bool ExternalDragOver(UWindowDialogControl ExternalControl, FLOAT X, FLOAT Y)
{
	local R6WindowListBox B;
	local UWindowListBoxItem OverItem;

	// Subclass should return false and not call this version if this external
	// drag should be denied.

	B = R6WindowListBox(ExternalControl);
	if(B != None && B.m_SelectedItem != None)
	{	
		OverItem = GetItemAt(X, Y);

		B.m_SelectedItem.Remove();
		if(OverItem != None)
        {
			OverItem.InsertItemBefore(B.m_SelectedItem);
        }
		else
        {
			Items.AppendItem(B.m_SelectedItem);
        }

		SetSelectedItem(B.m_SelectedItem);
		B.m_SelectedItem = None;
		B.Notify(DE_Change);
		Notify(DE_Change);

		if(m_bCanDrag || m_bCanDragExternal)
		{
			Root.CancelCapture();
			m_bDragging = True;
			bMouseDown = True;
			Root.CaptureMouse(Self);
			m_fDragY = Y;	
		}

		return True;
	}

	return False;	
}

function DropSelection()
{
    if(m_SelectedItem != None)
    {
	    m_SelectedItem.bSelected = False;
    }
    m_SelectedItem = None;

}


//=======================================================================
// Get the selected item
// return None if no item was selected
//=======================================================================
function UWindowListBoxItem GetSelectedItem()
{
    return m_SelectedItem;
}

//=======================================================================
// Set the border color
// Why use a fct for this, because we need to initialize the intial color too
// for mouveenter and mouse leave effect when you go on this window
//=======================================================================
function SetOverBorderColorEffect( Color _vBorderColor)
{
    m_BorderColor       = _vBorderColor;
    m_vInitBorderColor  = _vBorderColor;
    m_bActiveOverEffect = true;
}

//=======================================================================================================
// This function return the region where to draw the icon X and Y depending of window region
// (W and H are 0)
//=======================================================================================================
function Region CenterIconInBox( FLOAT _fX, FLOAT _fY, FLOAT _fWidth, FLOAT _fHeight, Region _RIconRegion)
{
    local Region RTemp;
	local FLOAT fTemp;

	fTemp = (_fWidth - _RIconRegion.W) / 2;
    RTemp.X = _fX + INT(fTemp + 0.5);

    fTemp = (_fHeight - _RIconRegion.H) / 2;
    RTemp.Y = FLOAT(INT(fTemp + 0.5));    
    RTemp.Y += _fY;

    return RTemp;
}

//=======================================================================================================
// GetCenterXPos: return the center pos of the region according the text size
//=======================================================================================================
function INT GetCenterXPos( FLOAT _fTagWidth, FLOAT _fTextWidth)
{
    return INT(((_fTagWidth - _fTextWidth) * 0.5) + 0.5);
}


function Clear()
{
    m_VertSB.Pos = 0;
    m_SelectedItem = None;
    Items.clear();    
}


//=======================================================================================================
// KeyDown: manage key down for list (movements in the list...)
//=======================================================================================================
function KeyDown(int Key, float X, float Y)
{
	local UWindowListBoxItem TempItem, OldSelection;

//	log("R6WindowListBox: KeyDown()"@Key);

	if (m_SelectedItem == None)
	{
		if (Items.Count() > 0)
		{
			// take the first valid element
			TempItem = CheckForNextItem(UWindowListBoxItem(Items.Next));
			if (TempItem != None)
				SetSelectedItem( TempItem);
		}

		return;
	}

	OldSelection = m_SelectedItem;

	switch (Key)
	{
		case Root.Console.EInputKey.IK_Up:
			TempItem = CheckForPrevItem(m_SelectedItem);
			if (TempItem != None)
				SetSelectedItem( TempItem);
			break;
		case Root.Console.EInputKey.IK_Down:
			TempItem = CheckForNextItem(m_SelectedItem);
			if (TempItem != None)
				SetSelectedItem( TempItem);
			break;
		case Root.Console.EInputKey.IK_Home:
			TempItem = CheckForNextItem(UWindowListBoxItem(Items));
			if (TempItem != None)
				SetSelectedItem( TempItem);
			break;
		case Root.Console.EInputKey.IK_End:
			TempItem = CheckForLastItem( UWindowListBoxItem(Items.Last));
			if (TempItem != None)
				SetSelectedItem( TempItem);
			break;
		case Root.Console.EInputKey.IK_Enter:
			if (!m_bIgnoreUserClicks)
				DoubleClickItem(m_SelectedItem);
			break;
		case Root.Console.EInputKey.IK_PageDown:
			TempItem = CheckForPageDown( m_SelectedItem);
			if (TempItem != None)
				SetSelectedItem( TempItem);			
			break;
		case Root.Console.EInputKey.IK_PageUp:
			TempItem = CheckForPageUp( m_SelectedItem);
			if (TempItem != None)
				SetSelectedItem( TempItem);
			break;
		case Root.Console.EInputKey.IK_Escape:
			CancelAcceptsFocus();
			break;
		default:
			break;
	}

	if (OldSelection != m_SelectedItem)
		MakeSelectedVisible();

	Super.KeyDown(Key, X, Y);
}

//===================================================================================
// CheckForNextItem: check for the next valid item on the list
//===================================================================================
function UWindowListBoxItem CheckForNextItem( UWindowListBoxItem _StartItem)
{
	local UWindowListBoxItem TempItem;
	local BOOL bIsASeparator;

	if (_StartItem == None)
		return None;

	TempItem = UWindowListBoxItem(_StartItem.Next);

	if ((TempItem == None) || !TempItem.ShowThisItem())
		return None;

	if (IsASeparatorItem())
		bIsASeparator = R6WindowListBoxItem(TempItem).m_IsSeparator;

	while((TempItem.m_bDisabled) || (bIsASeparator))
	{
		TempItem = UWindowListBoxItem(TempItem.Next);
		if ((TempItem == None) || !TempItem.ShowThisItem())
			return None;

		if (IsASeparatorItem())
			bIsASeparator = R6WindowListBoxItem(TempItem).m_IsSeparator;
	}

	return TempItem;
}

//===================================================================================
// CheckForPrevItem: check for the prev valid item on the list
//===================================================================================
function UWindowListBoxItem CheckForPrevItem( UWindowListBoxItem _StartItem)
{
	local UWindowListBoxItem TempItem;
	local BOOL bIsASeparator;

	if (_StartItem == None)
		return None;

	TempItem = UWindowListBoxItem(_StartItem.Prev);

	if ((TempItem == Items.Sentinel) || (TempItem == None))
		return None;

	if (IsASeparatorItem())
		bIsASeparator = R6WindowListBoxItem(TempItem).m_IsSeparator;

	while((TempItem.m_bDisabled) || (bIsASeparator))
	{
		TempItem = UWindowListBoxItem(TempItem.Prev);
		if ((TempItem == None) || (TempItem == UWindowListBoxItem(Items))) // this is the sentinel of the list
			return None;

		if (IsASeparatorItem())
			bIsASeparator = R6WindowListBoxItem(TempItem).m_IsSeparator;
	}

	return TempItem;
}

//===================================================================================
// CheckForLastItem: check for the last valid item on the list
//===================================================================================
function UWindowListBoxItem CheckForLastItem( UWindowListBoxItem _LastItem)
{
	local BOOL bIsASeparator;

	if (_LastItem == None)
		return None;

	if (IsASeparatorItem())
		bIsASeparator = R6WindowListBoxItem(_LastItem).m_IsSeparator;

	if ((_LastItem.m_bDisabled) || (bIsASeparator))
	{
		return CheckForPrevItem( _LastItem);
	}

	return _LastItem;
}

//===================================================================================
// CheckForPageDown: check for the next page down valid item on the list
//===================================================================================
function UWindowListBoxItem CheckForPageDown( UWindowListBoxItem _StartItem)
{
	local UWindowListBoxItem TempItem, ValidItem;
	local INT i, iMaxItemsDisplayed;
	local BOOL bIsASeparator;

	if (_StartItem == None)
		return None;

	// move to the end of the window and take the next element
	TempItem = _StartItem;

	i = 1;
	ValidItem = TempItem;
	iMaxItemsDisplayed = INT(GetSizeOfList()/GetSizeOfAnItem( TempItem));

	while( i < iMaxItemsDisplayed)
	{
		TempItem = UWindowListBoxItem(TempItem.Next);

		if ((TempItem == None) || ( i == m_iTotItemsDisplayed))
			return ValidItem;

		if(TempItem.ShowThisItem())
		{
			i++;
			ValidItem = TempItem;
		}
	}

	return CheckForNextItem(TempItem);
}

//===================================================================================
// CheckForPageUp: check for the next page up valid item on the list
//===================================================================================
function UWindowListBoxItem CheckForPageUp( UWindowListBoxItem _StartItem)
{
	local UWindowListBoxItem TempItem, ValidItem;
	local INT i, iMaxItemsDisplayed;
	local BOOL bIsASeparator;

	if (_StartItem == None)
		return None;

	// move to the end of the window and take the next element
	TempItem = _StartItem;

	i = 1;
	ValidItem = TempItem;
	iMaxItemsDisplayed = INT(GetSizeOfList()/GetSizeOfAnItem( TempItem));

	while( i < iMaxItemsDisplayed)
	{
		TempItem = UWindowListBoxItem(TempItem.Prev);

		if ((TempItem == None) || ( i == m_iTotItemsDisplayed) ||
			(TempItem == UWindowListBoxItem(Items)) ) // this is the sentinel of the list
			return ValidItem;

		if(TempItem.ShowThisItem())
		{
			i++;
			ValidItem = TempItem;
		}
	}

	return CheckForPrevItem(TempItem);
}

//===================================================================================
// SwapItem: Move an item in the list, by default is to the next element.
//			 Restrictions: Can apply swap on disable/separator item
//===================================================================================
function BOOL SwapItem( UWindowListBoxItem _pItem, BOOL _bUp)
{
	local UWindowListBoxItem TempItem, BkpItem;

	if (_pItem == None)
		return false;

	TempItem = _pItem;

	if (_bUp)
	{
		TempItem = UWindowListBoxItem(TempItem.Prev);

		if ((TempItem == None) || (TempItem == UWindowListBoxItem(Items))) // this is the sentinel of the list
			return false;

		// remove the item and add it before the previous one
		BkpItem = _pItem;
		_pItem.Remove();
		TempItem.InsertItemBefore(BkpItem);
	}
	else
	{
		TempItem = UWindowListBoxItem(TempItem.Next);

		if (TempItem == None)
			return false;

		// remove the item and add it after the next one
		BkpItem = _pItem;
		_pItem.Remove();
		TempItem.InsertItemAfter(BkpItem);		
	}

	MakeSelectedVisible();

	return true;
}

//===================================================================================
// IsASeparatorItem: check if item have separator
//===================================================================================
function BOOL IsASeparatorItem()
{
	return (ListClass == class'R6WindowListBoxItem');
}

function KeyFocusEnter()
{
	SetAcceptsFocus();
}

function KeyFocusExit()
{
	CancelAcceptsFocus();
}

defaultproperties
{
     m_fItemHeight=10.000000
     m_fSpaceBetItem=4.000000
     m_fXItemOffset=2.000000
     m_TIcon=Texture'R6MenuTextures.Credits.TeamBarIcon'
     m_SBClass=Class'R6Window.R6WindowVScrollbar'
     m_vMouseOverWindow=(B=239,G=209,R=129)
     ListClass=Class'UWindow.UWindowListBoxItem'
}
