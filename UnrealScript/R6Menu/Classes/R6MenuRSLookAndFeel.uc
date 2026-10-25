//=============================================================================
//  R6MenuRSLookAndFeel.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6MenuRSLookAndFeel extends R6WindowLookAndFeel;

enum ERSBLButton
{
    ERSBL_BLActive,
    ERSBL_BLLeft,
    ERSBL_BLRight
};

enum ENavBarButton
{
    NBB_Home,
    NBB_Option,
    NBB_Archive,
    NBB_TeleCom,
    NBB_Roster,
    NBB_Gear,
    NBB_Planning,
    NBB_Play,
    NBB_Load,
    NBB_Save
};

// enum for accept and cancel sign button
enum eSignChoiceButton
{
    eSCB_Accept,
    eSCB_Cancel
};


struct STWindowFrame
{
    var Region	TL;
    var Region	T;
    var Region	TR;
    var Region	L;
    var Region	R;
    var Region	BL;
    var Region	B;
    var Region	BR;
};

struct STFrameColor
{
    var Color TextColor;
    var Color SelTextColor;
    var Color DisableColor;
    var Color TitleColor;
    var Color TitleBack;
    var Color ButtonBack;
    var Color SelButtonBack;
    var Color ButtonLine;
};

struct STLapTopFrame// extends STWindowFrame
{
    var Region TL;
    var Region T;
    var Region TR;
    var Region L;
    var Region R;
    var Region BL;
    var Region B;
    var Region BR;
    var Region L2;
    var Region R2;
	var Region L3;
    var Region R3;
	var Region L4;
	var Region R4;
	
};

struct STLapTopFramePlus// addon to LaptopFrame
{
	var Region T1;
	var Region T2;
    var Region T3;
    var Region T4On;    
	var Region T4Off;    
};

var Region	            m_FrameSBL;
var Region	            m_FrameSB;
var Region	            m_FrameSBR;

// ****** R6 Add-On ******

var RegionButton        m_BLTitleL;
var RegionButton        m_BLTitleC;
var RegionButton        m_BLTitleR;


//***********************************
//        + MacArthur Menu +
//***********************************

// Menu Texture
var Texture             m_NavBarTex;

// Popup ActionPoint menu
var Region              m_PopupArrowUp;
var Region              m_PopupArrowDown;

//-----------------------------------------------
// Laptop frame
var STLapTopFrame       m_stLapTopFrame;
var STLapTopFramePlus   m_stLapTopFramePlus;
//-----------------------------------------------
// Navigation Bar
var Region              m_NavBarBack[12];

//-----------------------------------------------
//R6WindowButtonMainMenu
var float               m_fCurrentPct, m_fScrollRate;
var int                 m_iMultiplyer;

//-----------------------------------------------
//ListBox
var Region              m_topLeftCornerR;

//-----------------------------------------------
// Simple Pop-up Window (ex. JoinIp window with an edit box)
var RegionButton        m_RBAcceptCancel[2];            // accept button, cancel button 

//-----------------------------------------------
// In-Game Menu
var Texture             m_TIcon;
var FLOAT               m_fTextHeaderHeight;            // the in-game menu intermission text header

//-----------------------------------------------
// Create game menu
var RegionButton        m_RArrow[2];                    // the region of the arrow button for map list

//-----------------------------------------------

const SIZEBORDER = 3;       // only used by HitTest
const BRSIZEBORDER = 15;    // only used by HitTest

const RadioButtonHeight		= 17;
const RadioButtonWidth		= 16;

//-----------------------------------------------
//Scroll Bar
var INT                     m_fVSBButtonImageX, m_fHSBButtonImageX;
var INT                     m_fVSBButtonImageY, m_fHSBButtonImageY;
var Region                  m_SBScrollerActive;
var Region                  m_SBUpGear;
var Region                  m_SBDownGear;

//-----------------------------------------------
//Combo
var INT                     m_fComboImageX, m_fComboImageY;


//-----------------------------------------------
//Square Border
var Region              m_RSquareBgLeft;
var Region              m_RSquareBgMid;
var Region              m_RSquareBgRight;
var Texture             m_TSquareBg;

function Setup()
{
    Super.Setup();

    // setup texture reference    
    m_NavBarTex     = Texture(DynamicLoadObject("R6MenuTextures.GUI_01", class'Texture'));
    
	m_R6ScrollTexture   = Texture(DynamicLoadObject("R6MenuTextures.Gui_BoxScroll", class'Texture'));
    
    m_TIcon = Texture(DynamicLoadObject("R6MenuTextures.TeamBarIcon", class'Texture'));
}

//===================================================================
// Set the region for the accept and cancel(X) button
//===================================================================
function Button_SetupEnumSignChoice(UWindowButton W, INT eRegionId)
{
	W.bUseRegion = true;

	W.UpTexture       = m_R6ScrollTexture;
	W.DownTexture     = m_R6ScrollTexture;
	W.OverTexture     = m_R6ScrollTexture;
	W.DisabledTexture = m_R6ScrollTexture;

    W.UpRegion        = m_RBAcceptCancel[eRegionId].Up;
    W.DownRegion      = m_RBAcceptCancel[eRegionId].Down;
    W.OverRegion      = m_RBAcceptCancel[eRegionId].Over;
    W.DisabledRegion  = m_RBAcceptCancel[eRegionId].Disabled;
}

function Button_SetupMapList(UWindowButton W, bool _bInverseTex)
{
    local RegionButton RTemp;
	W.bUseRegion = true;

	W.UpTexture       = m_R6ScrollTexture;
	W.DownTexture     = m_R6ScrollTexture;
	W.OverTexture     = m_R6ScrollTexture;
	W.DisabledTexture = m_R6ScrollTexture;

    if (_bInverseTex)
    {
        W.RegionScale     = -1; // why -1 because the width of the region to display the button become < 0 when is displaying
        W.UpRegion        = m_RArrow[1].Up;
        W.DownRegion      = m_RArrow[1].Down;
        W.OverRegion      = m_RArrow[1].Over;
        W.DisabledRegion  = m_RArrow[1].Disabled;
    }
    else
    {
        W.RegionScale     = 1;
        W.UpRegion        = m_RArrow[0].Up;
        W.DownRegion      = m_RArrow[0].Down;
        W.OverRegion      = m_RArrow[0].Over;
        W.DisabledRegion  = m_RArrow[0].Disabled;
    }
}

// ****** Framed Window Drawing Functions ******

/* Rainbow Six version */
function Texture R6GetTexture(R6WindowFramedWindow W)
{
	if(W.IsActive())
		return Active;
	else
		return Inactive;
}

function FW_DrawWindowFrame(UWindowFramedWindow W, Canvas C)
{
	local Texture T;
	local Region R, Temp;

	C.SetDrawColor(255,255,255); 	

	T = W.GetLookAndFeelTexture();

	R = FrameTL;
	W.DrawStretchedTextureSegment( C, 0, 0, R.W, R.H, R.X, R.Y, R.W, R.H, T );

	R = FrameT;
	W.DrawStretchedTextureSegment( C, FrameTL.W, 0, 
									W.WinWidth - FrameTL.W
									- FrameTR.W,
									R.H, R.X, R.Y, R.W, R.H, T );

	R = FrameTR;
	W.DrawStretchedTextureSegment( C, W.WinWidth - R.W, 0, R.W, R.H, R.X, R.Y, R.W, R.H, T );
	

	if(W.bStatusBar)
    {
		Temp = m_FrameSBL;
    }
	else
    {
		Temp = FrameBL;
    }
	
	R = FrameL;
	W.DrawStretchedTextureSegment( C, 0, FrameTL.H,
									R.W,  
									W.WinHeight - FrameTL.H
									- Temp.H,
									R.X, R.Y, R.W, R.H, T );

	R = FrameR;
	W.DrawStretchedTextureSegment( C, W.WinWidth - R.W, FrameTL.H,
									R.W,  
									W.WinHeight - FrameTL.H
									- Temp.H,
									R.X, R.Y, R.W, R.H, T );

	if(W.bStatusBar)
    {
		R = m_FrameSBL;
    }
	else
    {
		R = FrameBL;
    }
	W.DrawStretchedTextureSegment( C, 0, W.WinHeight - R.H, R.W, R.H, R.X, R.Y, R.W, R.H, T );

	if(W.bStatusBar)
	{
		R = m_FrameSB;
		W.DrawStretchedTextureSegment( C, FrameBL.W, W.WinHeight - R.H, 
										W.WinWidth - m_FrameSBL.W
										- m_FrameSBR.W,
										R.H, R.X, R.Y, R.W, R.H, T );
	}
	else
	{
		R = FrameB;
		W.DrawStretchedTextureSegment( C, FrameBL.W, W.WinHeight - R.H, 
										W.WinWidth - FrameBL.W
										- FrameBR.W,
										R.H, R.X, R.Y, R.W, R.H, T );
	}

	if(W.bStatusBar)
    {
		R = m_FrameSBR;
    }
	else
    {
		R = FrameBR;
    }
	W.DrawStretchedTextureSegment( C, W.WinWidth - R.W, W.WinHeight - R.H, R.W, R.H, R.X, R.Y, 
									R.W, R.H, T );


	C.Font = W.Root.Fonts[W.F_Normal];
	if(W.ParentWindow.ActiveWindow == W)
    {		
		C.SetDrawColor(FrameActiveTitleColor.R,FrameActiveTitleColor.G,FrameActiveTitleColor.B); 	
    }
	else
    {		
		C.SetDrawColor(FrameInactiveTitleColor.R,FrameInactiveTitleColor.G,FrameInactiveTitleColor.B); 	
    }


	W.ClipTextWidth(C, FrameTitleX, FrameTitleY, 
					W.WindowTitle, W.WinWidth);

	if(W.bStatusBar) 
	{
		C.SetDrawColor(0,0,0); 			

		W.ClipTextWidth(C, 6, W.WinHeight - 13, W.StatusBarText, W.WinWidth);

		C.SetDrawColor(255,255,255); 	

	}
}

/* Rainbow Six version */
function R6FW_DrawWindowFrame(R6WindowFramedWindow W, Canvas C)
{
	local Texture T;
	local Region R;

	C.SetDrawColor(255,255,255); 	

	T = W.GetLookAndFeelTexture();

	R = FrameTL;
	W.DrawStretchedTextureSegment( C, 0, 0, R.W, R.H, R.X, R.Y, R.W, R.H, T );

	R = FrameT;
	W.DrawStretchedTextureSegment( C, FrameTL.W, 0, 
									W.WinWidth - FrameTL.W
									- FrameTR.W,
									R.H, R.X, R.Y, R.W, R.H, T );

	R = FrameTR;
	W.DrawStretchedTextureSegment( C, W.WinWidth - R.W, 0, R.W, R.H, R.X, R.Y, R.W, R.H, T );
	
	R = FrameL;
	W.DrawStretchedTextureSegment( C, 0, FrameTL.H,
									R.W,  
									W.WinHeight - FrameTL.H
									- FrameBL.H,
									R.X, R.Y, R.W, R.H, T );

	R = FrameR;
	W.DrawStretchedTextureSegment( C, W.WinWidth - R.W, FrameTL.H,
									R.W,  
									W.WinHeight - FrameTL.H
									- FrameBL.H,
									R.X, R.Y, R.W, R.H, T );

	R = FrameBL;
	W.DrawStretchedTextureSegment( C, 0, W.WinHeight - R.H, R.W, R.H, R.X, R.Y, R.W, R.H, T );

	R = FrameB;
	W.DrawStretchedTextureSegment( C, FrameBL.W, W.WinHeight - R.H, 
									W.WinWidth - FrameBL.W
									- FrameBR.W,
									R.H, R.X, R.Y, R.W, R.H, T );

	R = FrameBR;
	W.DrawStretchedTextureSegment( C, W.WinWidth - R.W, W.WinHeight - R.H, R.W, R.H, R.X, R.Y, 
									R.W, R.H, T );


	C.Font = W.Root.Fonts[W.F_Normal];
	if(W.ParentWindow.ActiveWindow == W)
    {		
		C.SetDrawColor(FrameActiveTitleColor.R,FrameActiveTitleColor.G,FrameActiveTitleColor.B); 	
    }
	else
    {		
		C.SetDrawColor(FrameInactiveTitleColor.R,FrameInactiveTitleColor.G,FrameInactiveTitleColor.B); 	
    }


	W.ClipTextWidth(C, W.m_fTitleOffSet, FrameTitleY, 
					W.m_szWindowTitle, W.WinWidth);
}


//======================================================================================
// Draw the pop-up frame
// IMPORTANT: the parameters for the window are set in R6WindowPopUpBox
//======================================================================================
function DrawPopUpFrameWindow( R6WindowPopUpBox W, Canvas C)
{
 	local Texture TBackGround;
    local Color vBorderColor, vCornerColor;

    TBackGround = Texture'UWindow.WhiteTexture';

    C.Style = ERenderStyle.STY_Alpha;

    // draw a gray background over all the window to hide (transparence) the map IN GAME MENU
    if (W.m_bBGFullScreen)
    {        
		W.Root.DrawBackGroundEffect( C, W.m_vFullBGColor);
    }
    
    if (W.m_bBGClientArea)
    {
        C.SetDrawColor( W.m_vClientAreaColor.R, W.m_vClientAreaColor.G, W.m_vClientAreaColor.B, W.m_vClientAreaColor.A);
        // the additionnal offset is for border size.
        W.DrawStretchedTextureSegment( C, W.m_RWindowBorder.X + 2, W.m_pTextLabel.WinTop + 1, 
                                          W.m_RWindowBorder.W - 4, W.m_pTextLabel.WinHeight + W.m_RWindowBorder.H - 2, 
                                          0, 0, 10, 10, TBackGround );
    }

    if (!W.m_bNoBorderToDraw)
    {
        
        // TOP BORDER
        if (W.m_sBorderForm[W.eBorderType.Border_Top].bActive)
        {
            if (W.m_sBorderForm[W.eBorderType.Border_Top].vColor != vBorderColor)
            {
                vBorderColor = W.m_sBorderForm[W.eBorderType.Border_Top].vColor;
                C.SetDrawColor(vBorderColor.R, vBorderColor.G, vBorderColor.B);
            }
            
            W.DrawStretchedTextureSegment( C, W.m_sBorderForm[W.eBorderType.Border_Top].fXPos, 
                W.m_sBorderForm[W.eBorderType.Border_Top].fYPos, 
                W.m_sBorderForm[W.eBorderType.Border_Top].fWidth, 
                W.m_sBorderForm[W.eBorderType.Border_Top].fHeight, 
                W.m_HBorderTextureRegion.X, W.m_HBorderTextureRegion.Y, W.m_HBorderTextureRegion.W, W.m_HBorderTextureRegion.H, W.m_HBorderTexture );
        }
        
        // BOTTOM BORDER
        if (W.m_sBorderForm[W.eBorderType.Border_Bottom].bActive)
        {
            if (W.m_sBorderForm[W.eBorderType.Border_Bottom].vColor != vBorderColor)
            {
                vBorderColor = W.m_sBorderForm[W.eBorderType.Border_Bottom].vColor;
                C.SetDrawColor(vBorderColor.R, vBorderColor.G, vBorderColor.B);
            }
            
            W.DrawStretchedTextureSegment( C, W.m_sBorderForm[W.eBorderType.Border_Bottom].fXPos, 
                W.m_sBorderForm[W.eBorderType.Border_Bottom].fYPos, 
                W.m_sBorderForm[W.eBorderType.Border_Bottom].fWidth, 
                W.m_sBorderForm[W.eBorderType.Border_Bottom].fHeight, 
                W.m_HBorderTextureRegion.X, W.m_HBorderTextureRegion.Y, W.m_HBorderTextureRegion.W, W.m_HBorderTextureRegion.H, W.m_HBorderTexture );
        }
        
        // LEFT BORDER
        if (W.m_sBorderForm[W.eBorderType.Border_Left].bActive)
        {
            if (W.m_sBorderForm[W.eBorderType.Border_Left].vColor != vBorderColor)
            {
                vBorderColor = W.m_sBorderForm[W.eBorderType.Border_Left].vColor;
                C.SetDrawColor(vBorderColor.R, vBorderColor.G, vBorderColor.B);
            }
            
            W.DrawStretchedTextureSegment( C, W.m_sBorderForm[W.eBorderType.Border_Left].fXPos, 
                W.m_sBorderForm[W.eBorderType.Border_Left].fYPos, 
                W.m_sBorderForm[W.eBorderType.Border_Left].fWidth, 
                W.m_sBorderForm[W.eBorderType.Border_Left].fHeight, 
                W.m_VBorderTextureRegion.X, W.m_VBorderTextureRegion.Y, W.m_VBorderTextureRegion.W, W.m_VBorderTextureRegion.H, W.m_VBorderTexture );
        }
        
        // RIGHT BORDER
        if (W.m_sBorderForm[W.eBorderType.Border_Right].bActive)
        {
            if (W.m_sBorderForm[W.eBorderType.Border_Right].vColor != vBorderColor)
            {
                vBorderColor = W.m_sBorderForm[W.eBorderType.Border_Right].vColor;
                C.SetDrawColor(vBorderColor.R, vBorderColor.G, vBorderColor.B);
            }
            
            W.DrawStretchedTextureSegment( C, W.m_sBorderForm[W.eBorderType.Border_Right].fXPos, 
                W.m_sBorderForm[W.eBorderType.Border_Right].fYPos, 
                W.m_sBorderForm[W.eBorderType.Border_Right].fWidth, 
                W.m_sBorderForm[W.eBorderType.Border_Right].fHeight, 
                W.m_VBorderTextureRegion.X, W.m_VBorderTextureRegion.Y, W.m_VBorderTextureRegion.W, W.m_VBorderTextureRegion.H, W.m_VBorderTexture );
        }
    }
    
    vCornerColor.R =0;
    vCornerColor.G =0;
    vCornerColor.B =0;
    // set the corner the same color than the border ???
    if (W.m_eCornerType != No_Corners)
    {
	    switch(W.m_eCornerType)
	    {
            case All_Corners:
                if (W.m_eCornerColor[W.eCornerType.All_Corners] != vCornerColor)
                {
                    vCornerColor = W.m_eCornerColor[W.eCornerType.All_Corners];
                    C.SetDrawColor(vCornerColor.R, vCornerColor.G, vCornerColor.B);
                }
		    case Top_Corners:
			    //Corners
                if (W.m_eCornerColor[W.eCornerType.Top_Corners] != vCornerColor)
                {
                    vCornerColor = W.m_eCornerColor[W.eCornerType.Top_Corners];
                    C.SetDrawColor(vCornerColor.R, vCornerColor.G, vCornerColor.B);
                }

			    if(W.m_topLeftCornerT != None)
			    {
				    W.DrawStretchedTextureSegment(C, W.m_RWindowBorder.X,
                                                     W.m_RWindowBorder.Y, 
                                                     W.m_topLeftCornerR.W, W.m_topLeftCornerR.H, 
                                                     W.m_topLeftCornerR.X, W.m_topLeftCornerR.Y, W.m_topLeftCornerR.W, W.m_topLeftCornerR.H, W.m_topLeftCornerT);		
				    W.DrawStretchedTextureSegment(C, W.m_RWindowBorder.X + W.m_RWindowBorder.W - m_topLeftCornerR.W, 
                                                     W.m_RWindowBorder.Y, 
                                                     W.m_topLeftCornerR.W, W.m_topLeftCornerR.H, 
                                                     W.m_topLeftCornerR.X + W.m_topLeftCornerR.W, W.m_topLeftCornerR.Y, - W.m_topLeftCornerR.W, W.m_topLeftCornerR.H, W.m_topLeftCornerT);
			    }

                if (W.m_eCornerType!=All_Corners) break;
		    case Bottom_Corners:
			    //Corners
                if (W.m_eCornerColor[W.eCornerType.Bottom_Corners] != vCornerColor)
                {
                    vCornerColor = W.m_eCornerColor[W.eCornerType.Bottom_Corners];
                    C.SetDrawColor(vCornerColor.R, vCornerColor.G, vCornerColor.B);
                }

			    if(W.m_topLeftCornerT != None)
			    {
				    W.DrawStretchedTextureSegment(C, W.m_RWindowBorder.X,
                                                     W.m_RWindowBorder.Y + W.m_RWindowBorder.H -  m_topLeftCornerR.H, 
                                                     W.m_topLeftCornerR.W, W.m_topLeftCornerR.H, W.m_topLeftCornerR.X, 
  											         W.m_topLeftCornerR.Y + W.m_topLeftCornerR.H, W.m_topLeftCornerR.W, -W.m_topLeftCornerR.H, W.m_topLeftCornerT);		
				    W.DrawStretchedTextureSegment(C, W.m_RWindowBorder.X + W.m_RWindowBorder.W - W.m_topLeftCornerR.W, 
                                                     W.m_RWindowBorder.Y + W.m_RWindowBorder.H -  W.m_topLeftCornerR.H, 
                                                     W.m_topLeftCornerR.W, W.m_topLeftCornerR.H, 
                                                     W.m_topLeftCornerR.X + W.m_topLeftCornerR.W, W.m_topLeftCornerR.Y + W.m_topLeftCornerR.H, -W.m_topLeftCornerR.W, -W.m_topLeftCornerR.H, W.m_topLeftCornerT);
			    }
			    break;
            default:
                break;
	    }
    }
}


function FW_SetupFrameButtons(UWindowFramedWindow W, Canvas C)
{
	local Texture T;

	T = W.GetLookAndFeelTexture();

	W.CloseBox.WinLeft = W.WinWidth - m_iCloseBoxOffsetX - m_CloseBoxUp.W;
	W.CloseBox.WinTop = m_iCloseBoxOffsetY;

	W.CloseBox.SetSize(m_CloseBoxUp.W, m_CloseBoxUp.H);
	W.CloseBox.bUseRegion = True;

	W.CloseBox.UpTexture = T;
	W.CloseBox.DownTexture = T;
	W.CloseBox.OverTexture = T;
	W.CloseBox.DisabledTexture = T;

	W.CloseBox.UpRegion = m_CloseBoxUp;
	W.CloseBox.DownRegion = m_CloseBoxDown;
	W.CloseBox.OverRegion = m_CloseBoxUp;
	W.CloseBox.DisabledRegion = m_CloseBoxUp;
}

/* Rainbow Six version */
function R6FW_SetupFrameButtons(R6WindowFramedWindow W, Canvas C)
{
	local Texture T;

	T = W.GetLookAndFeelTexture();

	W.m_CloseBoxButton.SetSize(m_CloseBoxUp.W, m_CloseBoxUp.H);
	W.m_CloseBoxButton.bUseRegion = True;

	W.m_CloseBoxButton.UpTexture = T;
	W.m_CloseBoxButton.DownTexture = T;
	W.m_CloseBoxButton.OverTexture = T;
	W.m_CloseBoxButton.DisabledTexture = T;

	W.m_CloseBoxButton.UpRegion = m_CloseBoxUp;
	W.m_CloseBoxButton.DownRegion = m_CloseBoxDown;
	W.m_CloseBoxButton.OverRegion = m_CloseBoxUp;
	W.m_CloseBoxButton.DisabledRegion = m_CloseBoxUp;
}

function Region FW_GetClientArea(UWindowFramedWindow W)
{
	local Region R;

	R.X = FrameL.W;
	R.Y	= FrameT.H;
	R.W = W.WinWidth - (FrameL.W + FrameR.W);
	if(W.bStatusBar) 
    {
		R.H = W.WinHeight - (FrameT.H + m_FrameSB.H);
    }
	else
    {
		R.H = W.WinHeight - (FrameT.H + FrameB.H);
    }

	return R;
}

/* Rainbow Six version */
function Region R6FW_GetClientArea(R6WindowFramedWindow W)
{
	local Region R;

	R.X = FrameL.W;
	R.Y	= FrameT.H;
	R.W = W.WinWidth - (FrameL.W + FrameR.W);
	R.H = W.WinHeight - (FrameT.H + FrameB.H);

	return R;
}


function FrameHitTest FW_HitTest(UWindowFramedWindow W, FLOAT X, FLOAT Y)
{
	if((X >= 3) && (X <= W.WinWidth-3) && (Y >= 3) && (Y <= 14))
		return HT_TitleBar;
	if((X < BRSIZEBORDER && Y < SIZEBORDER) || (X < SIZEBORDER && Y < BRSIZEBORDER)) 
		return HT_NW;
	if((X > W.WinWidth - SIZEBORDER && Y < BRSIZEBORDER) || (X > W.WinWidth - BRSIZEBORDER && Y < SIZEBORDER))
		return HT_NE;
	if((X < BRSIZEBORDER && Y > W.WinHeight - SIZEBORDER)|| (X < SIZEBORDER && Y > W.WinHeight - BRSIZEBORDER)) 
		return HT_SW;
	if((X > W.WinWidth - BRSIZEBORDER) && (Y > W.WinHeight - BRSIZEBORDER))
		return HT_SE;
	if(Y < SIZEBORDER)
		return HT_N;
	if(Y > W.WinHeight - SIZEBORDER)
		return HT_S;
	if(X < SIZEBORDER)
		return HT_W;
	if(X > W.WinWidth - SIZEBORDER)	
		return HT_E;

	return HT_None;	
}

/* Rainbow Six version */
function FrameHitTest R6FW_HitTest(R6WindowFramedWindow W, FLOAT X, FLOAT Y)
{
	if((X >= 3) && (X <= W.WinWidth-3) && (Y >= 3) && (Y <= 14))
		return HT_TitleBar;
	if((X < BRSIZEBORDER && Y < SIZEBORDER) || (X < SIZEBORDER && Y < BRSIZEBORDER)) 
		return HT_NW;
	if((X > W.WinWidth - SIZEBORDER && Y < BRSIZEBORDER) || (X > W.WinWidth - BRSIZEBORDER && Y < SIZEBORDER))
		return HT_NE;
	if((X < BRSIZEBORDER && Y > W.WinHeight - SIZEBORDER)|| (X < SIZEBORDER && Y > W.WinHeight - BRSIZEBORDER)) 
		return HT_SW;
	if((X > W.WinWidth - BRSIZEBORDER) && (Y > W.WinHeight - BRSIZEBORDER))
		return HT_SE;
	if(Y < SIZEBORDER)
		return HT_N;
	if(Y > W.WinHeight - SIZEBORDER)
		return HT_S;
	if(X < SIZEBORDER)
		return HT_W;
	if(X > W.WinWidth - SIZEBORDER)	
		return HT_E;

	return HT_None;	
}

// ****** Client Area Drawing Functions *******
function DrawClientArea(UWindowClientWindow W, Canvas C)
{
	W.DrawStretchedTexture(C, 0, 0, W.WinWidth, W.WinHeight, Texture'BlackTexture');
}


// ****** Combo Drawing Functions ******
function Combo_SetupSizes(UWindowComboControl W, Canvas C)
{
	local FLOAT fTW, fTH;

	C.Font = W.Root.Fonts[W.Font];
	W.TextSize(C, W.Text, fTW, fTH);
	
//	W.WinHeight = 12 + MiscBevelT[2].H + MiscBevelB[2].H;
	
	switch(W.Align)
	{
	case TA_Left:
		W.EditAreaDrawX = W.WinWidth - W.EditBoxWidth;
		W.TextX = 0;
		break;
	case TA_Right:
		W.EditAreaDrawX = 0;	
		W.TextX = W.WinWidth - fTW;
		break;
	case TA_Center:
		W.EditAreaDrawX = (W.WinWidth - W.EditBoxWidth) / 2;
		W.TextX = (W.WinWidth - fTW) / 2;
		break;
	}

	W.EditAreaDrawY = (W.WinHeight - 2) / 2;
	W.TextY = (W.WinHeight - fTH) / 2;

	W.EditBox.WinLeft = W.EditAreaDrawX + MiscBevelL[2].W;
	W.EditBox.WinTop = MiscBevelT[2].H;
	W.Button.WinWidth = ComboBtnUp.W;

	if(W.bButtons)
	{
		W.EditBox.WinWidth = W.EditBoxWidth - MiscBevelL[2].W - MiscBevelR[2].W - ComboBtnUp.W - m_SBLeft.Up.W - m_SBRight.Up.W;
		W.EditBox.WinHeight = W.WinHeight - MiscBevelT[2].H - MiscBevelB[2].H;
		W.Button.WinLeft = W.WinWidth - ComboBtnUp.W - MiscBevelR[2].W - m_SBLeft.Up.W - m_SBRight.Up.W;
		W.Button.WinTop = W.EditBox.WinTop;

		W.LeftButton.WinLeft = W.WinWidth - MiscBevelR[2].W - m_SBLeft.Up.W - m_SBRight.Up.W;
		W.LeftButton.WinTop = W.EditBox.WinTop;
		W.RightButton.WinLeft = W.WinWidth - MiscBevelR[2].W - m_SBRight.Up.W;
		W.RightButton.WinTop = W.EditBox.WinTop;

		W.LeftButton.WinWidth = m_SBLeft.Up.W;
		W.LeftButton.WinHeight = m_SBLeft.Up.H;
		W.RightButton.WinWidth = m_SBRight.Up.W;
		W.RightButton.WinHeight = m_SBRight.Up.H;
	}
	else
	{
		W.EditBox.WinWidth = W.EditBoxWidth - MiscBevelL[2].W - MiscBevelR[2].W - ComboBtnUp.W;
		W.EditBox.WinHeight = W.WinHeight - MiscBevelT[2].H - MiscBevelB[2].H;
		W.Button.WinLeft = W.WinWidth - ComboBtnUp.W - MiscBevelR[2].W;
		W.Button.WinTop = W.EditBox.WinTop;
	}
	W.Button.WinHeight = W.EditBox.WinHeight;
}

function Combo_Draw(UWindowComboControl W, Canvas C)
{
	local Texture T;
    
	T = W.GetLookAndFeelTexture();
    
    // this is draw the border of the combo control
    C.Style = ERenderStyle.STY_Alpha;

    C.SetDrawColor(120,120,120);  //GrayLight = (R=120,G=120,B=120)

    //Top
    W.DrawStretchedTextureSegment(C, 0, 0, W.WinWidth, W.m_BorderTextureRegion.H , W.m_BorderTextureRegion.X, W.m_BorderTextureRegion.Y, W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTexture);
    //Bottom
    W.DrawStretchedTextureSegment(C, 0, W.WinHeight  - W.m_BorderTextureRegion.H, W.WinWidth, W.m_BorderTextureRegion.H , W.m_BorderTextureRegion.X, W.m_BorderTextureRegion.Y, W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTexture);
    //Left
    W.DrawStretchedTextureSegment(C, 0, W.m_BorderTextureRegion.H, W.m_BorderTextureRegion.W, W.WinHeight - (2* W.m_BorderTextureRegion.H), W.m_BorderTextureRegion.X, W.m_BorderTextureRegion.Y, W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTexture);
    //Right
    W.DrawStretchedTextureSegment(C, W.WinWidth - W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTextureRegion.W, W.WinHeight - (2* W.m_BorderTextureRegion.H), W.m_BorderTextureRegion.X, W.m_BorderTextureRegion.Y, W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTexture);
    // end of border combo control

	if(W.Text != "")
	{		
		C.SetDrawColor(W.TextColor.R,W.TextColor.G,W.TextColor.B);
        W.ClipText(C, W.TextX, W.TextY, W.Text);
	}
}
function R6List_DrawBackground(R6WindowListBox W, Canvas C)
{
	local Texture T;    
    
	T = m_R6ScrollTexture;
   
    C.SetDrawColor(W.m_BorderColor.R,W.m_BorderColor.G,W.m_BorderColor.B);    
	
	C.Style = ERenderStyle.STY_Alpha;	

	switch(W.m_eCornerType)
	{
		case No_Corners:
            W.DrawSimpleBorder(C);
			break;
		case Top_Corners:
			//Corners
			W.DrawStretchedTextureSegment(C, 0, 0, m_topLeftCornerR.W, m_topLeftCornerR.H, m_topLeftCornerR.X, m_topLeftCornerR.Y, 
													m_topLeftCornerR.W, m_topLeftCornerR.H, m_R6ScrollTexture);		
			W.DrawStretchedTextureSegment(C, W.WinWidth - m_topLeftCornerR.W, 0, m_topLeftCornerR.W, m_topLeftCornerR.H, 
													m_topLeftCornerR.X + m_topLeftCornerR.W, m_topLeftCornerR.Y, 
													-m_topLeftCornerR.W, m_topLeftCornerR.H, m_R6ScrollTexture);
            //top countour
			W.DrawStretchedTextureSegment(C, m_topLeftCornerR.W + m_iListHPadding, 0, W.WinWidth - (2 * m_iListHPadding) - (2 * m_topLeftCornerR.W), W.m_BorderTextureRegion.H, W.m_BorderTextureRegion.X, W.m_BorderTextureRegion.Y, W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTexture);
			//bottom countour
			W.DrawStretchedTextureSegment(C, m_iListVPadding, W.WinHeight - W.m_BorderTextureRegion.H, W.WinWidth - (2 * m_iListVPadding), W.m_BorderTextureRegion.H, W.m_BorderTextureRegion.X, W.m_BorderTextureRegion.Y, W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTexture);
			//Left countour
			W.DrawStretchedTextureSegment(C, m_iListVPadding, m_topLeftCornerR.H, W.m_BorderTextureRegion.W, W.WinHeight - m_topLeftCornerR.H, W.m_BorderTextureRegion.X, W.m_BorderTextureRegion.Y, W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTexture);
			//Right countour
			W.DrawStretchedTextureSegment(C, W.WinWidth - W.m_BorderTextureRegion.W - m_iListVPadding, m_topLeftCornerR.H, W.m_BorderTextureRegion.W, W.WinHeight - m_topLeftCornerR.H, W.m_BorderTextureRegion.X, W.m_BorderTextureRegion.Y, W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTexture);
			

			break;
		case Bottom_Corners:
			//Corners
			W.DrawStretchedTextureSegment(C, 0, W.WinHeight -  m_topLeftCornerR.H, m_topLeftCornerR.W, m_topLeftCornerR.H, m_topLeftCornerR.X, 
													m_topLeftCornerR.Y + m_topLeftCornerR.H, 
													m_topLeftCornerR.W, -m_topLeftCornerR.H, m_R6ScrollTexture);		
			W.DrawStretchedTextureSegment(C, W.WinWidth - m_topLeftCornerR.W, W.WinHeight -  m_topLeftCornerR.H, m_topLeftCornerR.W, m_topLeftCornerR.H, 
													m_topLeftCornerR.X + m_topLeftCornerR.W, m_topLeftCornerR.Y + m_topLeftCornerR.H, 
													-m_topLeftCornerR.W, -m_topLeftCornerR.H, m_R6ScrollTexture);			
            //top countour
			W.DrawStretchedTextureSegment(C, m_iListVPadding, 0, W.WinWidth - (2 * m_iListVPadding) , W.m_BorderTextureRegion.H, W.m_BorderTextureRegion.X, W.m_BorderTextureRegion.Y, W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTexture);
			//bottom countour
			W.DrawStretchedTextureSegment(C, m_topLeftCornerR.W + m_iListHPadding, W.WinHeight - W.m_BorderTextureRegion.H, W.WinWidth - (2 * m_iListHPadding) - (2 * m_topLeftCornerR.W), W.m_BorderTextureRegion.H, W.m_BorderTextureRegion.X, W.m_BorderTextureRegion.Y, W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTexture);
			//Left countour
			W.DrawStretchedTextureSegment(C, m_iListVPadding, 0, W.m_BorderTextureRegion.W, W.WinHeight - m_topLeftCornerR.H, W.m_BorderTextureRegion.X, W.m_BorderTextureRegion.Y, W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTexture);
			//Right countour
			W.DrawStretchedTextureSegment(C, W.WinWidth - W.m_BorderTextureRegion.W - m_iListVPadding, 0, W.m_BorderTextureRegion.W, W.WinHeight - m_topLeftCornerR.H, W.m_BorderTextureRegion.X, W.m_BorderTextureRegion.Y, W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTexture);
			
			
			break;
		case All_Corners:
			//Corners
			W.DrawStretchedTextureSegment(C, 0, 0, m_topLeftCornerR.W, m_topLeftCornerR.H, m_topLeftCornerR.X, m_topLeftCornerR.Y, 
													m_topLeftCornerR.W, m_topLeftCornerR.H, m_R6ScrollTexture);		
			W.DrawStretchedTextureSegment(C, W.WinWidth - m_topLeftCornerR.W, 0, m_topLeftCornerR.W, m_topLeftCornerR.H, 
													m_topLeftCornerR.X + m_topLeftCornerR.W, m_topLeftCornerR.Y, 
													-m_topLeftCornerR.W, m_topLeftCornerR.H, m_R6ScrollTexture);
			W.DrawStretchedTextureSegment(C, 0, W.WinHeight -  m_topLeftCornerR.H, m_topLeftCornerR.W, m_topLeftCornerR.H, m_topLeftCornerR.X, 
													m_topLeftCornerR.Y + m_topLeftCornerR.H, 
													m_topLeftCornerR.W, -m_topLeftCornerR.H, m_R6ScrollTexture);		
			W.DrawStretchedTextureSegment(C, W.WinWidth - m_topLeftCornerR.W, W.WinHeight -  m_topLeftCornerR.H, m_topLeftCornerR.W, m_topLeftCornerR.H, 
													m_topLeftCornerR.X + m_topLeftCornerR.W, m_topLeftCornerR.Y + m_topLeftCornerR.H, 
													-m_topLeftCornerR.W, -m_topLeftCornerR.H, m_R6ScrollTexture);
			
            //top countour
			W.DrawStretchedTextureSegment(C, m_topLeftCornerR.W + m_iListHPadding, 0, W.WinWidth - (2 * m_iListHPadding) - (2 * m_topLeftCornerR.W), W.m_BorderTextureRegion.H, W.m_BorderTextureRegion.X, W.m_BorderTextureRegion.Y, W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTexture);
			//bottom countour
			W.DrawStretchedTextureSegment(C, m_topLeftCornerR.W + m_iListHPadding, W.WinHeight - W.m_BorderTextureRegion.H, W.WinWidth - (2 * m_iListHPadding) - (2 * m_topLeftCornerR.W), W.m_BorderTextureRegion.H, W.m_BorderTextureRegion.X, W.m_BorderTextureRegion.Y, W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTexture);
			//Left countour
			W.DrawStretchedTextureSegment(C, m_iListVPadding, m_topLeftCornerR.H, W.m_BorderTextureRegion.W, W.WinHeight - (2 * m_topLeftCornerR.H), W.m_BorderTextureRegion.X, W.m_BorderTextureRegion.Y, W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTexture);
			//Right countour
			W.DrawStretchedTextureSegment(C, W.WinWidth - W.m_BorderTextureRegion.W - m_iListVPadding, m_topLeftCornerR.H, W.m_BorderTextureRegion.W, W.WinHeight - (2 * m_topLeftCornerR.H), W.m_BorderTextureRegion.X, W.m_BorderTextureRegion.Y, W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTexture);
			
			
			
			break;
        case No_Borders:
            break;
	}
	
}

function List_DrawBackground(UWindowListControl W, Canvas C)
{
	local Texture T;
    
	T = W.GetLookAndFeelTexture();

    W.DrawUpBevel( C, 0, 0, W.WinWidth, W.WinHeight, Active);

}


//=================================================================================
// This is draw the border of a combo list item
//=================================================================================
function ComboList_DrawBackground(UWindowComboList W, Canvas C)
{
    W.DrawSimpleBorder(C);      
}

//=================================================================================
// This is draw a combo list item
//=================================================================================
function ComboList_DrawItem(UWindowComboList Combo, Canvas C, FLOAT X, FLOAT Y, FLOAT W, FLOAT H, string Text, bool bSelected)
{
	local Texture T;
    
	T = Combo.GetLookAndFeelTexture();

//	C.SetDrawColor(22,22,22);

	if(bSelected)
	{
    	C.SetDrawColor(0,0,0);
		Combo.DrawStretchedTextureSegment(C, X, Y, W, H, 4, 16, 1, 1, T);
//		C.SetDrawColor(0,0,0);
        C.SetDrawColor(255,255,255); // white
	}
	else
	{
		C.SetDrawColor(22,22,22);
		Combo.DrawStretchedTextureSegment(C, X, Y, W, H, 4, 16, 1, 1, T);
        C.SetDrawColor(15,136,176);
	}

//    C.SetDrawColor(255,255,255); // white

	Combo.ClipText(C, X + Combo.TextBorder + 2, Y + 3, Text);
}


function Combo_SetupButton(UWindowComboButton W)
{
	local Texture T;

	T = W.GetLookAndFeelTexture();
	
	W.bUseRegion = True;

	W.UpTexture =  Texture'R6MenuTextures.Gui_BoxScroll';
	W.DownTexture =  Texture'R6MenuTextures.Gui_BoxScroll';
	W.OverTexture =  Texture'R6MenuTextures.Gui_BoxScroll';
	W.DisabledTexture =  Texture'R6MenuTextures.Gui_BoxScroll';

	W.UpRegion = ComboBtnUp;
	W.DownRegion = ComboBtnDown;
	W.OverRegion = ComboBtnOver;
	W.DisabledRegion = ComboBtnDisabled;	

    W.ImageX = m_fComboImageX;
    W.ImageY = m_fComboImageY;
}

function Editbox_SetupSizes(UWindowEditControl W, Canvas C)
{
	local FLOAT fTW, fTH;
	local INT B;

	B = EditBoxBevel;
		
	C.Font = W.Root.Fonts[W.Font];
	W.TextSize(C, W.Text, fTW, fTH);
	
	W.WinHeight = 12 + MiscBevelT[B].H + MiscBevelB[B].H;
		
	switch(W.Align)
	{
	case TA_Left:
		W.EditAreaDrawX = W.WinWidth - W.EditBoxWidth;
		W.TextX = 0;
		break;
	case TA_Right:
		W.EditAreaDrawX = 0;	
		W.TextX = W.WinWidth - fTW;
		break;
	case TA_Center:
		W.EditAreaDrawX = W.WinWidth - W.EditBoxWidth;
		W.TextX = (W.WinWidth - fTW);
		break;
	}

	W.EditAreaDrawY = (W.WinHeight - 2);
	W.TextY = (W.WinHeight - fTH);

	W.EditBox.WinLeft = W.EditAreaDrawX + MiscBevelL[B].W;
	W.EditBox.WinTop = MiscBevelT[B].H;
	W.EditBox.WinWidth = W.EditBoxWidth - MiscBevelL[B].W - MiscBevelR[B].W;
	W.EditBox.WinHeight = W.WinHeight - MiscBevelT[B].H - MiscBevelB[B].H;
}

function Editbox_Draw(UWindowEditControl W, Canvas C)
{
	W.DrawMiscBevel(C, W.EditAreaDrawX, 0, W.EditBoxWidth, W.WinHeight, Active, EditBoxBevel);

    /*
	if(W.Text != "")
	{		
		C.SetDrawColor(W.TextColor.R,W.TextColor.G,W.TextColor.B);
		W.ClipText(C, W.TextX, W.TextY, W.Text);
//		C.SetDrawColor(255,255,255);		
	}
    */
}

function Tab_DrawTab(UWindowTabControlTabArea Tab, Canvas C, bool bActiveTab, bool bLeftmostTab, FLOAT X, FLOAT Y, FLOAT W, FLOAT H, string Text, bool bShowText)
{
	local Region R, 
                 Temp_RTabLeft,
                 Temp_RTabRight;
	local string szText;
	local FLOAT fTW, fTH, fXOffset;

    fXOffset = Size_TabTextOffset;  // this value is the offset from the beginning of the tab -- for text -- (just under the small curve)

    C.Style = ERenderStyle.STY_Alpha;
	szText = Text;

	if(bActiveTab)
	{
        // draw a border under the tab 
//        C.SetDrawColor( 120, 120, 120); //graylight
//        Tab.DrawStretchedTextureSegment(C, X, Y + Tab.WinHeight - 1, W, Tab.m_BorderTextureRegion.H , Tab.m_BorderTextureRegion.X, Tab.m_BorderTextureRegion.Y, Tab.m_BorderTextureRegion.W, Tab.m_BorderTextureRegion.H, Tab.m_BorderTexture);


        C.SetDrawColor( Tab.m_vEffectColor.R, Tab.m_vEffectColor.G, Tab.m_vEffectColor.B);
        if (Tab.m_bDisplayToolTip)
            C.SetDrawColor( Tab.Root.Colors.BlueLight.R, Tab.Root.Colors.BlueLight.G, Tab.Root.Colors.BlueLight.B);

        
        R = TabSelectedL;
        Tab.DrawStretchedTextureSegment( C, X, Y, R.W, R.H, R.X, R.Y, R.W, R.H, m_R6ScrollTexture);
		R = TabSelectedM;
		Tab.DrawStretchedTextureSegment( C, X+TabSelectedL.W, Y, W - TabSelectedL.W	- TabSelectedR.W,
  										 R.H, R.X, R.Y, R.W, R.H, m_R6ScrollTexture );
        R = TabSelectedR;
        Tab.DrawStretchedTextureSegment( C, X + W - R.W, Y, R.W, R.H, R.X, R.Y, R.W, R.H, m_R6ScrollTexture);

		if(bShowText)
		{
            C.Style  = ERenderStyle.STY_Normal;
    		C.Font   = Tab.Root.Fonts[F_TabMainTitle];
            C.SpaceX = 0;

			szText = Tab.TextSize(C, szText, fTW, fTH, W - fXOffset - TabSelectedR.W);

            // center the text in the tab
		    Y = (Tab.WinHeight - fTH) / 2;
		    Y = FLOAT(INT(Y+0.5));

//			Tab.ClipText(C, X + (W-fTW-6)/2, Y, Text, True);
            Tab.ClipText(C, X + fXOffset, Y, szText, True);
		}
	}
	else
	{
        switch(Tab.m_eTabCase)
        {
            case Tab.eTabCase.eTab_Left:
                Temp_RTabLeft = TabSelectedL;
                Temp_RTabRight = TabSelectedR;
                break;
            case Tab.eTabCase.eTab_Left_RightCut: 
                Temp_RTabLeft = TabSelectedL;
                Temp_RTabRight = TabUnselectedR;
                break;
            case Tab.eTabCase.eTab_Middle:
                Temp_RTabLeft = TabUnselectedL;
                Temp_RTabRight = TabSelectedR;
                break;
            case Tab.eTabCase.eTab_Middle_RightCut:
                Temp_RTabLeft = TabUnselectedL;
                Temp_RTabRight = TabUnselectedR;
                break;
            default:
                Temp_RTabLeft = TabUnselectedL;
                Temp_RTabRight = TabSelectedR;
                break;
        }

        // draw a border under the tab 
//        C.SetDrawColor( 255, 255, 255); //white
//        Tab.DrawStretchedTextureSegment(C, X, Y + Tab.WinHeight - 1, W, W.m_BorderTextureRegion.H , W.m_BorderTextureRegion.X, W.m_BorderTextureRegion.Y, W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTexture);

        C.SetDrawColor(Tab.m_vEffectColor.R, Tab.m_vEffectColor.G, Tab.m_vEffectColor.B);
		if (Tab.m_bDisplayToolTip)
			C.SetDrawColor( Tab.Root.Colors.BlueLight.R, Tab.Root.Colors.BlueLight.G, Tab.Root.Colors.BlueLight.B);

        // 2 part to 
        R = Temp_RTabLeft;
        Tab.DrawStretchedTextureSegment( C, X, Y, R.W, R.H, R.X, R.Y, R.W, R.H, m_R6ScrollTexture);
		R = TabSelectedM;
		Tab.DrawStretchedTextureSegment( C, X+TabSelectedL.W, Y, W - TabSelectedL.W	- TabSelectedR.W,
  										 R.H, R.X, R.Y, R.W, R.H, m_R6ScrollTexture );
        R = Temp_RTabRight;
        Tab.DrawStretchedTextureSegment( C, X + W - R.W, Y, R.W, R.H, R.X, R.Y, R.W, R.H, m_R6ScrollTexture);

		if(bShowText)
		{
            C.Style  = ERenderStyle.STY_Normal;
    		C.Font   = Tab.Root.Fonts[F_TabMainTitle];
            C.SpaceX = 0;
            
			szText = Tab.TextSize(C, szText, fTW, fTH, W - fXOffset - TabSelectedR.W);
            
            // center the text in the tab
		    Y = (Tab.WinHeight - fTH) / 2;
		    Y = FLOAT(INT(Y+0.5));

//			Tab.ClipText(C, X + (W-fTW-6)/2, Y, Text, True);
            Tab.ClipText(C, X + fXOffset, Y, szText, True);
		}
	}
}


// ****** Scroll Bar ******
function SB_SetupUpButton(UWindowSBUpButton W)
{
	local Texture T;
	
	T = m_R6ScrollTexture;

	W.bUseRegion = true;

	W.UpTexture         = T;
	W.DownTexture       = T;
	W.OverTexture       = T;
	W.DisabledTexture   = T;

    if( UWindowVScrollBar(W.OwnerWindow).m_bUseSpecialEffect == true)
    {
        W.UpRegion          = m_SBUpGear;
	}
    else
    {
        W.UpRegion          = m_SBUp.Up;	    
    }

    W.DownRegion        = m_SBUp.Down;
	W.OverRegion        = m_SBUp.Over;
	W.DisabledRegion    = m_SBUp.Disabled;
	
    W.m_bDrawButtonBorders = true;

    W.ImageX = m_fVSBButtonImageX;
    W.ImageY = m_fVSBButtonImageY;

}

function SB_SetupDownButton(UWindowSBDownButton W)
{
	local Texture T;

	T = m_R6ScrollTexture;

	W.bUseRegion = True;

	W.UpTexture = T;
	W.DownTexture = T;
	W.OverTexture = T;
	W.DisabledTexture = T;

    if( UWindowVScrollBar(W.OwnerWindow).m_bUseSpecialEffect == true)
    {
        W.UpRegion          = m_SBDownGear;	    
    }
    else
    {        
	    W.UpRegion          = m_SBDown.Up;	    
    }

    W.DownRegion        = m_SBDown.Down;
	W.OverRegion        = m_SBDown.Over;
	W.DisabledRegion    = m_SBDown.Disabled;

    W.m_bDrawButtonBorders = true;    

    
    W.ImageX = m_fVSBButtonImageX;
    W.ImageY = m_fVSBButtonImageY;
}

function SB_SetupLeftButton(UWindowSBLeftButton W)
{
	local Texture T;

	T = m_R6ScrollTexture;

	W.bUseRegion = True;

	W.UpTexture = T;
	W.DownTexture = T;
	W.OverTexture = T;
	W.DisabledTexture = T;

	W.UpRegion = m_SBLeft.Up;
	W.DownRegion = m_SBLeft.Down;
	W.OverRegion = m_SBLeft.Up;
	W.DisabledRegion = m_SBLeft.Disabled;
    W.m_bDrawButtonBorders = true;
    
    W.ImageX = m_fHSBButtonImageX;
    W.ImageY = m_fHSBButtonImageY;
}

function SB_SetupRightButton(UWindowSBRightButton W)
{
	local Texture T;

	T = m_R6ScrollTexture;

	W.bUseRegion = True;

	W.UpTexture = T;
	W.DownTexture = T;
	W.OverTexture = T;
	W.DisabledTexture = T;

	W.UpRegion = m_SBRight.Up;
	W.DownRegion = m_SBRight.Down;
	W.OverRegion = m_SBRight.Up;
	W.DisabledRegion = m_SBRight.Disabled;
    W.m_bDrawButtonBorders = true;

    //W.m_fRotAngleWidth=m_SBRight.Up.W;
    //W.m_fRotAngleHeight=m_SBRight.Up.H;

    W.ImageX = m_fHSBButtonImageX;
    W.ImageY = m_fHSBButtonImageY;
}

function SB_VDraw(UWindowVScrollbar W, Canvas C)
{		
    local int BoxHeight;

    BoxHeight = W.WinHeight - W.UpButton.WinHeight - W.DownButton.WinHeight + W.UpButton.m_BorderTextureRegion.H + W.DownButton.m_BorderTextureRegion.H;         

    C.SetDrawColor(W.m_BorderColor.R,W.m_BorderColor.G,W.m_BorderColor.B);	

    DrawBox(W, C, 0, W.UpButton.WinHeight - W.UpButton.m_BorderTextureRegion.H, W.WinWidth, BoxHeight);

    C.Style=5;//ERenderStyle.STY_Alpha
    C.SetDrawColor(W.Root.Colors.White.R,W.Root.Colors.White.G,W.Root.Colors.White.B, W.Root.Colors.White.A);	

//    if(W.bMouseDown == true)
//    {                
//	    //Scroller
//	    W.DrawStretchedTextureSegment(C, m_iSize_ScrollBarFrameW + m_iScrollerOffset, W.ThumbStart, m_iVScrollerWidth , W.ThumbHeight, 
//									 m_SBScrollerActive.X, m_SBScrollerActive.Y, m_SBScrollerActive.W, m_SBScrollerActive.H, m_R6ScrollTexture);	        
//    }
//    else
//    {

        if(W.m_bUseSpecialEffect)
            C.SetDrawColor(W.Root.Colors.GrayLight.R,W.Root.Colors.GrayLight.G,W.Root.Colors.GrayLight.B, W.Root.Colors.GrayLight.A);	

        //traditional stylez
	    W.DrawStretchedTextureSegment(C, m_iSize_ScrollBarFrameW + m_iScrollerOffset, W.ThumbStart, m_iVScrollerWidth , W.ThumbHeight, 
									 m_SBScroller.X, m_SBScroller.Y, m_SBScroller.W, m_SBScroller.H, m_R6ScrollTexture);	
//     }
    
}

function SB_HDraw(UWindowHScrollbar W, Canvas C)
{
    local int BoxWidth;
	
    C.SetDrawColor(W.m_BorderColor.R,W.m_BorderColor.G,W.m_BorderColor.B);	

    BoxWidth = W.WinWidth - W.LeftButton.WinWidth - W.RightButton.WinWidth + W.LeftButton.m_BorderTextureRegion.W + W.RightButton.m_BorderTextureRegion.W;

    DrawBox(W, C, W.LeftButton.WinWidth - W.LeftButton.m_BorderTextureRegion.W, 0, BoxWidth, W.WinHeight);
	
	// Scroller
	W.DrawStretchedTextureSegment(C, W.ThumbStart, m_iSize_ScrollBarFrameW + m_iScrollerOffset, W.ThumbWidth, m_iVScrollerWidth, 
									 m_SBScroller.X, m_SBScroller.Y, m_SBScroller.W, m_SBScroller.H, m_R6ScrollTexture);	
}

function Tab_SetupLeftButton(UWindowTabControlLeftButton W)
{
	local Texture T;

	T = W.GetLookAndFeelTexture();


	W.WinWidth = Size_ScrollbarButtonHeight;
	W.WinHeight = Size_ScrollbarWidth;
	W.WinTop = Size_TabAreaHeight - W.WinHeight;
	W.WinLeft = W.ParentWindow.WinWidth - 2*W.WinWidth;

	W.bUseRegion = True;

	W.UpTexture = T;
	W.DownTexture = T;
	W.OverTexture = T;
	W.DisabledTexture = T;

	W.UpRegion = m_SBLeft.Up;
	W.DownRegion = m_SBLeft.Down;
	W.OverRegion = m_SBLeft.Up;
	W.DisabledRegion = m_SBLeft.Disabled;
}

function Tab_SetupRightButton(UWindowTabControlRightButton W)
{
	local Texture T;

	T = W.GetLookAndFeelTexture();

	W.WinWidth = Size_ScrollbarButtonHeight;
	W.WinHeight = Size_ScrollbarWidth;
	W.WinTop = Size_TabAreaHeight - W.WinHeight;
	W.WinLeft = W.ParentWindow.WinWidth - W.WinWidth;

	W.bUseRegion = True;

	W.UpTexture = T;
	W.DownTexture = T;
	W.OverTexture = T;
	W.DisabledTexture = T;

	W.UpRegion = m_SBRight.Up;
	W.DownRegion = m_SBRight.Down;
	W.OverRegion = m_SBRight.Up;
	W.DisabledRegion = m_SBRight.Disabled;
}

function Tab_SetTabPageSize(UWindowPageControl W, UWindowPageWindow P)
{
	P.WinLeft = 2;
	P.WinTop = W.TabArea.WinHeight-(TabSelectedM.H-TabUnselectedM.H) + 3;
	P.SetSize(W.WinWidth - 4, W.WinHeight-(W.TabArea.WinHeight-(TabSelectedM.H-TabUnselectedM.H)) - 6);
}

function Tab_DrawTabPageArea(UWindowPageControl W, Canvas C, UWindowPageWindow P)
{
	W.DrawUpBevel( C, 0, Size_TabAreaHeight, W.WinWidth, W.WinHeight-Size_TabAreaHeight, Active);
}

function Tab_GetTabSize(UWindowTabControlTabArea Tab, Canvas C, string Text, out FLOAT W, out FLOAT H)
{
	local FLOAT fTW, fTH;

	C.Font = Tab.Root.Fonts[Tab.F_TabMainTitle];

	Tab.TextSize( C, Text, fTW, fTH );

	W = fTW + Size_TabSpacing + Size_TabTextOffset + TabSelectedR.W;
	H = fTH;
}

function Menu_DrawMenuBar(UWindowMenuBar W, Canvas C)
{
    W.DrawStretchedTextureSegment(C, 0, 0, W.WinWidth, 16, 11, 0, 106, 16, Active);
}

function Menu_DrawMenuBarItem(UWindowMenuBar B, UWindowMenuBarItem I, FLOAT X, FLOAT Y, FLOAT W, FLOAT H, Canvas C)
{
	if(B.Selected == I)
	{
		B.DrawClippedTexture(C, X, 1, Texture'BlackTexture');
		B.DrawClippedTexture(C, X+W-1, 1, Texture'BlackTexture');
		B.DrawStretchedTexture(C, X+1, 1, W-2, 16, Texture'BlackTexture');
	}

	C.Font = B.Root.Fonts[F_Normal];
	C.SetDrawColor(0,0,0);	

	B.ClipText(C, X + B.Spacing / 2, 2, I.Caption, True);
}

function Menu_DrawPulldownMenuBackground(UWindowPulldownMenu W, Canvas C)
{
}

function Menu_DrawPulldownMenuItem(UWindowPulldownMenu M, UWindowPulldownMenuItem Item, Canvas C, FLOAT X, FLOAT Y, FLOAT W, FLOAT H, bool bSelected)
{
}

// ****** R6 Add-On ******
function DrawWinTop(R6WindowHSplitter W, Canvas C)
{
    W.DrawStretchedTextureSegment(C, 0,0,FrameTL.W,W.WinHeight, FrameTL.X,FrameTL.Y,FrameTL.W,FrameTL.H, Active);
    W.DrawStretchedTextureSegment(C, FrameTL.W,0,W.WinWidth-FrameTL.W-FrameTR.W,W.WinHeight, FrameT.X,FrameT.Y,FrameT.W,FrameT.H, Active);
    W.DrawStretchedTextureSegment(C, W.WinWidth-FrameTR.W,0,FrameTR.W,W.WinHeight, FrameTR.X,FrameTR.Y,FrameTR.W,FrameTR.H, Active);
}

function DrawHSplitterT(R6WindowHSplitter W, Canvas C)
{
    W.DrawStretchedTextureSegment(C, 0,0,12,W.WinHeight, 30,5,12,6, Active);
    W.DrawStretchedTextureSegment(C, 12,0,W.WinWidth-24,W.WinHeight, 42,5, 2,6, Active);
    W.DrawStretchedTextureSegment(C, W.WinWidth-12,0,12,W.WinHeight, 49,5,12,6, Active);
}

function DrawHSplitterB(R6WindowHSplitter W, Canvas C)
{
    W.DrawStretchedTextureSegment(C, 0,0,12,W.WinHeight, 61,5,12,6, Active);
    W.DrawStretchedTextureSegment(C, 12,0,W.WinWidth-24,W.WinHeight, 73,5, 2,6, Active);
    W.DrawStretchedTextureSegment(C, W.WinWidth-12,0,12,W.WinHeight, 80,5,12,6, Active);
}

function DrawPopupButtonDown(R6MenuPopUpStayDownButton W, Canvas C)
{
    local INT iColor;
	local color MenuColor;

    iColor = R6PlanningCtrl(W.GetPlayerOwner()).m_iCurrentTeam;
    C.Style=1;//ERenderStyle.STY_Normal

    //Draw backtround
    MenuColor = W.Root.Colors.TeamColorLight[iColor];
    MenuColor.R /= 2;
    MenuColor.G /= 2;
    MenuColor.B /= 2;
	C.SetDrawColor(MenuColor.R,MenuColor.G,MenuColor.B);
    W.DrawStretchedTexture( C, 0, 0, W.WinWidth, W.WinHeight, Texture'UWindow.WhiteTexture');

    //Text and sub menu icon are now white, not transparent
    MenuColor = W.Root.Colors.White;
	C.SetDrawColor(MenuColor.R,MenuColor.G,MenuColor.B);

	//Button text
    if(W.Text != "")
	{
        W.ClipText(C, W.TextX, W.TextY, W.Text, true);
	}
    C.Style=5;
    //Submenu icon
    if(W.m_bSubMenu)
    {
        W.DrawStretchedTextureSegment( C, W.WinWidth - (2 + m_PopupArrowDown.H), (W.WinHeight - m_PopupArrowDown.H)*0.5, m_PopupArrowDown.W, m_PopupArrowDown.H, m_PopupArrowDown.X, m_PopupArrowDown.Y, m_PopupArrowDown.W, m_PopupArrowDown.H, m_R6ScrollTexture);
    }

	C.SetDrawColor(255,255,255);	
}

function DrawPopupButtonUp(R6MenuPopUpStayDownButton W, Canvas C)
{
	local color MenuColor;

	MenuColor = W.Root.Colors.White;
	C.SetDrawColor(MenuColor.R,MenuColor.G,MenuColor.B,W.Root.Colors.PopUpAlphaFactor);

    C.Style=5;//ERenderStyle.STY_Alpha
	if(W.Text != "")
	{
        W.ClipText(C, W.TextX, W.TextY, W.Text, true);
	}
    if(W.m_bSubMenu)
    {
        W.DrawStretchedTextureSegment( C, W.WinWidth - (2 + m_PopupArrowDown.H), (W.WinHeight - m_PopupArrowUp.H)*0.5, m_PopupArrowUp.W, m_PopupArrowUp.H, m_PopupArrowUp.X, m_PopupArrowUp.Y, m_PopupArrowUp.W, m_PopupArrowUp.H, m_R6ScrollTexture);
    }

    C.Style=1;//ERenderStyle.STY_Normal

	C.SetDrawColor(255,255,255);
}

function DrawPopupButtonOver(R6MenuPopUpStayDownButton W, Canvas C)
{
	local color MenuColor;

	MenuColor = W.Root.Colors.White;
	C.SetDrawColor(MenuColor.R,MenuColor.G,MenuColor.B);

    C.Style=1;//ERenderStyle.STY_Normal
	if(W.Text != "")
	{
        W.ClipText(C, W.TextX, W.TextY, W.Text, true);
	}
    C.Style=5;
    if(W.m_bSubMenu)
    {
        W.DrawStretchedTextureSegment( C, W.WinWidth - (2 + m_PopupArrowDown.H), (W.WinHeight - m_PopupArrowUp.H)*0.5, m_PopupArrowUp.W, m_PopupArrowUp.H, m_PopupArrowUp.X, m_PopupArrowUp.Y, m_PopupArrowUp.W, m_PopupArrowUp.H, m_R6ScrollTexture);
    }

	C.SetDrawColor(255,255,255);
}

function DrawPopupButtonDisable(R6MenuPopUpStayDownButton W, Canvas C)
{
	local color MenuColor; 

    MenuColor = W.Root.Colors.White;
	C.SetDrawColor(MenuColor.R,MenuColor.G,MenuColor.B,50);

    C.Style=5;//ERenderStyle.STY_Alpha
	if(W.Text != "")
	{
        W.ClipText(C, W.TextX, W.TextY, W.Text, true);
	}
    if(W.m_bSubMenu)
    {
        W.DrawStretchedTextureSegment( C, W.WinWidth - (2 + m_PopupArrowDown.H), (W.WinHeight - m_PopupArrowUp.H)*0.5, m_PopupArrowUp.W, m_PopupArrowUp.H, m_PopupArrowUp.X, m_PopupArrowUp.Y, m_PopupArrowUp.W, m_PopupArrowUp.H, m_R6ScrollTexture);
    }

    C.Style=1;//ERenderStyle.STY_Normal

	C.SetDrawColor(255,255,255);
	
}


//===================================================================================================
// Draw the navigation bar (ex.: in briefing menu, at the bottom of the page
//===================================================================================================
function DrawNavigationBar(R6MenuNavigationBar W, Canvas C)
{
    local INT iXStart, iXTexSize, iXWidth;
    local INT iYTexSize;
    local Region R;
    local color cTemp;  

    // Draw frame box
    cTemp = W.m_BorderColor;
    W.m_BorderColor = W.Root.Colors.BlueLight; 
    W.DrawSimpleBorder(C);
    W.m_BorderColor = cTemp;

    C.Style = ERenderStyle.STY_Alpha;

    // draw a line between option and briefing
    C.SetDrawColor( W.Root.Colors.BlueLight.R, W.Root.Colors.BlueLight.G, W.Root.Colors.BlueLight.B);
    W.DrawStretchedTextureSegment(C, 120, 0, 1, 33, 
                                     W.m_BorderTextureRegion.X, W.m_BorderTextureRegion.Y, W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTexture);

    // draw a line before play
    W.DrawStretchedTextureSegment(C, 414, 0, 1, 33, 
                                     W.m_BorderTextureRegion.X, W.m_BorderTextureRegion.Y, W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTexture);

    // draw a line after play
    W.DrawStretchedTextureSegment(C, 450, 0, 1, 33, 
                                     W.m_BorderTextureRegion.X, W.m_BorderTextureRegion.Y, W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTexture);

    // draw a line after load
    W.DrawStretchedTextureSegment(C, 554, 0, 1, 33, 
                                     W.m_BorderTextureRegion.X, W.m_BorderTextureRegion.Y, W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTexture);
    
    // Draw background effect
    iXStart = 120;      // the start position of the background effect (what appear on the button in the middle)
    iXTexSize = 12;     // the width size of the start tex
    iXWidth = 318;      // the width of the background effect
    iYTexSize = 34;     // the height size of the tex - 2 ->2 pixel for the border line
    
    //this is the part of the background between the two extremities (NAV BAR)
    R = m_NavBarBack[0];
    W.DrawStretchedTextureSegment( C, iXStart + iXTexSize, -1, iXWidth - iXTexSize, iYTexSize,R.X,R.Y,R.W,R.H, m_NavBarTex); 

    R = m_NavBarBack[1];
    //the left part of the background (NAV BAR)
    W.DrawStretchedTextureSegment( C, iXStart, -1, iXTexSize, iYTexSize,R.X,R.Y,R.W,R.H, m_NavBarTex);

    //the right part of the background (NAV BAR) inverse the texture
    W.DrawStretchedTextureSegment( C, iXStart + iXWidth, -1, iXTexSize, iYTexSize, R.X+iXTexSize, R.Y, -R.W,R.H, m_NavBarTex);

    C.Style = ERenderStyle.STY_Normal;
}


function DrawButtonBorder(UWindowWindow W, Canvas C, optional bool _bDefineBorderColor)
{	
	if( (m_TButtonBackGround != None))
	{
		C.Style = ERenderStyle.STY_Alpha;
	
        if ( _bDefineBorderColor)
            C.SetDrawColor( W.m_BorderColor.R, W.m_BorderColor.G, W.m_BorderColor.B);
        else
    		C.SetDrawColor(m_CBorder.R,m_CBorder.G,m_CBorder.B);
		
		//BackGround and Border        
		W.DrawStretchedTextureSegment( C, 0 , 0, W.WinWidth , W.WinHeight, 
											m_RButtonBackGround.X, m_RButtonBackGround.Y, 
											m_RButtonBackGround.W, m_RButtonBackGround.H, m_TButtonBackGround );

//		C.SetDrawColor(255,255,255);
//		C.Style =1;
	}
}


//Function to draw a different background then the basic SimpleBorder
function DrawSpecialButtonBorder(R6WindowButton Button, Canvas C, FLOAT X, FLOAT Y)
{
    local INT Xpos;
    local INT MidWidth;

    //Draw Buttons Contour
    C.Style = ERenderStyle.STY_Alpha;
    
    C.SetDrawColor(Button.m_BorderColor.R,Button.m_BorderColor.G,Button.m_BorderColor.B);

    Xpos = 0;

    //Left Part
    Button.DrawStretchedTextureSegment(C, Xpos, 0, m_RSquareBgLeft.W, m_RSquareBgLeft.H, m_RSquareBgLeft.X, m_RSquareBgLeft.Y, m_RSquareBgLeft.W, m_RSquareBgLeft.H, m_TSquareBg);

    Xpos += m_RSquareBgLeft.W;
    MidWidth = Button.WinWidth - m_RSquareBgLeft.W - m_RSquareBgRight.W;
    //Mid Part
    Button.DrawStretchedTextureSegment(C, Xpos, 0, MidWidth, m_RSquareBgMid.H, m_RSquareBgMid.X, m_RSquareBgMid.Y, m_RSquareBgMid.W, m_RSquareBgMid.H, m_TSquareBg);

    Xpos = Button.WinWidth - m_RSquareBgRight.W;
    //Right Part
    Button.DrawStretchedTextureSegment(C, Xpos, 0, m_RSquareBgRight.W, m_RSquareBgRight.H, m_RSquareBgRight.X, m_RSquareBgRight.Y, m_RSquareBgRight.W, m_RSquareBgRight.H, m_TSquareBg);
}

function DrawBox(UWindowWindow W, Canvas C, float X, float Y, float Width, float Height)
{
    //Draw Buttons Contour
    C.Style = ERenderStyle.STY_Alpha;

    C.SetDrawColor(W.m_BorderColor.R,W.m_BorderColor.G,W.m_BorderColor.B);

    //Top
    W.DrawStretchedTextureSegment(C, x, Y, Width, W.m_BorderTextureRegion.H , W.m_BorderTextureRegion.X, W.m_BorderTextureRegion.Y, W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTexture);
    //Bottom
    W.DrawStretchedTextureSegment(C, x, Y + Height - W.m_BorderTextureRegion.H, Width, W.m_BorderTextureRegion.H , W.m_BorderTextureRegion.X, W.m_BorderTextureRegion.Y, W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTexture);
    //Left
    W.DrawStretchedTextureSegment(C, x, Y + W.m_BorderTextureRegion.H, W.m_BorderTextureRegion.W, Height - (2* W.m_BorderTextureRegion.H), W.m_BorderTextureRegion.X, W.m_BorderTextureRegion.Y, W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTexture);
    //Right
    W.DrawStretchedTextureSegment(C, X + Width - W.m_BorderTextureRegion.W, Y + W.m_BorderTextureRegion.H, W.m_BorderTextureRegion.W, Height - (2* W.m_BorderTextureRegion.H), W.m_BorderTextureRegion.X, W.m_BorderTextureRegion.Y, W.m_BorderTextureRegion.W, W.m_BorderTextureRegion.H, W.m_BorderTexture);

//    C.Style = ERenderStyle.STY_Normal;
    
}

function DrawBGShading( UWindowWindow Window, Canvas C, FLOAT X, FLOAT Y, FLOAT W, FLOAT H)
{
     //Draw Buttons Contour
    C.Style = ERenderStyle.STY_Alpha;

    //ListBox bg shading
    C.SetDrawColor( Window.Root.Colors.Black.R, Window.Root.Colors.Black.G, Window.Root.Colors.Black.B, Window.Root.Colors.DarkBGAlpha);
    Window.DrawStretchedTexture( C, X, Y, W, H, Texture'UWindow.WhiteTexture');
}


function DrawPopUpTextBackGround( UWindowWindow W, Canvas C, FLOAT _fHeight )
{

    local Region RTexture;
    local FLOAT  fY, fHeight;
    // draw the eye icon
    RTexture.X = 114;
    RTexture.Y = 47;
    RTexture.W = 2;
    RTexture.H = 13;

	C.Style = ERenderStyle.STY_Alpha;

	fHeight = _fHeight;

    if ( fHeight < W.WinHeight )
        fY = ( W.WinHeight - fHeight ) / 2;
    else
        fY = 0;

	if (fHeight < RTexture.H) // don't stretch the tex before the min value
		fHeight = RTexture.H;

    W.DrawStretchedTextureSegment( C, 0, 0, W.WinWidth, 13, 
                                      RTexture.X, RTexture.Y, RTexture.W, RTexture.H, m_R6ScrollTexture);
}


function DrawInGamePlayerStats( UWindowWindow W, Canvas C, INT _iPlayerStats, FLOAT _fX, FLOAT _fY, FLOAT _fHeight, FLOAT _fWidth)
{
    local FLOAT fXOffset;
    local Region RIconRegion, RIconToDraw;

    // draw the health icon
    RIconToDraw.Y = 29;
    RIconToDraw.W = 10;
    RIconToDraw.H = 10;
    fXOffset      = _fX;    

    switch( _iPlayerStats)
    {
        case 1:
            // draw the full health icon
            RIconToDraw.X = 31;
            RIconRegion = CenterIconInBox( fXOffset, _fY, _fWidth, _fHeight, RIconToDraw);
            break;
        case 2:
            // draw the half health icon
            RIconToDraw.X = 42;
            RIconRegion = CenterIconInBox( fXOffset, _fY, _fWidth, _fHeight, RIconToDraw);
            break;
        case 3:
            // draw the empty health icon
            RIconToDraw.X = 53;
            RIconRegion = CenterIconInBox( fXOffset, _fY, _fWidth, _fHeight, RIconToDraw);
            break;
        case 4:
            // draw the team icon
            RIconToDraw.X = 53;
            RIconToDraw.Y = 40;
            RIconToDraw.W = 10;
            RIconToDraw.H = 10;            
            RIconRegion = CenterIconInBox( fXOffset, _fY, _fWidth, _fHeight, RIconToDraw);
            break;
        default:
            // draw the ? icon Kill by
            RIconToDraw.X = 49;
            RIconToDraw.Y = 14;
            RIconToDraw.W = 10;
            RIconToDraw.H = 10;           

            RIconRegion = CenterIconInBox( fXOffset, _fY, _fWidth, _fHeight, RIconToDraw);
            break;
    }

    W.DrawStretchedTextureSegment( C, RIconRegion.X, RIconRegion.Y, RIconToDraw.W, RIconToDraw.H, 
                                      RIconToDraw.X, RIconToDraw.Y, RIconToDraw.W, RIconToDraw.H, m_TIcon);
}

//=======================================================================================================
// This function return the region where to draw the icon X and Y depending of window region
// (W and H are 0)
//=======================================================================================================
function Region CenterIconInBox( FLOAT _fX, FLOAT _fY, FLOAT _fWidth, FLOAT _fHeight, Region _RIconRegion)
{
    local Region RTemp;
	local FLOAT fTemp;

	fTemp = (_fWidth - _RIconRegion.W) / 2;
    RTemp.X = _fX + INT(fTemp + 0.5);

    fTemp = (_fHeight - _RIconRegion.H) / 2;
    RTemp.Y = FLOAT(INT(fTemp + 0.5));    
    RTemp.Y += _fY;

    return RTemp;
}

//=================================================================================================
// Get the size (height) of the header window (interwidget menu)
//=================================================================================================
function FLOAT GetTextHeaderSize()
{
    return m_fTextHeaderHeight;
}

// --------------------------------------- 
// ---------- defaultproperties ---------- 
// ---------------------------------------

defaultproperties
{
     m_iMultiplyer=-1
     m_fVSBButtonImageX=1
     m_fHSBButtonImageX=2
     m_fVSBButtonImageY=2
     m_fHSBButtonImageY=2
     m_fComboImageX=1
     m_fComboImageY=2
     m_fScrollRate=200.000000
     m_fTextHeaderHeight=30.000000
     m_TSquareBg=Texture'R6MenuTextures.Gui_BoxScroll'
     m_FrameSBL=(W=1,H=1)
     m_FrameSB=(X=107,Y=17,W=16,H=17)
     m_FrameSBR=(W=1,H=1)
     m_BLTitleL=(Up=(W=3,H=22),Down=(Y=22,W=3,H=22),Over=(Y=44,W=3,H=22),Disabled=(Y=66,W=3,H=22))
     m_BLTitleC=(Up=(X=3,W=2,H=22),Down=(X=3,Y=22,W=2,H=22),Over=(X=3,Y=44,W=2,H=22),Disabled=(X=3,Y=66,W=2,H=22))
     m_BLTitleR=(Up=(X=18,W=3,H=22),Down=(X=18,Y=22,W=3,H=22),Over=(X=18,Y=44,W=3,H=22),Disabled=(X=18,Y=66,W=3,H=22))
     m_PopupArrowUp=(X=87,Y=53,W=6,H=7)
     m_PopupArrowDown=(X=80,Y=53,W=6,H=7)
     m_stLapTopFrame=(TL=(W=256,H=32),t=(X=45,Y=32,W=211,H=32),TR=(X=167,Y=172,W=87,H=32),L=(X=63,Y=136,W=20,H=120),R=(Y=136,W=20,H=120),BL=(Y=64,W=256,H=36),B=(Y=100,W=256,H=36),BR=(X=126,Y=136,W=128,H=36),L2=(X=84,Y=136,W=20,H=120),R2=(X=21,Y=136,W=20,H=120),L3=(X=105,Y=136,W=20,H=120),R3=(X=42,Y=136,W=20,H=120),L4=(X=147,Y=172,W=20,H=52),R4=(X=126,Y=172,W=20,H=52))
     m_stLapTopFramePlus=(T1=(Y=32,W=38,H=32),T2=(W=24,H=32),T3=(X=39,Y=32,W=5,H=32),T4On=(X=45,W=19,H=32),T4Off=(X=25,W=19,H=32))
     m_NavBarBack(0)=(X=246,Y=157,W=4,H=37)
     m_NavBarBack(1)=(X=244,Y=120,W=12,H=37)
     m_NavBarBack(2)=(X=220,Y=41,W=8,H=41)
     m_NavBarBack(3)=(X=229,Y=41,W=10,H=41)
     m_NavBarBack(4)=(X=240,Y=41,W=15,H=41)
     m_NavBarBack(5)=(X=220,Y=82,W=14,H=41)
     m_NavBarBack(6)=(X=235,Y=82,W=12,H=41)
     m_NavBarBack(7)=(X=248,Y=82,W=6,H=41)
     m_NavBarBack(8)=(X=220,Y=123,W=9,H=41)
     m_NavBarBack(9)=(X=230,Y=123,W=10,H=41)
     m_NavBarBack(10)=(X=226,W=16,H=41)
     m_NavBarBack(11)=(X=226,Y=41,W=19,H=41)
     m_topLeftCornerR=(X=12,Y=56,W=6,H=8)
     m_RBAcceptCancel(0)=(Up=(X=11,W=19,H=13),Down=(X=11,Y=26,W=19,H=13),Over=(X=11,Y=13,W=19,H=13))
     m_RBAcceptCancel(1)=(Up=(X=30,W=19,H=13),Down=(X=30,Y=26,W=19,H=13),Over=(X=30,Y=13,W=19,H=13))
     m_RArrow(0)=(Up=(X=94,Y=47,W=10,H=7),Down=(X=94,Y=54,W=10,H=7),Over=(X=94,Y=47,W=10,H=7),Disabled=(X=94,Y=47,W=10,H=7))
     m_RArrow(1)=(Up=(X=104,Y=47,W=-10,H=7),Down=(X=104,Y=54,W=-10,H=7),Over=(X=104,Y=47,W=-10,H=7),Disabled=(X=104,Y=47,W=-10,H=7))
     m_SBScrollerActive=(X=64,Y=1,W=10,H=16)
     m_SBUpGear=(X=87,Y=30,W=11,H=8)
     m_SBDownGear=(X=87,Y=38,W=11,H=-8)
     m_RSquareBgLeft=(X=26,Y=40,W=4,H=17)
     m_RSquareBgMid=(X=30,Y=40,W=1,H=17)
     m_RSquareBgRight=(X=45,Y=40,W=4,H=17)
     m_iCloseBoxOffsetX=3
     m_iCloseBoxOffsetY=5
     m_iListHPadding=1
     m_iListVPadding=1
     m_iSize_ScrollBarFrameW=1
     m_iVScrollerWidth=9
     m_iScrollerOffset=1
     m_TButtonBackGround=Texture'R6MenuTextures.Gui_BoxScroll'
     m_SBUp=(Up=(W=11,H=8),Down=(Y=16,W=11,H=8),Over=(Y=8,W=11,H=8),Disabled=(Y=16,W=11,H=8))
     m_SBDown=(Up=(Y=8,W=11,H=-8),Down=(Y=24,W=11,H=-8),Over=(Y=16,W=11,H=-8),Disabled=(Y=24,W=11,H=-8))
     m_SBRight=(Up=(X=9,Y=25,W=-8,H=9),Down=(X=9,Y=43,W=-8,H=9),Over=(X=9,Y=34,W=-8,H=9),Disabled=(X=9,Y=34,W=-8,H=9))
     m_SBLeft=(Up=(X=1,Y=25,W=8,H=9),Down=(X=1,Y=43,W=8,H=9),Over=(X=1,Y=34,W=8,H=9),Disabled=(X=1,Y=34,W=8,H=9))
     m_SBBackground=(X=15,Y=28,W=14,H=4)
     m_SBVBorder=(X=64,Y=56,W=1,H=1)
     m_SBHBorder=(X=64,Y=56,W=1,H=1)
     m_SBScroller=(X=51,Y=1,W=10,H=16)
     m_CloseBoxUp=(X=82,Y=29,W=13,H=13)
     m_CloseBoxDown=(X=82,Y=16,W=13,H=13)
     m_RButtonBackGround=(X=12,Y=40,W=14,H=14)
     m_CBorder=(B=176,G=136,R=15)
     FrameTitleX=6
     FrameTitleY=4
     ColumnHeadingHeight=13
     EditBoxBevel=2
     Size_ComboHeight=12.000000
     Size_ComboButtonWidth=13.000000
     Size_ScrollbarWidth=13.000000
     Size_ScrollbarButtonHeight=12.000000
     Size_MinScrollbarHeight=6.000000
     Size_TabAreaHeight=15.000000
     Size_TabAreaOverhangHeight=2.000000
     Size_TabXOffset=1.000000
     Size_TabTextOffset=12.000000
     Pulldown_ItemHeight=15.000000
     Pulldown_VBorder=3.000000
     Pulldown_HBorder=3.000000
     Pulldown_TextBorder=9.000000
     FrameTL=(W=12,H=16)
     FrameT=(X=12,W=1,H=16)
     FrameTR=(X=116,W=12,H=16)
     FrameL=(Y=17,W=4,H=18)
     FrameR=(Y=17,W=4,H=18)
     FrameBL=(Y=126,W=4,H=2)
     FrameB=(X=2,Y=126,W=1,H=2)
     FrameBR=(X=124,Y=125,W=4,H=2)
     FrameActiveTitleColor=(B=255,G=255,R=255)
     FrameInactiveTitleColor=(B=255,G=255,R=255)
     BevelUpTL=(X=4,Y=16,W=2,H=2)
     BevelUpT=(X=10,Y=16,W=1,H=2)
     BevelUpTR=(X=18,Y=16,W=2,H=2)
     BevelUpL=(X=4,Y=20,W=2,H=1)
     BevelUpR=(X=18,Y=20,W=2,H=1)
     BevelUpBL=(X=4,Y=30,W=2,H=2)
     BevelUpB=(X=10,Y=30,W=1,H=2)
     BevelUpBR=(X=18,Y=30,W=2,H=2)
     BevelUpArea=(X=8,Y=20,W=1,H=1)
     MiscBevelTL(0)=(X=11,W=1,H=1)
     MiscBevelTL(1)=(X=11,W=1,H=1)
     MiscBevelTL(2)=(X=11,W=1,H=1)
     MiscBevelT(0)=(X=11,W=1,H=1)
     MiscBevelT(1)=(X=11,W=1,H=1)
     MiscBevelT(2)=(X=11,W=1,H=1)
     MiscBevelTR(0)=(X=11,W=1,H=1)
     MiscBevelTR(1)=(X=11,W=1,H=1)
     MiscBevelTR(2)=(X=11,W=1,H=1)
     MiscBevelL(0)=(X=11,W=1,H=1)
     MiscBevelL(1)=(X=11,W=1,H=1)
     MiscBevelL(2)=(X=11,W=1,H=1)
     MiscBevelR(0)=(X=11,W=1,H=1)
     MiscBevelR(1)=(X=11,W=1,H=1)
     MiscBevelR(2)=(X=11,W=1,H=1)
     MiscBevelBL(0)=(X=11,W=1,H=1)
     MiscBevelBL(1)=(X=11,W=1,H=1)
     MiscBevelBL(2)=(X=11,W=1,H=1)
     MiscBevelB(0)=(X=11,W=1,H=1)
     MiscBevelB(1)=(X=11,W=1,H=1)
     MiscBevelB(2)=(X=11,W=1,H=1)
     MiscBevelBR(0)=(X=11,W=1,H=1)
     MiscBevelBR(1)=(X=11,W=1,H=1)
     MiscBevelBR(2)=(X=11,W=1,H=1)
     MiscBevelArea(0)=(X=12,Y=1,W=1,H=1)
     MiscBevelArea(1)=(X=20,Y=16,W=1,H=1)
     MiscBevelArea(2)=(X=20,Y=16,W=1,H=1)
     ComboBtnUp=(Y=8,W=11,H=-8)
     ComboBtnDown=(Y=24,W=11,H=-8)
     ComboBtnDisabled=(Y=24,W=11,H=-8)
     ComboBtnOver=(Y=16,W=11,H=-8)
     HLine=(X=5,Y=78,W=1,H=2)
     EditBoxTextColor=(B=255,G=255,R=255)
     TabSelectedL=(Y=64,W=54,H=25)
     TabSelectedM=(X=41,Y=57,W=2,H=3)
     TabSelectedR=(X=54,Y=64,W=32,H=25)
     TabUnselectedL=(X=86,Y=64,W=54,H=25)
     TabUnselectedM=(X=60,Y=80,W=1,H=15)
     TabUnselectedR=(X=140,Y=64,W=32,H=25)
     TabBackground=(X=4,Y=7,W=1,H=1)
}
