//=============================================================================
//  R6WindowLegend.uc : Planning phase legend window.  
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/29/04 * Created by Joel Tremblay
//=============================================================================
class R6WindowLegend extends R6MenuFramePopup;

var BOOL                        m_bDisplayWindow;
var BOOL                        m_bInitialized;
var INT                         m_iCurrentPage;
var INT                         m_NavButtonSize;
var R6MenuLegendPage            m_LegendPages[5];
var UWindowButton               m_PreviousPageButton;
var UWindowButton               m_NextPageButton;
var R6WindowBitmap              m_PrevBg;
var R6WindowBitmap              m_NextBg;
var Region                      ButtonBg;

function Created()
{
    local Texture	ButtonTexture;

    Super.Created();

    ButtonTexture	= R6WindowLookAndFeel(LookAndFeel).m_R6ScrollTexture;

    ToolTipString = Localize("PlanningLegend","MainTip","R6Menu");

    m_PreviousPageButton = R6LegendPreviousPageButton(CreateWindow(class'R6LegendPreviousPageButton', m_iFrameWidth+4, m_iFrameWidth+4, m_NavButtonSize, m_NavButtonSize, self));
    m_NextPageButton = R6LegendNextPageButton(CreateWindow(class'R6LegendNextPageButton', m_iFrameWidth+4, m_iFrameWidth+4, m_NavButtonSize, m_NavButtonSize, self));

    m_PrevBg =   R6WindowBitmap(CreateWindow(class'R6WindowBitmap',m_iFrameWidth+2, m_iFrameWidth+2, ButtonBg.W, ButtonBg.H, self));
    m_PrevBg.bAlwaysBehind        = true;
    m_PrevBg.m_bUseColor          = true;
    m_PrevBg.m_iDrawStyle         = 5;
    m_PrevBg.T                    = ButtonTexture;
    m_PrevBg.R                    = ButtonBg;
    m_PrevBg.SendToBack();
    
    m_NextBg =   R6WindowBitmap(CreateWindow(class'R6WindowBitmap',m_iFrameWidth+2, m_iFrameWidth+2, ButtonBg.W, ButtonBg.H, self));
    m_NextBg.bAlwaysBehind        = true;
    m_NextBg.m_bUseColor          = true;
    m_NextBg.m_iDrawStyle         = 5;
    m_NextBg.T                    = ButtonTexture;
    m_NextBg.R                    = ButtonBg;
    m_NextBg.SendToBack();

    //Width will be recalculated later
    m_LegendPages[0] = R6MenuLegendPageObject(CreateWindow(class'R6MenuLegendPageObject', m_iFrameWidth, m_fTitleBarHeight, 100, 100, self));
    m_LegendPages[1] = R6MenuLegendPageInteractive(CreateWindow(class'R6MenuLegendPageInteractive', m_iFrameWidth, m_fTitleBarHeight, 100, 100, self));
    m_LegendPages[1].HideWindow();
    m_LegendPages[2] = R6MenuLegendPageROE(CreateWindow(class'R6MenuLegendPageROE', m_iFrameWidth, m_fTitleBarHeight, 100, 100, self));
    m_LegendPages[2].HideWindow();
    m_LegendPages[3] = R6MenuLegendPageWPDesc(CreateWindow(class'R6MenuLegendPageWPDesc', m_iFrameWidth, m_fTitleBarHeight, 100, 100, self));
    m_LegendPages[3].HideWindow();
    m_LegendPages[4] = R6MenuLegendPageActions(CreateWindow(class'R6MenuLegendPageActions', m_iFrameWidth, m_fTitleBarHeight, 100, 100, self));
    m_LegendPages[4].HideWindow();
    m_ButtonList = m_LegendPages[0];
    m_szWindowTitle = m_LegendPages[0].m_szPageTitle;
}

//Should be before created.  Or add a function to that only once.
function BeforePaint(Canvas C, FLOAT X, FLOAT Y)
{
    local INT iTeamColor;

    if(m_bInitialized == false)
    {
        m_bInitialized = true;
        m_LegendPages[0].BeforePaint(C,X,Y);
        m_LegendPages[1].BeforePaint(C,X,Y);
        m_LegendPages[2].BeforePaint(C,X,Y);
        m_LegendPages[3].BeforePaint(C,X,Y);
        m_LegendPages[4].BeforePaint(C,X,Y);

        Resized();

		m_fTitleOffSet = (WinWidth - R6MenuLegendPage(m_ButtonList).m_fTitleWidth) * 0.5;
        m_NextBg.WinLeft = WinWidth - m_iFrameWidth - m_NavButtonSize - 2;
        m_NextPageButton.WinLeft = m_NextBg.WinLeft + 2;
    }

    iTeamColor = R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam;
    m_PrevBg.m_TextureColor = Root.Colors.TeamColor[iTeamColor];
    m_NextBg.m_TextureColor = Root.Colors.TeamColor[iTeamColor];
}

function Resized()
{
    local FLOAT fHeight, fWidth;
    local FLOAT fBiggestButtonList;

    fBiggestButtonList = m_LegendPages[0].WinWidth;
    if(fBiggestButtonList < m_LegendPages[1].WinWidth)
    {
        fBiggestButtonList = m_LegendPages[1].WinWidth;
    }
    if(fBiggestButtonList < m_LegendPages[2].WinWidth)
    {
        fBiggestButtonList = m_LegendPages[2].WinWidth;
    }
    if(fBiggestButtonList < m_LegendPages[3].WinWidth)
    {
        fBiggestButtonList = m_LegendPages[3].WinWidth;
    }
    if(fBiggestButtonList < m_LegendPages[4].WinWidth)
    {
        fBiggestButtonList = m_LegendPages[4].WinWidth;
    }

    fWidth = fBiggestButtonList + m_iFrameWidth * 2;  // *2 is for the border, left and right
    fHeight = m_ButtonList.WinHeight + m_fTitleBarHeight + m_iFrameWidth * 2; //Button lists are all the same size

    if((fWidth != WinWidth) || (fHeight != WinHeight))
    {
        m_ButtonList.WinTop = m_fTitleBarHeight;
        m_ButtonList.WinLeft = m_iFrameWidth;

        Super.Resized();

        if(m_bDisplayLeft == true)
        {
            WinLeft += (WinWidth - fWidth);
        }
        WinWidth = fWidth;

        if(m_bDisplayUp == true)
        {
            WinTop += (WinHeight - fHeight);
        }
        WinHeight = fHeight;
    }
}

function NextPage()
{
    m_iCurrentPage++;
    if(m_iCurrentPage == 5)
    {
        m_iCurrentPage = 0;
    }
    m_ButtonList.HideWindow();
    m_ButtonList = m_LegendPages[m_iCurrentPage];
    m_ButtonList.ShowWindow();
    m_szWindowTitle = m_LegendPages[m_iCurrentPage].m_szPageTitle;
	m_fTitleOffSet = (WinWidth - m_LegendPages[m_iCurrentPage].m_fTitleWidth) * 0.5;
}

function PreviousPage()
{
    m_iCurrentPage--;
    if(m_iCurrentPage < 0)
    {
        m_iCurrentPage = 4;
    }
    m_ButtonList.HideWindow();
    m_ButtonList = m_LegendPages[m_iCurrentPage];
    m_ButtonList.ShowWindow();
    m_szWindowTitle = m_LegendPages[m_iCurrentPage].m_szPageTitle;
	m_fTitleOffSet = (WinWidth - m_LegendPages[m_iCurrentPage].m_fTitleWidth) * 0.5;
}

function ToggleLegend()
{
    m_bDisplayWindow = !m_bDisplayWindow;
    if(m_bDisplayWindow == true)
    {
        ShowWindow();
    }
    else
    {
        HideWindow();
    }
}

function CloseLegendWindow()
{
    m_bDisplayWindow = false;
    HideWindow();
}

defaultproperties
{
     m_NavButtonSize=16
     ButtonBg=(X=240,Y=36,W=16,H=16)
     m_iNbButton=6
     m_bDisplayLeft=True
     m_fTitleBarHeight=22.000000
}
