//=============================================================================
//  UWindowMenuClassDefines.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/07/24  * Create by Yannick Joly
//=============================================================================
class UWindowMenuClassDefines extends Object
	Config(R6ClassDefines);

var config class<UWindowWindow>			ClassMPServerOption;
var config class<UWindowWindow>			ClassButtonsDefines;

// root
var config string						RegularRoot;
var config string						InGameMultiRoot;
var config string						InGameSingleRoot;

// Tab
var config class<UWindowWindow>			ClassMPCreateGameTabOpt;
var config class<UWindowWindow>			ClassMPCreateGameTabAdvOpt;
var config class<UWindowWindow>			ClassMPMenuTabGameModeFilters;

// Widget
var config class<UWindowWindow>         ClassMainWidget;
var config class<UWindowWindow>         ClassIntelWidget;
var config class<UWindowWindow>         ClassPlanningWidget;
var config class<UWindowWindow>         ClassExecuteWidget;
var config class<UWindowWindow>         ClassSinglePlayerWidget;
var config class<UWindowWindow>			ClassCustomMissionWidget;
var config class<UWindowWindow>         ClassTrainingWidget;
var config class<UWindowWindow>			ClassMultiPlayerWidget;
var config class<UWindowWindow>         ClassOptionsWidget;
var config class<UWindowWindow>         ClassCreditsWidget;
var config class<UWindowWindow>         ClassGearWidget;
var config class<UWindowWindow>			ClassMPCreateGameWidget;
var config class<UWindowWindow>			ClassUbiComWidget;
var config class<UWindowWindow>			ClassNonUbiComWidget;
var config class<UWindowWindow>         ClassQuitWidget;
var config class<UWindowWindow>         ClassActionPointPupUpMenu;
var config class<UWindowWindow>         ClassMovementModePupUpMenu;

// Servers related
var config class<object>				ClassGSServer;
var config class<object>				ClassLanServer;

// Ubi.com, CD-Key and game service related
var config class<UWindowWindow>			ClassUbiLogIn;
var config class<UWindowWindow>			ClassUbiCDKeyCheck;
var config class<UWindowWindow>			ClassQueryServerInfo;
var config class<UWindowWindow>			ClassUbiLoginClient;

// Multiplayer menus
var config class<UWindowWindow>			ClassMultiJoinIP;
var config class<UWindowWindow>    ClassWritableMapWidget;
var config class<UWindowWindow>    ClassJoinTeamWidget;
var config class<UWindowWindow>    ClassInterWidget;
var config class<UWindowWindow>    ClassInGameEsc;
var config class<UWindowWindow>    ClassInGameRecMessages;
var config class<UWindowWindow>    ClassInGameMsgOffensive;
var config class<UWindowWindow>    ClassInGameMsgDefensive;
var config class<UWindowWindow>    ClassInGameMsgReply;
var config class<UWindowWindow>    ClassInGameMsgStatus;
var config class<UWindowWindow>    ClassInGameVote;
var config class<UWindowWindow>    ClassInGameOptionsWidget;
var config class<UWindowWindow>    ClassCountDown;
var config class<UWindowWindow>    ClassInGameOperativeSelectorWidget;
var config class<UWindowWindow>    ClassInGameObjectives;
var config class<UWindowWindow>    ClassInGameEscNavBar;
var config class<object>           ClassGameMenuCom;
var config class<UWindowWindow>    ClassMenuCDKeyManager;
var config class<UWindowWindow>    ClassOptionsGame;
var config class<UWindowWindow>    ClassOptionsSound;
var config class<UWindowWindow>    ClassOptionsGraphic;
var config class<UWindowWindow>    ClassOptionsHud;
var config class<UWindowWindow>    ClassOptionsMulti;
var config class<UWindowWindow>    ClassOptionsControls;
var config class<UWindowWindow>    ClassOptionsMOD;
var config class<UWindowWindow>    ClassOptionsPatchService;

function Created()
{
	local string szMenuDefFile;

	szMenuDefFile = class'Actor'.static.GetModMgr().GetMenuDefFile();

	//Load the initial defines to get all the default values.
	if(szMenuDefFile != "R6ClassDefines")
	{
		LoadConfig("R6ClassDefines");
	}
	LoadConfig(szMenuDefFile);
	/*
	if (ClassMainWidget == None) ClassMainWidget = default.ClassMainWidget;

	if (ClassMPServerOption == None) ClassMPServerOption = default.ClassMPServerOption;
	if (ClassButtonsDefines == None) ClassButtonsDefines = default.ClassButtonsDefines;

	if (RegularRoot == "") RegularRoot = default.RegularRoot;
	if (InGameMultiRoot == "") InGameMultiRoot = default.InGameMultiRoot;
	if (InGameSingleRoot == "") InGameSingleRoot = default.InGameSingleRoot;

	// Tab
	if (ClassMPCreateGameTabOpt == None) ClassMPCreateGameTabOpt = default.ClassMPCreateGameTabOpt;
	if (ClassMPCreateGameTabAdvOpt == None) ClassMPCreateGameTabAdvOpt = default.ClassMPCreateGameTabAdvOpt;
	if (ClassMPMenuTabGameModeFilters == None) ClassMPMenuTabGameModeFilters = default.ClassMPMenuTabGameModeFilters;

	// Widget
	if (ClassMainWidget == None) ClassMainWidget = default.ClassMainWidget;
	if (ClassIntelWidget == None) ClassIntelWidget = default.ClassIntelWidget;
	if (ClassPlanningWidget == None) ClassPlanningWidget = default.ClassPlanningWidget;
	if (ClassExecuteWidget == None) ClassExecuteWidget = default.ClassExecuteWidget;
	if (ClassSinglePlayerWidget == None) ClassSinglePlayerWidget = default.ClassSinglePlayerWidget;
	if (ClassCustomMissionWidget == None) ClassCustomMissionWidget = default.ClassCustomMissionWidget;
	if (ClassTrainingWidget == None) ClassTrainingWidget = default.ClassTrainingWidget;
	if (ClassMultiPlayerWidget == None) ClassMultiPlayerWidget = default.ClassMultiPlayerWidget;
	if (ClassOptionsWidget == None) ClassOptionsWidget = default.ClassOptionsWidget;
	if (ClassCreditsWidget == None) ClassCreditsWidget = default.ClassCreditsWidget;
	if (ClassGearWidget == None) ClassGearWidget = default.ClassGearWidget;
	if (ClassMPCreateGameWidget == None) ClassMPCreateGameWidget = default.ClassMPCreateGameWidget;
	if (ClassUbiComWidget == None)ClassUbiComWidget  = default.ClassUbiComWidget;
	if (ClassNonUbiComWidget == None) ClassNonUbiComWidget = default.ClassNonUbiComWidget;
	if (ClassQuitWidget == None) ClassQuitWidget = default.ClassQuitWidget;

	if (ClassGSServer == None) ClassGSServer = default.ClassGSServer;
	if (ClassLanServer == None) ClassLanServer = default.ClassLanServer;

	// Ubi.com, CD-Key and game service related
	if (ClassUbiLogIn == None) ClassUbiLogIn = default.ClassUbiLogIn;
	if (ClassUbiCDKeyCheck == None) ClassUbiCDKeyCheck = default.ClassUbiCDKeyCheck;
	if (ClassQueryServerInfo == None) ClassQueryServerInfo = default.ClassQueryServerInfo;
	if (ClassUbiLoginClient == None) ClassUbiLoginClient = default.ClassUbiLoginClient;

	// Multiplayer menus
	if (ClassMultiJoinIP == None) ClassMultiJoinIP = default.ClassMultiJoinIP;
*/
}

defaultproperties
{
     ClassMPServerOption=Class'R6Menu.R6MenuMPServerOption'
     ClassButtonsDefines=Class'R6Menu.R6MenuButtonsDefines'
     ClassMPCreateGameTabOpt=Class'R6Menu.R6MenuMPCreateGameTabOptions'
     ClassMPCreateGameTabAdvOpt=Class'R6Menu.R6MenuMPCreateGameTabAdvOptions'
     ClassMPMenuTabGameModeFilters=Class'R6Menu.R6MenuMPMenuTab'
     ClassMainWidget=Class'R6Menu.R6MenuMainWidget'
     ClassIntelWidget=Class'R6Menu.R6MenuIntelWidget'
     ClassPlanningWidget=Class'R6Menu.R6MenuPlanningWidget'
     ClassExecuteWidget=Class'R6Menu.R6MenuExecuteWidget'
     ClassSinglePlayerWidget=Class'R6Menu.R6MenuSinglePlayerWidget'
     ClassCustomMissionWidget=Class'R6Menu.R6MenuCustomMissionWidget'
     ClassTrainingWidget=Class'R6Menu.R6MenuTrainingWidget'
     ClassMultiPlayerWidget=Class'R6Menu.R6MenuMultiPlayerWidget'
     ClassOptionsWidget=Class'R6Menu.R6MenuOptionsWidget'
     ClassCreditsWidget=Class'R6Menu.R6MenuCreditsWidget'
     ClassGearWidget=Class'R6Menu.R6MenuGearWidget'
     ClassMPCreateGameWidget=Class'R6Menu.R6MenuMPCreateGameWidget'
     ClassUbiComWidget=Class'R6Menu.R6MenuUbiComWidget'
     ClassNonUbiComWidget=Class'R6Menu.R6MenuNonUbiWidget'
     ClassQuitWidget=Class'R6Menu.R6MenuQuit'
     ClassActionPointPupUpMenu=Class'R6Menu.R6MenuActionPointMenu'
     ClassMovementModePupUpMenu=Class'R6Menu.R6MenuModeMenu'
     ClassGSServer=Class'R6GameService.R6GSServers'
     ClassLanServer=Class'R6GameService.R6LanServers'
     ClassUbiLogIn=Class'R6Window.R6WindowUbiLogIn'
     ClassUbiCDKeyCheck=Class'R6Window.R6WindowUbiCDKeyCheck'
     ClassQueryServerInfo=Class'R6Window.R6WindowQueryServerInfo'
     ClassUbiLoginClient=Class'R6Window.R6WindowUbiLoginClient'
     ClassMultiJoinIP=Class'R6Window.R6WindowJoinIP'
     ClassWritableMapWidget=Class'R6Menu.R6MenuInGameWritableMapWidget'
     ClassJoinTeamWidget=Class'R6Menu.R6MenuMPJoinTeamWidget'
     ClassInterWidget=Class'R6Menu.R6MenuMPInterWidget'
     ClassInGameEsc=Class'R6Menu.R6MenuMPInGameEsc'
     ClassInGameRecMessages=Class'R6Menu.R6MenuMPInGameRecMessages'
     ClassInGameMsgOffensive=Class'R6Menu.R6MenuMPInGameMsgOffensive'
     ClassInGameMsgDefensive=Class'R6Menu.R6MenuMPInGameMsgDefensive'
     ClassInGameMsgReply=Class'R6Menu.R6MenuMPInGameMsgReply'
     ClassInGameMsgStatus=Class'R6Menu.R6MenuMPInGameMsgStatus'
     ClassInGameVote=Class'R6Menu.R6MenuMPInGameVote'
     ClassInGameOptionsWidget=Class'R6Menu.R6MenuOptionsWidget'
     ClassCountDown=Class'R6Menu.R6MenuMPCountDown'
     ClassInGameOperativeSelectorWidget=Class'R6Menu.R6MenuInGameOperativeSelectorWidget'
     ClassInGameObjectives=Class'R6Menu.R6MenuMPInGameObj'
     ClassInGameEscNavBar=Class'R6Menu.R6MenuMPInGameEscNavBar'
     ClassGameMenuCom=Class'R6Menu.R6MPGameMenuCom'
     ClassMenuCDKeyManager=Class'R6Menu.R6MenuCDKeyManager'
     ClassOptionsGame=Class'R6Menu.R6MenuOptionsGame'
     ClassOptionsSound=Class'R6Menu.R6MenuOptionsSound'
     ClassOptionsGraphic=Class'R6Menu.R6MenuOptionsGraphic'
     ClassOptionsHud=Class'R6Menu.R6MenuOptionsHud'
     ClassOptionsMulti=Class'R6Menu.R6MenuOptionsMulti'
     ClassOptionsControls=Class'R6Menu.R6MenuOptionsControls'
     ClassOptionsMOD=Class'R6Menu.R6MenuOptionsMODS'
     ClassOptionsPatchService=Class'R6Menu.R6MenuOptionsPatchService'
     RegularRoot="R6Menu.R6MenuRootWindow"
     InGameMultiRoot="R6Menu.R6MenuInGameMultiPlayerRootWindow"
     InGameSingleRoot="R6Menu.R6MenuInGameRootWindow"
}
