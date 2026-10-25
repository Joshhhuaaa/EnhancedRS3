//=============================================================================
//  R6MenuMPMenuTab.uc : All the tab menu were define overhere
//                       You can choose only one of the 3 possible settings!!!!
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/5  * Create by Yannick Joly
//=============================================================================
class R6MenuMPMenuTab extends UWindowDialogClientWindow;

const K_HALFWINDOWWIDTH                 = 310;                    // the half size of window LAN SERVER INFO and GameMode see K_WINDOWWIDTH in MenuMultiplyerWidget
const K_FSECOND_WINDOWHEIGHT            = 90;                     // see R6MenuMultiplayerWidget definition
const C_fGM_COLUMNSWIDTH				= 155;				      // 248 is size of the window 620 * 1/4 4 colums
const C_fXPOS_LASTPOS					= 419;

// COMMON


// GAME MODE TAB
var R6WindowTextLabelExt                m_pGameModeText;

var R6WindowButtonBox                   m_pGameTypeDeadMatch;
var R6WindowButtonBox                   m_pGameTypeTDeadMatch;
var R6WindowButtonBox                   m_pGameTypeDisarmBomb;
var R6WindowButtonBox                   m_pGameTypeHostageAdv;
var R6WindowButtonBox                   m_pGameTypeEscort;
var R6WindowButtonBox                   m_pGameTypeMission;
var R6WindowButtonBox                   m_pGameTypeTerroHunt;
var R6WindowButtonBox                   m_pGameTypeHostageCoop;

// FILTER TAB
var R6WindowTextLabelExt                m_pFilterText;

var R6WindowButtonBox                   m_pFilterUnlock;
var R6WindowButtonBox                   m_pFilterFavorites;
var R6WindowButtonBox                   m_pFilterDedicated;
//#ifdefR6PUNKBUSTER
var R6WindowButtonBox                   m_pFilterPunkBuster;
//#endif
var R6WindowButtonBox                   m_pFilterNotEmpty;
var R6WindowButtonBox                   m_pFilterNotFull;
var R6WindowButtonBox                   m_pFilterResponding;
var R6WindowButtonBox                   m_pFilterSameVersion;
var R6WindowComboControl                m_pFilterFasterThan;

// SERVER INFO TAB
var R6WindowTextLabelExt                m_pServerInfo;        


//*******************************************************************************************
// GAME MODE TAB
//*******************************************************************************************
function UpdateGameTypeFilter()
{
    local R6MenuMultiPlayerWidget menu;
    // We use the same filter for m_LanServers  and for m_GameService
    
    menu = R6MenuMultiPlayerWidget(OwnerWindow);
    if ( m_pGameTypeDeadMatch != none ) // if we have the game type
	{
		m_pGameTypeDeadMatch.m_bSelected = Menu.m_bFilterDeathMatch;
		m_pGameTypeTDeadMatch.m_bSelected = Menu.m_bFilterTeamDeathMatch;
		m_pGameTypeDisarmBomb.m_bSelected = Menu.m_bFilterDisarmBomb;
		m_pGameTypeHostageAdv.m_bSelected = Menu.m_bFilterHostageRescueAdv;
		m_pGameTypeEscort.m_bSelected = Menu.m_bFilterEscortPilot;
		m_pGameTypeMission.m_bSelected = Menu.m_bFilterMission;
		m_pGameTypeTerroHunt.m_bSelected = Menu.m_bFilterTerroristHunt;
		m_pGameTypeHostageCoop.m_bSelected = Menu.m_bFilterHostageRescueCoop;
	}

    if ( m_pFilterResponding != none ) // if filter has been created
	{
		m_pFilterResponding.m_bSelected = Menu.m_bFilterResponding;
		m_pFilterUnlock.m_bSelected = Menu.m_bFilterUnlockedOnly;
		m_pFilterFavorites.m_bSelected = Menu.m_bFilterFavoritesOnly;
		m_pFilterDedicated.m_bSelected = Menu.m_bFilterDedicatedServersOnly;
		m_pFilterPunkBuster.m_bSelected = Menu.m_bFilterPunkBusterServerOnly;
		m_pFilterNotEmpty.m_bSelected = Menu.m_bFilterServersNotEmpty;
		m_pFilterNotFull.m_bSelected = Menu.m_bFilterServersNotFull;
		m_pFilterSameVersion.m_bSelected = Menu.m_bFilterSameVersion;
	}
//#ifdefR6PUNKBUSTER
//#endif
}

function InitGameModeTab()
{
    local FLOAT fXOffset, fYOffset, fYStep, fWidth, fHeight;
    local Font ButtonFont;

    // it's a text label ext because you want to draw the line in the middle (small hack)
    m_pGameModeText = R6WindowTextLabelExt( CreateWindow(class'R6WindowTextLabelExt', 0, 0, 2*K_HALFWINDOWWIDTH, K_FSECOND_WINDOWHEIGHT, self));
    m_pGameModeText.bAlwaysBehind = true;
    // draw middle line
    m_pGameModeText.ActiveBorder( 0, false);                                         // Top border
    m_pGameModeText.ActiveBorder( 1, false);                                         // Bottom border
    m_pGameModeText.SetBorderParam( 2, C_fGM_COLUMNSWIDTH * 2, 1, 1, Root.Colors.White);         // Left border

    // text part
    m_pGameModeText.m_Font = Root.Fonts[F_SmallTitle]; 
    m_pGameModeText.m_vTextColor = Root.Colors.BlueLight;
    m_pGameModeText.AddTextLabel( Caps(Localize("MultiPlayer","GameMode_Adversarial","R6Menu")), 5, 3, C_fGM_COLUMNSWIDTH * 2, TA_Left, false);
    m_pGameModeText.AddTextLabel( Caps(Localize("MultiPlayer","GameMode_Cooperative","R6Menu")), 5 + (C_fGM_COLUMNSWIDTH * 2), 3, C_fGM_COLUMNSWIDTH * 2, TA_Left, false);

    //create buttons
    fXOffset = 5;
    fYOffset = 20;
    fYStep = 25;
    fWidth = C_fGM_COLUMNSWIDTH; //***** old value = (K_HALFWINDOWWIDTH * 0.5) - fXOffset;
    fHeight = 14;
    ButtonFont = Root.Fonts[F_CheckBoxButton]; 

    // DEADMATCH
    m_pGameTypeDeadMatch = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeDeadMatch.m_TextFont = ButtonFont;
    m_pGameTypeDeadMatch.m_vTextColor = Root.Colors.White;
    m_pGameTypeDeadMatch.m_vBorder = Root.Colors.White;
    m_pGameTypeDeadMatch.CreateTextAndBox( Localize("MultiPlayer","GameType_Death","R6Menu"), 
                                           Localize("Tip","SrvGameType_Death","R6Menu"), 0,
                                           R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_DeathMatch);

    fYOffset += fYStep;
    // TEAM DEADMATCH
    m_pGameTypeTDeadMatch = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeTDeadMatch.m_TextFont = ButtonFont;
    m_pGameTypeTDeadMatch.m_vTextColor = Root.Colors.White;
    m_pGameTypeTDeadMatch.m_vBorder = Root.Colors.White;
    m_pGameTypeTDeadMatch.CreateTextAndBox( Localize("MultiPlayer","GameType_TeamDeath","R6Menu"), 
                                            Localize("Tip","SrvGameType_TeamDeath","R6Menu"), 0, 
                                            R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_TeamDeathMatch);

    fYOffset += fYStep;
	// BOMB
    m_pGameTypeDisarmBomb = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeDisarmBomb.m_TextFont = ButtonFont;
    m_pGameTypeDisarmBomb.m_vTextColor = Root.Colors.White;
    m_pGameTypeDisarmBomb.m_vBorder = Root.Colors.White;

    m_pGameTypeDisarmBomb.CreateTextAndBox( Localize("MultiPlayer","GameType_DisarmBomb","R6Menu"), 
                                      Localize("Tip","SrvGameType_DisarmBomb","R6Menu"), 0, 
                                      R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_Bomb);	

    fXOffset = 10 + C_fGM_COLUMNSWIDTH;//(K_HALFWINDOWWIDTH * 0.5);
    fYOffset = 20;
    fWidth -= 20; //substract small value to distance the check box from middle line
    // HOSTAGE RESCUE
    m_pGameTypeHostageAdv = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeHostageAdv.m_TextFont = ButtonFont;
    m_pGameTypeHostageAdv.m_vTextColor = Root.Colors.White;
    m_pGameTypeHostageAdv.m_vBorder = Root.Colors.White;
    m_pGameTypeHostageAdv.CreateTextAndBox( Localize("MultiPlayer","GameType_HostageAdv","R6Menu"), 
                                      Localize("Tip","SrvGameType_HostageAdv","R6Menu"), 0, 
                                      R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_HostageAdv);

    fYOffset += fYStep;
    // ESCORT THE PILOT
    m_pGameTypeEscort = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeEscort.m_TextFont = ButtonFont;
    m_pGameTypeEscort.m_vTextColor = Root.Colors.White;
    m_pGameTypeEscort.m_vBorder = Root.Colors.White;
    m_pGameTypeEscort.CreateTextAndBox( Localize("MultiPlayer","GameType_EscortGeneral","R6Menu"), 
                                        Localize("Tip","SrvGameType_EscortGeneral","R6Menu"), 0, 
                                        R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_Escort);

	//  Cooperative modes

    fXOffset = 5 + (C_fGM_COLUMNSWIDTH * 2); /* MissionPack1 (was *2) */
    fYOffset = 20;
    // MISSION
    m_pGameTypeMission = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeMission.m_TextFont = ButtonFont;
    m_pGameTypeMission.m_vTextColor = Root.Colors.White;
    m_pGameTypeMission.m_vBorder = Root.Colors.White;
    m_pGameTypeMission.CreateTextAndBox( Localize("MultiPlayer","GameType_Mission","R6Menu"), 
                                         Localize("Tip","SrvGameType_Mission","R6Menu"), 0, 
                                         R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_Mission);

    fYOffset += fYStep;
    // TERRORIST HUNT
    m_pGameTypeTerroHunt = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeTerroHunt.m_TextFont = ButtonFont;
    m_pGameTypeTerroHunt.m_vTextColor = Root.Colors.White;
    m_pGameTypeTerroHunt.m_vBorder = Root.Colors.White;
    m_pGameTypeTerroHunt.CreateTextAndBox( Localize("MultiPlayer","GameType_Terrorist","R6Menu"), 
                                           Localize("Tip","SrvGameType_Terrorist","R6Menu"), 0, 
                                           R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_Terrorist);

    fXOffset = 5 + (C_fGM_COLUMNSWIDTH * 3);
    fYOffset = 20;

    // HOSTAGE RESCUE
    m_pGameTypeHostageCoop = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pGameTypeHostageCoop.m_TextFont = ButtonFont;
    m_pGameTypeHostageCoop.m_vTextColor = Root.Colors.White;
    m_pGameTypeHostageCoop.m_vBorder = Root.Colors.White;
    m_pGameTypeHostageCoop.CreateTextAndBox( Localize("MultiPlayer","GameType_HostageCoop","R6Menu"), 
                                         Localize("Tip","SrvGameType_HostageCoop","R6Menu"), 0, 
                                         R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_HostageCoop);

    UpdateGameTypeFilter();

#ifdefMPDEMO
    m_pGameTypeDisarmBomb.bDisabled = true; 
    m_pGameTypeHostageAdv.bDisabled = true;     
    m_pGameTypeMission.bDisabled = true; 
    m_pGameTypeTerroHunt.bDisabled = true;
	m_pGameTypeHostageCoop.bDisabled = true;
#endif;
}

//*******************************************************************************************
// FILTER TAB
//*******************************************************************************************
function InitFilterTab()
{
    local float fXOffset, fYOffset, fYStep, fWidth, fHeight;

    local Font ButtonFont;

    m_pFilterText = R6WindowTextLabelExt(CreateWindow(Class'R6Window.R6WindowTextLabelExt', 0.0, 0.0, 2.0 * float(310), 90.0, self));
    m_pFilterText.bAlwaysBehind = true;
    m_pFilterText.ActiveBorder(0, false);
    m_pFilterText.ActiveBorder(1, false);
    m_pFilterText.SetBorderParam(2, 310.0, 1.0, 1.0, Root.Colors.GrayLight);
    m_pFilterText.ActiveBorder(3, false);
    fXOffset = 5.0;
    fYOffset = 7.0;
    fYStep = 16.0;
    fWidth = (310.0 - fXOffset) - float(30);
    fHeight = 14.0;
    ButtonFont = Root.Fonts[17];
    m_pFilterText.m_Font = ButtonFont;
    m_pFilterText.m_vTextColor = Root.Colors.White;
    m_pFilterFavorites = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pFilterFavorites.m_TextFont = ButtonFont;
    m_pFilterFavorites.m_vTextColor = Root.Colors.White;
    m_pFilterFavorites.m_vBorder = Root.Colors.White;
    m_pFilterFavorites.CreateTextAndBox(Localize("MultiPlayer", "FilterMode_Favorites", "R6Menu"), Localize("Tip", "FilterMode_Favorites", "R6Menu"), 0.0, int(R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_Favorites));
    fYOffset += fYStep;
    m_pFilterUnlock = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pFilterUnlock.m_TextFont = ButtonFont;
    m_pFilterUnlock.m_vTextColor = Root.Colors.White;
    m_pFilterUnlock.m_vBorder = Root.Colors.White;
    m_pFilterUnlock.CreateTextAndBox(Localize("MultiPlayer", "FilterMode_Unlocked", "R6Menu"), Localize("Tip", "FilterMode_Unlocked", "R6Menu"), 0.0, int(R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_Unlocked));
    fYOffset += fYStep;
    m_pFilterDedicated = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pFilterDedicated.m_TextFont = ButtonFont;
    m_pFilterDedicated.m_vTextColor = Root.Colors.White;
    m_pFilterDedicated.m_vBorder = Root.Colors.White;
    m_pFilterDedicated.CreateTextAndBox(Localize("MultiPlayer", "FilterMode_Dedicate", "R6Menu"), Localize("Tip", "FilterMode_Dedicate", "R6Menu"), 0.0, int(R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_Dedicated));
    fYOffset += fYStep;
    m_pFilterPunkBuster = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pFilterPunkBuster.m_TextFont = ButtonFont;
    m_pFilterPunkBuster.m_vTextColor = Root.Colors.White;
    m_pFilterPunkBuster.m_vBorder = Root.Colors.White;
    m_pFilterPunkBuster.CreateTextAndBox(Localize("MultiPlayer", "FilterMode_PunkBuster", "R6Menu"), Localize("Tip", "FilterMode_PunkBuster", "R6Menu"), 0.0, int(R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_PunkBuster));
    fYOffset += fYStep;
    m_pFilterNotEmpty = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pFilterNotEmpty.m_TextFont = ButtonFont;
    m_pFilterNotEmpty.m_vTextColor = Root.Colors.White;
    m_pFilterNotEmpty.m_vBorder = Root.Colors.White;
    m_pFilterNotEmpty.CreateTextAndBox(Localize("MultiPlayer", "FilterMode_NotEmpty", "R6Menu"), Localize("Tip", "FilterMode_NotEmpty", "R6Menu"), 0.0, int(R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_NotEmpty));
    fXOffset = 5.0 + float(310);
    fYOffset = 7.0;
    fYStep = 16.0;
    m_pFilterNotFull = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pFilterNotFull.m_TextFont = ButtonFont;
    m_pFilterNotFull.m_vTextColor = Root.Colors.White;
    m_pFilterNotFull.m_vBorder = Root.Colors.White;
    m_pFilterNotFull.CreateTextAndBox(Localize("MultiPlayer", "FilterMode_NotFull", "R6Menu"), Localize("Tip", "FilterMode_NotFull", "R6Menu"), 0.0, int(R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_NotFull));
    fYOffset += fYStep;
    m_pFilterSameVersion = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pFilterSameVersion.m_TextFont = ButtonFont;
    m_pFilterSameVersion.m_vTextColor = Root.Colors.White;
    m_pFilterSameVersion.m_vBorder = Root.Colors.White;
    m_pFilterSameVersion.CreateTextAndBox(Localize("MultiPlayer", "FilterMode_SameVersion", "R6Menu"), Localize("Tip", "FilterMode_SameVersion", "R6Menu"), 0.0, int(R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_SameVersion));
    fYOffset += fYStep;
    m_pFilterResponding = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pFilterResponding.m_TextFont = ButtonFont;
    m_pFilterResponding.m_vTextColor = Root.Colors.White;
    m_pFilterResponding.m_vBorder = Root.Colors.White;
    m_pFilterResponding.CreateTextAndBox(Localize("MultiPlayer", "FilterMode_Respond", "R6Menu"), Localize("Tip", "FilterMode_Respond", "R6Menu"), 0.0, int(R6MenuMultiPlayerWidget(OwnerWindow).eServerInfoID.eServerInfoID_Responding));
    fYOffset += fYStep;
    m_pFilterText.AddTextLabel(Localize("MultiPlayer", "FilterMode_FasterThan", "R6Menu"), fXOffset, fYOffset + float(2), 150.0, TA_Left, false);
    fXOffset = 310.0 + float(115);
    fWidth = 165.0;
    m_pFilterFasterThan = R6WindowComboControl(CreateControl(Class'R6Window.R6WindowComboControl', fXOffset, fYOffset, fWidth, fHeight));
    m_pFilterFasterThan.SetEditBoxTip(Localize("Tip", "FilterMode_FasterThan", "R6Menu"));
    m_pFilterFasterThan.EditBoxWidth = m_pFilterFasterThan.WinWidth;
    m_pFilterFasterThan.SetFont(6);
    m_pFilterFasterThan.List.MaxVisible = 4;
    m_pFilterFasterThan.AddItem(Caps(Localize("MultiPlayer", "FilterMode_FasterThanNone", "R6Menu")));
    m_pFilterFasterThan.AddItem(Caps(Localize("MultiPlayer", "FilterMode_FasterThan75", "R6Menu")));
    m_pFilterFasterThan.AddItem(Caps(Localize("MultiPlayer", "FilterMode_FasterThan100", "R6Menu")));
    m_pFilterFasterThan.AddItem(Caps(Localize("MultiPlayer", "FilterMode_FasterThan250", "R6Menu")));
    m_pFilterFasterThan.AddItem(Caps(Localize("MultiPlayer", "FilterMode_FasterThan350", "R6Menu")));
    m_pFilterFasterThan.AddItem(Caps(Localize("MultiPlayer", "FilterMode_FasterThan500", "R6Menu")));
    m_pFilterFasterThan.AddItem(Caps(Localize("MultiPlayer", "FilterMode_FasterThan1000", "R6Menu")));
    switch(R6MenuMultiPlayerWidget(OwnerWindow).m_iFilterFasterThan)
    {
        case 75:
            m_pFilterFasterThan.SetValue(Caps(Localize("MultiPlayer", "FilterMode_FasterThan75", "R6Menu")));
            break;
        case 100:
            m_pFilterFasterThan.SetValue(Caps(Localize("MultiPlayer", "FilterMode_FasterThan100", "R6Menu")));
            break;
        case 250:
            m_pFilterFasterThan.SetValue(Caps(Localize("MultiPlayer", "FilterMode_FasterThan250", "R6Menu")));
            break;
        case 350:
            m_pFilterFasterThan.SetValue(Caps(Localize("MultiPlayer", "FilterMode_FasterThan350", "R6Menu")));
            break;
        case 500:
            m_pFilterFasterThan.SetValue(Caps(Localize("MultiPlayer", "FilterMode_FasterThan500", "R6Menu")));
            break;
        case 1000:
            m_pFilterFasterThan.SetValue(Caps(Localize("MultiPlayer", "FilterMode_FasterThan1000", "R6Menu")));
            break;
        default:
            R6MenuMultiPlayerWidget(OwnerWindow).m_iFilterFasterThan = 0;
            m_pFilterFasterThan.SetValue(Caps(Localize("MultiPlayer", "FilterMode_FasterThanNone", "R6Menu")));
    }
}


//*******************************************************************************************
// SERVER INFO TAB
//*******************************************************************************************
function InitServerTab()
{

    local FLOAT fWidth, fPreviousPos;

    fWidth = 91;
    fPreviousPos = 0; // at the beginning of the window

    m_pServerInfo = R6WindowTextLabelExt( CreateWindow(class'R6WindowTextLabelExt', 0, 0, WinWidth, 12, self));
    m_pServerInfo.ActiveBorder( 0, false);                      // Top border
    m_pServerInfo.SetBorderParam( 1, 2, 0, 1, Root.Colors.White);       // Bottom border
    m_pServerInfo.ActiveBorder( 2, false);                      // Left border
    m_pServerInfo.ActiveBorder( 3, false);                      // Rigth border
    m_pServerInfo.m_eCornerType = No_Corners;
    m_pServerInfo.m_Font = Root.Fonts[F_VerySmallTitle];
    m_pServerInfo.m_vTextColor = Root.Colors.BlueLight;
    m_pServerInfo.m_vLineColor = Root.Colors.White;

    m_pServerInfo.AddTextLabel( Localize("MultiPlayer","InfoBar_Name","R6Menu"), fPreviousPos, 0, fWidth, TA_Center, true);
    fPreviousPos += fWidth;
    fWidth = 40;
    m_pServerInfo.AddTextLabel( Localize("MultiPlayer","InfoBar_Kills","R6Menu"), fPreviousPos, 0, fWidth, TA_Center, true);
    fPreviousPos += fWidth;
    fWidth = 50;
    m_pServerInfo.AddTextLabel( Localize("MultiPlayer","InfoBar_Time","R6Menu"), fPreviousPos, 0, fWidth, TA_Center, true);
    fPreviousPos += fWidth;
    fWidth = 50;
    m_pServerInfo.AddTextLabel( Localize("MultiPlayer","InfoBar_Ping","R6Menu"), fPreviousPos, 0, fWidth, TA_Center, true);
    fPreviousPos += fWidth;
//    fWidth = 53;
//    m_pServerInfo.AddTextLabel( Localize("MultiPlayer","InfoBar_Rank","R6Menu"), fPreviousPos, 0, fWidth, TA_Center, true);
//    fPreviousPos += fWidth;
    fWidth = 82;
    m_pServerInfo.AddTextLabel( Localize("MultiPlayer","InfoBar_MapList","R6Menu"), fPreviousPos, 0, fWidth, TA_Center, true);
    fPreviousPos += fWidth;
    fWidth = 92;
    m_pServerInfo.AddTextLabel( Localize("MultiPlayer","InfoBar_Type","R6Menu"), fPreviousPos, 0, fWidth, TA_Center, true);
    fPreviousPos += fWidth;
    fWidth = 150;
    m_pServerInfo.AddTextLabel( Localize("MultiPlayer","InfoBar_ServerOptions","R6Menu"), fPreviousPos, 0, fWidth, TA_Center, true);
}





//-------------------------------------------------------------------------
// Notify - Called when buttons are selected, options changed, etc.
//-------------------------------------------------------------------------

function Notify(UWindowDialogControl C, byte E)
{
    // Based on the class type, call the appopriate Notify Function

    if ( C.IsA('R6WindowComboControl') )
        ManageR6ComboControlNotify( C, E );

    else if ( C.IsA('R6WindowButtonBox') )
        ManageR6ButtonBoxNotify( C, E );
}

//-------------------------------------------------------------------------
// ManageR6ComboControlNotify - Notify function for classes of
// type 'R6WindowComboControl'
//-------------------------------------------------------------------------
function ManageR6ComboControlNotify(UWindowDialogControl C, byte E)
{
    // Update the "Faster Than" filter with new input.
    if ( E == DE_Change )
    {
        R6MenuMultiPlayerWidget(OwnerWindow).SetServerFilterFasterThan( INT( R6WindowComboControl(C).GetValue() ) );
    }
}


//-------------------------------------------------------------------------
// ManageR6ButtonBoxNotify - Notify function for classes of
// type 'R6WindowButtonBox'
//-------------------------------------------------------------------------
function ManageR6ButtonBoxNotify(UWindowDialogControl C, byte E)
{
    // Change the Active/Not Active status of the filter
	if(E == DE_Click)
	{
        if (R6WindowButtonBox(C).GetSelectStatus())
        {
            R6WindowButtonBox(C).m_bSelected = !R6WindowButtonBox(C).m_bSelected;
            if (R6MenuMultiPlayerWidget(OwnerWindow) != None)
            {
                R6MenuMultiPlayerWidget(OwnerWindow).SetServerFilterBooleans(  R6WindowButtonBox(C).m_iButtonID, R6WindowButtonBox(C).m_bSelected );
            }
        }
    }
}

defaultproperties
{
}
