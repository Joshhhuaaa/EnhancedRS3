//=============================================================================
//  R6MenuOperativeBio.uc : This Class Should Provide us with a window displaying
//                              an operative bio details in a R6MenuOperativeDetailControl
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/20 * Created by Alexandre Dionne
//=============================================================================


class R6MenuOperativeBio extends UWindowWindow;

//Titles
var R6MenuOperativeSkillsLabel  m_TDateBirth;
var R6MenuOperativeSkillsLabel  m_THeight;
var R6MenuOperativeSkillsLabel  m_TWeight;
var R6MenuOperativeSkillsLabel  m_THair;
var R6MenuOperativeSkillsLabel  m_TEyes;
var R6MenuOperativeSkillsLabel  m_TGender;

var R6WindowTextLabel  m_TStatus;


//Values Labels
var R6MenuOperativeSkillsLabel  m_NDateBirth;
var R6MenuOperativeSkillsLabel  m_NHeight;
var R6MenuOperativeSkillsLabel  m_NWeight;
var R6MenuOperativeSkillsLabel  m_NHair;
var R6MenuOperativeSkillsLabel  m_NEyes;
var R6MenuOperativeSkillsLabel  m_NGender;


//Display settings
var FLOAT                        m_fHSidePadding;               //Horizontal padding where we start drawing from left and right
var FLOAT                        m_fTileLabelWidth;
var FLOAT                        m_fTopYPadding;                //Vertical Padding from the top of the window
var FLOAT                        m_fTitleHeight;                //Titles Height
var FLOAT                        m_fValueLabelWidth;
var FLOAT                        m_fYPaddingBetweenElements;  //Vertical Padding Between Lines
var FLOAT                        m_fHealthHeight;






//Debug
var bool                         bshowlog;


function Created()
{
    
    local FLOAT Y, X, TitlesHeight, ValuesHeight;
    

    TitlesHeight = m_fTitleHeight + m_fYPaddingBetweenElements;
    ValuesHeight = class'R6MenuOperativeSkillsLabel'.Default.m_BGTextureRegion.H;

    //Titles
    m_TDateBirth=R6MenuOperativeSkillsLabel(CreateWindow(class'R6MenuOperativeSkillsLabel',m_fHSidePadding,m_fTopYPadding,m_fTileLabelWidth,m_fTitleHeight,self));
    m_TDateBirth.Text     = Localize("R6Operative","DateBirth","R6Menu");
    m_TDateBirth.m_BGTexture = None;

    Y= m_TDateBirth.WinTop + TitlesHeight;
    m_THeight=R6MenuOperativeSkillsLabel(CreateWindow(class'R6MenuOperativeSkillsLabel',m_fHSidePadding, Y ,m_fTileLabelWidth,m_fTitleHeight,self));
    m_THeight.Text = Localize("R6Operative","Height","R6Menu");
    m_THeight.m_BGTexture = None;

    Y= m_THeight.WinTop + TitlesHeight;
    m_TWeight=R6MenuOperativeSkillsLabel(CreateWindow(class'R6MenuOperativeSkillsLabel',m_fHSidePadding, Y ,m_fTileLabelWidth,m_fTitleHeight,self));
    m_TWeight.Text = Localize("R6Operative","Weight","R6Menu");
    m_TWeight.m_BGTexture = None;

    Y= m_TWeight.WinTop + TitlesHeight;
    m_THair=R6MenuOperativeSkillsLabel(CreateWindow(class'R6MenuOperativeSkillsLabel',m_fHSidePadding, Y ,m_fTileLabelWidth,m_fTitleHeight,self));
    m_THair.Text      = Localize("R6Operative","Hair","R6Menu");
    m_THair.m_BGTexture = None;

    Y= m_THair.WinTop +  TitlesHeight;
    m_TEyes=R6MenuOperativeSkillsLabel(CreateWindow(class'R6MenuOperativeSkillsLabel',m_fHSidePadding, Y ,m_fTileLabelWidth,m_fTitleHeight,self));
    m_TEyes.Text     = Localize("R6Operative","Eyes","R6Menu");
    m_TEyes.m_BGTexture = None;

    Y= m_TEyes.WinTop + TitlesHeight;
    m_TGender=R6MenuOperativeSkillsLabel(CreateWindow(class'R6MenuOperativeSkillsLabel',m_fHSidePadding, Y ,m_fTileLabelWidth,m_fTitleHeight,self));
    m_TGender.Text = Localize("R6Operative","Gender","R6Menu");
    m_TGender.m_BGTexture = None;

        
    
    X= WinWidth - m_fValueLabelWidth - m_fHSidePadding;
        
    Y= m_TDateBirth.WinTop;
    m_NDateBirth=R6MenuOperativeSkillsLabel(CreateWindow(class'R6MenuOperativeSkillsLabel',X, Y, m_fValueLabelWidth, ValuesHeight,self));
    m_NDateBirth.Align=TA_Left;


    Y= m_THeight.WinTop;
    m_NHeight=R6MenuOperativeSkillsLabel(CreateWindow(class'R6MenuOperativeSkillsLabel',X,Y, m_fValueLabelWidth, ValuesHeight,self));
    m_NHeight.Align=TA_Left;

    Y= m_TWeight.WinTop;
    m_NWeight=R6MenuOperativeSkillsLabel(CreateWindow(class'R6MenuOperativeSkillsLabel',X,Y, m_fValueLabelWidth, ValuesHeight,self));
    m_NWeight.Align=TA_Left;

    Y= m_THair.WinTop;
    m_NHair=R6MenuOperativeSkillsLabel(CreateWindow(class'R6MenuOperativeSkillsLabel',X,Y, m_fValueLabelWidth, ValuesHeight,self));
    m_NHair.Align=TA_Left;

    Y= m_TEyes.WinTop;
    m_NEyes=R6MenuOperativeSkillsLabel(CreateWindow(class'R6MenuOperativeSkillsLabel',X,Y, m_fValueLabelWidth, ValuesHeight,self));
    m_NEyes.Align=TA_Left;

    Y= m_TGender.WinTop;
    m_NGender=R6MenuOperativeSkillsLabel(CreateWindow(class'R6MenuOperativeSkillsLabel',X,Y, m_fValueLabelWidth, ValuesHeight,self));
    m_NGender.Align=TA_Left;

    
    m_TStatus=R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel',0,WinHeight - m_fHealthHeight, WinWidth, m_fHealthHeight,self));
    m_TStatus.m_bDrawBorders=true;
    m_TStatus.m_BGTexture = None;
    m_TStatus.Align=TA_Center;
    m_TStatus.m_Font= Root.Fonts[F_SmallTitle]; 
    m_TStatus.m_BorderColor = m_BorderColor;
    m_TStatus.TextColor   = Root.Colors.White;
    

}

function SetBorderColor(Color _NewColor)
{
    m_BorderColor = _NewColor;
    m_TStatus.m_BorderColor = _NewColor;
}

function SetBirthDate(string _szBirthDate)
{
    m_NDateBirth.Text = _szBirthDate;
}

function SetHeight(string _szHeight)
{
    m_NHeight.Text = _szHeight;
}

function SetWeight(string _szWeight)
{
    m_NWeight.Text = _szWeight;
}


function SetHairColor(string _szHair)
{
    m_NHair.Text = _szHair;
}


function SetEyesColor(string _szEyes)
{
    m_NEyes.Text = _szEyes;
}

function SetGender(string _szGender)
{
    m_NGender.Text = _szGender;
}

function SetHealthStatus(string _Health)
{
    m_TStatus.SetNewText(_Health, true);    
}


function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    R6WindowLookAndFeel(LookAndFeel).DrawBGShading(Self, C, 0, 0, WinWidth, WinHeight);
}

defaultproperties
{
     m_fHSidePadding=5.000000
     m_fTileLabelWidth=90.000000
     m_fTopYPadding=7.000000
     m_fTitleHeight=12.000000
     m_fValueLabelWidth=84.000000
     m_fYPaddingBetweenElements=3.000000
     m_fHealthHeight=20.000000
}
