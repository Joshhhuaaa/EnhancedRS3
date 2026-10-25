//=============================================================================
//  R6WindowTextListBox.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//    2001/12/13 * Modified by Alexandre Dionne
//=============================================================================

class R6WindowTextListBox extends R6WindowListBox;

const C_iSEL_BORDER_WIDTH		= 2; // the selected border width

var Color   m_BGSelColor;       // BackGround color when selected

var Texture m_BGSelTexture;     // BackGround texture under item when selected
var Region  m_BGSelRegion;      // BackGround texture Region under item when selected
var ERenderStyle m_BGRenderStyle;

//var color   TextColor;          // color for text            N.B. var already define in class UWindowDialogControl
var Color   m_SelTextColor;		  // color for selected text
var color   m_SeparatorTextColor; //If we want the Separator to be displayed another color
var Color   m_DisableTextColor;	  // color for disable text (item)

var Font    m_font;
var Font	m_FontSeparator;			// font for the separator

var float   m_fFontSpacing;

function Created()
{
	Super.Created();       

    m_font = Root.Fonts[F_VerySmallTitle];
	m_FontSeparator = Root.Fonts[F_ListItemBig];
    
    TextColor           = Root.Colors.m_LisBoxNormalTextColor;
    m_SelTextColor      = Root.Colors.m_LisBoxSelectedTextColor;
    m_BGSelColor        = Root.Colors.m_LisBoxSelectionColor;    
    m_SeparatorTextColor = Root.Colors.m_LisBoxSeparatorTextColor;
	m_DisableTextColor	= Root.Colors.m_LisBoxDisabledTextColor;
    m_BGRenderStyle     = ERenderStyle.STY_Alpha;
	m_VertSB.SetHideWhenDisable(true); // hide the scrollbar when is disable
}


function BeforePaint(Canvas C, FLOAT fMouseX, FLOAT fMouseY)
{    
      m_VertSB.SetBorderColor(m_BorderColor);
}

function Paint(Canvas C, FLOAT fMouseX, FLOAT fMouseY)
{    
    if(!m_bSkipDrawBorders)
        R6WindowLookAndFeel(LookAndFeel).R6List_DrawBackground(self,C);
    
    Super.Paint( C, fMouseX, fMouseY);
}

function DrawItem(Canvas C, UWindowList Item, FLOAT X, FLOAT Y, FLOAT W, FLOAT H)
{
	local string szToDisplay;
	local float TextY, TW,TH, fTemp;
	local UWindowListBoxItem pListBoxItem;

	pListBoxItem = UWindowListBoxItem(Item);

    if (pListBoxItem.HelpText != "")
    {
   	    C.Font = m_font; 
        C.SpaceX = m_fFontSpacing;

		if (m_bForceCaps)
		    szToDisplay = TextSize(C, Caps(pListBoxItem.HelpText), TW, TH, W); 
		else
			szToDisplay = TextSize(C, pListBoxItem.HelpText, TW, TH, W);

		if(pListBoxItem.bSelected)
		{
			if(m_BGSelTexture != NONE)
			{
				C.Style = m_BGRenderStyle;

				// We draw the extremities then we tile			
				C.SetDrawColor(m_BGSelColor.R,m_BGSelColor.G,m_BGSelColor.B);
				
				DrawStretchedTextureSegment( C, X, Y, W, H - m_fSpaceBetItem, 
											 m_BGSelRegion.X, m_BGSelRegion.Y, m_BGSelRegion.W, m_BGSelRegion.H, m_BGSelTexture );
					
			}
    
			C.SetDrawColor(m_SelTextColor.r,m_SelTextColor.g,m_SelTextColor.b);
		}
		else if ( pListBoxItem.m_bDisabled)
		{
			C.SetDrawColor(m_DisableTextColor.r,m_DisableTextColor.g,m_DisableTextColor.b);
		}
		else
		{
			if( R6WindowListBoxItem(Item) != None && R6WindowListBoxItem(Item).m_IsSeparator)
            {
                C.Font = m_FontSeparator;
				C.SetDrawColor(m_SeparatorTextColor.r,m_SeparatorTextColor.g,m_SeparatorTextColor.b);
            }                
			else
				C.SetDrawColor(TextColor.r,TextColor.g,TextColor.b);
		}

        C.Style = ERenderStyle.STY_Alpha;

		ClipText(C, X, Y, szToDisplay, true);

        if (pListBoxItem.m_bUseSubText)
        {
            fTemp = Y + TH; // the Y pos after first text
            
    	    C.Font = pListBoxItem.m_stSubText.FontSubText;

    	    TextSize(C, pListBoxItem.m_stSubText.szGameTypeSelect, TW, TH);
            TextY = (pListBoxItem.m_stSubText.fHeight - TH) / 2;
            TextY = FLOAT(INT(TextY+0.5));

            ClipTextWidth(C, X + pListBoxItem.m_stSubText.fXOffset, fTemp + TextY, pListBoxItem.m_stSubText.szGameTypeSelect, W - 12);
        }
    }
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
			}

			m_SelectedItem = NewSelected;

			if(m_SelectedItem != None)
			{
				m_SelectedItem.bSelected = True;
			}
			
			Notify(DE_Click);
		}
	}
}

//=====================================================================================
// FindItemWithName: Find item depending is name 
//=====================================================================================
function UWindowList FindItemWithName( string _ItemName)
{
	local UWindowList CurItem;

	if (_ItemName == "")
		return None;

	CurItem = Items.Next;

	while (CurItem != None) 
    {
		if (!R6WindowListBoxItem(CurItem).m_IsSeparator)
			if (R6WindowListBoxItem(CurItem).HelpText == _ItemName)
				break;

		CurItem = CurItem.Next;	
	}

	return CurItem;
}

defaultproperties
{
     m_BGSelTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     m_BGSelColor=(B=128)
     m_BGSelRegion=(X=253,W=2,H=13)
     m_SelTextColor=(B=255,G=255,R=255)
     m_SeparatorTextColor=(B=255,G=255,R=255)
     m_fItemHeight=12.000000
     m_fXItemOffset=5.000000
     ListClass=Class'R6Window.R6WindowListBoxItem'
     TextColor=(B=255,G=255,R=255)
}
