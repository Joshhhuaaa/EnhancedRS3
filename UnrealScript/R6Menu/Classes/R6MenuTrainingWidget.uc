//=============================================================================
//  R6MenuTrainingWidget.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/12/11 * Created by Alexandre Dionne
//=============================================================================


class R6MenuTrainingWidget extends R6MenuWidget;

var color  m_TitleTextColor;

var bool	bshowlog;

var R6WindowButton	                    m_ButtonStart;
var R6WindowButton	                    m_ButtonMainMenu;
var R6WindowButton	                    m_ButtonOptions;

var R6WindowTextLabel		        	m_LMenuTitle; 

    
var R6MenuHelpWindow                    m_pHelpWindow;            // the help window (tooltip)
var R6WindowSimpleFramedWindow          m_Map;

var Texture                             m_mapPreviews[9];
var String                              m_mapNames[9];

//************************************************************************************************
//      Training sections Buttons
//************************************************************************************************
var R6WindowButton						m_pButBasics;
var R6WindowButton						m_pButShooting;
var R6WindowButton						m_pButExplosives;
var R6WindowButton						m_pButRoomClearing1;
var R6WindowButton						m_pButRoomClearing2;
var R6WindowButton						m_pButRoomClearing3;
var R6WindowButton						m_pButHostageRescue1;
var R6WindowButton						m_pButHostageRescue2;
var R6WindowButton						m_pButHostageRescue3;

var R6WindowButton						m_pButCurrent;

////////////////////////////////////////////////////////////////////////////////////////////////////

var   Font    m_LeftButtonFont;
var   Font    m_LeftDownSizeFont;


function Created()
{
	local   Font                                buttonFont;       
    local   INT   XPos;
    local   R6WindowBitMap          mapBitmap;



	buttonFont		= Root.Fonts[F_PrincipalButton];        
    
    m_Map = R6WindowSimpleFramedWindow(CreateWindow(class'R6WindowSimpleFramedWindow', 198, 72, 422, 220, self));
    m_Map.CreateClientWindow(class'R6WindowBitMap');
    m_Map.m_eCornerType = All_Corners;   
    mapBitmap = R6WindowBitMap(m_Map.m_ClientArea);
    mapBitmap.R.X             = 0;
    mapBitmap.R.Y             = 0;
    mapBitmap.R.W             = mapBitmap.WinWidth;
    mapBitmap.R.H             = mapBitmap.WinHeight;
    mapBitmap.m_iDrawStyle    = ERenderStyle.STY_Normal;

    //=================================================================================
    // Help Zone
    //=================================================================================
    // create the help window
    m_pHelpWindow = R6MenuHelpWindow(CreateWindow(class'R6MenuHelpWindow', 150, 429, 340, 42, self)); //std param is set in help window    
    

	m_ButtonMainMenu                    = R6WindowButton(CreateControl( class'R6WindowButton', 10, 421, 250, 25, self));
    m_ButtonMainMenu.ToolTipString      = Localize("Tip","ButtonMainMenu","R6Menu");
	m_ButtonMainMenu.Text               = Localize("SinglePlayer","ButtonMainMenu","R6Menu");	
	m_ButtonMainMenu.Align              = TA_LEFT;	
	m_ButtonMainMenu.m_buttonFont       = buttonFont;
	m_ButtonMainMenu.ResizeToText();	

	m_ButtonOptions = R6WindowButton(CreateControl( class'R6WindowButton', 10, 452, 250, 25, self));
    m_ButtonOptions.ToolTipString       = Localize("Tip","ButtonOptions","R6Menu");
	m_ButtonOptions.Text                = Localize("SinglePlayer","ButtonOptions","R6Menu");	
	m_ButtonOptions.Align               = TA_LEFT;		
	m_ButtonOptions.m_buttonFont        = buttonFont;
	m_ButtonOptions.ResizeToText();    
	
    

    XPos = m_pHelpWindow.WinLeft + m_pHelpWindow.WinWidth;

	m_ButtonStart = R6WindowButton(CreateControl( class'R6WindowButton', XPos, 452, WinWidth - XPos - 20, 25, self));	
    m_ButtonStart.ToolTipString     = Localize("Tip","ButtonStart","R6Menu");
	m_ButtonStart.Text              = Localize("CustomMission","ButtonStart1","R6Menu");	
	m_ButtonStart.Align             = TA_RIGHT;		
	m_ButtonStart.m_buttonFont      = buttonFont;
	m_ButtonStart.ResizeToText();		
    m_ButtonStart.m_bWaitSoundFinish= true;

    
	m_TitleTextColor = Root.Colors.White;
		
	
	m_LMenuTitle        = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 0, 18, WinWidth - 20, 25, self));
	m_LMenuTitle.Text           = Localize("Training","Title","R6Menu");
	m_LMenuTitle.Align          = TA_Right;
	m_LMenuTitle.m_Font         = Root.Fonts[F_MenuMainTitle];
	m_LMenuTitle.TextColor      = m_TitleTextColor;
	m_LMenuTitle.m_BGTexture    = None;
    m_LMenuTitle.m_bDrawBorders = False;  
    
}

function ShowWindow()
{
    Super.ShowWindow();
    // randomly update the background texture
	Root.SetLoadRandomBackgroundImage("Training");
}

//=================================================================================
// Setup Help Text
//=================================================================================
function ToolTip(string strTip) 
{
    m_pHelpWindow.ToolTip(strTip);
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
	Root.PaintBackground( C, self);
}

function CurrentSelectedButton( R6WindowButton _IwasPressed)
{
    local   R6WindowBitMap          mapBitmap;
    
    if(m_pButCurrent != None)
        m_pButCurrent.m_bSelected = false;
    
    _IwasPressed.m_bSelected = true;
    m_pButCurrent = _IwasPressed;


    mapBitmap = R6WindowBitMap(m_Map.m_ClientArea);    
    mapBitmap.T = m_mapPreviews[_IwasPressed.m_iButtonID];
    
}

//------------------------------------------------------------------
// SetCurrentMissionInTraining
//	set the mission description
//------------------------------------------------------------------
function SetCurrentMissionInTraining()
{
    local R6MissionDescription mission;
    local R6console r6Console;
    local int iMission;
    local string szMapName1, szMapName2;

    r6console = R6Console( Root.Console );
    
    // loop on campaign and list all thier mission in the right order
    szMapName2 = r6console.master.m_StartGameInfo.m_MapName;
    szMapName2 = Caps( szMapName2 );

    iMission = 0;
    while ( iMission < r6console.m_aMissionDescriptions.length )
    {
        mission = r6console.m_aMissionDescriptions[iMission];
        szMapName1 = mission.m_MapName;
        szMapName1 = Caps( szMapName1 );
        if ( szMapName1 == szMapName2 )
        {
            r6console.master.m_StartGameInfo.m_CurrentMission = mission;
            return;
        }
        iMission++;
    }
}

function Notify(UWindowDialogControl C, byte E)
{             
    if(E == DE_Click)
    {
        
        switch(C)
        {
        case m_ButtonMainMenu:
			Root.ChangeCurrentWidget(MainMenuWidgetID);
			break;
		case m_ButtonOptions:
			Root.ChangeCurrentWidget(OptionsWidgetID);
			break;	
        case m_pButBasics:
        case m_pButShooting:
        case m_pButExplosives:
        case m_pButRoomClearing1:
        case m_pButRoomClearing2:
        case m_pButRoomClearing3:
        case m_pButHostageRescue1:
        case m_pButHostageRescue2:
        case m_pButHostageRescue3:
            CurrentSelectedButton(R6WindowButton(C));            
            break;
        case m_ButtonStart:
            StartTraining();
            break;
        }       
        
    }
    if(E == DE_DoubleClick)
    {        
        switch(C)
        {
        case m_pButBasics:
        case m_pButShooting:
        case m_pButExplosives:
        case m_pButRoomClearing1:
        case m_pButRoomClearing2:
        case m_pButRoomClearing3:
        case m_pButHostageRescue1:
        case m_pButHostageRescue2:
        case m_pButHostageRescue3:
            CurrentSelectedButton(R6WindowButton(C));            
            StartTraining();
            break;
        
        }       
        
    }
}

function StartTraining()
{
    local R6StartGameInfo           StartGameInfo;
    local R6FileManagerPlanning     pFileManager;
    local INT                       i,j;
    local int                       iNbTeam;
    local string                    szMapName;
    local string                    szMenuMapName;
    local string                    szSaveName;
    local string                    szLoadErrorMsg;   
    
    StartGameInfo = R6Console(Root.console).master.m_StartGameInfo;
    
    StartGameInfo.m_MapName = m_mapNames[m_pButCurrent.m_iButtonID];
    SetCurrentMissionInTraining();
    
    StartGameInfo.m_GameMode = "R6Game.R6TrainingMgr";
    
    szMapName = StartGameInfo.m_MapName;
    szMapName = Caps( szMapName );
    
    if(szMapName == "TRAINING_BASICS"    ||
        szMapName == "TRAINING_SHOOTING"  ||
        szMapName == "TRAINING_EXPLOSIVES" )
    {
        StartGameInfo.m_TeamInfo[0].m_iNumberOfMembers = 1;
        iNbTeam = 1;
        StartGameInfo.m_TeamInfo[0].m_iSpawningPointNumber = 1;
        
        StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_CharacterName   = Localize("Training","ROOKIE","R6Menu");
        StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_ArmorName = "R6Characters.R6RainbowLightBlue";
        StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_szSpecialityID  = "ID_ASSAULT";
        StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_FaceTexture          =  class'R6RookieAssault'.default.m_TMenuFaceSmall;
        StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_FaceCoords.X         =  class'R6RookieAssault'.default.m_RMenuFaceSmallX;
        StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_FaceCoords.Y         =  class'R6RookieAssault'.default.m_RMenuFaceSmallY;
        StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_FaceCoords.Z         =  class'R6RookieAssault'.default.m_RMenuFaceSmallW;
        StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_FaceCoords.W         =  class'R6RookieAssault'.default.m_RMenuFaceSmallH;
        StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_WeaponName[0]   = "";
        StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_WeaponName[1]   = "";
        StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_BulletType[0]   = "";
        StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_BulletType[1]   = "";
        StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_WeaponGadgetName[0] = "";
        StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_WeaponGadgetName[1] = "";
        StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_GadgetName[0]   = "";
        StartGameInfo.m_TeamInfo[0].m_CharacterInTeam[0].m_GadgetName[1]   = "";
        
    }
    
    Root.Console.ViewportOwner.bShowWindowsMouse = False;
    R6Console(Root.console).LaunchTraining();
    close();
}

function CreateButtons()
{
    
    local FLOAT fXOffset, fYOffset, fWidth, fHeight, fYPos;    
    
    fXOffset = 10;
    //fYOffset = 35;

    fYOffset = 26;
    
    fWidth   = 200;    
    fHeight  = 25; 
    fYPos    = 64;
 
    
    m_pButBasics = R6WindowButton(CreateControl( class'R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
    m_pButBasics.ToolTipString		= Localize("Tip","ButtonBasics","R6Menu");
    m_pButBasics.Text				= Localize("Training","ButtonBasics","R6Menu");    
    m_pButBasics.Align				= TA_Left;    
    m_pButBasics.m_buttonFont		= m_LeftButtonFont;
    m_pButBasics.m_iButtonID        = 0;
    m_pButBasics.bIgnoreLDoubleClick = false;
    m_pButBasics.CheckToDownSizeFont(m_LeftDownSizeFont,0);
    m_pButBasics.ResizeToText();       
    
    fYPos += fYOffset;

    m_pButShooting = R6WindowButton(CreateControl( class'R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
    m_pButShooting.ToolTipString	= Localize("Tip","ButtonShooting","R6Menu");
    m_pButShooting.Text				= Localize("Training","ButtonShooting","R6Menu");    
    m_pButShooting.Align			= TA_Left;    
    m_pButShooting.m_buttonFont		= m_LeftButtonFont;
    m_pButShooting.m_iButtonID      = 1;
    m_pButShooting.bIgnoreLDoubleClick = false;
    m_pButShooting.CheckToDownSizeFont(m_LeftDownSizeFont,0);
    m_pButShooting.ResizeToText();        

    fYPos += fYOffset;

    m_pButExplosives = R6WindowButton(CreateControl( class'R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
    m_pButExplosives.ToolTipString		= Localize("Tip","ButtonExplosives","R6Menu");
    m_pButExplosives.Text				= Localize("Training","ButtonExplosives","R6Menu");    
    m_pButExplosives.Align				= TA_Left;    
    m_pButExplosives.m_buttonFont		= m_LeftButtonFont;
    m_pButExplosives.m_iButtonID        = 2;
    m_pButExplosives.bIgnoreLDoubleClick = false;
    m_pButExplosives.CheckToDownSizeFont(m_LeftDownSizeFont,0);
    m_pButExplosives.ResizeToText();    
    
    fYPos += fYOffset;


    m_pButRoomClearing1 = R6WindowButton(CreateControl( class'R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
    m_pButRoomClearing1.ToolTipString		= Localize("Tip","ButtonClearing1","R6Menu");
    m_pButRoomClearing1.Text				= Localize("Training","ButtonClearing1","R6Menu");    
    m_pButRoomClearing1.Align				= TA_Left;    
    m_pButRoomClearing1.m_buttonFont		= m_LeftButtonFont;
    m_pButRoomClearing1.m_iButtonID         = 3;
    m_pButRoomClearing1.bIgnoreLDoubleClick = false;    
    m_pButRoomClearing1.CheckToDownSizeFont(m_LeftDownSizeFont,0);
    m_pButRoomClearing1.ResizeToText();    
    
    fYPos += fYOffset;


    m_pButRoomClearing2 = R6WindowButton(CreateControl( class'R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
    m_pButRoomClearing2.ToolTipString		= Localize("Tip","ButtonClearing2","R6Menu");
    m_pButRoomClearing2.Text				= Localize("Training","ButtonClearing2","R6Menu");    
    m_pButRoomClearing2.Align				= TA_Left;    
    m_pButRoomClearing2.m_buttonFont		= m_LeftButtonFont;
    m_pButRoomClearing2.m_iButtonID         = 4;
    m_pButRoomClearing2.bIgnoreLDoubleClick = false;
    m_pButRoomClearing2.CheckToDownSizeFont(m_LeftDownSizeFont,0);
    m_pButRoomClearing2.ResizeToText();    
    
    fYPos += fYOffset;


    m_pButRoomClearing3 = R6WindowButton(CreateControl( class'R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
    m_pButRoomClearing3.ToolTipString		= Localize("Tip","ButtonClearing3","R6Menu");
    m_pButRoomClearing3.Text				= Localize("Training","ButtonClearing3","R6Menu");    
    m_pButRoomClearing3.Align				= TA_Left;    
    m_pButRoomClearing3.m_buttonFont		= m_LeftButtonFont;
    m_pButRoomClearing3.m_iButtonID         = 5;
    m_pButRoomClearing3.bIgnoreLDoubleClick = false;
    m_pButRoomClearing3.CheckToDownSizeFont(m_LeftDownSizeFont,0);
    m_pButRoomClearing3.ResizeToText();    
    
    fYPos += fYOffset;

    m_pButHostageRescue1 = R6WindowButton(CreateControl( class'R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
    m_pButHostageRescue1.ToolTipString		= Localize("Tip","ButtonHostageRescue1","R6Menu");
    m_pButHostageRescue1.Text				= Localize("Training","ButtonHostageRescue1","R6Menu");    
    m_pButHostageRescue1.Align				= TA_Left;    
    m_pButHostageRescue1.m_buttonFont		= m_LeftButtonFont;
    m_pButHostageRescue1.m_iButtonID        = 6;
    m_pButHostageRescue1.bIgnoreLDoubleClick = false;
    m_pButHostageRescue1.CheckToDownSizeFont(m_LeftDownSizeFont,0);
    m_pButHostageRescue1.ResizeToText();    
    
    fYPos += fYOffset;


    m_pButHostageRescue2 = R6WindowButton(CreateControl( class'R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
    m_pButHostageRescue2.ToolTipString		= Localize("Tip","ButtonHostageRescue2","R6Menu");
    m_pButHostageRescue2.Text				= Localize("Training","ButtonHostageRescue2","R6Menu");    
    m_pButHostageRescue2.Align				= TA_Left;    
    m_pButHostageRescue2.m_buttonFont		= m_LeftButtonFont;
    m_pButHostageRescue2.m_iButtonID        = 7;
    m_pButHostageRescue2.bIgnoreLDoubleClick = false;
    m_pButHostageRescue2.CheckToDownSizeFont(m_LeftDownSizeFont,0);
    m_pButHostageRescue2.ResizeToText();    
    
    fYPos += fYOffset;


    m_pButHostageRescue3 = R6WindowButton(CreateControl( class'R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
    m_pButHostageRescue3.ToolTipString		= Localize("Tip","ButtonHostageRescue3","R6Menu");
    m_pButHostageRescue3.Text				= Localize("Training","ButtonHostageRescue3","R6Menu");    
    m_pButHostageRescue3.Align				= TA_Left;    
    m_pButHostageRescue3.m_buttonFont		= m_LeftButtonFont;
    m_pButHostageRescue3.m_iButtonID        = 8;
    m_pButHostageRescue3.bIgnoreLDoubleClick = false;
    m_pButHostageRescue3.CheckToDownSizeFont(m_LeftDownSizeFont,0);
    m_pButHostageRescue3.ResizeToText();
    
    CurrentSelectedButton(m_pButBasics);
    
}


function BOOL ButtonsUsingDownSizeFont()
{
    local BOOL result;    
    
    if( m_pButBasics.IsFontDownSizingNeeded()        ||
        m_pButShooting.IsFontDownSizingNeeded()      ||
        m_pButExplosives.IsFontDownSizingNeeded()    ||
        m_pButRoomClearing1.IsFontDownSizingNeeded() ||
        m_pButRoomClearing2.IsFontDownSizingNeeded() ||
        m_pButRoomClearing3.IsFontDownSizingNeeded() ||
        m_pButHostageRescue1.IsFontDownSizingNeeded()||
        m_pButHostageRescue2.IsFontDownSizingNeeded()||
        m_pButHostageRescue3.IsFontDownSizingNeeded()
        
       )
        result = true;    

    return result;
}


function ForceFontDownSizing()
{
    m_pButBasics.m_buttonFont = m_LeftDownSizeFont;
    m_pButShooting.m_buttonFont       = m_LeftDownSizeFont;
    m_pButExplosives.m_buttonFont      = m_LeftDownSizeFont;
    m_pButRoomClearing1.m_buttonFont  = m_LeftDownSizeFont;
    m_pButRoomClearing2.m_buttonFont = m_LeftDownSizeFont;
    m_pButRoomClearing3.m_buttonFont       = m_LeftDownSizeFont;
    m_pButHostageRescue1.m_buttonFont      = m_LeftDownSizeFont;
    m_pButHostageRescue2.m_buttonFont  = m_LeftDownSizeFont;
    m_pButHostageRescue3.m_buttonFont = m_LeftDownSizeFont;


    m_pButBasics.ResizeToText();
    m_pButShooting.ResizeToText();
    m_pButExplosives.ResizeToText();
    m_pButRoomClearing1.ResizeToText();
    m_pButRoomClearing2.ResizeToText();
    m_pButRoomClearing3.ResizeToText();
    m_pButHostageRescue1.ResizeToText();
    m_pButHostageRescue2.ResizeToText();
    m_pButHostageRescue3.ResizeToText();
}

defaultproperties
{
     m_mapPreviews(0)=Texture'R6MenuBG.TrainingMenu.Training_basics'
     m_mapPreviews(1)=Texture'R6MenuBG.TrainingMenu.Training_shooting'
     m_mapPreviews(2)=Texture'R6MenuBG.TrainingMenu.Training_explosives'
     m_mapPreviews(3)=Texture'R6MenuBG.TrainingMenu.Training_RoomClear1'
     m_mapPreviews(4)=Texture'R6MenuBG.TrainingMenu.Training_RoomClear2'
     m_mapPreviews(5)=Texture'R6MenuBG.TrainingMenu.Training_RoomClear3'
     m_mapPreviews(6)=Texture'R6MenuBG.TrainingMenu.Training_Hostage1'
     m_mapPreviews(7)=Texture'R6MenuBG.TrainingMenu.Training_Hostage2'
     m_mapPreviews(8)=Texture'R6MenuBG.TrainingMenu.Training_Hostage3'
     m_mapNames(0)="Training_basics"
     m_mapNames(1)="Training_shooting"
     m_mapNames(2)="Training_explosives"
     m_mapNames(3)="Training_RoomClear1"
     m_mapNames(4)="Training_RoomClear2"
     m_mapNames(5)="Training_RoomClear3"
     m_mapNames(6)="Training_Hostage1"
     m_mapNames(7)="Training_Hostage2"
     m_mapNames(8)="Training_Hostage3"
}
