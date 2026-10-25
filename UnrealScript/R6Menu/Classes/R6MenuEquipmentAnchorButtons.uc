//=============================================================================
//  R6MenuEquipmentAnchorButtons.uc : The top buttons needed for quick find a equipment category
//                                    in the list box        
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/09/21 * Created by Alexandre Dionne
//=============================================================================


class R6MenuEquipmentAnchorButtons extends UWindowDialogControl;

////////////////////////////////////////////////////////////////////////////////////
//          Quick equipment find tab buttons 1 by separator
////////////////////////////////////////////////////////////////////////////////////
// Primary Weapons
var     R6WindowListBoxAnchorButton   m_ASSAULTButton;
var     R6WindowListBoxAnchorButton   m_LMGButton;
var     R6WindowListBoxAnchorButton   m_SHOTGUNButton;
var     R6WindowListBoxAnchorButton   m_SNIPERButton;
var     R6WindowListBoxAnchorButton   m_SUBGUNButton;

// Secondary Weapons

var     R6WindowListBoxAnchorButton   m_PISTOLSButton;
var     R6WindowListBoxAnchorButton   m_MACHINEPISTOLSButton;

// Gadgets
var     R6WindowListBoxAnchorButton   m_GRENADESButton;
var     R6WindowListBoxAnchorButton   m_EXPLOSIVESButton;
var     R6WindowListBoxAnchorButton   m_HBDEVICEButton;
var     R6WindowListBoxAnchorButton   m_KITSButton;
var     R6WindowListBoxAnchorButton   m_GENERALButton;

//Button Texture Regions
var     Region                          m_RASSAULTUp,    
                                        m_RASSAULTOver,
                                        m_RASSAULTDown,                                        

                                        m_RLMGUp,
                                        m_RLMGOver,
                                        m_RLMGDown,                                        

                                        m_RSHOTGUNUp,
                                        m_RSHOTGUNOver,
                                        m_RSHOTGUNDown,                                        

                                        m_RSNIPERUp,
                                        m_RSNIPEROver,
                                        m_RSNIPERDown,
                                        
                                        m_RSUBGUNUp,
                                        m_RSUBGUNOver,
                                        m_RSUBGUNDown,

                                        m_RPISTOLSUp,
                                        m_RPISTOLSOver,
                                        m_RPISTOLSDown,

                                        m_RMACHINEPISTOLSUp,
                                        m_RMACHINEPISTOLSOver,
                                        m_RMACHINEPISTOLSDown,

                                        m_RGRENADESUp,
                                        m_RGRENADESOver,
                                        m_RGRENADESDown,

                                        m_REXPLOSIVESUp,
                                        m_REXPLOSIVESOver,
                                        m_REXPLOSIVESDown,

                                        m_RHBDEVICEUp,
                                        m_RHBDEVICEOver,
                                        m_RHBDEVICEDown,
                                        
                                        m_RKITSUp,
                                        m_RKITSOver,
                                        m_RKITSDown,                                        

                                        m_GENERALUp,
                                        m_GENERALOver,
                                        m_GENERALDown;


var     FLOAT   m_fButtonTabWidth, m_fButtonTabHeight;
var     FLOAT   m_fPrimarWTabOffset, m_fPistolOffset, m_fGrenadesOffset;
var     FLOAT   m_fPrimaryBetweenButtonOffset, m_fSecondaryBetweenButtonOffset, m_fGadgetsBetweenButtonOffset;

var     FLOAT   m_fYTopOffset;  //Offset from the top of the control
var     BOOL    m_bDrawBorders;                         


////////////////////////////////////////////////////////////////////////////////////

enum eAnchorEquipmentType
{
    AET_Primary,
    AET_Secondary,
    AET_Gadget,
    AET_None
};



function Created()
{
    

    m_fYTopOffset = WinHeight - m_fButtonTabHeight;

    // Primary Weapons
    m_SUBGUNButton  = R6WindowListBoxAnchorButton(CreateWindow(class'R6WindowListBoxAnchorButton', 
                    m_fPrimarWTabOffset, 
                    m_fYTopOffset, 
                    m_fButtonTabWidth, 
                    m_fButtonTabHeight, 
                    self));
    m_ASSAULTButton = R6WindowListBoxAnchorButton(CreateWindow(class'R6WindowListBoxAnchorButton', 
                    m_SUBGUNButton.WinLeft + m_SUBGUNButton.WinWidth + m_fPrimaryBetweenButtonOffset, 
                    m_fYTopOffset, 
                    m_fButtonTabWidth, 
                    m_fButtonTabHeight, 
                    self));
    m_SHOTGUNButton = R6WindowListBoxAnchorButton(CreateWindow(class'R6WindowListBoxAnchorButton', 
                    m_ASSAULTButton.WinLeft + m_ASSAULTButton.WinWidth + m_fPrimaryBetweenButtonOffset, 
                    m_fYTopOffset, 
                    m_fButtonTabWidth, 
                    m_fButtonTabHeight, 
                    self));
    m_SNIPERButton  = R6WindowListBoxAnchorButton(CreateWindow(class'R6WindowListBoxAnchorButton', 
                    m_SHOTGUNButton.WinLeft + m_SHOTGUNButton.WinWidth + m_fPrimaryBetweenButtonOffset, 
                    m_fYTopOffset, 
                    m_fButtonTabWidth, 
                    m_fButtonTabHeight, 
                    self));
    m_LMGButton     = R6WindowListBoxAnchorButton(CreateWindow(class'R6WindowListBoxAnchorButton', 
                    m_SNIPERButton.WinLeft + m_SNIPERButton.WinWidth + m_fPrimaryBetweenButtonOffset, 
                    m_fYTopOffset, 
                    m_fButtonTabWidth, 
                    m_fButtonTabHeight, 
                    self));

    // Secondary Weapons
    m_PISTOLSButton = R6WindowListBoxAnchorButton(CreateWindow(class'R6WindowListBoxAnchorButton', 
                    m_fPistolOffset, 
                    m_fYTopOffset, 
                    m_fButtonTabWidth, 
                    m_fButtonTabHeight, 
                    self));

    m_MACHINEPISTOLSButton 
                    = R6WindowListBoxAnchorButton(CreateWindow(class'R6WindowListBoxAnchorButton', 
                    m_PISTOLSButton.WinLeft + m_PISTOLSButton.WinWidth + m_fSecondaryBetweenButtonOffset,
                    m_fYTopOffset, 
                    m_fButtonTabWidth, 
                    m_fButtonTabHeight, 
                    self));
    // Gadgets      
    m_GRENADESButton
                    = R6WindowListBoxAnchorButton(CreateWindow(class'R6WindowListBoxAnchorButton', 
                    m_fGrenadesOffset, 
                    m_fYTopOffset, 
                    m_fButtonTabWidth, 
                    m_fButtonTabHeight, 
                    self));
    m_EXPLOSIVESButton
                    = R6WindowListBoxAnchorButton(CreateWindow(class'R6WindowListBoxAnchorButton', 
                    m_GRENADESButton.WinLeft + m_GRENADESButton.WinWidth + m_fGadgetsBetweenButtonOffset, 
                    m_fYTopOffset, 
                    m_fButtonTabWidth, 
                    m_fButtonTabHeight, 
                    self));
    m_HBDEVICEButton
                    = R6WindowListBoxAnchorButton(CreateWindow(class'R6WindowListBoxAnchorButton', 
                    m_EXPLOSIVESButton.WinLeft + m_EXPLOSIVESButton.WinWidth + m_fGadgetsBetweenButtonOffset, 
                    m_fYTopOffset, 
                    m_fButtonTabWidth, 
                    m_fButtonTabHeight, 
                    self));
    m_KITSButton    = R6WindowListBoxAnchorButton(CreateWindow(class'R6WindowListBoxAnchorButton', 
                    m_HBDEVICEButton.WinLeft + m_HBDEVICEButton.WinWidth + m_fGadgetsBetweenButtonOffset, 
                    m_fYTopOffset, 
                    m_fButtonTabWidth, 
                    m_fButtonTabHeight, 
                    self));
    m_GENERALButton = R6WindowListBoxAnchorButton(CreateWindow(class'R6WindowListBoxAnchorButton', 
                    m_KITSButton.WinLeft + m_KITSButton.WinWidth + m_fGadgetsBetweenButtonOffset, 
                    m_fYTopOffset, 
                    m_fButtonTabWidth, 
                    m_fButtonTabHeight, 
                    self));

    m_ASSAULTButton.ToolTipString        = Localize("Tip","GearRoomButAssaultRif","R6Menu");
    m_LMGButton.ToolTipString            = Localize("Tip","GearRoomButLightMach","R6Menu"); 
    m_SHOTGUNButton.ToolTipString        = Localize("Tip","GearRoomButShotGun","R6Menu"); 
    m_SNIPERButton.ToolTipString         = Localize("Tip","GearRoomButSniperRif","R6Menu"); 
    m_SUBGUNButton.ToolTipString         = Localize("Tip","GearRoomButSubMach","R6Menu"); 
    m_PISTOLSButton.ToolTipString        = Localize("Tip","GearRoomButPistols","R6Menu"); 
    m_MACHINEPISTOLSButton.ToolTipString = Localize("Tip","GearRoomButMPistols","R6Menu"); 
    m_GRENADESButton.ToolTipString       = Localize("Tip","GearRoomButGrenade","R6Menu"); 
    m_EXPLOSIVESButton.ToolTipString     = Localize("Tip","GearRoomButExplosive","R6Menu"); 
    m_HBDEVICEButton.ToolTipString       = Localize("Tip","GearRoomButHeartB","R6Menu"); 
    m_KITSButton.ToolTipString           = Localize("Tip","GearRoomButKits","R6Menu"); 
    m_GENERALButton.ToolTipString        = Localize("Tip","GearRoomButOthers","R6Menu");

    m_ASSAULTButton.UpRegion            =m_RASSAULTUp; 
    m_ASSAULTButton.OverRegion          =m_RASSAULTOver; 
    m_ASSAULTButton.DownRegion          =m_RASSAULTDown; 

    m_LMGButton.UpRegion                =m_RLMGUp; 
    m_LMGButton.OverRegion              =m_RLMGOver; 
    m_LMGButton.DownRegion              =m_RLMGDown; 

    m_SHOTGUNButton.UpRegion            =m_RSHOTGUNUp; 
    m_SHOTGUNButton.OverRegion          =m_RSHOTGUNOver; 
    m_SHOTGUNButton.DownRegion          =m_RSHOTGUNDown; 

    m_SNIPERButton.UpRegion             =m_RSNIPERUp; 
    m_SNIPERButton.OverRegion           =m_RSNIPEROver; 
    m_SNIPERButton.DownRegion           =m_RSNIPERDown; 

    m_SUBGUNButton.UpRegion             =m_RSUBGUNUp; 
    m_SUBGUNButton.OverRegion           =m_RSUBGUNOver; 
    m_SUBGUNButton.DownRegion           =m_RSUBGUNDown; 

    m_PISTOLSButton.UpRegion            =m_RPISTOLSUp; 
    m_PISTOLSButton.OverRegion          =m_RPISTOLSOver; 
    m_PISTOLSButton.DownRegion          =m_RPISTOLSDown; 

    m_MACHINEPISTOLSButton.UpRegion     =m_RMACHINEPISTOLSUp; 
    m_MACHINEPISTOLSButton.OverRegion   =m_RMACHINEPISTOLSOver; 
    m_MACHINEPISTOLSButton.DownRegion   =m_RMACHINEPISTOLSDown; 

    m_GRENADESButton.UpRegion           =m_RGRENADESUp; 
    m_GRENADESButton.OverRegion         =m_RGRENADESOver; 
    m_GRENADESButton.DownRegion         =m_RGRENADESDown; 

    m_EXPLOSIVESButton.UpRegion         =m_REXPLOSIVESUp; 
    m_EXPLOSIVESButton.OverRegion       =m_REXPLOSIVESOver; 
    m_EXPLOSIVESButton.DownRegion       =m_REXPLOSIVESDown; 

    m_HBDEVICEButton.UpRegion           =m_RHBDEVICEUp; 
    m_HBDEVICEButton.OverRegion         =m_RHBDEVICEOver; 
    m_HBDEVICEButton.DownRegion         =m_RHBDEVICEDown; 

    m_KITSButton.UpRegion               =m_RKITSUp; 
    m_KITSButton.OverRegion             =m_RKITSOver; 
    m_KITSButton.DownRegion             =m_RKITSDown; 

    m_GENERALButton.UpRegion            =m_GENERALUp; 
    m_GENERALButton.OverRegion          =m_GENERALOver; 
    m_GENERALButton.DownRegion          =m_GENERALDown; 


    m_ASSAULTButton.m_iDrawStyle        =5; //STY_Alpha
    m_LMGButton.m_iDrawStyle            =5; 
    m_SHOTGUNButton.m_iDrawStyle        =5; 
    m_SNIPERButton.m_iDrawStyle         =5; 
    m_SUBGUNButton.m_iDrawStyle         =5; 
    m_PISTOLSButton.m_iDrawStyle        =5; 
    m_MACHINEPISTOLSButton.m_iDrawStyle =5; 
    m_GRENADESButton.m_iDrawStyle       =5; 
    m_EXPLOSIVESButton.m_iDrawStyle     =5; 
    m_HBDEVICEButton.m_iDrawStyle       =5; 
    m_KITSButton.m_iDrawStyle           =5; 
    m_GENERALButton.m_iDrawStyle        =5; 

    DisplayButtons(AET_Primary);

    m_BorderColor = Root.Colors.White;

}

function DisplayButtons(eAnchorEquipmentType _Equipment)
{
    switch(_Equipment)
    {
    case AET_Primary:            
            m_ASSAULTButton.ShowWindow();
            m_LMGButton.ShowWindow();
            m_SHOTGUNButton.ShowWindow();
            m_SNIPERButton.ShowWindow();
            m_SUBGUNButton.ShowWindow();

            m_PISTOLSButton.HideWindow();
            m_MACHINEPISTOLSButton.HideWindow();
            m_GRENADESButton.HideWindow();
            m_EXPLOSIVESButton.HideWindow();
            m_HBDEVICEButton.HideWindow();
            m_KITSButton.HideWindow();
            m_GENERALButton.HideWindow();

        break;
    case AET_Secondary:            
            m_ASSAULTButton.HideWindow();
            m_LMGButton.HideWindow();
            m_SHOTGUNButton.HideWindow();
            m_SNIPERButton.HideWindow();
            m_SUBGUNButton.HideWindow();

            m_PISTOLSButton.ShowWindow();
            m_MACHINEPISTOLSButton.ShowWindow();

            m_GRENADESButton.HideWindow();
            m_EXPLOSIVESButton.HideWindow();
            m_HBDEVICEButton.HideWindow();
            m_KITSButton.HideWindow();
            m_GENERALButton.HideWindow();
        break;
    case AET_Gadget:            
            m_ASSAULTButton.HideWindow();
            m_LMGButton.HideWindow();
            m_SHOTGUNButton.HideWindow();
            m_SNIPERButton.HideWindow();
            m_SUBGUNButton.HideWindow();
            m_PISTOLSButton.HideWindow();
            m_MACHINEPISTOLSButton.HideWindow();

            m_GRENADESButton.ShowWindow();
            m_EXPLOSIVESButton.ShowWindow();
            m_HBDEVICEButton.ShowWindow();
            m_KITSButton.ShowWindow();
            m_GENERALButton.ShowWindow();
        break;    
    
    }


}

function Register(UWindowDialogClientWindow	W)
{    
	Super.Register(W);

    m_ASSAULTButton.Register(W);
    m_LMGButton.Register(W);
    m_SHOTGUNButton.Register(W);
    m_SNIPERButton.Register(W);
    m_SUBGUNButton.Register(W);

    m_PISTOLSButton.Register(W);
    m_MACHINEPISTOLSButton.Register(W);
    
    
    m_GRENADESButton.Register(W);
    m_EXPLOSIVESButton.Register(W);
    m_HBDEVICEButton.Register(W);
    m_KITSButton.Register(W);
    m_GENERALButton.Register(W);
    
}

function Resize()
{
    
    m_fYTopOffset = WinHeight - m_fButtonTabHeight;

        // Primary Weapons
    m_SUBGUNButton.WinLeft  = m_fPrimarWTabOffset;
    m_SUBGUNButton.WinTop   = m_fYTopOffset;
    m_SUBGUNButton.WinWidth = m_fButtonTabWidth;
    m_SUBGUNButton.WinHeight = m_fButtonTabHeight;

    m_ASSAULTButton.WinLeft     = m_SUBGUNButton.WinLeft + m_SUBGUNButton.WinWidth + m_fPrimaryBetweenButtonOffset;
    m_ASSAULTButton.WinTop      = m_fYTopOffset;
    m_ASSAULTButton.WinWidth    = m_fButtonTabWidth;
    m_ASSAULTButton.WinHeight    = m_fButtonTabHeight;
                    
    m_SHOTGUNButton.WinLeft = m_ASSAULTButton.WinLeft + m_ASSAULTButton.WinWidth + m_fPrimaryBetweenButtonOffset; 
    m_SHOTGUNButton.WinTop = m_fYTopOffset;
    m_SHOTGUNButton.WinWidth = m_fButtonTabWidth;
    m_SHOTGUNButton.WinHeight = m_fButtonTabHeight;
    
    m_SNIPERButton.WinLeft  = m_SHOTGUNButton.WinLeft + m_SHOTGUNButton.WinWidth + m_fPrimaryBetweenButtonOffset;
    m_SNIPERButton.WinTop  = m_fYTopOffset;
    m_SNIPERButton.WinWidth  = m_fButtonTabWidth;
    m_SNIPERButton.WinHeight  = m_fButtonTabHeight;
    
    m_LMGButton.WinLeft     = m_SNIPERButton.WinLeft + m_SNIPERButton.WinWidth + m_fPrimaryBetweenButtonOffset;
    m_LMGButton.WinTop     = m_fYTopOffset;
    m_LMGButton.WinWidth     = m_fButtonTabWidth;
    m_LMGButton.WinHeight     = m_fButtonTabHeight;
    

    // Secondary Weapons
    m_PISTOLSButton.WinLeft = m_fPistolOffset;
    m_PISTOLSButton.WinTop = m_fYTopOffset;
    m_PISTOLSButton.WinWidth = m_fButtonTabWidth;
    m_PISTOLSButton.WinHeight = m_fButtonTabHeight;
    

    m_MACHINEPISTOLSButton.WinLeft = m_PISTOLSButton.WinLeft + m_PISTOLSButton.WinWidth + m_fSecondaryBetweenButtonOffset;
    m_MACHINEPISTOLSButton.WinTop = m_fYTopOffset;
    m_MACHINEPISTOLSButton.WinWidth = m_fButtonTabWidth;
    m_MACHINEPISTOLSButton.WinHeight = m_fButtonTabHeight;
    
    // Gadgets      
    m_GRENADESButton.WinLeft = m_fGrenadesOffset;
    m_GRENADESButton.WinTop = m_fYTopOffset;
    m_GRENADESButton.WinWidth = m_fButtonTabWidth;
    m_GRENADESButton.WinHeight = m_fButtonTabHeight;

    m_EXPLOSIVESButton.WinLeft = m_GRENADESButton.WinLeft + m_GRENADESButton.WinWidth + m_fGadgetsBetweenButtonOffset; 
    m_EXPLOSIVESButton.WinTop = m_fYTopOffset;
    m_EXPLOSIVESButton.WinWidth = m_fButtonTabWidth;
    m_EXPLOSIVESButton.WinHeight = m_fButtonTabHeight;

    m_HBDEVICEButton.WinLeft = m_EXPLOSIVESButton.WinLeft + m_EXPLOSIVESButton.WinWidth + m_fGadgetsBetweenButtonOffset;
    m_HBDEVICEButton.WinTop = m_fYTopOffset; 
    m_HBDEVICEButton.WinWidth = m_fButtonTabWidth;
    m_HBDEVICEButton.WinHeight = m_fButtonTabHeight;
        
    m_KITSButton.WinLeft =  m_HBDEVICEButton.WinLeft + m_HBDEVICEButton.WinWidth + m_fGadgetsBetweenButtonOffset;
    m_KITSButton.WinTop =  m_fYTopOffset;
    m_KITSButton.WinWidth =  m_fButtonTabWidth;
    m_KITSButton.WinHeight =  m_fButtonTabHeight;
                    
    m_GENERALButton.WinLeft     = m_KITSButton.WinLeft + m_KITSButton.WinWidth + m_fGadgetsBetweenButtonOffset;
    m_GENERALButton.WinTop      = m_fYTopOffset;
    m_GENERALButton.WinWidth    = m_fButtonTabWidth;
    m_GENERALButton.WinHeight    = m_fButtonTabHeight;
                    
}

function AfterPaint(Canvas C, FLOAT X, FLOAT Y)
{
    if(m_bDrawBorders)
        DrawSimpleBorder(C);
}

defaultproperties
{
     m_bDrawBorders=True
     m_fButtonTabWidth=37.000000
     m_fButtonTabHeight=20.000000
     m_fPrimarWTabOffset=2.000000
     m_fPistolOffset=2.000000
     m_fGrenadesOffset=2.000000
     m_RASSAULTUp=(X=114,Y=63,W=37,H=20)
     m_RASSAULTOver=(X=114,Y=84,W=37,H=20)
     m_RASSAULTDown=(X=114,Y=105,W=37,H=20)
     m_RLMGUp=(X=152,Y=63,W=37,H=20)
     m_RLMGOver=(X=152,Y=84,W=37,H=20)
     m_RLMGDown=(X=152,Y=105,W=37,H=20)
     m_RSHOTGUNUp=(Y=126,W=37,H=20)
     m_RSHOTGUNOver=(Y=147,W=37,H=20)
     m_RSHOTGUNDown=(Y=168,W=37,H=20)
     m_RSNIPERUp=(X=38,Y=126,W=37,H=20)
     m_RSNIPEROver=(X=38,Y=147,W=37,H=20)
     m_RSNIPERDown=(X=38,Y=168,W=37,H=20)
     m_RSUBGUNUp=(X=76,Y=126,W=37,H=20)
     m_RSUBGUNOver=(X=76,Y=147,W=37,H=20)
     m_RSUBGUNDown=(X=76,Y=168,W=37,H=20)
     m_RPISTOLSUp=(X=190,Y=63,W=37,H=20)
     m_RPISTOLSOver=(X=190,Y=84,W=37,H=20)
     m_RPISTOLSDown=(X=190,Y=105,W=37,H=20)
     m_RMACHINEPISTOLSUp=(X=114,Y=126,W=37,H=20)
     m_RMACHINEPISTOLSOver=(X=114,Y=147,W=37,H=20)
     m_RMACHINEPISTOLSDown=(X=114,Y=168,W=37,H=20)
     m_RGRENADESUp=(X=152,Y=126,W=37,H=20)
     m_RGRENADESOver=(X=152,Y=147,W=37,H=20)
     m_RGRENADESDown=(X=152,Y=168,W=37,H=20)
     m_REXPLOSIVESUp=(X=190,Y=126,W=37,H=20)
     m_REXPLOSIVESOver=(X=190,Y=147,W=37,H=20)
     m_REXPLOSIVESDown=(X=190,Y=168,W=37,H=20)
     m_RHBDEVICEUp=(Y=189,W=37,H=20)
     m_RHBDEVICEOver=(Y=210,W=37,H=20)
     m_RHBDEVICEDown=(Y=231,W=37,H=20)
     m_RKITSUp=(X=38,Y=189,W=37,H=20)
     m_RKITSOver=(X=38,Y=210,W=37,H=20)
     m_RKITSDown=(X=38,Y=231,W=37,H=20)
     m_GENERALUp=(X=76,Y=189,W=37,H=20)
     m_GENERALOver=(X=76,Y=210,W=37,H=20)
     m_GENERALDown=(X=76,Y=231,W=37,H=20)
}
