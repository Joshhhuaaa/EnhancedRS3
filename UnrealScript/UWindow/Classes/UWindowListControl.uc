//=============================================================================
// UWindowListControl - Abstract class for list controls
//	- List boxes
//	- Dropdown Menus
//	- Combo Boxes, etc
//=============================================================================
class UWindowListControl extends UWindowDialogControl;

var class<UWindowList>	ListClass;
var UWindowList			Items;

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	// Declared in Subclass
}

function Created()
{
	Super.Created();

	Items = New ListClass;
	Items.Last = Items;
	Items.Next = None;	
	Items.Prev = None;
	Items.Sentinel = Items;
}

function UWindowList GetItemAtIndex( INT _iIndex)
{
	local UWindowList CurItem;
	local INT i;

	if (Items.Next == None)
	{
		if (_iIndex == 0) 
			return Items.Append(ListClass); // create the item
		else
			return None; // if the index is > 0 and you don't have an item, problem!!!
	}

	CurItem = Items.Next;
	i =0;

	while( CurItem != None)
	{
		if (i == _iIndex)
		{
			CurItem.m_bShowThisItem = true; // show the item 
			break;
		}

		CurItem = CurItem.Next;
		i++;
	}

	if ( CurItem == None)
		return Items.Append(ListClass); // create the item
	else
		return CurItem;
}

function UWindowList GetNextItem( INT _iIndex, UWindowList prevItem)
{
	local UWindowList CurItem;
	local INT i;

	if (Items.Next == None)
	{
		if (_iIndex == 0) 
			return Items.Append(ListClass); // create the item
		else
			return None; // if the index is > 0 and you don't have an item, problem!!!
	}

	if (_iIndex == 0)
		CurItem = Items.Next;
	else
	{
		if ( prevItem != None )
			curItem = prevItem.Next;
	}

	if ( CurItem == None)
		return Items.Append(ListClass); // create the item

	CurItem.m_bShowThisItem = true; // show the item 

	return CurItem;
}


function ClearListOfItems()
{
	local UWindowList CurItem;
    local INT i, iListLength;

	if (Items.Next == None)
		return;

	CurItem = Items.Next;
	iListLength = Items.Count();

	for ( i = 0; i < iListLength; i++)
	{
		if (CurItem != None)
		{
			CurItem.ClearItem(); // clear the item except the link with the list
			CurItem = CurItem.Next;
		}
		else
		{
			break;
		}
	}
}

defaultproperties
{
}
