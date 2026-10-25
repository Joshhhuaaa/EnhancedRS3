class R6MenuOptionsGame extends R6MenuOptionsTab;

var INT									m_iRefMouseSens;

// OPTION GAME
//var R6WindowButtonBox                   m_pOptionUnlimitedP;
var R6WindowButtonBox                   m_pOptionAlwaysRun;

var R6WindowButtonBox                   m_pOptionInvertMouse;

#ifndefMPDEMO
var R6WindowButtonBox                   m_pPopUpLoadPlan;

var R6WindowButtonBox                   m_pPopUpQuickPlay;

var R6WindowTextureBrowser              m_pAutoAim;

#endif
var Texture                             m_pAutoAimTexture;

var R6WindowHScrollBar					m_pOptionMouseSens;

var Region                              m_pAutoAimTextReg[4];

function InitPageOptions()
{
    local float fXOffset, fYOffset, fYStep, fWidth, fHeight, fTemp,
	    fSizeOfCounter, fXRightOffset;

    local Font ButtonFont;
    local int iAutoAimBitmapHeight, iAutoAimVPadding, iSBButtonWidth;

    ButtonFont = Root.Fonts[5];
    fXOffset = 5.0;
    fXRightOffset = 26.0;
    fYOffset = 5.0;
    fWidth = (WinWidth - fXOffset) - float(40);
    fHeight = 15.0;
    fYStep = 27.0;
    iSBButtonWidth = 14;
    iAutoAimBitmapHeight = 73;
    iAutoAimVPadding = 5;
    m_pOptionAlwaysRun = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pOptionAlwaysRun.SetButtonBox(false);
    m_pOptionAlwaysRun.CreateTextAndBox(Localize("Options", "Opt_GameAlways", "R6Menu"), Localize("Tip", "Opt_GameAlways", "R6Menu"), 0.0, 2);
    fYOffset += fYStep;
    m_pOptionInvertMouse = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pOptionInvertMouse.SetButtonBox(false);
    m_pOptionInvertMouse.CreateTextAndBox(Localize("Options", "Opt_GameInvertM", "R6Menu"), Localize("Tip", "Opt_GameInvertM", "R6Menu"), 0.0, 3);
    fYOffset += fYStep;
    m_pOptionMouseSens = R6WindowHScrollbar(CreateControl(Class'R6Window.R6WindowHScrollbar', fXOffset, fYOffset, (WinWidth - fXOffset) - fXRightOffset, 14.0, self));
    m_pOptionMouseSens.CreateSB(0, 250.0, 0.0, 140.0, 14.0, self);
    m_pOptionMouseSens.CreateSBTextLabel(Localize("Options", "Opt_GameMouseSens", "R6Menu"), Localize("Tip", "Opt_GameMouseSens", "R6Menu"));
    m_pOptionMouseSens.SetScrollBarRange(0.0, 120.0, 20.0);
    fYOffset += fYStep;
    m_pPopUpLoadPlan = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pPopUpLoadPlan.SetButtonBox(false);
    m_pPopUpLoadPlan.CreateTextAndBox(Localize("Options", "Opt_GamePopUpLoadPlan", "R6Menu"), Localize("Tip", "Opt_GamePopUpLoadPlan", "R6Menu"), 0.0, 5);
    fYOffset += fYStep;
    m_pPopUpQuickPlay = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pPopUpQuickPlay.SetButtonBox(false);
    m_pPopUpQuickPlay.CreateTextAndBox(Localize("Options", "Opt_GamePopUpQuickPlay", "R6Menu"), Localize("Tip", "Opt_GamePopUpQuickPlay", "R6Menu"), 0.0, 5);
    fYOffset += fYStep;
    m_pAutoAim = R6WindowTextureBrowser(CreateWindow(Class'R6Window.R6WindowTextureBrowser', fXOffset, fYOffset, WinWidth - fXOffset, (14.0 + float(iAutoAimBitmapHeight)) + float(iAutoAimVPadding), self));
    m_pAutoAim.CreateSB(250, int(m_pAutoAim.WinHeight - float(14)), 140, 14);
    m_pAutoAim.CreateBitmap(250 + iSBButtonWidth, 0, 140 - (2 * iSBButtonWidth), iAutoAimBitmapHeight);
    m_pAutoAim.SetBitmapProperties(false, true, 5, false);
    m_pAutoAim.SetBitmapBorder(true, Root.Colors.White);
    m_pAutoAim.CreateTextLabel(0, 0, int(m_pAutoAim.WinWidth - m_pAutoAim.m_CurrentSelection.WinLeft), int(m_pAutoAim.WinHeight), Localize("Options", "Opt_AutoTarget", "R6Menu"), Localize("Tip", "Opt_AutoTarget", "R6Menu"));
    m_pAutoAim.AddTexture(m_pAutoAimTexture, m_pAutoAimTextReg[0]);
    m_pAutoAim.AddTexture(m_pAutoAimTexture, m_pAutoAimTextReg[1]);
    m_pAutoAim.AddTexture(m_pAutoAimTexture, m_pAutoAimTextReg[2]);
    m_pAutoAim.AddTexture(m_pAutoAimTexture, m_pAutoAimTextReg[3]);
    InitResetButton();
    UpdateOptionsInPage();
    m_bInitComplete = true;
}

function UpdateOptionsInEngine()
{
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    pGameOptions.AlwaysRun = m_pOptionAlwaysRun.m_bSelected;
    pGameOptions.InvertMouse = m_pOptionInvertMouse.m_bSelected;
    pGameOptions.PopUpLoadPlan = m_pPopUpLoadPlan.m_bSelected;
    pGameOptions.PopUpQuickPlay = m_pPopUpQuickPlay.m_bSelected;
    pGameOptions.AutoTargetSlider = m_pAutoAim.GetCurrentTextureIndex();
    pGameOptions.MouseSensitivity = m_pOptionMouseSens.GetScrollBarValue();
}

function UpdateOptionsInPage()
{
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    m_pOptionAlwaysRun.SetButtonBox(pGameOptions.AlwaysRun);
    m_pOptionInvertMouse.SetButtonBox(pGameOptions.InvertMouse);
    m_pPopUpLoadPlan.SetButtonBox(pGameOptions.PopUpLoadPlan);
    m_pPopUpQuickPlay.SetButtonBox(pGameOptions.PopUpQuickPlay);
    m_pAutoAim.SetCurrentTextureFromIndex(pGameOptions.AutoTargetSlider);
    m_pOptionMouseSens.SetScrollBarValue(pGameOptions.MouseSensitivity);
}

function RestoreDefaultValue()
{
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    pGameOptions.ResetGameToDefault();
    UpdateOptionsInPage();
}

function Notify(UWindowDialogControl C, byte E)
{
    local R6MenuOptionsWidget OptionsWidget;
    local bool bUpdateGameOptions;
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    OptionsWidget = R6MenuOptionsWidget(OwnerWindow);
    if(E == DE_Click)
    {
        if(C.IsA('R6WindowButtonBox'))
        {
            if(R6WindowButtonBox(C).GetSelectStatus())
            {
                R6WindowButtonBox(C).m_bSelected = !R6WindowButtonBox(C).m_bSelected;
                bUpdateGameOptions = true;
            }            
        }
        else
        {
            if(C.IsA('R6WindowButton'))
            {
                if(C == m_pGeneralButUse)
                {
                    Root.SimplePopUp(Localize("Options", "ResetToDefault", "R6Menu"), Localize("Options", "ResetToDefaultConfirm", "R6Menu"), EPopUpID_OptionsResetDefault, 0, false, self);
                }
            }
        }        
    }
    else
    {
        if(C.IsA('UWindowHScrollbar'))
        {
            if(E == DE_MouseLeave)
            {
                if(float(m_iRefMouseSens) != m_pOptionMouseSens.GetScrollBarValue())
                {
                    m_iRefMouseSens = int(m_pOptionMouseSens.GetScrollBarValue());
                    bUpdateGameOptions = true;
                }                
            }
            else
            {
                if((E == DE_Change) && m_bInitComplete)
                {
                    pGameOptions.MouseSensitivity = m_pOptionMouseSens.GetScrollBarValue();
                }
            }            
        }
        else
        {
            if(C.IsA('R6WindowComboControl'))
            {
                if(E == DE_Change)
                {
                    if(m_bInitComplete && R6WindowComboControl(C).m_bSelectedByUser)
                    {
                        bUpdateGameOptions = true;
                    }
                }
            }
        }
    }
    if(bUpdateGameOptions)
    {
        UpdateOptionsInEngine();
        pGameOptions.SaveConfig();
    }
}

defaultproperties
{
    m_pAutoAimTexture=Texture'R6MenuTextures.Gui_BoxScroll'
    m_pAutoAimTextReg(0)=(Y=104,W=111,H=73)
    m_pAutoAimTextReg(1)=(Y=177,W=111,H=73)
    m_pAutoAimTextReg(2)=(Y=250,W=111,H=73)
    m_pAutoAimTextReg(3)=(Y=323,W=111,H=73)
}
