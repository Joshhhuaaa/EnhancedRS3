//=============================================================================
//  R6WindowButtonBox.uc : This class create a window with differents buttons region that
//                         you can specify and return to the parent a msg when a region is click
//                         Possibility to have a text in front and a tooltip associate with it
//                         Is like : TEXT ...... CheckBox
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/09 * Created by Yannick Joly
//=============================================================================

class R6WindowButtonBox extends UWindowButton;

enum eButtonBoxType
{
    BBT_Normal,         // seleted or not
    BBT_DeathCam,       // previous button have to change state (DeathCamera: swap state between button sel)
    BBT_ResKit          // Button used for restriction kit menu
};

const C_fWIDTH_OF_MSG_BOX			= 90;						// the size of the msg box ex. EDIT

/////// we can find this in the R6WindowLookAndFeel
var Texture         m_TButtonBG;                                // the texture button
var Region          m_RButtonBG;                                // the region of the button background
var Color           m_vBorder;                                  // the color of the button border
//////

var Texture         m_TDownTexture;

var Font            m_TextFont;                                 // the text font (only one text font for all the buttons)
var Color           m_vTextColor;                               // the text color (only one text color for all the buttons)

var UWindowWindow	m_AdviceWindow;								// advice this window when a mouse wheel is down

var eButtonBoxType  m_eButtonType;                              // the type of the button

var string			m_szMsgBoxText;								// the message box text
var string          m_szMiscText;                               // use to store any information useful for treatment
var string			m_szToolTipWhenDisable;						// force to display a disable tooltip

var FLOAT           m_fYTextPos;
var FLOAT           m_fXText;
var FLOAT           m_fXBox;
var FLOAT           m_fYBox;
var FLOAT			m_fXMsgBoxText;
var FLOAT			m_fHMsgBoxText;
//var FLOAT           m_fWMsgBoxText;

var bool            m_bRefresh;
var bool            m_bMouseIsOver;                             // to know if the mouse is on text or on the check box
var bool            m_bMouseOnButton;                           // to know is the mouse in on the window
var bool            m_bSelected;                                // true if the player selected the button
var bool			m_bResizeToText;							// Resize the button to the box + text size
var bool			m_bAutomaticResizeFont;						// try smaller fonts when the text doesn't fit

//*********************************
//      DISPLAY FUNCTIONS
//*********************************
function BeforePaint(Canvas C, FLOAT X, FLOAT Y)
{
    local INT i;

    if (m_bRefresh)
    {
        m_bRefresh = false;

		if (m_szMsgBoxText != "")
		{
			m_fXMsgBoxText = AlignText( C, m_fXBox, C_fWIDTH_OF_MSG_BOX, m_szMsgBoxText, TA_Center);
		}

        if (Text != "")
        {
			m_fXText = AlignText( C, 0, WinWidth - m_RButtonBG.W, Text, TA_Left);
        }
    }
}

function FLOAT AlignText( Canvas C, FLOAT _fXStartPos, FLOAT _fWidth, out string _szTextToAlign, TextAlign _eTextAlign)
{
	local array<Font> ALowerFont;
	local string szTmpText;
	local FLOAT W, H;
    local FLOAT fXTemp;
	local FLOAT fLMarge, fDistBetBoxAndText;
	local INT i;

    fXTemp  = 0;
	fLMarge = 2;
	fDistBetBoxAndText = 4; // give space between box and text on a resize

	i = 0;
	ALowerFont[ALowerFont.Length] = m_TextFont;
	if (m_bAutomaticResizeFont)
	{
		ALowerFont[ALowerFont.Length] = Root.Fonts[F_VerySmallTitle];
		ALowerFont[ALowerFont.Length] = Root.Fonts[F_ListItemSmall];
	}

	// use the first font that fits
	while (i < ALowerFont.Length)
	{
		C.Font = ALowerFont[i];
		szTmpText = TextSize(C, _szTextToAlign, W, H, _fWidth);
		TextSize(C, _szTextToAlign, W, H);
		if (szTmpText != _szTextToAlign)
			i++;
		else
		{
			m_TextFont = ALowerFont[i];
			break;
		}
	}

#ifdefDEBUG
	if (szTmpText != _szTextToAlign)
		log("The text"@_szTextToAlign@"is too long by"@(W - _fWidth)@"pixels");
#endif

	if (_szTextToAlign ==m_szMsgBoxText)
		m_fHMsgBoxText = H;
	    
	switch(_eTextAlign)
	{
		case TA_Left:
			if (m_fXBox == 0) // the text is after the box
				fXTemp = m_RButtonBG.W + _fXStartPos + fLMarge;
			else
				fXTemp = _fXStartPos + fLMarge;
			break;
//		case TA_Right:
//			break;
		case TA_Center:
			fXTemp = _fXStartPos + (_fWidth - W) / 2;
			break;            
    }

    m_fYTextPos = (WinHeight - H) / 2;
  	m_fYTextPos = FLOAT(INT(m_fYTextPos+0.5));

	if( m_bResizeToText)
	{
		// put the text at the begginning -- it's an alignement to the left by default
		WinWidth = m_RButtonBG.W + _fXStartPos + fLMarge + W + fDistBetBoxAndText;
		if (m_fXBox != 0)
			m_fXBox = WinWidth - m_RButtonBG.W;
	}
	else
		_szTextToAlign = szTmpText;

	return fXTemp;
}


// draw all the button
function Paint( Canvas C, FLOAT X, FLOAT Y)
{
    local Color vTempColor;
//    local bool bMouseOver;

	if ((!bDisabled) || (m_szToolTipWhenDisable != ""))
	{
		m_bMouseIsOver = MouseIsOver();
//#ifdefDEBUG
//		if (m_bMouseIsOver)
//			m_bMouseIsOver = CheckText_Box_Region();
//#endif
		if (m_bMouseOnButton)
		{
			if (bDisabled)
				ToolTipString = m_szToolTipWhenDisable;

			if(ToolTipString != "")
			{
				if (m_bMouseIsOver)
					ToolTip(ToolTipString);
				else
					ToolTip("");
			}
		}
	}

    if ( m_eButtonType == BBT_Normal )
		DrawCheckBox( C, m_fXBox, m_fYBox, m_bMouseIsOver);
    else if ( m_eButtonType == BBT_ResKit )
        DrawResKitBotton( C, m_fXBox, m_fYBox, m_bMouseIsOver );

	if( Text != "")
	{
//		tempSpace = C.SpaceX;
        C.Font = m_TextFont;
		C.SpaceX = 0;//m_fFontSpacing;		
//        C.Style =m_TextDrawstyle;
        vTempColor = m_vTextColor;

		if (bDisabled)
		{
			C.SetDrawColor(m_DisabledTextColor.R,m_DisabledTextColor.G,m_DisabledTextColor.B);
		}
		else if(m_bMouseIsOver) 
        {
            vTempColor = m_OverTextColor;
    	    C.SetDrawColor(m_OverTextColor.R, m_OverTextColor.G, m_OverTextColor.B);		
        }
		else
        {
            if (vTempColor != m_vTextColor)
            {
                vTempColor = m_vTextColor;
    			C.SetDrawColor(m_vTextColor.R,m_vTextColor.G,m_vTextColor.B);
            }
        }

    	ClipText(C, m_fXText, m_fYTextPos, Text, True); // 2 is the marge
	}
}

function DrawCheckBox( Canvas C, FLOAT _fXBox, FLOAT _fYBox, bool _bMouseOverButton)
{

	C.Style = ERenderStyle.STY_Alpha;

	if (bDisabled)
	{
		C.SetDrawColor(m_DisabledTextColor.R,m_DisabledTextColor.G,m_DisabledTextColor.B);
	}
	else if (_bMouseOverButton)
        C.SetDrawColor(m_OverTextColor.R, m_OverTextColor.G, m_OverTextColor.B);
    else
    	C.SetDrawColor(m_vBorder.R,m_vBorder.G,m_vBorder.B);

	DrawStretchedTextureSegment( C, _fXBox, _fYBox, 
                                    m_RButtonBG.W, m_RButtonBG.H, 
									m_RButtonBG.X, m_RButtonBG.Y, m_RButtonBG.W, m_RButtonBG.H, m_TButtonBG );

	if(m_bSelected)
	{
		DrawStretchedTextureSegment( C, 2 + _fXBox , 2 + _fYBox, 
                                     DownRegion.W, DownRegion.H, 
									 DownRegion.X, DownRegion.Y, DownRegion.W, DownRegion.H, DownTexture );
    }
}

function DrawResKitBotton( Canvas C, FLOAT _fXBox, FLOAT _fYBox, bool _bMouseOverButton)
{
	local FLOAT fYLineTop, fYLineBottom;

	C.Style = ERenderStyle.STY_Alpha;
    C.Font = m_TextFont;

	if (bDisabled)
	{
		C.SetDrawColor(m_DisabledTextColor.R,m_DisabledTextColor.G,m_DisabledTextColor.B);
	}
    else if (_bMouseOverButton)
        C.SetDrawColor(m_OverTextColor.R, m_OverTextColor.G, m_OverTextColor.B);
    else
    	C.SetDrawColor(m_vBorder.R,m_vBorder.G,m_vBorder.B);

	// draw the border m_fHMsgBoxText
	fYLineTop	 = m_fYTextPos;
	fYLineBottom = m_fYTextPos + m_fHMsgBoxText - 2;

    //Top
    DrawStretchedTextureSegment(C, _fXBox, fYLineTop, WinWidth - _fXBox, m_BorderTextureRegion.H , m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
    //Bottom
    DrawStretchedTextureSegment(C, _fXBox, fYLineBottom, WinWidth - _fXBox, m_BorderTextureRegion.H , m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
    //Left
    DrawStretchedTextureSegment(C, _fXBox, fYLineTop, m_BorderTextureRegion.W, m_fHMsgBoxText - 2, m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
    //Right
    DrawStretchedTextureSegment(C, _fXBox + C_fWIDTH_OF_MSG_BOX - m_BorderTextureRegion.W, fYLineTop, m_BorderTextureRegion.W, m_fHMsgBoxText - 2, m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);

	// draw the text inside
   	ClipText(C, m_fXMsgBoxText, m_fYTextPos, m_szMsgBoxText, True); 



}
//*********************************
//      MOUSE FUNCTIONS OVERLOADED
//*********************************
// Why overwrite this 2 functions, because the tooltip have to be on the text or the check box only
// not on all the window. We force it in Paint()
// overwrite uwindowwindow fct
function MouseEnter()
{
    m_bMouseOnButton = true;;
}

// overwrite uwindowwindow fct
function MouseLeave()
{
//    log("MouseLeave");
    Super.MouseLeave();
    m_bMouseOnButton = false;
}

//*********************************
//      CHECK 
//*********************************
function bool CheckText_Box_Region()
{
    local INT i;
    local FLOAT fX, fY, fMin, fMax;

    GetMouseXY( fX, fY);

	fMin = m_fXBox;
	
    if ( m_eButtonType == BBT_Normal )
	{
		fMax = m_fXBox + m_RButtonBG.W;
	}
    else if ( m_eButtonType == BBT_ResKit )
	{
		fMax = m_fXBox + C_fWIDTH_OF_MSG_BOX;
	}

    // check if you are over the text
   // if (InRange( fX, m_fXText, m_fXText + m_fTextWidth))
   //     return true;

    // check if you are over the check box
    if (InRange( fX, m_fXBox, fMax))
        return true;

    return false;
}

function bool InRange( FLOAT _fTestValue, FLOAT _fMin, FLOAT _fMax)
{
    if ( _fTestValue > _fMin )
        if ( _fTestValue < _fMax)
            return true;

    return false;
}


//*********************************
//      Create the button 
//*********************************
function CreateTextAndBox( string _szText, string _szToolTip, FLOAT _fXText, INT _iButtonID, optional bool _bTextAfterBox, optional bool _bUseAutomaticResizeFont)
{
    Text = _szText; 
    ToolTipString = _szToolTip;
    m_fXText = _fXText;
    m_iButtonID = _iButtonID;

	if (_bTextAfterBox)
		m_fXBox = 0; // the check box was at the beginning	
	else
	    m_fXBox = WinWidth - m_RButtonBG.W; // suppose that the box is always at the end of window

    // center the box
    m_fYBox = (WinHeight - m_RButtonBG.H) / 2;
  	m_fYBox = FLOAT(INT(m_fYBox+0.5));
	m_bAutomaticResizeFont = _bUseAutomaticResizeFont;
}

function CreateTextAndMsgBox( string _szText, string _szToolTip, string _szTextBox, FLOAT _fXText, INT _iButtonID)
{
    Text = _szText; 
    ToolTipString = _szToolTip;
    m_fXText = _fXText;
    m_iButtonID = _iButtonID;

//	if ( _iButtonID == eButtonBoxType.BBT_ResKit)
//	{
	    m_fXBox = WinWidth - C_fWIDTH_OF_MSG_BOX; // suppose that the box is always at the end of window, 30 is size of the msg Box
//	}

	ModifyMsgBox(_szTextBox);

    // center the box
	m_fYBox = 0;
//    m_fYBox = WinHeight / 2;
//    m_fYBox = FLOAT(INT(m_fYTextPos+0.5));
}

//=============================================================================
// ModifyMsgBox: Modify the text inside the msg box depending if you're are in-game or not
//=============================================================================
function ModifyMsgBox( string _szTextBox)
{
	m_szMsgBoxText = _szTextBox;
	m_bRefresh = true;
}

//=============================================================================
// SetButtonBox: Set the regular param for this type of button, 
// for other type add a enum or set the member variable invidually
//=============================================================================
function SetButtonBox( bool _bSelected)
{
    m_TextFont = Root.Fonts[F_SmallTitle]; 
    m_vTextColor = Root.Colors.White;
    m_vBorder = Root.Colors.White;
    m_bSelected = _bSelected; 
}

//===============================================================
// SetNewWidth: set the new width of the button
//===============================================================
function SetNewWidth( FLOAT _fWidth)
{
	WinWidth = _fWidth;
	m_fXBox  = _fWidth - m_RButtonBG.W; // suppose that the box is always at the end of window

	m_bRefresh = true;
}


//*********************************
//      Get the selected status (change where you create the button by Notify)
//*********************************
function bool GetSelectStatus()
{
//    log("m_bMouseOnButton: "$m_bMouseOnButton);
//    log("m_bMouseIsOver: "$m_bMouseIsOver);
    if (bDisabled)
        return false;

    if (m_bMouseOnButton && m_bMouseIsOver)
        return true;

    return false;
}


simulated function Click(float X, float Y) 
{
    if(bDisabled)
        return;

	if (GetSelectStatus())
	{
		if (m_bPlayButtonSnd && DownSound != None)
        {
            GetPlayerOwner().PlaySound(DownSound, SLOT_Menu);
            if (m_bWaitSoundFinish)
            {
                m_bSoundStart = true;
                return;
            }
        }

        Notify(DE_Click);
	}
}

//=======================================================================================
// MouseWheelDown: advice a window of your choice for mouse wheel down
//=======================================================================================
function MouseWheelDown(FLOAT X, FLOAT Y)
{
	if (m_AdviceWindow != None)
	{
		m_AdviceWindow.MouseWheelDown(X, Y);
	}
}

//=======================================================================================
// MouseWheelUp: advice a window of your choice for mouse wheel up
//=======================================================================================
function MouseWheelUp(FLOAT X, FLOAT Y)
{
	if (m_AdviceWindow != None)
	{
		m_AdviceWindow.MouseWheelUp(X, Y);
	}
}

defaultproperties
{
     m_bRefresh=True
     m_TButtonBG=Texture'R6MenuTextures.Gui_BoxScroll'
     m_RButtonBG=(X=12,Y=40,W=14,H=14)
     m_vBorder=(B=176,G=136,R=15)
     m_vTextColor=(B=255,G=255,R=255)
     DownTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     DownRegion=(Y=52,W=10,H=10)
}
