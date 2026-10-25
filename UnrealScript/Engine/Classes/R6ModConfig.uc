//=============================================================================
//  R6ModConfig.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

// mod configuration.  Spawned to configure the current mod
class R6ModConfig extends Object;

function AddModSpecificGameModes(LevelInfo pLevelInfo)
{
	pLevelInfo.GameTypeInfoAdd( "RGM_StoryMode", "RGM_StoryMode", GMI_SinglePlayer, false, false,  false, true, true,
		"R6GameMode", "R6Game.R6StoryModeGame", "loc story mode",
		"", "", 
		"", "", "RGM_StoryMode");

	pLevelInfo.GameTypeSaveGameInfo( pLevelInfo.m_aGameTypeInfo.Length - 1, 
		Localize("SaveGameDirectory","SaveGameType_Mission","R6Engine"), 
		"Mission");

	pLevelInfo.GameTypeInfoAdd( "RGM_PracticeMode", "RGM_PracticeMode", GMI_SinglePlayer, false, false,  false, true, true,
		"R6GameMode", "R6Game.R6PracticeModeGame", "loc practice mode",
		"", "", 
		"", "", "RGM_PracticeMode");

	pLevelInfo.GameTypeSaveGameInfo( pLevelInfo.m_aGameTypeInfo.Length - 1, 
		Localize("SaveGameDirectory","SaveGameType_Mission","R6Engine"), 
		"Mission");

	pLevelInfo.GameTypeInfoAdd( "RGM_MissionMode", "RGM_MissionMode", GMI_Cooperative,  false, true,  false, true, true,
		"R6GameMode", "R6Game.R6MissionGame", Localize("MultiPlayer","GameType_Mission","R6Menu"),
		"R6GameMode", "", 
		"R6GameMode", "", "RGM_MissionMode");

	pLevelInfo.GameTypeInfoAdd( "RGM_TerroristHuntMode", "RGM_TerroristHuntMode", GMI_SinglePlayer, false, false,  true, true, true, 
		"R6GameMode", "R6Game.R6TerroristHuntGame", Localize("MultiPlayer","GameType_Terrorist","R6Menu"),
		"","", 
		"", "", "RGM_TerroristHuntMode");

	pLevelInfo.GameTypeSaveGameInfo( pLevelInfo.m_aGameTypeInfo.Length - 1, 
		Localize("SaveGameDirectory","SaveGameType_TerroristHunt","R6Engine"), 
		"Terrorist Hunt");

	pLevelInfo.GameTypeInfoAdd( "RGM_TerroristHuntCoopMode", "RGM_TerroristHuntCoopMode", GMI_Cooperative,  false, true,  true, true, true,
		"R6GameMode", "R6Game.R6TerroristHuntCoopGame", Localize("MultiPlayer","GameType_Terrorist","R6Menu"),
		"R6GameMode", "",
		"R6GameMode", "", "RGM_TerroristHuntCoopMode");

	pLevelInfo.GameTypeInfoAdd( "RGM_HostageRescueMode", "RGM_HostageRescueMode", GMI_SinglePlayer, false, false,  true, true, true, 
		"R6GameMode", "R6Game.R6HostageRescueGame", Localize("MultiPlayer","GameType_HostageAdv","R6Menu"),
		"", "", 
		"", "", "RGM_HostageRescueMode");

	pLevelInfo.GameTypeSaveGameInfo( pLevelInfo.m_aGameTypeInfo.Length - 1, 
		Localize("SaveGameDirectory","SaveGameType_HostageRescue","R6Engine"), 
		"Hostage Rescue");

	pLevelInfo.GameTypeInfoAdd( "RGM_HostageRescueCoopMode", "RGM_HostageRescueCoopMode", GMI_Cooperative,  false, true,  true, true, true, 
		"R6GameMode", "R6Game.R6HostageRescueCoopGame", Localize("MultiPlayer","GameType_HostageCoop","R6Menu"),
		"R6GameMode", "", 
		"R6GameMode", "", "RGM_HostageRescueCoopMode");

	pLevelInfo.GameTypeInfoAdd( "RGM_HostageRescueAdvMode", "RGM_HostageRescueAdvMode", GMI_Adversarial,  true,  true,  true, true, true, 
		"R6GameMode", "R6Game.R6HostageRescueAdvGame", Localize("MultiPlayer","GameType_HostageAdv","R6Menu"),
		"R6GameMode", "R6GameMode",
		"R6GameMode", "R6GameMode", "RGM_HostageRescueAdvMode");

	pLevelInfo.GameTypeInfoAdd( "RGM_DeathmatchMode", "RGM_DeathmatchMode", GMI_Adversarial,  false, false, false, false, false,
		"R6GameMode", "R6Game.R6DeathMatch", Localize("MultiPlayer","GameType_Death","R6Menu"),
		"R6GameMode", "",
		"R6GameMode", "", "RGM_DeathmatchMode");

	pLevelInfo.GameTypeInfoAdd( "RGM_TeamDeathmatchMode", "RGM_TeamDeathmatchMode", GMI_Adversarial,  true,  true,  false, false, false,
		"R6GameMode", "R6Game.R6TeamDeathMatchGame", Localize("MultiPlayer","GameType_TeamDeath","R6Menu"),
		"R6GameMode", "R6GameMode",
		"R6GameMode", "R6GameMode", "RGM_TeamDeathmatchMode");

	pLevelInfo.GameTypeInfoAdd( "RGM_BombAdvMode", "RGM_BombAdvMode", GMI_Adversarial,  true,  true,  false, false, false,
		"R6GameMode", "R6Game.R6TeamBomb", Localize("MultiPlayer","GameType_DisarmBomb","R6Menu"),
		"R6GameMode", "R6GameMode",
		"R6GameMode", "R6GameMode", "RGM_BombAdvMode");

	pLevelInfo.SetGameTypeDisplayBombTimer( "RGM_BombAdvMode" );

	pLevelInfo.GameTypeInfoAdd( "RGM_EscortAdvMode", "RGM_EscortAdvMode", GMI_Adversarial,  true,  true,  false, false, false,
		"R6GameMode", "R6Game.R6EscortPilotGame", Localize("MultiPlayer","GameType_EscortGeneral","R6Menu"),
		"R6GameMode", "R6GameMode",
		"R6GameMode", "R6GameMode", "RGM_EscortAdvMode");

	pLevelInfo.GameTypeInfoAdd( "RGM_LoneWolfMode", "RGM_LoneWolfMode", GMI_SinglePlayer, false, false,  true, true, false,
		"R6GameMode", "R6Game.R6LoneWolfGame", "loc LoneWolfMode",
		"", "", 
		"", "", "RGM_LoneWolfMode");

	pLevelInfo.GameTypeSaveGameInfo( pLevelInfo.m_aGameTypeInfo.Length - 1, 
		Localize("SaveGameDirectory","SaveGameType_LoneWolf","R6Engine"), 
		"Lone Wolf");

	pLevelInfo.GameTypeInfoAdd( "RGM_NoRulesMode", "RGM_NoRulesMode", GMI_None, true,  false, false, true, true,
		"No Rule", "R6Game.R6NoRules", "GameType_Debug",
		"", "", 
		"", "", "RGM_NoRulesMode");
}

defaultproperties
{
}
