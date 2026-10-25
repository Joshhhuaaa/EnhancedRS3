class R6MenuOptionsGraphic extends R6MenuOptionsTab;

const C_szEGameOptionsGraphicLevel		= "EGameOptionsGraphicLevel";	// come fron R6GameOptions

const C_szEGameOptionsEffectLevel		= "EGameOptionsEffectLevel";	// come fron R6GameOptions

const C_iITEM_NONE						= 0x01;

const C_iITEM_LOW						= 0x02;

const C_iITEM_MEDIUM					= 0x04;

const C_iITEM_HIGH						= 0x08;

const C_iGORE_ITEMS						= 0x0A;

const C_iSHADOW_ITEMS					= 0x0B;							// NONE, LOW, HIGH

const C_iALL_ITEMS						= 0x0F;

var bool m_bUpdateFileOnly;

// OPTION GRAPHIC
var R6WindowComboControl				m_pVideoRes;

var R6WindowComboControl				m_pTextureDetail;

var R6WindowComboControl				m_pLightmapDetail;

var R6WindowComboControl				m_pRainbowsDetail;

var R6WindowComboControl				m_pHostagesDetail;

var R6WindowComboControl				m_pTerrosDetail;

var R6WindowComboControl				m_pRainbowsShadowLevel;

var R6WindowComboControl				m_pHostagesShadowLevel;

var R6WindowComboControl				m_pTerrosShadowLevel;

var R6WindowComboControl				m_pGoreLevel;

var R6WindowComboControl				m_pDecalsDetail;

var R6WindowButtonBox                   m_pAnimGeometry;

var R6WindowButtonBox                   m_pHideDeadBodies;

var R6WindowButtonBox                   m_pLowDetailSmoke;

// GENERAL
var string								m_pComboLevel[4];

function Created()
{
    super.Created();
    m_pComboLevel[0] = Localize("Options", "Level_None", "R6Menu");
    m_pComboLevel[1] = Localize("Options", "Level_Low", "R6Menu");
    m_pComboLevel[2] = Localize("Options", "Level_Medium", "R6Menu");
    m_pComboLevel[3] = Localize("Options", "Level_Hi", "R6Menu");
}

function InitPageOptions()
{
    local Region rRegionW;
    local float fYStep;
    local Font ButtonFont;
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    ButtonFont = Root.Fonts[5];
    rRegionW.X = 5;
    rRegionW.Y = 5;
    rRegionW.W = int((WinWidth - float(rRegionW.X)) - float(20));
    rRegionW.H = 14;
    fYStep = 19.0;
    m_pVideoRes = SetComboControlButton(rRegionW, Localize("Options", "Opt_GrapVideoRes", "R6Menu"), Localize("Tip", "Opt_GrapVideoRes", "R6Menu"));
    AddVideoResolution(m_pVideoRes);
    if(m_bInGame)
    {
        m_pVideoRes.SetDisableButton(!pGameOptions.AllowChangeResInGame);
    }
    rRegionW.Y += int(fYStep);
    m_pTextureDetail = SetComboControlButton(rRegionW, Localize("Options", "Opt_GrapTexDetail", "R6Menu"), Localize("Tip", "Opt_GrapTexDetail", "R6Menu"));
    AddGraphComboControlItem(15, m_pTextureDetail, "EGameOptionsGraphicLevel");
    rRegionW.Y += int(fYStep);
    m_pLightmapDetail = SetComboControlButton(rRegionW, Localize("Options", "Opt_GrapLightMap", "R6Menu"), Localize("Tip", "Opt_GrapLightMap", "R6Menu"));
    AddGraphComboControlItem(15, m_pLightmapDetail, "EGameOptionsGraphicLevel", true);
    rRegionW.Y += int(fYStep);
    m_pRainbowsDetail = SetComboControlButton(rRegionW, Localize("Options", "Opt_GrapRainbowDetail", "R6Menu"), Localize("Tip", "Opt_GrapRainbowDetail", "R6Menu"));
    AddGraphComboControlItem(15, m_pRainbowsDetail, "EGameOptionsGraphicLevel");
    rRegionW.Y += int(fYStep);
    m_pHostagesDetail = SetComboControlButton(rRegionW, Localize("Options", "Opt_GrapHostDetail", "R6Menu"), Localize("Tip", "Opt_GrapHostDetail", "R6Menu"));
    AddGraphComboControlItem(15, m_pHostagesDetail, "EGameOptionsGraphicLevel");
    rRegionW.Y += int(fYStep);
    m_pTerrosDetail = SetComboControlButton(rRegionW, Localize("Options", "Opt_GrapTerroDetail", "R6Menu"), Localize("Tip", "Opt_GrapTerroDetail", "R6Menu"));
    AddGraphComboControlItem(15, m_pTerrosDetail, "EGameOptionsGraphicLevel");
    rRegionW.Y += int(fYStep);
    m_pRainbowsShadowLevel = SetComboControlButton(rRegionW, Localize("Options", "Opt_GrapRainbowShadow", "R6Menu"), Localize("Tip", "Opt_GrapRainbowShadow", "R6Menu"));
    AddGraphComboControlItem(11, m_pRainbowsShadowLevel, "EGameOptionsEffectLevel", true);
    m_pRainbowsShadowLevel.SetDisableButton(m_bInGame);
    rRegionW.Y += int(fYStep);
    m_pHostagesShadowLevel = SetComboControlButton(rRegionW, Localize("Options", "Opt_GrapHostShadow", "R6Menu"), Localize("Tip", "Opt_GrapHostShadow", "R6Menu"));
    AddGraphComboControlItem(11, m_pHostagesShadowLevel, "EGameOptionsEffectLevel", true);
    m_pHostagesShadowLevel.SetDisableButton(m_bInGame);
    rRegionW.Y += int(fYStep);
    m_pTerrosShadowLevel = SetComboControlButton(rRegionW, Localize("Options", "Opt_GrapTerroShadow", "R6Menu"), Localize("Tip", "Opt_GrapTerroShadow", "R6Menu"));
    AddGraphComboControlItem(11, m_pTerrosShadowLevel, "EGameOptionsEffectLevel", true);
    m_pTerrosShadowLevel.SetDisableButton(m_bInGame);
    if(!pGameOptions.SplashScreen)
    {
        rRegionW.Y += int(fYStep);
        m_pGoreLevel = SetComboControlButton(rRegionW, Localize("Options", "Opt_GrapGoreLevel", "R6Menu"), Localize("Tip", "Opt_GrapGoreLevel", "R6Menu"));
        AddGraphComboControlItem(10, m_pGoreLevel, "EGameOptionsGraphicLevel");
        m_pGoreLevel.SetDisableButton(m_bInGame);
    }
    rRegionW.Y += int(fYStep);
    m_pDecalsDetail = SetComboControlButton(rRegionW, Localize("Options", "Opt_GrapDecalsDetail", "R6Menu"), Localize("Tip", "Opt_GrapDecalsDetail", "R6Menu"));
    AddGraphComboControlItem(15, m_pDecalsDetail, "EGameOptionsEffectLevel");
    m_pDecalsDetail.SetDisableButton(m_bInGame);
    rRegionW.Y += int(fYStep);
    rRegionW.W -= 20;
    m_pAnimGeometry = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', float(rRegionW.X), float(rRegionW.Y), float(rRegionW.W), float(rRegionW.H), self));
    m_pAnimGeometry.SetButtonBox(true);
    m_pAnimGeometry.CreateTextAndBox(Localize("Options", "Opt_GrapAnimGeometry", "R6Menu"), Localize("Tip", "Opt_GrapAnimGeometry", "R6Menu"), 0.0, 0);
    if(!pGameOptions.SplashScreen)
    {
        rRegionW.Y += int(fYStep);
        m_pHideDeadBodies = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', float(rRegionW.X), float(rRegionW.Y), float(rRegionW.W), float(rRegionW.H), self));
        m_pHideDeadBodies.SetButtonBox(true);
        m_pHideDeadBodies.CreateTextAndBox(Localize("Options", "Opt_GrapHideDeadBodies", "R6Menu"), Localize("Tip", "Opt_GrapHideDeadBodies", "R6Menu"), 0.0, 0);
    }
    rRegionW.Y += int(fYStep);
    m_pLowDetailSmoke = R6WindowButtonBox(CreateControl(Class'R6Window.R6WindowButtonBox', float(rRegionW.X), float(rRegionW.Y), float(rRegionW.W), float(rRegionW.H), self));
    m_pLowDetailSmoke.SetButtonBox(false);
    m_pLowDetailSmoke.CreateTextAndBox(Localize("Options", "Opt_GrapLowDetailSmoke", "R6Menu"), Localize("Tip", "Opt_GrapLowDetailSmoke", "R6Menu"), 0.0, 0);
    InitResetButton();
    UpdateOptionsInPage();
    m_bInitComplete = true;
}

function UpdateOptionsInEngine()
{
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    GetResolutionXY(pGameOptions.R6ScreenSizeX, pGameOptions.R6ScreenSizeY, pGameOptions.R6ScreenRefreshRate);
    pGameOptions.TextureDetail = ConvertToGLEnum(m_pTextureDetail.GetValue());
    pGameOptions.LightmapDetail = ConvertToGLEnum(m_pLightmapDetail.GetValue());
    pGameOptions.RainbowsDetail = ConvertToGLEnum(m_pRainbowsDetail.GetValue());
    pGameOptions.RainbowsShadowLevel = ConvertToELEnum(m_pRainbowsShadowLevel.GetValue());
    pGameOptions.HostagesDetail = ConvertToGLEnum(m_pHostagesDetail.GetValue());
    pGameOptions.TerrosDetail = ConvertToGLEnum(m_pTerrosDetail.GetValue());
    pGameOptions.HostagesShadowLevel = ConvertToELEnum(m_pHostagesShadowLevel.GetValue());
    pGameOptions.TerrosShadowLevel = ConvertToELEnum(m_pTerrosShadowLevel.GetValue());
    if(pGameOptions.SplashScreen)
    {
        pGameOptions.GoreLevel = pGameOptions.EGameOptionsEffectLevel.eEL_None;        
    }
    else
    {
        pGameOptions.GoreLevel = ConvertToELEnum(m_pGoreLevel.GetValue());
    }
    pGameOptions.DecalsDetail = ConvertToELEnum(m_pDecalsDetail.GetValue());
    pGameOptions.AnimatedGeometry = m_pAnimGeometry.m_bSelected;
    if(pGameOptions.SplashScreen)
    {
        pGameOptions.HideDeadBodies = true;        
    }
    else
    {
        pGameOptions.HideDeadBodies = m_pHideDeadBodies.m_bSelected;
    }
    pGameOptions.LowDetailSmoke = m_pLowDetailSmoke.m_bSelected;
    if(R6MenuOptionsWidget(OwnerWindow).m_bInGame && !m_bUpdateFileOnly)
    {
        class'Actor'.static.UpdateGraphicOptions();
    }
}

function UpdateOptionsInPage()
{
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    if(pGameOptions.ShowRefreshRates && pGameOptions.R6ScreenRefreshRate != -1)
    {
        m_pVideoRes.SetValue((((string(pGameOptions.R6ScreenSizeX) $ "x") $ string(pGameOptions.R6ScreenSizeY)) $ "@") $ string(pGameOptions.R6ScreenRefreshRate));        
    }
    else
    {
        m_pVideoRes.SetValue((string(pGameOptions.R6ScreenSizeX) $ "x") $ string(pGameOptions.R6ScreenSizeY));
    }
    m_pTextureDetail.SetValue(ConvertToGraphicString(15, int(pGameOptions.TextureDetail), "EGameOptionsGraphicLevel"));
    m_pLightmapDetail.SetValue(ConvertToGraphicString(15, int(pGameOptions.LightmapDetail), "EGameOptionsGraphicLevel", true));
    m_pRainbowsDetail.SetValue(ConvertToGraphicString(15, int(pGameOptions.RainbowsDetail), "EGameOptionsGraphicLevel"));
    m_pRainbowsShadowLevel.SetValue(ConvertToGraphicString(11, int(pGameOptions.RainbowsShadowLevel), "EGameOptionsEffectLevel", true));
    m_pHostagesDetail.SetValue(ConvertToGraphicString(15, int(pGameOptions.HostagesDetail), "EGameOptionsGraphicLevel"));
    m_pTerrosDetail.SetValue(ConvertToGraphicString(15, int(pGameOptions.TerrosDetail), "EGameOptionsGraphicLevel"));
    m_pHostagesShadowLevel.SetValue(ConvertToGraphicString(11, int(pGameOptions.HostagesShadowLevel), "EGameOptionsEffectLevel", true));
    m_pTerrosShadowLevel.SetValue(ConvertToGraphicString(11, int(pGameOptions.TerrosShadowLevel), "EGameOptionsEffectLevel", true));
    if(!pGameOptions.SplashScreen)
    {
        m_pGoreLevel.SetValue(ConvertToGraphicString(10, int(pGameOptions.GoreLevel), "EGameOptionsEffectLevel"));
    }
    m_pDecalsDetail.SetValue(ConvertToGraphicString(15, int(pGameOptions.DecalsDetail), "EGameOptionsEffectLevel"));
    m_pAnimGeometry.SetButtonBox(pGameOptions.AnimatedGeometry);
    if(!pGameOptions.SplashScreen)
    {
        m_pHideDeadBodies.SetButtonBox(pGameOptions.HideDeadBodies);
    }
    m_pLowDetailSmoke.SetButtonBox(pGameOptions.LowDetailSmoke);
}

//=============================================================================================
// ConvertToGLEnum: Convert string to EGameOptionsGraphicLevel enum
//=============================================================================================
function R6GameOptions.EGameOptionsGraphicLevel ConvertToGLEnum( string _szValueToConvert)
{
	local R6GameOptions.EGameOptionsGraphicLevel eGLResult;

	switch(_szValueToConvert)
	{
		case m_pComboLevel[1]:
			eGLResult = eGL_Low;
			break;
		case m_pComboLevel[2]:
			eGLResult = eGL_Medium;
			break;
		case m_pComboLevel[3]:
			eGLResult = eGL_High;
			break;
		default:
			break;
	}

	return eGLResult;
}

//=============================================================================================
// ConvertToGLEnum: Convert string to EGameOptionsGraphicLevel enum
//=============================================================================================
function R6GameOptions.EGameOptionsEffectLevel ConvertToELEnum( string _szValueToConvert)
{
	local R6GameOptions.EGameOptionsEffectLevel eELResult;

	switch(_szValueToConvert)
	{
		case m_pComboLevel[0]:
			eELResult = eEL_None;
			break;
		case m_pComboLevel[1]:
			eELResult = eEL_Low;
			break;
		case m_pComboLevel[2]:
			eELResult = eEL_Medium;
			break;
		case m_pComboLevel[3]:
			eELResult = eEL_High;
			break;
		default:
			break;
	}

	return eELResult;
}

//=============================================================================================
// ConvertToGraphicString: This function convert graphics enum -- define in r6gameoptions to a value to display
//=============================================================================================
function string ConvertToGraphicString( INT _iAddItemMask, INT _iValueToConvert, string _szGraphicsEnumName, optional BOOL _bCheckFor32MegVideoCard)
{
	local string szResult;

	if (_szGraphicsEnumName == C_szEGameOptionsGraphicLevel)
	{
		switch(_iValueToConvert)
		{
			case 0:
				if ((_iAddItemMask & C_iITEM_LOW) > 0)
					szResult = m_pComboLevel[1]; // LOW
#ifdefDEBUG
				else
					log("Assign at least one valid item for your combo list");
#endif
				break;
			case 1:
				if ((_iAddItemMask & C_iITEM_MEDIUM) > 0)
					szResult = m_pComboLevel[2]; // MEDIUM
				else // try with a lowest item level
					szResult = ConvertToGraphicString( _iAddItemMask, 0, _szGraphicsEnumName, _bCheckFor32MegVideoCard);
				break;
			case 2: // try with a lowest item level
				if ((_iAddItemMask & C_iITEM_HIGH) > 0)
					szResult = m_pComboLevel[3]; // HIGH
				else
					szResult = ConvertToGraphicString( _iAddItemMask, 1, _szGraphicsEnumName, _bCheckFor32MegVideoCard);
				break;
			default:
				szResult = m_pComboLevel[1]; // ini file was modify with a bad value, put to LOW
				break;
		}
	}
	else // C_szEGameOptionsEffectLevel
	{
		switch(_iValueToConvert)
		{
			case 0:
				if ((_iAddItemMask & C_iITEM_NONE) > 0)
					szResult = m_pComboLevel[0]; // NONE
#ifdefDEBUG
				else
					log("Assign at least one valid item for your combo list");
#endif
				break;
			case 1:
				if ((_iAddItemMask & C_iITEM_LOW) > 0)
					szResult = m_pComboLevel[1]; // LOW
				else // try with a lowest item level
					szResult = ConvertToGraphicString( _iAddItemMask, 0, _szGraphicsEnumName, _bCheckFor32MegVideoCard);
				break;
			case 2: 
				if ((_iAddItemMask & C_iITEM_MEDIUM) > 0)
					szResult = m_pComboLevel[2]; // MEDIUM
				else // try with a lowest item level
					szResult = ConvertToGraphicString( _iAddItemMask, 1, _szGraphicsEnumName, _bCheckFor32MegVideoCard);
				break;
			case 3: // try with a lowest item level
				if ((_iAddItemMask & C_iITEM_HIGH) > 0)
					szResult = m_pComboLevel[3]; // HIGH
				else
					szResult = ConvertToGraphicString( _iAddItemMask, 2, _szGraphicsEnumName, _bCheckFor32MegVideoCard);
				break;
			default:
				szResult = m_pComboLevel[0]; // ini file was modify with a bad value, put to NONE
				break;
		}
	}

	if (_bCheckFor32MegVideoCard)
	{
		if (!class'Actor'.static.IsVideoHardwareAtLeast64M())
		{
			if (_szGraphicsEnumName == C_szEGameOptionsGraphicLevel) // high
			{
                if (szResult == m_pComboLevel[3])
    				szResult = ConvertToGraphicString( _iAddItemMask, 1, _szGraphicsEnumName, _bCheckFor32MegVideoCard);
			}
			else // C_szEGameOptionsEffectLevel -- High
			{
                if (szResult == m_pComboLevel[3])
    				szResult = ConvertToGraphicString( _iAddItemMask, 2, _szGraphicsEnumName, _bCheckFor32MegVideoCard);
			}
		}
	}

	return szResult;
}

function AddGraphComboControlItem( INT _iAddItemMask, R6WindowComboControl _pR6WindowComboControl, string _szGraphicsEnumName, optional BOOL _bCheckFor32MegVideoCard)
{
	local BOOL bAddHiItem;

	bAddHiItem = true;

	if (_szGraphicsEnumName == C_szEGameOptionsEffectLevel)
	{
		if ((_iAddItemMask & C_iITEM_NONE) > 0)
		_pR6WindowComboControl.AddItem( m_pComboLevel[0], "");
	}

	if ((_iAddItemMask & C_iITEM_LOW) > 0)
		_pR6WindowComboControl.AddItem( m_pComboLevel[1], "");
	if ((_iAddItemMask & C_iITEM_MEDIUM) > 0)
		_pR6WindowComboControl.AddItem( m_pComboLevel[2], "");

	if(_bCheckFor32MegVideoCard)
	{
		if (!class'Actor'.static.IsVideoHardwareAtLeast64M())
		{
			bAddHiItem = false;
		}
	}

	if ((bAddHiItem) && ( (_iAddItemMask & C_iITEM_HIGH) > 0))
		_pR6WindowComboControl.AddItem( m_pComboLevel[3], "");
}

//=============================================================================================
// AddVideoResolution: Add video resolution in the combo list
//=============================================================================================
function AddVideoResolution( R6WindowComboControl _pR6WindowComboControl)
{
	local INT i,j,iWidth, iHeight, iRefreshRate;
	local R6GameOptions pGameOptions;
	pGameOptions = class'Actor'.static.GetGameOptions();

	i = class'Actor'.static.GetNbAvailableResolutions();

	for(j=0; j < i; j++)
	{
	    class'Actor'.static.GetAvailableResolution(j, iWidth, iHeight, iRefreshRate);
        
        if(pGameOptions.ShowRefreshRates)
            _pR6WindowComboControl.AddItem( iWidth $ "x" $ iHeight $ "@" $ iRefreshRate, "");
        else
            _pR6WindowComboControl.AddItem( iWidth $ "x" $ iHeight, "");
	}
}

function GetResolutionXY(OUT INT iSX, OUT INT iSY, OUT INT iRR)
{
	local INT	 iX;
	local string szTemp;
    local string szTemp2;
	local R6GameOptions pGameOptions;
	pGameOptions = class'Actor'.static.GetGameOptions();

	szTemp  = m_pVideoRes.GetValue();
	iX		= InStr(szTemp, "x");
    szTemp2 = Left(szTemp, iX);
    iSX     = INT(szTemp2);
    szTemp  = Right(szTemp, Len(szTemp) - iX - 1); // -1 to remove the "x" char

    if(pGameOptions.ShowRefreshRates)
    {
	    iX		= InStr(szTemp, "@");
        szTemp2 = Left(szTemp, iX);
        iSY     = INT(szTemp2);
        szTemp  = Right(szTemp, Len(szTemp) - iX - 1); // -1 to remove the "x" char
        iRR     = INT(szTemp);
    }
    else
    {
        iSY     = INT(szTemp);
        iRR     = -1;
    }
}

function RestoreDefaultValue()
{
    local R6GameOptions pGameOptions;

    pGameOptions = class'Actor'.static.GetGameOptions();
    pGameOptions.ResetGraphicsToDefault(m_bInGame);
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
        m_bUpdateFileOnly = true;
        UpdateOptionsInEngine();
        m_bUpdateFileOnly = false;
        pGameOptions.SaveConfig();
    }
}
