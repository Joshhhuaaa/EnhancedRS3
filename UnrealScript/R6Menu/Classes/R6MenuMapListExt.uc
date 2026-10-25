class R6MenuMapListExt extends R6MenuMapList;

const C_fHEIGHT_OF_MAPLIST = 115;                         // the size of the window list

const C_fY_ButPos		   = 67;

const C_MAP_INDEX = 0;

const C_GAME_TYPE_INDEX = 1;

const C_GREEN_ARMOR_INDEX = 2;

const C_RED_ARMOR_INDEX = 3;

var bool m_bFinalListEmpty;

function Created()
{
    local UWindowListBoxItem CurItem;
    local float fXOffset, fYOffset, fWidth, fXSecondWindow;

    fXSecondWindow = (WinWidth - float(7)) - float(135);
    m_pTextInfo = R6WindowTextLabelExt(CreateWindow(Class'R6Window.R6WindowTextLabelExt', 0.0, 0.0, WinWidth, WinHeight, self));
    m_pTextInfo.bAlwaysBehind = true;
    m_pTextInfo.SetNoBorder();
    m_pTextInfo.m_Font = Root.Fonts[5];
    m_pTextInfo.m_vTextColor = Root.Colors.White;
    fXOffset = 5.0;
    fYOffset = 0.0;
    fWidth = 135.0;
    m_pTextInfo.AddTextLabel(Localize("MPCreateGame", "Options_Map", "R6Menu"), fXOffset, fYOffset, fWidth, TA_Left, false);
    fXOffset = fXSecondWindow;
    m_pTextInfo.AddTextLabel(Localize("MPCreateGame", "Options_MapList", "R6Menu"), fXOffset, fYOffset, fWidth, TA_Left, false);
    fXOffset = 5.0;
    fYOffset = (16.0 + float(214)) + float(5);
    m_pTextInfo.m_Font = Root.Fonts[6];
    m_iTextIndex = m_pTextInfo.AddTextLabel((m_szLocGameMode $ " ") $ (Localize("MPCreateGame", "Options_GameType", "R6Menu")), fXOffset, fYOffset, fXSecondWindow - fXOffset, TA_Left, false);
    m_pStartMapList = R6WindowTextListBoxExt(CreateControl(Class'R6Window.R6WindowTextListBoxExt', 7.0, 16.0, 135.0, 214.0, self));
    m_pStartMapList.TextColor = Root.Colors.BlueLight;
    m_pStartMapList.SetCornerType(No_Corners);
    m_pStartMapList.SetOverBorderColorEffect(Root.Colors.GrayLight);
    m_pStartMapList.ToolTipString = Localize("Tip", "Options_Map", "R6Menu");
    m_pFinalMapList = R6WindowTextListBoxExt(CreateControl(Class'R6Window.R6WindowTextListBoxExt', fXSecondWindow, 16.0, 135.0, 214.0, self));
    m_pFinalMapList.TextColor = Root.Colors.BlueLight;
    m_pFinalMapList.SetCornerType(No_Corners);
    m_pFinalMapList.SetOverBorderColorEffect(Root.Colors.GrayLight);
    m_pFinalMapList.ToolTipString = Localize("Tip", "Options_MapList", "R6Menu");
    m_pSelectButton = UWindowButton(CreateControl(Class'UWindow.UWindowButton', 148.0, 117.0, 13.0, 13.0, self));
    m_pSelectButton.m_bDrawButtonBorders = true;
    SetButtonRegion(true);
    m_pSelectButton.ToolTipString = Localize("Tip", "Options_MapListAddRemove", "R6Menu");
    fYOffset = (16.0 + float(214)) + float(5);
    m_pGameTypeCombo = R6WindowComboControl(CreateControl(Class'R6Window.R6WindowComboControl', fXSecondWindow, fYOffset, fWidth, LookAndFeel.Size_ComboHeight));
    m_pGameTypeCombo.SetFont(6);
    m_pGameTypeCombo.SetEditBoxTip(Localize("Tip", "Options_MapListGameType", "R6Menu"));
    m_pGameTypeCombo.List.MaxVisible = 5;
    CreateButtons();
}

function FillMapListItem()
{
    local R6WindowListBoxItemExt NewItem;
    local R6MissionDescription mission;
    local R6Console R6Console;
    local LevelInfo pLevel;
    local Region ItemR;
    local string szLocMapName, szMod, szRavenShieldMod;
    local int i, j;
    local bool bLoadMap;

    pLevel = GetLevel();
    R6Console = R6Console(Root.Console);
    m_pStartMapList.Items.Clear();
    szMod = class'Actor'.static.GetModMgr().m_pCurrentMod.m_szKeyWord;
    szRavenShieldMod = class'Actor'.static.GetModMgr().m_pRVS.m_szKeyWord;
    i = 0;

    while(i < R6Console.m_aMissionDescriptions.Length)
    {
        mission = R6Console.m_aMissionDescriptions[i];
        if(mission.m_MapName != "")
        {

            for(j = 0; j < mission.m_szGameTypes.Length; j++)
            {
                bLoadMap = false;
                if(szMod ~= mission.mod)
                {
                    bLoadMap = true;                    
                }
                else
                {
                    if(mission.mod ~= szRavenShieldMod)
                    {
                        bLoadMap = true;
                    }
                }
                if(bLoadMap && pLevel.IsGameTypeMultiplayer(mission.m_szGameTypes[j], true))
                {
                    NewItem = R6WindowListBoxItemExt(m_pStartMapList.Items.Append(m_pStartMapList.ListClass));
                    if(!Root.GetMapNameLocalisation(mission.m_MapName, szLocMapName))
                    {
                        szLocMapName = mission.m_MapName;
                    }
                    ItemR.X = 5;
                    ItemR.Y = 0;
                    ItemR.W = (135 - 5) - 13;
                    ItemR.H = 14;
                    AssignParamsToNewItem(NewItem, 0, szLocMapName, mission.m_MapName, ItemR, 0);
                    AssignParamsToNewItem(NewItem, 1, "", "", ItemR, 0, true);
                    break;
                }
            }
        }
        ++i;
    }
    m_pStartMapList.Items.Sort();
}

function string FillFinalMapList()
{
    local R6MenuInGameMultiPlayerRootWindow r6Root;
    local R6WindowListBoxItemExt NewItem;
    local int i;
    local Region ItemR;
    local string szGameType, szResult, szTemp, szGreenArmor, szRedArmor, szGreenPkg,
	    szRedPkg;

    local R6ServerInfo pServerOpt;
    local LevelInfo pLevel;
    local Region ItemRegion;

    pServerOpt = class'Actor'.static.GetServerOptions();
    pLevel = GetLevel();
    m_pFinalMapList.Items.Clear();
    if(pServerOpt.m_ServerMapList == none)
    {
        pServerOpt.m_ServerMapList = GetPlayerOwner().Spawn(Class'Engine.R6MapList');
    }

    for(i = 0; (i < 32) && pServerOpt.m_ServerMapList.Maps[i] != ""; i++)
    {
        szGameType = pLevel.GetGameTypeFromClassName(pServerOpt.m_ServerMapList.GameType[i]);
        szTemp = GetGameModeFromList(szGameType);
        if(m_eMyGameMode == GetPlayerOwner().EGameModeInfo.GMI_Adversarial)
        {
            if(!pLevel.IsGameTypeAdversarial(szGameType))
            {
                if(szResult == "")
                {
                    szResult = szTemp;
                }
                continue;
            }
            szResult = szTemp;            
        }
        else
        {
            if(m_eMyGameMode == GetPlayerOwner().EGameModeInfo.GMI_Cooperative)
            {
                if(!pLevel.IsGameTypeCooperative(szGameType))
                {
                    if(szResult == "")
                    {
                        szResult = szTemp;
                    }
                    continue;
                }
                szResult = szTemp;                
            }
            else
            {
                continue;
            }
        }
        if(!Root.GetMapNameLocalisation(pServerOpt.m_ServerMapList.Maps[i], szTemp))
        {
            if(!FindMapInStartMapList(pServerOpt.m_ServerMapList.Maps[i]))
            {
                continue;
            }
            szTemp = pServerOpt.m_ServerMapList.Maps[i];
        }
        NewItem = R6WindowListBoxItemExt(m_pFinalMapList.Items.Append(m_pFinalMapList.ListClass));
        ItemR.X = 5;
        ItemR.Y = 0;
        ItemR.W = (135 - 5) - 13;
        ItemR.H = 14;
        AssignParamsToNewItem(NewItem, 0, szTemp, pServerOpt.m_ServerMapList.Maps[i], ItemR, 0);
        ItemR.X = 10;
        ItemR.W = (135 - 10) - 13;
        ItemR.H = 11;
        AssignParamsToNewItem(NewItem, 1, pLevel.GetGameNameLocalization(szGameType), pServerOpt.m_ServerMapList.GameType[i], ItemR, 1);
        GetInitArmor(szTemp, szGameType, szGreenArmor, szRedArmor, szGreenPkg, szRedPkg);
        AssignParamsToNewItem(NewItem, 2, szGreenArmor, szGreenPkg, ItemR, 2);
        AssignParamsToNewItem(NewItem, 3, szRedArmor, szRedPkg, ItemR, 3);
    }
    if(szResult == "")
    {
        szResult = string(m_eMyGameMode);
    }
    return szResult;
}

function ManageAvailableGameTypes(UWindowList _pSelectItem, optional bool _bKeepItemGameType)
{
    local UWindowComboListItem pComboListItem;
    local R6MissionDescription pCurMissionDesc;
    local string szGameTypeFind, szGameTypeClassName, szFirstGameTypeFound, szItemGameType;
    local R6Console R6Console;
    local string szMapName, szEditBoxValue;
    local int i;
    local bool bUseSameGameType;
    local LevelInfo pLevel;

    pLevel = GetLevel();
    R6Console = R6Console(Root.Console);
    if(_pSelectItem == none)
    {
        return;
    }
    szMapName = R6WindowListBoxItemExt(_pSelectItem).GetItemMisc(0);
    szItemGameType = R6WindowListBoxItemExt(_pSelectItem).GetItemMisc(1);
    i = 0;

    while(i < R6Console.m_aMissionDescriptions.Length)
    {
        if(szMapName == R6Console.m_aMissionDescriptions[i].m_MapName)
        {
            pCurMissionDesc = R6Console.m_aMissionDescriptions[i];
            break;
        }
        ++i;
    }

    if(pCurMissionDesc != none)
    {
        m_pGameTypeCombo.DisableAllItems();
        szEditBoxValue = m_pGameTypeCombo.GetValue();
        szFirstGameTypeFound = "RGM_NoRulesMode";

        for(i = 0; i < pCurMissionDesc.m_szGameTypes.Length; i++)
        {
            szGameTypeFind = pCurMissionDesc.m_szGameTypes[i];
            szGameTypeClassName = (pCurMissionDesc.GameTypes[i].Package $ ".") $ pCurMissionDesc.GameTypes[i].type;
            pComboListItem = m_pGameTypeCombo.GetItem(pLevel.GetGameNameLocalization(szGameTypeFind));
            if(pComboListItem != none)
            {
                pComboListItem.bDisabled = false;
                if(szFirstGameTypeFound == "RGM_NoRulesMode")
                {
                    szFirstGameTypeFound = szGameTypeFind;
                }
                if(_bKeepItemGameType && szItemGameType == szGameTypeClassName)
                {
                    szFirstGameTypeFound = szGameTypeFind;
                    continue;
                }
                if(szEditBoxValue == pLevel.GetGameNameLocalization(szGameTypeFind))
                {
                    bUseSameGameType = true;
                }
            }
        }
    }
    if(!bUseSameGameType && szFirstGameTypeFound != "RGM_NoRulesMode")
    {
        m_pGameTypeCombo.SetValue(pLevel.GetGameNameLocalization(szFirstGameTypeFound), pLevel.GetGameTypeClassName(szFirstGameTypeFound));
    }
}

function CopyAndAddItemInList(UWindowListBoxItem _ItemToAdd, UWindowListControl _ListAddItem)
{
    local R6WindowListBoxItemExt NewItem, ItemToAdd;
    local Region ItemR;
    local string szGreenArmor, szRedArmor, szGreenPkg, szRedPkg;

    if((_ListAddItem.Items.Count() < 32) && _ItemToAdd != none)
    {
        ItemToAdd = R6WindowListBoxItemExt(_ItemToAdd);
        NewItem = R6WindowListBoxItemExt(_ListAddItem.Items.Append(_ListAddItem.ListClass));
        ItemR.X = 5;
        ItemR.Y = 0;
        ItemR.W = (135 - 5) - 13;
        ItemR.H = 14;
        AssignParamsToNewItem(NewItem, 0, ItemToAdd.GetItemText(0), ItemToAdd.GetItemMisc(0), ItemR, 0);
        ItemR.X = 10;
        ItemR.W = (135 - 10) - 13;
        ItemR.H = 11;
        szGreenArmor = GetLevel().GetGameTypeFromLocName(m_pGameTypeCombo.GetValue(), true);
        AssignParamsToNewItem(NewItem, 1, m_pGameTypeCombo.GetValue(), GetLevel().GetGameTypeClassName(szGreenArmor), ItemR, 1);
        GetInitArmor(ItemToAdd.GetItemText(0), GetLevel().GetGameTypeFromLocName(m_pGameTypeCombo.GetValue(), true), szGreenArmor, szRedArmor, szGreenPkg, szRedPkg);
        AssignParamsToNewItem(NewItem, 2, szGreenArmor, szGreenPkg, ItemR, 2);
        AssignParamsToNewItem(NewItem, 3, szRedArmor, szRedPkg, ItemR, 3);
    }
}

function AssignParamsToNewItem(R6WindowListBoxItemExt NewItem, int _index, string _szText, string _szMisc, Region R, int _iLineNumber, optional bool _bNotDisplay)
{
    local R6WindowListBoxItemExt.stItemDesc NewItemDesc;

    if(NewItem != none)
    {
        NewItemDesc.szText = _szText;
        NewItemDesc.szMisc = _szMisc;
        NewItemDesc.TextFont = Root.Fonts[6];
        NewItemDesc.fXPos = float(R.X);
        NewItemDesc.fYPos = float(R.Y);
        NewItemDesc.fWidth = float(R.W);
        NewItemDesc.fHeigth = float(R.H);
        NewItemDesc.iLineNumber = _iLineNumber;
        NewItemDesc.eAlignment = TA_Left;
        NewItemDesc.bDisplay = !_bNotDisplay;
        NewItem.SetItemParam(_index, NewItemDesc);
    }
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
        _SelectedMapList[i] = R6WindowListBoxItemExt(CurItem).GetItemMisc(0);
        _SelectedGameTypeList[i] = R6WindowListBoxItemExt(CurItem).GetItemMisc(1);
        CurItem = UWindowListBoxItem(CurItem.Next);
        i++;
    }
    return byte(i);
}

function Notify(UWindowDialogControl C, byte E)
{
    local bool bUpdate;

    if(m_bInGame)
    {
        return;
    }
    if(C.IsA('R6WindowTextListBoxExt'))
    {
        switch(E)
        {
            case 2:
                if(C == m_pStartMapList)
                {
                    if(m_pStartMapList.GetSelectedItem() != none)
                    {
                        ManageAvailableGameTypes(m_pStartMapList.GetSelectedItem());
                    }
                    m_pFinalMapList.DropSelection();
                    SetButtonRegion(true);                    
                }
                else
                {
                    if(m_pFinalMapList.GetSelectedItem() != none)
                    {
                        ManageAvailableGameTypes(m_pFinalMapList.GetSelectedItem(), true);
                        m_pGameTypeCombo.SetValue(R6WindowListBoxItemExt(m_pFinalMapList.GetSelectedItem()).GetItemText(1));
                    }
                    m_pStartMapList.DropSelection();
                    SetButtonRegion(false);
                }
                break;
            case 11:
                ManageTextListBox();
                break;
            default:
                break;
        }        
    }
    else
    {
        super.Notify(C, E);
    }
    bUpdate = false;
    if(m_bFinalListEmpty)
    {
        if(!IsFinalMapListEmpty())
        {
            m_bFinalListEmpty = false;
            bUpdate = true;
        }        
    }
    else
    {
        if(IsFinalMapListEmpty())
        {
            m_bFinalListEmpty = true;
            bUpdate = true;
        }
    }
    if(bUpdate)
    {
        if(R6MenuMPCreateGameTabOptions(OwnerWindow) != none)
        {
            R6MenuMPCreateGameTabOptions(OwnerWindow).UpdateSkinButton();
        }
    }
}

function ManageComboChange()
{
    local R6WindowListBoxItemExt Item;
    local UWindowComboListItem pComboListItem;
    local string szTemp, szGreenArmor, szRedArmor, szGreenPkg, szRedPkg;

    Item = R6WindowListBoxItemExt(m_pStartMapList.GetSelectedItem());
    if(Item != none)
    {
        pComboListItem = m_pGameTypeCombo.GetItem(m_pGameTypeCombo.GetValue());
        if(pComboListItem != none)
        {
            if(!pComboListItem.bDisabled)
            {
                Item.SetItemMisc(1, m_pGameTypeCombo.GetValue());
            }
        }
        return;
    }
    Item = R6WindowListBoxItemExt(m_pFinalMapList.GetSelectedItem());
    if(Item != none)
    {
        pComboListItem = m_pGameTypeCombo.GetItem(m_pGameTypeCombo.GetValue());
        if(pComboListItem != none)
        {
            if(!pComboListItem.bDisabled)
            {
                szTemp = GetLevel().GetGameTypeFromLocName(m_pGameTypeCombo.GetValue(), true);
                Item.SetItemText(1, m_pGameTypeCombo.GetValue());
                Item.SetItemMisc(1, GetLevel().GetGameTypeClassName(szTemp));
                GetInitArmor(Item.GetItemText(0), szTemp, szGreenArmor, szRedArmor, szGreenPkg, szRedPkg);
                Item.SetItemText(2, szGreenArmor);
                Item.SetItemText(3, szRedArmor);
            }
        }
    }
}

function GetInitArmor(string _szMapName, string _szGameType, out string _szGreenArmor, out string _szRedArmor, out string _szGreenPkg, out string _szRedPkg)
{
    local Class<R6ArmorDescription> ArmorDescriptionClass;
    local R6MissionDescription CurrentMission;
    local R6Console R6Console;
    local string szGreenArmor, szRedArmor, szTemp, szValidEntry;
    local int i, j, nbArmor;
    local bool bFind, bFindBothArmor, bFindGreenArmor, bFindRedArmor;
    local R6ModMgr pModManager;

    pModManager = class'Actor'.static.GetModMgr();
    R6Console = R6Console(Root.Console);
    szGreenArmor = "";
    szRedArmor = "";
    for(i = 0; i < R6Console.m_aMissionDescriptions.Length; ++i)
    {
        CurrentMission = R6Console.m_aMissionDescriptions[i];
        if(CurrentMission == none)
        {
            break;
        }
        if(!Root.GetMapNameLocalisation(CurrentMission.m_MapName, szTemp))
        {
            continue;
        }
        if(szTemp == _szMapName)
        {
            bFind = true;
            break;
        }
    }

    if(bFind)
    {

        for(j = 0; j < CurrentMission.SkinsPerGameTypes.Length; j++)
        {
            szTemp = GetLevel().GetGameTypeClassName(_szGameType);
            i = InStr(szTemp, ".");
            szTemp = Right(szTemp, (Len(szTemp) - 1) - InStr(szTemp, "."));
            if(CurrentMission.SkinsPerGameTypes[j].type ~= szTemp)
            {
                szGreenArmor = CurrentMission.SkinsPerGameTypes[j].Green;
                szRedArmor = CurrentMission.SkinsPerGameTypes[j].Red;
                break;
            }
        }
    }
    bFind = false;
    if(szGreenArmor != "")
    {
        bFindBothArmor = GetLevel().IsGameTypeTeamAdversarial(_szGameType);
        szGreenArmor = (CurrentMission.SkinsPerGameTypes[j].greenPackage $ ".") $ szGreenArmor;
        szRedArmor = (CurrentMission.SkinsPerGameTypes[j].redPackage $ ".") $ szRedArmor;
        _szGreenPkg = szGreenArmor;
        _szRedPkg = szRedArmor;

        for(j = 0; j < pModManager.m_pCurrentMod.m_aDescriptionPackage.Length; j++)
        {

            for(ArmorDescriptionClass = Class<R6ArmorDescription>(GetFirstPackageClass(pModManager.m_pCurrentMod.m_aDescriptionPackage[j] $ ".u", Class'R6Description.R6ArmorDescription')); ArmorDescriptionClass != none; ArmorDescriptionClass = Class<R6ArmorDescription>(GetNextClass()))
            {
                if(ArmorDescriptionClass.default.m_NameID != "NONE")
                {
                    if(ArmorDescriptionClass.default.m_ClassName == szGreenArmor)
                    {
                        szGreenArmor = Localize(ArmorDescriptionClass.default.m_NameID, "ID_NAME", "R6Armor");
                        bFindGreenArmor = true;                        
                    }
                    else
                    {
                        if(bFindBothArmor && ArmorDescriptionClass.default.m_ClassName == szRedArmor)
                        {
                            szRedArmor = Localize(ArmorDescriptionClass.default.m_NameID, "ID_NAME", "R6Armor");
                            bFindRedArmor = true;                            
                        }
                        else
                        {
                            if(szValidEntry == "")
                            {
                                szValidEntry = Localize(ArmorDescriptionClass.default.m_NameID, "ID_NAME", "R6Armor");
                            }
                        }
                    }
                    if(bFindBothArmor)
                    {
                        if(bFindGreenArmor && bFindRedArmor)
                        {
                            bFind = true;
                            break;
                        }                        
                    }
                    else
                    {
                        if(bFindGreenArmor)
                        {
                            bFind = true;
                            break;
                        }
                    }
                }
            }

            FreePackageObjects();
        }
        if(!bFind && pModManager.m_pCurrentMod.m_bUseCustomOperatives == true)
        {

            for(j = 0; j < pModManager.GetPackageMgr().GetNbPackage(); j++)
            {
                if(bFind)
                {
                    break;
                }

                for(ArmorDescriptionClass = Class<R6ArmorDescription>(pModManager.GetPackageMgr().GetFirstClassFromPackage(j, Class'R6Description.R6ArmorDescription')); (ArmorDescriptionClass != none) && ArmorDescriptionClass.default.m_bHideFromMenu == false; ArmorDescriptionClass = Class<R6ArmorDescription>(pModManager.GetPackageMgr().GetNextClassFromPackage()))
                {
                    if(ArmorDescriptionClass.default.m_ClassName == szGreenArmor)
                    {
                        szGreenArmor = Localize(ArmorDescriptionClass.default.m_NameID, "ID_NAME", "R6Armor");
                        bFindGreenArmor = true;                        
                    }
                    else
                    {
                        if(bFindBothArmor && ArmorDescriptionClass.default.m_ClassName == szRedArmor)
                        {
                            szRedArmor = Localize(ArmorDescriptionClass.default.m_NameID, "ID_NAME", "R6Armor");
                            bFindRedArmor = true;
                        }
                    }
                    if(bFindBothArmor)
                    {
                        if(bFindGreenArmor && bFindRedArmor)
                        {
                            bFind = true;
                            continue;
                        }                        
                    }
                    else
                    {
                        if(bFindGreenArmor)
                        {
                            bFind = true;
                            continue;
                        }
                    }
                }
            }
        }
    }
    if(!bFind)
    {
        if(!bFindGreenArmor)
        {
            if(bFindBothArmor && bFindRedArmor)
            {
                szGreenArmor = szRedArmor;                
            }
            else
            {
                if(szValidEntry != "")
                {
                    szGreenArmor = szValidEntry;                    
                }
                else
                {
                    szGreenArmor = "Uniform is not valid";
                }
            }
        }
        if(!bFindRedArmor)
        {
            if(bFindBothArmor && bFindGreenArmor)
            {
                szRedArmor = szGreenArmor;                
            }
            else
            {
                if(szValidEntry != "")
                {
                    szRedArmor = szValidEntry;                    
                }
                else
                {
                    szRedArmor = "Uniform is not valid";
                }
            }
        }
    }
    _szGreenArmor = szGreenArmor;
    if(bFindBothArmor)
    {
        _szRedArmor = szRedArmor;        
    }
    else
    {
        _szRedArmor = "";
    }
}

function SetAllArmor()
{
    local int i;
    local R6WindowListBoxItemExt CurItem;
    local string szMapName, szItemGameType, szGreenArmor, szRedArmor;
    local R6MissionDescription mission;
    local R6Console R6Console;

    R6Console = R6Console(Root.Console);

    for(CurItem = R6WindowListBoxItemExt(m_pFinalMapList.Items.Next); CurItem != none; CurItem = R6WindowListBoxItemExt(CurItem.Next))
    {
        szMapName = CurItem.GetItemMisc(0);
        szItemGameType = CurItem.GetItemMisc(1);
        szGreenArmor = CurItem.GetItemMisc(2);
        szRedArmor = CurItem.GetItemMisc(3);
        i = 0;

        while(i < R6Console.m_aMissionDescriptions.Length)
        {
            mission = R6Console.m_aMissionDescriptions[i];
            if(mission.m_MapName == szMapName)
            {
                mission.SetSkins(szItemGameType, szGreenArmor, szRedArmor);
            }
            ++i;
        }
    }
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
