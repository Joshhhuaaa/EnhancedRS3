//=============================================================================
//  R6MenuSinglePlayerCampaignCreate.uc : Small group of control to create a
//											campaign		
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/12/17 * Created by Alexandre Dionne
//=============================================================================


class R6MenuSinglePlayerCampaignCreate extends UWindowDialogClientWindow;

var R6WindowTextLabel				m_CampaignName, m_Difficulty; 
var R6WindowTextLabel				m_Difficulty1, m_Difficulty2, m_Difficulty3;

var R6MenuDiffCustomMissionSelect	m_pDiffSelection;

var R6WindowEditControl				m_CampaignNameEdit;
var bool							bShowlog;


function Created()
{
	local color LabelTextColor;

    LabelTextColor = Root.Colors.White; 
	
	m_CampaignName = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 5, 0, WinWidth-5, 25, self));
	m_CampaignName.Text = Localize("SinglePlayer","CampaignName","R6Menu");
	m_CampaignName.Align = TA_LEFT;
	m_CampaignName.m_Font = Root.Fonts[F_SmallTitle];
	m_CampaignName.TextColor = LabelTextColor;
	m_CampaignName.m_BGTexture         = None;
    m_CampaignName.m_bDrawBorders      =False;

   
	m_CampaignNameEdit = R6WindowEditControl(CreateControl(class'R6WindowEditControl', 3, 24,WinWidth-6, 15,self));    
    m_CampaignNameEdit.SetValue( Localize("SinglePlayer","DefaultCampaignName","R6Menu"));    
    m_CampaignNameEdit.EditBox.Font = F_SmallTitle;
    m_CampaignNameEdit.ForceCaps(true);
	m_CampaignNameEdit.SetEditBoxTip( Localize("Tip","CampaignDefaultName","R6Menu"));
    m_CampaignNameEdit.EditBox.SelectAll();
    m_CampaignNameEdit.SetMaxLength(30);


	m_Difficulty = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 0, 59, WinWidth, 30, self));
	m_Difficulty.Text = Localize("SinglePlayer","Difficulty","R6Menu");
	m_Difficulty.Align = TA_CENTER;
	m_Difficulty.m_Font = Root.Fonts[F_PopUpTitle]; 
	m_Difficulty.TextColor = LabelTextColor;
    m_Difficulty.m_bDrawBorders = false;

	m_pDiffSelection = R6MenuDiffCustomMissionSelect(
                                                CreateWindow(class'R6MenuDiffCustomMissionSelect',
                                                0, 
                                                m_Difficulty.WinTop + m_Difficulty.WinHeight,
                                                WinWidth,
                                                WinHeight - (m_Difficulty.WinTop + m_Difficulty.WinHeight),
                                                self)
                                                );   
    m_pDiffSelection.m_pButLevel1.WinTop = m_pDiffSelection.m_pButLevel1.WinTop +1;    
    m_pDiffSelection.m_pButLevel2.WinTop = m_pDiffSelection.m_pButLevel2.WinTop +12;    
    m_pDiffSelection.m_pButLevel3.WinTop = m_pDiffSelection.m_pButLevel3.WinTop +23;    

    bAlwaysAcceptsFocus = true;
    
}

function KeyDown(int Key, float X, float Y)
{    
    Super.KeyDown(Key, X, Y);

    if(Key == Root.Console.EInputKey.IK_Enter && m_CampaignNameEdit.GetValue()!= "")
        R6MenuSinglePlayerWidget(OwnerWindow).ButtonClicked(R6MenuSinglePlayerWidget(OwnerWindow).ECampaignButID.ButtonAccept);
}

function Notify(UWindowDialogControl C, BYTE E)
{
    if(C == m_CampaignNameEdit && E == DE_EnterPressed && m_CampaignNameEdit.GetValue()!= "")
        R6MenuSinglePlayerWidget(OwnerWindow).ButtonClicked(R6MenuSinglePlayerWidget(OwnerWindow).ECampaignButID.ButtonAccept);
}

function Reset()
{    
    m_CampaignNameEdit.SetValue( Localize("SinglePlayer","DefaultCampaignName","R6Menu"));
    m_CampaignNameEdit.EditBox.SelectAll();
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{       
    //**Draw Bg and borders for the Center Text Label

    C.Style = ERenderStyle.STY_Modulated;    
    DrawStretchedTextureSegment( C, m_Difficulty.WinLeft, m_Difficulty.Wintop, m_Difficulty.WinWidth, m_Difficulty.WinHeight,
                                77,0,4,29,
                                Texture'R6MenuTextures.Gui_BoxScroll');
    
    C.Style = ERenderStyle.STY_Alpha;    
	C.SetDrawColor( m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);   

    DrawStretchedTexture( C, 0, m_Difficulty.Wintop, WinWidth, 1, Texture'UWindow.WhiteTexture');
    DrawStretchedTexture( C, 0, m_Difficulty.Wintop + m_Difficulty.WinHeight, WinWidth, 1, Texture'UWindow.WhiteTexture');
}

function bool CreateCampaign()
{
    local R6MenuRootWindow r6Root;
    local int iNbArrayElements, iNbTotalOperatives, i;
    local R6Operative tmpOperative;
    local Class<R6Operative> tmpOperativeClass;
    local R6PlayerCampaign PlayerCampaign;
    local R6ModMgr pModManager;

    pModManager = class'Actor'.static.GetModMgr();
    r6Root = R6MenuRootWindow(Root);
    iNbArrayElements = 0;
    if(((m_CampaignNameEdit.GetValue() != "") && r6Root != none) && R6MenuSinglePlayerWidget(OwnerWindow).m_pFileManager != none)
    {
        PlayerCampaign = R6Console(r6Root.Console).m_PlayerCampaign;
        PlayerCampaign.m_FileName = m_CampaignNameEdit.GetValue();
        ReplaceText(PlayerCampaign.m_FileName, " ", "_");
        PlayerCampaign.m_iDifficultyLevel = m_pDiffSelection.GetDifficulty();
        PlayerCampaign.m_CampaignFileName = class'Actor'.static.GetModMgr().m_pCurrentMod.m_szCampaignIniFile;
        PlayerCampaign.m_iNoMission = 0;
        PlayerCampaign.m_OperativesMissionDetails = none;
        PlayerCampaign.m_OperativesMissionDetails = new (none) Class'R6Game.R6MissionRoster';
        iNbArrayElements = R6Console(r6Root.Console).m_CurrentCampaign.m_OperativeClassName.Length;

        for(i = 0; i < iNbArrayElements; i++)
        {
            tmpOperative = new (none) Class<R6Operative>(DynamicLoadObject(R6Console(r6Root.Console).m_CurrentCampaign.m_OperativeClassName[i], Class'Core.Class'));
            PlayerCampaign.m_OperativesMissionDetails.m_MissionOperatives[i] = tmpOperative;
            if(bShowLog)
            {
                log(("adding" @ string(tmpOperative)) @ "to default player campaign roster");
            }
        }
        iNbTotalOperatives = i;
        if(pModManager.m_pCurrentMod.m_bUseCustomOperatives == true)
        {

            for(i = 0; i < pModManager.GetPackageMgr().GetNbPackage(); i++)
            {

                for(tmpOperativeClass = Class<R6Operative>(pModManager.GetPackageMgr().GetFirstClassFromPackage(i, Class'R6Game.R6Operative')); tmpOperativeClass != none; tmpOperativeClass = Class<R6Operative>(pModManager.GetPackageMgr().GetNextClassFromPackage()))
                {
                    tmpOperative = new (none) tmpOperativeClass;
                    if(tmpOperative != none)
                    {
                        PlayerCampaign.m_OperativesMissionDetails.m_MissionOperatives[iNbTotalOperatives] = tmpOperative;
                        iNbTotalOperatives++;
                    }
                }
            }
        }
        if(R6MenuSinglePlayerWidget(OwnerWindow).m_pFileManager.SaveCampaign(PlayerCampaign) == false)
        {
            r6Root.SimplePopUp(Localize("POPUP", "FILEERROR", "R6Menu"), (PlayerCampaign.m_FileName @ ":") @ (Localize("POPUP", "FILEERRORPROBLEM", "R6Menu")), EPopUpID_FileWriteError, 1);
            return false;            
        }
        else
        {
            return true;
        }
    }
    return false;
}

defaultproperties
{
}
