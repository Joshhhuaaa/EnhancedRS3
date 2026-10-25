class R6MenuMPInGameNavBar extends UWindowDialogClientWindow;

const C_fHEIGHT_HELPTEXTBAR = 20;

var R6MenuMPInGameHelpBar      m_HelpTextBar;



var R6WindowButton              m_SelectTeamButton,m_ServerOptButton, m_KitRestrictionButton, m_GearButton;

var R6WindowButtonBox			m_pPlayerReady;


var Texture                    m_TSelectTeamButton, m_TServerOptButton, m_TKitRestrictionButton, m_TGearButton;

var Region                     m_RSelectTeamButtonUp,	  m_RSelectTeamButtonDown,     m_RSelectTeamButtonDisabled,     m_RSelectTeamButtonOver; 
var Region                     m_RServerOptButtonUp,	  m_RServerOptButtonDown,      m_RServerOptButtonDisabled,      m_RServerOptButtonOver;
var Region                     m_RKitRestrictionButtonUp, m_RKitRestrictionButtonDown, m_RKitRestrictionButtonDisabled, m_RKitRestrictionButtonOver;
var Region                     m_RGearButtonUp,			  m_RGearButtonDown,           m_RGearButtonDisabled,           m_RGearButtonOver;

var FLOAT						m_fPlayerButWidth; // the width of the player button

var INT							m_iXNavBarLoc[4]; // X pos of each nav bar icon
var INT							m_iYNavBarLoc[4]; // Y pos of each nav bar icon


function Created()
{
	local FLOAT fXOffset, fHeight;

	m_HelpTextBar = R6MenuMPInGameHelpBar(CreateWindow(class'R6MenuMPInGameHelpBar', 1, 0, WinWidth - 2, C_fHEIGHT_HELPTEXTBAR, self));
	m_HelpTextBar.m_bUseExternSetTip = true;

    m_SelectTeamButton     = R6WindowButton(CreateControl( class'R6WindowButton', m_iXNavBarLoc[0], m_iYNavBarLoc[0], m_RSelectTeamButtonUp.W, m_RSelectTeamButtonUp.H, self));   
    m_SelectTeamButton.UpTexture          =   m_TSelectTeamButton;
    m_SelectTeamButton.OverTexture        =   m_TSelectTeamButton;
    m_SelectTeamButton.DownTexture        =   m_TSelectTeamButton;
    m_SelectTeamButton.DisabledTexture    =   m_TSelectTeamButton;
    m_SelectTeamButton.UpRegion           =   m_RSelectTeamButtonUp;
    m_SelectTeamButton.DownRegion         =   m_RSelectTeamButtonDown;   
    m_SelectTeamButton.DisabledRegion     =   m_RSelectTeamButtonDisabled;
    m_SelectTeamButton.OverRegion         =   m_RSelectTeamButtonOver;    
    m_SelectTeamButton.bUseRegion         =   true;
    m_SelectTeamButton.ToolTipString      =   Localize("MPInGame","SelectTeam","R6Menu");
    m_SelectTeamButton.m_iDrawStyle       =   5; //Alpha

    m_ServerOptButton    = R6WindowButton(CreateControl( class'R6WindowButton', m_iXNavBarLoc[1], m_iYNavBarLoc[1], m_RServerOptButtonUp.W, m_RServerOptButtonUp.H, self));
    m_ServerOptButton.UpTexture          =   m_TServerOptButton;
    m_ServerOptButton.OverTexture        =   m_TServerOptButton;
    m_ServerOptButton.DownTexture        =   m_TServerOptButton;
    m_ServerOptButton.DisabledTexture    =   m_TServerOptButton;
    m_ServerOptButton.UpRegion           =   m_RServerOptButtonUp;
    m_ServerOptButton.OverRegion         =   m_RServerOptButtonOver;    
    m_ServerOptButton.DownRegion         =   m_RServerOptButtonDown;   
    m_ServerOptButton.DisabledRegion     =   m_RServerOptButtonDisabled;    
    m_ServerOptButton.bUseRegion         =   true;
    m_ServerOptButton.ToolTipString      =   Localize("Tip","ServerOpt","R6Menu");
    m_ServerOptButton.m_iDrawStyle       =   5; //Alpha
	
	m_KitRestrictionButton        = R6WindowButton(CreateControl( class'R6WindowButton', m_iXNavBarLoc[2], m_iYNavBarLoc[2], m_RKitRestrictionButtonUp.W, m_RKitRestrictionButtonUp.H, self));
    m_KitRestrictionButton.UpTexture          =   m_TKitRestrictionButton;
    m_KitRestrictionButton.OverTexture        =   m_TKitRestrictionButton;
    m_KitRestrictionButton.DownTexture        =   m_TKitRestrictionButton;
    m_KitRestrictionButton.DisabledTexture    =   m_TKitRestrictionButton;   
    m_KitRestrictionButton.UpRegion           =   m_RKitRestrictionButtonUp;
    m_KitRestrictionButton.OverRegion         =   m_RKitRestrictionButtonOver;    
    m_KitRestrictionButton.DownRegion         =   m_RKitRestrictionButtonDown;   
    m_KitRestrictionButton.DisabledRegion     =   m_RKitRestrictionButtonDisabled;    
    m_KitRestrictionButton.bUseRegion         =   true;
    m_KitRestrictionButton.ToolTipString      =   Localize("Tip","KitRestriction","R6Menu");
    m_KitRestrictionButton.m_iDrawStyle       =   5; //Alpha    

	m_GearButton       = R6WindowButton(CreateControl( class'R6WindowButton', m_iXNavBarLoc[3], m_iYNavBarLoc[3], m_RGearButtonUp.W, m_RGearButtonUp.H, self));
    m_GearButton.UpTexture          =   m_TGearButton;
    m_GearButton.OverTexture        =   m_TGearButton;
    m_GearButton.DownTexture        =   m_TGearButton;
    m_GearButton.DisabledTexture    =   m_TGearButton;        
    m_GearButton.UpRegion           =   m_RGearButtonUp;
    m_GearButton.OverRegion         =   m_RGearButtonOver;    
    m_GearButton.DownRegion         =   m_RGearButtonDown;   
    m_GearButton.DisabledRegion     =   m_RGearButtonDisabled;    
    m_GearButton.bUseRegion         =   true;
    m_GearButton.ToolTipString      =   Localize("Tip","Gear","R6Menu");
    m_GearButton.m_iDrawStyle       =   5; //Alpha

	// create player ready button
	fXOffset = m_iXNavBarLoc[3] + m_RGearButtonUp.W + 30;
	fHeight  = 15;
    m_pPlayerReady = R6WindowButtonBox(CreateControl(class'R6WindowButtonBox', fXOffset, 30, 80, fHeight, self));
    m_pPlayerReady.m_TextFont = Root.Fonts[F_SmallTitle];
    m_pPlayerReady.m_vTextColor = Root.Colors.White;
    m_pPlayerReady.m_vBorder = Root.Colors.White;
    m_pPlayerReady.m_eButtonType = BBT_Normal;
    m_pPlayerReady.CreateTextAndBox( Localize("MPInGame","PlayerReady","R6Menu"), 
                                     Localize("Tip","PlayerReady","R6Menu"), 0, 0);
    m_pPlayerReady.bDisabled = true;
	m_pPlayerReady.m_bResizeToText = true;

    m_BorderColor = Root.Colors.BlueLight;

	AlignButtons();
}

function BeforePaint(Canvas C, FLOAT X, FLOAT Y)
{
	if (m_fPlayerButWidth != m_pPlayerReady.WinWidth)
	{
		if (m_SelectTeamButton != None)
			m_SelectTeamButton.m_bPreCalculatePos = true;

		if (m_ServerOptButton != None)
			m_ServerOptButton.m_bPreCalculatePos = true;

		if (m_KitRestrictionButton != None)
			m_KitRestrictionButton.m_bPreCalculatePos = true;

		if (m_GearButton != None)
			m_GearButton.m_bPreCalculatePos = true;

		if (m_pPlayerReady != None)
			m_pPlayerReady.m_bPreCalculatePos = true;

		AlignButtons();

		m_fPlayerButWidth = m_pPlayerReady.WinWidth;
	}

	CheckForNavBarState();
}

function CheckForNavBarState()
{
	local R6MenuInGameMultiPlayerRootWindow R6Root; 

	R6Root = R6MenuInGameMultiPlayerRootWindow(Root);

	if ( (!m_pPlayerReady.bDisabled) &&
		 (R6Root.m_R6GameMenuCom != None) && (R6Root.m_R6GameMenuCom.IsInBetweenRoundMenu()) )
	{
		SetNavBarState( m_pPlayerReady.m_bSelected, true);
	}
}

function AlignButtons()
{
	local FLOAT fFreeSpace, fDistanceBetEachBut;

	fFreeSpace = WinWidth - 4; // 2 pixels each side for border lines
	fFreeSpace -= m_SelectTeamButton.WinWidth + m_ServerOptButton.WinWidth + m_KitRestrictionButton.WinWidth + m_GearButton.WinWidth + m_pPlayerReady.WinWidth;

	if (fFreeSpace > WinWidth)
	{
		fFreeSpace = WinWidth;
	}

	fDistanceBetEachBut = fFreeSpace / 6; // 5 buttons + 1 space --> 1_2_3_4_5_6

	m_SelectTeamButton.WinLeft		= fDistanceBetEachBut;
	m_ServerOptButton.WinLeft		= m_SelectTeamButton.WinLeft + m_SelectTeamButton.WinWidth + fDistanceBetEachBut;
	m_KitRestrictionButton.WinLeft	= m_ServerOptButton.WinLeft + m_ServerOptButton.WinWidth + fDistanceBetEachBut;
	m_GearButton.WinLeft			= m_KitRestrictionButton.WinLeft + m_KitRestrictionButton.WinWidth + fDistanceBetEachBut;
	m_pPlayerReady.WinLeft			= m_GearButton.WinLeft + m_GearButton.WinWidth + fDistanceBetEachBut;
}

function Notify(UWindowDialogControl C, byte E)
{    
	local R6MenuInGameMultiPlayerRootWindow R6Root; 

    if( E == DE_Click )
    {
		R6Root = R6MenuInGameMultiPlayerRootWindow(Root);

        switch(C)
        {
        case m_SelectTeamButton:
			R6Root.m_R6GameMenuCom.SelectTeam();
        	R6Root.ChangeCurrentWidget(InGameMPWID_TeamJoin);   			
            break;
		case m_ServerOptButton:        
			if (R6Root.m_pIntermissionMenuWidget != None)
				R6Root.m_pIntermissionMenuWidget.PopUpServerOptMenu();    			
            break;
        case m_KitRestrictionButton: 
			if (R6Root.m_pIntermissionMenuWidget != None)
				R6Root.m_pIntermissionMenuWidget.PopUpKitRestMenu();		
            break;
		case m_GearButton:		
			if (R6Root.m_pIntermissionMenuWidget != None)
				R6Root.m_pIntermissionMenuWidget.PopUpGearMenu();		
            break;
		case m_pPlayerReady:
			if (R6WindowButtonBox(C).GetSelectStatus())
			{
//				R6WindowButtonBox(C).m_bSelected = !R6WindowButtonBox(C).m_bSelected; // change the boolean state
				R6Root.m_R6GameMenuCom.SetPlayerReadyStatus( !R6WindowButtonBox(C).m_bSelected);
			}			
			break;
		default:
			break;
        }
    }

}


function ToolTip(string strTip) 
{
	m_HelpTextBar.SetToolTip( strTip);
}

function SetNavBarState( BOOL _bDisable, optional BOOL _bDisableAllExceptReadyBut)
{
	m_SelectTeamButton.bDisabled	 = _bDisable;
	m_ServerOptButton.bDisabled		 = _bDisable;
	m_KitRestrictionButton.bDisabled = _bDisable;
	m_GearButton.bDisabled			 = _bDisable;
	if (!_bDisableAllExceptReadyBut)
		m_pPlayerReady.bDisabled		 = _bDisable;
}

function SetNavBarButtonsStatus( BOOL _bDisplay)
{
	if (_bDisplay)
	{
		m_SelectTeamButton.ShowWindow();
		m_ServerOptButton.ShowWindow();
		m_KitRestrictionButton.ShowWindow();
		m_GearButton.ShowWindow();	
		m_pPlayerReady.ShowWindow();
	}
	else
	{
		m_SelectTeamButton.HideWindow();
		m_ServerOptButton.HideWindow();
		m_KitRestrictionButton.HideWindow();
		m_GearButton.HideWindow();	
		m_pPlayerReady.HideWindow();
	}
}

defaultproperties
{
     m_iXNavBarLoc(0)=160
     m_iXNavBarLoc(1)=250
     m_iXNavBarLoc(2)=340
     m_iXNavBarLoc(3)=430
     m_iYNavBarLoc(0)=23
     m_iYNavBarLoc(1)=24
     m_iYNavBarLoc(2)=24
     m_iYNavBarLoc(3)=22
     m_TSelectTeamButton=Texture'R6MenuTextures.Gui_02'
     m_TServerOptButton=Texture'R6MenuTextures.Gui_01'
     m_TKitRestrictionButton=Texture'R6MenuTextures.Gui_02'
     m_TGearButton=Texture'R6MenuTextures.Gui_01'
     m_RSelectTeamButtonUp=(X=39,W=35,H=30)
     m_RSelectTeamButtonDown=(X=39,Y=60,W=35,H=30)
     m_RSelectTeamButtonDisabled=(X=39,Y=90,W=35,H=30)
     m_RSelectTeamButtonOver=(X=39,Y=30,W=35,H=30)
     m_RServerOptButtonUp=(X=186,W=36,H=30)
     m_RServerOptButtonDown=(X=186,Y=60,W=36,H=30)
     m_RServerOptButtonDisabled=(X=186,Y=90,W=36,H=30)
     m_RServerOptButtonOver=(X=186,Y=30,W=36,H=30)
     m_RKitRestrictionButtonUp=(W=38,H=30)
     m_RKitRestrictionButtonDown=(Y=60,W=38,H=30)
     m_RKitRestrictionButtonDisabled=(Y=90,W=38,H=30)
     m_RKitRestrictionButtonOver=(Y=30,W=38,H=30)
     m_RGearButtonUp=(X=223,W=33,H=30)
     m_RGearButtonDown=(X=223,Y=60,W=33,H=30)
     m_RGearButtonDisabled=(X=223,Y=90,W=33,H=30)
     m_RGearButtonOver=(X=223,Y=30,W=33,H=30)
}
