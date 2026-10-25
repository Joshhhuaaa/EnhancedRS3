class R6MenuMPArmor extends UWindowDialogControl;

var R6WindowButtonGear m_2DArmor;

var R6WindowButtonGear m_2DArmorRed;

function Created()
{
    m_2DArmor = R6WindowButtonGear(CreateWindow(Class'R6Window.R6WindowButtonGear', 0.0, 0.0, (WinWidth * 0.5) - float(1), WinHeight, self));
    m_2DArmor.bUseRegion = true;
    m_2DArmor.m_bDrawSimpleBorder = true;
    m_2DArmor.m_iDrawStyle = 5;
    SetArmorBorderColor(m_2DArmor, 9);
    m_2DArmorRed = R6WindowButtonGear(CreateWindow(Class'R6Window.R6WindowButtonGear', WinWidth * 0.5, 0.0, WinWidth * 0.5, WinHeight, self));
    m_2DArmorRed.bUseRegion = true;
    m_2DArmorRed.m_bDrawSimpleBorder = true;
    m_2DArmorRed.m_iDrawStyle = 5;
    SetArmorBorderColor(m_2DArmorRed, 9);
}

function Register(UWindowDialogClientWindow W)
{
    super.Register(W);
    m_2DArmor.Register(W);
    m_2DArmorRed.Register(W);
}

function SetArmorTexture(Texture t, Region R, bool _bRedTeam)
{
    R.X = int(float(R.X) + ((float(119) - m_2DArmor.WinWidth) * 0.5));
    R.W = int(m_2DArmor.WinWidth);
    if(_bRedTeam)
    {
        R.X = R.X + R.W;
        R.W = -R.W;
        m_2DArmorRed.DisabledTexture = t;
        m_2DArmorRed.DisabledRegion = R;
        m_2DArmorRed.DownTexture = t;
        m_2DArmorRed.DownRegion = R;
        m_2DArmorRed.OverTexture = t;
        m_2DArmorRed.OverRegion = R;
        m_2DArmorRed.UpTexture = t;
        m_2DArmorRed.UpRegion = R;        
    }
    else
    {
        m_2DArmor.DisabledTexture = t;
        m_2DArmor.DisabledRegion = R;
        m_2DArmor.DownTexture = t;
        m_2DArmor.DownRegion = R;
        m_2DArmor.OverTexture = t;
        m_2DArmor.OverRegion = R;
        m_2DArmor.UpTexture = t;
        m_2DArmor.UpRegion = R;
    }
}

function SetButtonsStatus(bool _bDisable, bool _bRedTeam)
{
    local Region R;

    if(_bRedTeam)
    {
        m_2DArmorRed.bDisabled = _bDisable;        
    }
    else
    {
        m_2DArmor.bDisabled = _bDisable;
    }
}

function SetHighLightGreenArmor(bool _bHighLight)
{
    m_2DArmor.m_HighLight = _bHighLight;
}

function SetHighLightRedArmor(bool _bHighLight)
{
    m_2DArmorRed.m_HighLight = _bHighLight;
}

function bool IsGreenArmorSelect()
{
    return m_2DArmor.m_HighLight;
}

function bool IsRedArmorSelect()
{
    return m_2DArmorRed.m_HighLight;
}

function SetArmorBorderColor(UWindowDialogControl _ArmorButton, byte E)
{
    if(m_2DArmor == _ArmorButton)
    {
        if(!m_2DArmor.bDisabled)
        {
            if(E == DE_MouseEnter)
            {
                m_2DArmor.m_BorderColor = Root.Colors.TeamColorLight[1];                
            }
            else
            {
                m_2DArmor.m_BorderColor = Root.Colors.TeamColorDark[1];
            }
        }
    }
    if(m_2DArmorRed == _ArmorButton)
    {
        if(!m_2DArmorRed.bDisabled)
        {
            if(E == DE_MouseEnter)
            {
                m_2DArmorRed.m_BorderColor = Root.Colors.TeamColorLight[0];                
            }
            else
            {
                m_2DArmorRed.m_BorderColor = Root.Colors.TeamColorDark[0];
            }
        }
    }
}

function ForceMouseOver(bool _bForceMouseOver)
{
    m_2DArmor.ForceMouseOver(_bForceMouseOver);
}
