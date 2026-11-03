class MP2ModConfig extends R6ModConfig;

function AddModSpecificGameModes(LevelInfo pLevelInfo)
{
    pLevelInfo.GameTypeInfoAdd("RGM_LimitSeatsAdvMode", "RGM_LimitSeatsAdvMode", GMI_Adversarial, true, true, false, true, false, "IronWrathGameMode", "MP2Game.MP2LimitSeatsAdvGame", Localize("MultiPlayer", "GameType_LimitSeatsAdv", "R6Menu"), "IronWrathGameMode", "IronWrathGameMode", "IronWrathGameMode", "IronWrathGameMode", "RGM_LimitSeatsAdvMode");
    pLevelInfo.GameTypeInfoAdd("RGM_FreeBackupAdvMode", "RGM_FreeBackupAdvMode", GMI_Adversarial, true, true, false, false, false, "IronWrathGameMode", "MP2Game.MP2FreeBackupAdvGame", Localize("MultiPlayer", "GameType_FreeBackupAdv", "R6Menu"), "IronWrathGameMode", "IronWrathGameMode", "IronWrathGameMode", "IronWrathGameMode", "RGM_FreeBackupAdvMode");
    pLevelInfo.GameTypeInfoAdd("RGM_GazAlertAdvMode", "RGM_GazAlertAdvMode", GMI_Adversarial, true, true, false, true, false, "IronWrathGameMode", "MP2Game.MP2GazAlertAdvGame", Localize("MultiPlayer", "GameType_GazAlertAdv", "R6Menu"), "IronWrathGameMode", "IronWrathGameMode", "IronWrathGameMode", "IronWrathGameMode", "RGM_GazAlertAdvMode");
    pLevelInfo.GameTypeInfoAdd("RGM_IntruderAdvMode", "RGM_IntruderAdvMode", GMI_Adversarial, true, true, false, true, false, "IronWrathGameMode", "MP2Game.MP2IntruderAdvGame", Localize("MultiPlayer", "GameType_IntruderAdv", "R6Menu"), "IronWrathGameMode", "IronWrathGameMode", "IronWrathGameMode", "IronWrathGameMode", "RGM_IntruderAdvMode");
    pLevelInfo.GameTypeInfoAdd("RGM_VirusUploadAdvMode", "RGM_VirusUploadAdvMode", GMI_Adversarial, true, true, false, true, false, "IronWrathGameMode", "MP2Game.MP2VirusUploadAdvGame", Localize("MultiPlayer", "GameType_VirusUploadAdv", "R6Menu"), "IronWrathGameMode", "IronWrathGameMode", "IronWrathGameMode", "IronWrathGameMode", "RGM_VirusUploadAdvMode");
    pLevelInfo.GameTypeInfoAdd("RGM_NoRulesMode", "RGM_NoRulesMode", GMI_None, true, false, false, true, true, "No Rule", "R6Game.R6NoRules", "GameType_Debug", "", "", "", "", "RGM_NoRulesMode");
}
