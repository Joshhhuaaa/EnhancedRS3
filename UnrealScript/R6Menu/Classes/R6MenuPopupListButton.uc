class R6MenuPopupListButton extends R6WindowListRadioButton;

#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning

var R6WindowListButtonItem  m_ButtonItem[10];
var const INT m_iNbButton;
var BOOL bInitialized;

var Texture m_SeperatorLineTexture;
var Region  m_SeperatorLineRegion; 

var Font    m_FontForButtons;

//Call once
function BeforePaint(Canvas C, FLOAT MouseX, FLOAT MouseY)
{
    local INT i;
    local INT iCurrentNbButton;
    local FLOAT fWidth, fHeight, fMaxWidth, fMaxHeight;
    local bool bNeedRisize;

    if(bInitialized == false)
    {
        bInitialized = true;
        C.Font = Root.Fonts[F_Normal];
        for(i=0;i<m_iNbButton;i++)
        {
            if((m_ButtonItem[i]!=None) && (m_ButtonItem[i].m_Button!=None))
            {
                TextSize(C, m_ButtonItem[i].m_Button.Text, fWidth, fHeight);
                
                if(R6MenuPopUpStayDownButton(m_ButtonItem[i].m_Button).m_bSubMenu == true)
                {
                    fWidth += 6; // add width for the sub-menu triangle.
                }

                //Log("Got text: "$m_ButtonItem[i].m_Button.Text);
                if(fWidth > fMaxWidth)
                {
                    fMaxWidth = fWidth;
                }
                if(fHeight > fMaxHeight)
                {
                    fMaxHeight = fHeight;
                }
            }
        }
    
        WinWidth = fMaxWidth + 12;// add space between text and border (6) 
        m_fItemHeight  = fMaxHeight + 6;
        iCurrentNbButton = 0;

        for(i=0;i<m_iNbButton;i++)
        {
            if((m_ButtonItem[i]!=None) && (m_ButtonItem[i].m_Button!=None))
            {
                m_ButtonItem[i].m_Button.WinWidth  = WinWidth;
                m_ButtonItem[i].m_Button.WinHeight = m_fItemHeight;
                iCurrentNbButton++;
            }
        }
    
        WinHeight = m_fItemHeight*iCurrentNbButton + (iCurrentNbButton-1);
        ParentWindow.Resized();
    }
    
    //Super.BeforePaint(C,MouseX,MouseY);
}

function Paint(Canvas C, FLOAT MouseX, FLOAT MouseY)
{
	local FLOAT x;
    local FLOAT y;
	local UWindowList CurItem;
	local Color lcolor;

    lcolor = Root.Colors.TeamColor[R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam];
	C.SetDrawColor(lcolor.R,lcolor.G,lcolor.B,Root.Colors.PopUpAlphaFactor); 

    if(m_fItemWidth==0)
        m_fItemWidth = WinWidth;

    x = (WinWidth-m_fItemWidth)/2;
    for(CurItem = Items.Next; CurItem != None; CurItem = CurItem.Next)
	{
        R6WindowListButtonItem(CurItem).m_Button.ShowWindow();
        DrawItem(C, CurItem, x, y, m_fItemWidth, m_fItemHeight);
        y += m_fItemHeight;
        if(y < WinHeight)
        {
            // Draw line between button
            C.Style=GetPlayerOwner().ERenderStyle.STY_Alpha;
            DrawStretchedTextureSegment(C, x, y, m_SeperatorLineRegion.W, m_SeperatorLineRegion.H, m_SeperatorLineRegion.X, m_SeperatorLineRegion.Y, m_SeperatorLineRegion.W, m_SeperatorLineRegion.H, m_SeperatorLineTexture);
            C.Style=GetPlayerOwner().ERenderStyle.STY_Normal;
            y+=m_SeperatorLineRegion.H;
        }
        if(y >= WinHeight)
        {
            // switch column
            y = 0;
            x += WinWidth;
        }
	}
	C.SetDrawColor(255,255,255); 
}

function DrawItem(Canvas C, UWindowList Item, FLOAT X, FLOAT Y, FLOAT W, FLOAT H)
{
	local R6WindowListButtonItem pListButtonItem;

	pListButtonItem = R6WindowListButtonItem(Item);

    // Set the item location
    if(pListButtonItem.m_Button!=NONE)
    {
        pListButtonItem.m_Button.WinLeft = X;
        pListButtonItem.m_Button.WinTop = Y;
        pListButtonItem.m_Button.WinHeight = H;
    }
}

function ChangeItemsSize(FLOAT fNewWidth)
{
    local INT i;

    for(i=0;i<m_iNbButton;i++)
    {
        if((m_ButtonItem[i]!=None) && (m_ButtonItem[i].m_Button!=None))
        {
            m_ButtonItem[i].m_Button.WinWidth = fNewWidth;
        }
    }
}

defaultproperties
{
     m_SeperatorLineTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     m_SeperatorLineRegion=(X=80,Y=62,W=36,H=1)
}
