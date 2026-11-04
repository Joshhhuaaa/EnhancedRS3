class ASMenuCustomMissionWidget extends R6MenuCustomMissionWidget
    config(User);

var R6WindowButton m_pButCountDown;

function bool IsMission_StoryOrClassic(R6MissionDescription selectedMission)
{
    local int i, strlength, numWords;
    local string szMissionBriefing;

    if(selectedMission == none)
    {
        return false;
    }
    szMissionBriefing = Localize(selectedMission.m_MapName, "ID_CLARK", selectedMission.LocalizationFile, true, true);
    strlength = Len(szMissionBriefing) - 1;
    numWords = 1;

    for(i = 0; i < strlength; i++)
    {
        if(Mid(szMissionBriefing, i, 1) == " ")
        {
            numWords++;
        }
    }
    return numWords > 2;
}

function UpdateBackground()
{
    if(GetLevel().GameTypeUseNbOfTerroristToSpawn(GetLevel().ConvertGameTypeIntToString(m_pButCurrent.m_iButtonID)) || ((m_pButCurrent == m_pButCountDown) && !IsMission_StoryOrClassic(R6MissionDescription(R6WindowListBoxItem(m_GameLevelBox.GetSelectedItem()).m_Object))))
    {
        m_DifficultyArea.SetCornerType(Top_Corners);
        m_TerroArea.ShowWindow();
        Root.SetLoadRandomBackgroundImage("OtherMission");
    }
    else
    {
        m_DifficultyArea.SetCornerType(All_Corners);
        m_TerroArea.HideWindow();
        Root.SetLoadRandomBackgroundImage("PracticeMission");
    }
}

function Notify(UWindowDialogControl C, byte E)
{
    local R6WindowListBoxItem SelectedItem;
    local R6MissionDescription CurrentMission;
    local R6WindowBitMap mapBitmap;

    if(int(E) == DE_Click)
    {
        switch(C)
        {
            case m_ButtonMainMenu:
                Root.ChangeCurrentWidget(MainMenuWidgetID);
                break;
            case m_ButtonOptions:
                Root.ChangeCurrentWidget(OptionsWidgetID);
                break;
            case m_ButtonStart:
                if(ValidateBeforePlanning())
                {
                    GotoPlanning();
                }
                break;
            case m_pButPraticeMission:
            case m_pButLoneWolf:
            case m_pButTerroHunt:
            case m_pButHostageRescue:
            case m_pButCountDown:
            case m_pButCurrent:
                m_pButCurrent.m_bSelected = false;
                R6WindowButton(C).m_bSelected = true;
                m_pButCurrent = R6WindowButton(C);
                RefreshList();
                break;
            case m_GameLevelBox:
                mapBitmap = R6WindowBitMap(m_Map.m_ClientArea);
                SelectedItem = R6WindowListBoxItem(m_GameLevelBox.m_SelectedItem);
                if(SelectedItem == none)
                {
                    mapBitmap.t = none;
                    break;
                }
                if(m_pButCurrent == m_pButCountDown)
                {
                    if(!IsMission_StoryOrClassic(R6MissionDescription(SelectedItem.m_Object)))
                    {
                        m_DifficultyArea.SetCornerType(Top_Corners);
                        m_TerroArea.ShowWindow();
                        Root.SetLoadRandomBackgroundImage("OtherMission");
                    }
                    else
                    {
                        m_DifficultyArea.SetCornerType(All_Corners);
                        m_TerroArea.HideWindow();
                        Root.SetLoadRandomBackgroundImage("PracticeMission");
                    }
                }
                if(SelectedItem.m_Object == none)
                {
                    break;
                }
                CurrentMission = R6MissionDescription(SelectedItem.m_Object);
                if(CurrentMission == none)
                {
                    break;
                }
                mapBitmap.R = CurrentMission.m_RMissionOverview;
                mapBitmap.t = CurrentMission.m_TMissionOverview;
                break;
            default:
                break;
        }

    }
    else
    {
        if(int(E) == DE_DoubleClick)
        {
            if(C == m_GameLevelBox)
            {
                if(ValidateBeforePlanning())
                {
                    GotoPlanning();
                }
            }
        }
    }
}

function CreateButtons()
{
    local float fXOffset, fYOffset, fWidth, fHeight, fYPos;

    fXOffset = 10.0;
    fYOffset = 26.0;
    fWidth = 200.0;
    fHeight = 25.0;
    fYPos = 64.0;
    m_pButPraticeMission = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
    m_pButPraticeMission.ToolTipString = Localize("Tip", "GameType_Practice", "R6Menu");
    m_pButPraticeMission.Text = Localize("CustomMission", "ButtonPractice", "R6Menu");
    m_pButPraticeMission.m_iButtonID = GetLevel().ConvertGameTypeToInt("RGM_PracticeMode");
    m_pButPraticeMission.Align = TA_Left;
    m_pButPraticeMission.m_buttonFont = m_LeftButtonFont;
    m_pButPraticeMission.CheckToDownSizeFont(m_LeftDownSizeFont, 0.0);
    m_pButPraticeMission.ResizeToText();
    fYPos += fYOffset;
    m_pButLoneWolf = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
    m_pButLoneWolf.ToolTipString = Localize("Tip", "GameType_LoneWolf", "R6Menu");
    m_pButLoneWolf.Text = Localize("CustomMission", "ButtonLoneWolf", "R6Menu");
    m_pButLoneWolf.m_iButtonID = GetLevel().ConvertGameTypeToInt("RGM_LoneWolfMode");
    m_pButLoneWolf.Align = TA_Left;
    m_pButLoneWolf.m_buttonFont = m_LeftButtonFont;
    m_pButLoneWolf.CheckToDownSizeFont(m_LeftDownSizeFont, 0.0);
    m_pButLoneWolf.ResizeToText();
    fYPos += fYOffset;
    m_pButTerroHunt = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
    m_pButTerroHunt.ToolTipString = Localize("Tip", "GameType_TerroristHunt", "R6Menu");
    m_pButTerroHunt.Text = Localize("CustomMission", "ButtonTerroHunt", "R6Menu");
    m_pButTerroHunt.m_iButtonID = GetLevel().ConvertGameTypeToInt("RGM_TerroristHuntMode");
    m_pButTerroHunt.Align = TA_Left;
    m_pButTerroHunt.m_buttonFont = m_LeftButtonFont;
    m_pButTerroHunt.CheckToDownSizeFont(m_LeftDownSizeFont, 0.0);
    m_pButTerroHunt.ResizeToText();
    fYPos += fYOffset;
    m_pButHostageRescue = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
    m_pButHostageRescue.ToolTipString = Localize("Tip", "GameType_HostageRescue", "R6Menu");
    m_pButHostageRescue.Text = Localize("CustomMission", "ButtonHostageRescue", "R6Menu");
    m_pButHostageRescue.m_iButtonID = GetLevel().ConvertGameTypeToInt("RGM_HostageRescueMode");
    m_pButHostageRescue.Align = TA_Left;
    m_pButHostageRescue.m_buttonFont = m_LeftButtonFont;
    m_pButHostageRescue.CheckToDownSizeFont(m_LeftDownSizeFont, 0.0);
    m_pButHostageRescue.ResizeToText();
    fYPos += fYOffset;
    m_pButCountDown = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
    m_pButCountDown.ToolTipString = Localize("Tip", "GameType_CountDown", "R6Menu");
    m_pButCountDown.Text = Localize("CustomMission", "ButtonCountDown", "R6Menu");
    m_pButCountDown.m_iButtonID = GetLevel().ConvertGameTypeToInt("RGM_CountDownMode");
    m_pButCountDown.Align = TA_Left;
    m_pButCountDown.m_buttonFont = m_LeftButtonFont;
    m_pButCountDown.CheckToDownSizeFont(m_LeftDownSizeFont, 0.0);
    m_pButCountDown.ResizeToText();
    switch(CustomMissionGameType)
    {
        case m_pButPraticeMission.m_iButtonID:
            m_pButCurrent = m_pButPraticeMission;
            break;
        case m_pButLoneWolf.m_iButtonID:
            m_pButCurrent = m_pButLoneWolf;
            break;
        case m_pButTerroHunt.m_iButtonID:
            m_pButCurrent = m_pButTerroHunt;
            break;
        case m_pButHostageRescue.m_iButtonID:
            m_pButCurrent = m_pButHostageRescue;
            break;
        case m_pButCountDown.m_iButtonID:
            m_pButCurrent = m_pButCountDown;
            break;
        default:
            m_pButCurrent = m_pButPraticeMission;
    }
    m_pButCurrent.m_bSelected = true;
}

function bool ButtonsUsingDownSizeFont()
{
    local bool Result;

    if((((m_pButPraticeMission.IsFontDownSizingNeeded() || m_pButLoneWolf.IsFontDownSizingNeeded()) || m_pButCountDown.IsFontDownSizingNeeded()) || m_pButTerroHunt.IsFontDownSizingNeeded()) || m_pButHostageRescue.IsFontDownSizingNeeded())
    {
        Result = true;
    }
    return Result;
}

function ForceFontDownSizing()
{
    m_pButPraticeMission.m_buttonFont = m_LeftDownSizeFont;
    m_pButLoneWolf.m_buttonFont = m_LeftDownSizeFont;
    m_pButTerroHunt.m_buttonFont = m_LeftDownSizeFont;
    m_pButHostageRescue.m_buttonFont = m_LeftDownSizeFont;
    m_pButCountDown.m_buttonFont = m_LeftDownSizeFont;
    m_pButPraticeMission.ResizeToText();
    m_pButLoneWolf.ResizeToText();
    m_pButTerroHunt.ResizeToText();
    m_pButHostageRescue.ResizeToText();
    m_pButCountDown.ResizeToText();
}
