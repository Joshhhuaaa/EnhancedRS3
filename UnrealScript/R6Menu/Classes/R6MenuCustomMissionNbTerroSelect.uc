//=============================================================================
//  R6MenuCustomMissionNbTerroSelect.uc : Select Terro Count
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/24 * Created by Alexandre Dionne
//=============================================================================


class R6MenuCustomMissionNbTerroSelect extends UWindowDialogClientWindow 
                config(USER);


var R6WindowTextLabel			m_TitleNbTerro;

var Float                       m_fLabelHeight;

var const INT c_iNbTerroMax;
var const INT c_iNbTerroMin;
var config  INT CustomMissionNbTerro; 

var R6WindowCounter m_TerroCounter;

function Created()
{

	m_TitleNbTerro = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 0, 0, WinWidth, m_fLabelHeight, self));
	m_TitleNbTerro.Text = Localize("CustomMission","NbTerro","R6Menu");
	m_TitleNbTerro.Align = TA_Center;
	m_TitleNbTerro.m_Font = Root.Fonts[F_PopUpTitle];
	m_TitleNbTerro.TextColor = Root.Colors.White;
    m_TitleNbTerro.m_bDrawBorders      =False;
    

    m_TerroCounter = R6WindowCounter(CreateWindow( class'R6WindowCounter', 0, m_TitleNbTerro.WinTop + m_TitleNbTerro.WinHeight + 9, WinWidth, 15, self)); 
    m_TerroCounter.bAlwaysBehind = true;
    m_TerroCounter.ToolTipString =  Localize("Tip","Custom_NbTerro","R6Menu");
    m_TerroCounter.m_iButtonID   = 0;
    m_TerroCounter.SetAdviceParent(false);    
    m_TerroCounter.CreateButtons( (m_TerroCounter.WinWidth/2) - 30, 0, 60);
    m_TerroCounter.SetDefaultValues( c_iNbTerroMin, c_iNbTerroMax, CustomMissionNbTerro);    
    m_TerroCounter.SetButtonToolTip( Localize("Tip","Custom_NbTerro","R6Menu"),
									 Localize("Tip","Custom_NbTerro","R6Menu") );	   

}

function int GetNbTerro()
{   
    if(m_TerroCounter.m_iCounter != CustomMissionNbTerro)
    {
        CustomMissionNbTerro = m_TerroCounter.m_iCounter;
        SaveConfig();
    }        

	return m_TerroCounter.m_iCounter;
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{       
    //**Draw Bg and borders for the Center Text Label

    C.Style = ERenderStyle.STY_Modulated;    
    DrawStretchedTextureSegment( C, m_TitleNbTerro.WinLeft, m_TitleNbTerro.Wintop, m_TitleNbTerro.WinWidth, m_TitleNbTerro.WinHeight,
                                77,0,4,29,
                                Texture'R6MenuTextures.Gui_BoxScroll');
    
    
    C.Style = ERenderStyle.STY_Alpha;    
	C.SetDrawColor( m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);   
    
    DrawStretchedTexture( C, 0, m_TitleNbTerro.Wintop + m_TitleNbTerro.WinHeight, WinWidth, 1, Texture'UWindow.WhiteTexture');
}

defaultproperties
{
     c_iNbTerroMax=35
     c_iNbTerroMin=5
     CustomMissionNbTerro=35
     m_fLabelHeight=29.000000
}
