//=============================================================================
//  R6MenuIntelRadioArea.uc : Controls for intel menu (under speaker widget)
//                                         
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/21 * Created by Yannick Joly
//=============================================================================


class R6MenuIntelRadioArea extends UWindowDialogClientWindow;

var R6WindowStayDownButton  m_ControlButton;
var R6WindowStayDownButton  m_ClarkButton;
var R6WindowStayDownButton  m_SweenyButton;
var R6WindowStayDownButton  m_NewsButton;
var R6WindowStayDownButton  m_MissionButton;
var R6WindowStayDownButton  m_CurrentSelectedButton;


function Created()
{
	local color   cFontColor;
	local Font    buttonFont;
    local Texture BGSelecTexture;
    local Region  BGRegion;
    local FLOAT   fXOffset,
                  fYOffset,
                  fStepBetweenControl;   



    BGSelecTexture = Texture(DynamicLoadObject("R6MenuTextures.Gui_BoxScroll", class'Texture'));
	buttonFont     = Root.Fonts[F_PrincipalButton];

	cFontColor = Root.Colors.BlueLight;	

    BGRegion.X = 132;
    BGRegion.Y = 24;
    BGRegion.W = 2;
    BGRegion.H = 19;

    fXOffset = 5;             // from the border window in X
    fYOffset = 8;             // from the border window in Y
    fStepBetweenControl = 20; // the step between each control


    // CONTROL button
    m_ControlButton = R6WindowStayDownButton(CreateControl( class'R6WindowStayDownButton', fXOffset, fYOffset, WinWidth, 20)); 
    m_ControlButton.ToolTipString = Localize("Tip","Speaker1","R6Menu");
	m_ControlButton.Text = Localize("Briefing","Speaker1","R6Menu");
	m_ControlButton.Align = TA_Left;	
	m_ControlButton.m_buttonFont = buttonFont;
    m_ControlButton.m_BGSelecTexture = BGSelecTexture;
    m_ControlButton.DownRegion = BGRegion;
	m_ControlButton.m_iButtonID  = R6MenuIntelWidget(OwnerWindow).EMenuIntelButtonID.ButtonControlID;
    m_ControlButton.m_bUseOnlyNotifyMsg = true;
//    m_ControlButton.ResizeToText();


    fYOffset += fStepBetweenControl;

    // JOHN CLARK button
    m_ClarkButton = R6WindowStayDownButton(CreateControl( class'R6WindowStayDownButton', fXOffset, fYOffset, WinWidth, 20)); 
    m_ClarkButton.ToolTipString = Localize("Tip","Speaker2","R6Menu");
	m_ClarkButton.Text = Localize("Briefing","Speaker2","R6Menu");
	m_ClarkButton.Align = TA_Left;	
	m_ClarkButton.m_buttonFont = buttonFont;
    m_ClarkButton.m_BGSelecTexture = BGSelecTexture;
    m_ClarkButton.DownRegion = BGRegion;
	m_ClarkButton.m_iButtonID  = R6MenuIntelWidget(OwnerWindow).EMenuIntelButtonID.ButtonClarkID; 
    m_ClarkButton.m_bUseOnlyNotifyMsg = true;


    fYOffset += fStepBetweenControl;

    // KEVIN SWEENY button
    m_SweenyButton = R6WindowStayDownButton(CreateControl( class'R6WindowStayDownButton', fXOffset, fYOffset, WinWidth, 20)); 
    m_SweenyButton.ToolTipString = Localize("Tip","Speaker3","R6Menu");
	m_SweenyButton.Text = Localize("Briefing","Speaker3","R6Menu");
	m_SweenyButton.Align = TA_Left;	
	m_SweenyButton.m_buttonFont = buttonFont;   	
    m_SweenyButton.DownRegion = BGRegion; 
	m_SweenyButton.m_iButtonID  = R6MenuIntelWidget(OwnerWindow).EMenuIntelButtonID.ButtonSweenyID;
    m_SweenyButton.m_bUseOnlyNotifyMsg = true;


    fYOffset += fStepBetweenControl;

    // NEWSWIRE button
    m_NewsButton = R6WindowStayDownButton(CreateControl( class'R6WindowStayDownButton', fXOffset, fYOffset, WinWidth, 20)); 
    m_NewsButton.ToolTipString = Localize("Tip","Speaker4","R6Menu");
	m_NewsButton.Text = Localize("Briefing","Speaker4","R6Menu");
	m_NewsButton.Align = TA_Left;	
	m_NewsButton.m_buttonFont = buttonFont;
    m_NewsButton.m_BGSelecTexture = BGSelecTexture;
    m_NewsButton.DownRegion = BGRegion;
	m_NewsButton.m_iButtonID  = R6MenuIntelWidget(OwnerWindow).EMenuIntelButtonID.ButtonNewsID;
    m_NewsButton.m_bUseOnlyNotifyMsg = true;


    fYOffset += fStepBetweenControl;

    // MISSION ORDER button
    m_MissionButton = R6WindowStayDownButton(CreateControl( class'R6WindowStayDownButton', fXOffset, fYOffset, WinWidth, 20)); 
    m_MissionButton.ToolTipString = Localize("Tip","Speaker5","R6Menu");
	m_MissionButton.Text = Localize("Briefing","Speaker5","R6Menu");
	m_MissionButton.Align = TA_Left;
	m_MissionButton.m_buttonFont = buttonFont;
    m_MissionButton.m_BGSelecTexture = BGSelecTexture;
    m_MissionButton.DownRegion = BGRegion; 
	m_MissionButton.m_iButtonID  = R6MenuIntelWidget(OwnerWindow).EMenuIntelButtonID.ButtonMissionID;
    m_MissionButton.m_bUseOnlyNotifyMsg = true;


    //Set Current Selected Button
    m_CurrentSelectedButton = m_ControlButton;
    m_CurrentSelectedButton.m_bSelected= true;
}

function Reset()
{
        m_CurrentSelectedButton.m_bSelected= false;
        m_CurrentSelectedButton = m_ControlButton;
        m_CurrentSelectedButton.m_bSelected= true;
}


function AssociateButtons()
{
    AssociateTextWithButton( m_ControlButton, "ID_CONTROL");
    AssociateTextWithButton( m_ClarkButton, "ID_CLARK");
    AssociateTextWithButton( m_SweenyButton, "ID_SWEENY");
    AssociateTextWithButton( m_NewsButton, "ID_NEWSWIRE");
    AssociateTextWithButton( m_MissionButton, "ID_MISSION_ORDER");

}



function Notify(UWindowDialogControl C, byte E)
{
    local R6WindowStayDownButton tmpButton;
    
    
    if  (E == DE_Click)
    {
        tmpButton = R6WindowStayDownButton(C);

        if (tmpButton != None)
        {
            // Change Current Selected Button
            if( (tmpButton != m_CurrentSelectedButton) &&
                (!tmpButton.bDisabled) )
            {
                m_CurrentSelectedButton.m_bSelected= false;
                m_CurrentSelectedButton = tmpButton;
                m_CurrentSelectedButton.m_bSelected= true;
                
                // Advise Parent window
                if( R6MenuIntelWidget(OwnerWindow) != None)
                    R6MenuIntelWidget(OwnerWindow).ManageButtonSelection( m_CurrentSelectedButton.m_iButtonID);	
            }
        }
    }
    
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{    
   DrawSimpleBorder(C);
}

function AssociateTextWithButton( R6WindowStayDownButton _R6Button, string _szTextToFind)
{
    local bool bHaveTextForButton;

    // we have to check if this button have an associate text with it
    bHaveTextForButton = R6MenuIntelWidget(OwnerWindow).SetMissionText( _szTextToFind);

    if (!bHaveTextForButton)
    {
        _R6Button.bDisabled = true;
        //_R6Button.TextColor = Root.Colors.GrayLight;
    }
    else
    {
        _R6Button.bDisabled = false;
    }
}

defaultproperties
{
}
