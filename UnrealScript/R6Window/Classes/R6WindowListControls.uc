//=============================================================================
//  R6WindowListControls.uc : Create the controls page in options. Scrollbar page with 3 types of the same items
//							  Title, selected item and line item
//							  see default properties for some settings
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/16 * Created by Yannick Joly
//=============================================================================

class R6WindowListControls extends R6WindowTextListBox;

var UWindowListBoxItem					m_pPreviousItem;

var FLOAT								m_fXOffset;

// for the draw line
var Region								m_BorderTextureRegion;
var Texture								m_BorderTexture;

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
        fdrawWidth = WinWidth;    
    else
        fdrawWidth = WinWidth - m_VertSB.WinWidth;

	m_iTotItemsDisplayed = 0;

    for(y = LAF.m_SBHBorder.H; (y + fItemHeight <= fListHeight) && (CurItem != None); CurItem = CurItem.Next)
	{
		if(CurItem.ShowThisItem())
		{	
			if (UWindowListBoxItem(CurItem).m_bImALine)
	            DrawItem(C, CurItem, m_fXOffset, y, fdrawWidth, fItemHeight);
			else
				DrawItem(C, CurItem, m_fXOffset, y, fdrawWidth - m_fXOffset, fItemHeight);
			
			y = y + fItemHeight;

			m_iTotItemsDisplayed++;
		}
	}
}


function DrawItem(Canvas C, UWindowList Item, FLOAT X, FLOAT Y, FLOAT W, FLOAT H)
{
	local FLOAT fXPos, fW, fH, fTextY;
	local INT Temp;
 	local Texture T;
	local UWindowListBoxItem pListBoxItem;

	pListBoxItem = UWindowListBoxItem(Item);

	C.SetDrawColor(UWindowListBoxItem(Item).m_vItemColor.R , UWindowListBoxItem(Item).m_vItemColor.G, UWindowListBoxItem(Item).m_vItemColor.B);

	if (pListBoxItem.m_bImALine)
	{
		// draw a line
	    C.Style = ERenderStyle.STY_Alpha;
		
		if ((H % 2 > 0) && (m_BorderTextureRegion.H<=1.0))
			H = H+1;

		DrawStretchedTextureSegment(C, 1, Y + (H * 0.5), W - 1, m_BorderTextureRegion.H, 
									   m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
	}
	else
	{
		if (pListBoxItem.HelpText != "")
		{
			C.Style = ERenderStyle.STY_Alpha;
   			C.Font = Root.Fonts[F_ListItemBig]; 
			C.SpaceX = m_fFontSpacing;

			TextSize(C, UWindowListBoxItem(Item).HelpText, fW, fH);
			
			fTextY = (m_fItemHeight - fH) * 0.5;
			fTextY = FLOAT(INT(TextY+0.5));

			// do you have a fake edit box for this item ?
			if (pListBoxItem.m_szActionKey != "")
			{
				// draw the edit box background
			    T = Texture'UWindow.WhiteTexture';
				C.DrawColor = Root.Colors.Black;
				C.Style = ERenderStyle.STY_Alpha;
				C.SetDrawColor( C.DrawColor.R, C.DrawColor.G, C.DrawColor.B, 50);
				DrawStretchedTexture( C, pListBoxItem.m_fXFakeEditBox, Y + fTextY, pListBoxItem.m_fWFakeEditBox, H, T);
				
				// draw the text
				C.SetDrawColor(pListBoxItem.m_vItemColor.R , pListBoxItem.m_vItemColor.G, pListBoxItem.m_vItemColor.B);
				// center the text for a beautiful effect
				TextSize(C, pListBoxItem.m_szFakeEditBoxValue, fW, fH);

				fXPos = pListBoxItem.m_fXFakeEditBox + (pListBoxItem.m_fWFakeEditBox - fW) / 2;

				ClipTextWidth(C, fXPos, Y + fTextY, pListBoxItem.m_szFakeEditBoxValue, W);
			}
			
			ClipTextWidth(C, X + 2, Y + fTextY, pListBoxItem.HelpText, W);
		}
	}
}


function MouseMove(FLOAT X, FLOAT Y)
{
	Super.MouseMove(X, Y);

	ManageOverEffect( X, Y);
}

function MouseLeave()
{
	Super.MouseLeave();
	ManageOverEffect( 0, 0);
}

function ManageOverEffect(FLOAT X, FLOAT Y)
{
	local UWindowListBoxItem OverItem;

	OverItem = GetItemAt(X, Y);

	if (m_pPreviousItem != None)
	{
		m_pPreviousItem.m_vItemColor = Root.Colors.White;
		m_pPreviousItem = None;
		ToolTip("");
	}

	if (OverItem != None)
	{
		if (!OverItem.m_bNotAffectByNotify)
		{
			// Im over an fake edit box
//			if ( (X > OverItem.m_fXFakeEditBox) && 
//				 (X < OverItem.m_fXFakeEditBox + OverItem.m_fWFakeEditBox) )
//			{
				// change the color of item
				OverItem.m_vItemColor = Root.Colors.BlueLight;
				ToolTip(OverItem.m_szToolTip);
				m_pPreviousItem = OverItem;
//			}
		}
	}
}

//=====================================================================
// SetSelectedItem: derivate from R6WindowListBox
//=====================================================================
function SetSelectedItem(UWindowListBoxItem NewSelected)
{
	if(NewSelected != None)
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
		
		if (m_pPreviousItem != None)
			Notify(DE_Click);
	}
}

defaultproperties
{
     m_BorderTexture=Texture'UWindow.WhiteTexture'
     m_BorderTextureRegion=(W=1,H=1)
     m_fItemHeight=20.000000
     m_fSpaceBetItem=0.000000
}
