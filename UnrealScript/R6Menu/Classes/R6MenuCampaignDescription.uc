//=============================================================================
//  R6MenuCampaignDescription.uc : In single player, show the status of the current 
//                                  selected campaign        
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/21 * Created by Alexandre Dionne
//=============================================================================

class R6MenuCampaignDescription extends UWindowWindow;

var R6WindowTextLabel   m_MissionTitle, m_NameTitle, m_DifficultyTitle;
var R6WindowTextLabel   m_MissionValue, m_NameValue, m_DifficultyValue;

var FLOAT               m_HPadding, m_VPadding, m_VSpaceBetweenElements , m_LabelHeight;

var Texture             m_BGTexture;
var Region              m_BGTextureRegion;
var int                 m_DrawStyle;
var Color               m_vBGColor;

function Created()
{
    local FLOAT LabelWidth , RightLabelX, DifficultyWidth, NameWidth;

    LabelWidth = WinWidth/2 -  m_HPadding;
    RightLabelX = WinWidth - LabelWidth - m_HPadding;
    DifficultyWidth = 135;
    NameWidth = 75;
    
    m_MissionTitle      = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', m_HPadding, m_VPadding, LabelWidth, m_LabelHeight, self));
    m_MissionTitle.m_bDrawBorders   = False;
    m_MissionTitle.Align            = TA_Left;
    m_MissionTitle.TextColor        = Root.Colors.White;
    m_MissionTitle.m_Font           = Root.Fonts[F_SmallTitle];
    m_MissionTitle.Text             = Localize("SinglePlayer","Mission","R6Menu");
    m_MissionTitle.m_BGTexture      = None;     

    m_NameTitle         = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', m_HPadding, m_MissionTitle.WinTop + m_MissionTitle.WinHeight + m_VSpaceBetweenElements, NameWidth, m_LabelHeight, self));  
    m_NameTitle.m_bDrawBorders      = False;
    m_NameTitle.Align               = TA_Left;
    m_NameTitle.TextColor           = Root.Colors.White;
    m_NameTitle.m_Font              = Root.Fonts[F_SmallTitle];
    m_NameTitle.Text                = Localize("SinglePlayer", "Name","R6Menu");
    m_NameTitle.m_BGTexture         = None;     

    m_DifficultyTitle   = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', m_HPadding, m_NameTitle.WinTop + m_NameTitle.WinHeight + m_VSpaceBetweenElements, DifficultyWidth, m_LabelHeight, self));
    m_DifficultyTitle.m_bDrawBorders= False;
    m_DifficultyTitle.Align         = TA_Left;
    m_DifficultyTitle.TextColor     = Root.Colors.White;
    m_DifficultyTitle.m_Font        = Root.Fonts[F_SmallTitle];
    m_DifficultyTitle.Text          = Localize("SinglePlayer","Difficulty","R6Menu");
    m_DifficultyTitle.m_BGTexture   = None;     

    m_MissionValue      = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', RightLabelX, m_VPadding, LabelWidth, m_LabelHeight, self));
    m_MissionValue.m_bDrawBorders   = False;
    m_MissionValue.Align            = TA_Right;
    m_MissionValue.TextColor        = Root.Colors.White;
    m_MissionValue.m_Font           = Root.Fonts[F_SmallTitle];
    m_MissionValue.m_BGTexture      = None;     

    m_NameValue         = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', m_NameTitle.WinLeft + m_NameTitle.WinWidth, m_MissionTitle.WinTop + m_MissionTitle.WinHeight + m_VSpaceBetweenElements, (LabelWidth * 2) - m_NameTitle.WinWidth, m_LabelHeight, self));
    m_NameValue.m_bDrawBorders      = False;
    m_NameValue.Align               = TA_Right;
    m_NameValue.TextColor           = Root.Colors.White;
    m_NameValue.m_Font              = Root.Fonts[F_SmallTitle];
    m_NameValue.m_BGTexture         = None;     

    m_DifficultyValue   = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', m_DifficultyTitle.WinLeft + m_DifficultyTitle.WinWidth, m_NameTitle.WinTop + m_NameTitle.WinHeight + m_VSpaceBetweenElements, (LabelWidth * 2) - m_DifficultyTitle.WinWidth, m_LabelHeight, self));
    m_DifficultyValue.m_bDrawBorders = False;
    m_DifficultyValue.Align          = TA_Right;
    m_DifficultyValue.TextColor      = Root.Colors.White;
    m_DifficultyValue.m_Font         = Root.Fonts[F_SmallTitle];
    m_DifficultyValue.m_BGTexture    = None;     

    m_vBGColor  = Root.Colors.Black;

}

/*
function Paint(Canvas C, FLOAT X, FLOAT Y)
{
 
    R6WindowLookAndFeel(LookAndFeel).DrawBGShading(Self, C, 0, 0, WinWidth, WinHeight);

}
*/

defaultproperties
{
     m_DrawStyle=5
     m_HPadding=12.000000
     m_VPadding=18.000000
     m_VSpaceBetweenElements=25.000000
     m_LabelHeight=12.000000
     m_BGTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     m_BGTextureRegion=(X=97,W=33,H=23)
}
