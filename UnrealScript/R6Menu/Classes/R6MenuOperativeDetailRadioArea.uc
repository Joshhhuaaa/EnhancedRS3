//=============================================================================
//  R6MenuOperativeDetailRadioArea.uc : This is the top part of R6WindowOperativeDetailControl
//                                         
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/15 * Created by Alexandre Dionne
//=============================================================================


class R6MenuOperativeDetailRadioArea extends UWindowDialogClientWindow;

var R6WindowStayDownButton  m_OperativeHistoryButton;
var R6WindowStayDownButton  m_OperativeSkillsButton;
var R6WindowStayDownButton  m_OperativeBioButton;
var R6WindowStayDownButton  m_OperativeStatsButton;

var     Region                          m_RHistoryUp,    
                                        m_RHistoryOver,
                                        m_RHistoryDown,                                        

                                        m_RSkillsUp,
                                        m_RSkillsOver,
                                        m_RSkillsDown,                                        

                                        m_RBioUp,
                                        m_RBioOver,
                                        m_RBioDown,                                        

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
    local   INT                         YPos;
   
    ButtonTexture = Texture(DynamicLoadObject("R6MenuTextures.Tab_Icon00", class'Texture'));

    YPos = WinHeight - m_fButtonTabHeight;

    m_OperativeHistoryButton= R6WindowStayDownButton(CreateControl( class'R6WindowStayDownButton', m_fFirstButtonOffset, YPos, m_fButtonTabWidth, m_fButtonTabHeight, self)); 
	m_OperativeHistoryButton.ToolTipString	 = Localize("Tip","GearRoomButHistory","R6Menu"); 
    m_OperativeHistoryButton.UpRegion        = m_RHistoryUp;   
    m_OperativeHistoryButton.OverRegion      = m_RHistoryOver;  
    m_OperativeHistoryButton.DownRegion      = m_RHistoryDown;   
    m_OperativeHistoryButton.UpTexture       = ButtonTexture;    
    m_OperativeHistoryButton.OverTexture     = ButtonTexture;    
    m_OperativeHistoryButton.DownTexture     = ButtonTexture;
    m_OperativeHistoryButton.m_iDrawStyle    = 5; //STY_Alpha
    m_OperativeHistoryButton.m_iButtonID     = 1; 
    m_OperativeHistoryButton.m_bCanBeUnselected = false;
    m_OperativeHistoryButton.bUseRegion      = True;

    m_OperativeSkillsButton = R6WindowStayDownButton(CreateControl( class'R6WindowStayDownButton', m_OperativeHistoryButton.WinLeft + m_OperativeHistoryButton.WinWidth + m_fBetweenButtonOffset, YPos, m_fButtonTabWidth, m_fButtonTabHeight, self)); 
	m_OperativeSkillsButton.ToolTipString	= Localize("Tip","GearRoomButSkills","R6Menu");
    m_OperativeSkillsButton.UpRegion        = m_RSkillsUp;   
    m_OperativeSkillsButton.OverRegion      = m_RSkillsOver;
    m_OperativeSkillsButton.DownRegion      = m_RSkillsDown;       
    m_OperativeSkillsButton.UpTexture       = ButtonTexture;    
    m_OperativeSkillsButton.OverTexture     = ButtonTexture;
    m_OperativeSkillsButton.DownTexture     = ButtonTexture;
    m_OperativeSkillsButton.m_iDrawStyle    = 5; //STY_Alpha
    m_OperativeSkillsButton.m_iButtonID     = 2; 
    m_OperativeSkillsButton.m_bCanBeUnselected = false;
    m_OperativeSkillsButton.bUseRegion      = True;


    m_OperativeBioButton    = R6WindowStayDownButton(CreateControl( class'R6WindowStayDownButton', m_OperativeSkillsButton.WinLeft + m_OperativeSkillsButton.WinWidth + m_fBetweenButtonOffset, YPos, m_fButtonTabWidth, m_fButtonTabHeight, self)); 
	m_OperativeBioButton.ToolTipString		= Localize("Tip","GearRoomButMedic","R6Menu");
    m_OperativeBioButton.UpRegion           = m_RBioUp;
    m_OperativeBioButton.OverRegion         = m_RBioOver;
    m_OperativeBioButton.DownRegion         = m_RBioDown;
    m_OperativeBioButton.UpTexture          = ButtonTexture;
    m_OperativeBioButton.OverTexture        = ButtonTexture;  
    m_OperativeBioButton.DownTexture        = ButtonTexture;
    m_OperativeBioButton.m_iDrawStyle       = 5; //STY_Alpha
    m_OperativeBioButton.m_iButtonID        = 3; 
    m_OperativeBioButton.m_bCanBeUnselected = false;
    m_OperativeBioButton.bUseRegion         = True;

    m_OperativeStatsButton  = R6WindowStayDownButton(CreateControl( class'R6WindowStayDownButton', m_OperativeBioButton.WinLeft + m_OperativeBioButton.WinWidth + m_fBetweenButtonOffset, YPos, m_fButtonTabWidth, m_fButtonTabHeight, self));     
	m_OperativeStatsButton.ToolTipString  = Localize("Tip","GearRoomButCampStats","R6Menu");
    m_OperativeStatsButton.UpRegion       = m_RStatsUp;
    m_OperativeStatsButton.OverRegion     = m_RStatsOver;
    m_OperativeStatsButton.DownRegion     = m_RStatsDown;
    m_OperativeStatsButton.UpTexture      = ButtonTexture;
    m_OperativeStatsButton.OverTexture    = ButtonTexture;
    m_OperativeStatsButton.DownTexture    = ButtonTexture;
    m_OperativeStatsButton.m_iDrawStyle   = 5; //STY_Alpha
    m_OperativeStatsButton.m_iButtonID    = 4;
    m_OperativeStatsButton.m_bCanBeUnselected = false; 
    m_OperativeStatsButton.bUseRegion      = True;

    //Set Current Selected Button
    m_CurrentSelectedButton = m_OperativeSkillsButton;
    m_CurrentSelectedButton.m_bSelected= true;
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
        
        if( R6MenuOperativeDetailControl(OwnerWindow) != None)
            R6MenuOperativeDetailControl(OwnerWindow).ChangePage(m_CurrentSelectedButton.m_iButtonID);	
        }            
    }
}

defaultproperties
{
     m_fButtonTabWidth=37.000000
     m_fButtonTabHeight=20.000000
     m_fFirstButtonOffset=2.000000
     m_RHistoryUp=(X=190,W=37,H=20)
     m_RHistoryOver=(X=190,Y=21,W=37,H=20)
     m_RHistoryDown=(X=190,Y=42,W=37,H=20)
     m_RSkillsUp=(Y=63,W=37,H=20)
     m_RSkillsOver=(Y=84,W=37,H=20)
     m_RSkillsDown=(Y=105,W=37,H=20)
     m_RBioUp=(X=38,Y=63,W=37,H=20)
     m_RBioOver=(X=38,Y=84,W=37,H=20)
     m_RBioDown=(X=38,Y=105,W=37,H=20)
     m_RStatsUp=(X=76,Y=63,W=37,H=20)
     m_RStatsOver=(X=76,Y=84,W=37,H=20)
     m_RStatsDown=(X=76,Y=105,W=37,H=20)
}
