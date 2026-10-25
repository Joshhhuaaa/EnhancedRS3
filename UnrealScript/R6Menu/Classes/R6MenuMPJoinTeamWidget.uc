//=============================================================================
//  R6MenuMPJoinTeamWidget.uc : The first in game multi player menu window
//  the size of the window is 800 * 600
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//    2002/03/7  * Modify by Yannick Joly
//=============================================================================
class R6MenuMPJoinTeamWidget extends R6MenuWidget;

const C_iMIN_TIME_FOR_WELCOME_SCREEN			= 10;

var R6WindowButtonMPInGame          m_pButAlphaTeam;
var R6WindowButtonMPInGame          m_pButBravoTeam;
var R6WindowButtonMPInGame          m_pButAutoTeam;
var R6WindowButtonMPInGame          m_pButSpectator;

var R6WindowButtonMPInGame          m_pButCurrentSelected;

var R6WindowTextLabelExt            m_pInfoText;

var R6MenuHelpWindow                m_pHelpTextWindow;
var Region                          m_pHelpReg;

var INT                             m_iYBetweenButtonPadding; //Vertical padding between buttons
var INT                             m_iButtonHeight, m_iButtonWidth;

//Character Texture
var R6WindowBitmap                  m_SingleChar;
var R6WindowBitmap                  m_LeftChar;
var R6WindowBitmap                  m_RightChar;
var R6WindowBitmap                  m_BetweenCharIcon;

var INT                             m_iSingleCharXPos, m_iSingleCharYPos,   //Coordinates where these elements are displayed
                                    m_iLeftCharXPos, m_iLeftCharYPos,
                                    m_iRightCharXPos, m_iRightCharYPos,
                                    m_iBetweenCharXPos, m_iBetweenCharYPos;

var Texture                         m_TBetweenChar;
var Region                          m_RBetweenChar;
var Texture                         m_TSpectatorChar;
var Region                          m_RSpectatorChar;

var Texture                         m_TAlphaChar;
var Region                          m_RAlphaChar;
var Texture                         m_TBetaChar;
var Region                          m_RBetaChar;

var Array<Class>                    m_AArmorDescriptions;

var FLOAT							m_fTimeForRefresh;					// time before a refresh
var FLOAT							m_fTimeAutoTeam;					// time before forcing auto team

var bool                            m_bIsTeamGame;

var string  m_szMenuGreenTeamPawnClass; // backup Class and check if they have changed (server can change them)
var string  m_szMenuRedTeamPawnClass;

function Created()
{
    FillDescriptionArray();
    CreateTextLabels();
    CreateButtons();
    CreateBitmaps();

    m_pHelpTextWindow = R6MenuHelpWindow(CreateWindow(class'R6MenuHelpWindow', m_pHelpReg.X, m_pHelpReg.Y, m_pHelpReg.W, m_pHelpReg.H, self)); //std param is set in help window
    
}

//===============================================================================
// Fills the array with all R6ArmorDescription to retreive Level armor texture 
// and texture coordinates
//===============================================================================
function FillDescriptionArray()
{
    local class<R6ArmorDescription>    DescriptionClass;  

	// MPF - Eric
	local INT	i;
	local R6Mod	pCurrentMod;
	pCurrentMod = class'Actor'.static.GetModMgr().m_pCurrentMod;
	
	for (i = 0; i < pCurrentMod.m_aDescriptionPackage.Length; i++)
	{
		DescriptionClass = class<R6ArmorDescription>(GetFirstPackageClass(pCurrentMod.m_aDescriptionPackage[i]$".u", class'R6ArmorDescription'));
		
		while( DescriptionClass != None )
		{
			
			m_AArmorDescriptions[m_AArmorDescriptions.Length] = DescriptionClass;
			DescriptionClass = class<R6ArmorDescription>(GetNextClass());
		}  
		
		FreePackageObjects();
	}
}
       
function Tick(float deltaTime)
{
	local string szAutoSelection;

    if ( m_szMenuGreenTeamPawnClass != GetLevel().GreenTeamPawnClass ||
         (m_szMenuRedTeamPawnClass   != GetLevel().RedTeamPawnClass && m_bIsTeamGame) )
    {        
        RefreshBitmaps();
    }

	if (m_bIsTeamGame)
	{
		if (m_fTimeForRefresh >= 4.0)
		{
			RefreshButtonsStatus();
			m_fTimeForRefresh = 0;
		}
		else
		{
			// Incremant timer for refresh
			m_fTimeForRefresh += deltaTime;
		}
	}

	//===========================================================================
	// FOR AUTOTEAM CHEAT, according an automatic selection
	if (m_fTimeAutoTeam > C_iMIN_TIME_FOR_WELCOME_SCREEN)
	{
		szAutoSelection = class'Actor'.static.GetGameOptions().MPAutoSelection;

		if ( szAutoSelection ~= "GREEN")
		{
			m_pButAlphaTeam.Click(0,0); // force a click
			class'Actor'.static.GetGameOptions().SaveConfig();
		} 
		else if ( szAutoSelection ~= "SPECTATOR")
		{
			m_pButSpectator.Click(0,0);
			class'Actor'.static.GetGameOptions().SaveConfig();
		}
		else if (m_bIsTeamGame)
		{
			if (szAutoSelection ~= "RED")
			{
				m_pButBravoTeam.Click(0,0); 
				class'Actor'.static.GetGameOptions().SaveConfig();
			}
			else if (szAutoSelection ~= "AUTOTEAM")
			{
				m_pButAutoTeam.Click(0,0);
				class'Actor'.static.GetGameOptions().SaveConfig();
			}
		}

		m_fTimeAutoTeam = 0;
	}
	else
	{
		m_fTimeAutoTeam += deltaTime;
	}
	//===========================================================================
}

//===============================================================================
//       Called by the root just after the showwindow()
//===============================================================================
function SetMenuToDisplay( string _szCurrentGameType)
{
    m_bIsTeamGame       = GetLevel().IsGameTypeTeamAdversarial( _szCurrentGameType);

    RefreshServerInfo();
    RefreshButtons(_szCurrentGameType);
    RefreshBitmaps();
    RefreshButtonsStatus();

	m_fTimeAutoTeam = 0;
}

//===============================================================================
// Refresh server info after we display the menu page
//===============================================================================
function RefreshServerInfo()
{
	local R6MenuInGameMultiPlayerRootWindow R6Root;
	R6Root = R6MenuInGameMultiPlayerRootWindow(Root);
        
    if (R6Root.m_R6GameMenuCom.m_GameRepInfo != None)
    {
        m_pInfoText.ChangeTextLabel( Localize("MPInGame","ServerName","R6Menu") $ " " $ R6Root.m_R6GameMenuCom.m_GameRepInfo.ServerName, 0); // server name
		m_pInfoText.ChangeTextLabel(((Localize("MPInGame", "GameVersion", "R6Menu")) $ " ") $ class'Actor'.static.GetGameVersion(true, !class'Actor'.static.GetModMgr().IsRavenShield()), 1);
        m_pInfoText.ChangeTextLabel( R6Root.m_R6GameMenuCom.m_GameRepInfo.MOTDLine1, 3); // msg of the day      
    }
}


//===============================================================================
//       INIT SECTION Called after we display the page
//===============================================================================
//===============================================================================
//       Initial Creation of the buttons
//===============================================================================
function CreateButtons()
{
	local Font  buttonFont;
    local FLOAT fXOffset, fYOffset;

    fXOffset = R6MenuInGameMultiPlayerRootWindow(OwnerWindow).m_RJoinWidget.X + 100;
    fYOffset = R6MenuInGameMultiPlayerRootWindow(OwnerWindow).m_RJoinWidget.Y + 100;       

	buttonFont		= Root.Fonts[F_PrincipalButton];
	
    // define Alpha Team Button
	m_pButAlphaTeam = R6WindowButtonMPInGame(CreateControl( class'R6WindowButtonMPInGame', fXOffset, fYOffset, m_iButtonWidth, m_iButtonHeight, self));    
    m_pButAlphaTeam.Text                = Localize("MPInGame","AlphaTeam","R6Menu");
	m_pButAlphaTeam.m_eButInGame_Action = Button_AlphaTeam;
	m_pButAlphaTeam.Align               = TA_Left;
	m_pButAlphaTeam.m_fFontSpacing      = 2;
	m_pButAlphaTeam.m_buttonFont        = buttonFont;
	m_pButAlphaTeam.ResizeToText();

    fYOffset += m_iButtonHeight + m_iYBetweenButtonPadding;

    // define Bravo Team Button
	m_pButBravoTeam = R6WindowButtonMPInGame(CreateControl( class'R6WindowButtonMPInGame', fXOffset, fYOffset, m_iButtonWidth, m_iButtonHeight, self));    
    m_pButBravoTeam.Text                = Localize("MPInGame","BravoTeam","R6Menu");
	m_pButBravoTeam.m_eButInGame_Action = Button_BravoTeam;
	m_pButBravoTeam.Align               = TA_Left;
	m_pButBravoTeam.m_fFontSpacing      = 2;
	m_pButBravoTeam.m_buttonFont        = buttonFont;
	m_pButBravoTeam.ResizeToText();

    fYOffset += m_iButtonHeight + m_iYBetweenButtonPadding;

    // define Auto Team button
	m_pButAutoTeam = R6WindowButtonMPInGame(CreateControl( class'R6WindowButtonMPInGame', fXOffset, fYOffset, m_iButtonWidth, m_iButtonHeight, self));
    m_pButAutoTeam.ToolTipString       = Localize("Tip","AutoTeam","R6Menu");
    m_pButAutoTeam.Text                = Localize("MPInGame","AutoTeam","R6Menu");
	m_pButAutoTeam.m_eButInGame_Action = Button_AutoTeam;
	m_pButAutoTeam.Align               = TA_Left;
	m_pButAutoTeam.m_fFontSpacing      = 2;
	m_pButAutoTeam.m_buttonFont        = buttonFont;
	m_pButAutoTeam.ResizeToText();

    fYOffset += m_iButtonHeight +m_iYBetweenButtonPadding;

    // define Spectator button
	m_pButSpectator = R6WindowButtonMPInGame(CreateControl( class'R6WindowButtonMPInGame', fXOffset, fYOffset, m_iButtonWidth, m_iButtonHeight, self));
    m_pButSpectator.ToolTipString       = Localize("Tip","Spectator","R6Menu");;
    m_pButSpectator.Text                = Localize("MPInGame","Spectator","R6Menu");
	m_pButSpectator.m_eButInGame_Action = Button_Spectator;
	m_pButSpectator.Align               = TA_Left;
	m_pButSpectator.m_fFontSpacing      = 2;
	m_pButSpectator.m_buttonFont        = buttonFont;
	m_pButSpectator.ResizeToText();
}

function RefreshButtons(string _szCurrentGameType)
{

    local FLOAT fSpectatorYPos;


    if (!m_bIsTeamGame)
    {
        //Play Button	    
        m_pButAlphaTeam.ToolTipString       = GetLevel().GetGreenTeamObjective(_szCurrentGameType);        
        m_pButAlphaTeam.Text                = Localize("MPInGame","Play","R6Menu");
	    m_pButAlphaTeam.m_eButInGame_Action = Button_Play;	    
        m_pButAlphaTeam.ResizeToText();

        //Hide the two unused buttons        
        m_pButBravoTeam.HideWindow();    
        m_pButAutoTeam.HideWindow();     
        
        fSpectatorYPos = m_pButAlphaTeam.WinTop + m_pButAlphaTeam.WinHeight +  m_iYBetweenButtonPadding;
    }
    else
    {
        
        //Alpha Team Button
        m_pButAlphaTeam.ToolTipString       = GetLevel().GetGreenTeamObjective(_szCurrentGameType);        
        m_pButAlphaTeam.Text                = Localize("MPInGame","AlphaTeam","R6Menu");
	    m_pButAlphaTeam.m_eButInGame_Action = Button_AlphaTeam;        
        m_pButAlphaTeam.ResizeToText();
        
        //Show Bravo Team Button	    
        m_pButBravoTeam.ShowWindow();        
        m_pButBravoTeam.ToolTipString       = GetLevel().GetRedTeamObjective(_szCurrentGameType);        

        //Show Auto Team button	    
        m_pButAutoTeam.ShowWindow();
        
        fSpectatorYPos = m_pButAutoTeam.WinTop + m_pButAutoTeam.WinHeight +  m_iYBetweenButtonPadding;
    }

    // Spectator button
    m_pButSpectator.WinTop = fSpectatorYPos;
    
}

function RefreshButtonsStatus()
{
	local R6MenuInGameMultiPlayerRootWindow R6Root;
	R6Root = R6MenuInGameMultiPlayerRootWindow(Root);

	m_pButAlphaTeam.bDisabled = false;
	m_pButBravoTeam.bDisabled = false;

	if ( R6Root.m_R6GameMenuCom.GetNbOfTeamPlayer( true) >= 8) // 8 is the max of player in a list
	{
		if (m_pButAlphaTeam.m_eButInGame_Action == Button_AlphaTeam)
			m_pButAlphaTeam.bDisabled = true;
	}
	
    if ( R6Root.m_R6GameMenuCom.GetNbOfTeamPlayer( false) >= 8)
	{
		m_pButBravoTeam.bDisabled = true;
	}
}

//===============================================================================
//       Initial Creation of the text labels
//===============================================================================
function CreateTextLabels()
{
    local FLOAT fXOffset, fYOffset, fYStep, fWidth, fHeight, fTemp, fSizeOfCounter;

    fXOffset = R6MenuInGameMultiPlayerRootWindow(OwnerWindow).m_RJoinWidget.X;
    fYOffset = R6MenuInGameMultiPlayerRootWindow(OwnerWindow).m_RJoinWidget.Y;
    fWidth   = R6MenuInGameMultiPlayerRootWindow(OwnerWindow).m_RJoinWidget.W;
    fHeight  = R6MenuInGameMultiPlayerRootWindow(OwnerWindow).m_RJoinWidget.H;

    // Use text array with R6WindowTextLabelExt
    m_pInfoText = R6WindowTextLabelExt( CreateWindow(class'R6WindowTextLabelExt', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pInfoText.bAlwaysBehind = true;
    m_pInfoText.SetNoBorder();

    // text part
    m_pInfoText.m_Font = Root.Fonts[F_VerySmallTitle];
    m_pInfoText.m_vTextColor = Root.Colors.White;

    fXOffset = 4;
    fYOffset = R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize() + 3;
    fWidth = fWidth * 0.5;
    m_pInfoText.AddTextLabel( Localize("MPInGame","ServerName","R6Menu"), fXOffset, fYOffset, fWidth, TA_Left, false); 

    fXOffset = fWidth + 4;
    fYOffset = R6MenuRSLookAndFeel(LookAndFeel).GetTextHeaderSize() + 3;
    m_pInfoText.AddTextLabel( Localize("MPInGame","GameVersion","R6Menu"), fXOffset, fYOffset, fWidth, TA_Left, false);

    fXOffset = 4;
    fYOffset = fHeight - 40;
    fWidth = fWidth;
    m_pInfoText.m_Font = Root.Fonts[F_SmallTitle]; // special font
    m_pInfoText.AddTextLabel( Localize("MPInGame","PleaseNote","R6Menu"), fXOffset, fYOffset, fWidth, TA_Left, false);
    m_pInfoText.m_Font = Root.Fonts[F_VerySmallTitle];

    fXOffset = 4;
    fYOffset = fHeight - 20;
    fWidth = fWidth;
    m_pInfoText.AddTextLabel( "", fXOffset, fYOffset, fWidth, TA_Left, false);
}


//===============================================================================
//       Initial Creation of the Bitmaps
//===============================================================================
function CreateBitmaps()
{

    m_SingleChar = R6WindowBitmap(CreateWindow(class'R6WindowBitmap',m_iSingleCharXPos,m_iSingleCharYPos,m_RSpectatorChar.W,m_RSpectatorChar.H,self));
    m_SingleChar.m_iDrawStyle = 5;
    m_SingleChar.HideWindow();
    //m_SingleChar.m_bDrawBorder = true;
    
    m_LeftChar = R6WindowBitmap(CreateWindow(class'R6WindowBitmap',m_iLeftCharXPos,m_iLeftCharYPos,m_RSpectatorChar.W,m_RSpectatorChar.H,self));
    m_LeftChar.m_iDrawStyle = 5;
    m_LeftChar.HideWindow();
    m_LeftChar.m_bHorizontalFlip = true;
    //m_LeftChar.m_bDrawBorder = true;
    
    m_RightChar = R6WindowBitmap(CreateWindow(class'R6WindowBitmap',m_iRightCharXPos,m_iRightCharYPos,m_RSpectatorChar.W,m_RSpectatorChar.H,self));
    m_RightChar.m_iDrawStyle = 5;
    m_RightChar.HideWindow();
    //m_RightChar.m_bHorizontalFlip = true;
    //m_RightChar.m_bDrawBorder = true;

    m_BetweenCharIcon = R6WindowBitmap(CreateWindow(class'R6WindowBitmap',m_iBetweenCharXPos,m_iBetweenCharYPos,m_RBetweenChar.W,m_RBetweenChar.H,self));
    m_BetweenCharIcon.m_iDrawStyle = 5;
    m_BetweenCharIcon.HideWindow();    
    m_BetweenCharIcon.T = m_TBetweenChar; 
    m_BetweenCharIcon.R = m_RBetweenChar;
    //m_BetweenCharIcon.m_bDrawBorder = true;

}

//===============================================================================
//       Called after the menu is displayed
//===============================================================================
function RefreshBitmaps()
{
	m_TAlphaChar    = Texture(GetLevel().GreenMenuSkin);
	m_RAlphaChar    = GetLevel().GreenMenuRegion;    
	m_TBetaChar     = Texture(GetLevel().RedMenuSkin);
	m_RBetaChar     = GetLevel().RedMenuRegion;

    m_LeftChar.T    = m_TAlphaChar;
    m_LeftChar.R    = m_RAlphaChar;

    m_RightChar.T   = m_TBetaChar;
    m_RightChar.R   = m_RBetaChar;    


    m_SingleChar.HideWindow();
    m_LeftChar.HideWindow();
    m_RightChar.HideWindow();
    m_BetweenCharIcon.HideWindow();    

    if(m_pButCurrentSelected != None)
    {
        Notify(m_pButCurrentSelected, DE_MouseEnter);
    }
    
}

/////////////////////////////////////////////////////////////////
// display the help text in the m_pHelpTextWindow (derivate for uwindowwindow
/////////////////////////////////////////////////////////////////
function ToolTip(string strTip) 
{
    m_pHelpTextWindow.ToolTip(strTip);
}


//===============================================================================
//       This allow us to switch the right bitmap accordingly
//===============================================================================
function Notify(UWindowDialogControl C, byte E)
{
	if(E == DE_MouseEnter)
    {
		if (R6WindowButtonMPInGame(C).bDisabled)
			return;

        switch(C)
        {
        case m_pButAlphaTeam:
            m_SingleChar.ShowWindow();
            m_SingleChar.T = m_TAlphaChar;
            m_SingleChar.R = m_RAlphaChar;            
            m_pButCurrentSelected = m_pButAlphaTeam;
            break;
        case m_pButBravoTeam:
            m_SingleChar.ShowWindow();
            m_SingleChar.T = m_TBetaChar;
            m_SingleChar.R = m_RBetaChar;           
            m_pButCurrentSelected = m_pButBravoTeam;
            break;
        case m_pButAutoTeam:            
            m_LeftChar.ShowWindow();
            m_RightChar.ShowWindow();
            m_BetweenCharIcon.ShowWindow();
            m_pButCurrentSelected = m_pButAutoTeam;
            break;
        case m_pButSpectator:
            m_SingleChar.ShowWindow();
            m_SingleChar.T = m_TSpectatorChar;
            m_SingleChar.R = m_RSpectatorChar;            
            m_pButCurrentSelected = m_pButSpectator;
            break;            
        }
    }
    else if(E == DE_MouseLeave )
    {
		if (R6WindowButtonMPInGame(C).bDisabled)
			return;

        switch(C)
        {
        case m_pButAlphaTeam:
        case m_pButBravoTeam:         
        case m_pButSpectator:
            m_SingleChar.HideWindow();        
            m_pButCurrentSelected = None;
            break;            
        case m_pButAutoTeam:             
            m_LeftChar.HideWindow();
            m_RightChar.HideWindow();
            m_BetweenCharIcon.HideWindow();
            m_pButCurrentSelected = None;
            break;  
        }
    }

    
}

function HideWindow()
{
    Super.HideWindow();
    m_pButCurrentSelected = None;
}

defaultproperties
{
     m_iYBetweenButtonPadding=20
     m_iButtonHeight=25
     m_iButtonWidth=220
     m_iSingleCharXPos=420
     m_iSingleCharYPos=120
     m_iLeftCharXPos=340
     m_iLeftCharYPos=120
     m_iRightCharXPos=491
     m_iRightCharYPos=120
     m_iBetweenCharXPos=453
     m_iBetweenCharYPos=170
     m_TBetweenChar=Texture'R6MenuTextures.Gui_BoxScroll'
     m_TSpectatorChar=Texture'R6MenuTextures.Gui_BoxScroll'
     m_pHelpReg=(X=45,Y=326,W=299,H=40)
     m_RBetweenChar=(X=188,Y=396,W=58,H=77)
     m_RSpectatorChar=(X=112,Y=145,W=133,H=251)
}
