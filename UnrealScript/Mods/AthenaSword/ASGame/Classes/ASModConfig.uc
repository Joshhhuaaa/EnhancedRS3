class ASModConfig extends R6ModConfig;

function AddModSpecificGameModes(LevelInfo pLevelInfo)
{
    pLevelInfo.GameTypeInfoAdd("RGM_TerroristHuntAdvMode", "RGM_TerroristHuntAdvMode", GMI_Adversarial, true, true, true, true, true, "ASGameMode", "ASGame.R6TerroristHuntAdvGame", Localize("MultiPlayer", "GameType_TerroristAdv", "R6Menu"), "ASGameMode", "ASGameMode", "ASGameMode", "ASGameMode", "RGM_TerroristHuntAdvMode");
    pLevelInfo.GameTypeInfoAdd("RGM_ScatteredHuntAdvMode", "RGM_ScatteredHuntAdvMode", GMI_Adversarial, true, true, true, true, true, "ASGameMode", "ASGame.R6ScatteredHuntAdvGame", Localize("MultiPlayer", "GameType_ScatteredAdv", "R6Menu"), "ASGameMode", "ASGameMode", "ASGameMode", "ASGameMode", "RGM_ScatteredHuntAdvMode");
    pLevelInfo.GameTypeInfoAdd("RGM_CaptureTheEnemyAdvMode", "RGM_CaptureTheEnemyAdvMode", GMI_Adversarial, true, true, false, false, true, "ASGameMode", "ASGame.R6CaptureTheEnemyAdvGame", Localize("MultiPlayer", "GameType_CaptTheEnemyAdv", "R6Menu"), "ASGameMode", "ASGameMode", "ASGameMode", "ASGameMode", "RGM_CaptureTheEnemyAdvMode");
    pLevelInfo.GameTypeInfoAdd("RGM_KamikazeMode", "RGM_KamikazeMode", GMI_Adversarial, true, true, false, false, true, "ASGameMode", "ASGame.R6KamikazeGame", Localize("MultiPlayer", "GameType_Kamikaze", "R6Menu"), "ASGameMode", "ASGameMode", "ASGameMode", "ASGameMode", "RGM_KamikazeMode");
    pLevelInfo.GameTypeInfoAdd("RGM_CountDownMode", "RGM_CountDownMode", GMI_SinglePlayer, false, false, false, true, false, "ASGameMode", "ASGame.R6CountdownGame", "loc CountDownMode", "", "", "", "", "RGM_CountDownMode");
    pLevelInfo.GameTypeSaveGameInfo(pLevelInfo.m_aGameTypeInfo.Length - 1, Localize("SaveGameDirectory", "SaveGameType_Countdown", "R6Engine"), "Countdown");
}
