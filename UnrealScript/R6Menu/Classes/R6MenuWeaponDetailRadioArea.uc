//=============================================================================
//  R6MenuWeaponDetailRadioArea.uc : Top buttons that allow us to change from weapon
//                                  stats to the text description
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/02 * Created by Alexandre Dionne
//=============================================================================


class R6MenuWeaponDetailRadioArea extends UWindowDialogClientWindow;

var R6WindowStayDownButton  m_WeaponHistoryButton;
var R6WindowStayDownButton  m_WeaponStatsButton;

var     Region                          m_RHistoryUp,    
                                        m_RHistoryOver,
                                        m_RHistoryDown,                                         

                                        m_RStatsUp,
                                        m_RStatsOver,
                                        m_RStatsDown;

var     FLOAT   m_fButtonTabWidth, m_fButtonTabHeight;
var     FLOAT   m_fFirstButtonOffset;
var     FLOAT   m_fBetweenButtonOffset;

var R6WindowStayDownButton  m_CurrentSelectedButton;


function Created()
{    
 
    local   texture                     ButtonTexture;
    local   FLOAT                       fYPos;
	
       
    ButtonTexture = Texture(DynamicLoadObject("R6MenuTextures.Tab_Icon00", class'Texture'));
    fYPos = WinHeight - m_RHistoryUp.H;

    m_WeaponHistoryButton= R6WindowStayDownButton(CreateControl( class'R6WindowStayDownButton', m_fFirstButtonOffset, fYPos, m_fButtonTabWidth, m_fButtonTabHeight, self)); 
    
    
    m_WeaponHistoryButton.UpRegion        = m_RHistoryUp;    
    m_WeaponHistoryButton.OverRegion      = m_RHistoryOver;
    m_WeaponHistoryButton.DownRegion      = m_RHistoryDown;
    m_WeaponHistoryButton.UpTexture       = ButtonTexture;    
    m_WeaponHistoryButton.OverTexture     = ButtonTexture;        
    m_WeaponHistoryButton.DownTexture     = ButtonTexture;
    m_WeaponHistoryButton.m_iDrawStyle    = 5; //STY_Alpha
    m_WeaponHistoryButton.m_iButtonID     = 0; 
    m_WeaponHistoryButton.ToolTipString      = Localize("GearRoom","WEAPONDESC","R6Menu");
    m_WeaponHistoryButton.m_bCanBeUnselected = false;
    m_WeaponHistoryButton.bUseRegion      = True;

    //Set Current Selected Button
    m_CurrentSelectedButton = m_WeaponHistoryButton;
    m_CurrentSelectedButton.m_bSelected= true;
    
    m_WeaponStatsButton = R6WindowStayDownButton(CreateControl( class'R6WindowStayDownButton', m_WeaponHistoryButton.WinLeft + m_WeaponHistoryButton.WinWidth + m_fBetweenButtonOffset, fYPos, m_fButtonTabWidth, m_fButtonTabHeight, self)); 
    m_WeaponStatsButton.UpRegion        = m_RStatsUp;
    m_WeaponStatsButton.OverRegion      = m_RStatsOver;
    m_WeaponStatsButton.DownRegion      = m_RStatsDown;
    m_WeaponStatsButton.UpTexture       = ButtonTexture;
    m_WeaponStatsButton.OverTexture     = ButtonTexture;   
    m_WeaponStatsButton.DownTexture     = ButtonTexture;
    m_WeaponStatsButton.m_iDrawStyle    = 5; //STY_Alpha
    m_WeaponStatsButton.m_iButtonID     = 1; 
    m_WeaponStatsButton.ToolTipString      = Localize("GearRoom","WEAPONSTATS","R6Menu");
    m_WeaponStatsButton.m_bCanBeUnselected = false;
    m_WeaponStatsButton.bUseRegion      = True;
}


function Notify(UWindowDialogControl C, byte E)
{

	if(E == DE_Click)
	{ 
	   //Change Current Selected Button
        if( (R6WindowStayDownButton(C) != None) && (R6WindowStayDownButton(C) != m_CurrentSelectedButton) )
        {
            m_CurrentSelectedButton.m_bSelected= false;
            m_CurrentSelectedButton = R6WindowStayDownButton(C);
            m_CurrentSelectedButton.m_bSelected= true;

            //Advise Parent window
        
        if( R6MenuEquipmentDetailControl(OwnerWindow) != None)
            R6MenuEquipmentDetailControl(OwnerWindow).ChangePage(m_CurrentSelectedButton.m_iButtonID);	
        } 
    }
}

function AfterPaint(Canvas C, FLOAT X, FLOAT Y)
{
    
   DrawSimpleBorder(C);

}

function ShowWindow()
{
    Super.ShowWindow();
    m_CurrentSelectedButton.m_bSelected= false;
    m_CurrentSelectedButton = m_WeaponStatsButton;//m_WeaponHistoryButton;    
    m_CurrentSelectedButton.m_bSelected= true;
}

defaultproperties
{
     m_fButtonTabWidth=37.000000
     m_fButtonTabHeight=20.000000
     m_fFirstButtonOffset=2.000000
     m_RHistoryUp=(X=114,Y=189,W=37,H=20)
     m_RHistoryOver=(X=114,Y=210,W=37,H=20)
     m_RHistoryDown=(X=114,Y=231,W=37,H=20)
     m_RStatsUp=(Y=63,W=37,H=20)
     m_RStatsOver=(Y=84,W=37,H=20)
     m_RStatsDown=(Y=105,W=37,H=20)
}
