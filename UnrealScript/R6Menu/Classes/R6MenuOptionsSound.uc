class R6MenuOptionsSound extends R6MenuOptionsTab;

var INT									m_iRefAmbientVolume;

var INT									m_iRefVoicesVolume;

var INT									m_iRefMusicVolume;

var BOOL								m_bEAXNotSupported; // if EAX is not supported

// OPTION SOUND
var R6WindowHScrollBar					m_pAmbientVolume;

var R6WindowHScrollBar					m_pVoicesVolume;

var R6WindowHScrollBar					m_pMusicVolume;

var R6WindowComboControl				m_pSndQuality;

var R6WindowComboControl				m_pAudioVirtual;

var R6WindowButtonBox                   m_pSndHardware;

var R6WindowButtonBox                   m_pEAX;

var R6WindowBitMap                      m_EaxLogo;

var Texture                             m_EaxTexture;

var Region                              m_EaxTextureReg;

// GENERAL
var string								m_pComboLevel[4];

var string								m_pSndLocEnum[3];

function Created()
{
    super.Created();
    m_pComboLevel[0] = Localize("Options", "Level_None", "R6Menu");
    m_pComboLevel[1] = Localize("Options", "Level_Low", "R6Menu");
    m_pComboLevel[2] = Localize("Options", "Level_Medium", "R6Menu");
    m_pComboLevel[3] = Localize("Options", "Level_Hi", "R6Menu");
    m_pSndLocEnum[0] = Localize("Options", "Opt_SndVirtualHigh", "R6Menu");
    m_pSndLocEnum[1] = Localize("Options", "Opt_SndVirtualLow", "R6Menu");
    m_pSndLocEnum[2] = Localize("Options", "Opt_SndVirtualOff", "R6Menu");
}

function InitPageOptions()
{
    local Region rRegionW;
    local float fXOffset, fYOffset, fYStep, fWidth, fHeight, fTemp,
	    fSizeOfCounter, fXRightOffset;

    local Font ButtonFont;

    ButtonFont = Root.Fonts[5];
    fXOffset = 5.0;
    fXRightOffset = 26.0;
    fYOffset = 5.0;
    fWidth = (WinWidth - fXOffset) - float(40);
    fHeight = 14.0;
    fYStep = 27.0;
    m_pAmbientVolume = R6WindowHScrollbar(CreateControl(Class'R6Window.R6WindowHScrollbar', fXOffset, fYOffset, (WinWidth - fXOffset) - fXRightOffset, 14.0, self));
    m_pAmbientVolume.CreateSB(GetPlayerOwner().ESoundSlot.SLOT_Ambient, 250.0, 0.0, 140.0, 14.0, self);
    m_pAmbientVolume.CreateSBTextLabel(Localize("Options", "Opt_SndAmbient", "R6Menu"), Localize("Tip", "Opt_SndAmbient", "R6Menu"));
    m_pAmbientVolume.SetScrollBarRange(0.0, 100.0, 20.0);
    fYOffset += fYStep;
    m_pVoicesVolume = R6WindowHScrollbar(CreateControl(Class'R6Window.R6WindowHScrollbar', fXOffset, fYOffset, (WinWidth - fXOffset) - fXRightOffset, 14.0, self));
    m_pVoicesVolume.CreateSB(GetPlayerOwner().ESoundSlot.SLOT_Talk, 250.0, 0.0, 140.0, 14.0, self);
    m_pVoicesVolume.CreateSBTextLabel(Localize("Options", "Opt_SndVoices", "R6Menu"), Localize("Tip", "Opt_SndVoices", "R6Menu"));
    m_pVoicesVolume.SetScrollBarRange(0.0, 100.0, 20.0);
    fYOffset += fYStep;
    m_pMusicVolume = R6WindowHScrollbar(CreateControl(Class'R6Window.R6WindowHScrollbar', fXOffset, fYOffset, (WinWidth - fXOffset) - fXRightOffset, 14.0, self));
    m_pMusicVolume.CreateSB(GetPlayerOwner().ESoundSlot.SLOT_Music, 250.0, 0.0, 140.0, 14.0, self);
    m_pMusicVolume.CreateSBTextLabel(Localize("Options", "Opt_SndMusic", "R6Menu"), Localize("Tip", "Opt_SndMusic", "R6Menu"));
    m_pMusicVolume.SetScrollBarRange(0.0, 100.0, 20.0);
    fYOffset += fYStep;
    rRegionW.X = int(fXOffset);
    rRegionW.Y = int(fYOffset);
    rRegionW.W = int(fWidth + float(20));
    rRegionW.H = int(fHeight);
    m_pSndQuality = SetComboControlButton(rRegionW, Localize("Options", "Opt_SndQuality", "R6Menu"), Localize("Tip", "Opt_SndQuality", "R6Menu"));
    m_pSndQuality.AddItem(m_pComboLevel[1], "");
    m_pSndQuality.AddItem(m_pComboLevel[3], "");
    m_pSndQuality.SetDisableButton(m_bInGame);
    fYOffset += fYStep;
    rRegionW.Y = int(fYOffset);
    m_pAudioVirtual = SetComboControlButton(rRegionW, Localize("Options", "Opt_SndVirtual", "R6Menu"), Localize("Tip", "Opt_SndVirtual", "R6Menu"));
    m_pAudioVirtual.AddItem(m_pSndLocEnum[2], "");
    m_pAudioVirtual.AddItem(m_pSndLocEnum[1], "");
    m_pAudioVirtual.AddItem(m_pSndLocEnum[0], "");
    fYOffset += fYStep;
    m_pSndHardware = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pSndHardware.SetButtonBox(false);
    m_pSndHardware.CreateTextAndBox(Localize("Options", "Opt_SndHardware", "R6Menu"), Localize("Tip", "Opt_SndHardware", "R6Menu"), 0.0, 0);
    fYOffset += fYStep;
    m_pEAX = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', fXOffset, fYOffset, fWidth, fHeight, self));
    m_pEAX.SetButtonBox(false);
    m_pEAX.CreateTextAndBox(Localize("Options", "Opt_SndEAX", "R6Menu"), Localize("Tip", "Opt_SndEAX", "R6Menu"), 0.0, 1);
    fYOffset += fYStep;
    m_EaxLogo = R6WindowBitMap(CreateWindow(Class'R6Window.R6WindowBitMap', 0.0, fYOffset, WinWidth, float(m_EaxTextureReg.H), self));
    m_EaxLogo.bCenter = true;
    m_EaxLogo.m_iDrawStyle = 5;
    m_EaxLogo.t = m_EaxTexture;
    m_EaxLogo.R = m_EaxTextureReg;
    m_EaxLogo.m_bUseColor = true;
    m_EaxLogo.m_TextureColor = Root.Colors.GrayLight;
    InitResetButton();
    UpdateOptionsInPage();
    m_bInitComplete = true;
}

function UpdateOptionsInEngine()
{
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    pGameOptions.AmbientVolume = int(m_pAmbientVolume.GetScrollBarValue());
    pGameOptions.VoicesVolume = int(m_pVoicesVolume.GetScrollBarValue());
    pGameOptions.MusicVolume = int(m_pMusicVolume.GetScrollBarValue());
    pGameOptions.SndHardware = m_pSndHardware.m_bSelected;
    pGameOptions.EAX = m_pEAX.m_bSelected;
    pGameOptions.SndQuality = ConvertToSndQuality(m_pSndQuality.GetValue());
    pGameOptions.AudioVirtual = ConvertToAVEnum(m_pAudioVirtual.GetValue());
}

function UpdateOptionsInPage()
{
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    m_pAmbientVolume.SetScrollBarValue(float(pGameOptions.AmbientVolume));
    m_pVoicesVolume.SetScrollBarValue(float(pGameOptions.VoicesVolume));
    m_pMusicVolume.SetScrollBarValue(float(pGameOptions.MusicVolume));
    m_iRefAmbientVolume = int(m_pAmbientVolume.GetScrollBarValue());
    m_iRefVoicesVolume = int(m_pVoicesVolume.GetScrollBarValue());
    m_iRefMusicVolume = int(m_pMusicVolume.GetScrollBarValue());
    m_pSndHardware.SetButtonBox(pGameOptions.SndHardware);
    if(pGameOptions.EAXCompatible)
    {
        m_pEAX.SetButtonBox(pGameOptions.EAX);        
    }
    else
    {
        m_bEAXNotSupported = true;
        m_pEAX.bDisabled = true;
        m_pEAX.SetButtonBox(false);
    }
    ManageNotifyForSound(m_pSndHardware, 1);
    ManageNotifyForSound(m_pEAX, 1);
    m_pAudioVirtual.SetValue(ConvertToAudioString(int(pGameOptions.AudioVirtual)));
    m_pSndQuality.SetValue(ConvertToSndQualityString(pGameOptions.SndQuality));
}

//=============================================================================
// ConvertSndQuality: Convert the sound quality to a bin value or the inverse
//=============================================================================
function INT ConvertToSndQuality( string _szValue)
{
	if (_szValue == m_pComboLevel[3])
		return 1;
	else
		return 0;
}

//=============================================================================
// ConvertSndQuality: Convert the sound quality to a bin value or the inverse
//=============================================================================
function string ConvertToSndQualityString( INT _iValue)
{
	if ( _iValue == 1)
		return m_pComboLevel[3];
	else
		return m_pComboLevel[1];
}

//=============================================================================================
// ConvertToAVEnum: Convert string to EGameOptionsAudioVirtual enum
//=============================================================================================
function R6GameOptions.EGameOptionsAudioVirtual ConvertToAVEnum( string _szValueToConvert)
{
	local R6GameOptions.EGameOptionsAudioVirtual eAVResult;

	switch(_szValueToConvert)
	{
		case m_pSndLocEnum[0]:
			eAVResult = eAV_High;
			break;
		case m_pSndLocEnum[1]:
			eAVResult = eAV_Low;
			break;
		case m_pSndLocEnum[2]:
			eAVResult = eAV_None;
			break;
		default:
			break;
	}

	return eAVResult;
}

//=============================================================================================
// ConvertToAudioString: This function convert sounds enum -- define in r6gameoptions to a value to display
//=============================================================================================
function string ConvertToAudioString( INT _iValueToConvert)
{
	local string szResult;

	switch(_iValueToConvert)
	{
		case 0:
			szResult = m_pSndLocEnum[0];
			break;
		case 1:
			szResult = m_pSndLocEnum[1];
			break;
		case 2:
			szResult = m_pSndLocEnum[2];
			break;
		default:
			break;
	}

	return szResult;
}

function RestoreDefaultValue()
{
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    pGameOptions.ResetSoundToDefault(m_bInGame);
    UpdateOptionsInPage();
}

function Notify(UWindowDialogControl C, byte E)
{
    local bool bUpdateGameOptions;
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    if(E == DE_Click)
    {
        if(C.IsA('R6WindowButtonBox'))
        {
            if(R6WindowButtonBox(C).GetSelectStatus())
            {
                R6WindowButtonBox(C).m_bSelected = !R6WindowButtonBox(C).m_bSelected;
                bUpdateGameOptions = true;
            }
            ManageNotifyForSound(C, E);            
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
            switch(UWindowHScrollbar(C).m_iScrollBarID)
            {
                case GetPlayerOwner().ESoundSlot.SLOT_Ambient:
                    if(E == DE_MouseLeave)
                    {
                        if(float(m_iRefAmbientVolume) != m_pAmbientVolume.GetScrollBarValue())
                        {
                            m_iRefAmbientVolume = int(m_pAmbientVolume.GetScrollBarValue());
                            bUpdateGameOptions = true;
                        }                        
                    }
                    else
                    {
                        if((E == DE_Change) && m_bInitComplete)
                        {
                            GetPlayerOwner().ChangeVolumeTypeLinear(GetPlayerOwner().ESoundSlot.SLOT_Ambient, m_pAmbientVolume.GetScrollBarValue());
                        }
                    }
                    break;
                case GetPlayerOwner().ESoundSlot.SLOT_Music:
                    if(E == DE_MouseLeave)
                    {
                        if(float(m_iRefMusicVolume) != m_pMusicVolume.GetScrollBarValue())
                        {
                            m_iRefMusicVolume = int(m_pMusicVolume.GetScrollBarValue());
                            bUpdateGameOptions = true;
                        }                        
                    }
                    else
                    {
                        if((E == DE_Change) && m_bInitComplete)
                        {
                            GetPlayerOwner().ChangeVolumeTypeLinear(GetPlayerOwner().ESoundSlot.SLOT_Music, m_pMusicVolume.GetScrollBarValue());
                        }
                    }
                    break;
                case GetPlayerOwner().ESoundSlot.SLOT_Talk:
                    if(E == DE_MouseLeave)
                    {
                        if(float(m_iRefVoicesVolume) != m_pVoicesVolume.GetScrollBarValue())
                        {
                            m_iRefVoicesVolume = int(m_pVoicesVolume.GetScrollBarValue());
                            bUpdateGameOptions = true;
                        }                        
                    }
                    else
                    {
                        if((E == DE_Change) && m_bInitComplete)
                        {
                            GetPlayerOwner().ChangeVolumeTypeLinear(GetPlayerOwner().ESoundSlot.SLOT_Talk, m_pVoicesVolume.GetScrollBarValue());
                        }
                    }
                    break;
                default:
                    bUpdateGameOptions = false;
                    break;
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

function ManageNotifyForSound(UWindowDialogControl C, byte E)
{
	if (C == m_pSndHardware)
	{
		if (!m_bEAXNotSupported)
		{
			// if snd hardware is activate, remove disable to eax
			if (R6WindowButtonBox(C).m_bSelected)
			{
				m_pEAX.bDisabled   = false;
			}
			else // if you desactivate the SndHardware, EAX is desactivate too
			{
				m_pEAX.bDisabled   = true;
				m_pEAX.m_bSelected = false;
			}

			m_EaxLogo.m_bUseColor = !m_pEAX.m_bSelected;
		}
	}
	else if(C == m_pEAX)
	{
		m_EaxLogo.m_bUseColor = !m_pEAX.m_bSelected;
	}
}

defaultproperties
{
    m_EaxTexture=Texture'R6MenuTextures.Gui_BoxScroll'
    m_EaxTextureReg=(Y=396,W=188,H=84)
}
