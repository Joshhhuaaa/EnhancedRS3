//=============================================================================
//  R6MenuMapList.uc : This menu display the map and the map list window and manage
//                     all the operations between the two window (+ the button in center)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/02  * Create by Yannick Joly
//=============================================================================
class R6MenuMapList extends UWindowDialogClientWindow;

const C_fX_START_TEXT      = 5;
const C_fX_START_MAPLIST   = 7;                           // the start x pos of the map list window -- offset from 0 (winleft)
const C_fY_START_MAPLIST   = 16;                          // the start y pos of map list -- offset from beginning of this window
const C_fWIDTH_OF_MAPLIST  = 135;                         // the size of the window list
const C_fHEIGHT_OF_MAPLIST = 115;                         // the size of the window list

const C_fX_ButPos		   = 148;
const C_fY_ButPos		   = 67;

const C_iMAX_MAPLIST_SIZE  = 32;						  // the max size of the selected map list

var R6WindowTextLabelExt                m_pTextInfo;      // the text info in background

var R6WindowTextListBoxExt              m_pStartMapList;
var R6WindowTextListBoxExt              m_pFinalMapList;

var R6WindowComboControl                m_pGameTypeCombo; // the combo control for game type

var Texture								m_pButtonTexture;
var UWindowButton                       m_pSelectButton;
var Region								m_RArrowUp;	      // the region of the arrow button for map list
var Region								m_RArrowDown;     // the region of the arrow button for map list
var Region								m_RArrowDisabled; // the region of the arrow button for map list
var Region								m_RArrowOver;     // the region of the arrow button for map list

var string                              m_szLocGameMode;  // the game mode selected (Adversarial, Cooperative, etc)v
var  Actor.EGameModeInfo				m_eMyGameMode;	  // the game mode of the map list

var INT                                 m_iTextIndex;     // only to refresh game mode

var bool                                m_bFromStartList; // you come from Start list -- for color effect window!
var BOOL								m_bInGame;

var UWindowButton              m_pSubButton;       // the substract button
var UWindowButton              m_pPlusButton;      // the adding button 

function Created()
{
    local UWindowListBoxItem CurItem;
    local FLOAT fXOffset, fYOffset, fWidth, fXSecondWindow;

    fXSecondWindow = WinWidth - C_fX_START_MAPLIST - C_fWIDTH_OF_MAPLIST;

    // create the text part
    m_pTextInfo = R6WindowTextLabelExt( CreateWindow(class'R6WindowTextLabelExt', 0, 0, WinWidth, WinHeight, self));
    m_pTextInfo.bAlwaysBehind = true;
    m_pTextInfo.SetNoBorder(); 

    // add text label
    m_pTextInfo.m_Font = Root.Fonts[F_SmallTitle];  
    m_pTextInfo.m_vTextColor = Root.Colors.White;

    fXOffset = C_fX_START_TEXT;
    fYOffset = 0;
    fWidth   = C_fWIDTH_OF_MAPLIST;
    m_pTextInfo.AddTextLabel( Localize("MPCreateGame","Options_Map","R6Menu"), fXOffset, fYOffset, fWidth, TA_Left, false);

    fXOffset = fXSecondWindow;
    m_pTextInfo.AddTextLabel( Localize("MPCreateGame","Options_MapList","R6Menu"), fXOffset, fYOffset, fWidth, TA_Left, false);

    fXOffset = C_fX_START_TEXT;
    fYOffset = C_fY_START_MAPLIST + C_fHEIGHT_OF_MAPLIST + 5; // 5 offset after map list window
    m_pTextInfo.m_Font = Root.Fonts[F_VerySmallTitle]; 
    m_iTextIndex = m_pTextInfo.AddTextLabel( m_szLocGameMode $ " " $ Localize("MPCreateGame","Options_GameType","R6Menu"), fXOffset, fYOffset, fXSecondWindow - fXOffset, TA_Left, false);

    // create the two lists box
	m_pStartMapList = R6WindowTextListBoxTest(CreateControl(Class'R6Window.R6WindowTextListBoxTest', 7.0, 16.0, 135.0, 115.0, self));
    m_pStartMapList.TextColor     = Root.Colors.BlueLight;
    m_pStartMapList.SetCornerType(No_Corners);
    m_pStartMapList.SetOverBorderColorEffect( Root.Colors.GrayLight);    
    m_pStartMapList.ToolTipString = Localize("Tip","Options_Map","R6Menu");

	m_pFinalMapList = R6WindowTextListBoxTest(CreateControl(Class'R6Window.R6WindowTextListBoxTest', fXSecondWindow, 16.0, 135.0, 115.0, self));
    m_pFinalMapList.TextColor     = Root.Colors.BlueLight;
    m_pFinalMapList.SetCornerType(No_Corners);
    m_pFinalMapList.SetOverBorderColorEffect( Root.Colors.GrayLight); 
    m_pFinalMapList.ToolTipString = Localize("Tip","Options_MapList","R6Menu");

    // create the button between the two map list
    m_pSelectButton = UWindowButton(CreateControl(class'UWindowButton', C_fX_ButPos, C_fY_ButPos, 13, 13, self));
    m_pSelectButton.m_bDrawButtonBorders = true;
	SetButtonRegion(true);
    m_pSelectButton.ToolTipString = Localize("Tip","Options_MapListAddRemove","R6Menu");

    //create the combo control box -- game type
    fYOffset = C_fY_START_MAPLIST + C_fHEIGHT_OF_MAPLIST + 5; // 5 offset after map list window
    m_pGameTypeCombo = R6WindowComboControl(CreateControl( class'R6WindowComboControl', fXSecondWindow, fYOffset, fWidth, LookAndFeel.Size_ComboHeight));
//    m_pGameTypeCombo.EditBoxWidth = m_pGameTypeCombo.WinWidth - m_pGameTypeCombo.Button.WinWidth;
    m_pGameTypeCombo.SetFont( F_VerySmallTitle);
    m_pGameTypeCombo.SetEditBoxTip( Localize("Tip","Options_MapListGameType","R6Menu"));

	CreateButtons();
}

function CreateButtons()
{
    local Region        RDisableRegion, 
                        RNormalRegion,
						ROverRegion;
    local FLOAT         fHeight,
                        fButtonWidth,
                        fButtonHeight;

    // init
	RNormalRegion.X		= 0;    // sub region
	RNormalRegion.Y		= 0;
	RNormalRegion.W		= 11;
	RNormalRegion.H		= 8;
	RDisableRegion.X	= 0;    // sub region
	RDisableRegion.Y	= 16;
	RDisableRegion.W	= 11;
	RDisableRegion.H	= 8;
	ROverRegion.X		= 0;
	ROverRegion.Y		= 8;
	ROverRegion.W		= 11;
	ROverRegion.H		= 8;

    fButtonWidth        = 13; //R6MenuRSLookAndFeel(LookAndFeel).m_RButtonBackGround.W;
    fButtonHeight       = 12; //R6MenuRSLookAndFeel(LookAndFeel).m_RButtonBackGround.H;

	fHeight = m_pSelectButton.WinTop - fButtonHeight - 10; // + m_pSelectButton.WinHeight + 4;

    // place the sub button always at 0 in X
	m_pSubButton = UWindowButton(CreateControl( class'UWindowButton', C_fX_ButPos, fHeight, fButtonWidth, fButtonHeight, self));
	m_pSubButton.m_bDrawButtonBorders = true;
	m_pSubButton.bUseRegion         = true;
	m_pSubButton.DownTexture		= R6MenuRSLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pSubButton.DownRegion         = RDisableRegion;
	m_pSubButton.OverTexture		= R6MenuRSLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pSubButton.OverRegion         = ROverRegion;
	m_pSubButton.UpTexture		    = R6MenuRSLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pSubButton.UpRegion           = RNormalRegion;
	m_pSubButton.DisabledTexture	= R6MenuRSLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pSubButton.DisabledRegion		= RDisableRegion;
	m_pSubButton.ImageX             = 1;
	m_pSubButton.ImageY             = 2;

    // place the plus button always at the end of the window in X
	RNormalRegion.X		= 0;    // sub region
	RNormalRegion.Y		= 8;
	RNormalRegion.W		= 11;
	RNormalRegion.H		= -8;
	RDisableRegion.X	= 0;    // sub region
	RDisableRegion.Y	= 24;
	RDisableRegion.W	= 11;
	RDisableRegion.H	= -8;
	ROverRegion.X		= 0;
	ROverRegion.Y		= 16;
	ROverRegion.W		= 11;
	ROverRegion.H		= -8;

	fHeight = m_pSelectButton.WinTop + m_pSelectButton.WinHeight + 10;

	m_pPlusButton = UWindowButton(CreateControl( class'UWindowButton', C_fX_ButPos, fHeight, fButtonWidth, fButtonHeight, self));
	m_pPlusButton.m_bDrawButtonBorders = true;
	m_pPlusButton.bUseRegion        = true;
	m_pPlusButton.DownTexture		= R6MenuRSLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pPlusButton.DownRegion        = RDisableRegion;
	m_pPlusButton.OverTexture		= R6MenuRSLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pPlusButton.OverRegion        = ROverRegion;
	m_pPlusButton.UpTexture			= R6MenuRSLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pPlusButton.UpRegion          = RNormalRegion;
	m_pPlusButton.DisabledTexture	= R6MenuRSLookAndFeel(LookAndFeel).m_TButtonBackGround;
	m_pPlusButton.DisabledRegion	= RDisableRegion;
	m_pPlusButton.ImageX            = 1;
	m_pPlusButton.ImageY            = 2;

	SetOrderButtons(true);

#ifdefDEBUG
	fHeight = (WinWidth * 0.5) - 7.5;
//	log("1YAN fHeight:"@fHeight);
	fHeight = WinHeight * 0.5;
//	log("2YAN fHeight:"@fHeight);
#endif
}


/////////////////////////////////////////////////////////////////
// Fill the map window text list box
/////////////////////////////////////////////////////////////////
function FillMapListItem()
{
	local R6WindowListBoxItem   NewItem;
	local INT                   i, j;
	local string                szLocMapName;
    local R6Console             r6console;
	local R6MissionDescription  mission;
	local LevelInfo             pLevel;
    local string                szMod;
    local string                szRavenShieldMod;
    local bool                  bLoadMap;


	pLevel = GetLevel();
    r6console = R6Console( Root.Console );

    m_pStartMapList.Items.Clear();
    
    szMod = class'Actor'.static.GetModMgr().m_pCurrentMod.m_szKeyWord;
    szRavenShieldMod = class'Actor'.static.GetModMgr().m_pRVS.m_szKeyWord;

    // from the main list, get all mission who can be played
    for ( i = 0; i < r6console.m_aMissionDescriptions.Length; ++i )
    {
        mission = r6console.m_aMissionDescriptions[i];

		if (mission.m_MapName != "" )
		{
			// check if the map is accessible in multi
			for (j=0; j < mission.m_szGameTypes.Length; j++)
			{
                
                bLoadMap = false;

                if ( szMod ~= mission.mod )
                    bLoadMap = true;        // map is for this mod
                else
                {
                    if ( mission.mod ~= szRavenShieldMod )
                        bLoadMap = true; // all RavenShield map are available in any mods
                }

//				log("bLoadMap: "@bLoadMap@pLevel.IsGameTypeMultiplayer(mission.m_eGameTypes[j], true));

				if ( bLoadMap && pLevel.IsGameTypeMultiplayer(mission.m_szGameTypes[j], true) )
				{
					NewItem = R6WindowListBoxItem(m_pStartMapList.Items.Append(m_pStartMapList.ListClass));

					if (!Root.GetMapNameLocalisation( mission.m_MapName, szLocMapName)) // failed to find the name, copy the map map (usefull for debugging)
					{
						szLocMapName = mission.m_MapName;
					}

					NewItem.HelpText = szLocMapName;
					NewItem.m_szMisc = mission.m_MapName;
					break;
				}
			}
		}
    }
    
    m_pStartMapList.Items.Sort();
}

//===================================================================================================
// GetNewServerProfileGameMode: 
//===================================================================================================
function string GetNewServerProfileGameMode( optional BOOL _bInGame)
{
    local R6MenuInGameMultiPlayerRootWindow R6Root;
	local string szResult;
	local R6ServerInfo pServerOpt;
    local R6GameReplicationInfo _GRI;

	szResult = string(GetPlayerOwner().EGameModeInfo.GMI_Adversarial);

	if (_bInGame)
	{	
		R6Root = R6MenuInGameMultiPlayerRootWindow(Root);
		_GRI = R6GameReplicationInfo(R6Root.m_R6GameMenuCom.m_GameRepInfo);

		if (_GRI != None)
		{
			szResult = GetGameModeFromList( GetLevel().GetGameTypeFromClassName(_GRI.m_gameModeArray[0]));
		}
	}
	else
	{
		pServerOpt = class'Actor'.static.GetServerOptions();

		if (pServerOpt.m_ServerMapList != none)
		{
			szResult = GetGameModeFromList( GetLevel().GetGameTypeFromClassName(pServerOpt.m_ServerMapList.GameType[0]));
		}
	}

	return szResult;
}

function string GetGameModeFromList( string _szGameType)
{
	local string szResult;

	szResult = string(GetPlayerOwner().EGameModeInfo.GMI_Adversarial);

	if (GetLevel().IsGameTypeCooperative( _szGameType) )
	{
		szResult = string(GetPlayerOwner().EGameModeInfo.GMI_Cooperative);
	}

	return szResult;
}

function bool IsFinalMapListEmpty()
{
    if(m_pFinalMapList == none)
    {
        return false;
    }
    return m_pFinalMapList.Items.Count() == 0;
}

//===================================================================================================
// FillFinalMapList: Fill the map list according the list give by the serveroptions --> from "server".ini
//===================================================================================================
function string FillFinalMapList()
{
    local R6MenuInGameMultiPlayerRootWindow R6Root;
	local UWindowListBoxItem                NewItem;
	local INT                               i;
	local string							szGameType;

	local string							szResult, szTemp;
	local R6ServerInfo pServerOpt;
	local LevelInfo pLevel;
	
#ifdefDEBUG
	local BOOL bShowLog;
#endif

	pServerOpt = class'Actor'.static.GetServerOptions();
	pLevel = GetLevel();

	m_pFinalMapList.Items.Clear();

	// if the maplist is not create in the server info class
	if (pServerOpt.m_ServerMapList == none)
	{
		// create a copy of what's you have by default
		pServerOpt.m_ServerMapList = GetPlayerOwner().spawn(class'Engine.R6MapList');
	}

	for ( i = 0; i < arraycount(pServerOpt.m_ServerMapList.Maps) && pServerOpt.m_ServerMapList.Maps[i] != ""; i++ )
	{
#ifdefDEBUG
		if (bShowLog)
		{
			if (pServerOpt.m_ServerMapList.Maps[i] == "")
			{
				log("pServerOpt.m_ServerMapList.Maps[i] is none!!!");
				break;
			}

			log("HELP TEXT ===> "@pServerOpt.m_ServerMapList.Maps[i]);
		}
#endif
		szGameType = pLevel.GetGameTypeFromClassName(pServerOpt.m_ServerMapList.GameType[i]);

		szTemp = GetGameModeFromList( szGameType);

		// before filling the list, check if you have the same gamemode -- else not add the item
		if (m_eMyGameMode == GetPlayerOwner().EGameModeInfo.GMI_Adversarial)
		{
			if (!pLevel.IsGameTypeAdversarial(szGameType))
			{
				if (szResult == "")
					szResult = szTemp;

				continue;
			}

			szResult = szTemp;
		}
		else if (m_eMyGameMode == GetPlayerOwner().EGameModeInfo.GMI_Cooperative)
		{
			if (!pLevel.IsGameTypeCooperative(szGameType))
			{
				if (szResult == "")
					szResult = szTemp;

				continue;
			}

			szResult = szTemp;
		}
		else
		{
			continue;
		}

		if (!Root.GetMapNameLocalisation( pServerOpt.m_ServerMapList.Maps[i], szTemp))
		{
			// localisation file not exist or server.ini was modify with a non-existant map
			// check if we find the equivalent in original map list
			if (!FindMapInStartMapList(pServerOpt.m_ServerMapList.Maps[i]))
			{
#ifdefDEBUG
				if (bShowLog) log("this map,"@pServerOpt.m_ServerMapList.Maps[i]@"don't exist in your map folder at index"@i);
#endif
				continue;
			}
#ifdefDEBUG
			if (bShowLog) log("find no loc for this map:"@pServerOpt.m_ServerMapList.Maps[i]@"at index"@i);
#endif
			szTemp = pServerOpt.m_ServerMapList.Maps[i];
		}

		NewItem = UWindowListBoxItem(m_pFinalMapList.Items.Append(m_pFinalMapList.ListClass));
		NewItem.HelpText = szTemp;
		R6WindowListBoxItem(NewItem).m_szMisc = pServerOpt.m_ServerMapList.Maps[i];	

		NewItem.m_bUseSubText                   = true;
		NewItem.m_stSubText.FontSubText         = Root.Fonts[F_ListItemSmall];
		NewItem.m_stSubText.fHeight             = 10;
		NewItem.m_stSubText.fXOffset			= 10;
		NewItem.m_stSubText.szGameTypeSelect    = pLevel.GetGameNameLocalization(szGameType);
	}

	if (szResult == "")
		szResult = string(m_eMyGameMode);

#ifdefDEBUG
	if (bShowLog) log("szResult"@szResult@self);
#endif

	return szResult;
}

//===================================================================================================
// FillFinalMapListInGame: Fill the map list according the list give by the server -- in-game only 
//===================================================================================================
function string FillFinalMapListInGame()
{
    local R6MenuInGameMultiPlayerRootWindow R6Root;
	local UWindowListBoxItem                NewItem;
	local INT                               i;
	local string							szGameType;

	local string							szResult, szTemp;
    local R6GameReplicationInfo _GRI;
	local LevelInfo pLevel;
	
#ifdefDEBUG
	local BOOL bShowLog;
#endif

	pLevel = GetLevel();
	m_pFinalMapList.Items.Clear();

	R6Root = R6MenuInGameMultiPlayerRootWindow(Root);
    _GRI = R6GameReplicationInfo(R6Root.m_R6GameMenuCom.m_GameRepInfo);

	for ( i = 0; (i < _GRI.m_MapLength) && (_GRI.m_mapArray[i] != ""); i++ )
	{
#ifdefDEBUG
		if (bShowLog)
		{
			log("HELP TEXT ===> "$_GRI.m_mapArray[i]);
		}
#endif
		szGameType = pLevel.GetGameTypeFromClassName(_GRI.m_gameModeArray[i]);

		szTemp = GetGameModeFromList( szGameType);

		// before filling the list, check if you have the same gamemode -- else not add the item
		if (m_eMyGameMode == GetPlayerOwner().EGameModeInfo.GMI_Adversarial)
		{
			if (!pLevel.IsGameTypeAdversarial(szGameType))
			{
				if (szResult == "")
					szResult = szTemp;

				continue;
			}

			szResult = szTemp;
		}
		else if (m_eMyGameMode == GetPlayerOwner().EGameModeInfo.GMI_Cooperative)
		{
			if (!pLevel.IsGameTypeCooperative(szGameType))
			{
				if (szResult == "")
					szResult = szTemp;

				continue;
			}

			szResult = szTemp;
		}
		else
		{
			continue;
		}


		NewItem = UWindowListBoxItem(m_pFinalMapList.Items.Append(m_pFinalMapList.ListClass));

		if (!Root.GetMapNameLocalisation( _GRI.m_mapArray[i], NewItem.HelpText))
		{
			// localisation file not exist or client don't have the map
			// check if we find the equivalent in original map list
			if (FindMapInStartMapList(_GRI.m_mapArray[i]))
			{
#ifdefDEBUG
				if (bShowLog) log("find no loc for this map:"@_GRI.m_mapArray[i]@"at index"@i);
#endif
				NewItem.HelpText = _GRI.m_mapArray[i]; // no loc for this map
			}
			else
			{
#ifdefDEBUG
				if (bShowLog) log("this map,"@_GRI.m_mapArray[i]@"don't exist in your map folder at index"@i);
#endif
			NewItem.HelpText = Localize( "General","None","R6Menu"); // client missing map and/or the .ini associate
			}
		}

		R6WindowListBoxItem(NewItem).m_szMisc = _GRI.m_mapArray[i];	

		NewItem.m_bUseSubText                   = true;
		NewItem.m_stSubText.FontSubText         = Root.Fonts[F_ListItemSmall];
		NewItem.m_stSubText.fHeight             = 10;
		NewItem.m_stSubText.fXOffset			= 10;
		NewItem.m_stSubText.szGameTypeSelect    = pLevel.GetGameNameLocalization(szGameType); 
	}

	if (szResult == "")
		szResult = string(m_eMyGameMode);

#ifdefDEBUG
	if (bShowLog) log("FillFinalMapListInGame szResult"@szResult@self);
#endif

	return szResult;
}

//===================================================================================================
//
//===================================================================================================
function SetGameModeToDisplay( string _szIndex)
{
	m_pTextInfo.ChangeTextLabel( m_szLocGameMode $ " " $ Localize("MPCreateGame","Options_GameType","R6Menu"), m_iTextIndex);
    m_pGameTypeCombo.Clear();
	InitMode( _szIndex);
}

//===================================================================================================
//
//===================================================================================================
function InitMode( string _szIndex)
{
	local string szGameTypeFind, szFirstGameType;
	local INT i;
	local BOOL bFindGameType, bFirstValue;
	local LevelInfo pLevel;

	pLevel = GetLevel();

	for ( i = 0; i < pLevel.m_aGameTypeInfo.Length; i++)
	{
		szGameTypeFind = pLevel.m_aGameTypeInfo[i].m_szGameType;
		if(( szGameTypeFind != "RGM_NoRulesMode") && (pLevel.IsGameTypeMultiplayer(szGameTypeFind)))
		{
			switch( _szIndex)
			{
				case string(GetPlayerOwner().EGameModeInfo.GMI_Adversarial): 
					if ( pLevel.IsGameTypeAdversarial( szGameTypeFind))
					{
						#ifdefMPDEMO
							// only adv and team adv for the demo
							if ( (szGameTypeFind == "RGM_DeathmatchMode") ||
								 (szGameTypeFind == "RGM_TeamDeathmatchMode") ||
								 (szGameTypeFind == "RGM_EscortAdvMode") ) 
							{
								bFindGameType = true;
							}
							break;
						#endif
						bFindGameType = true;
					}
					break;
				case string(GetPlayerOwner().EGameModeInfo.GMI_Cooperative): 
					if ( pLevel.IsGameTypeCooperative( szGameTypeFind))
					{
						bFindGameType = true;
					}
					break;
				default:
					log("GAME MODE NOT DEFINED");
					break;
			}

            // MPF check if Gametype is available for the MOD
            if ( bFindGameType )
                bFindGameType = class'Actor'.static.GetModMgr().IsGameTypeAvailable( szGameTypeFind );

			if (bFindGameType)
			{
				m_pGameTypeCombo.AddItem( pLevel.GetGameNameLocalization( szGameTypeFind), szGameTypeFind);

				if (!bFirstValue)
				{
					bFirstValue = true;
					szFirstGameType = szGameTypeFind;
				}
			}

			bFindGameType = false;
		}
	}

	ManageAvailableGameTypes( m_pStartMapList.GetSelectedItem());

	if (m_pFinalMapList.GetSelectedItem() == none)
		m_pGameTypeCombo.SetValue( pLevel.GetGameNameLocalization( szFirstGameType), szFirstGameType);
	else
		ManageAvailableGameTypes( m_pFinalMapList.GetSelectedItem(), true);
}


function ManageAvailableGameTypes( UWindowList _pSelectItem, optional BOOL _bKeepItemGameType)
{
	local UWindowComboListItem pComboListItem;
	local R6MissionDescription pCurMissionDesc;
	local string szGameTypeFind, szFirstGameTypeFound, szItemGameType;
	local R6Console r6Console;
	local string szMapName, szEditBoxValue;
	local INT i;
	local BOOL bUseSameGameType;
	local LevelInfo pLevel;

	pLevel = GetLevel();
    r6console = R6Console( Root.Console );

	if (_pSelectItem == none)
		return;

	szMapName = R6WindowListBoxItem(_pSelectItem).m_szMisc;
	szItemGameType = pLevel.GetGameTypeFromLocName(UWindowListBoxItem(_pSelectItem).m_stSubText.szGameTypeSelect);

	// find the current mission description -- according the item selected by the user
    for ( i = 0; i < r6console.m_aMissionDescriptions.Length; ++i )
    {
		if (szMapName == r6console.m_aMissionDescriptions[ i ].m_MapName)
		{
			pCurMissionDesc = r6console.m_aMissionDescriptions[ i ];
			break;
		}
	}

	// if you have a mission desc -- if not we have a problem
	if (pCurMissionDesc != None)
	{
		// put all the current game type to disable 
		m_pGameTypeCombo.DisableAllItems();
		szEditBoxValue = m_pGameTypeCombo.GetValue();
		szFirstGameTypeFound = "RGM_NoRulesMode";

		// change the status of current gametype available for this map
		for ( i = 0; i < pCurMissionDesc.m_szGameTypes.Length; i++)
		{
			szGameTypeFind  = pCurMissionDesc.m_szGameTypes[i];
			pComboListItem = m_pGameTypeCombo.GetItem( pLevel.GetGameNameLocalization( szGameTypeFind));

			if (pComboListItem != none)
			{
				// this gametype is available
				pComboListItem.bDisabled = false;

				if (szFirstGameTypeFound == "RGM_NoRulesMode")
					szFirstGameTypeFound = szGameTypeFind;

				if ((_bKeepItemGameType) && (szItemGameType == szGameTypeFind))
				{
					szFirstGameTypeFound = szGameTypeFind;
					continue; // skip the next if
				}

				if (szEditBoxValue == pLevel.GetGameNameLocalization( szGameTypeFind))
					bUseSameGameType = true;
			}
		}
	}

	// if we not find a gametype, check the first available item in the list 
	if ( (!bUseSameGameType) && (szFirstGameTypeFound != "RGM_NoRulesMode") )
	{
		m_pGameTypeCombo.SetValue(pLevel.GetGameNameLocalization( szFirstGameTypeFound), szFirstGameTypeFound);
	}
}




//===================================================================================
// Copy an item and add it in a specfic list
//===================================================================================
function CopyAndAddItemInList( UWindowListBoxItem _ItemToAdd, UWindowListControl _ListAddItem)
{
	local UWindowListBoxItem NewItem;
	
	if ( _ListAddItem.Items.Count() < C_iMAX_MAPLIST_SIZE)
	{
		NewItem = UWindowListBoxItem( _ListAddItem.Items.Append( _ListAddItem.ListClass));
		NewItem.HelpText            = _ItemToAdd.HelpText;	
		R6WindowListBoxItem(NewItem).m_szMisc            = R6WindowListBoxItem(_ItemToAdd).m_szMisc;

		NewItem.m_bUseSubText                   = true;
		NewItem.m_stSubText.FontSubText         = Root.Fonts[F_ListItemSmall];
		NewItem.m_stSubText.fHeight             = 10;
		NewItem.m_stSubText.fXOffset			= 10;
		NewItem.m_stSubText.szGameTypeSelect    = m_pGameTypeCombo.GetValue(); // or _ItemToAdd.m_stSubText.szGameTypeSelect
	}
}


function BOOL FindMapInStartMapList( string _szMapName)
{
   	local UWindowListBoxItem CurItem;

    // Go through list of maps, we find it in m_pStartMapList

	CurItem = UWindowListBoxItem(m_pStartMapList.Items.Next);

	while ( CurItem != None ) 
	{
		if (R6WindowListBoxItem(CurItem).m_szMisc == _szMapName)
			return true;

        CurItem = UWindowListBoxItem(CurItem.Next);
	}

    return false;
}

function byte FillGameTypeMapArray(out array<string> _SelectedMapList, out array<string> _SelectedGameTypeList)
{
    local UWindowListBoxItem CurItem;
    local int i;

    _SelectedMapList.Remove(0, _SelectedMapList.Length);
    if(m_pFinalMapList.Items.Next == none)
    {
        return 0;
    }
    CurItem = UWindowListBoxItem(m_pFinalMapList.Items.Next);
    i = 0;

    while(CurItem != none)
    {
        _SelectedMapList[i] = R6WindowListBoxItem(CurItem).m_szMisc;
        _SelectedGameTypeList[i] = GetLevel().GetGameTypeFromLocName(CurItem.m_stSubText.szGameTypeSelect, true);
        CurItem = UWindowListBoxItem(CurItem.Next);
        i++;
    }
    return byte(i);
}

//===================================================================================
// Notify : Receive msg from UWindowDialogControl window
//===================================================================================
function Notify(UWindowDialogControl C, byte E)
{
//    log("Notify from class: "$C);
//    log("Notify msg: "$E);

	if (m_bInGame)
	{
		// verify if you are an admin, if yes process the notify
		if ( !R6PlayerController(GetPlayerOwner()).CheckAuthority(R6PlayerController(GetPlayerOwner()).Authority_Admin))
		{
			return;
		}
	}

    if (C.IsA('R6WindowTextListBox'))
    {
        switch( E)
        {
            case DE_Click:
                // if we quit a list text box
                if ( C == m_pStartMapList)
                {
                    // update Combo
                    if (m_pStartMapList.GetSelectedItem() != None)
                    {
                        // we need to refresh the combo list and display the first valid game type
						ManageAvailableGameTypes( m_pStartMapList.GetSelectedItem());
                    }

                    // drop selection in the other window
                    m_pFinalMapList.DropSelection();

                    // change the button selection side
					SetButtonRegion(true);
                }
                else // m_pFinalMapList
                {
                    // update Combo
                    if (m_pFinalMapList.GetSelectedItem() != None)
                    {
						ManageAvailableGameTypes( m_pFinalMapList.GetSelectedItem(), true);
                        m_pGameTypeCombo.SetValue( m_pFinalMapList.GetSelectedItem().m_stSubText.szGameTypeSelect);
                    }

                    // drop selection in the other window
                    m_pStartMapList.DropSelection();

                    // change the button selection side
					SetButtonRegion(false);
                }
                break;
//            case DE_MouseEnter:
//            case DE_MouseLeave:
//                WindowStateChange();
//                break;
            case DE_DoubleClick:
                ManageTextListBox();
                break;
            default:
                break;
        }
    }
    else if (C.IsA('R6WindowComboControl'))
    {
        switch( E)
        {
            case DE_Change:
                ManageComboChange();
                break;
    //        case :
    //            break;
            default:
                break;
        }
    }
    else if (C.IsA('UWindowButton'))
    {
//        log("Notify Control="@C@"MSG="@E);

		if ((UWindowButton(C).bDisabled) || ((C != m_pSelectButton) && (m_pFinalMapList.GetSelectedItem() == None)))
			return;

		switch(E)
		{
			case DE_Click:
				if (C == m_pSelectButton)
					ManageTextListBox();
				else
					m_pFinalMapList.SwapItem( m_pFinalMapList.GetSelectedItem(), (C != m_pPlusButton));
				break;
			case DE_MouseEnter:
				UWindowButton(C).m_BorderColor = Root.Colors.BlueLight; 
				break;
			case DE_MouseLeave:
				UWindowButton(C).m_BorderColor = Root.Colors.White; 
				break;
		}
    }
}

/////////////////////////////////////////////////////////////////
// ManageTextListBox: Manage the operation between the two map list
/////////////////////////////////////////////////////////////////
function ManageTextListBox()
{
    local UWindowListBoxItem Item, NextItem, PrevItem;

    // check if an item is selected and switch it to the appropriate window
    Item = m_pStartMapList.GetSelectedItem();
//    log("Item in StartMapList: "$Item);

    if ( Item != None )
    {
		if (m_pGameTypeCombo.GetValue() != "") // if you have selected a gametype
	        CopyAndAddItemInList( Item, m_pFinalMapList); // add the item in map list
    }
    else
    {
        Item = m_pFinalMapList.GetSelectedItem();
//        log("Item in FinalMapList: "$Item);

        if ( Item != None )
        {
			PrevItem = m_pFinalMapList.CheckForPrevItem(Item);
			NextItem = m_pFinalMapList.CheckForNextItem(Item);

            Item.Remove();
			m_pFinalMapList.DropSelection();

            if (m_pFinalMapList.Items.Next == None)
			{
				m_pFinalMapList.Items.Clear();

				SetButtonRegion(true);
			}
            else
			{
				// take the previous button
				if (NextItem != None)
					Item = NextItem;
				else if (PrevItem != None)
					Item = PrevItem;

				if (Item != None)
				{
					m_pFinalMapList.SetSelectedItem( Item);
					m_pFinalMapList.MakeSelectedVisible();
				}

				SetButtonRegion(false);
			}
        }
    }
}

function WindowStateChange( )
{
    local UWindowListBoxItem Item;

    Item = m_pFinalMapList.GetSelectedItem();

    if (Item !=  None)
    {
        m_bFromStartList = False;
    }
    else
    {
        m_bFromStartList = True;
    }

	SetButtonRegion(!m_bFromStartList);
}


/////////////////////////////////////////////////////////////////
// ManageComboChange: Manage the DE_Change combo control message
/////////////////////////////////////////////////////////////////
function ManageComboChange()
{
    local UWindowListBoxItem Item;
	local UWindowComboListItem pComboListItem;

    Item = m_pStartMapList.GetSelectedItem();

    // it's start map list
    if ( Item != None)
    {
		pComboListItem = m_pGameTypeCombo.GetItem(m_pGameTypeCombo.GetValue());

		if (pComboListItem != None)
		{
			if (!pComboListItem.bDisabled)
				Item.m_stSubText.szGameTypeSelect = m_pGameTypeCombo.GetValue();
		}

        return;
    }
    
    Item = m_pFinalMapList.GetSelectedItem();

    // if we have something in final map list
    if ( Item != None) 
    {
		pComboListItem = m_pGameTypeCombo.GetItem(m_pGameTypeCombo.GetValue());

		if (pComboListItem != None)
		{
			if (!pComboListItem.bDisabled)
				Item.m_stSubText.szGameTypeSelect = m_pGameTypeCombo.GetValue();
		}
    }
}


function SetButtonRegion(bool _bInverseTex)
{
	m_pSelectButton.bUseRegion = true;

	if (_bInverseTex)
	{
		m_pSelectButton.ImageX				= 1;
		m_pSelectButton.ImageY				= 3;
		m_pSelectButton.m_fRotAngleWidth	= 9;
		m_pSelectButton.m_fRotAngleHeight	= 7;
	}
	else
	{
		m_pSelectButton.ImageX				= 3;
		m_pSelectButton.ImageY				= 3;
		m_pSelectButton.m_fRotAngleWidth	= 9;
		m_pSelectButton.m_fRotAngleHeight	= 7;
	}

	m_pSelectButton.UpTexture       = m_pButtonTexture;
	m_pSelectButton.DownTexture     = m_pButtonTexture;
	m_pSelectButton.OverTexture     = m_pButtonTexture;
	m_pSelectButton.DisabledTexture = m_pButtonTexture;

    m_pSelectButton.UpRegion        = m_RArrowUp;
    m_pSelectButton.DownRegion      = m_RArrowDown;
    m_pSelectButton.OverRegion      = m_RArrowOver;
    m_pSelectButton.DisabledRegion  = m_RArrowDisabled;

	m_pSelectButton.m_bUseRotAngle  = _bInverseTex;
	m_pSelectButton.m_fRotAngle		= 3.1416;

	SetOrderButtons(_bInverseTex);
}

function SetOrderButtons( BOOL _bDisable)
{
	if ((m_pSubButton == None) || (m_pPlusButton == None))
		return;

	if ((_bDisable) || (m_pFinalMapList.Items.CountShown() <= 1))
	{
		m_pSubButton.m_BorderColor  = Root.Colors.GrayLight;
		m_pSubButton.bDisabled		= true;
		m_pPlusButton.m_BorderColor = Root.Colors.GrayLight;
		m_pPlusButton.bDisabled		= true;
	}
	else
	{
		m_pSubButton.m_BorderColor  = Root.Colors.White;
		m_pSubButton.bDisabled		= false;
		m_pPlusButton.m_BorderColor = Root.Colors.White;
		m_pPlusButton.bDisabled		= false;
	}

//	log("Buttons are disable : "@m_pSubButton.bDisabled);
}

defaultproperties
{
     m_pButtonTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     m_RArrowUp=(X=94,Y=47,W=9,H=7)
     m_RArrowDown=(X=94,Y=54,W=9,H=7)
     m_RArrowDisabled=(X=94,Y=47,W=9,H=7)
     m_RArrowOver=(X=94,Y=47,W=9,H=7)
}
