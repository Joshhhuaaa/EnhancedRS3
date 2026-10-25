class R6MenuSkinsSelection extends UWindowDialogClientWindow;

const C_fY_START_TEXT = 15;

const C_fY_START = 40;

const C_fWIDTH = 140;

const C_fWIDTH_OF_ARMOR_W = 160;

const C_fHEIGHT_OF_ARMOR_IMAGE = 245;

const C_iMAX_MAPLIST_SIZE  = 32;						  // the max size of the selected map list

const C_MAP_INDEX = 0;

const C_GAME_TYPE_INDEX = 1;

const C_GREEN_ARMOR_INDEX = 2;

const C_RED_ARMOR_INDEX = 3;

struct ArmorInfo
{
    var Class armorClass;
    var string szArmorPkg;
};

var bool m_bFirstDisplay;

var R6WindowTextLabelExt                m_pTextInfo;      // the text info in background

var R6WindowTextListBoxExt m_pMapList;

var R6WindowTextListBox m_ArmorListBox;

var R6MenuMPArmor m_2DArmor;

var Class<R6ArmorDescription> m_GreenArmorDesc;

var Class<R6ArmorDescription> m_RedArmorDesc;

var array<ArmorInfo> m_AArmors;

function Created()
{
    local float fXPos, fXStep;

    fXStep = ((WinWidth - float(2 * 140)) - float(160)) * 0.25;
    m_pTextInfo = R6WindowTextLabelExt(CreateWindow(Class'R6Window.R6WindowTextLabelExt', 0.0, 0.0, WinWidth, WinHeight, self));
    m_pTextInfo.bAlwaysBehind = true;
    m_pTextInfo.SetNoBorder();
    m_pTextInfo.m_Font = Root.Fonts[5];
    fXPos = fXStep;
    m_pTextInfo.m_vTextColor = Root.Colors.White;
    m_pTextInfo.AddTextLabel(Localize("MPCreateGame", "Options_Map", "R6Menu"), fXPos, 15.0, 140.0, TA_Center, false);
    m_pMapList = R6WindowTextListBoxExt(CreateControl(Class'R6Window.R6WindowTextListBoxExt', fXPos, 40.0, 140.0, 245.0, self));
    m_pMapList.TextColor = Root.Colors.BlueLight;
    m_pMapList.SetCornerType(No_Corners);
    m_pMapList.SetOverBorderColorEffect(Root.Colors.GrayLight);
    fXPos = (fXPos + float(140)) + fXStep;
    m_pTextInfo.m_vTextColor = Root.Colors.BlueLight;
    m_pTextInfo.AddTextLabel(Localize("MPCreateGame", "Teams", "R6Menu"), fXPos, 15.0, 160.0, TA_Center, false);
    m_2DArmor = R6MenuMPArmor(CreateControl(Class'R6Menu.R6MenuMPArmor', fXPos, 40.0, 160.0, 245.0, self));
    fXPos = (fXPos + float(160)) + fXStep;
    m_pTextInfo.m_vTextColor = Root.Colors.White;
    m_pTextInfo.AddTextLabel(Localize("MPCreateGame", "Options_UniformSelect", "R6Menu"), fXPos, 15.0, 140.0, TA_Center, false);
    m_ArmorListBox = R6WindowTextListBox(CreateControl(Class'R6Window.R6WindowTextListBox', fXPos, 40.0, 140.0, 245.0, self));
    m_ArmorListBox.ListClass = Class'R6Window.R6WindowListBoxItem';
    m_ArmorListBox.m_VertSB.SetHideWhenDisable(true);
    m_ArmorListBox.m_Font = Root.Fonts[6];
    m_ArmorListBox.SetCornerType(No_Corners);
    m_ArmorListBox.SetOverBorderColorEffect(Root.Colors.GrayLight);
    m_ArmorListBox.m_fSpaceBetItem = 0.0;
}

function ShowWindow()
{
    super(UWindowWindow).ShowWindow();
    m_bFirstDisplay = true;
    FirstDisplay();
    m_bFirstDisplay = false;
}

function FirstDisplay()
{
    if(m_pMapList.GetSelectedItem() == none)
    {
        if(m_pMapList.Items.Count() > 0)
        {
            m_pMapList.SetSelectedItem(UWindowListBoxItem(m_pMapList.Items.Next));
        }
    }
    m_pMapList.MakeSelectedVisible();
    m_2DArmor.SetHighLightGreenArmor(true);
    m_2DArmor.SetHighLightRedArmor(false);
    FillArmorList();
    UpdateImages();
}

function UpdateImages()
{
    local Region R;
    local string szTemp;

    if(m_ArmorListBox.GetSelectedItem() != none)
    {
        m_2DArmor.SetArmorTexture(m_GreenArmorDesc.default.m_2DMenuTexture, m_GreenArmorDesc.default.m_2dMenuRegion, false);
        szTemp = R6WindowListBoxItemExt(m_pMapList.GetSelectedItem()).m_AItemDesc[1].szText;
        if(GetLevel().IsGameTypeTeamAdversarial(GetLevel().GetGameTypeFromLocName(szTemp, true)))
        {
            m_2DArmor.SetArmorTexture(m_RedArmorDesc.default.m_2DMenuTexture, m_RedArmorDesc.default.m_2dMenuRegion, true);
            m_2DArmor.SetButtonsStatus(false, true);            
        }
        else
        {
            m_2DArmor.SetArmorTexture(none, R, true);
            m_2DArmor.SetButtonsStatus(true, true);
        }
    }
}

function FillArmorList()
{
    local Class<R6ArmorDescription> ArmorDescriptionClass;
    local R6WindowListBoxItem NewItem, GreenItem, RedItem;
    local R6WindowListBoxItemExt MapListItem;
    local string szTemp;
    local int i;

    BuildAvailableMissionArmors();
    if(m_ArmorListBox != none)
    {
        m_ArmorListBox.Clear();
        m_GreenArmorDesc = none;
        m_RedArmorDesc = none;
        MapListItem = R6WindowListBoxItemExt(m_pMapList.GetSelectedItem());

        for(i = 0; i < m_AArmors.Length; i++)
        {
            ArmorDescriptionClass = Class<R6ArmorDescription>(m_AArmors[i].armorClass);
            NewItem = R6WindowListBoxItem(m_ArmorListBox.Items.Append(Class'R6Window.R6WindowListBoxItem'));
            NewItem.HelpText = Localize(ArmorDescriptionClass.default.m_NameID, "ID_NAME", "R6Armor");
            NewItem.m_szMisc = m_AArmors[i].szArmorPkg;
            NewItem.m_Object = ArmorDescriptionClass;
            szTemp = MapListItem.GetItemText(2);
            if(szTemp == NewItem.HelpText)
            {
                m_GreenArmorDesc = ArmorDescriptionClass;
                GreenItem = NewItem;
            }
            szTemp = MapListItem.GetItemText(3);
            if(szTemp == NewItem.HelpText)
            {
                m_RedArmorDesc = ArmorDescriptionClass;
                RedItem = NewItem;
            }
        }
        if(MapListItem.GetItemText(3) == "")
        {
            if(m_2DArmor.IsRedArmorSelect())
            {
                m_2DArmor.SetHighLightGreenArmor(true);
                m_2DArmor.SetHighLightRedArmor(false);
                m_ArmorListBox.SetSelectedItem(GreenItem);
            }
        }
        if(m_ArmorListBox.GetSelectedItem() == none)
        {
            if((GreenItem != none) && m_2DArmor.IsGreenArmorSelect())
            {
                m_ArmorListBox.SetSelectedItem(GreenItem);                
            }
            else
            {
                if((RedItem != none) && m_2DArmor.IsRedArmorSelect())
                {
                    m_ArmorListBox.SetSelectedItem(RedItem);
                }
            }
        }
        m_ArmorListBox.MakeSelectedVisible();
    }
}

function BuildAvailableMissionArmors()
{
    local Class<R6ArmorDescription> ArmorDescriptionClass;
    local R6MissionDescription CurrentMission;
    local R6Console R6Console;
    local ArmorInfo pArmorInfo;
    local array< Class > AArmors;
    local string szTemp;
    local int i, j, nbArmor;
    local bool bFind;
    local R6ModMgr pModManager;

    pModManager = class'Actor'.static.GetModMgr();
    R6Console = R6Console(Root.Console);
    m_AArmors.Remove(0, m_AArmors.Length);
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
        if(szTemp == R6WindowListBoxItemExt(m_pMapList.GetSelectedItem()).m_AItemDesc[0].szText)
        {
            bFind = true;
            break;
        }
    }

    if(bFind)
    {
        nbArmor = 0;

        for(j = 0; j < pModManager.m_pCurrentMod.m_aDescriptionPackage.Length; j++)
        {

            for(ArmorDescriptionClass = Class<R6ArmorDescription>(GetFirstPackageClass(pModManager.m_pCurrentMod.m_aDescriptionPackage[j] $ ".u", Class'R6Description.R6ArmorDescription')); ArmorDescriptionClass != none; ArmorDescriptionClass = Class<R6ArmorDescription>(GetNextClass()))
            {
                if(ArmorDescriptionClass.default.m_NameID != "NONE")
                {
                    AArmors[nbArmor] = ArmorDescriptionClass;
                    nbArmor++;
                }
            }
            FreePackageObjects();
        }
        if(pModManager.m_pCurrentMod.m_bUseCustomOperatives == true)
        {

            for(j = 0; j < pModManager.GetPackageMgr().GetNbPackage(); j++)
            {

                for(ArmorDescriptionClass = Class<R6ArmorDescription>(pModManager.GetPackageMgr().GetFirstClassFromPackage(j, Class'R6Description.R6ArmorDescription')); (ArmorDescriptionClass != none) && ArmorDescriptionClass.default.m_bHideFromMenu == false; ArmorDescriptionClass = Class<R6ArmorDescription>(pModManager.GetPackageMgr().GetNextClassFromPackage()))
                {
                    AArmors[nbArmor] = ArmorDescriptionClass;
                    nbArmor++;
                }
            }
        }
        class'R6MenuEquipmentDetailControl'.static.SortDescriptions(true, AArmors, "R6Armor", true);

        for(j = 0; j < nbArmor; j++)
        {
            pArmorInfo.armorClass = AArmors[j];
            ArmorDescriptionClass = Class<R6ArmorDescription>(pArmorInfo.armorClass);
            pArmorInfo.szArmorPkg = ArmorDescriptionClass.default.m_ClassName;
            m_AArmors[j] = pArmorInfo;
        }
    }
}

function CopyAllValues(R6MenuMapListExt _pMyList)
{
    local R6WindowListBoxItemExt CurItem, CreateItem, FoundItem;
    local bool Found;

    m_pMapList.DropSelection();
    m_pMapList.Items.Clear();

    for(CurItem = R6WindowListBoxItemExt(_pMyList.m_pFinalMapList.Items.Next); CurItem != none; CurItem = R6WindowListBoxItemExt(CurItem.Next))
    {
        Found = false;

        for(FoundItem = R6WindowListBoxItemExt(m_pMapList.Items.Next); FoundItem != none; FoundItem = R6WindowListBoxItemExt(FoundItem.Next))
        {
            if(SameSkins(FoundItem, CurItem))
            {
                Found = true;
            }
        }
        CreateItem = CopyItemInList(CurItem, m_pMapList);
        if((m_pMapList.GetSelectedItem() == none) && _pMyList.m_pFinalMapList.GetSelectedItem() == CurItem)
        {
            m_pMapList.SetSelectedItem(CreateItem);
        }
    }
}

function GetAllValues(out R6MenuMapListExt _pMyList)
{
    local R6WindowListBoxItemExt CurItem;

    _pMyList.m_pFinalMapList.Items.Clear();

    for(CurItem = R6WindowListBoxItemExt(m_pMapList.Items.Next); CurItem != none; CurItem = R6WindowListBoxItemExt(CurItem.Next))
    {
        CopyItemInList(CurItem, _pMyList.m_pFinalMapList);
    }
}

function R6WindowListBoxItemExt CopyItemInList(R6WindowListBoxItemExt _ItemToAdd, UWindowListControl _ListAddItem)
{
    local R6WindowListBoxItemExt NewItem;
    local R6WindowListBoxItemExt.stItemDesc ItemDesc;
    local int i;

    if(_ListAddItem.Items.Count() < 32)
    {
        NewItem = R6WindowListBoxItemExt(_ListAddItem.Items.Append(_ListAddItem.ListClass));

        for(i = 0; i < _ItemToAdd.m_AItemDesc.Length; i++)
        {
            ItemDesc.szText = _ItemToAdd.m_AItemDesc[i].szText;
            ItemDesc.szMisc = _ItemToAdd.m_AItemDesc[i].szMisc;
            ItemDesc.TextFont = _ItemToAdd.m_AItemDesc[i].TextFont;
            ItemDesc.fXPos = _ItemToAdd.m_AItemDesc[i].fXPos;
            ItemDesc.fYPos = _ItemToAdd.m_AItemDesc[i].fYPos;
            ItemDesc.fWidth = _ItemToAdd.m_AItemDesc[i].fWidth;
            ItemDesc.fHeigth = _ItemToAdd.m_AItemDesc[i].fHeigth;
            ItemDesc.iLineNumber = _ItemToAdd.m_AItemDesc[i].iLineNumber;
            ItemDesc.eAlignment = _ItemToAdd.m_AItemDesc[i].eAlignment;
            ItemDesc.bDisplay = _ItemToAdd.m_AItemDesc[i].bDisplay;
            NewItem.m_AItemDesc[NewItem.m_AItemDesc.Length] = ItemDesc;
        }
    }
    return NewItem;
}

function SetButtonRegion(bool _bInverseTex)
{
    return;
}

function bool SameSkins(R6WindowListBoxItemExt Item1, R6WindowListBoxItemExt Item2)
{
    if(Item1.GetItemMisc(0) == Item2.GetItemMisc(0))
    {
        if(Item1.GetItemMisc(1) == Item2.GetItemMisc(1))
        {
            return true;
        }
    }
    return false;
}

function ChangeCurrentMapSkin(int Skin)
{
    local R6WindowListBoxItemExt CurItem, SelItem;

    SelItem = R6WindowListBoxItemExt(m_pMapList.GetSelectedItem());

    for(CurItem = R6WindowListBoxItemExt(m_pMapList.Items.Next); CurItem != none; CurItem = R6WindowListBoxItemExt(CurItem.Next))
    {
        if(SameSkins(SelItem, CurItem))
        {
            CurItem.SetItemText(Skin, m_ArmorListBox.GetSelectedItem().HelpText);
            CurItem.SetItemMisc(Skin, R6WindowListBoxItem(m_ArmorListBox.GetSelectedItem()).m_szMisc);
        }
    }
}

function Notify(UWindowDialogControl C, byte E)
{
    local string szTemp;

    if(m_bFirstDisplay)
    {
        return;
    }
    if(C.IsA('R6WindowButtonGear'))
    {
        switch(E)
        {
            case 2:
                m_2DArmor.SetHighLightGreenArmor(false);
                m_2DArmor.SetHighLightRedArmor(false);
                if(C == m_2DArmor.m_2DArmor)
                {
                    m_2DArmor.SetHighLightGreenArmor(true);                    
                }
                else
                {
                    if(C == m_2DArmor.m_2DArmorRed)
                    {
                        m_2DArmor.SetHighLightRedArmor(true);
                    }
                }
                FillArmorList();
                break;
            case 12:
                m_2DArmor.SetArmorBorderColor(C, E);
                break;
            case 9:
                m_2DArmor.SetArmorBorderColor(C, E);
                break;
            default:
                break;
        }        
    }
    else
    {
        if(C.IsA('R6WindowTextListBoxExt'))
        {
            if((E == DE_Click) || E == DE_DoubleClick)
            {
                if(m_pMapList.GetSelectedItem() != none)
                {
                    FillArmorList();
                    UpdateImages();
                }
            }            
        }
        else
        {
            if(C.IsA('R6WindowTextListBox'))
            {
                if((E == DE_Click) || E == DE_DoubleClick)
                {
                    if(m_ArmorListBox.GetSelectedItem() != none)
                    {
                        if(m_pMapList.GetSelectedItem() != none)
                        {
                            if(m_2DArmor.IsGreenArmorSelect())
                            {
                                m_GreenArmorDesc = Class<R6ArmorDescription>(R6WindowListBoxItem(m_ArmorListBox.GetSelectedItem()).m_Object);
                                ChangeCurrentMapSkin(2);                                
                            }
                            else
                            {
                                if(m_2DArmor.IsRedArmorSelect())
                                {
                                    m_RedArmorDesc = Class<R6ArmorDescription>(R6WindowListBoxItem(m_ArmorListBox.GetSelectedItem()).m_Object);
                                    ChangeCurrentMapSkin(3);
                                }
                            }
                            UpdateImages();
                        }
                    }
                }
            }
        }
    }
}
