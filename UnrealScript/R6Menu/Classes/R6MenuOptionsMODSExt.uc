class R6MenuOptionsMODSExt extends R6MenuOptionsMODS;

function Created()
{
}

function InitPageOptions()
{
    local float fXOffset, fYOffset;

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

    for(i = 0; i < pModManager.GetNbMods(); i++)
    {
        pTempMod = pModManager.m_aMods[i];
        NewItem = R6WindowListBoxItem(m_pListOfMods.FindItemWithName(pTempMod.m_szKeyWord));
        if(pModManager.IsOfficialMod(pTempMod.m_szKeyWord))
        {
            continue;
        }
        if(NewItem == none)
        {
            NewItem = R6WindowListBoxItem(m_pListOfMods.Items.Append(m_pListOfMods.ListClass));
        }
        NewItem.SetItemParameters(0, pTempMod.m_szName, Root.Fonts[5], 5.0, 2.0, WinWidth, 15.0, 0, TA_Left);
        szInstallStatus = Localize("MISC", "Installed", "R6Mod");
        m_pListOfMods.SetItemState(NewItem, m_pListOfMods.eItemState.eIS_Normal, true);
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
                log("DE_Click");
                ActiveMod();
            }
        }        
    }
    else
    {
        if(E == DE_DoubleClick)
        {
            if(C == m_pListOfMods)
            {
                log("DE_DoubleClick");
                ActiveMod();
            }
        }
    }
}

function ActiveMod()
{
    local array<UWindowRootWindow.eGameWidgetID> AWIDList;

    if((m_pListOfMods != none) && m_pListOfMods.m_SelectedItem != none)
    {
        class'Actor'.static.GetModMgr().m_szPendingModName = m_pListOfMods.m_SelectedItem.HelpText;
        class'Actor'.static.GetModMgr().SetCurrentMod(m_pListOfMods.m_SelectedItem.HelpText, GetLevel(), true);
        AWIDList[AWIDList.Length] = UbiComWidgetID;
        R6Console(Root.Console).CleanAndChangeMod(AWIDList);
    }
}
