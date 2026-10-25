//=============================================================================
//  R6WindowTextIconsListBox.uc : New and improved List Box
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/22 * Created by Alexandre Dionne
//=============================================================================


class R6WindowTextIconsListBox extends R6WindowListBox;

const C_iFIRST_ICON_XPOS            = 3;
const C_iDISTANCE_BETWEEN_ICON		= 4;// the distance between icons 

var Color   m_BGSelColor;				// BackGround color when selected
var Texture m_BGSelTexture;				// BackGround texture under item when selected
var Region  m_BGSelRegion;				// BackGround texture Region under item when selected
var ERenderStyle m_BGRenderStyle;

var Texture	m_HealthIconTexture;		// texture for the health icon

var color   m_SeparatorTextColor;		// If we want the Separator to be displayed another color
var Color   m_SelTextColor;				// color for selected text
var Color   m_DisabledTextColor;		// color text item disabled

var bool    bScrollable;

var Font    m_font;
var Font	m_FontSeparator;			// font for the separator

var float   m_fFontSpacing;
var bool    m_IgnoreAllreadySelected;	//Don't send the click event if we select the same item that is currently selected


function Created()
{
	Super.Created();
	
    m_font = Root.Fonts[F_VerySmallTitle];
	m_FontSeparator = Root.Fonts[F_ListItemBig];
    
    TextColor           = Root.Colors.m_LisBoxNormalTextColor;
    m_SelTextColor      = Root.Colors.m_LisBoxSelectedTextColor;
    m_BGSelColor        = Root.Colors.m_LisBoxSelectionColor;
    m_DisabledTextColor = Root.Colors.m_LisBoxDisabledTextColor;
    m_SeparatorTextColor = Root.Colors.m_LisBoxSpectatorTextColor;
    m_BGRenderStyle     = ERenderStyle.STY_Alpha;
} 


function BeforePaint(Canvas C, FLOAT fMouseX, FLOAT fMouseY)
{
    if(m_VertSB != None)
    {
        m_VertSB.SetBorderColor(m_BorderColor);
    }	    
 
    Super.BeforePaint(C, fMouseX, fMouseY);
}

function Paint(Canvas C, FLOAT fMouseX, FLOAT fMouseY)
{
    
    R6WindowLookAndFeel(LookAndFeel).R6List_DrawBackground(self,C);
    
    Super.Paint( C, fMouseX, fMouseY);
    
}

function DrawItem(Canvas C, UWindowList Item, FLOAT X, FLOAT Y, FLOAT W, FLOAT H)
{
    local R6WindowListBoxItem pItem;
	local Region RIcon;
	local string szClipText;
	local float TW, TH, TextX, TextY;
    
    pItem = R6WindowListBoxItem(Item);

    //Draw the high Light
    if(pItem.bSelected)
	{	
    	if(m_BGSelTexture != NONE)
		{
            
            C.Style = m_BGRenderStyle;
			C.SetDrawColor(m_BGSelColor.R,m_BGSelColor.G,m_BGSelColor.B);			

		    DrawStretchedTextureSegment( C, X, Y, W, H, m_BGSelRegion.X, m_BGSelRegion.Y, 
						m_BGSelRegion.W, m_BGSelRegion.H,	m_BGSelTexture );
				
		}
    }
    
    TextX = X;

    //Draw the Icon
    if( pItem.m_Icon != None)
    {
        if(pItem.m_addedToSubList)
			RIcon = pItem.m_IconRegion;        
        else        
            RIcon = pItem.m_IconSelectedRegion;        

        C.Style = ERenderStyle.STY_Alpha;
        C.SetDrawColor(Root.Colors.White.R,Root.Colors.White.G,Root.Colors.White.B);			

        TextX += C_iFIRST_ICON_XPOS;

        DrawStretchedTextureSegment( C, TextX, GetYIconPos( Y, H, RIcon.H), RIcon.W, RIcon.H, 
										RIcon.X, RIcon.Y, RIcon.W, RIcon.H,	pItem.m_Icon );	
        
		TextX += C_iDISTANCE_BETWEEN_ICON + RIcon.W;

        if (pItem.m_Object.IsA('R6Operative'))
		{
            if (pItem.m_addedToSubList)	
                C.SetDrawColor(m_DisabledTextColor.r,m_DisabledTextColor.g,m_DisabledTextColor.b);               

			TextX += C_iDISTANCE_BETWEEN_ICON + DrawHealthIcon( C, TextX, Y, H, R6Operative(pItem.m_Object).m_iHealth);
		}
    }

    //Draw the Text
    C.Font = m_font;
    if (pItem.m_IsSeparator)
	{
		C.Font = m_FontSeparator;
        C.SetDrawColor(m_SeparatorTextColor.r,m_SeparatorTextColor.g,m_SeparatorTextColor.b);
	}
    else if (pItem.m_addedToSubList)	
        C.SetDrawColor(m_DisabledTextColor.r,m_DisabledTextColor.g,m_DisabledTextColor.b);    
    else if(pItem.bSelected)    
        C.SetDrawColor(m_SelTextColor.r,m_SelTextColor.g,m_SelTextColor.b);    
    else
	    C.SetDrawColor(TextColor.r,TextColor.g,TextColor.b);


    C.SpaceX = m_fFontSpacing;
    C.Style = ERenderStyle.STY_Alpha;

	szClipText = TextSize(C, pItem.HelpText, TW, TH, W - TextX, m_fFontSpacing);

	TextY = (H - TH) * 0.5;
    TextY = FLOAT(INT(TextY+0.5));
    
	C.SetPos(TextX, Y + TextY);
	C.DrawText(szClipText);
}



function FLOAT DrawHealthIcon( Canvas C, FLOAT _fX, FLOAT _fY, FLOAT _fH, INT _iHealthStatus)
{
	local Region RHealthIcon;

	RHealthIcon = GetHealthIconRegion(_iHealthStatus);

	DrawStretchedTextureSegment( C, _fX, GetYIconPos( _fY, _fH, RHealthIcon.H), RHealthIcon.W, RHealthIcon.H, 
									RHealthIcon.X, RHealthIcon.Y, RHealthIcon.W, RHealthIcon.H,	m_HealthIconTexture);

	return RHealthIcon.W;
}

function FLOAT GetYIconPos( FLOAT _fYItemPos, FLOAT _fItemHeight, FLOAT _fIconHeight)
{
	local FLOAT fTemp;

	fTemp = (_fItemHeight - _fIconHeight) * 0.5; //This is to adjust the Icon at a middle height
	fTemp = FLOAT(INT(fTemp+0.5)) + _fYItemPos;

	return fTemp;
}

function Region GetHealthIconRegion( INT _iOperativeHealth)
{
	local Region RTemp;

	RTemp.X = 500;
	RTemp.W = 8;
	RTemp.H = 8;

	switch(_iOperativeHealth)
	{
		case 0: // Ready
			RTemp.Y = 0;
			break;
		case 1: // wounded
			RTemp.Y = 8;
			break;
		case 2: // incapacitated
		case 3:	// dead
			RTemp.Y = 16;
			break;
	}

	return RTemp;
}

function SetSelectedItem(UWindowListBoxItem NewSelected)
{

	if(NewSelected != None  && (R6WindowListBoxItem(NewSelected).m_IsSeparator == False))
	{

        if(m_IgnoreAllreadySelected && (m_SelectedItem == NewSelected) )
            return;

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

function SetScrollable(bool newScrollable)
{
	bScrollable = newScrollable;
	if(newScrollable)
	{
		m_VertSB = R6WindowVScrollbar(CreateWindow(m_SBClass, WinWidth-LookAndFeel.Size_ScrollbarWidth, 0, LookAndFeel.Size_ScrollbarWidth, WinHeight));
		m_VertSB.bAlwaysOnTop = True;
	}
	else
	{
		if (m_VertSB != None)
		{
			m_VertSB.Close();
			m_VertSB = None;
		}
	}
}

defaultproperties
{
     m_IgnoreAllreadySelected=True
     m_BGSelTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     m_HealthIconTexture=Texture'R6HUD.HUDElements'
     m_BGSelColor=(B=128)
     m_BGSelRegion=(X=253,W=2,H=13)
     m_SeparatorTextColor=(B=255,G=255,R=255)
     m_SelTextColor=(B=255,G=255,R=255)
     m_DisabledTextColor=(B=136,G=140,R=141)
     m_fItemHeight=11.000000
     m_fSpaceBetItem=0.000000
     ListClass=Class'R6Window.R6WindowListBoxItem'
     TextColor=(B=255,G=255,R=255)
}
