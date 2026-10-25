//=============================================================================
//  R6MenuLegendPage.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/29 * Created by Joel Tremblay
//=============================================================================

class R6MenuLegendPage extends R6MenuPopupListButton;

var localized string            m_szPageTitle;
var FLOAT   m_fTitleWidth;
var INT     m_iTextureSize;//Texture will be displayed as 32x32
var INT     m_iSpaceBetweenTextureNText;
var INT     m_iSpaceEnd; //little space at the end of the text

function Created()
{
    Super.Created();

    m_fItemHeight = m_iTextureSize;
}

function BeforePaint(Canvas C, FLOAT MouseX, FLOAT MouseY)
{
    local INT i;
    local INT iCurrentNbButton;
    local FLOAT fTitleHeight;
    local FLOAT fWidth, fHeight, fMaxWidth;

    if(bInitialized == false)
    {
        bInitialized = true;
        C.Font = Root.Fonts[F_HelpWindow];
        for(i=0;i<m_iNbButton;i++)
        {
            if((m_ButtonItem[i]!=None) && (m_ButtonItem[i].m_Button!=None))
            {
                TextSize(C, m_ButtonItem[i].m_Button.Text, fWidth, fHeight);
                fWidth += m_iSpaceEnd;

                //Log("Got text: "$m_ButtonItem[i].m_Button.Text);
                if(fWidth > fMaxWidth)
                {
                    fMaxWidth = fWidth;
                }
            }
        }

        //New window Width
        WinWidth = fMaxWidth + m_iTextureSize + m_iSpaceBetweenTextureNText; 
        
        if(m_szPageTitle != "")
        {
            C.Font = Root.Fonts[F_PopUpTitle];
    	    TextSize(C, m_szPageTitle, m_fTitleWidth, fTitleHeight);

            // (2 x FrameTitleX) = 12
            //Add the two navigation button width to total
            fMaxWidth = m_fTitleWidth + 12.0 + (R6WindowLegend(ParentWindow).m_NavButtonSize * 2); 
        }

        if( WinWidth < fMaxWidth )
        {
            WinWidth = fMaxWidth;
        }

        m_fItemHeight = m_iTextureSize;
        iCurrentNbButton = 0;

        for(i=0;i<m_iNbButton;i++)
        {
            if((m_ButtonItem[i]!=None) && (m_ButtonItem[i].m_Button!=None))
            {
                m_ButtonItem[i].m_Button.TextColor = Root.Colors.White;
                m_ButtonItem[i].m_Button.WinWidth  = WinWidth;
                m_ButtonItem[i].m_Button.WinHeight = m_fItemHeight;
                iCurrentNbButton++;
            }
        }
    
        WinHeight = m_fItemHeight*iCurrentNbButton + (iCurrentNbButton-1);
        ParentWindow.Resized();
    }
}

function Paint(Canvas C, FLOAT MouseX, FLOAT MouseY)
{
	local FLOAT x;
    local FLOAT y;
	local UWindowList CurItem;

 	local Color lcolor;
	C.SetDrawColor(255,255,255); 

    if(m_fItemWidth==0)
        m_fItemWidth = WinWidth;

    x = (WinWidth-m_fItemWidth)/2;
   
    C.Style=GetPlayerOwner().ERenderStyle.STY_Alpha;
    for(CurItem = Items.Next; CurItem != None; CurItem = CurItem.Next)
	{
        R6WindowListButtonItem(CurItem).m_Button.ShowWindow();
        DrawItem(C, CurItem, x, y, m_fItemWidth, m_fItemHeight);
        y += m_fItemHeight;
        if(y < WinHeight)
        {
            // Draw line between button
            lcolor = Root.Colors.TeamColorLight[R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam];

            C.SetDrawColor(lcolor.R,lcolor.G,lcolor.B, Root.Colors.PopUpAlphaFactor);
            DrawStretchedTextureSegment(C, x, y, m_SeperatorLineRegion.W + m_iTextureSize, m_SeperatorLineRegion.H, m_SeperatorLineRegion.X, m_SeperatorLineRegion.Y, m_SeperatorLineRegion.W, m_SeperatorLineRegion.H, m_SeperatorLineTexture);
            y+=m_SeperatorLineRegion.H;
         	C.SetDrawColor(255,255,255); 
        }
	}

}

function DrawItem(Canvas C, UWindowList Item, FLOAT X, FLOAT Y, FLOAT W, FLOAT H)
{
	local R6MenuLegendItem pR6MenuLegendItem;
	local R6WindowListButtonItem pListButtonItem;

	pR6MenuLegendItem = R6MenuLegendItem(Item);
	pListButtonItem	  = R6WindowListButtonItem(Item);

    // Draw Texture here
    if( pR6MenuLegendItem.m_pObjectIcon != none)
    {
        if(pR6MenuLegendItem.m_bOtherTextureHeight == TRUE)
        {
            DrawStretchedTextureSegment( C, x, y, m_iTextureSize, m_iTextureSize, 0, 0, 128, 148, R6MenuLegendItem(Item).m_pObjectIcon );
        }
        else
        {
            DrawStretchedTexture( C, x, y, m_iTextureSize, m_iTextureSize, R6MenuLegendItem(Item).m_pObjectIcon );
        }
    }

    // Set the item location, (the text)
    if(pListButtonItem.m_Button!=NONE)
    {
        pListButtonItem.m_Button.WinLeft = X + m_iTextureSize + m_iSpaceBetweenTextureNText;
        pListButtonItem.m_Button.WinTop = Y;
        pListButtonItem.m_Button.WinHeight = H;
    }
}

defaultproperties
{
     m_iTextureSize=32
     m_iSpaceBetweenTextureNText=2
     m_iSpaceEnd=12
     m_iNbButton=6
     ListClass=Class'R6Menu.R6MenuLegendItem'
}
