//=============================================================================
// UWindowListControl - Abstract class for list controls
//	- List boxes
//	- Dropdown Menus
//	- Combo Boxes, etc
//=============================================================================
class R6WindowListGeneral extends UWindowListControl;

var FLOAT   m_fItemWidth;
var FLOAT   m_fItemHeight;
var FLOAT   m_fStepBetweenItem;


function Paint(Canvas C, FLOAT X, FLOAT Y)
{

	local FLOAT fX;
    local FLOAT fY;
	local UWindowList CurItem;
#ifdefDEBUG
	local BOOL bShowListBorder;
	
	if (bShowListBorder)
	{
		// draw the window border, usefull to debug
		m_BorderColor = Root.Colors.Yellow;
		DrawSimpleBorder(C);
		// apply a white tex on all the window
//	DrawStretchedTexture( C, 0, 0, WinWidth, WinHeight, Texture'UWindow.WhiteTexture');
	}
#endif

    if(m_fItemWidth==0)
        m_fItemWidth = WinWidth;

    fX = (WinWidth-m_fItemWidth)/2;

    for(CurItem = Items.Next; CurItem != None; CurItem = CurItem.Next)
	{
        if (!R6WindowListGeneralItem(CurItem).m_bFakeItem)
            DrawItem(C, CurItem, fX, fY, m_fItemWidth, m_fItemHeight);

        fY += m_fItemHeight + m_fStepBetweenItem;
        if(fY >= WinHeight)
        {
            fY = 0;
            fX += WinWidth;
        }
	}
}

function DrawItem(Canvas C, UWindowList Item, FLOAT X, FLOAT Y, FLOAT W, FLOAT H)
{
	local R6WindowListGeneralItem pListGenItem;

	pListGenItem = R6WindowListGeneralItem(Item);

	// Why the WinLeft and WinTop addition to the item ? 
	// special case for R6MenuMPCreateGameTab
	// because thoses buttons are create in a window with others buttons, etc
	// so, the reference window is not this window but the creator, R6MenuMPCreateGameTab
	// all the button are set in reference of this window, for not declare a sub class to declare button, 
	// we add Winleft and WinTop YJ.

    // Set the item location
    if (pListGenItem.m_pR6WindowCounter != None)
    {
        pListGenItem.m_pR6WindowCounter.WinLeft = WinLeft + X;
        pListGenItem.m_pR6WindowCounter.WinTop = WinTop + Y;
        pListGenItem.m_pR6WindowCounter.WinHeight = H;
    }
	else if (pListGenItem.m_pR6WindowButtonBox != None)
	{
        pListGenItem.m_pR6WindowButtonBox.WinLeft = WinLeft + X;
        pListGenItem.m_pR6WindowButtonBox.WinTop = WinTop + Y;
        pListGenItem.m_pR6WindowButtonBox.WinHeight = H;
	}
	else if (pListGenItem.m_pR6WindowComboControl != None)
	{
        pListGenItem.m_pR6WindowComboControl.WinLeft = WinLeft + X;
        pListGenItem.m_pR6WindowComboControl.WinTop = WinTop + Y;
        pListGenItem.m_pR6WindowComboControl.WinHeight = H;
	}

}

function RemoveAllItems()
{
	local R6WindowListGeneralItem ItemIndex;

	ItemIndex = R6WindowListGeneralItem(Items.Next);
		
	while(ItemIndex != None)
	{
		if (ItemIndex.m_pR6WindowCounter != None)
		{
			ItemIndex.m_pR6WindowCounter.HideWindow();
		}
		else if (ItemIndex.m_pR6WindowButtonBox != None)
		{
			ItemIndex.m_pR6WindowButtonBox.HideWindow();
		}
		else if (ItemIndex.m_pR6WindowComboControl != None)
		{
			ItemIndex.m_pR6WindowComboControl.HideWindow();
		}

		ItemIndex.Remove();
		ItemIndex = R6WindowListGeneralItem(Items.Next);
	}
}

function ChangeVisualItems( bool _bVisible)
{
	local UWindowList I;

	if (Items.Next != None)
	{

		for( I = Items.Next;I != None; I = I.Next)
		{

			if (R6WindowListGeneralItem(I).m_pR6WindowCounter != None)
			{
				if (_bVisible)
				{
					R6WindowListGeneralItem(I).m_pR6WindowCounter.ShowWindow();
				}
				else
				{
					R6WindowListGeneralItem(I).m_pR6WindowCounter.HideWindow();
				}
			}
			else if (R6WindowListGeneralItem(I).m_pR6WindowButtonBox != None)
			{
				if (_bVisible)
				{
					R6WindowListGeneralItem(I).m_pR6WindowButtonBox.ShowWindow();
				}
				else
				{
					R6WindowListGeneralItem(I).m_pR6WindowButtonBox.HideWindow();
				}
			}
			else if (R6WindowListGeneralItem(I).m_pR6WindowComboControl != None)
			{
				if (_bVisible)
				{
					R6WindowListGeneralItem(I).m_pR6WindowComboControl.ShowWindow();
				}
				else
				{
					R6WindowListGeneralItem(I).m_pR6WindowComboControl.HideWindow();
				}
			}

//			ItemIndex = R6WindowListGeneralItem(I);//Items.Next);
		}
	}
}

defaultproperties
{
     m_fItemHeight=15.000000
     m_fStepBetweenItem=1.000000
     ListClass=Class'R6Window.R6WindowListGeneralItem'
}
