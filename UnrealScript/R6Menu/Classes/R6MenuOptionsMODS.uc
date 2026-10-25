class R6MenuOptionsMODS extends R6MenuOptionsTab;

// OPTION MODS
// MPF - Yannick
var R6WindowListMODS					m_pListOfMODS;				// the list of MODS

var UWindowInfo							m_pInfo;					// official informations for mission pack/mods

function InitPageOptions()
{
    local float fXOffset, fYOffset;

    m_pInfo = new (none) Class'UWindow.UWindowInfo';
    m_pInfo.LoadConfig();
    m_pListOfMods = R6WindowListMODS(CreateWindow(Class'R6Window.R6WindowListMODS', 0.0, 0.0, WinWidth, WinHeight - float(14)));
    m_pListOfMods.ListClass = Class'R6Window.R6WindowListBoxItem';
    m_pListOfMods.m_Font = Root.Fonts[6];
    m_pListOfMods.Register(self);
    m_pListOfMods.m_DoubleClickClient = OwnerWindow;
    m_pListOfMods.m_bSkipDrawBorders = true;
    m_pListOfMods.m_fItemHeight = 14.0;
    m_szGeneralButLoc = Localize("Options", "ActivateModButton", "R6Menu");
    m_szGeneralButTip = Localize("Tip", "ActivateModButton", "R6Menu");
    InitResetButton();
    SetMenuMODS();
    m_bInitComplete = true;
}

function SetMenuMODS()
{
    local R6WindowListBoxItem NewItem;
    local int i;
    local R6ModMgr pModManager;
    local R6Mod pTempMod;
    local string szInstallStatus;

    pModManager = class'Actor'.static.GetModMgr();
    m_pListOfMods.Items.Clear();

    for(i = 0; i < m_pInfo.m_AModsInfo.Length; i++)
    {
        NewItem = R6WindowListBoxItem(m_pListOfMods.Items.Append(m_pListOfMods.ListClass));
        NewItem.SetItemParameters(0, Localize(m_pInfo.m_AModsInfo[i], "ModName", "R6Mod", true), Root.Fonts[5], 5.0, 2.0, WinWidth, 15.0, 0, TA_Left);
        szInstallStatus = Localize("MISC", "NotInstalled", "R6Mod");
        m_pListOfMods.SetItemState(NewItem, m_pListOfMods.eItemState.eIS_Disable, true);
        NewItem.SetItemParameters(1, szInstallStatus, Root.Fonts[5], WinWidth - float(5), 2.0, WinWidth, 15.0, 0, TA_Right);
        NewItem.SetItemParameters(2, Localize(m_pInfo.m_AModsInfo[i], "ModInfo", "R6Mod", true), Root.Fonts[5], 5.0, 0.0, WinWidth, 15.0, 1, TA_Left);
        NewItem.HelpText = m_pInfo.m_AModsInfo[i];
    }

    for(i = 0; i < pModManager.GetNbMods(); i++)
    {
        pTempMod = pModManager.m_aMods[i];
        NewItem = R6WindowListBoxItem(m_pListOfMods.FindItemWithName(pTempMod.m_szKeyWord));
        if(NewItem == none)
        {
            NewItem = R6WindowListBoxItem(m_pListOfMods.Items.Append(m_pListOfMods.ListClass));
        }
        NewItem.SetItemParameters(0, pTempMod.m_szName, Root.Fonts[5], 5.0, 2.0, WinWidth, 15.0, 0, TA_Left);
        if(pModManager.CheckValidModVersion(pTempMod))
        {
            szInstallStatus = Localize("MISC", "Installed", "R6Mod");
            m_pListOfMods.SetItemState(NewItem, m_pListOfMods.eItemState.eIS_Disable, false);
            if(pTempMod == pModManager.m_pCurrentMod)
            {
                m_pListOfMods.SetItemState(NewItem, m_pListOfMods.eItemState.eIS_CurrentChoice, true);                
            }
            else
            {
                m_pListOfMods.SetItemState(NewItem, m_pListOfMods.eItemState.eIS_Normal, true);
            }            
        }
        else
        {
            szInstallStatus = Localize("MISC", "VersionMM", "R6Mod");
            m_pListOfMods.SetItemState(NewItem, m_pListOfMods.eItemState.eIS_Disable, true);
        }
        NewItem.SetItemParameters(1, szInstallStatus, Root.Fonts[5], WinWidth - float(5), 2.0, WinWidth, 15.0, 0, TA_Right);
        NewItem.SetItemParameters(2, pTempMod.m_szModInfo, Root.Fonts[5], 5.0, 0.0, WinWidth, 15.0, 1, TA_Left);
        NewItem.HelpText = pTempMod.m_szKeyWord;
    }
}

function Notify(UWindowDialogControl C, byte E)
{
    if(E == DE_Click)
    {
        if(C.IsA('R6WindowButton'))
        {
            if(C == m_pGeneralButUse)
            {
                m_pListOfMods.ActivateMOD();
            }
        }        
    }
    else
    {
        if(E == DE_DoubleClick)
        {
            if(C == m_pListOfMods)
            {
                m_pListOfMods.ActivateMOD();
            }
        }
    }
}
