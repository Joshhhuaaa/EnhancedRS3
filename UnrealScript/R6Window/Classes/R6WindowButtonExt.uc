//=============================================================================
//  R6WindowButtonExt.uc : This class give the following type of button... 
//						   DESC TEXT                 BOX desc BOX desc BOX desc
//						   minimum of 1 box and max of 3
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/09 * Created by Yannick Joly
//=============================================================================

class R6WindowButtonExt extends UWindowButton;

struct CheckBox
{
	var string	szText;
	var FLOAT	fXBoxPos;
	var bool    bSelected;
	var INT		iIndex;
};

/////// we can find this in the R6WindowLookAndFeel
var Texture         m_TButtonBG;                                // the texture button
var Region          m_RButtonBG;                                // the region of the button background
var Color           m_vBorder;                                  // the color of the button border
//////

var Texture         m_TDownTexture;

var Font            m_TextFont;                                 // the text font (only one text font for all the buttons)
var Color           m_vTextColor;                               // the text color (only one text color for all the buttons)

var CheckBox		m_stCheckBox[3];

var FLOAT           m_fTextWidth;
var FLOAT           m_fYTextPos;
var FLOAT           m_fXText;
var FLOAT           m_fYBox;

var INT				m_iNumberOfCheckBox;						// the number of check box for this button
var INT				m_iCurSelectedBox;
var INT				m_iCheckBoxOver;							// the check box over index

var bool            m_bOneTime;
var bool            m_bMouseIsOver;                             // to know if the mouse is on text or on the check box
var bool            m_bMouseOnButton;                           // to know is the mouse in on the window
var bool            m_bSelected;                                // true if the player selected the button

//*********************************
//      DISPLAY FUNCTIONS
//*********************************
function BeforePaint(Canvas C, FLOAT X, FLOAT Y)
{
	local FLOAT W, H;
    local FLOAT fWinWidth;

    local INT i;

    if (m_bOneTime)
    {
        m_bOneTime = false;

        if (Text != "")
        {
            C.Font = m_TextFont;

		    TextSize(C, Text, W, H);
	    
//            m_fTextWidth = W;  //this is for check range when you want to detect the mouse on the text
            m_fXText += 2;//m_fLMarge;		// start pos of the text for the button

            m_fYTextPos = (WinHeight - H) / 2;
    	    m_fYTextPos = FLOAT(INT(m_fYTextPos+0.5));
        }
    }
}

// draw all the button
function Paint( Canvas C, FLOAT X, FLOAT Y)
{
    local Color vTempColor;
	local INT i;
//    local bool bMouseOver;

	if (!bDisabled)
	{
		m_bMouseIsOver = MouseIsOver();
		if (m_bMouseIsOver)
			m_bMouseIsOver = CheckText_Box_Region();

		if (m_bMouseOnButton)
		{
			if(ToolTipString != "")
			{
				if (m_bMouseIsOver)
					ToolTip(ToolTipString);
				else
					ToolTip("");
			}
		}
	}

	DrawCheckBox( C, m_bMouseIsOver);

	if( Text != "")
	{
        C.Font = m_TextFont;
		C.SpaceX = 0;//m_fFontSpacing;		
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

		for ( i = 0; i < m_iNumberOfCheckBox ; i++)
		{
			ClipText(C, m_stCheckBox[i].fXBoxPos + m_RButtonBG.W + 2, m_fYTextPos, m_stCheckBox[i].szText, True); // 2 is the marge
		}
	}
}

function DrawCheckBox( Canvas C, bool _bMouseOverButton)
{
	local INT i;

	C.Style = ERenderStyle.STY_Alpha;

	if (bDisabled)
	{
		C.SetDrawColor(m_DisabledTextColor.R,m_DisabledTextColor.G,m_DisabledTextColor.B);
	}
	else if (_bMouseOverButton)
        C.SetDrawColor(m_OverTextColor.R, m_OverTextColor.G, m_OverTextColor.B);
    else
    	C.SetDrawColor(m_vBorder.R,m_vBorder.G,m_vBorder.B);

	for ( i = 0; i < m_iNumberOfCheckBox ; i++)
	{
		DrawStretchedTextureSegment( C, m_stCheckBox[i].fXBoxPos, m_fYBox, 
	                                 m_RButtonBG.W, m_RButtonBG.H, 
									 m_RButtonBG.X, m_RButtonBG.Y, m_RButtonBG.W, m_RButtonBG.H, m_TButtonBG );

		if(m_stCheckBox[i].bSelected)
		{
			DrawStretchedTextureSegment( C, 2 + m_stCheckBox[i].fXBoxPos , 2 + m_fYBox, 
	                                     DownRegion.W, DownRegion.H, 
										 DownRegion.X, DownRegion.Y, DownRegion.W, DownRegion.H, DownTexture );
	    }		
	}
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
    local FLOAT fX, fY;

    GetMouseXY( fX, fY);

    // check if you are over the text
   // if (InRange( fX, m_fXText, m_fXText + m_fTextWidth))
   //     return true;

    // check if you are over the check box
	for ( i = 0; i < m_iNumberOfCheckBox ; i++)
	{	
	    if (InRange( fX, m_stCheckBox[i].fXBoxPos, m_stCheckBox[i].fXBoxPos + m_RButtonBG.W))
		{
			m_iCheckBoxOver = i;
	        return true;			
		}
	}

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
function CreateTextAndBox( string _szText, string _szToolTip, FLOAT _fXText, INT _iButtonID, INT _iNumberOfCheckBox)
{
    Text		  = _szText;			// the name of the button
    ToolTipString = _szToolTip;			// the help text for the button
    m_fXText      = _fXText;			// the position of the text of the button
    m_iButtonID   = _iButtonID;			// the ID of the button

	m_iNumberOfCheckBox = _iNumberOfCheckBox;

    // center the box
    m_fYBox = (WinHeight - m_RButtonBG.H) / 2;
  	m_fYBox = FLOAT(INT(m_fYTextPos+0.5));
}

//=============================================================================
// SetButtonBox: Set the regular param for this type of button, 
// for other type add a enum or set the member variable invidually
//=============================================================================
function SetCheckBox( string _szText, FLOAT _fXBoxPos, bool _bSelected, INT _iIndex)
{
	m_stCheckBox[_iIndex].szText    = _szText;
	m_stCheckBox[_iIndex].fXBoxPos  = _fXBoxPos;
	m_stCheckBox[_iIndex].bSelected = _bSelected;

	if (_bSelected)
		m_iCurSelectedBox = _iIndex;

    m_TextFont = Root.Fonts[F_SmallTitle]; 
    m_vTextColor = Root.Colors.White;
    m_vBorder = Root.Colors.White;
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

//===============================================
// Change the check box status
//===============================================
function ChangeCheckBoxStatus()
{
	// we have to change the previous check box state before the new one if the selection box is different
	if (m_iCurSelectedBox !=  m_iCheckBoxOver)
	{
		m_stCheckBox[m_iCurSelectedBox].bSelected = false;
		m_stCheckBox[m_iCheckBoxOver].bSelected   = true;
		m_iCurSelectedBox = m_iCheckBoxOver;
	}

}

//===============================================
// SetCheckBoxStatus: Change the check box status depending the state in .ini 
//					  this function is specific, the selected state is store in int,
//					  so we have to switch to a bool before displaying it
//===============================================
function SetCheckBoxStatus( INT _iSelected)
{
	m_iCurSelectedBox = _iSelected;
	
	switch(_iSelected)
	{
		case 0:
			m_stCheckBox[0].bSelected = true;
			m_stCheckBox[1].bSelected = false;
			m_stCheckBox[2].bSelected = false;			
			break;
		case 1:
			m_stCheckBox[0].bSelected = false;
			m_stCheckBox[1].bSelected = true;
			m_stCheckBox[2].bSelected = false;
			break;
		case 2:
			m_stCheckBox[0].bSelected = false;
			m_stCheckBox[1].bSelected = false;
			m_stCheckBox[2].bSelected = true;
			break;
		default:
			break;
	}
}

//===============================================
// GetCheckBoxStatus: Return the selected button index 
//===============================================
function INT GetCheckBoxStatus()
{
	if (m_stCheckBox[0].bSelected)
		return 0;
	else if (m_stCheckBox[1].bSelected)
		return 1;
	else if (m_stCheckBox[2].bSelected)
		return 2;
}

































/*
var R6WindowButtonBox					m_pButtonBox1;
var R6WindowButtonBox					m_pButtonBox2;
var R6WindowButtonBox					m_pButtonBox3;
var R6WindowButtonBox					m_pCurrentSelection;

var R6WindowTextLabel					m_pTextLabel;

var UWindowDialogClientWindow			m_pParent;

function CreatedMultipleButtons( string _szButtonTitle, INT _iNumberOfButton)
{
    local FLOAT fXOffset, fYOffset, fYStep, fWidth, fHeight, fTemp, fSizeOfCounter;

	if ( _iNumberOfButton > 1 && _iNumberOfButton < 4)
	{
	    fXOffset = WinWidth * 0.5;
	    fYOffset = 0;
	    fWidth = fXOffset / _iNumberOfButton;
	    fHeight = 15;

		m_pTextLabel = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 0, 0, WinWidth, WinHeight, self));
		m_pTextLabel.SetProperties( _szButtonTitle, TA_LEFT, Root.Fonts[F_SmallTitle], White, false);

		m_pButtonBox1 = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
		m_pButtonBox1.SetButtonBox( true);
		m_pButtonBox1.CreateTextAndBox( "LOW",//Localize("Options","Opt_HudPlanning","R6Menu"), 
		                                "HELP TEXT LOW", 17,//Localize("Tip","Opt_HudPlanning","R6Menu"), 20, 
		                                0, true);	
		
		fXOffset = fXOffset + fWidth;
		if ( _iNumberOfButton > 1)
		{
		    m_pButtonBox2 = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
		    m_pButtonBox2.SetButtonBox( false);
		    m_pButtonBox2.CreateTextAndBox( "MEDIUM",//Localize("Options","Opt_HudPlanning","R6Menu"), 
		                                    "HELP TEXT MEDIUM", 17,//Localize("Tip","Opt_HudPlanning","R6Menu"), 20, 
		                                    0, true);	
		}

		fXOffset = fXOffset + fWidth;	
		if ( _iNumberOfButton > 2)
		{
		    m_pButtonBox3 = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
		    m_pButtonBox3.SetButtonBox( false);
		    m_pButtonBox3.CreateTextAndBox( "HIGH", //Localize("Options","Opt_HudPlanning","R6Menu"), 
		                                    "HELP TEXT HIGH", 17,//Localize("Tip","Opt_HudPlanning","R6Menu"), 20, 
		                                    0, true);	
		}

		m_pCurrentSelection = m_pButtonBox1;
	}
}


//=================================
//      DISPLAY FUNCTIONS
//=================================
function BeforePaint(Canvas C, FLOAT X, FLOAT Y)
{

}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{

}


/////////////////////////////////////////////////////////////////
// notify the parent window by using the appropriate parent function
/////////////////////////////////////////////////////////////////
function Notify(UWindowDialogControl C, byte E)
{
    log("Notify from class: "$C);
    log("Notify msg: "$E);
    
	if(E == DE_Click)
	{
        // Change Current Selected Button
        if ( C.IsA('R6WindowButtonBox'))
        {
            if (R6WindowButtonBox(C).GetSelectStatus())
            {
				m_pCurrentSelection.m_bSelected = !m_pCurrentSelection.m_bSelected; // change the boolean state
				m_pCurrentSelection = R6WindowButtonBox(C);

				if (m_pParent != None)
				{
					if (m_pParent.IsA('UWindowDialogClientWindow'))
						m_pParent.Notify( C, E);	
				}
//				else
//                R6WindowButtonBox(C).m_bSelected = !R6WindowButtonBox(C).m_bSelected; // change the boolean state
            }
        }
    }

}
*/

defaultproperties
{
     m_bOneTime=True
     m_TButtonBG=Texture'R6MenuTextures.Gui_BoxScroll'
     m_RButtonBG=(X=12,Y=40,W=14,H=14)
     m_vBorder=(B=176,G=136,R=15)
     m_vTextColor=(B=255,G=255,R=255)
     DownTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     DownRegion=(Y=52,W=10,H=10)
}
