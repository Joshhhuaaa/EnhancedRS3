//=============================================================================
//  R6MenuOperativeHistory.uc : Page wich contains Operative 2d face, flag and
//                              history text
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/15 * Created by Alexandre Dionne
//=============================================================================


class R6MenuOperativeHistory extends UWindowWindow;

var     R6WindowWrappedTextArea     m_OperativeText;
var     R6WindowTextLabel           m_Title; 

function Created()
{   
    m_Title = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 0, 0, WinWidth, 17, self ));
    m_Title.Text = Localize("GearRoom","History","R6Menu");
	m_Title.Align = TA_Center;
	m_Title.m_Font = Root.Fonts[F_VerySmallTitle];     
    m_Title.m_BGTexture = None;
    m_Title.m_bDrawBorders= false;

    m_OperativeText = 
	R6WindowWrappedTextArea(CreateWindow(class'R6WindowWrappedTextArea', 0, 
                                                                        m_Title.WinTop + m_Title.WinHeight,
                                                                        WinWidth, 
                                                                        WinHeight - m_Title.WinHeight,
                                                                        self));
	m_OperativeText.m_HBorderTexture	= None;
	m_OperativeText.m_VBorderTexture	= None;
	m_OperativeText.m_fHBorderHeight = 0;
	m_OperativeText.m_fVBorderWidth = 0;    
    m_OperativeText.SetScrollable(true);    
    m_OperativeText.VertSB.SetEffect(true);

    
	
}

function SetBorderColor(Color _NewColor)
{
    m_BorderColor = _NewColor;
    m_Title.m_BorderColor = _NewColor;
    m_OperativeText.SetBorderColor(_NewColor);
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{       

    R6WindowLookAndFeel(LookAndFeel).DrawBGShading(Self, C, m_OperativeText.WinLeft, m_OperativeText.Wintop, m_OperativeText.WinWidth, m_OperativeText.WinHeight);
   
    C.Style = ERenderStyle.STY_Alpha;    
	C.SetDrawColor( m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);   
    DrawStretchedTexture( C, 0, m_OperativeText.Wintop, WinWidth, 1, Texture'UWindow.WhiteTexture');
}

function SetText(Canvas C, String newText)
{
    m_OperativeText.Clear();    
    m_OperativeText.AddTextWithCanvas(C , 5, 5, newText, 
                                      Root.Fonts[F_VerySmallTitle],
                                      Root.Colors.White); 
}

defaultproperties
{
}
