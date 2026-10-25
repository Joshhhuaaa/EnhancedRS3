//=============================================================================
//  R6WindowComboList.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6WindowComboList extends UWindowComboList;

var Color   m_BGColor;          // BackGround color 
var Color   m_BGSelColor;       // BackGround color when selected

var Texture m_BGSelTexture;     // BackGround texture under item when selected
var Region  m_BGSelRegion;      // BackGround texture Region under item when selected

var ERenderStyle m_BGRenderStyle;
var ERenderStyle m_BGSelRenderStyle;

//var color   TextColor;			// color for text            N.B. var already define in class UWindowDialogControl
var Color   m_SelTextColor;			// color for selected text (item)
var Color   m_DisableTextColor;		// color for disable text (item)

var class<UWindowVScrollBar>	m_SBClass;

function Created()
{
    Super.Created();

    TextColor           = Root.Colors.m_LisBoxNormalTextColor;
    m_SelTextColor      = Root.Colors.m_LisBoxSelectedTextColor;
	m_DisableTextColor  = Root.Colors.m_LisBoxDisabledTextColor;
    m_BGSelColor        = Root.Colors.m_LisBoxSelectionColor;        
    m_BGRenderStyle     = ERenderStyle.STY_Normal;
    m_BGSelRenderStyle  = ERenderStyle.STY_Alpha;
    m_BGColor           = Root.Colors.m_ComboBGColor;
}

function Setup()
{
	VertSB = UWindowVScrollBar(CreateWindow(m_SBClass, WinWidth - LookAndFeel.Size_ScrollbarWidth, 0, LookAndFeel.Size_ScrollbarWidth, WinHeight));
}

function BeforePaint(Canvas C, float X, float Y)
{
	local FLOAT W, H; //, MaxWidth;
	local INT Count;
	local UWindowComboListItem I;
	local FLOAT ListX, ListY;
	//local FLOAT ExtraWidth;

//	C.Font = Root.Fonts[F_Normal];
//	C.SetPos(0, 0);

	//MaxWidth = Owner.EditBoxWidth;
	//ExtraWidth = ((HBorder + TextBorder) * 2);

	Count = Items.Count();
	if(Count > MaxVisible)
	{
		//ExtraWidth += LookAndFeel.Size_ScrollbarWidth;
		WinHeight = (ItemHeight * MaxVisible) + (VBorder * 2);
	}
	else
	{
		VertSB.Pos = 0;
		WinHeight = (ItemHeight * Count) + (VBorder * 2);
	}

    /*
	for( I = UWindowComboListItem(Items.Next);I != None; I = UWindowComboListItem(I.Next) )
	{
		TextSize(C, RemoveAmpersand(I.Value), W, H);
		if(W + ExtraWidth > MaxWidth)
			MaxWidth = W + ExtraWidth;
	}
    */
	//WinWidth = MaxWidth;

//	ListX = Owner.EditAreaDrawX + Owner.EditBoxWidth - WinWidth;
	ListX = Owner.EditBox.WinLeft;
	ListY = Owner.Button.WinTop + Owner.Button.WinHeight -1;

	if(Count > MaxVisible)
	{
		VertSB.ShowWindow();
		VertSB.SetRange(0, Count, MaxVisible);
		VertSB.WinLeft = WinWidth - LookAndFeel.Size_ScrollbarWidth;
		VertSB.WinTop = 0;
		VertSB.SetSize(LookAndFeel.Size_ScrollbarWidth, WinHeight);
    }
	else
	{
		VertSB.HideWindow();
	}

	Owner.WindowToGlobal(ListX, ListY, WinLeft, WinTop);
}

//-----------------------------------------------------------------------------
// There was a bug in the paint in the parent class (UWindowComboList), to 
// avoid an ugly merge, overload the Paint() function here and correct the bug.
//-----------------------------------------------------------------------------
function Paint(Canvas C, float X, float Y)
{
	local int Count;
	local UWindowComboListItem I;

	DrawMenuBackground(C);
	
	Count = 0;
    C.Font = Root.Fonts[Font];

	for( I = UWindowComboListItem(Items.Next);I != None; I = UWindowComboListItem(I.Next) )
	{
		if(VertSB.bWindowVisible)
		{
			if(Count >= VertSB.Pos && ( Count - INT(VertSB.Pos) < MaxVisible ) )
				DrawItem(C, I, HBorder, VBorder + (ItemHeight * (Count - VertSB.Pos)), WinWidth - (2 * HBorder) - VertSB.WinWidth, ItemHeight);
		}
		else
			DrawItem(C, I, HBorder, VBorder + (ItemHeight * Count), WinWidth - (2 * HBorder), ItemHeight);
		Count++;
	}
}

function DrawMenuBackground(Canvas C)
{    
    C.Style = m_BGRenderStyle;

    C.SetDrawColor(m_BGColor.R,m_BGColor.G,m_BGColor.B);
    
    DrawStretchedTextureSegment(C, 0, 0, WinWidth, WinHeight, m_BorderTextureRegion.X, m_BorderTextureRegion.Y, 
													m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
    
    DrawSimpleBorder(C);
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{	 
	local UWindowComboListItem pComboListItem;

	pComboListItem = UWindowComboListItem(item);

    if(Selected == Item)
	{   
        C.Style = m_BGSelRenderStyle;            
        
		// We draw the extremities then we tile			
		C.SetDrawColor(m_BGSelColor.R,m_BGSelColor.G,m_BGSelColor.B);
		

		DrawStretchedTextureSegment( C, X, Y, W, H, m_BGSelRegion.X, m_BGSelRegion.Y, 
					m_BGSelRegion.W, m_BGSelRegion.H,	m_BGSelTexture );
		    
        C.SetDrawColor(m_SelTextColor.r,m_SelTextColor.g,m_SelTextColor.b);
	}
	else if ( pComboListItem.bDisabled)
	{
		C.SetDrawColor(m_DisableTextColor.r,m_DisableTextColor.g,m_DisableTextColor.b);
	}
	else
    {
        C.SetDrawColor(TextColor.r,TextColor.g,TextColor.b);
	}
    
    
    ClipText(C, X + TextBorder + 2, Y + 3, pComboListItem.Value);
}

defaultproperties
{
     m_BGSelTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     m_SBClass=Class'R6Window.R6WindowVScrollbar'
     m_BGSelRegion=(X=253,W=2,H=13)
}
