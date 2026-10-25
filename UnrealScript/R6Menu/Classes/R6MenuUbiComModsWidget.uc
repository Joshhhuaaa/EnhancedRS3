class R6MenuUbiComModsWidget extends R6MenuWidget;

// Parameters for option window (where you can change options)
const C_fXSTARTPOS                     = 198;                   // the x start pos of option window

const C_fYSTARTPOS                     = 101;                   // the y start pos of option window

const C_fWINDOWWIDTH                   = 422;                   // the size of option window 

const C_fWINDOWHEIGHT                  = 321;                   // the height of option window 

const C_fHEIGHT_OF_LABELW              = 30;                    // the height of the label window over option window  

var R6WindowTextLabelCurved           m_pOptionsTextLabel;      // the text label of the window option   

var R6WindowTextLabel			      m_LMenuTitle;             // the title

var R6WindowSimpleFramedWindowExt     m_pOptionsBorder;         // the border of the option window

// OPTION MODS
// MPF - Yannick
var R6MenuOptionsMODSExt				m_pListOfMODS;				// the list of MODS

var R6WindowButton                    m_ButtonQuit;

var R6WindowButton m_ButtonReturnUbiCom;

function Created()
{
    m_ButtonQuit = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', 10.0, 425.0, 300.0, 25.0, self));
    m_ButtonQuit.ToolTipString = "";
    m_ButtonQuit.Text = Localize("UbiCom", "ButtonQuit", "R6Menu");
    m_ButtonQuit.Align = TA_Left;
    m_ButtonQuit.m_fFontSpacing = 0.0;
    m_ButtonQuit.m_buttonFont = Root.Fonts[15];
    m_ButtonQuit.m_iButtonID = 1;
    m_ButtonQuit.ResizeToText();
    m_ButtonReturnUbiCom = R6WindowButton(CreateControl(Class'R6Window.R6WindowButton', 10.0, 447.0, 300.0, 25.0, self));
    m_ButtonReturnUbiCom.ToolTipString = "";
    m_ButtonReturnUbiCom.Text = Localize("UbiCom", "ButtonReturn", "R6Menu");
    m_ButtonReturnUbiCom.Align = TA_Left;
    m_ButtonReturnUbiCom.m_fFontSpacing = 0.0;
    m_ButtonReturnUbiCom.m_buttonFont = Root.Fonts[15];
    m_ButtonReturnUbiCom.m_iButtonID = 2;
    m_ButtonReturnUbiCom.ResizeToText();
    m_LMenuTitle = R6WindowTextLabel(CreateWindow(Class'R6Window.R6WindowTextLabel', 0.0, 18.0, WinWidth - float(8), 25.0, self));
    m_LMenuTitle.Text = "CUSTOM MODS";
    m_LMenuTitle.Align = TA_Right;
    m_LMenuTitle.m_Font = Root.Fonts[4];
    m_LMenuTitle.m_BGTexture = none;
    m_LMenuTitle.m_bDrawBorders = false;
    m_pOptionsTextLabel = R6WindowTextLabelCurved(CreateWindow(Class'R6Window.R6WindowTextLabelCurved', 189.0, (92.0 - float(30)) + float(1), 422.0, 30.0, self));
    m_pOptionsTextLabel.bAlwaysBehind = true;
    m_pOptionsTextLabel.Align = TA_Center;
    m_pOptionsTextLabel.m_Font = Root.Fonts[5];
    m_pOptionsTextLabel.SetNewText(Localize("Options", "ButtonCustomGame", "R6Menu"), true);
    m_pOptionsBorder = R6WindowSimpleFramedWindowExt(CreateWindow(Class'R6Window.R6WindowSimpleFramedWindowExt', 189.0, 92.0, 422.0, 321.0, self));
    m_pOptionsBorder.bAlwaysBehind = true;
    m_pOptionsBorder.ActiveBorder(0, false);
    m_pOptionsBorder.SetBorderParam(1, 7.0, 0.0, 1.0, Root.Colors.White);
    m_pOptionsBorder.SetBorderParam(2, 1.0, 1.0, 1.0, Root.Colors.White);
    m_pOptionsBorder.SetBorderParam(3, 1.0, 1.0, 1.0, Root.Colors.White);
    m_pOptionsBorder.m_eCornerType = Bottom_Corners;
    m_pOptionsBorder.SetCornerColor(2, Root.Colors.White);
    m_pOptionsBorder.ActiveBackGround(true, Root.Colors.Black);
    m_pListOfMods = R6MenuOptionsMODSExt(CreateWindow(Class'R6Menu.R6MenuOptionsMODSExt', 189.0 + float(1), 92.0, 422.0 - float(2), 321.0, self));
    m_pListOfMods.InitPageOptions();
}

function Paint(Canvas C, float X, float Y)
{
    Root.PaintBackground(C, self);
}

function ShowWindow()
{
    Root.SetLoadRandomBackgroundImage("ModSelector");
    super(UWindowWindow).ShowWindow();
}

function Notify(UWindowDialogControl C, byte E)
{
    if(C.IsA('R6WindowButton'))
    {
        if(E == DE_Click)
        {
            if(C == m_ButtonQuit)
            {
                Root.DoQuitGame();                
            }
            else
            {
                if(C == m_ButtonReturnUbiCom)
                {
                    class'Actor'.static.GetGameManager().StopGSClientProcedure();
                }
            }
        }
    }
}
