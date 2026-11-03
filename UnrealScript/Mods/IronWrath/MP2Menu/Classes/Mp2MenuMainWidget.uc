class Mp2MenuMainWidget extends R6MenuMainWidget;

function Created()
{
    local int iRand;
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    if(pGameOptions.AutoPatchDownload)
    {
        class'eviLPatchService'.static.StartPatch();
    }
    m_ButtonSinglePlayer = R6WindowButtonMainMenu(CreateWindow(Class'R6Menu.R6WindowButtonMainMenu', m_fButtonXpos, m_fFirstButtonYpos, m_fButtonWidth, m_fButtonHeight, self));
    m_ButtonSinglePlayer.ToolTipString = Localize("MainMenu", "ButtonSinglePlayer", "R6Menu");
    m_ButtonSinglePlayer.Text = Localize("MainMenu", "ButtonSinglePlayer", "R6Menu");
    m_ButtonSinglePlayer.m_eButton_Action = Button_SinglePlayer;
    m_ButtonSinglePlayer.Align = TA_Right;
    m_ButtonSinglePlayer.m_buttonFont = Root.Fonts[F_FirstMenuButton];
    m_ButtonSinglePlayer.ResizeToText();
    m_ButtonCustomMission = R6WindowButtonMainMenu(CreateWindow(Class'R6Menu.R6WindowButtonMainMenu', m_fButtonXpos, m_ButtonSinglePlayer.WinTop + m_fButtonOffset, m_fButtonWidth, m_fButtonHeight, self));
    m_ButtonCustomMission.ToolTipString = Localize("MainMenu", "ButtonCustomMission", "R6Menu");
    m_ButtonCustomMission.Text = Localize("MainMenu", "ButtonCustomMission", "R6Menu");
    m_ButtonCustomMission.m_eButton_Action = Button_CustomMission;
    m_ButtonCustomMission.Align = TA_Right;
    m_ButtonCustomMission.m_buttonFont = Root.Fonts[F_FirstMenuButton];
    m_ButtonCustomMission.ResizeToText();
    m_ButtonMultiPlayer = R6WindowButtonMainMenu(CreateWindow(Class'R6Menu.R6WindowButtonMainMenu', m_fButtonXpos, m_ButtonCustomMission.WinTop + m_fButtonOffset, m_fButtonWidth, m_fButtonHeight, self));
    m_ButtonMultiPlayer.ToolTipString = Localize("MainMenu", "ButtonMultiPlayer", "R6Menu");
    m_ButtonMultiPlayer.Text = Localize("MainMenu", "ButtonMultiPlayer", "R6Menu");
    m_ButtonMultiPlayer.m_eButton_Action = Button_MultiPlayer;
    m_ButtonMultiPlayer.Align = TA_Right;
    m_ButtonMultiPlayer.m_buttonFont = Root.Fonts[F_FirstMenuButton];
    m_ButtonMultiPlayer.ResizeToText();
    m_ButtonOption = R6WindowButtonMainMenu(CreateWindow(Class'R6Menu.R6WindowButtonMainMenu', m_fButtonXpos, m_ButtonMultiPlayer.WinTop + m_fButtonOffset, m_fButtonWidth, m_fButtonHeight, self));
    m_ButtonOption.ToolTipString = Localize("MainMenu", "ButtonOptions", "R6Menu");
    m_ButtonOption.Text = Localize("MainMenu", "ButtonOptions", "R6Menu");
    m_ButtonOption.m_eButton_Action = Button_Options;
    m_ButtonOption.Align = TA_Right;
    m_ButtonOption.m_buttonFont = Root.Fonts[F_FirstMenuButton];
    m_ButtonOption.ResizeToText();
    m_ButtonCredits = R6WindowButtonMainMenu(CreateWindow(Class'R6Menu.R6WindowButtonMainMenu', m_fButtonXpos, m_ButtonOption.WinTop + m_fButtonOffset, m_fButtonWidth, m_fButtonHeight, self));
    m_ButtonCredits.ToolTipString = Localize("MainMenu", "ButtonCredits", "R6Menu");
    m_ButtonCredits.Text = Localize("MainMenu", "ButtonCredits", "R6Menu");
    m_ButtonCredits.m_eButton_Action = Button_Credits;
    m_ButtonCredits.Align = TA_Right;
    m_ButtonCredits.m_buttonFont = Root.Fonts[F_FirstMenuButton];
    m_ButtonCredits.ResizeToText();
    m_ButtonQuit = R6WindowButtonMainMenu(CreateWindow(Class'R6Menu.R6WindowButtonMainMenu', m_fButtonXpos, m_ButtonCredits.WinTop + m_fButtonOffset, m_fButtonWidth, m_fButtonHeight, self));
    m_ButtonQuit.ToolTipString = Localize("MainMenu", "ButtonQuit", "R6Menu");
    m_ButtonQuit.Text = Localize("MainMenu", "ButtonQuit", "R6Menu");
    m_ButtonQuit.m_eButton_Action = Button_Quit;
    m_ButtonQuit.Align = TA_Right;
    m_ButtonQuit.m_buttonFont = Root.Fonts[F_FirstMenuButton];
    m_ButtonQuit.ResizeToText();
    m_Version = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 421.0, WinHeight - float(18), 200.0, 15.0, self));
    m_Version.SetProperties(class'Actor'.static.GetGameVersion(true, true), TA_Right, Root.Fonts[F_ListItemSmall], Root.Colors.White, false);
}

defaultproperties
{
    m_fFirstButtonYpos=201.0
}
