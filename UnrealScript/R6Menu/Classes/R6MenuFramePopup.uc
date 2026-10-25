class R6MenuFramePopup extends R6WindowFramedWindow;

var R6WindowListRadioButton m_ButtonList;
var const INT               m_iNbButton;
var INT                     m_iTeamColor;
var INT                     m_iFrameWidth;     //default width and height for popups windows
var FLOAT                   m_fTitleBarHeight;
var FLOAT                   m_fTitleBarWidth;
var BOOL                    m_bDisplayUp;
var BOOL                    m_bDisplayLeft;
var INT                     m_iTextureSize;
var Texture                 m_Texture;
var BOOL                    m_bInitialized;


//Should be before created.  Or add a function to that only once.
function BeforePaint(Canvas C, FLOAT X, FLOAT Y)
{
    if(m_bInitialized == false)
    {
        m_bInitialized = true;
        Super.BeforePaint(C,X,Y);
        C.Font = Root.Fonts[F_PopUpTitle];
        TextSize(C,m_szWindowTitle,m_fTitleBarWidth,m_fTitleBarHeight);
        m_fTitleBarHeight+=6.0;
        m_fTitleBarWidth+=12.0;  // (2 x FrameTitleX) = 12
    }
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
	local Region R, Temp;
	local color iColor;
    
    m_iTeamColor = R6PlanningCtrl(GetPlayerOwner()).m_iCurrentTeam;

    if(m_szWindowTitle != "")
    {
        // title bar
        iColor = Root.Colors.TeamColor[m_iTeamColor];
        C.Style=5;//ERenderStyle.STY_Alpha
		C.SetDrawColor(iColor.R,iColor.G,iColor.B, Root.Colors.PopUpAlphaFactor);
        DrawStretchedTextureSegment( C, 
                                m_iTextureSize, m_iTextureSize, WinWidth - m_iTextureSize - m_iTextureSize, m_fTitleBarHeight - m_iTextureSize,
                                0, 0, m_iTextureSize, m_iTextureSize,
                                m_Texture );

        // background area
        C.Style=5;//ERenderStyle.STY_Alpha
        iColor = Root.Colors.TeamColorDark[m_iTeamColor];
		C.SetDrawColor(iColor.R,iColor.G,iColor.B, Root.Colors.PopUpAlphaFactor);
        DrawStretchedTextureSegment( C, m_iTextureSize, m_fTitleBarHeight, WinWidth - m_iTextureSize - m_iTextureSize, WinHeight - m_fTitleBarHeight - m_iTextureSize, 
                                       0, 0, m_iTextureSize, m_iTextureSize, 
                                       m_Texture );
    }
    else
    {
    
        // background area
        C.Style=5;//ERenderStyle.STY_Alpha
        iColor = Root.Colors.TeamColorDark[m_iTeamColor];
		C.SetDrawColor(iColor.R,iColor.G,iColor.B, Root.Colors.PopUpAlphaFactor);
        DrawStretchedTextureSegment( C, m_iTextureSize, m_iTextureSize, WinWidth - m_iTextureSize - m_iTextureSize, WinHeight - m_iTextureSize - m_iTextureSize, 
                                       0, 0, m_iTextureSize, m_iTextureSize,
                                       m_Texture );
    }

    iColor = Root.Colors.TeamColor[m_iTeamColor];
    C.SetDrawColor(iColor.R,iColor.G,iColor.B);

    //Top Segment
	DrawStretchedTextureSegment( C, 0, 0, WinWidth, m_iTextureSize, 0, 0, m_iTextureSize, m_iTextureSize, m_Texture );

    //Bottom header
    if(m_szWindowTitle != "")
    {
    	DrawStretchedTextureSegment( C, 0, m_fTitleBarHeight-1, WinWidth, m_iTextureSize, 0, 0, m_iTextureSize, m_iTextureSize, m_Texture );
    }

    //Left
    DrawStretchedTextureSegment( C, 0, m_iTextureSize, m_iTextureSize, WinHeight - m_iTextureSize - m_iTextureSize,
									0, 0, m_iTextureSize, m_iTextureSize, m_Texture );

    //Right
	DrawStretchedTextureSegment( C, WinWidth - m_iTextureSize , m_iTextureSize, m_iTextureSize, WinHeight - m_iTextureSize - m_iTextureSize,
									0, 0, m_iTextureSize, m_iTextureSize, m_Texture );

    //Bottom
	DrawStretchedTextureSegment( C, 0, WinHeight - m_iTextureSize, WinWidth, m_iTextureSize, 
                                    0, 0, m_iTextureSize, m_iTextureSize, m_Texture );

    // Window title text
    C.Style=5;//ERenderStyle.STY_Alpha
    C.Font = Root.Fonts[F_PopUpTitle];
    iColor = Root.Colors.White;
	C.SetDrawColor(iColor.R,iColor.G,iColor.B);

	ClipTextWidth(C, m_fTitleOffSet, 3, 
					m_szWindowTitle, WinWidth);

}

function Resized()
{
    local FLOAT fHeight, fWidth;

    if(m_fTitleBarWidth > m_ButtonList.WinWidth)
    {
        fWidth = m_fTitleBarWidth + m_iFrameWidth * 2;  // *2 is for the border, left and right
        m_ButtonList.WinWidth = m_fTitleBarWidth;
        m_ButtonList.ChangeItemsSize(m_fTitleBarWidth);
    }
    else
    {
        fWidth = m_ButtonList.WinWidth + m_iFrameWidth * 2;  // *2 is for the border, left and right
    }
    fHeight = m_ButtonList.WinHeight + m_fTitleBarHeight + m_iFrameWidth;

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
        m_fTitleOffSet = (WinWidth - m_fTitleBarWidth) / 2 + 6;

        if(m_bDisplayUp == true)
        {
            WinTop += (WinHeight - fHeight);
        }
        WinHeight = fHeight;
    }
}

function ShowWindow()
{
    Super.ShowWindow();
    m_ButtonList.ShowWindow();
}

function AjustPosition(BOOL bDisplayUp, BOOL bDisplayLeft)
{
    m_bDisplayUp = bDisplayUp;
    m_bDisplayLeft = bDisplayLeft;
    
    if(m_bDisplayLeft == TRUE)
    {
        WinLeft -= WinWidth;
    }
    if(m_bDisplayUp == TRUE)
    {
        WinTop -= WinHeight;
    }
}

defaultproperties
{
     m_iFrameWidth=1
     m_iTextureSize=1
     m_fTitleBarHeight=17.000000
     m_Texture=Texture'Color.Color.White'
     m_TitleAlign=TA_Center
     m_bDisplayClose=False
}
