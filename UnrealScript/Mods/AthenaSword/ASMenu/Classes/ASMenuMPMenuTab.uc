class ASMenuMPMenuTab extends R6MenuMPMenuTab;

var R6WindowButtonBox m_pGameTypeTerroHuntAdv;
var R6WindowButtonBox m_pGameTypeScattHuntAdv;
var R6WindowButtonBox m_pGameTypeCaptTheEnemyAdv;
var R6WindowButtonBox m_pGameTypeKamikaze;

function UpdateGameTypeFilter()
{
    local ASMenuMultiPlayerWidget Menu;

    Menu = ASMenuMultiPlayerWidget(OwnerWindow);
    if(m_pGameTypeTerroHuntAdv != none)
    {
        m_pGameTypeTerroHuntAdv.m_bSelected = Menu.m_bFilterTerroristHuntAdv;
        m_pGameTypeScattHuntAdv.m_bSelected = Menu.m_bFilterScatteredHuntAdv;
        m_pGameTypeCaptTheEnemyAdv.m_bSelected = Menu.m_bFilterCaptureTheEnemyAdv;
        m_pGameTypeKamikaze.m_bSelected = Menu.m_bFilterKamikaze;
    }
    super.UpdateGameTypeFilter();
}

function InitGameModeTab()
{
    local float fXOffset, fYOffset, fYStep, fWidth, fHeight;

    local Font ButtonFont;

    m_pGameModeText = R6WindowTextLabelExt(CreateWindow(Class'R6Window.R6WindowTextLabelExt', 0.0, 0.0, 2.0 * float(310), 90.0, self));
    m_pGameModeText.bAlwaysBehind = true;
    m_pGameModeText.ActiveBorder(0, false);
    m_pGameModeText.ActiveBorder(1, false);
    m_pGameModeText.SetBorderParam(2, 155.0 * float(3), 1.0, 1.0, Root.Colors.White);
    m_pGameModeText.m_Font = Root.Fonts[F_SmallTitle];
    m_pGameModeText.m_vTextColor = Root.Colors.BlueLight;
    m_pGameModeText.AddTextLabel(Caps(Localize("MultiPlayer", "GameMode_Adversarial", "R6Menu")), 5.0, 3.0, 155.0 * float(3), TA_Left, false);
    m_pGameModeText.AddTextLabel(Caps(Localize("MultiPlayer", "GameMode_Cooperative", "R6Menu")), 5.0 + float(C_fGM_COLUMNSWIDTH * 3), 3.0, 155.0, TA_Left, false);
    fXOffset = 5.0;
    fYOffset = 20.0;
    fYStep = 25.0;
    fWidth = 155.0;
    fHeight = 14.0;
    ButtonFont = Root.Fonts[F_CheckBoxButton];
    m_pGameTypeDeadMatch = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeDeadMatch.m_TextFont = ButtonFont;
    m_pGameTypeDeadMatch.m_vTextColor = Root.Colors.White;
    m_pGameTypeDeadMatch.m_vBorder = Root.Colors.White;
    m_pGameTypeDeadMatch.CreateTextAndBox(Localize("MultiPlayer", "GameType_Death", "R6Menu"), Localize("Tip", "SrvGameType_Death", "R6Menu"), 0.0, R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_DeathMatch);
    fYOffset += fYStep;
    m_pGameTypeTDeadMatch = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeTDeadMatch.m_TextFont = ButtonFont;
    m_pGameTypeTDeadMatch.m_vTextColor = Root.Colors.White;
    m_pGameTypeTDeadMatch.m_vBorder = Root.Colors.White;
    m_pGameTypeTDeadMatch.CreateTextAndBox(Localize("MultiPlayer", "GameType_TeamDeath", "R6Menu"), Localize("Tip", "SrvGameType_TeamDeath", "R6Menu"), 0.0, R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_TeamDeathMatch);
    fYOffset += fYStep;
    m_pGameTypeDisarmBomb = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeDisarmBomb.m_TextFont = ButtonFont;
    m_pGameTypeDisarmBomb.m_vTextColor = Root.Colors.White;
    m_pGameTypeDisarmBomb.m_vBorder = Root.Colors.White;
    m_pGameTypeDisarmBomb.CreateTextAndBox(Localize("MultiPlayer", "GameType_DisarmBomb", "R6Menu"), Localize("Tip", "SrvGameType_DisarmBomb", "R6Menu"), 0.0, R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_Bomb);
    fXOffset = 10.0 + float(155);
    fYOffset = 20.0;
    fWidth -= float(20);
    m_pGameTypeHostageAdv = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeHostageAdv.m_TextFont = ButtonFont;
    m_pGameTypeHostageAdv.m_vTextColor = Root.Colors.White;
    m_pGameTypeHostageAdv.m_vBorder = Root.Colors.White;
    m_pGameTypeHostageAdv.CreateTextAndBox(Localize("MultiPlayer", "GameType_HostageAdv", "R6Menu"), Localize("Tip", "SrvGameType_HostageAdv", "R6Menu"), 0.0, R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_HostageAdv);
    fYOffset += fYStep;
    m_pGameTypeEscort = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeEscort.m_TextFont = ButtonFont;
    m_pGameTypeEscort.m_vTextColor = Root.Colors.White;
    m_pGameTypeEscort.m_vBorder = Root.Colors.White;
    m_pGameTypeEscort.CreateTextAndBox(Localize("MultiPlayer", "GameType_EscortGeneral", "R6Menu"), Localize("Tip", "SrvGameType_EscortGeneral", "R6Menu"), 0.0, R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_Escort);
    fYOffset += fYStep;
    m_pGameTypeTerroHuntAdv = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeTerroHuntAdv.m_TextFont = ButtonFont;
    m_pGameTypeTerroHuntAdv.m_vTextColor = Root.Colors.White;
    m_pGameTypeTerroHuntAdv.m_vBorder = Root.Colors.White;
    m_pGameTypeTerroHuntAdv.CreateTextAndBox(Localize("MultiPlayer", "GameType_TerroristAdv", "R6Menu"), Localize("Tip", "SrvGameType_TerroristHuntAdv", "R6Menu"), 0.0, ASMenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_TerroristAdv);
    fXOffset = 5.0 + float(C_fGM_COLUMNSWIDTH * 2);
    fYOffset = 20.0;
    m_pGameTypeScattHuntAdv = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeScattHuntAdv.m_TextFont = ButtonFont;
    m_pGameTypeScattHuntAdv.m_vTextColor = Root.Colors.White;
    m_pGameTypeScattHuntAdv.m_vBorder = Root.Colors.White;
    m_pGameTypeScattHuntAdv.CreateTextAndBox(Localize("MultiPlayer", "GameType_ScatteredAdv", "R6Menu"), Localize("Tip", "SrvGameType_ScatteredAdv", "R6Menu"), 0.0, ASMenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_ScatteredAdv);
    fYOffset += fYStep;
    m_pGameTypeCaptTheEnemyAdv = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeCaptTheEnemyAdv.m_TextFont = ButtonFont;
    m_pGameTypeCaptTheEnemyAdv.m_vTextColor = Root.Colors.White;
    m_pGameTypeCaptTheEnemyAdv.m_vBorder = Root.Colors.White;
    m_pGameTypeCaptTheEnemyAdv.CreateTextAndBox(Localize("MultiPlayer", "GameType_CaptTheEnemyAdv", "R6Menu"), Localize("Tip", "SrvGameType_CaptTheEnemyAdv", "R6Menu"), 0.0, ASMenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_CaptTheEnemyAdv);
    fYOffset += fYStep;
    m_pGameTypeKamikaze = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeKamikaze.m_TextFont = ButtonFont;
    m_pGameTypeKamikaze.m_vTextColor = Root.Colors.White;
    m_pGameTypeKamikaze.m_vBorder = Root.Colors.White;
    m_pGameTypeKamikaze.CreateTextAndBox(Localize("MultiPlayer", "GameType_Kamikaze", "R6Menu"), Localize("Tip", "SrvGameType_Kamikaze", "R6Menu"), 0.0, ASMenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_Kamikaze);
    fXOffset = 5.0 + float(155 * 3);
    fYOffset = 20.0;
    m_pGameTypeMission = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeMission.m_TextFont = ButtonFont;
    m_pGameTypeMission.m_vTextColor = Root.Colors.White;
    m_pGameTypeMission.m_vBorder = Root.Colors.White;
    m_pGameTypeMission.CreateTextAndBox(Localize("MultiPlayer", "GameType_Mission", "R6Menu"), Localize("Tip", "SrvGameType_Mission", "R6Menu"), 0.0, R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_Mission);
    fYOffset += fYStep;
    m_pGameTypeTerroHunt = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeTerroHunt.m_TextFont = ButtonFont;
    m_pGameTypeTerroHunt.m_vTextColor = Root.Colors.White;
    m_pGameTypeTerroHunt.m_vBorder = Root.Colors.White;
    m_pGameTypeTerroHunt.CreateTextAndBox(Localize("MultiPlayer", "GameType_Terrorist", "R6Menu"), Localize("Tip", "SrvGameType_Terrorist", "R6Menu"), 0.0, R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_Terrorist);
    fYOffset += fYStep;
    m_pGameTypeHostageCoop = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeHostageCoop.m_TextFont = ButtonFont;
    m_pGameTypeHostageCoop.m_vTextColor = Root.Colors.White;
    m_pGameTypeHostageCoop.m_vBorder = Root.Colors.White;
    m_pGameTypeHostageCoop.CreateTextAndBox(Localize("MultiPlayer", "GameType_HostageCoop", "R6Menu"), Localize("Tip", "SrvGameType_HostageCoop", "R6Menu"), 0.0, R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_HostageCoop);
    UpdateGameTypeFilter();
}
