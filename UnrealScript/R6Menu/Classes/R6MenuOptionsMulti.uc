class R6MenuOptionsMulti extends R6MenuOptionsTab;

var BOOL								m_bPBNotInstalled; // if PunkBuster is not installed

//#ifdefR6PUNKBUSTER
var BOOL							  m_bPBWaitForInit;

// OPTION MULTIPLAYER
var R6WindowEditControl                 m_pOptionPlayerName;

var R6WindowComboControl				m_pSpeedConnection;

var R6WindowButtonExt					m_pOptionGender;

var R6MenuArmpatchSelect                m_pArmpatchChooser;

var R6WindowButtonBox                   m_bTriggerLagWanted;

//#ifdefR6PUNKBUSTER
var R6WindowButtonBox					m_pPunkBusterOpt;

var Region                              m_RArmpatchBitmapPos;

var Region                              m_RArmpatchListPos;

var string								m_pConnectionSpeed[5];

function Created()
{
    super.Created();
    m_pConnectionSpeed[0] = Localize("Options", "Opt_NetSpeedT1", "R6Menu");
    m_pConnectionSpeed[1] = Localize("Options", "Opt_NetSpeedT3", "R6Menu");
    m_pConnectionSpeed[2] = Localize("Options", "Opt_NetSpeedCable", "R6Menu");
    m_pConnectionSpeed[3] = Localize("Options", "Opt_NetSpeedADSL", "R6Menu");
    m_pConnectionSpeed[4] = Localize("Options", "Opt_NetSpeedModem", "R6Menu");
}

function InitPageOptions()
{
    local Region rRegionW;
    local float fXOffset, fYOffset, fYStep, fWidth, fHeight, fTemp,
	    fSizeOfCounter;

    local Font ButtonFont;

    ButtonFont = Root.Fonts[5];
    fXOffset = 5.0;
    fYOffset = 5.0;
    fWidth = (WinWidth - fXOffset) - float(20);
    fHeight = 15.0;
    fYStep = 27.0;
    m_pOptionPlayerName = R6WindowEditControl(CreateWindow(Class'R6Window.R6WindowEditControl', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pOptionPlayerName.SetValue("");
    m_pOptionPlayerName.CreateTextLabel(Localize("Options", "Opt_NetPlayerName", "R6Menu"), 0.0, 0.0, fWidth * 0.5, fHeight);
    m_pOptionPlayerName.SetEditBoxTip(Localize("Tip", "Opt_NetPlayerName", "R6Menu"));
    m_pOptionPlayerName.ModifyEditBoxW(250.0, 0.0, 135.0, fHeight);
    m_pOptionPlayerName.EditBox.MaxLength = 15;
    fYOffset += fYStep;
    rRegionW.X = int(fXOffset);
    rRegionW.Y = int(fYOffset);
    rRegionW.W = int(fWidth);
    rRegionW.H = int(fHeight);
    m_pSpeedConnection = SetComboControlButton(rRegionW, Localize("Options", "Opt_NetConnecSpeed", "R6Menu"), Localize("Tip", "Opt_NetConnecSpeed", "R6Menu"));
    m_pSpeedConnection.AddItem(m_pConnectionSpeed[0], "");
    m_pSpeedConnection.AddItem(m_pConnectionSpeed[1], "");
    m_pSpeedConnection.AddItem(m_pConnectionSpeed[2], "");
    m_pSpeedConnection.AddItem(m_pConnectionSpeed[3], "");
    m_pSpeedConnection.AddItem(m_pConnectionSpeed[4], "");
    fYOffset += fYStep;
    fWidth -= float(20);
    m_pOptionGender = R6WindowButtonExt(CreateControl(Class'R6Window.R6WindowButtonExt', fXOffset, fYOffset, WinWidth - fXOffset, fHeight, self));
    m_pOptionGender.CreateTextAndBox(Localize("Options", "Opt_NetGender", "R6Menu"), Localize("Tip", "Opt_NetGender", "R6Menu"), 0.0, 0, 2);
    m_pOptionGender.SetCheckBox(Localize("Options", "Opt_NetGenderMale", "R6Menu"), 250.0, true, 0);
    m_pOptionGender.SetCheckBox(Localize("Options", "Opt_NetGenderFemale", "R6Menu"), 356.0, false, 1);
    fYOffset += fYStep;
    m_pArmpatchChooser = R6MenuArmpatchSelect(CreateWindow(Class'R6Menu.R6MenuArmpatchSelect', fXOffset, fYOffset, WinWidth - fXOffset, float(m_RArmpatchListPos.H), self));
    m_pArmpatchChooser.CreateTextLabel(0, 0, m_RArmpatchListPos.X, int(m_pArmpatchChooser.WinHeight), Localize("Options", "Opt_NetUArmP", "R6Menu"), Localize("Tip", "Opt_NetUArmP", "R6Menu"));
    m_pArmpatchChooser.CreateListBox(m_RArmpatchListPos.X, m_RArmpatchListPos.Y, m_RArmpatchListPos.W, m_RArmpatchListPos.H);
    m_pArmpatchChooser.CreateArmPatchBitmap(m_RArmpatchBitmapPos.X, m_RArmpatchBitmapPos.Y, m_RArmpatchBitmapPos.W, m_RArmpatchBitmapPos.H);
    m_pArmpatchChooser.RefreshListBox();
    m_pArmpatchChooser.SetToolTip(Localize("Tip", "Opt_NetUArmP", "R6Menu"));
    fYOffset = (m_pArmpatchChooser.WinTop + m_pArmpatchChooser.WinHeight) + float(15);
    m_pPunkBusterOpt = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pPunkBusterOpt.SetButtonBox(false);
    m_pPunkBusterOpt.CreateTextAndBox(Localize("Options", "Opt_NetPunkBuster", "R6Menu"), Localize("Tip", "Opt_NetPunkBuster", "R6Menu"), 0.0, 0);
    m_pPunkBusterOpt.m_szToolTipWhenDisable = Localize("Tip", "Opt_NetPunkBuster", "R6Menu");
    fYOffset += fYStep;
    m_bTriggerLagWanted = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_bTriggerLagWanted.SetButtonBox(false);
    m_bTriggerLagWanted.CreateTextAndBox(Localize("Options", "Opt_TriggerLag", "R6Menu"), Localize("Tip", "Opt_TriggerLag", "R6Menu"), 0.0, 2);
    InitResetButton();
    UpdateOptionsInPage();
    m_bInitComplete = true;
}

function UpdateOptionsInEngine()
{
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    if(m_pOptionPlayerName.GetValue() != m_pOptionPlayerName.GetValue2())
    {
        GetPlayerOwner().Name(m_pOptionPlayerName.GetValue());
        m_pOptionPlayerName.SetValue(m_pOptionPlayerName.GetValue(), m_pOptionPlayerName.GetValue());
    }
    pGameOptions.NetSpeed = ConvertToNSEnum(m_pSpeedConnection.GetValue());
    switch(pGameOptions.NetSpeed)
    {
        case eNS_T1:
            Root.Console.ConsoleCommand("NETSPEED 20000");
            break;
        case eNS_T3:
            Root.Console.ConsoleCommand("NETSPEED 20000");
            break;
        case eNS_Cable:
            Root.Console.ConsoleCommand("NETSPEED 4000");
            break;
        case eNS_ADSL:
            Root.Console.ConsoleCommand("NETSPEED 5000");
            break;
        case eNS_Modem:
            Root.Console.ConsoleCommand("NETSPEED 1500");
            break;
        default:
            Root.Console.ConsoleCommand("NETSPEED 5000");
            break;
    }
    pGameOptions.Gender = m_pOptionGender.GetCheckBoxStatus();
    pGameOptions.ArmPatchTexture = m_pArmpatchChooser.GetSelectedArmpatch();
    pGameOptions.ActivePunkBuster = m_pPunkBusterOpt.m_bSelected;
    pGameOptions.WantTriggerLag = !m_bTriggerLagWanted.m_bSelected;
}

function UpdateOptionsInPage()
{
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    if(!m_bInitComplete)
    {
        m_pOptionPlayerName.SetValue(pGameOptions.characterName, pGameOptions.characterName);        
    }
    else
    {
        m_pOptionPlayerName.SetValue(pGameOptions.characterName, m_pOptionPlayerName.GetValue2());
    }
    m_pOptionPlayerName.EditBox.MoveHome();
    m_pSpeedConnection.SetValue(ConvertToNetSpeedString(int(pGameOptions.NetSpeed)));
    m_pOptionGender.SetCheckBoxStatus(pGameOptions.Gender);
    m_pArmpatchChooser.SetDesiredSelectedArmpatch(pGameOptions.ArmPatchTexture);
    if(m_bInitComplete)
    {
        if(pGameOptions.ActivePunkBuster != class'Actor'.static.IsPBClientEnabled())
        {
            pGameOptions.ActivePunkBuster = !pGameOptions.ActivePunkBuster;
        }
        m_pPunkBusterOpt.SetButtonBox(pGameOptions.ActivePunkBuster);
    }
    m_bTriggerLagWanted.SetButtonBox(!pGameOptions.WantTriggerLag);
}

//#ifdefR6PUNKBUSTER
function SetPBOptValue()
{
	local R6GameOptions pGameOptions;

#ifdefDEBUG
	local BOOL bShowLog;
	bShowLog = true;

	if (bShowLog) log("R6MenuOptionsTab GetPBOptValue");
#endif

	pGameOptions = class'Actor'.static.GetGameOptions();

	if (pGameOptions.m_bPBInstalled)	// PUNKBUSTER installed?
	{
#ifdefDEBUG
		if (bShowLog) log("PunkBuster is installed");
#endif
		// do verification before according the state define in .ini
		if (pGameOptions.ActivePunkBuster)
		{
#ifdefDEBUG
		if (bShowLog) log("User.ini define ActivePunkBuster to be active");
#endif
			if (!class'Actor'.static.IsPBClientEnabled())
			{
#ifdefDEBUG
				if (bShowLog) log("PunkBuster is disable, try to enable it");
#endif
				// try to set PBClientEnable
				class'Actor'.static.SetPBStatus( false, false);

				if (!class'Actor'.static.IsPBClientEnabled())
				{
#ifdefDEBUG
					if (bShowLog) log("CAN'T ACTIVATE PunkBuster, WHAT'S WRONG???");
#endif
					SetPBOptDisable();
					pGameOptions.ActivePunkBuster = false;
				}
			}
		}
		else
		{
#ifdefDEBUG
			if (bShowLog) log("User.ini define ActivePunkBuster to be inactive");
#endif
			if (class'Actor'.static.IsPBClientEnabled())
			{
#ifdefDEBUG
				if (bShowLog) log("PunkBuster is enable, you have to disable it!!!");
#endif
				// user modify .ini, try to disable PB -- this should happen only the next time user will load
				class'Actor'.static.SetPBStatus( true, false);
			}
		}
	}
	else // disabled the button
	{
#ifdefDEBUG
		if (bShowLog) log("PunkBuster is not installed");
#endif
		SetPBOptDisable();
		pGameOptions.ActivePunkBuster = false;
	}

	m_pPunkBusterOpt.SetButtonBox( pGameOptions.ActivePunkBuster);
}

function SetPBOptDisable()
{
	m_bPBNotInstalled = true;
	m_pPunkBusterOpt.bDisabled = true;
//	m_pPunkBusterOpt.SetButtonBox( False);    
}

function Tick(float DeltaTime)
{
    if(!m_bPBWaitForInit)
    {
        m_bPBWaitForInit = true;
        SetPBOptValue();
    }
    if(bWindowVisible && m_pPunkBusterOpt.m_bSelected != class'Actor'.static.IsPBClientEnabled())
    {
        log("Tick UpdateOptionsInPage");
        UpdateOptionsInPage();
    }
}

//#endif

//=============================================================================================
// ConvertToGLEnum: Convert string to EGameOptionsGraphicLevel enum
//=============================================================================================
function R6GameOptions.EGameOptionsNetSpeed ConvertToNSEnum( string _szValueToConvert)
{
	local R6GameOptions.EGameOptionsNetSpeed eNSResult;

	switch(_szValueToConvert)
	{
		case m_pConnectionSpeed[0]:
			eNSResult = eNS_T1;
			break;
		case m_pConnectionSpeed[1]:
			eNSResult = eNS_T3;
			break;
		case m_pConnectionSpeed[2]:
			eNSResult = eNS_Cable;
			break;
		case m_pConnectionSpeed[3]:
			eNSResult = eNS_ADSL;
			break;
		case m_pConnectionSpeed[4]:
			eNSResult = eNS_Modem;
			break;
		default:
			eNSResult = eNS_T1; // in case the file was modified
			break;
	}

	return eNSResult;
}

//=============================================================================================
// ConvertToGraphicString: This function convert graphics enum -- define in r6gameoptions to a value to display
//=============================================================================================
function string ConvertToNetSpeedString( INT _iValueToConvert)
{
	local string szResult;

	switch(_iValueToConvert)
	{
		case 0:
			szResult = m_pConnectionSpeed[0];
			break;
		case 1:
			szResult = m_pConnectionSpeed[1];
			break;
		case 2:
			szResult = m_pConnectionSpeed[2];
			break;
		case 3:
			szResult = m_pConnectionSpeed[3];
			break;
		case 4:
			szResult = m_pConnectionSpeed[4];
			break;
		default:
			szResult = m_pConnectionSpeed[0]; // in case the file was modified
			break;
	}

	return szResult;
}

function RestoreDefaultValue()
{
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    pGameOptions.ResetMultiToDefault();
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
            ManageNotifyForNetwork(C, E);            
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
                        Root.SimplePopUp(Localize("Options", "ResetToDefault", "R6Menu"), Localize("Options", "ResetToDefaultConfirm", "R6Menu"), EPopUpID_OptionsResetDefault, 0, false, self);
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

//#ifdefR6PUNKBUSTER
function ManageNotifyForNetwork(UWindowDialogControl C, byte E)
{
	if (C == m_pPunkBusterOpt)
	{
		// are you able to activate PunkBuster on client?
		if (R6WindowButtonBox(C).m_bSelected)		
		{
			class'Actor'.static.SetPBStatus( false, false);

			if (!class'Actor'.static.IsPBClientEnabled())
			{
				R6WindowButtonBox(C).m_bSelected = false;
			}
		}
		else
		{
			class'Actor'.static.SetPBStatus( true, false);
		}
	}
}

defaultproperties
{
    m_RArmpatchBitmapPos=(X=55,Y=38,W=64,H=64)
    m_RArmpatchListPos=(X=230,W=156,H=150)
}
