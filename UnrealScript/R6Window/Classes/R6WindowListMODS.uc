//=============================================================================
//  R6WindowListMODS.uc : List of all MODS
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/05/20 * Created by Yannick Joly
//=============================================================================

class R6WindowListMODS extends R6WindowTextListBox;

enum eItemState
{
	eIS_Normal,				// item was displaying without any attributes
	eIS_Disable,			// item was displaying but it was disabled
	eIS_Selected,			// this item was the selection in the list, highlight was apply on this item
	eIS_CurrentChoice		// this item was the current choice
};

var Color   m_CurrentChoiceColor;	  // color for current choice text (item)

function Created()
{
	Super.Created();

	m_CurrentChoiceColor = Root.Colors.Yellow;
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
			i++;
		    CurItem = CurItem.Next;
	    }
    }

	// check the width of the list box
    if( (m_VertSB == None) || (m_VertSB.isHidden()))
        fdrawWidth = WinWidth - (2*m_fXItemOffset);    
    else
        fdrawWidth = WinWidth - m_VertSB.WinWidth - (2*m_fXItemOffset);

	m_iTotItemsDisplayed = 0;

    for(y = 0; (y + fItemHeight <= fListHeight) && (CurItem != None); CurItem = CurItem.Next)
	{
		if(CurItem.ShowThisItem())
		{	
            DrawItem(C, CurItem, m_fXItemOffset, y, fdrawWidth, fItemHeight);
			
			y = y + fItemHeight;

			m_iTotItemsDisplayed++;
		}
	}
}

function DrawItem(Canvas C, UWindowList Item, FLOAT X, FLOAT Y, FLOAT W, FLOAT H)
{
	local UWindowListBoxItem pIt;
	local string szToDisplay;
	local FLOAT TW,TH, fYPos;
	local INT i, j;
	local UWindowListBoxItem.stItemProperties pCurrentItem;

#ifdefDEBUG
	local BOOL bShowSeparator;
#endif

	pIt = UWindowListBoxItem(Item);

	if ((pIt != None) && (pIt.m_AItemProperties.Length == 0))
		return;

	if (pIt.bSelected)
	{
		if(m_BGSelTexture != NONE)
		{
			C.Style = m_BGRenderStyle;

			// We draw the extremities then we tile			
			C.SetDrawColor(m_BGSelColor.R,m_BGSelColor.G,m_BGSelColor.B);

			DrawStretchedTextureSegment( C, X, Y, W, H, 
										 m_BGSelRegion.X, m_BGSelRegion.Y, m_BGSelRegion.W, m_BGSelRegion.H, m_BGSelTexture );
		}
	}

	for ( i = 0; i < pIt.m_AItemProperties.Length; i++)
	{

		pCurrentItem = pIt.m_AItemProperties[i];
   	    C.Font = pCurrentItem.TextFont; 
        C.SpaceX = m_fFontSpacing;

		if (m_bForceCaps)
		    szToDisplay = TextSize(C, Caps(pCurrentItem.szText), TW, TH, pCurrentItem.fWidth); 
		else
			szToDisplay = TextSize(C, pCurrentItem.szText, TW, TH, pCurrentItem.fWidth);

		// define text color of the item
		if ( pIt.m_bDisabled)
		{
			C.SetDrawColor(m_DisableTextColor.r,m_DisableTextColor.g,m_DisableTextColor.b);
		}
		else if (pIt.m_iItemID == eItemState.eIS_CurrentChoice)
		{
			C.SetDrawColor(m_CurrentChoiceColor.r,m_CurrentChoiceColor.g,m_CurrentChoiceColor.b);
		}
		else
		{
			C.SetDrawColor(TextColor.r,TextColor.g,TextColor.b);
		}

		// display

        fYPos = (pCurrentItem.fHeigth - TH) / 2;
        fYPos = FLOAT(INT(fYPos+0.5));

		fYPos += pCurrentItem.fYPos;

		if (pCurrentItem.iLineNumber != 0)
		{
			for ( j = 0; j < pCurrentItem.iLineNumber; j++)
			{
				fYPos += pCurrentItem.fHeigth;
			}
		}


#ifdefDEBUG
		// DEBUG
	    if (bShowSeparator) DrawStretchedTextureSegment(C, pCurrentItem.fXPos, Y + fYPos, WinWidth, m_BorderTextureRegion.H , m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
#endif

		switch(pCurrentItem.eAlignment)
		{
			case TA_RIGHT:
				C.SetPos(pCurrentItem.fXPos - TW, Y + fYPos );	
				break;
			case TA_LEFT:
				C.SetPos(pCurrentItem.fXPos, Y + fYPos);
				break;
			case TA_CENTER:
				C.SetPos(pCurrentItem.fXPos - (TW / 2.0), Y+fYPos);
				break;
		}
	    
	    C.DrawText(szToDisplay);
	}


}

// For not rewrite the class R6WindowListBox with the new system of item properties, hack the value
// over here
function FLOAT GetSizeOfAnItem( UWindowList _pItem)
{
	local FLOAT fTotalHeight;
	local INT i, iLineNumber;
#ifdefDEBUG
	local BOOL bShowItemHeight;
#endif

	iLineNumber =0;

	for ( i = 0; i < UWindowListBoxItem(_pItem).m_AItemProperties.Length; i++)
	{
		if (UWindowListBoxItem(_pItem).m_AItemProperties[i].iLineNumber == iLineNumber)
		{
			iLineNumber++;
			fTotalHeight += UWindowListBoxItem(_pItem).m_AItemProperties[i].fHeigth;
		}
	}

#ifdefDEBUG
	if (bShowItemHeight) log("fTotalHeight: "@fTotalHeight);
#endif

	return fTotalHeight;
}

function SetSelectedItem(UWindowListBoxItem NewSelected)
{
	local BOOL bNotify;

	if( (NewSelected != None) && (m_SelectedItem != NewSelected) )
	{
		if (NewSelected.m_bDisabled) // this item is not selectionnable yet
			return;

		bNotify = true;
		if ( R6WindowListBoxItem(NewSelected) != None )
		{
			bNotify = !R6WindowListBoxItem(NewSelected).m_IsSeparator;
		}

		if (bNotify)
		{
			if(m_SelectedItem != None)
			{
				m_SelectedItem.bSelected = False;

				if (m_SelectedItem.m_iItemID !=  eItemState.eIS_CurrentChoice)
					m_SelectedItem.m_iItemID = eItemState.eIS_Normal;
			}

			m_SelectedItem = NewSelected;

			if(m_SelectedItem != None)
			{
				m_SelectedItem.bSelected = True;

				if (m_SelectedItem.m_iItemID !=  eItemState.eIS_CurrentChoice)
					m_SelectedItem.m_iItemID = eItemState.eIS_Selected;
			}
			
			Notify(DE_Click);
		}
	}
}


//=====================================================================================
// SetItemState: Set the item state, return true when succeed operation 
//=====================================================================================
function BOOL SetItemState(UWindowListBoxItem _NewItem, eItemState _eISState, optional BOOL _bForceSelection)
{
	if (_NewItem == None)
		return false;

	// reset values
	_NewItem.m_bDisabled = false;	
//	_NewItem.bSelected   = false;

	switch(_eISState)
	{
		case eIS_Normal:
			_NewItem.m_iItemID	 = eItemState.eIS_Normal;
			break;
		case eIS_Disable:
			_NewItem.m_iItemID	 = eItemState.eIS_Disable;
			_NewItem.m_bDisabled = true;
			break;

		case eIS_Selected:
			_NewItem.m_iItemID	 = eItemState.eIS_Selected;
			_NewItem.bSelected   = true;
			m_SelectedItem		 = _NewItem;
			break;

		case eIS_CurrentChoice:
			_NewItem.m_iItemID	 = eItemState.eIS_CurrentChoice;

			if (_bForceSelection)
			{
				_NewItem.bSelected   = true;
				m_SelectedItem		 = _NewItem;
			}
			break;
	}

	return true;
}


//=====================================================================================
// ActivateMOD: Activate the current selection to be the current choice 
//=====================================================================================
function ActivateMOD()
{
	local array<UWindowRootWindow.eGameWidgetID> AWIDList;
	local UWindowListBoxItem pListBoxItem;

	pListBoxItem = UWindowListBoxItem(FindCurrentMOD());

	// find the current choice
	if (pListBoxItem != None)
	{
		// it's not the current choice?
		if (pListBoxItem == m_SelectedItem)
		{
			// already in this mod
			return;
		}

		// change to the new one
		pListBoxItem.m_iItemID = eItemState.eIS_Normal;

		if(m_SelectedItem != None)
		{
			m_SelectedItem.m_iItemID = eItemState.eIS_CurrentChoice;
			class'Actor'.static.GetModMgr().SetCurrentMod(m_SelectedItem.HelpText, GetLevel(), true, Root.Console, GetPlayerOwner().xlevel);
			class'Actor'.static.GetServerOptionsRefreshed();
			// once the mod is loaded, go back through the previous widget to the options
			AWIDList[AWIDList.Length] = Root.m_ePrevWidgetInUse;
			AWIDList[AWIDList.Length] = OptionsWidgetID;
			R6Console(Root.console).CleanAndChangeMod(AWIDList);
		}

	}
}


//=====================================================================================
// FindCurrentMOD: Find item of the current MOD 
//=====================================================================================
function UWindowList FindCurrentMOD()
{
	local UWindowList CurItem;

	CurItem = Items.Next;

	while (CurItem != None) 
    {
		if (!R6WindowListBoxItem(CurItem).m_IsSeparator)
			if (R6WindowListBoxItem(CurItem).m_iItemID == eItemState.eIS_CurrentChoice)
				break;

		CurItem = CurItem.Next;	
	}

	return CurItem;
}

defaultproperties
{
     m_fXItemOffset=2.000000
     ListClass=Class'UWindow.UWindowListBoxItem'
}
