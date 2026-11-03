class MP2MenuMPMenuTab extends R6MenuMPMenuTab;

const C_fGM_COLUMNSWIDTH = 146;
const C_fGM_RIGHT_COLUMNSWIDTH = 146;
const C_fWIDTH_BETWEEN_BUT = 6;

var R6WindowButtonBox m_pGameTypeIntruderAdv;
var R6WindowButtonBox m_pGameTypeVirusUploadAdv;
var R6WindowButtonBox m_pGameTypeLimitSeatsAdv;
var R6WindowButtonBox m_pGameTypeFreeBackUpAdv;
var R6WindowButtonBox m_pGameTypeGazAlertAdv;

function UpdateGameTypeFilter()
{
    local MP2MenuMultiPlayerWidget Menu;

    Menu = MP2MenuMultiPlayerWidget(OwnerWindow);
    if(m_pGameTypeIntruderAdv != none)
    {
        m_pGameTypeIntruderAdv.m_bSelected = Menu.m_bFilterIntruderAdv;
        m_pGameTypeVirusUploadAdv.m_bSelected = Menu.m_bFilterVirusUploadAdv;
        m_pGameTypeGazAlertAdv.m_bSelected = Menu.m_bFilterGazAlertAdv;
        m_pGameTypeFreeBackUpAdv.m_bSelected = Menu.m_bFilterFreeBackUpAdv;
        m_pGameTypeLimitSeatsAdv.m_bSelected = Menu.m_bFilterLimitSeatsAdv;
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
    m_pGameModeText.SetBorderParam(2, (3.0 * float(146)) + float(4 * 6), 1.0, 1.0, Root.Colors.White);
    m_pGameModeText.m_Font = Root.Fonts[F_SmallTitle];
    m_pGameModeText.m_vTextColor = Root.Colors.BlueLight;
    m_pGameModeText.AddTextLabel(Caps(Localize("MultiPlayer", "GameMode_Adversarial", "R6Menu")), 5.0, 3.0, 146.0 * float(3), TA_Left, false);
    m_pGameModeText.AddTextLabel(Caps(Localize("MultiPlayer", "GameMode_Cooperative", "R6Menu")), (3.0 * float(146)) + float(5 * 6), 3.0, 146.0, TA_Left, false);
    fXOffset = 6.0;
    fYOffset = 18.0;
    fYStep = 17.0;
    fWidth = 146.0;
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
    fYOffset += fYStep;
    m_pGameTypeHostageAdv = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeHostageAdv.m_TextFont = ButtonFont;
    m_pGameTypeHostageAdv.m_vTextColor = Root.Colors.White;
    m_pGameTypeHostageAdv.m_vBorder = Root.Colors.White;
    m_pGameTypeHostageAdv.CreateTextAndBox(Localize("MultiPlayer", "GameType_HostageAdv", "R6Menu"), Localize("Tip", "SrvGameType_HostageAdv", "R6Menu"), 0.0, R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_HostageAdv);
    fXOffset = 146.0 + float(2 * 6);
    fYOffset = 18.0;
    m_pGameTypeEscort = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeEscort.m_TextFont = ButtonFont;
    m_pGameTypeEscort.m_vTextColor = Root.Colors.White;
    m_pGameTypeEscort.m_vBorder = Root.Colors.White;
    m_pGameTypeEscort.CreateTextAndBox(Localize("MultiPlayer", "GameType_EscortGeneral", "R6Menu"), Localize("Tip", "SrvGameType_EscortGeneral", "R6Menu"), 0.0, R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_Escort);
    fYOffset += fYStep;
    m_pGameTypeLimitSeatsAdv = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeLimitSeatsAdv.m_TextFont = ButtonFont;
    m_pGameTypeLimitSeatsAdv.m_vTextColor = Root.Colors.White;
    m_pGameTypeLimitSeatsAdv.m_vBorder = Root.Colors.White;
    m_pGameTypeLimitSeatsAdv.CreateTextAndBox(Localize("MultiPlayer", "GameType_LimitSeatsAdv", "R6Menu"), Localize("Tip", "SrvGameType_LimitSeatsAdv", "R6Menu"), 0.0, MP2MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_LimitSeatsAdv);
    fYOffset += fYStep;
    m_pGameTypeFreeBackUpAdv = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeFreeBackUpAdv.m_TextFont = ButtonFont;
    m_pGameTypeFreeBackUpAdv.m_vTextColor = Root.Colors.White;
    m_pGameTypeFreeBackUpAdv.m_vBorder = Root.Colors.White;
    m_pGameTypeFreeBackUpAdv.CreateTextAndBox(Localize("MultiPlayer", "GameType_FreeBackupAdv", "R6Menu"), Localize("Tip", "SrvGameType_FreeBackupAdv", "R6Menu"), 0.0, MP2MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_FreeBackUpAdv);
    fYOffset += fYStep;
    m_pGameTypeGazAlertAdv = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeGazAlertAdv.m_TextFont = ButtonFont;
    m_pGameTypeGazAlertAdv.m_vTextColor = Root.Colors.White;
    m_pGameTypeGazAlertAdv.m_vBorder = Root.Colors.White;
    m_pGameTypeGazAlertAdv.CreateTextAndBox(Localize("MultiPlayer", "GameType_GazAlertAdv", "R6Menu"), Localize("Tip", "SrvGameType_GazAlertAdv", "R6Menu"), 0.0, MP2MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_GazAlertAdv);
    fXOffset = (2.0 * float(146)) + float(3 * 6);
    fYOffset = 18.0;
    m_pGameTypeIntruderAdv = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeIntruderAdv.m_TextFont = ButtonFont;
    m_pGameTypeIntruderAdv.m_vTextColor = Root.Colors.White;
    m_pGameTypeIntruderAdv.m_vBorder = Root.Colors.White;
    m_pGameTypeIntruderAdv.CreateTextAndBox(Localize("MultiPlayer", "GameType_IntruderAdv", "R6Menu"), Localize("Tip", "SrvGameType_IntruderAdv", "R6Menu"), 0.0, MP2MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_IntruderAdv);
    fYOffset += fYStep;
    m_pGameTypeVirusUploadAdv = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeVirusUploadAdv.m_TextFont = ButtonFont;
    m_pGameTypeVirusUploadAdv.m_vTextColor = Root.Colors.White;
    m_pGameTypeVirusUploadAdv.m_vBorder = Root.Colors.White;
    m_pGameTypeVirusUploadAdv.CreateTextAndBox(Localize("MultiPlayer", "GameType_VirusUploadAdv", "R6Menu"), Localize("Tip", "SrvGameType_VirusUploadAdv", "R6Menu"), 0.0, MP2MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_VirusUploadAdv);
    fXOffset = (3.0 * float(146)) + float(5 * 6);
    fYOffset = 18.0;
    fWidth = 146.0;
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
