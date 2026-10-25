//=============================================================================
//  R6MenuOperativeStats.uc : This class will provode us with an 
//                              view of an operative stats
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/21 * Created by Alexandre Dionne
//=============================================================================
class R6MenuOperativeStats extends UWindowWindow;


//Titles
var R6MenuOperativeSkillsLabel  m_TNbMissions;
var R6MenuOperativeSkillsLabel  m_TTerroKilled;
var R6MenuOperativeSkillsLabel  m_TRoundsFired;
var R6MenuOperativeSkillsLabel  m_TRoundsOnTarget;
var R6MenuOperativeSkillsLabel  m_TShootPercent;
var R6MenuOperativeSkillsLabel  m_TGender;


//Values Labels
var R6MenuOperativeSkillsLabel  m_NNbMissions;
var R6MenuOperativeSkillsLabel  m_NTerroKilled;
var R6MenuOperativeSkillsLabel  m_NRoundsFired;
var R6MenuOperativeSkillsLabel  m_NRoundsOnTarget;
var R6MenuOperativeSkillsLabel  m_NShootPercent;
var R6MenuOperativeSkillsLabel  m_NGender;


//Display settings
var FLOAT                        m_fHSidePadding;               //Horizontal padding where we start drawing from left and right
var FLOAT                        m_fTileLabelWidth;
var FLOAT                        m_fTopYPadding;                //Vertical Padding from the top of the window
var FLOAT                        m_fTitleHeight;                //Titles Height
var FLOAT                        m_fValueLabelWidth;
var FLOAT                        m_fYPaddingBetweenElements;  //Vertical Padding Between Lines



//Debug
var bool                         bshowlog;


function Created()
{
    
    local FLOAT Y, X, TitlesHeight, ValuesHeight;
    

    TitlesHeight = m_fTitleHeight + m_fYPaddingBetweenElements;
    ValuesHeight = class'R6MenuOperativeSkillsLabel'.Default.m_BGTextureRegion.H;

    //Titles
    m_TNbMissions=R6MenuOperativeSkillsLabel(CreateWindow(class'R6MenuOperativeSkillsLabel',m_fHSidePadding,m_fTopYPadding,m_fTileLabelWidth,m_fTitleHeight,self));
    m_TNbMissions.Text     = Localize("R6Operative","NbMissions","R6Menu");
    m_TNbMissions.m_BGTexture = None;

    Y= m_TNbMissions.WinTop + TitlesHeight;
    m_TTerroKilled=R6MenuOperativeSkillsLabel(CreateWindow(class'R6MenuOperativeSkillsLabel',m_fHSidePadding, Y ,m_fTileLabelWidth,m_fTitleHeight,self));
    m_TTerroKilled.Text = Localize("R6Operative","TerroKilled","R6Menu");
    m_TTerroKilled.m_BGTexture = None;

    Y= m_TTerroKilled.WinTop + TitlesHeight;
    m_TRoundsFired=R6MenuOperativeSkillsLabel(CreateWindow(class'R6MenuOperativeSkillsLabel',m_fHSidePadding, Y ,m_fTileLabelWidth,m_fTitleHeight,self));
    m_TRoundsFired.Text = Localize("R6Operative","RoundsFired","R6Menu");
    m_TRoundsFired.m_BGTexture = None;

    Y= m_TRoundsFired.WinTop + TitlesHeight;
    m_TRoundsOnTarget=R6MenuOperativeSkillsLabel(CreateWindow(class'R6MenuOperativeSkillsLabel',m_fHSidePadding, Y ,m_fTileLabelWidth,m_fTitleHeight,self));
    m_TRoundsOnTarget.Text      = Localize("R6Operative","RoundsOnTarget","R6Menu");
    m_TRoundsOnTarget.m_BGTexture = None;

    Y= m_TRoundsOnTarget.WinTop +  TitlesHeight;
    m_TShootPercent=R6MenuOperativeSkillsLabel(CreateWindow(class'R6MenuOperativeSkillsLabel',m_fHSidePadding, Y ,m_fTileLabelWidth,m_fTitleHeight,self));
    m_TShootPercent.Text     = Localize("R6Operative","ShootPercent","R6Menu");
    m_TShootPercent.m_BGTexture = None;

           
    
    X= WinWidth - m_fValueLabelWidth - m_fHSidePadding;
        
    Y= m_TNbMissions.WinTop;
    m_NNbMissions=R6MenuOperativeSkillsLabel(CreateWindow(class'R6MenuOperativeSkillsLabel',X, Y, m_fValueLabelWidth, ValuesHeight,self));
    m_NNbMissions.Align=TA_Right;


    Y= m_TTerroKilled.WinTop;
    m_NTerroKilled=R6MenuOperativeSkillsLabel(CreateWindow(class'R6MenuOperativeSkillsLabel',X,Y, m_fValueLabelWidth, ValuesHeight,self));
    m_NTerroKilled.Align=TA_Right;

    Y= m_TRoundsFired.WinTop;
    m_NRoundsFired=R6MenuOperativeSkillsLabel(CreateWindow(class'R6MenuOperativeSkillsLabel',X,Y, m_fValueLabelWidth, ValuesHeight,self));
    m_NRoundsFired.Align=TA_Right;

    Y= m_TRoundsOnTarget.WinTop;
    m_NRoundsOnTarget=R6MenuOperativeSkillsLabel(CreateWindow(class'R6MenuOperativeSkillsLabel',X,Y, m_fValueLabelWidth, ValuesHeight,self));
    m_NRoundsOnTarget.Align=TA_Right;

    Y= m_TShootPercent.WinTop;
    m_NShootPercent=R6MenuOperativeSkillsLabel(CreateWindow(class'R6MenuOperativeSkillsLabel',X,Y, m_fValueLabelWidth, ValuesHeight,self));
    m_NShootPercent.Align=TA_Right;


}

function SetNbMissions(string _szNbMissions)
{
    m_NNbMissions.SetNewText(_szNbMissions, true);
}

function SeTTerroKilled(string _szTerroKilled)
{
    m_NTerroKilled.SetNewText(_szTerroKilled, true);
}

function SetRoundsFired(string _szRoundsFired)
{
    m_NRoundsFired.SetNewText(_szRoundsFired,true);
}


function SetRoundsOnTarget(string _szRoundsOnTarget)
{
    m_NRoundsOnTarget.SetNewText(_szRoundsOnTarget,true);
}


function SetShootPercent(string _szShootPercent)
{
    m_NShootPercent.SetNewText(_szShootPercent, true);
}



function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    R6WindowLookAndFeel(LookAndFeel).DrawBGShading(Self, C, 0, 0, WinWidth, WinHeight);
}

defaultproperties
{
     m_fHSidePadding=5.000000
     m_fTileLabelWidth=148.000000
     m_fTopYPadding=7.000000
     m_fTitleHeight=12.000000
     m_fValueLabelWidth=32.000000
     m_fYPaddingBetweenElements=3.000000
}
