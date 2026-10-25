//=============================================================================
//  R6MenuMainWidget.uc : Game Main Menu
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//	Main Menu
//
//  Revision history:
//    2001/11/08 * Created by Alexandre Dionne
//=============================================================================
class R6MenuMainWidget extends R6MenuWidget;

var R6WindowButtonMainMenu  m_ButtonSinglePlayer;
var R6WindowButtonMainMenu  m_ButtonCustomMission;
var R6WindowButtonMainMenu  m_ButtonMultiPlayer;
var R6WindowButtonMainMenu  m_ButtonTraining;
var R6WindowButtonMainMenu  m_ButtonOption;
var R6WindowButtonMainMenu  m_ButtonCredits;
var R6WindowButtonMainMenu  m_ButtonQuit;

var R6WindowTextLabel		m_Version;


var FLOAT m_fButtonXpos, m_fButtonWidth, m_fButtonHeight,m_fFirstButtonYpos, m_fButtonOffset;

function Created()
{
    Local INT iRand;
	local R6GameOptions pGameOptions;

	pGameOptions = class'Actor'.static.GetGameOptions();

	if( pGameOptions.AutoPatchDownload ){
		class'eviLPatchService'.static.StartPatch();
	}

	m_ButtonSinglePlayer = R6WindowButtonMainMenu(CreateWindow( class'R6WindowButtonMainMenu', m_fButtonXpos, m_fFirstButtonYpos, m_fButtonWidth, m_fButtonHeight, self));
    m_ButtonSinglePlayer.ToolTipString = Localize("MainMenu","ButtonSinglePlayer","R6Menu");
	m_ButtonSinglePlayer.Text = Localize("MainMenu","ButtonSinglePlayer","R6Menu");
	m_ButtonSinglePlayer.m_eButton_Action = Button_SinglePlayer;
	m_ButtonSinglePlayer.Align = TA_Right;
    m_ButtonSinglePlayer.m_buttonFont  = Root.Fonts[F_FirstMenuButton];
	m_ButtonSinglePlayer.ResizeToText();
	

	m_ButtonCustomMission = R6WindowButtonMainMenu(CreateWindow( class'R6WindowButtonMainMenu', m_fButtonXpos, m_ButtonSinglePlayer.WinTop + m_fButtonOffset, m_fButtonWidth, m_fButtonHeight, self));
	m_ButtonCustomMission.ToolTipString = Localize("MainMenu","ButtonCustomMission","R6Menu");
	m_ButtonCustomMission.Text = Localize("MainMenu","ButtonCustomMission","R6Menu");
	m_ButtonCustomMission.m_eButton_Action = Button_CustomMission;
	m_ButtonCustomMission.Align = TA_Right;
    m_ButtonCustomMission.m_buttonFont  = Root.Fonts[F_FirstMenuButton];
	m_ButtonCustomMission.ResizeToText();
	

	m_ButtonMultiPlayer = R6WindowButtonMainMenu(CreateWindow( class'R6WindowButtonMainMenu', m_fButtonXpos, m_ButtonCustomMission.WinTop + m_fButtonOffset, m_fButtonWidth, m_fButtonHeight, self));
	m_ButtonMultiPlayer.ToolTipString = Localize("MainMenu","ButtonMultiPlayer","R6Menu");
	m_ButtonMultiPlayer.Text = Localize("MainMenu","ButtonMultiPlayer","R6Menu");
	m_ButtonMultiPlayer.m_eButton_Action = Button_MultiPlayer;
	m_ButtonMultiPlayer.Align = TA_Right;
    m_ButtonMultiPlayer.m_buttonFont  = Root.Fonts[F_FirstMenuButton];
	m_ButtonMultiPlayer.ResizeToText();

	m_ButtonTraining = R6WindowButtonMainMenu(CreateWindow( class'R6WindowButtonMainMenu', m_fButtonXpos, m_ButtonMultiPlayer.WinTop + m_fButtonOffset, m_fButtonWidth, m_fButtonHeight, self));
	m_ButtonTraining.ToolTipString = Localize("MainMenu","ButtonTraining","R6Menu");
	m_ButtonTraining.Text = Localize("MainMenu","ButtonTraining","R6Menu");
	m_ButtonTraining.m_eButton_Action = Button_Training;
	m_ButtonTraining.Align = TA_Right;
    m_ButtonTraining.m_buttonFont  = Root.Fonts[F_FirstMenuButton];
	m_ButtonTraining.ResizeToText();

    m_ButtonOption = R6WindowButtonMainMenu(CreateWindow( class'R6WindowButtonMainMenu', m_fButtonXpos, m_ButtonTraining.WinTop + m_fButtonOffset, m_fButtonWidth, m_fButtonHeight, self));
	m_ButtonOption.ToolTipString = Localize("MainMenu","ButtonOptions","R6Menu");
	m_ButtonOption.Text = Localize("MainMenu","ButtonOptions","R6Menu");
	m_ButtonOption.m_eButton_Action = Button_Options;
	m_ButtonOption.Align = TA_Right;
    m_ButtonOption.m_buttonFont  = Root.Fonts[F_FirstMenuButton];
	m_ButtonOption.ResizeToText();    	

	m_ButtonCredits = R6WindowButtonMainMenu(CreateWindow( class'R6WindowButtonMainMenu',m_fButtonXpos, m_ButtonOption.WinTop + m_fButtonOffset, m_fButtonWidth, m_fButtonHeight, self));
	m_ButtonCredits.ToolTipString = Localize("MainMenu","ButtonCredits","R6Menu");
	m_ButtonCredits.Text= Localize("MainMenu","ButtonCredits","R6Menu");
	m_ButtonCredits.m_eButton_Action = Button_Credits;
	m_ButtonCredits.Align = TA_Right;
    m_ButtonCredits.m_buttonFont  = Root.Fonts[F_FirstMenuButton];
	m_ButtonCredits.ResizeToText();

	m_ButtonQuit = R6WindowButtonMainMenu(CreateWindow( class'R6WindowButtonMainMenu', m_fButtonXpos, m_ButtonCredits.WinTop + m_fButtonOffset, m_fButtonWidth, m_fButtonHeight, self));
	m_ButtonQuit.ToolTipString = Localize("MainMenu","ButtonQuit","R6Menu");
	m_ButtonQuit.Text = Localize("MainMenu","ButtonQuit","R6Menu");
	m_ButtonQuit.m_eButton_Action = Button_Quit;
	m_ButtonQuit.Align = TA_Right;
    m_ButtonQuit.m_buttonFont  = Root.Fonts[F_FirstMenuButton];
	m_ButtonQuit.ResizeToText();

	m_Version = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 421, WinHeight - 18, 200, 15, self));	
	m_Version.SetProperties( class'Actor'.static.GetGameVersion( true),
                             TA_Right, Root.Fonts[F_ListItemSmall], Root.Colors.White, false);

#ifdefMPDEMO
	m_ButtonSinglePlayer.bDisabled  = true;
	m_ButtonCustomMission.bDisabled = true;
	m_ButtonTraining.bDisabled		= true;
#endif
    
#ifdefSPDEMO
     m_ButtonSinglePlayer.bDisabled = true;
     m_ButtonMultiPlayer.bDisabled = true;
     m_ButtonTraining.bDisabled = true;
#endif
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
	Root.PaintBackground( C, self);
}

function ShowWindow()
{
	// randomly update the background texture
    Root.SetLoadRandomBackgroundImage("");

	Super.ShowWindow();
}

defaultproperties
{
     m_fButtonXpos=371.000000
     m_fButtonWidth=250.000000
     m_fButtonHeight=35.000000
     m_fFirstButtonYpos=166.000000
     m_fButtonOffset=35.000000
}
