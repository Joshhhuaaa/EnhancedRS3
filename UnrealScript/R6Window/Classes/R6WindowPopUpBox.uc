//=============================================================================
//  R6WindowPopUpBox.uc : This provides the simple frame for all the pop-up window
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/04 * Created by Yannick Joly
//=============================================================================

class R6WindowPopUpBox extends UWindowWindow;

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
    var FLOAT   fHeight;
    var bool    bActive;
//    var bool    bBorderSet;
};

const C_fTITLE_TIME_OFFSET	  = 10;

const K_FBUTTON_HEIGHT_REGION = 25;

//const K_BORDER_HOR_OFF        = 10;    // Offset between border and text in the horizontal
const K_BORDER_HOR_OFF          = 1;     //CHANGED BY ALEX
const K_BORDER_VER_OFF          = 1;     

var Texture                 m_BGTexture;		                    // Put = None when no background is needed
var Texture                 m_HBorderTexture, m_VBorderTexture;
var Texture                 m_topLeftCornerT;
var Region                  m_BGTextureRegion;                      // the background texture region
var Region                  m_HBorderTextureRegion, 
                            m_VBorderTextureRegion;
var Region	                m_topLeftCornerR;
var Region                  m_RWindowBorder;
var Region                  SimpleBorderRegion;


var stBorderForm            m_sBorderForm[4];                       // 0 = top ; 1 = down ; 2 = Left ; 3 = Right
var Color                   m_eCornerColor[4];
var Color                   m_vFullBGColor;                         // the full back ground color
var Color                   m_vClientAreaColor;                     // inside the frame pop-up -- include the header

var FLOAT                   m_fHBorderHeight, m_fVBorderWidth;      // Border size
//////////////////////////////
//Please make sure you set the Padding correctly if you use the offsets values
//////////////////////////////
var FLOAT                   m_fHBorderPadding, m_fVBorderPadding;   // Allow the borders not to start in corners
				    												// to let for instance a space of 1 pixel
				    												// between a corner and the begining of the border	
   
var FLOAT                   m_fHBorderOffset, m_fVBorderOffset;     // Border offset if you want the borders to 
				    												// Offsetted form the window limits
				    												// The VOffset is for the side borders

var EPopUpID				m_ePopUpID;

var INT                     m_DrawStyle;
var INT						m_iPopUpButtonsType;

var BOOL                    m_bNoBorderToDraw;
var BOOL                    m_bBGFullScreen;                        // true if you want the bck for all the screen, false the bck is only for the pop up size
var BOOL                    m_bBGClientArea;                        // true, draw client area and header background
var BOOL					m_bDetectKey;							// detect escape and enter key
var BOOL					m_bForceButtonLine;						// force to draw the button line
var BOOL					m_bDisablePopUpActive;					// the disable pop-up button is there
var BOOL					m_bPopUpLock;							// if true, popup will not close, only hidewindow will close it
var BOOL                    m_bTextWindowOnly;
var BOOL					m_bResizePopUpOnTextLabel;
var BOOL					m_bHideAllChild;

//This is to create the window that needs the frame
var class<UWindowWindow>    m_ClientClass;
var UWindowWindow           m_ClientArea;
var UWindowWindow           m_ButClientArea;
var R6WindowTextLabelExt    m_pTextLabel;

var MessageBoxResult        Result;
var MessageBoxResult        DefaultResult;


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

    m_eCornerColor[eCornerType.All_Corners]    = Root.Colors.White;
    m_eCornerColor[eCornerType.Top_Corners]    = Root.Colors.White;
    m_eCornerColor[eCornerType.Bottom_Corners] = Root.Colors.White;
   
    m_vFullBGColor = Root.Colors.m_cBGPopUpContour;
    m_vClientAreaColor = Root.Colors.m_cBGPopUpWindow;

    m_ClientArea = None;
}

//Just Pass any Control to this function to get it to show in the frame
function CreateClientWindow( class<UWindowWindow> clientClass, optional bool _bButtonBar, optional bool _bDrawClientOnBorder)
{
	m_ClientClass = clientClass;

    // we have to create the window bar button and the "empty" window inside the frame border pop up window
    if (_bButtonBar)
    {
        m_ButClientArea = CreateWindow(m_ClientClass, m_RWindowBorder.X, m_RWindowBorder.Y + m_RWindowBorder.H - K_FBUTTON_HEIGHT_REGION, m_RWindowBorder.W, K_FBUTTON_HEIGHT_REGION, OwnerWindow);
    }
    else
    {
		if (_bDrawClientOnBorder)
		{
			m_ClientArea = CreateWindow(m_ClientClass, m_RWindowBorder.X + K_BORDER_HOR_OFF, 
										m_RWindowBorder.Y - K_BORDER_VER_OFF, m_RWindowBorder.W - (2 * K_BORDER_HOR_OFF), 
										m_RWindowBorder.H + (2 * K_BORDER_VER_OFF) - K_FBUTTON_HEIGHT_REGION, OwnerWindow);
		}
		else
		{
			m_ClientArea = CreateWindow(m_ClientClass, m_RWindowBorder.X + K_BORDER_HOR_OFF + 1, 
										m_RWindowBorder.Y, m_RWindowBorder.W - (2 * K_BORDER_HOR_OFF) - 1, 
										m_RWindowBorder.H - K_FBUTTON_HEIGHT_REGION, OwnerWindow);
		}
    }
}

function BeforePaint(Canvas C, FLOAT X, FLOAT Y)
{
	local FLOAT W, H, XOff;
	local FLOAT fWinWidth;
	local string _szTitleText;
	local FLOAT _TextHeight, _X, _Y, _fWidth, _fHeight;

	if ( m_pTextLabel!= None)
	{
		C.Font = Root.Fonts[F_PopUpTitle];
		_szTitleText = m_pTextLabel.GetTextLabel(0);
		TextSize(C, "  "$_szTitleText $"  ", W, H);
		if (W > m_pTextLabel.WinWidth) {
			XOff = W-m_pTextLabel.WinWidth;

			_TextHeight = m_pTextLabel.WinHeight;
			_X = m_pTextLabel.WinLeft - XOff/2;
			_Y = m_pTextLabel.WinTop;
			_fWidth = m_pTextLabel.WinWidth + XOff;
			_fHeight = m_RWindowBorder.H;

			ModifyPopUpFrameWindow(_szTitleText, _TextHeight, _X, _Y, _fWidth, _fHeight);
		}
	}
}

function Paint(Canvas C, float X, float Y)
{
	if (m_bResizePopUpOnTextLabel)
	{
		if (m_pTextLabel != None)
			m_pTextLabel.m_bPreCalculatePos = m_bHideAllChild;

		if (m_ClientArea != None)
			m_ClientArea.m_bPreCalculatePos = m_bHideAllChild;

		if (m_ButClientArea != None)
			m_ButClientArea.m_bPreCalculatePos = m_bHideAllChild;		
		
		if (m_bHideAllChild)
		{
			m_bHideAllChild = false;
			return;
		}
	}

    // draw the border using this fct
    R6WindowLookAndFeel(LookAndFeel).DrawPopUpFrameWindow( self, C);

    if (m_bTextWindowOnly)
    {
        if (m_ClientArea != None)
            m_ClientArea.HideWindow();

        if (m_ButClientArea != None)
            m_ButClientArea.HideWindow();

        return;
    }

    // draw a line over the button 
    if ( (m_ButClientArea != None) || (m_bForceButtonLine) )
    {
        C.SetDrawColor( 255, 255, 255); // White
        // the value 1 and 2 is for border offset
        DrawStretchedTextureSegment(C, m_RWindowBorder.X + 1, m_RWindowBorder.Y + m_RWindowBorder.H - K_FBUTTON_HEIGHT_REGION,
                                       m_RWindowBorder.W - 2, 1, 
                                       SimpleBorderRegion.X, SimpleBorderRegion.Y, SimpleBorderRegion.W, SimpleBorderRegion.H, m_BGTexture);    
    }
}


//===========================================================================
// function to create a std pop up window with clientwindow (for button)
//===========================================================================
function CreateStdPopUpWindow( string _szPopUpTitle, FLOAT _fTextHeight, FLOAT _fXPos, FLOAT _fYPos, FLOAT _fWidth, FLOAT _fHeight, optional INT _iButtonsType)
{
    CreateTextWindow( _szPopUpTitle, _fXPos, _fYPos, _fWidth, _fTextHeight);
    CreatePopUpFrame( _fXPos, _fYPos + _fTextHeight, _fWidth, _fHeight);

    // create the client window of the pop up window for this time is a fix client window
    CreateClientWindow( class'R6WindowPopUpBoxCW', true);

    SetButtonsType( _iButtonsType);
}

//===========================================================================
// function to create a std pop up window (only the visual)
//===========================================================================
function CreatePopUpFrameWindow( string _szPopUpTitle, FLOAT _fTextHeight, FLOAT _fXPos, FLOAT _fYPos, FLOAT _fWidth, FLOAT _fHeight)
{
    CreateTextWindow( _szPopUpTitle, _fXPos, _fYPos, _fWidth, _fTextHeight);
    CreatePopUpFrame( _fXPos, _fYPos + _fTextHeight, _fWidth, _fHeight);
}

function ModifyPopUpFrameWindow( string _szPopUpTitle, FLOAT _fTextHeight, FLOAT _fXPos, FLOAT _fYPos, FLOAT _fWidth, FLOAT _fHeight, optional INT _iButtonsType)
{
    m_bTextWindowOnly = false;

   ModifyTextWindow(_szPopUpTitle, _fXPos, _fYPos, _fWidth, _fTextHeight);
   CreatePopUpFrame( _fXPos, _fYPos + _fTextHeight, _fWidth, _fHeight);// - _fTextHeight); 
   
   if ( m_ButClientArea != None)
   {
        m_ButClientArea.WinLeft     = m_RWindowBorder.X;
        m_ButClientArea.WinTop      = m_RWindowBorder.Y + m_RWindowBorder.H - K_FBUTTON_HEIGHT_REGION;
        m_ButClientArea.WinWidth    = m_RWindowBorder.W;
        m_ButClientArea.WinHeight   = K_FBUTTON_HEIGHT_REGION;

	   SetButtonsType( _iButtonsType);
   }

   if(m_ClientArea != None)
   {
        m_ClientArea.WinLeft     = m_RWindowBorder.X + K_BORDER_HOR_OFF;
        m_ClientArea.WinTop      = m_RWindowBorder.Y;
        m_ClientArea.SetSize(m_RWindowBorder.W - 2 * K_BORDER_HOR_OFF, m_RWindowBorder.H - K_FBUTTON_HEIGHT_REGION);        
   }
   
}

//===========================================================================
// function create the text window
//===========================================================================
function CreateTextWindow( string _szTitleText, FLOAT _X, FLOAT _Y, FLOAT _fWidth, FLOAT _fHeight)
{
    m_pTextLabel = R6WindowTextLabelExt( CreateWindow(class'R6WindowTextLabelExt', _X, _Y, _fWidth, _fHeight, self));
    // draw middle line
    m_pTextLabel.SetBorderParam( 0, 7, 0, 1, Root.Colors.White);     // Top border
    m_pTextLabel.SetBorderParam( 1, 1, 0, 1, Root.Colors.White);     // Bottom border
    m_pTextLabel.SetBorderParam( 2, 1, 1, 1, Root.Colors.White);     // Left border
    m_pTextLabel.SetBorderParam( 3, 1, 1, 1, Root.Colors.White);     // Rigth border   

    // text part
    m_pTextLabel.m_Font = Root.Fonts[F_PopUpTitle]; 
    m_pTextLabel.m_vTextColor = Root.Colors.White;    
    m_pTextLabel.AddTextLabel( _szTitleText, 0, 0, _fWidth, TA_Center, false, 0, m_bResizePopUpOnTextLabel);
	m_pTextLabel.AddTextLabel( "", _fWidth - C_fTITLE_TIME_OFFSET, 0, 0, TA_Right, false, 0, true);
    m_pTextLabel.m_bTextCenterToWindow = true;

    m_pTextLabel.m_eCornerType = Top_Corners;
    SetCornerColor( 1, Root.Colors.White);
}

function ModifyTextWindow( string _szTitleText, FLOAT _X, FLOAT _Y, FLOAT _fWidth, FLOAT _fHeight)
{
    if (m_pTextLabel != None)
    {
        m_pTextLabel.WinLeft = _X;
        m_pTextLabel.WinTop = _Y;
        m_pTextLabel.WinWidth = _fWidth;
        m_pTextLabel.WinHeight = _fHeight;

        // draw middle line
        m_pTextLabel.SetBorderParam( 0, 7, 0, 1, Root.Colors.White);     // Top border
        m_pTextLabel.SetBorderParam( 1, 1, 0, 1, Root.Colors.White);     // Bottom border
        m_pTextLabel.SetBorderParam( 2, 1, 1, 1, Root.Colors.White);     // Left border
        m_pTextLabel.SetBorderParam( 3, 1, 1, 1, Root.Colors.White);     // Rigth border       

        // text part
        m_pTextLabel.Clear();
		m_pTextLabel.m_vTextColor = Root.Colors.White;
        m_pTextLabel.AddTextLabel( _szTitleText, 0, 0, _fWidth, TA_Center, false, 0, m_bResizePopUpOnTextLabel);
		m_pTextLabel.AddTextLabel( "", _fWidth - C_fTITLE_TIME_OFFSET, 0, 0, TA_Right, false, 0, true);
        m_pTextLabel.m_bTextCenterToWindow = true; // in Y
    }
}

function TextWindowOnly( string _szTitleText, FLOAT _X, FLOAT _Y, FLOAT _fWidth, FLOAT _fHeight)
{
    if (m_pTextLabel != None)
    {
        m_bTextWindowOnly = true;
        SetNoBorder();
        m_eCornerType = No_Corners;
        m_RWindowBorder.H = 0;

        m_pTextLabel.WinLeft = _X;
        m_pTextLabel.WinTop = _Y;
        m_pTextLabel.WinWidth = _fWidth;
        m_pTextLabel.WinHeight = _fHeight;

        // draw middle line
        m_pTextLabel.SetBorderParam( 0, 7, 0, 1, Root.Colors.White);     // Top border
        m_pTextLabel.SetBorderParam( 1, 7, 0, 1, Root.Colors.White);     // Bottom border
        m_pTextLabel.SetBorderParam( 2, 1, 1, 1, Root.Colors.White);     // Left border
        m_pTextLabel.SetBorderParam( 3, 1, 1, 1, Root.Colors.White);     // Rigth border       

        m_pTextLabel.m_eCornerType = All_Corners;

        // text part
        m_pTextLabel.Clear();
		m_pTextLabel.m_vTextColor = Root.Colors.White;
        m_pTextLabel.AddTextLabel( _szTitleText, 0, 0, _fWidth, TA_Center, false);
        m_pTextLabel.m_bTextCenterToWindow = true;
    }
}

function UpdateTimeInTextLabel( INT _iNewTime, OPTIONAL string _StringInstead)
{
	local Color vTimeColor;
	local string szTemp;

    if (m_pTextLabel != None)
    {
		vTimeColor = Root.Colors.White;
		if ( _iNewTime < 10) // under 10 sec
			vTimeColor = Root.Colors.Red;
        
        if (_StringInstead != "")
            szTemp = _StringInstead;		
        else if ( _iNewTime == -1)
            szTemp = "";
		else
			szTemp = class'Actor'.static.ConvertIntTimeToString(_iNewTime);

		m_pTextLabel.ChangeColorLabel( vTimeColor, 1);
		m_pTextLabel.ChangeTextLabel( szTemp, 1);
	}
}

//===========================================================================
// function create the pop up frame under the text window
//===========================================================================
function CreatePopUpFrame( FLOAT _X, FLOAT _Y, FLOAT _fWidth, FLOAT _fHeight)
{
    local FLOAT fBorderSize, fBorderWidth;
    fBorderSize = 1;  // distance to border window
    fBorderWidth = 1;

    m_RWindowBorder.X = _X;
    m_RWindowBorder.Y = _Y;
    m_RWindowBorder.W = _fWidth;
    m_RWindowBorder.H = _fHeight;

    ActiveBorder( eBorderType.Border_Top, false);
    SetBorderParam( eBorderType.Border_Bottom, 7, _fHeight - fBorderSize, _fWidth - 14, fBorderWidth, Root.Colors.White);     // Bottom border
    SetBorderParam( eBorderType.Border_Left,   fBorderSize, 0, fBorderWidth , _fHeight - (2 * fBorderSize), Root.Colors.White);     // Left border
    SetBorderParam( eBorderType.Border_Right,  _fWidth - 2, 0, fBorderWidth, _fHeight - (2 * fBorderSize), Root.Colors.White);     // Rigth border    

    m_eCornerType = Bottom_Corners;
    SetCornerColor( eCornerType.Bottom_Corners, Root.Colors.White);
}


//===========================================================================
// function to assign each border param
//===========================================================================
function SetBorderParam( INT _iBorderType, FLOAT _X, FLOAT _Y, FLOAT _fWidth, FLOAT _fHeight, COLOR _vColor)
{
    m_sBorderForm[_iBorderType].fXPos      = _X + m_RWindowBorder.X;
    m_sBorderForm[_iBorderType].fYPos      = _Y + m_RWindowBorder.Y;
    m_sBorderForm[_iBorderType].fWidth     = _fWidth;
    m_sBorderForm[_iBorderType].fHeight    = _fHeight;
    m_sBorderForm[_iBorderType].vColor     = _vColor;
    m_sBorderForm[_iBorderType].bActive    = true;

    m_bNoBorderToDraw = false;
//    m_sBorderForm[_iBorderType].bBorderSet = true;
}

//===========================================================================
// function to active border or not
//===========================================================================
// active border or not
function ActiveBorder( INT _iBorderType, bool _Active)
{
    local INT i;
    local bool bNoBorderToDraw;

    m_sBorderForm[_iBorderType].bActive = _Active;

    bNoBorderToDraw = true;

    for ( i = 0 ; i < 4; i++)
    {
        if (m_sBorderForm[_iBorderType].bActive)
        {
            bNoBorderToDraw = false;
            break;
        }
    }

    m_bNoBorderToDraw = bNoBorderToDraw;
}

function SetNoBorder()
{
    m_bNoBorderToDraw = true;
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

//===========================================================================
// ResizePopUp: set a new width for the popup base on the size of the text label 
//===========================================================================
function ResizePopUp( FLOAT _fNewWidth)
{
	local FLOAT fTemp;
	local INT iTemp;

	fTemp = (640 - _fNewWidth) * 0.5;
	fTemp += 0.5;
	iTemp = fTemp;

	m_bHideAllChild = true;

	ModifyPopUpFrameWindow( m_pTextLabel.GetTextLabel(0), m_pTextLabel.WinHeight, iTemp, m_pTextLabel.WinTop, _fNewWidth, m_RWindowBorder.H, m_iPopUpButtonsType);
}

function SetPopUpResizable( BOOL _bResizable)
{
	m_bResizePopUpOnTextLabel = _bResizable;
	m_bHideAllChild = _bResizable;
}

//===========================================================================
// function to set pop up window button 
//===========================================================================
function SetButtonsType( INT _iButtonsType)
{
	m_iPopUpButtonsType = _iButtonsType;

    switch(_iButtonsType)
    {        
        case MessageBoxButtons.MB_OK:
            SetupPopUpBox( MB_OK, MR_OK, MR_OK);
            break;
		case MessageBoxButtons.MB_Cancel:
			SetupPopUpBox( MB_Cancel, MR_OK);
			break;
        case MessageBoxButtons.MB_None:
            SetupPopUpBox( MB_None, MR_None);
			break;
        default:
		    SetupPopUpBox( MB_OKCancel, MR_Cancel, MR_OK);
            break;
    }
}


//===========================================================================
// function to set pop up window button 
//===========================================================================
function SetupPopUpBox( MessageBoxButtons Buttons, MessageBoxResult InESCResult, optional MessageBoxResult InEnterResult)
{
    // you have to create a clientwindow use setup!!! with fct CreateClientWindow
    if (m_ButClientArea != None)
    {
     //   function SetupPopUpBoxClient( MessageBoxButtons InButtons, MessageBoxResult InEnterResult)
	    R6WindowPopUpBoxCW(m_ButClientArea).SetupPopUpBoxClient( Buttons, InESCResult, InEnterResult);
    }

	Result		  = InESCResult;
	DefaultResult = InESCResult; // if we re-use the same pop-up, reset the value in close() to the default one
}

//===========================================================================
// Close the pop up window and advice owner
//===========================================================================
function Close(optional bool bByParent)
{
	local R6GameOptions pGameOptions;
	local BOOL bGOSaveConfig;

	if (m_bPopUpLock)
		return;

    Super.Close(bByParent);

	// if the disable pop-up button is active
	if (m_bDisablePopUpActive)
	{
		if (m_ButClientArea != None)
		{
            pGameOptions = class'Actor'.static.GetGameOptions();
            bGOSaveConfig = true;

			
            switch( m_ePopUpID)
			{
                case EPopUpID_QuickPlay:                
                    pGameOptions.PopUpQuickPlay = !(R6WindowPopUpBoxCW(m_ButClientArea).m_pDisablePopUpButton.m_bSelected);
                    break;
				case EPopUpID_LoadPlanning:
					pGameOptions.PopUpLoadPlan = !(R6WindowPopUpBoxCW(m_ButClientArea).m_pDisablePopUpButton.m_bSelected);
					break;
				default:
					log("Need to add your disable/enable pop-up ID in game options to have this feature ON");
					bGOSaveConfig = false;
					break;
			}

            if (bGOSaveConfig)
					pGameOptions.SaveConfig();
		}
	}

	if (m_ButClientArea != None)
	{
		R6WindowPopUpBoxCW(m_ButClientArea).CancelAcceptsFocus();
	}

#ifdefDEBUG
	if (OwnerWindow == None)
		log("R6WindowPopUpBox function Close() OwnerWindow is none!!!");
	else
#endif
    OwnerWindow.PopUpBoxDone( Result, m_ePopUpID);

    if (m_ClientArea != None)
	{
        m_ClientArea.PopUpBoxDone( Result, m_ePopUpID);
	}

	Result = DefaultResult; // if we re-use the same pop-up, reset the value in close() to the default one
}



//===========================================================================
// This allows the client area to get notified of showwindows
//===========================================================================
function ShowWindow()
{   
    Super.ShowWindow();      

	if (m_bResizePopUpOnTextLabel)
		m_bHideAllChild = true;

	if (m_bDetectKey)
	{
		if (m_ButClientArea != None)
		{
			R6WindowPopUpBoxCW(m_ButClientArea).SetAcceptsFocus();
		}
	}

    if (m_ClientArea != None)
    {
        m_ClientArea.ShowWindow();
    }
}

function ShowLockPopUp()
{
	m_bPopUpLock = true;
	ShowWindow();
}

function HideWindow()
{
	m_bPopUpLock = false;

	Super.HideWindow();
}

function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key) 
{
	Super.WindowEvent( Msg, C, X, Y, Key);

	if (m_bDetectKey)
	{
		if ( Msg == WM_KeyDown)
		{
			if (m_ButClientArea != None)
			{
				if ( m_ButClientArea.IsA('R6WindowPopUpBoxCW'))
				{
					R6WindowPopUpBoxCW(m_ButClientArea).KeyDown( Key, X, Y);
				}
			}
		}
	}
}


//=========================================================================================
// AddDisableDLG: add a disable text and box to disable-enable pop-up
//=========================================================================================
function AddDisableDLG()
{
    local R6GameOptions pGameOptions;

    if (m_ButClientArea != None)
    {
	    R6WindowPopUpBoxCW(m_ButClientArea).AddDisablePopUpButton();

        pGameOptions = class'Actor'.static.GetGameOptions();

        switch( m_ePopUpID)
		{
            case EPopUpID_QuickPlay:
                R6WindowPopUpBoxCW(m_ButClientArea).m_pDisablePopUpButton.m_bSelected = !(pGameOptions.PopUpQuickPlay);
                break;
			case EPopUpID_LoadPlanning:
				R6WindowPopUpBoxCW(m_ButClientArea).m_pDisablePopUpButton.m_bSelected = !(pGameOptions.PopUpLoadPlan);
				break;
			default:				
				break;
		}
    }

	m_bDisablePopUpActive = true;
}

//=========================================================================================
// RemoveDisableDLG: remove a disable text and box to disable-enable pop-up
//=========================================================================================
function RemoveDisableDLG()
{
    if (m_ButClientArea != None)
    {
	    R6WindowPopUpBoxCW(m_ButClientArea).RemoveDisablePopUpButton();
    }

	m_bDisablePopUpActive = false;
}

defaultproperties
{
     m_DrawStyle=5
     m_bBGFullScreen=True
     m_bBGClientArea=True
     m_bDetectKey=True
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
     m_BGTextureRegion=(X=70,Y=45,W=9,H=18)
     m_HBorderTextureRegion=(X=64,Y=56,W=1,H=1)
     m_VBorderTextureRegion=(X=64,Y=56,W=1,H=1)
     m_topLeftCornerR=(X=12,Y=56,W=6,H=8)
     SimpleBorderRegion=(X=64,Y=56,W=1,H=1)
}
