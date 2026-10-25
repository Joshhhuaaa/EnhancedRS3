//=============================================================================
//  R6MenuCarreerStats.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/08 * Created by Alexandre Dionne
//=============================================================================


class R6MenuCarreerStats extends UWindowWindow;

var R6WindowTextLabel m_LTitle, m_LMissionServed, m_LTerroKilled, m_LRoundsFired, m_LRoundsOnTarget, m_LShootPercent;
var FLOAT             m_fTitleHeight, m_fYOffset, m_fXOffset, m_fLabelHeight;        

var R6WindowTextLabel m_LOpName, m_LOpSpecility, m_LOpHealthStatus;
var FLOAT             m_fLOpNameX;
var FLOAT             m_fLOpNameW;

var R6WindowBitMap    m_RainBowLogo;                       
var Texture           m_TRainBowLogo;                       
var Region            m_RRainBowLogo;                       

var R6MenuCarreerOperative m_OperativeFace;
var INT               m_iPadding, m_iHeight;

function Created()
{
    local int YPos, XPos;

    m_LTitle = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                0, 
                                                0, 
                                        		WinWidth, 
                                                m_fTitleHeight, 
                                                self));
    m_LTitle.SetProperties( Localize("DebriefingMenu", "CARREERSTATS", "R6Menu"), TA_CENTER, Root.Fonts[F_PopUpTitle], Root.Colors.BlueLight, false);
    
    
    YPos = m_fYOffset;
    m_LMissionServed = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                m_fXOffset, 
                                                YPos, 
                                        		WinWidth - m_fXOffset, 
                                                m_fLabelHeight, 
                                                self));
    m_LMissionServed.SetProperties( "", TA_LEFT, Root.Fonts[F_SmallTitle], Root.Colors.BlueLight, false);
    

    YPos += m_fLabelHeight;    
    m_LTerroKilled = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                m_fXOffset, 
                                                YPos, 
                                        		WinWidth - m_fXOffset, 
                                                m_fLabelHeight, 
                                                self));
    m_LTerroKilled.SetProperties( "", TA_LEFT, Root.Fonts[F_SmallTitle], Root.Colors.BlueLight, false);

    
    YPos += m_fLabelHeight;
    m_LRoundsFired  = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                m_fXOffset, 
                                                YPos, 
                                        		WinWidth - m_fXOffset, 
                                                m_fLabelHeight, 
                                                self));
    m_LRoundsFired.SetProperties( "", TA_LEFT, Root.Fonts[F_SmallTitle], Root.Colors.BlueLight, false);

    
    
    
    YPos += m_fLabelHeight;
    m_LRoundsOnTarget = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                m_fXOffset, 
                                                YPos, 
                                        		WinWidth - m_fXOffset, 
                                                m_fLabelHeight, 
                                                self));
    m_LRoundsOnTarget.SetProperties( "", TA_LEFT, Root.Fonts[F_SmallTitle], Root.Colors.BlueLight, false);



    
    YPos += m_fLabelHeight;
    m_LShootPercent = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                m_fXOffset, 
                                                YPos, 
                                        		WinWidth - m_fXOffset, 
                                                m_fLabelHeight, 
                                                self));
    m_LShootPercent.SetProperties( "", TA_LEFT, Root.Fonts[F_SmallTitle], Root.Colors.BlueLight, false);

    m_RainBowLogo = R6WindowBitMap(CreateWindow(class'R6WindowBitMap',204,31,m_RRainBowLogo.W,m_RRainBowLogo.H,self));
    m_RainBowLogo.T = m_TRainBowLogo;
    m_RainBowLogo.R = m_RRainBowLogo;
    m_RainBowLogo.m_iDrawStyle  = 5;
    
    m_BorderColor = Root.Colors.GrayLight;

    
    m_OperativeFace = R6MenuCarreerOperative(CreateWindow(class'R6MenuCarreerOperative',m_iPadding,138,WinWidth - (2 * m_iPadding),m_iHeight,self));



    //Text Labels covering Operative face 
    m_LOpName = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                m_fLOpNameX, 
                                                m_OperativeFace.WinTop, 
                                        		m_fLOpNameW, 
                                                m_OperativeFace.WinHeight /3, 
                                                self));
    m_LOpName.m_bFixedYPos = true;
    m_LOpName.TextY = 16;
    m_LOpName.SetProperties( "", TA_Right, Root.Fonts[F_VerySmallTitle], Root.Colors.White, false);
    m_LOpName.bAlwaysOnTop = true;



    m_LOpSpecility = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                m_LOpName.WinLeft, 
                                                m_LOpName.WinTop + m_LOpName.WinHeight, 
                                        		m_LOpName.WinWidth, 
                                                m_LOpName.WinHeight, 
                                                self));
    m_LOpSpecility.SetProperties( "", TA_Right, Root.Fonts[F_VerySmallTitle], Root.Colors.White, false);
    m_LOpSpecility.bAlwaysOnTop = true;

    m_LOpHealthStatus = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                m_LOpName.WinLeft, 
                                                m_LOpSpecility.WinTop + m_LOpSpecility.WinHeight, 
                                        		m_LOpName.WinWidth, 
                                                m_OperativeFace.WinHeight - m_LOpName.WinHeight - m_LOpSpecility.WinHeight, 
                                                self));
    m_LOpHealthStatus.m_bFixedYPos = true;
    m_LOpHealthStatus.TextY = 2;
    m_LOpHealthStatus.SetProperties( "", TA_Right, Root.Fonts[F_VerySmallTitle], Root.Colors.White, false);
    m_LOpHealthStatus.bAlwaysOnTop = true;


}

//To change the current operative Carreer Stats
function UpdateStats( string _MissionServed, string _TerroKilled, string _RoundsShot, string _RoundsOnTarget, string _ShootPercent)
{
    m_LMissionServed.SetNewText(Localize("R6Operative", "NbMissions", "R6Menu")@_MissionServed,true);
    m_LTerroKilled.SetNewText(Localize("R6Operative", "TerroKilled", "R6Menu")@_TerroKilled,true);
    m_LRoundsFired.SetNewText(Localize("R6Operative", "RoundsFired", "R6Menu")@_RoundsShot,true);
    m_LRoundsOnTarget.SetNewText(Localize("R6Operative", "RoundsOnTarget", "R6Menu")@_RoundsOnTarget,true);   
    m_LShootPercent.SetNewText(Localize("R6Operative", "ShootPercent", "R6Menu")@_ShootPercent,true);
}

//To change the current Operative Face
function UpdateFace(Texture _Face, Region _FaceRegion)
{
    m_OperativeFace.SetFace(_Face, _FaceRegion);    
}

function UpdateTeam(int _Team)
{ 
    m_OperativeFace.SetTeam(_Team);    
}

function UpdateName(string _szOpName)
{
    m_LOpName.SetNewText(_szOpName, true);
}

function UpdateSpeciality(string _szOpSpeciality)
{
    m_LOpSpecility.SetNewText(_szOpSpeciality, true);
}

function UpdateHealthStatus(string _szHealthStatus)
{
    m_LOpHealthStatus.SetNewText(_szHealthStatus, true);
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{ 

    R6WindowLookAndFeel(LookAndFeel).DrawBGShading(Self, C, 0, m_fTitleHeight, WinWidth, WinHeight - m_fTitleHeight);
    
    DrawSimpleBorder(C);
    
    DrawStretchedTextureSegment(C, 0, m_fTitleHeight, WinWidth, m_BorderTextureRegion.H , 
                                     m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
}

defaultproperties
{
     m_iPadding=2
     m_iHeight=85
     m_fTitleHeight=16.000000
     m_fYOffSet=21.000000
     m_fXOffSet=3.000000
     m_fLabelHeight=18.000000
     m_fLOpNameX=133.000000
     m_fLOpNameW=140.000000
     m_TRainBowLogo=Texture'R6MenuTextures.Gui_BoxScroll'
     m_RRainBowLogo=(X=172,Y=66,W=72,H=62)
}
