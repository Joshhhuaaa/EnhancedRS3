class R6WindowPageSwitch extends UWindowDialogClientWindow;

var R6WindowButton              m_pNextButton;       
var R6WindowButton              m_pPreviousButton;      
var R6WindowTextLabel           m_pPageInfo;  

var INT							m_iTotalPages;
var INT							m_iCurrentPages;

var INT                         m_iButtonWidth;
var INT                         m_iButtonHeight;


function Created()
{
    m_iTotalPages   = 1;
    m_iCurrentPages = 1;

    // Create the two buttons (<<< and >>>) plus the text label in the center
    CreateButtons();

    // Create the text label window
    m_pPageInfo = R6WindowTextLabel(CreateWindow( class'R6WindowTextLabel', m_pPreviousButton.WinLeft + m_pPreviousButton.WinWidth, 
                                                  0, WinWidth - m_pPreviousButton.WinWidth - m_pNextButton.WinWidth, WinHeight, self));
    m_pPageInfo.bAlwaysBehind = true;

    SetTotalPages( m_iTotalPages );
    SetCurrentPage( m_iCurrentPages );
}


//===============================================================
// Set the text label param
//===============================================================
function SetLabelText( string _szText, Font _TextFont, Color _vTextColor)
{
    if (m_pPageInfo != None)
    {        
        m_pPageInfo.m_Font              = _TextFont;
        m_pPageInfo.TextColor           = _vTextColor;
        m_pPageInfo.m_bDrawBorders      = false;
        m_pPageInfo.Align               = TA_Center;
        m_pPageInfo.m_BGTexture         = None;
        m_pPageInfo.SetNewText(_szText, true);
    }
}


//===============================================================
// Create the two buttons (- and +) plus the text label in the center
//===============================================================
function CreateButtons()
{
 
    m_pPreviousButton = R6WindowButton(CreateControl( class'R6WindowButton', 0, 0, m_iButtonWidth, m_iButtonHeight));    
	m_pPreviousButton.m_bDrawBorders        = false;
    m_pPreviousButton.SetButtonBorderColor(Root.Colors.White);
    m_pPreviousButton.TextColor             = Root.Colors.White;
    m_pPreviousButton.m_OverTextColor       = Root.Colors.BlueLight;
    m_pPreviousButton.m_DisabledTextColor   = Root.Colors.Black;
    m_pPreviousButton.Text                  = "<<<";
    m_pPreviousButton.m_buttonFont          = Root.Fonts[F_SmallTitle];
	
	m_pNextButton = R6WindowButton(CreateControl( class'R6WindowButton', WinWidth - m_iButtonWidth, 0, m_iButtonWidth, m_iButtonHeight));    
	m_pNextButton.m_bDrawBorders        = false;
    m_pNextButton.SetButtonBorderColor(Root.Colors.White);
    m_pNextButton.TextColor             = Root.Colors.White;
    m_pNextButton.m_OverTextColor       = Root.Colors.BlueLight; 
    m_pNextButton.m_DisabledTextColor   = Root.Colors.Black;
    m_pNextButton.Text                  = ">>>";
    m_pNextButton.m_buttonFont          = Root.Fonts[F_SmallTitle];

}

//===============================================================
// Set button tool tip string, the same tip for the two button!
//===============================================================
function SetButtonToolTip( string _szLeftToolTip, string _szRightToolTip)
{
    if (m_pNextButton != None)
        m_pNextButton.ToolTipString = _szLeftToolTip;

    if (m_pPreviousButton != None)
        m_pPreviousButton.ToolTipString = _szRightToolTip;
}


//------------------------------------------------------------------
// 
//	
//------------------------------------------------------------------
function SetTotalPages(int iPage)
{
	m_iTotalPages = iPage;

    UpdatePageNb();
}

//------------------------------------------------------------------
// 
//	
//------------------------------------------------------------------
function SetCurrentPage(int iPage)
{
	m_iCurrentPages = iPage;
    
    UpdatePageNb();
}

//------------------------------------------------------------------
// 
//	
//------------------------------------------------------------------
function UpdatePageNb()
{
	local string szText;

    if ( m_iCurrentPages <= 1 )
    {
        m_pPreviousButton.bDisabled = true;
        m_iCurrentPages = 1;
    }
    else if( m_iCurrentPages >= m_iTotalPages)
    {
        m_pPreviousButton.bDisabled = false;        
        m_iCurrentPages = m_iTotalPages;
    }
    else
    {
         m_pPreviousButton.bDisabled = false;
    }

    if ( m_iTotalPages <= 1 )
    {
        m_iTotalPages = 1;
        m_pNextButton.bDisabled = true;
    }
    else if ( m_iCurrentPages == m_iTotalPages ) 
    {
        m_pNextButton.bDisabled = true;
    }
    else
    {
        m_pNextButton.bDisabled = false;
    }

	szText = m_iCurrentPages$ " / "$m_iTotalPages;

    SetLabelText( szText, Root.Fonts[F_SmallTitle], Root.Colors.White);
}


function NextPage()
{
    SetCurrentPage( m_iCurrentPages + 1 );
}

function PreviousPage()
{
    SetCurrentPage( m_iCurrentPages - 1 );
}


//===============================================================
// notify and notify parent if m_bAdviceParent is true
//===============================================================
function Notify(UWindowDialogControl C, byte E)
{
	if(E == DE_Click)
	{	
		switch(C)
		{		
		case m_pNextButton:	            
            //SetCurrentPage(m_iCurrentPages+1);
            if(UWindowDialogClientWindow(OwnerWindow) != None)
                UWindowDialogClientWindow(OwnerWindow).Notify( C, E);
            break;		
		case m_pPreviousButton:
            //SetCurrentPage(m_iCurrentPages-1);
            if( UWindowDialogClientWindow(OwnerWindow) != None)
                UWindowDialogClientWindow(OwnerWindow).Notify( C, E);
            break;
        }			
    }			
}

defaultproperties
{
     m_iButtonWidth=20
     m_iButtonHeight=25
}
