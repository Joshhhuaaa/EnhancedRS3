//=============================================================================
//  R6WindowSimpleFramedWindow.uc : This provides a simple frame for a window
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/04 * Created by Yannick Joly
//=============================================================================


class R6WindowSimpleFramedWindowExt extends UWindowWindow;

enum eBorderType     // the type of the border you want 
{
    Border_Top,
    Border_Bottom,
    Border_Left,
    Border_Right 
};

var enum eCornerType // To draw some corners
{
	No_Corners,
    Top_Corners,
	Bottom_Corners,       
	All_Corners
} m_eCornerType;

struct stBorderForm
{
    var color   vColor;
    var FLOAT   fXPos;
    var FLOAT   fYPos;
    var FLOAT   fWidth;
    var bool    bActive;
//    var bool    bBorderSet;
};

var Texture         m_BGTexture;		                    // Put = None when no background is needed
var Texture         m_HBorderTexture, m_VBorderTexture;
var Texture         m_topLeftCornerT;
var Region          m_BGTextureRegion;                      // the background texture region
var Region          m_HBorderTextureRegion, 
                    m_VBorderTextureRegion;
var Region	        m_topLeftCornerR;

var stBorderForm    m_sBorderForm[4];                       // 0 = top ; 1 = down ; 2 = Left ; 3 = Right
var Color           m_eCornerColor[4];
var Color           m_vBGColor;                             // the back ground color, default black

var FLOAT           m_fHBorderHeight, m_fVBorderWidth;      // Border size
//////////////////////////////
//Please make sure you set the Padding correctly if you use the offsets values
//////////////////////////////
var FLOAT           m_fHBorderPadding, m_fVBorderPadding;   // Allow the borders not to start in corners
				    								        // to let for instance a space of 1 pixel
				    								        // between a corner and the begining of the border	
   
var FLOAT           m_fHBorderOffset, m_fVBorderOffset;     // Border offset if you want the borders to 
				    								        // Offsetted form the window limits
				    								        // The VOffset is for the side borders

var INT             m_DrawStyle;

var bool            m_bNoBorderToDraw;
var bool            m_bDrawBackGround;

//This is to create the window that needs the frame
var class<UWindowWindow>    m_ClientClass;
var UWindowWindow           m_ClientArea;

// default initialisation
// we have to set after the create window the parameters you want
function Created()
{
    local INT i;

    // by default you see no border
    for ( i = 0 ; i < 4; i++)
    {
        m_sBorderForm[i].vColor = Root.Colors.BlueLight;
        m_sBorderForm[i].fXPos = 0;
        m_sBorderForm[i].fYPos = 0;
        m_sBorderForm[i].fWidth = 1;
        m_sBorderForm[i].bActive = false;
    }

    /*
    for ( i = 0 ; i < 4; i++)
    {
        if ( !m_sBorderForm[i].bBorderSet)
        {

            m_sBorderForm[i].vColor = BlueLight;
            m_sBorderForm[i].bActive = false;

            if ( i < 2)
            {
                m_sBorderForm[i].fWidth   = m_fHBorderHeight;
            }
            else
            {
                m_sBorderForm[i].fWidth   = m_fVBorderWidth;
            }
        }
    }
    */

    m_eCornerColor[eCornerType.All_Corners]    = Root.Colors.BlueLight;
    m_eCornerColor[eCornerType.Top_Corners]    = Root.Colors.BlueLight;
    m_eCornerColor[eCornerType.Bottom_Corners] = Root.Colors.BlueLight;
}

//Just Pass any Control to this function to get it to show in the frame
function CreateClientWindow( class<UWindowWindow> clientClass)
{
	m_ClientClass = clientClass;
    /*
	m_ClientArea = CreateWindow(m_ClientClass, m_fVBorderWidth + m_fVBorderOffset, m_fHBorderHeight +m_fHBorderOffset, 
										WinWidth - ( 2* m_fVBorderWidth) - ( 2* m_fVBorderOffset), 
										WinHeight -  (2* m_fHBorderHeight) - ( 2* m_fHBorderOffset), OwnerWindow);   
                                        */
    m_ClientArea = CreateWindow(m_ClientClass, 0, 0, WinWidth, WinHeight, OwnerWindow);
}

function Paint(Canvas C, float X, float Y)
{
 
    if(m_bDrawBackGround)
	{
	    C.Style = m_DrawStyle;

        C.SetDrawColor(m_vBGColor.R, m_vBGColor.G, m_vBGColor.B);

		// 1 in Y, the background is not paint over the border... eventually replace it by a var. Shoud change X too?
        DrawStretchedTextureSegment( C, 0, 1, WinWidth, WinHeight - 1, 
                                        m_BGTextureRegion.X, m_BGTextureRegion.Y, m_BGTextureRegion.W, m_BGTextureRegion.H, m_BGTexture );
	}
}

function AfterPaint(Canvas C, float X, float Y)
{	
    local Color vBorderColor, 
                vCornerColor;

    C.Style = m_DrawStyle;
    vBorderColor = Root.Colors.BlueLight;
    C.SetDrawColor(vBorderColor.R, vBorderColor.G, vBorderColor.B);

//	if(m_HBorderTexture != NONE)
//	{
        if (m_sBorderForm[eBorderType.Border_Top].bActive)
        {
            if (m_sBorderForm[eBorderType.Border_Top].vColor != vBorderColor)
            {
                vBorderColor = m_sBorderForm[eBorderType.Border_Top].vColor;
                C.SetDrawColor(vBorderColor.R, vBorderColor.G, vBorderColor.B);
            }

		    //top
		    DrawStretchedTextureSegment( C, m_sBorderForm[eBorderType.Border_Top].fXPos, 
                                            m_sBorderForm[eBorderType.Border_Top].fYPos, 
                                            WinWidth  - (2* m_sBorderForm[eBorderType.Border_Top].fXPos), m_sBorderForm[eBorderType.Border_Top].fWidth, 
                                            m_HBorderTextureRegion.X, m_HBorderTextureRegion.Y, m_HBorderTextureRegion.W, m_HBorderTextureRegion.H, m_HBorderTexture );
        }

        if (m_sBorderForm[eBorderType.Border_Bottom].bActive)
        {
            if (m_sBorderForm[eBorderType.Border_Bottom].vColor != vBorderColor)
            {
                vBorderColor = m_sBorderForm[eBorderType.Border_Bottom].vColor;
                C.SetDrawColor(vBorderColor.R, vBorderColor.G, vBorderColor.B);
            }

		    //Bottom
		    DrawStretchedTextureSegment( C, m_sBorderForm[eBorderType.Border_Bottom].fXPos, 
                                            WinHeight - m_sBorderForm[eBorderType.Border_Bottom].fWidth - m_sBorderForm[eBorderType.Border_Bottom].fYPos, 
    									    WinWidth - (2* m_sBorderForm[eBorderType.Border_Bottom].fXPos), m_sBorderForm[eBorderType.Border_Bottom].fWidth, 
                                            m_HBorderTextureRegion.X, m_HBorderTextureRegion.Y, m_HBorderTextureRegion.W, m_HBorderTextureRegion.H, m_HBorderTexture );
        }
//	}

//	if(m_VBorderTexture != NONE)
//	{
        if (m_sBorderForm[eBorderType.Border_Left].bActive)
        {
            if (m_sBorderForm[eBorderType.Border_Left].vColor != vBorderColor)
            {
                vBorderColor = m_sBorderForm[eBorderType.Border_Left].vColor;
                C.SetDrawColor(vBorderColor.R, vBorderColor.G, vBorderColor.B);
            }

		    //Left
		    DrawStretchedTextureSegment( C, m_sBorderForm[eBorderType.Border_Left].fXPos, 
                                            m_sBorderForm[eBorderType.Border_Left].fYPos, 
                                            m_sBorderForm[eBorderType.Border_Left].fWidth, WinHeight - (2 * m_sBorderForm[eBorderType.Border_Left].fYPos), 
                                            m_VBorderTextureRegion.X, m_VBorderTextureRegion.Y, m_VBorderTextureRegion.W, m_VBorderTextureRegion.H, m_VBorderTexture );
        }

        if (m_sBorderForm[eBorderType.Border_Right].bActive)
        {
            if (m_sBorderForm[eBorderType.Border_Right].vColor != vBorderColor)
            {
                vBorderColor = m_sBorderForm[eBorderType.Border_Right].vColor;
                C.SetDrawColor(vBorderColor.R, vBorderColor.G, vBorderColor.B);
            }

		    //Right
		    DrawStretchedTextureSegment( C, WinWidth - m_sBorderForm[eBorderType.Border_Right].fWidth - m_sBorderForm[eBorderType.Border_Right].fXPos, 
                                            m_sBorderForm[eBorderType.Border_Right].fYPos, 
                                            m_sBorderForm[eBorderType.Border_Right].fWidth, WinHeight  - (2 * m_sBorderForm[eBorderType.Border_Right].fYPos), 
										    m_VBorderTextureRegion.X, m_VBorderTextureRegion.Y, m_VBorderTextureRegion.W, m_VBorderTextureRegion.H, m_VBorderTexture );
        }
//	}

    vCornerColor = Root.Colors.BlueLight;
    // set the corner the same color than the border ???
    if (m_eCornerType != No_Corners)
    {
	    switch(m_eCornerType)
	    {
            case All_Corners:
                if (m_eCornerColor[eCornerType.All_Corners] != vCornerColor)
                {
                    vCornerColor = m_eCornerColor[eCornerType.All_Corners];
                    C.SetDrawColor(vCornerColor.R, vCornerColor.G, vCornerColor.B);
                }
		    case Top_Corners:
			    //Corners
                if (m_eCornerColor[eCornerType.Top_Corners] != vCornerColor)
                {
                    vCornerColor = m_eCornerColor[eCornerType.Top_Corners];
                    C.SetDrawColor(vCornerColor.R, vCornerColor.G, vCornerColor.B);
                }

			    if(m_topLeftCornerT != NONE)
			    {
				    DrawStretchedTextureSegment(C, 0, 0, 
                                                   m_topLeftCornerR.W, m_topLeftCornerR.H, 
                                                   m_topLeftCornerR.X, m_topLeftCornerR.Y, m_topLeftCornerR.W, m_topLeftCornerR.H, m_topLeftCornerT);		
				    DrawStretchedTextureSegment(C, WinWidth - m_topLeftCornerR.W, 0, 
                                                   m_topLeftCornerR.W, m_topLeftCornerR.H, 
                                                   m_topLeftCornerR.X + m_topLeftCornerR.W, m_topLeftCornerR.Y, -m_topLeftCornerR.W, m_topLeftCornerR.H, m_topLeftCornerT);
			    }

                if (m_eCornerType!=All_Corners) break;
		    case Bottom_Corners:
			    //Corners
                if (m_eCornerColor[eCornerType.Bottom_Corners] != vCornerColor)
                {
                    vCornerColor = m_eCornerColor[eCornerType.Bottom_Corners];
                    C.SetDrawColor(vCornerColor.R, vCornerColor.G, vCornerColor.B);
                }

			    if(m_topLeftCornerT != NONE)
			    {
				    DrawStretchedTextureSegment(C, 0, WinHeight -  m_topLeftCornerR.H, 
                                                   m_topLeftCornerR.W, m_topLeftCornerR.H, m_topLeftCornerR.X, 
  											       m_topLeftCornerR.Y + m_topLeftCornerR.H, m_topLeftCornerR.W, -m_topLeftCornerR.H, m_topLeftCornerT);		
				    DrawStretchedTextureSegment(C, WinWidth - m_topLeftCornerR.W, WinHeight -  m_topLeftCornerR.H, 
                                                   m_topLeftCornerR.W, m_topLeftCornerR.H, 
                                                   m_topLeftCornerR.X + m_topLeftCornerR.W, m_topLeftCornerR.Y + m_topLeftCornerR.H, -m_topLeftCornerR.W, -m_topLeftCornerR.H, m_topLeftCornerT);
			    }
			    break;
            default:
                break;
	    }
    }
}

function SetBorderParam( INT _iBorderType, FLOAT _X, FLOAT _Y, FLOAT _fWidth, COLOR _vColor)
{
    m_sBorderForm[_iBorderType].fXPos      = _X;
    m_sBorderForm[_iBorderType].fYPos      = _Y;
    m_sBorderForm[_iBorderType].vColor     = _vColor;
    m_sBorderForm[_iBorderType].fWidth     = _fWidth;
    m_sBorderForm[_iBorderType].bActive    = true;

    m_bNoBorderToDraw = false;
}

// active border or not
function ActiveBorder( INT _iBorderType, bool _Active)
{
    local INT i;
    local bool bNoBorderToDraw;

    m_sBorderForm[_iBorderType].bActive = _Active;

    bNoBorderToDraw = true;
    for ( i = 0 ; i < 4; i++)
    {
        if (m_sBorderForm[i].bActive)
        {
            bNoBorderToDraw = false;
        }
    }

    m_bNoBorderToDraw = bNoBorderToDraw;
}

function SetNoBorder()
{
    m_bNoBorderToDraw = true;
}

function ActiveBackGround( bool _bActivate, Color _vBGColor)
{
    m_bDrawBackGround = _bActivate;
    m_vBGColor = _vBGColor;
}

// set the corner color
function SetCornerColor( INT _iCornerType, Color _Color)
{
    // fix a bug where when you have a All_Corners, 
    // in the switch in paint, the color is erase by bottom and top color (all corners use the draw of top and bottom)
    if ( _iCornerType == eCornerType.All_Corners)
    {
        m_eCornerColor[eCornerType.Top_Corners] = _Color;
        m_eCornerColor[eCornerType.Bottom_Corners] = _Color;
    }

    m_eCornerColor[_iCornerType] = _Color;
}

// verify if you at least one border to draw
function bool GetActivateBorder()
{
    return m_bNoBorderToDraw;
}

defaultproperties
{
     m_DrawStyle=5
     m_fHBorderHeight=2.000000
     m_fVBorderWidth=2.000000
     m_fHBorderPadding=7.000000
     m_fVBorderPadding=2.000000
     m_fVBorderOffset=1.000000
     m_BGTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     m_HBorderTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     m_VBorderTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     m_topLeftCornerT=Texture'R6MenuTextures.Gui_BoxScroll'
     m_ClientClass=Class'UWindow.UWindowClientWindow'
     m_BGTextureRegion=(X=77,Y=31,W=8,H=8)
     m_HBorderTextureRegion=(X=64,Y=56,W=1,H=1)
     m_VBorderTextureRegion=(X=64,Y=56,W=1,H=1)
     m_topLeftCornerR=(X=12,Y=56,W=6,H=8)
}
