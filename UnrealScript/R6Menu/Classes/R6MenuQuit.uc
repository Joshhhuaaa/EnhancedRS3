//=============================================================================
//  R6MenuQuit.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/08/12 * Created by Alexandre Dionne
//=============================================================================


class R6MenuQuit extends R6MenuWidget;

var R6WindowButton	        m_ButtonMainMenu;
var R6WindowButton	        m_ButtonQuit;

var R6MenuVideo             m_QuitVideo;

#ifdefSPDEMO
var R6WindowBitMap          m_UbiShop;
var R6WindowButton	        m_BUbiShopUS;
var R6WindowButton	        m_BUbiShopFR;
var R6WindowButton	        m_BUbiShopUK;
var R6WindowButton	        m_BUbiShopGR;

var String                  szUbiShopUSAddress;
var String                  szUbiShopFRAddress;
var String                  szUbiShopUKAddress;
var String                  szUbiShopGRAddress;

var Region                  m_RUSFlag;
var Region                  m_RFRFlag;
var Region                  m_RUKFlag;
var Region                  m_RGRFlag;

var INT                     m_IButWidth, m_IButHeight;
var INT                     m_IYButPos;
var INT                     m_IXFirstButPos, m_IXButOffset;

#endif

function Created()
{
    local   Font    buttonFont;

    buttonFont		= Root.Fonts[F_PrincipalButton];

#ifdefMPDEMO
    m_QuitVideo= R6MenuVideo(CreateWindow(class'R6MenuVideo', 
                                             0,
                                             0,
                                             640,
                                             480, self));
    m_QuitVideo.bAlwaysBehind = true;   
#endif


#ifdefSPDEMO
    szUbiShopUSAddress="http://shopping.ubi.com/gameinfo.php?id=459";
    szUbiShopFRAddress="http://www.digitalriver.com/dr/v2/ec_MAIN.Entry10?V1=482329&PN=1&SP=10023&xid=42207&DSP=&CUR=978&PGRP=0&CACHE_ID=0";
    szUbiShopUKAddress="http://www.digitalriver.com/dr/v2/ec_MAIN.Entry10?V1=487027&PN=1&SP=10023&xid=42206&DSP=&CUR=826&PGRP=0&CACHE_ID=0";
    szUbiShopGRAddress="http://www.digitalriver.com/dr/v2/ec_MAIN.Entry10?V1=489069&PN=1&SP=10023&xid=44205&DSP=&CUR=978&PGRP=0&CACHE_ID=0";

    m_RUSFlag.X=0;   m_RUSFlag.Y=0;   m_RUSFlag.W=250; m_RUSFlag.H=134;
    m_RFRFlag.X=260; m_RFRFlag.Y=146; m_RFRFlag.W=250; m_RFRFlag.H=134;
    m_RUKFlag.X=0;   m_RUKFlag.Y=146; m_RUKFlag.W=250; m_RUKFlag.H=134;
    m_RGRFlag.X=260; m_RGRFlag.Y=0;   m_RGRFlag.W=250; m_RGRFlag.H=134;

    m_IYButPos=291;
    m_IXFirstButPos=170;
    m_IXButOffset=77;
    m_IButWidth=72;
    m_IButHeight=45;

    m_UbiShop                           = R6WindowBitMap(CreateWindow( class'R6WindowBitMap', 170, 62, 299, 224, self));	    
	m_UbiShop.T                         =Texture'R6menuBG.rainbowsix3_Pre_order';
	m_UbiShop.R.x                       = 106;
    m_UbiShop.R.Y                       = 287;
    m_UbiShop.R.W                       = 299;
    m_UbiShop.R.H                       = 224;	
	m_UbiShop.m_iDrawStyle              = 5;


    m_BUbiShopUS                           = R6WindowButton(CreateControl( class'R6WindowButton', m_IXFirstButPos, m_IYButPos, m_IButWidth, m_IButHeight, self));
	m_BUbiShopUS.m_bDrawBorders            = true;
    m_BUbiShopUS.m_bDrawSimpleBorder       = true;
	m_BUbiShopUS.bUseRegion                = true;
    m_BUbiShopUS.bStretched                = true;
	m_BUbiShopUS.DisabledTexture           = Texture'R6menuBG.rainbowsix3_Pre_order'	;
	m_BUbiShopUS.DisabledRegion            = m_RUSFlag;    
	m_BUbiShopUS.DownTexture               = Texture'R6menuBG.rainbowsix3_Pre_order';
    m_BUbiShopUS.DownRegion                = m_RUSFlag;    
    m_BUbiShopUS.OverTexture               = Texture'R6menuBG.rainbowsix3_Pre_order';
    m_BUbiShopUS.OverRegion                = m_RUSFlag;    
	m_BUbiShopUS.UpTexture                 = Texture'R6menuBG.rainbowsix3_Pre_order';
    m_BUbiShopUS.UpRegion                  = m_RUSFlag;
    m_BUbiShopUS.m_BorderColor             = Root.Colors.White;
    
    m_BUbiShopFR                           = R6WindowButton(CreateControl( class'R6WindowButton', m_BUbiShopUS.WinLeft + m_IXButOffset, m_IYButPos, m_IButWidth, m_IButHeight, self));
	m_BUbiShopFR.m_bDrawBorders            = true;
    m_BUbiShopFR.m_bDrawSimpleBorder       = true;
	m_BUbiShopFR.bUseRegion                = true;
    m_BUbiShopFR.bStretched                = true;
	m_BUbiShopFR.DisabledTexture           = Texture'R6menuBG.rainbowsix3_Pre_order'	;
	m_BUbiShopFR.DisabledRegion            = m_RFRFlag;    
	m_BUbiShopFR.DownTexture               = Texture'R6menuBG.rainbowsix3_Pre_order';
    m_BUbiShopFR.DownRegion                = m_RFRFlag;    
    m_BUbiShopFR.OverTexture               = Texture'R6menuBG.rainbowsix3_Pre_order';
    m_BUbiShopFR.OverRegion                = m_RFRFlag;    
	m_BUbiShopFR.UpTexture                 = Texture'R6menuBG.rainbowsix3_Pre_order';
    m_BUbiShopFR.UpRegion                  = m_RFRFlag;
    m_BUbiShopFR.m_BorderColor             = Root.Colors.White;

    m_BUbiShopUK                           = R6WindowButton(CreateControl( class'R6WindowButton', m_BUbiShopFR.WinLeft + m_IXButOffset, m_IYButPos, m_IButWidth, m_IButHeight, self));
	m_BUbiShopUK.m_bDrawBorders            = true;
    m_BUbiShopUK.m_bDrawSimpleBorder       = true;
	m_BUbiShopUK.bUseRegion                = true;
    m_BUbiShopUK.bStretched                = true;
	m_BUbiShopUK.DisabledTexture           = Texture'R6menuBG.rainbowsix3_Pre_order'	;
	m_BUbiShopUK.DisabledRegion            = m_RUKFlag;    
	m_BUbiShopUK.DownTexture               = Texture'R6menuBG.rainbowsix3_Pre_order';
    m_BUbiShopUK.DownRegion                = m_RUKFlag;    
    m_BUbiShopUK.OverTexture               = Texture'R6menuBG.rainbowsix3_Pre_order';
    m_BUbiShopUK.OverRegion                = m_RUKFlag;    
	m_BUbiShopUK.UpTexture                 = Texture'R6menuBG.rainbowsix3_Pre_order';
    m_BUbiShopUK.UpRegion                  = m_RUKFlag;
    m_BUbiShopUK.m_BorderColor             = Root.Colors.White;


    m_BUbiShopGR                           = R6WindowButton(CreateControl( class'R6WindowButton', m_BUbiShopUK.WinLeft + m_IXButOffset, m_IYButPos, m_IButWidth, m_IButHeight, self));
	m_BUbiShopGR.m_bDrawBorders            = true;
    m_BUbiShopGR.m_bDrawSimpleBorder       = true;
	m_BUbiShopGR.bUseRegion                = true;
    m_BUbiShopGR.bStretched                = true;
	m_BUbiShopGR.DisabledTexture           = Texture'R6menuBG.rainbowsix3_Pre_order'	;
	m_BUbiShopGR.DisabledRegion            = m_RGRFlag;    
	m_BUbiShopGR.DownTexture               = Texture'R6menuBG.rainbowsix3_Pre_order';
    m_BUbiShopGR.DownRegion                = m_RGRFlag;    
    m_BUbiShopGR.OverTexture               = Texture'R6menuBG.rainbowsix3_Pre_order';
    m_BUbiShopGR.OverRegion                = m_RGRFlag;    
	m_BUbiShopGR.UpTexture                 = Texture'R6menuBG.rainbowsix3_Pre_order';
    m_BUbiShopGR.UpRegion                  = m_RGRFlag;
    m_BUbiShopGR.m_BorderColor             = Root.Colors.White;





#endif


    m_ButtonMainMenu                    = R6WindowButton(CreateControl( class'R6WindowButton', 10, 425, 250, 25, self));
    m_ButtonMainMenu.ToolTipString      = Localize("Tip","ButtonMainMenu","R6Menu");
	m_ButtonMainMenu.Text               = Localize("SinglePlayer","ButtonMainMenu","R6Menu");	
	m_ButtonMainMenu.Align              = TA_LEFT;	
	m_ButtonMainMenu.m_buttonFont       = buttonFont;
	m_ButtonMainMenu.ResizeToText();
    // If the game was started by the ubi.com client, we cannot allow the player to return to the 
    // main menu since the in game browsers will not work, therefore disable the button.
    if (Root.Console.m_bStartedByGSClient || Root.Console.m_bNonUbiMatchMakingHost)
        m_ButtonMainMenu.bDisabled=TRUE;

	m_ButtonQuit = R6WindowButton(CreateControl( class'R6WindowButton', 10, 450, 250, 25, self));
    m_ButtonQuit.ToolTipString       = Localize("MainMenu","ButtonQuit","R6Menu");
	m_ButtonQuit.Text                = Localize("MainMenu","ButtonQuit","R6Menu");	
	m_ButtonQuit.Align               = TA_LEFT;	
	m_ButtonQuit.m_buttonFont        = buttonFont;
	m_ButtonQuit.ResizeToText();    

    
    

}

function HideWindow()
{
    Super.HideWindow();

#ifdefMPDEMO    
    m_QuitVideo.StopVideo();   
#endif
    
}

function ShowWindow()
{
    Super.ShowWindow();
#ifdefMPDEMO
    m_QuitVideo.PlayVideo( 0,
                           0,
                           "Thx.bik"); 
#endif
}

	
function Notify(UWindowDialogControl C, byte E)
{ 
    if( E == DE_Click )
    {
        switch(C)
        {
        case m_ButtonMainMenu:
            Root.ChangeCurrentWidget(MainMenuWidgetID);
            break;
        case m_ButtonQuit:            
            Root.DoQuitGame();
            break;        
#ifdefSPDEMO
        case m_BUbiShopUS:
            Root.Console.ConsoleCommand("startminimized " @ szUbiShopUSAddress);
            break;
        case m_BUbiShopFR:
            Root.Console.ConsoleCommand("startminimized " @ szUbiShopFRAddress);
            break;
        case m_BUbiShopUK:
            Root.Console.ConsoleCommand("startminimized " @ szUbiShopUKAddress);
            break;
        case m_BUbiShopGR:
            Root.Console.ConsoleCommand("startminimized " @ szUbiShopGRAddress);
            break;
#endif
        }
    }    
}

defaultproperties
{
}
