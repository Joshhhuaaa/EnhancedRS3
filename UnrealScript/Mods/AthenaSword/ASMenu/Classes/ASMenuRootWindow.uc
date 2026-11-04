class ASMenuRootWindow extends R6MenuRootWindow
    config;

function Created()
{
    super.Created();
}

function bool CheckASVersion()
{
    local float fRSVersion, fASVersion;
    local string szRSVersion, szRSVersionInCAPS, szASVersion, szASVersionInCAPS;

    szRSVersion = class'Actor'.static.GetGameVersion(true);
    szASVersion = class'Actor'.static.GetGameVersion(true, true);
    szRSVersionInCAPS = Caps(szRSVersion);
    szASVersionInCAPS = Caps(szASVersion);
    if(szRSVersionInCAPS < szASVersionInCAPS)
    {
        SimplePopUp(Localize("MultiPlayer", "PopUp_Error_BadVersion", "R6Menu"), ((((((Localize("AthenaSword", "PopUp_NewerASVersion", "R6Menu")) $ " ") $ szASVersion) $ "\\nRAVEN SHIELD: ") $ szRSVersion) $ "\\nATHENA SWORD: ") $ szASVersion, EPopUpID_Max, MessageBoxButtons.MB_OK, false, self);
        return false;
    }
    else
    {
        if(szRSVersionInCAPS > szASVersionInCAPS)
        {
            SimplePopUp(Localize("MultiPlayer", "PopUp_Error_BadVersion", "R6Menu"), ((((((Localize("AthenaSword", "PopUp_OlderASVersion", "R6Menu")) $ " ") $ szRSVersion) $ "\\nRAVEN SHIELD: ") $ szRSVersion) $ "\\nATHENA SWORD: ") $ szASVersion, EPopUpID_Max, MessageBoxButtons.MB_OK, false, self);
            return false;
        }
    }
    return true;
}

function AssignShowFirstWidget()
{
    if(R6Console(Console).m_bStartedByGSClient)
    {
        m_CurrentWidget = m_pUbiComWidget;
    }
    else
    {
        if(R6Console(Console).m_bNonUbiMatchMaking)
        {
            m_CurrentWidget = m_pNonUbiWidget;
        }
        else
        {
            if(R6Console(Console).m_bNonUbiMatchMakingHost)
            {
                m_CurrentWidget = m_pMPCreateGameWidget;
                m_pMPCreateGameWidget.RefreshCreateGameMenu();
            }
            else
            {
                m_CurrentWidget = m_MainMenuWidget;
            }
        }
    }
    m_CurrentWidget.ShowWindow();
}

function ChangeCurrentWidget(UWindowRootWindow.eGameWidgetID widgetID)
{
    local bool bDontQuitNow;

    if(R6Console(Console).m_bStartedByGSClient)
    {
        m_bJoinServerProcess = false;
        if(widgetID == PreviousWidgetID)
        {
            m_eCurWidgetInUse = m_ePrevWidgetInUse;
            m_ePrevWidgetInUse = WidgetID_None;
        }
        else
        {
            m_ePrevWidgetInUse = m_eCurWidgetInUse;
            m_eCurWidgetInUse = widgetID;
            if(m_ePrevWidgetInUse == PlanningWidgetID)
            {
                if(R6PlanningCtrl(GetPlayerOwner()) != none)
                {
                    R6PlanningCtrl(GetPlayerOwner()).CancelActionPointAction();
                }
            }
        }
        switch(widgetID)
        {
            case MPCreateGameWidgetID:
                m_CurrentWidget.HideWindow();
                m_PreviousWidget = m_CurrentWidget;
                m_CurrentWidget = m_pMPCreateGameWidget;
                m_pMPCreateGameWidget.RefreshCreateGameMenu();
                m_CurrentWidget.ShowWindow();
                break;
            case UbiComWidgetID:
                m_CurrentWidget.HideWindow();
                m_PreviousWidget = m_CurrentWidget;
                m_CurrentWidget = m_pUbiComWidget;
                m_CurrentWidget.ShowWindow();
                break;
            case OptionsWidgetID:
                if(m_ePrevWidgetInUse == UbiComWidgetID)
                {
                    return;
                }
                m_CurrentWidget.HideWindow();
                m_PreviousWidget = m_CurrentWidget;
                m_CurrentWidget = m_OptionsWidget;
                m_OptionsWidget.RefreshOptions();
                m_CurrentWidget.ShowWindow();
                break;
            default:
                super.ChangeCurrentWidget(widgetID);
                break;
        }
    }
    else
    {
        if(widgetID == TrainingWidgetID)
        {
            widgetID = MainMenuWidgetID;
        }
        super.ChangeCurrentWidget(widgetID);
    }
}
