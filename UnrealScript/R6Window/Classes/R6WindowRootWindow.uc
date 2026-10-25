//=============================================================================
//  R6WindowRootWindow.uc : This root is an intermediate between uwindowrootwindow and all the menu root window
//							to have access for R6WindowPopUpBox
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/11/07 * Created by Yannick Joly
//=============================================================================
class R6WindowRootWindow extends UWindowRootWindow;

struct stKeyAvailability
{
	var INT								iKey;
	var INT								iWidgetKA;
};

struct StWidget
{
	var UWindowWindow					m_pWidget;
	var R6WindowPopUpBox                m_pPopUpFrame; 
	var eGameWidgetID					m_eGameWidgetID;
	var name							m_WidgetConsoleState;
	var INT								iWidgetKA;
};

var	Array<StWidget>						m_pListOfActiveWidget;
var Array<stKeyAvailability>			m_pListOfKeyAvailability;
var Array<R6WindowPopUpBox>				m_pListOfFramePopUp;

var	R6WindowPopUpBox					m_pSimplePopUp;					// a real simple pop-up

var	Region								m_RSimplePopUp;					// the region of the simple popup
var	Region                              m_RAddDlgSimplePopUp;           // Pop up with disable button

var Texture
								m_BGTexture[2];					// for random background texture
var INT									m_iWidgetKA;					// widget key availability
var INT									m_iLastKeyDown;

// MPF - Eric
var string								m_szCurrentBackgroundSubDirectory; // Directory of the background currently displayed


//=====================================================================================================
// SimplePopUp: Provide a simple pop-up
//=====================================================================================================
function SimplePopUp( string _szTitle, string _szText, ePopUpID _ePopUpID, optional INT _iButtonsType, OPTIONAL BOOL bAddDisableDlg, optional UWindowWindow OwnerWindow)
{
    local R6WindowWrappedTextArea pTextZone;
    
    if (m_pSimplePopUp == None)
    {
        // Create PopUp frame
        m_pSimplePopUp = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480, OwnerWindow));
		m_pSimplePopUp.SetPopUpResizable((_ePopUpID != EPopUpID_TextOnly));
        m_pSimplePopUp.bAlwaysOnTop = true;
        m_pSimplePopUp.CreateStdPopUpWindow( _szTitle, 25, m_RSimplePopUp.X, m_RSimplePopUp.Y, m_RSimplePopUp.W, m_RSimplePopUp.H, _iButtonsType);
        m_pSimplePopUp.CreateClientWindow( class'R6WindowWrappedTextArea');
        m_pSimplePopUp.m_ePopUpID = _ePopUpID;
		pTextZone = R6WindowWrappedTextArea(m_pSimplePopUp.m_ClientArea);
		pTextZone.SetScrollable(true);			
		pTextZone.m_fXOffset = 5;
		pTextZone.m_fYOffset = 5;
		pTextZone.AddText(_szText, Root.Colors.White, Root.Fonts[F_HelpWindow]);
        pTextZone.m_bDrawBorders = false;
    }
    else
    {        
        pTextZone = R6WindowWrappedTextArea(m_pSimplePopUp.m_ClientArea);
        pTextZone.Clear(true, true);		
        pTextZone.AddText(_szText, Root.Colors.White, Root.Fonts[F_HelpWindow]);
		m_pSimplePopUp.OwnerWindow = OwnerWindow;
		m_pSimplePopUp.SetPopUpResizable((_ePopUpID != EPopUpID_TextOnly));
        m_pSimplePopUp.ModifyPopUpFrameWindow( _szTitle, 25, m_RSimplePopUp.X, m_RSimplePopUp.Y, m_RSimplePopUp.W, m_RSimplePopUp.H, _iButtonsType);
        m_pSimplePopUp.m_ePopUpID = _ePopUpID;
        m_pSimplePopUp.ShowWindow(); 
    }
    
    if (_ePopUpID == EPopUpID_TextOnly)
    {
        m_pSimplePopUp.m_ePopUpID = _ePopUpID;
        m_pSimplePopUp.TextWindowOnly( _szTitle, m_RSimplePopUp.X, m_RSimplePopUp.Y, m_RSimplePopUp.W, m_RSimplePopUp.H);
    }
    else
    {
        if(bAddDisableDlg)    
        {            
            m_pSimplePopUp.AddDisableDLG();            
            m_pSimplePopUp.ModifyPopUpFrameWindow( _szTitle, 25, m_RAddDlgSimplePopUp.X, m_RAddDlgSimplePopUp.Y, m_RAddDlgSimplePopUp.W, m_RAddDlgSimplePopUp.H, _iButtonsType);                                    
        }
        else
            m_pSimplePopUp.RemoveDisableDLG();
        
    }
    
	if (Console.IsInState('Game'))
        Console.LaunchUWindow();
}
//=====================================================================================================
// SimpleTextPopUp: Provide a simple pop-up for text only, no buttons
//=====================================================================================================
function SimpleTextPopUp(string _szText)
{
    SimplePopUp(_szText,"",EPopUpID_TextOnly, MessageBoxButtons.MB_None);        
}

function PopUpBoxDone( MessageBoxResult Result, ePopUpID _ePopUpID)
{    
#ifdefDEBUG
	local BOOL bShowPopUpBoxDoneLog;

	if (bShowPopUpBoxDoneLog)
	{
		log("R6WindowRootWindow PopUpBoxDone: " $ GetEPopUpID(_ePopUpID));
	}
#endif
    
	m_RSimplePopUp = self.Default.m_RSimplePopUp;

	switch(_ePopUpID)
	{
		case EPopUpID_DownLoadingInProgress:
			if (Result == MR_Cancel)
			{
				// user interrupt connection, advice console!
				Console.m_bInterruptConnectionProcess = true;
			}
			break;
		default:
			break;
	}
}

function ePopUpID GetSimplePopUpID()
{
	if ((m_pSimplePopUp != None) && ( m_pSimplePopUp.bWindowVisible))
		return m_pSimplePopUp.m_ePopUpID;
	
	return EPopUpID_None;
}

function ModifyPopUpInsideText( array<string> _ANewText)
{
	local R6WindowWrappedTextArea pTextZone;
	local INT i;

	if ((m_pSimplePopUp != None) && ( m_pSimplePopUp.bWindowVisible))
	{
		if (m_pSimplePopUp.m_ePopUpID == EPopUpID_DownLoadingInProgress)
		{
			pTextZone = R6WindowWrappedTextArea(m_pSimplePopUp.m_ClientArea);
			pTextZone.Clear(true, true);		

			for ( i = 0; i < _ANewText.length; i++)
			{
				pTextZone.AddText( _ANewText[i], Root.Colors.White, Root.Fonts[F_HelpWindow]);
			}
		}
	}
}

//=============================================================================================
// FillListOfKeyAvailability: Fill the list of key availability
//							  Each widget (pop-up by a key) is define here
//=============================================================================================
function FillListOfKeyAvailability()
{
	// implemented in child class
}

//=============================================================================================
// AddKeyInList: Add key in key list availability
//=============================================================================================
function AddKeyInList( INT _iKey, INT _iWKA)
{
	local stKeyAvailability stKeyATemp;

	stKeyATemp.iKey		 = _iKey;
	stKeyATemp.iWidgetKA = _iWKA;

	m_pListOfKeyAvailability[m_pListOfKeyAvailability.Length] = stKeyATemp;
}

//=========================================================================================================
// GetPopUpFrame: Get a pop-up frame
//=========================================================================================================
function R6WindowPopUpBox GetPopUpFrame( INT _iIndex)
{
	local R6WindowPopUpBox pPopUpFrame;

	if ( m_pListOfFramePopUp.Length > _iIndex) // the pop-up frame exist
	{
		pPopUpFrame = m_pListOfFramePopUp[_iIndex];
	}
	else //create the pop-up frame
	{
		pPopUpFrame = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480));
		pPopUpFrame.CreatePopUpFrameWindow( "", 0, 0, 0, 0, 0); //this fct is use for initialisation
		pPopUpFrame.m_bBGFullScreen = true;
		pPopUpFrame.HideWindow();		

		// add it to the list
		m_pListOfFramePopUp[m_pListOfFramePopUp.Length] = pPopUpFrame;
	}
	
	return pPopUpFrame;
}

//===================================================================================
// ManagePrevWInHistory:  Remove the previous widget in the list (in fact the one that you have on the screen, you do a changewidget)
//===================================================================================
function ManagePrevWInHistory( BOOL _bClearPrevWInHistory, out INT _iNbOfWidgetInList)
{
	if (_bClearPrevWInHistory)
	{
		if (_iNbOfWidgetInList != 0) // at least one window in the list
		{
			// hide the last window
			if (m_pListOfActiveWidget[_iNbOfWidgetInList - 1].m_pPopUpFrame != None)
				m_pListOfActiveWidget[_iNbOfWidgetInList - 1].m_pPopUpFrame.HideWindow();

			m_pListOfActiveWidget[_iNbOfWidgetInList - 1].m_pWidget.HideWindow();

			m_pListOfActiveWidget.remove( _iNbOfWidgetInList - 1, 1); // remove the element from the list
			_iNbOfWidgetInList -= 1;
		}
	}
}

function BOOL IsWidgetIsInHistory( eGameWidgetID _eWidgetToFind)
{
	local INT i;

	for ( i = 0; i < m_pListOfActiveWidget.Length; i++)
	{
		if (m_pListOfActiveWidget[i].m_eGameWidgetID == _eWidgetToFind)
			return true;
	}

	return false;
}

//===================================================================================
// CloseAllWindow:  Process a hide window on all the window in the list 
//===================================================================================
function CloseAllWindow()
{
	local INT i, iNbOfWindow;

	iNbOfWindow = m_pListOfActiveWidget.Length; // number of windows on the screen

	for ( i = 0; i < iNbOfWindow ; i++)
	{
		// hide the window
		if (m_pListOfActiveWidget[i].m_pPopUpFrame != None)
			m_pListOfActiveWidget[i].m_pPopUpFrame.HideWindow();

		m_pListOfActiveWidget[i].m_pWidget.HideWindow();
	}

	m_pListOfActiveWidget.remove( 0, iNbOfWindow); // remove all the element from the list
}

function SetLoadRandomBackgroundImage( string _szFolder)
{
	// MPF - Eric
	m_szCurrentBackgroundSubDirectory = _szFolder;
	class'Actor'.static.LoadRandomBackgroundImage(_szFolder);
}

function PaintBackground( Canvas C, UWindowWindow _WidgetWindow)
{
	if (m_BGTexture[0] != none && m_BGTexture[1] != none)
	{
		_WidgetWindow.DrawStretchedTextureSegment(C, 0,0,512,512,0,0,512,512,    m_BGTexture[0]);
		_WidgetWindow.DrawStretchedTextureSegment(C, 512,0,512,512,0,0,512,512,  m_BGTexture[1]);
	}
}

function CheckConsoleTypingState( name _RequestConsoleState)
{
	if ( Console.IsInState('Typing'))
	{
		Console.ConsoleState = _RequestConsoleState; // give the next console state to the console and stay in state 'typing'
//		ConsoleStateResult = 'Typing';
	}
	else
	{
		Console.GotoState( _RequestConsoleState);
	}
}

//===================================================================================================
// GetMapNameLocalisation: Get the map name localisation. Return true if we found a name
//===================================================================================================
function BOOL GetMapNameLocalisation( string _szMapName, OUT string _szMapNameLoc, optional BOOL _bReturnInitName)
{
	local INT                   i, j;
    local R6Console             r6console;
	local R6MissionDescription  mission;
	local LevelInfo pLevel;

	pLevel = GetLevel();
    r6console = R6Console( Root.Console );

	_szMapNameLoc = "";

    // from the main list, get all mission who can be played
    for ( i = 0; i < r6console.m_aMissionDescriptions.Length; ++i )
    {
        mission = r6console.m_aMissionDescriptions[i];

		if (Caps(mission.m_MapName) == Caps(_szMapName))
		{
	        _szMapNameLoc = Localize( mission.m_MapName, "ID_MENUNAME", mission.LocalizationFile, true );
			break;
		}
    }
	
	if ((_bReturnInitName) && (_szMapNameLoc == "")) // return the default name if we find nothing
		_szMapNameLoc = _szMapName;

	return (_szMapNameLoc != "");
}

defaultproperties
{
     m_iLastKeyDown=-1
     m_BGTexture(0)=Texture'R6MenuBG.Backgrounds.GenericMainMenu0'
     m_BGTexture(1)=Texture'R6MenuBG.Backgrounds.GenericMainMenu1'
     m_RSimplePopUp=(X=170,Y=100,W=300,H=80)
     m_RAddDlgSimplePopUp=(X=165,Y=100,W=310,H=80)
}
