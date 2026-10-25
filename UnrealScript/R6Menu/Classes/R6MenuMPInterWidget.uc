//=============================================================================
//  R6MenuMPInterWidget.uc : Intermission widget (when you press start during MP game or 
//                           during the between round time)
//  the size of the window is 640 * 480
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/25 * Created  Yannick Joly
//=============================================================================
class R6MenuMPInterWidget extends R6MenuWidget;

var R6MenuMPInterHeader         m_pMPInterHeader;              // the intermission header menu
var R6MenuMPTeamBar             m_pR6AlphaTeam;                // the alpha team bar with stats
var R6MenuMPTeamBar             m_pR6BravoTeam;                // the bravo team bar with stats
var R6MenuMPTeamBar             m_pR6MissionObj;			   // the mission objectives in coop
var R6MenuMPInGameNavBar        m_pInGameNavBar;               // the nav bar

var R6WindowPopUpBox			m_pPopUpBoxCurrent;
var R6WindowPopUpBox            m_pPopUpGearRoom;
var R6WindowPopUpBox            m_pPopUpServerOption;          // Pop up server option menu
var R6WindowPopUpBox            m_pPopUpKitRest;               // Pop up the kit restriction menu

var	string						m_szCurGameType;

var FLOAT                       m_fYStartTeamBarPos;           // the Y team bar start pos

var bool                        m_bDisplayNavBar;            // display the Inter Bar only if you are in between round time
var BOOL                        m_bRefreshRestKit;             // refesh rest kit when you click on the button
var BOOL						m_bForceRefreshOfGear;		   // force refresh the first time this window is displaying
var BOOL						m_bNavBarActive;

//test
var INT                         m_Counter;
var ePopUpID                    m_InGameOptionsChange;

//===================================================================================
// Create the window and all the area for displaying game information
//===================================================================================
function Created()
{

    m_fYStartTeamBarPos = R6MenuInGameMultiPlayerRootWindow(OwnerWindow).m_RInterWidget.Y +R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize();

    // create the header window
    m_pMPInterHeader = R6MenuMPInterHeader( CreateWindow(class'R6MenuMPInterHeader', 
                                            R6MenuInGameMultiPlayerRootWindow(OwnerWindow).m_RInterWidget.X,
                                            m_fYStartTeamBarPos,
                                            R6MenuInGameMultiPlayerRootWindow(OwnerWindow).m_RInterWidget.W,
                                            66, self));

    m_fYStartTeamBarPos += m_pMPInterHeader.WinHeight;

    m_pR6AlphaTeam = R6MenuMPTeamBar( CreateWindow(class'R6MenuMPTeamBar', 0, 0, 10, 10, self));
    m_pR6AlphaTeam.m_vTeamColor = Root.Colors.TeamColorLight[1]; // GREEN
    m_pR6AlphaTeam.m_szTeamName = Localize("MPInGame","AlphaTeam","R6Menu");

    m_pR6BravoTeam = R6MenuMPTeamBar( CreateWindow(class'R6MenuMPTeamBar', 0, 0, 10, 10, self));
    m_pR6BravoTeam.m_vTeamColor = Root.Colors.TeamColorLight[0]; // RED
    m_pR6BravoTeam.m_szTeamName = Localize("MPInGame","BravoTeam","R6Menu");

    m_pR6MissionObj = R6MenuMPTeamBar( CreateWindow(class'R6MenuMPTeamBar', 0, 0, 10, 10, self));
	m_pR6MissionObj.m_bDisplayObj = true;

    m_pInGameNavBar = R6MenuMPInGameNavBar( CreateWindow(class'R6MenuMPInGameNavBar', 
                                            R6MenuInGameMultiPlayerRootWindow(OwnerWindow).m_RInterWidget.X,
                                            0,
                                            R6MenuInGameMultiPlayerRootWindow(OwnerWindow).m_RInterWidget.W,
                                            m_pMPInterHeader.WinHeight));
    

    m_Counter = 0;
//    SetInterWidgetMenu(eInterMenuMode.IMM_PureDeathMatch);

    m_pR6AlphaTeam.InitTeamBar(); // need to have the team color
    m_pR6BravoTeam.InitTeamBar(); // need to have the team color
	m_pR6MissionObj.InitMissionWindows();
}

function Tick(float Delta)
{
    m_Counter++;

	if (m_bForceRefreshOfGear)
	{
		m_bForceRefreshOfGear = false;
		RefreshGearMenu( true);
	}
	
    // refresh every 15 frames
    if (m_Counter > 10) 
    {
        RefreshServerInfo();
    }
}


//function SetInterWidgetMenu( INT _iGameType, bool _bActiveMenuBar)
function SetInterWidgetMenu( string _szCurrentGameType, bool _bActiveMenuBar)
{
	local R6MenuInGameMultiPlayerRootWindow R6Root;
    local FLOAT fXPos, fWidth, fAvailableSpace;
	local BOOL bActiveMenuBar;

	R6Root = R6MenuInGameMultiPlayerRootWindow(Root);

    fXPos  = R6Root.m_RInterWidget.X;
    fWidth = R6Root.m_RInterWidget.W;
    fAvailableSpace = R6Root.m_RInterWidget.H - m_pMPInterHeader.WinHeight; //- R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize() - m_pMPInterHeader.WinHeight;

	m_pR6BravoTeam.HideWindow(); 
	m_pR6MissionObj.HideWindow();

	// the design change, the bar have to be there all the time, but we not displaying button is activemenubar is false
	m_bDisplayNavBar = _bActiveMenuBar;
	m_pInGameNavBar.SetNavBarButtonsStatus( _bActiveMenuBar);

// OLD CODE resize the team bar stat window depending if you have a nav bar or not
//	bActiveMenuBar = _bActiveMenuBar; 
//	m_pInGameNavBar.HideWindow(); 
// end of OLD CODE
	bActiveMenuBar = true;

	if (m_szCurGameType != _szCurrentGameType)
	{
		m_pMPInterHeader.ResetDisplayInfo();
		m_szCurGameType = _szCurrentGameType;
	}

	// reset variables link to specific game type
	m_pMPInterHeader.Reset();

	if (GetLevel().IsGameTypeTeamAdversarial( _szCurrentGameType))
	{
//		log("TEAM ADVERSARIAL");
		m_pMPInterHeader.m_bDisplayTotVictory = true;

		m_pR6AlphaTeam.InitMenuLayout( 1);
		m_pR6BravoTeam.InitMenuLayout( 1);

		if (bActiveMenuBar)
		{
            fAvailableSpace -= m_pInGameNavBar.WinHeight;

            m_pR6AlphaTeam.SetWindowSize( fXPos, m_fYStartTeamBarPos, fWidth, fAvailableSpace * 0.5);
            // show bravo team
            m_pR6BravoTeam.SetWindowSize( fXPos, m_fYStartTeamBarPos + (fAvailableSpace * 0.5), fWidth, fAvailableSpace * 0.5);
            m_pR6BravoTeam.ShowWindow();
            // display the nav bar
            SetWindowSize( m_pInGameNavBar, fXPos, m_fYStartTeamBarPos + fAvailableSpace, fWidth, m_pInGameNavBar.WinHeight);
            m_pInGameNavBar.ShowWindow();
		}
		else
		{
            m_pR6AlphaTeam.SetWindowSize( fXPos, m_fYStartTeamBarPos, fWidth, fAvailableSpace * 0.5);
            // show bravo team
            m_pR6BravoTeam.SetWindowSize( fXPos, m_fYStartTeamBarPos + (fAvailableSpace * 0.5), fWidth, fAvailableSpace * 0.5);
            m_pR6BravoTeam.ShowWindow();
		}
	}
	else if (GetLevel().IsGameTypeAdversarial( _szCurrentGameType))
	{
//		log("ADVERSARIAL");
		m_pR6AlphaTeam.InitMenuLayout( 0);

		if (bActiveMenuBar)
		{
            fAvailableSpace -= m_pInGameNavBar.WinHeight;

            m_pR6AlphaTeam.SetWindowSize( fXPos, m_fYStartTeamBarPos, fWidth, fAvailableSpace);
            // display the nav bar
            SetWindowSize( m_pInGameNavBar, fXPos, m_fYStartTeamBarPos + fAvailableSpace, fWidth, m_pInGameNavBar.WinHeight); 
            m_pInGameNavBar.ShowWindow();
		}
		else
		{
            m_pR6AlphaTeam.SetWindowSize( fXPos, m_fYStartTeamBarPos, fWidth, fAvailableSpace);
//            m_pR6BravoTeam.SetWindowSize( fXPos, m_fYStartTeamBarPos, fWidth, fAvailableSpace); // PATCH
		}
	}
	else if (GetLevel().IsGameTypeCooperative( _szCurrentGameType))
	{
//		log("COOPERATIVE");
		m_pMPInterHeader.m_bDisplayCoopStatus = true;

		m_pR6AlphaTeam.InitMenuLayout( 1);

		if (bActiveMenuBar)
		{
            fAvailableSpace -= m_pInGameNavBar.WinHeight;

            m_pR6AlphaTeam.SetWindowSize( fXPos, m_fYStartTeamBarPos, fWidth, fAvailableSpace * 0.5);
            // show bravo team
//            m_pR6BravoTeam.SetWindowSize( fXPos, m_fYStartTeamBarPos + (fAvailableSpace * 0.5), fWidth, fAvailableSpace * 0.5);
            // display the nav bar
            SetWindowSize( m_pInGameNavBar, fXPos, m_fYStartTeamBarPos + fAvailableSpace, fWidth, m_pInGameNavBar.WinHeight);
            m_pInGameNavBar.ShowWindow();
			// display mission briefing
            m_pR6MissionObj.SetWindowSize( fXPos, m_fYStartTeamBarPos + (fAvailableSpace * 0.5), fWidth, fAvailableSpace * 0.5);
			m_pR6MissionObj.ShowWindow();
		}
		else
		{
            m_pR6AlphaTeam.SetWindowSize( fXPos, m_fYStartTeamBarPos, fWidth, fAvailableSpace * 0.5);
            // show bravo team
            m_pR6MissionObj.SetWindowSize( fXPos, m_fYStartTeamBarPos + (fAvailableSpace * 0.5), fWidth, fAvailableSpace * 0.5);
            m_pR6MissionObj.ShowWindow();
		}
	}

    RefreshServerInfo();
	if (_bActiveMenuBar)
		m_bForceRefreshOfGear = true;
}


//===================================================================================
// PopUpGearMenu(): This function pop-up the gear menu with accept and cancel button
//===================================================================================
function PopUpGearMenu()
{
    if (m_pPopUpGearRoom == None)
    {
        m_pPopUpGearRoom = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480));
        m_pPopUpGearRoom.CreateStdPopUpWindow( Localize("MPInGame","Gear","R6Menu"), 32, 103, 70, 434, 340);
        m_pPopUpGearRoom.CreateClientWindow(class'R6MenuMPAdvGearWidget');
		m_pPopUpGearRoom.m_ePopUpID = EPopUpID_MPGearRoom;
        m_pPopUpGearRoom.bAlwaysOnTop    = true;
        m_pPopUpGearRoom.m_bBGFullScreen = true;
		m_pPopUpGearRoom.Close();
    }
    else
	{
	    m_pPopUpGearRoom.ShowWindow(); 
		RefreshGearMenu( true);
		m_pPopUpBoxCurrent = m_pPopUpGearRoom;
	}
}


//===================================================================================
// PopUpServerOptMenu(): This function pop-up the server option menu with accept and cancel button
//===================================================================================
function PopUpServerOptMenu()
{
    if (m_pPopUpServerOption == None)
    {
        m_pPopUpServerOption = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480));
        //TODO we have to decide the correct text depending if it's a admin (adversarial host option) or a client (adversarial server option)
        m_pPopUpServerOption.CreateStdPopUpWindow( Localize("MPInGame","ServerOpt","R6Menu"), 32, 10, 80, 620, 325);
		m_pPopUpServerOption.CreateClientWindow(Root.MenuClassDefines.ClassMPServerOption);
		m_pPopUpServerOption.m_ePopUpID = EPopUpID_MPServerOpt;
        m_pPopUpServerOption.bAlwaysOnTop    = true;
        m_pPopUpServerOption.m_bBGFullScreen = true;
    }
    
    m_pPopUpServerOption.ShowWindow();
#ifndefMPDEMO
    R6PlayerController(GetPlayerOwner()).ServerPausePreGameRoundTime();
#endif
    
	m_pPopUpBoxCurrent = m_pPopUpServerOption;

	R6MenuMPCreateGameTab(m_pPopUpServerOption.m_ClientArea).RefreshServerOpt();
}


//===================================================================================
// PopUpKitRestMenu(): This function pop-up the server option menu with accept and cancel button
//===================================================================================
function PopUpKitRestMenu()
{
	local R6MenuMPRestKitMain pR6MenuMPRestKitMain;

    if (m_pPopUpKitRest == None)
    {
        m_pPopUpKitRest = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480));
        //TODO we have to decide the correct text depending if it's a admin (adversarial host option) or a client (adversarial server option)
        m_pPopUpKitRest.CreateStdPopUpWindow( Localize("MPInGame","KitRestriction","R6Menu"), 32, 10, 70, 620, 332);
        m_pPopUpKitRest.CreateClientWindow(class'R6MenuMPRestKitMain');
		m_pPopUpKitRest.m_ePopUpID = EPopUpID_MPKitRest;
        m_pPopUpKitRest.bAlwaysOnTop			= true;
        m_pPopUpKitRest.m_bBGFullScreen			= true;
		pR6MenuMPRestKitMain = R6MenuMPRestKitMain( m_pPopUpKitRest.m_ClientArea);
		pR6MenuMPRestKitMain.CreateKitRestriction();
    }
    
    m_pPopUpKitRest.ShowWindow();
#ifndefMPDEMO
    R6PlayerController(GetPlayerOwner()).ServerPausePreGameRoundTime();
#endif
	m_pPopUpBoxCurrent = m_pPopUpKitRest;

	R6MenuMPRestKitMain(m_pPopUpKitRest.m_ClientArea).RefreshKitRest();
}

//==============================================================================
// ForceClosePopUp -  Force to close all the popup -- temporary... 
//==============================================================================
function ForceClosePopUp()
{
    if(m_pPopUpGearRoom != none)
    {
        if(m_bDisplayNavBar)
        {
            R6MenuMPAdvGearWidget(m_pPopUpGearRoom.m_ClientArea).AcceptSelection();
        }
    }
    if(m_pPopUpBoxCurrent != none)
    {
        if(m_pPopUpBoxCurrent.bWindowVisible)
        {
            m_pPopUpBoxCurrent.Close();
        }
    }
}

//==============================================================================
// HideWindow: When you hide this window, hide the current pop-up too
//==============================================================================
function HideWindow()
{
	ForceClosePopUp();
	Super.HideWindow();
}

//==============================================================================
// PopUpBoxDone -  receive the result of the popup box  
//==============================================================================
function PopUpBoxDone(UWindowBase.MessageBoxResult Result, UWindowBase.EPopUpID _ePopUpID)
{
    if(Result == MR_OK)
    {
        m_InGameOptionsChange = _ePopUpID;
        switch(_ePopUpID)
        {
            case EPopUpID_MPGearRoom:
                if(m_pPopUpGearRoom != none)
                {
                    R6MenuMPAdvGearWidget(m_pPopUpGearRoom.m_ClientArea).AcceptSelection();
                }
                break;
            case EPopUpID_MPServerOpt:
                R6PlayerController(GetPlayerOwner()).ServerStartChangingInfo();
                break;
            case EPopUpID_MPKitRest:
                R6PlayerController(GetPlayerOwner()).ServerStartChangingInfo();
                break;
            default:
        }        
    }
    else
    {
        if(Result == MR_Cancel)
        {
            switch(_ePopUpID)
            {
                case EPopUpID_MPGearRoom:
                    if(m_pPopUpGearRoom != none)
                    {
                        R6MenuMPAdvGearWidget(m_pPopUpGearRoom.m_ClientArea).CancelSelection();
                    }
                    break;
                case EPopUpID_MPServerOpt:
                case EPopUpID_MPKitRest:
                default:
                    break;
            }
        }
    }
    R6PlayerController(GetPlayerOwner()).ServerUnPausePreGameRoundTime();
}

function SetClientServerSettings(BOOL _bChange)
{
	local R6MenuMPCreateGameTab pServerOpt;
	local R6MenuMPRestKitMain  pKitRest;
	local BOOL bSetNewSettings;
    local BYTE _bMapCount;

    if (_bChange)
    {
		switch(m_InGameOptionsChange)
		{
			case EPopUpID_MPServerOpt:
				pServerOpt = R6MenuMPCreateGameTab(m_pPopUpServerOption.m_ClientArea);
        
                // we have to set the new server settings
                bSetNewSettings = pServerOpt.SendNewServerSettings();


                bSetNewSettings = (pServerOpt.SendNewMapSettings(_bMapCount) || bSetNewSettings);
                if ((bSetNewSettings == true) && (_bMapCount==0))
                {
                    R6PlayerController(GetPlayerOwner()).SendSettingsAndRestartServer( false, false);
                }
                else // restart the server
                {
					SetNavBarInActive( bSetNewSettings);

                    R6PlayerController(GetPlayerOwner()).SendSettingsAndRestartServer( false, bSetNewSettings);
                }
                break;
            case EPopUpID_MPKitRest:
                pKitRest = R6MenuMPRestKitMain( m_pPopUpKitRest.m_ClientArea);
                
                // we have to set the new kit rest settings
                bSetNewSettings = pKitRest.SendNewRestrictionsKit();
                
                // restart the server
                R6PlayerController(GetPlayerOwner()).SendSettingsAndRestartServer( true, bSetNewSettings);
                break;
        }
    }
}

//==============================================================================
// RefreshServerInfo -  refresh the server info  
//==============================================================================
function RefreshServerInfo()
{
	local R6MenuInGameMultiPlayerRootWindow R6Root;
	R6Root = R6MenuInGameMultiPlayerRootWindow(Root);
        
    m_Counter = 0;

	if (!R6Root.m_bPreventMenuSwitch)
	{
		if (R6Root.m_R6GameMenuCom != None)
		{
			R6Root.m_R6GameMenuCom.RefreshMPlayerInfo();

			m_pMPInterHeader.RefreshInterHeaderInfo();
			m_pR6AlphaTeam.RefreshTeamBarInfo( R6Root.m_R6GameMenuCom.ePlayerTeamSelection.PTS_Alpha);
			if (m_pR6BravoTeam.bWindowVisible)
				m_pR6BravoTeam.RefreshTeamBarInfo( R6Root.m_R6GameMenuCom.ePlayerTeamSelection.PTS_Bravo);
			if (m_pR6MissionObj.bWindowVisible)
				m_pR6MissionObj.m_pMissionObj.UpdateObjectives();
		}
	}

    if (m_pPopUpBoxCurrent != None)
    {
        if (m_pPopUpBoxCurrent.bWindowVisible)
        {
            if (m_pPopUpBoxCurrent.m_ePopUpID == EPopUpID_MPKitRest)
            {
                if (m_bRefreshRestKit)
                {
                    m_bRefreshRestKit = false;
                    R6MenuMPRestKitMain(m_pPopUpKitRest.m_ClientArea).RefreshKitRest();
                }

                R6MenuMPRestKitMain(m_pPopUpKitRest.m_ClientArea).Refresh();
            }
            else if (m_pPopUpBoxCurrent.m_ePopUpID == EPopUpID_MPServerOpt)
            {
				R6MenuMPCreateGameTab(m_pPopUpServerOption.m_ClientArea).Refresh();
            }
			else if (m_pPopUpBoxCurrent.m_ePopUpID == EPopUpID_MPGearRoom)
			{
				RefreshGearMenu();
			}
        }
        else
        {
            m_bRefreshRestKit = true;
        }
    }
}

//==============================================================================
// RefreshGearMenu -  refresh the gear menu  
//==============================================================================
function RefreshGearMenu( optional BOOL _bForceUpdate)
{
	local BOOL bForceUpdate;

	bForceUpdate = _bForceUpdate;

	if (m_pPopUpGearRoom == None)
	{
		PopUpGearMenu(); // force to create the gearmenu
		bForceUpdate = true;
	}

	R6MenuMPAdvGearWidget(m_pPopUpGearRoom.m_ClientArea).RefreshGearInfo( bForceUpdate);
}

function SetWindowSize( UWindowWindow _W, FLOAT _fX, FLOAT _fY, FLOAT _fW, FLOAT _fH)
{
    _W.WinTop    = _fY;
	_W.WinLeft   = _fX;
	_W.WinWidth  = _fW;
	_W.WinHeight = _fH;
}

function SetNavBarInActive( BOOL _bDisable, optional BOOL _bError)
{
	if (_bError)
	{
		if (m_bNavBarActive)
			return;
		else
			m_bNavBarActive = _bDisable;
	}
	else
	{
		m_bNavBarActive = _bDisable;
	}

	m_pInGameNavBar.SetNavBarState( m_bNavBarActive);
}

//====================================================================================================
//====================================================================================================
// THOSES FUNCTIONS ARE ONLY FOR COOP MODE
//==============================================================================
// IsMissionInProgress -  Is mission is on progress  
//==============================================================================
function BOOL IsMissionInProgress()
{
	local R6MenuInGameMultiPlayerRootWindow R6Root;
	R6Root = R6MenuInGameMultiPlayerRootWindow(Root);

    return  R6Root.m_R6GameMenuCom.m_GameRepInfo.m_bRepMObjInProgress == 1;
}

function BYTE GetLastMissionSuccess()
{
	local R6MenuInGameMultiPlayerRootWindow R6Root;
	R6Root = R6MenuInGameMultiPlayerRootWindow(Root);

    return R6Root.m_R6GameMenuCom.m_GameRepInfo.m_bRepLastRoundSuccess;
}


function BOOL IsMissionSuccess()
{
	local R6MenuInGameMultiPlayerRootWindow R6Root;
	R6Root = R6MenuInGameMultiPlayerRootWindow(Root);

    return  R6Root.m_R6GameMenuCom.m_GameRepInfo.m_bRepMObjSuccess == 1;
}

defaultproperties
{
}
