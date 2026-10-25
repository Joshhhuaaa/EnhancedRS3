class UWindowTabControlTabArea extends UWindowWindow;

enum eTabCase
{
    eTab_Left,
    eTab_Middle,
    eTab_Right,
    eTab_Left_RightCut,
    eTab_Middle_RightCut
};

var UWindowTabControlItem   FirstShown;
var UWindowTabControlItem   DragTab;
var globalconfig bool       bArrangeRowsLikeTimHates;

var Color                   m_vEffectColor;

var FLOAT                   UnFlashTime;

var INT                     TabOffset;
var INT                     TabRows;
var INT                     m_iTotalTab;
var eTabCase                m_eTabCase;

var bool                    bShowSelected;
var bool                    bDragging;
var bool                    bFlashShown;
var bool                    m_bDisplayToolTip;                  // display a tool tip for a item

function Created()
{
	TabOffset = 0;
//	Super.Created();
}

function SizeTabsSingleLine(Canvas C)
{
	local UWindowTabControlItem I, Selected, LastHidden;
	local int Count, TabCount;
	local float ItemX, W, H, fTotalTabsWidth;
	local bool bHaveMore;


	ItemX = LookAndFeel.Size_TabXOffset;
	TabCount=0;
	for( 
			I = UWindowTabControlItem(UWindowTabControl(ParentWindow).Items.Next);
			I != None; 
			I = UWindowTabControlItem(I.Next) 
		)
	{
		LookAndFeel.Tab_GetTabSize(Self, C, RemoveAmpersand(I.Caption), W, H);
		I.TabWidth = W;
		
        if (I.m_fFixWidth != 0)
            I.TabWidth = I.m_fFixWidth;

		fTotalTabsWidth += I.TabWidth;

		// check if the total tab window is not > than the winwidth (UWindowTabControl(ParentWindow).m_bTabButton == None)
		if (fTotalTabsWidth > WinWidth)
		{
			I.TabWidth -= fTotalTabsWidth - WinWidth;
			fTotalTabsWidth = WinWidth;
		}

		I.TabHeight = H + 1;
		I.TabTop = 0;
		I.RowNumber = 0;
		TabCount++;
	}

    m_iTotalTab = TabCount;
	Selected = UWindowTabControl(ParentWindow).SelectedTab;

	while(True)
	{
		ItemX = LookAndFeel.Size_TabXOffset;  // seems the first X offset

		Count = 0;
		LastHidden = None;
		FirstShown = None;
		for( 
				I = UWindowTabControlItem(UWindowTabControl(ParentWindow).Items.Next);
				I != None; 
				I = UWindowTabControlItem(I.Next) 
			)
		{
			if( Count < TabOffset)
			{
				I.TabLeft = -1;
				LastHidden = I;
			}
			else
			{
				if(FirstShown == None) FirstShown = I;
				I.TabLeft = ItemX;

				if(I.TabLeft + I.TabWidth >= WinWidth + 5) bHaveMore = True;
				
				ItemX += I.TabWidth;
//                if () // overload the tab
				ItemX -= 15; // this value back the tab on the previous one
			}
			Count++;
		}

		if( TabOffset > 0 && LastHidden != None && LastHidden.TabWidth + 5 < WinWidth - ItemX)
			TabOffset--;
		else 
		if(	bShowSelected && TabOffset < TabCount - 1 
			&&	Selected != None &&	Selected != FirstShown 
			&& Selected.TabLeft + Selected.TabWidth > WinWidth - 5
		  ) 
			TabOffset++;
		else				
			break;
	}
	bShowSelected = False;

    if (UWindowTabControl(ParentWindow).m_bTabButton)
    {
    	UWindowTabControl(ParentWindow).LeftButton.bDisabled = TabOffset <= 0;
	    UWindowTabControl(ParentWindow).RightButton.bDisabled = !bHaveMore;
    }

	TabRows = 1;
}

function SizeTabsMultiLine(Canvas C)
{
	local UWindowTabControlItem I, Selected;
	local float W, H;
	local int MinRow;
	local float RowWidths[10];
	local int TabCounts[10];
	local int j;
	local bool bTryAnotherRow;
		
	TabOffset = 0;
	FirstShown = None;

	TabRows = 1;
	bTryAnotherRow = True;

	while(bTryAnotherRow && TabRows <= 10)
	{	
		bTryAnotherRow = False;
		for(j=0;j<TabRows;j++)
		{
			RowWidths[j] = 0;
			TabCounts[j] = 0;		
		}

		for( 
				I = UWindowTabControlItem(UWindowTabControl(ParentWindow).Items.Next);
				I != None; 
				I = UWindowTabControlItem(I.Next) 
			)
		{
			LookAndFeel.Tab_GetTabSize(Self, C, RemoveAmpersand(I.Caption), W, H);
			I.TabWidth = W;
			I.TabHeight = H;

			// find the best row for this tab
			MinRow = 0;
			for(j=1;j<TabRows;j++)
				if(RowWidths[j] < RowWidths[MinRow])
					MinRow = j;

			if(RowWidths[MinRow] + W > WinWidth)
			{
				TabRows ++;
				bTryAnotherRow = True;
				break;
			}
			else
			{
				RowWidths[MinRow] += W;
				TabCounts[MinRow]++;
				I.RowNumber = MinRow;
			}
		}
	}

	Selected = UWindowTabControl(ParentWindow).SelectedTab;

	if(TabRows > 1)
	{
		for( 
				I = UWindowTabControlItem(UWindowTabControl(ParentWindow).Items.Next);
				I != None; 
				I = UWindowTabControlItem(I.Next) 
			)
		{
			I.TabWidth += (WinWidth - RowWidths[I.RowNumber]) / TabCounts[I.RowNumber];
		}
	}

	for(j=0;j<TabRows;j++)
		RowWidths[j] = 0;

	for( 
			I = UWindowTabControlItem(UWindowTabControl(ParentWindow).Items.Next);
			I != None; 
			I = UWindowTabControlItem(I.Next) 
		)
	{
		I.TabLeft = RowWidths[I.RowNumber];

		if(bArrangeRowsLikeTimHates)
			I.TabTop = ((I.RowNumber + ((TabRows - 1) - Selected.RowNumber)) % TabRows) * I.TabHeight;
		else
			I.TabTop = I.RowNumber * I.TabHeight;

		RowWidths[I.RowNumber] += I.TabWidth;
	}
}

function LayoutTabs(Canvas C)
{
	if(UWindowTabControl(ParentWindow).bMultiLine)
		SizeTabsMultiLine(C);
	else
		SizeTabsSingleLine(C);
}

function Paint(Canvas C, float X, float Y)
{
	local UWindowTabControlItem I, ITemp;
	local int Count;
	local int Row;
    local INT iTabNumber;
	local float T;
    local bool bNextTabSelected, bPrevTabSelected;
	
	T = GetEntryLevel().TimeSeconds;

	if(UnFlashTime < T)
	{
		bFlashShown = !bFlashShown;

		if(bFlashShown)
			UnFlashTime = T + 0.5;
		else
			UnFlashTime = T + 0.3;
	}
	
	for(Row=0;Row<TabRows;Row++)
	{
		Count = 0;
        iTabNumber = 0;
        m_eTabCase = eTabCase.eTab_Left;
		for( 
				I = UWindowTabControlItem(UWindowTabControl(ParentWindow).Items.Next);
				I != None; 
				I = UWindowTabControlItem(I.Next) 
			)
		{
			if( Count < TabOffset)
			{
				Count++;
				continue;
			}
			if(I.RowNumber == Row)
            {
                bNextTabSelected = false;

                if (UWindowTabControlItem(I.Next) == UWindowTabControl(ParentWindow).SelectedTab)
                    bNextTabSelected = true;
                if (UWindowTabControlItem(I.Prev) == UWindowTabControl(ParentWindow).SelectedTab)
                    bPrevTabSelected = true;

                if ( iTabNumber > 0)
                {
                    if ( iTabNumber == m_iTotalTab - 1)
                    {
                        m_eTabCase = eTabCase.eTab_Right;
//                        if (bPrevTabSelected)
//                            m_eTabCase = eTabCase.eTab_Right_LeftCut;
                    }
                    else
                    {
                        m_eTabCase = eTabCase.eTab_Middle;
                        if (bNextTabSelected)
                            m_eTabCase = eTabCase.eTab_Middle_RightCut;
                    }
                }
                else if (bNextTabSelected) // 
                {
                    m_eTabCase = eTabCase.eTab_Left_RightCut;
                }

				DrawItem(C, I, I.TabLeft, I.TabTop, I.TabWidth, I.TabHeight, (!I.bFlash) || bFlashShown);
                iTabNumber++;
            }
		}
	}
}

function LMouseDown(float X, float Y)
{
	local UWindowTabControlItem I;
	local int Count;

	Super.LMouseDown(X, Y);

	Count = 0;
	for( 
			I = UWindowTabControlItem(UWindowTabControl(ParentWindow).Items.Next);
			I != None; 
			I = UWindowTabControlItem(I.Next) 
		)
	{
		if( Count < TabOffset)
		{
			Count++;
			continue;
		}
		if( X >= I.TabLeft && X <= I.TabLeft + I.TabWidth && (TabRows==1 || (Y >= I.TabTop && Y <= I.TabTop + I.TabHeight)) )
		{
			if(!UWindowTabControl(ParentWindow).bMultiLine)
			{
				bDragging = True;
				DragTab = I;
				Root.CaptureMouse();
			}
			UWindowTabControl(ParentWindow).GotoTab(I, True);
		}
	}
}


function MouseLeave()
{
    Super.MouseLeave();

    ResetMouseOverOnItem();
}


function MouseMove(float X, float Y)
{
    CheckToolTip( X, Y);

	if(bDragging && bMouseDown)
	{
		if(X < DragTab.TabLeft)
			TabOffset++;

		if(X > DragTab.TabLeft + DragTab.TabWidth && TabOffset > 0)
			TabOffset--;	
	}
	else
		bDragging = False;
}


function RMouseDown(float X, float Y)
{
	local UWindowTabControlItem I;
	local int Count;

	Super.LMouseDown(X, Y);

	Count = 0;
	for( 
			I = UWindowTabControlItem(UWindowTabControl(ParentWindow).Items.Next);
			I != None; 
			I = UWindowTabControlItem(I.Next) 
		)
	{
		if( Count < TabOffset)
		{
			Count++;
			continue;
		}
		if( X >= I.TabLeft && X <= I.TabLeft + I.TabWidth )
		{
			I.RightClickTab();
		}
	}
}


//===================================================================
// draw the tab-item
//===================================================================
function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H, bool bShowText)
{
	local UWindowTabControlItem pTabControlItem;

	pTabControlItem = UWindowTabControlItem(Item);

    m_bDisplayToolTip = pTabControlItem.m_bMouseOverItem;

	if(Item == UWindowTabControl(ParentWindow).SelectedTab)
    {
        m_vEffectColor = pTabControlItem.m_vSelectedColor;
		LookAndFeel.Tab_DrawTab(Self, C, True, FirstShown==Item, X, Y, W, H, pTabControlItem.Caption, bShowText);
    }
	else
    {
        m_vEffectColor = pTabControlItem.m_vNormalColor;
		LookAndFeel.Tab_DrawTab(Self, C, False, FirstShown==Item, X, Y, W, H, pTabControlItem.Caption, bShowText);
    }
}

function bool CheckMousePassThrough(float X, float Y)
{
	return Y >= LookAndFeel.Size_TabAreaHeight*TabRows;
}


//===================================================================
// check if the mouse is over an item
//===================================================================
function UWindowTabControlItem CheckMouseOverOnItem( FLOAT _fX, FLOAT _fY)
{
	local UWindowTabControlItem I, ItemTemp;
	local int Count;
    local FLOAT fXMin, fXMax;


    ItemTemp = None;
	Count = 0;
    
    for( 
			I = UWindowTabControlItem(UWindowTabControl(ParentWindow).Items.Next);
			I != None; 
			I = UWindowTabControlItem(I.Next) 
		)
	{
		if( Count < TabOffset)
		{
			Count++;
			continue;
		}

        // we need to take count of the left-right overlap-border 
        // (to avoid that the left and/or the right tab have a mouseover on it)
        fXMin = I.TabLeft + 10;
        fXMax = I.TabLeft + I.TabWidth - 18;

		if( _fX >= fXMin && _fX <= fXMax && (TabRows==1 || (_fY >= I.TabTop && _fY <= I.TabTop + I.TabHeight)) )
		{
            ItemTemp = I;
            I.m_bMouseOverItem = true;
            continue;
//            return I;
		}
        I.m_bMouseOverItem = false;
	}

    return ItemTemp;
//    return None;
}


//===================================================================
// put all the mouseoveritem bool at false
//===================================================================
function ResetMouseOverOnItem()
{
	local UWindowTabControlItem I;
	local int Count;

	Count = 0;
	for( 
			I = UWindowTabControlItem(UWindowTabControl(ParentWindow).Items.Next);
			I != None; 
			I = UWindowTabControlItem(I.Next) 
		)
	{
		if( Count < TabOffset)
		{
			Count++;
			continue;
		}

        I.m_bMouseOverItem = false;
	}

    ParentWindow.ToolTip("");
}


//===================================================================
// check if the mouse is over an item and display a tool tip when is required
//===================================================================
function CheckToolTip( FLOAT _fX, FLOAT _fY)
{
    local UWindowTabControlItem Item;

    Item = CheckMouseOverOnItem( _fX, _fY);

    if (Item != None)
    {
        // provide the appropriate tooltip == HelpText
        if (Item.m_bMouseOverItem && Item.HelpText != "")
        {
            ParentWindow.ToolTip(Item.HelpText);
        }
    }
    else
        ParentWindow.ToolTip("");
}

defaultproperties
{
}
