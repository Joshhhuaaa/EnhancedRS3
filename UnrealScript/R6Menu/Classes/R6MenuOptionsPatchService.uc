class R6MenuOptionsPatchService extends R6MenuOptionsTab;

var float m_lastUpdateServiceClick;

// OPTION PATCH SERVICE
var R6WindowButtonBox					m_pOptionAutoPatchDownload;

var R6WindowButton						m_pStartDownloadButton;

var R6WindowWrappedTextArea				m_pPatchStatus;

function InitPageOptions()
{
    local float fXOffset, fYOffset, fYStep, fWidth, fHeight;

    local bool bUpdateAllowed;

    bUpdateAllowed = class'eviLPatchService'.static.CanRunUpdateService();
    m_lastUpdateServiceClick = 0.0;
    fXOffset = 5.0;
    fYOffset = 5.0;
    fWidth = (WinWidth - fXOffset) - float(40);
    fHeight = 15.0;
    fYStep = 27.0;
    m_pOptionAutoPatchDownload = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pOptionAutoPatchDownload.SetButtonBox(false);
    m_pOptionAutoPatchDownload.CreateTextAndBox(Localize("Options", "Opt_PatchServiceAutoDownload", "R6Menu"), Localize("Tip", "Opt_PatchServiceAutoDownload", "R6Menu"), 0.0, 2, false, true);
    m_pOptionAutoPatchDownload.bDisabled = !bUpdateAllowed;
    fYOffset += fYStep;
    m_pStartDownloadButton = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pStartDownloadButton.Text = Localize("Options", "ButtonStartPatchDownload", "R6Menu");
    m_pStartDownloadButton.ToolTipString = Localize("Tip", "ButtonStartPatchDownload", "R6Menu");
    m_pStartDownloadButton.Align = TA_Left;
    m_pStartDownloadButton.m_iButtonID = 0;
    m_pStartDownloadButton.bDisabled = !bUpdateAllowed;
    fYOffset += fYStep;
    m_pPatchStatus = R6WindowWrappedTextArea(CreateWindow(Class'R6Window.R6WindowWrappedTextArea', fXOffset, fYOffset, fWidth, 248.0, self));
    m_pPatchStatus.SetScrollable(false);
    m_pPatchStatus.m_fXOffSet = 2.0;
    m_pPatchStatus.m_fYOffSet = 0.0;
    m_pPatchStatus.m_bDrawBorders = false;
    m_pPatchStatus.AddText(Localize("Options", "PatchStatus_Unknown", "R6Menu"), Root.Colors.BlueLight, Root.Fonts[6]);
    if(bUpdateAllowed)
    {
        InitResetButton();
        UpdateOptionsInPage();
    }
    m_bInitComplete = true;
}

function UpdateOptionsInEngine()
{
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    pGameOptions.AutoPatchDownload = m_pOptionAutoPatchDownload.m_bSelected;
}

function UpdateOptionsInPage()
{
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    m_pOptionAutoPatchDownload.SetButtonBox(pGameOptions.AutoPatchDownload);
}

function GetDownloadMetric(FLOAT totalBytes, out string metric, out FLOAT divider)
{
	if(totalBytes > 10 * 1024*1024){
		metric = Localize("Options","PatchStatus_MegaBytes", "R6Menu");
		divider = 1024*1024;
	}else if(totalBytes > 10 * 1024){
		metric = Localize("Options","PatchStatus_KiloBytes", "R6Menu");
		divider = 1024;
	}else{
		metric = Localize("Options","PatchStatus_Bytes", "R6Menu");
		divider = 1;
	}
}

function GetDownloadPercentageStringValues(FLOAT totalBytes, FLOAT recvdBytes, out string bytesProgress, out string percentProgress)
{
	local string strTotal;
	local string strRecvd;
	local string metric;
	local FLOAT  divider;

	GetDownloadMetric(totalBytes, metric, divider);
	
	strTotal = string(totalBytes / divider);
	strTotal = Left(strTotal, InStr(strTotal, "."));

	strRecvd = string(recvdBytes / divider);
	strRecvd = Left(strRecvd, InStr(strRecvd, "."));
	
 	percentProgress = string(100.0 * recvdBytes / totalBytes);
    percentProgress = Left(percentProgress, InStr(percentProgress, ".")) $ "%";

	bytesProgress = strRecvd $ "/" $ strTotal $ metric;
}

function GetDownloadString(FLOAT totalBytes, FLOAT recvdBytes, out string str)
{
	local string bytesProgress;
	local string percentProgress;

	if(totalBytes > 0 && recvdBytes > 0){
		GetDownloadPercentageStringValues(totalBytes, recvdBytes, bytesProgress, percentProgress);

		str = bytesProgress $ " (" $ percentProgress $ ")";
	}
}

function UpdatePatchStatus()
{
    local R6AbstractEviLPatchService.PatchState PatchState;
    local eviLPatchService.ExitCause ExitCause;
    local float totalBytes, fCurrentFileBytes, recvdBytes, fCurrentFileRecvdBytes;
    local string Progress, NewText;

    PatchState = class'eviLPatchService'.static.GetState();
    switch(PatchState)
    {
        case PS_Initializing:
            SetUpdateStatusOn(false);
            NewText = Localize("Options", "PatchStatus_Initializing", "R6Menu");
            break;
        case PS_DownloadVersionFile:
            SetUpdateStatusOn(false);
            class'eviLPatchService'.static.GetDownloadProgress(totalBytes, recvdBytes, fCurrentFileBytes, fCurrentFileRecvdBytes);
            GetDownloadString(totalBytes, recvdBytes, Progress);
            NewText = (Localize("Options", "PatchStatus_DownloadVersionFile", "R6Menu")) $ Progress;
            break;
        case PS_SelectPatch:
            SetUpdateStatusOn(false);
            NewText = Localize("Options", "PatchStatus_SelectPatch", "R6Menu");
            break;
        case PS_DownloadPatch:
            SetUpdateStatusOn(false);
            class'eviLPatchService'.static.GetDownloadProgress(totalBytes, recvdBytes, fCurrentFileBytes, fCurrentFileRecvdBytes);
            GetDownloadString(totalBytes, recvdBytes, Progress);
            NewText = (Localize("Options", "PatchStatus_DownloadPatch", "R6Menu")) $ Progress;
            break;
        case PS_Terminate:
            SetUpdateStatusOff(true);
            ExitCause = class'eviLPatchService'.static.GetExitCause();
            switch(ExitCause)
            {
                case EC_PatchStarted:
                    NewText = Localize("Options", "PatchStatus_PatchStarted", "R6Menu");
                    break;
                case EC_NoPatchNeeded:
                    NewText = Localize("Options", "PatchStatus_NoPatchNeeded", "R6Menu");
                    break;
                case EC_FatalDownloadError:
                    NewText = Localize("Options", "PatchStatus_FatalDownloadError", "R6Menu");
                    break;
                case EC_PartialDownloadError:
                    NewText = Localize("Options", "PatchStatus_PartialDownloadError", "R6Menu");
                    break;
                case EC_UserAborted:
                    NewText = Localize("Options", "PatchStatus_UserAborted", "R6Menu");
                    break;
                case EC_Unknown:
                    NewText = Localize("Options", "PatchStatus_ExitUnknown", "R6Menu");
                    break;
                case EC_UserQuit:
                    NewText = Localize("Options", "PatchStatus_UserQuit", "R6Menu");
                    break;
                default:
                    NewText = Localize("Options", "PatchStatus_ExitError", "R6Menu");
                    break;
            }
            break;
        case PS_RunPatch:
            SetUpdateStatusOn(false);
            NewText = Localize("Options", "PatchStatus_RunPatch", "R6Menu");
            break;
        case PS_Unknown:
            NewText = Localize("Options", "PatchStatus_Unknown", "R6Menu");
            break;
        default:
            NewText = Localize("Options", "PatchStatus_Unknown", "R6Menu");
            break;
    }
    m_pPatchStatus.Clear(true, true);
    m_pPatchStatus.AddText(NewText, Root.Colors.BlueLight, Root.Fonts[6]);
}

function Tick(float DeltaTime)
{
    UpdatePatchStatus();
}

function SetUpdateStatusOn(bool _bPerformPSAction)
{
    if(_bPerformPSAction)
    {
        class'eviLPatchService'.static.StartPatch();
    }
    m_pStartDownloadButton.Text = Localize("Options", "ButtonAbortPatchDownload", "R6Menu");
    m_pStartDownloadButton.ToolTipString = Localize("Tip", "ButtonAbortPatchDownload", "R6Menu");
    m_pStartDownloadButton.m_iButtonID = 1;
    m_pStartDownloadButton.MouseEnter();
}

function SetUpdateStatusOff(bool _bPerformPSAction)
{
    if(_bPerformPSAction)
    {
        class'eviLPatchService'.static.AbortPatchService();
    }
    m_pStartDownloadButton.Text = Localize("Options", "ButtonStartPatchDownload", "R6Menu");
    m_pStartDownloadButton.ToolTipString = Localize("Tip", "ButtonStartPatchDownload", "R6Menu");
    m_pStartDownloadButton.m_iButtonID = 0;
    m_pStartDownloadButton.MouseEnter();
}

function ToggleUpdateStatus(bool _bPerformPSAction)
{
    if(m_pStartDownloadButton.m_iButtonID == 0)
    {
        SetUpdateStatusOn(_bPerformPSAction);        
    }
    else
    {
        if(m_pStartDownloadButton.m_iButtonID == 1)
        {
            SetUpdateStatusOff(_bPerformPSAction);
        }
    }
}

function RestoreDefaultValue()
{
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    pGameOptions.ResetPatchServiceToDefault();
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
            if(C.IsA('R6WindowButtonExt'))
            {
                if(R6WindowButtonExt(C).GetSelectStatus())
                {
                    R6WindowButtonExt(C).ChangeCheckBoxStatus();
                    bUpdateGameOptions = true;
                }                
            }
            else
            {
                if(C.IsA('R6WindowButton'))
                {
                    if(C == m_pGeneralButUse)
                    {
                        if(C == m_pGeneralButUse)
                        {
                            Root.SimplePopUp(Localize("Options", "ResetToDefault", "R6Menu"), Localize("Options", "ResetToDefaultConfirm", "R6Menu"), EPopUpID_OptionsResetDefault, 0, false, self);
                        }                        
                    }
                    else
                    {
                        if(C == m_pStartDownloadButton)
                        {
                            if((GetTime() - m_lastUpdateServiceClick) >= float(2))
                            {
                                ToggleUpdateStatus(true);
                                m_lastUpdateServiceClick = GetTime();
                            }
                        }
                    }
                }
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
    if(bUpdateGameOptions)
    {
        UpdateOptionsInEngine();
        pGameOptions.SaveConfig();
    }
}
