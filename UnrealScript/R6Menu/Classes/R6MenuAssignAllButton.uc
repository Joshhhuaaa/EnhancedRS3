//=============================================================================
//  R6MenuAssignAllButton.uc : This button should assign it's associated item
//                              to all team members
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/15 * Created by Alexandre Dionne
//=============================================================================

class R6MenuAssignAllButton extends R6WindowButton;

var Color                       m_DisableColor;
var Color						m_EnableColor;

var BOOL						m_bDrawLeftBorder;			// draw the left broder
var BOOL						m_bDrawRightBorder;
var BOOL						m_bDrawTopBorder;
var BOOL						m_bDrawDownBorder;

function Created()
{
	m_DisableColor = Root.Colors.GrayLight;
	m_EnableColor  = Root.Colors.White;

	m_vButtonColor = m_DisableColor;
	m_BorderColor  = m_DisableColor;	

	m_bDrawBorders  = true;
	m_bDrawSimpleBorder = true;
}

function RMouseDown(float X, float Y) 
{
	bRMouseDown = True;
}

function MMouseDown(float X, float Y) 
{	
	bMMouseDown = True;
}

function LMouseDown(float X, float Y)
{
	bMouseDown = True;
} 


function DrawSimpleBorder(Canvas C)
{
    //Draw Buttons Contour
    C.Style = m_BorderStyle;

    C.SetDrawColor(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);

    //Top
	if (m_bDrawTopBorder)
	    DrawStretchedTextureSegment(C, 0, 0, WinWidth, m_BorderTextureRegion.H , m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
    //Bottom
	if (m_bDrawDownBorder)
		DrawStretchedTextureSegment(C, 0, WinHeight  - m_BorderTextureRegion.H, WinWidth, m_BorderTextureRegion.H , m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
    //Left
	if (m_bDrawLeftBorder)
	    DrawStretchedTextureSegment(C, 0, m_BorderTextureRegion.H, m_BorderTextureRegion.W, WinHeight - (2* m_BorderTextureRegion.H), m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
    //Right
	if (m_bDrawRightBorder)
		DrawStretchedTextureSegment(C, WinWidth - m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTextureRegion.W, WinHeight - (2* m_BorderTextureRegion.H), m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
}


//===========================================================
// SetButtonStatus: set the status of all the buttons, colors maybe change here too
//===========================================================
function SetButtonStatus( BOOL _bDisable)
{
	bDisabled = _bDisable;

    if (_bDisable)
        m_vButtonColor = m_DisableColor;
    else
        m_vButtonColor = m_EnableColor;
}


//=================================================================
// SetBorderColor: set the border color
//=================================================================
function SetBorderColor( Color _NewColor)
{
    m_BorderColor = _NewColor;    
}


function SetCompleteAssignAllButton()
{
	// draw all the borders
	m_bDrawLeftBorder  = true;	
	m_bDrawRightBorder = true;
	m_bDrawTopBorder   = true;
	m_bDrawDownBorder  = true;

    UpRegion		= NewRegion( 172, 0, 30, 13);
    OverRegion		= NewRegion( 172, 13, 30, 13);
    DownRegion		= NewRegion( 172, 26, 30, 13);
    DisabledRegion	= NewRegion( 172, 0, 30, 13);

    ImageX				= (WinWidth - UpRegion.W)/2;
	ImageY				= 0;
}

defaultproperties
{
     m_bDrawLeftBorder=True
     m_iDrawStyle=5
     bUseRegion=True
     UpTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     DownTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     DisabledTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     OverTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     UpRegion=(X=172,W=10,H=13)
     DownRegion=(X=172,Y=26,W=10,H=13)
     DisabledRegion=(X=172,W=10,H=13)
     OverRegion=(X=172,Y=13,W=10,H=13)
}
