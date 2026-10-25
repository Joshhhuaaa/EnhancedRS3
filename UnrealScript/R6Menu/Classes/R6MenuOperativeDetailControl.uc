//=============================================================================
//  R6MenuOperativeDetailControl.uc : This will provide fonctionalities
//                                      to get operative descriptions
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/15 * Created by Alexandre Dionne
//=============================================================================


class R6MenuOperativeDetailControl extends UWindowDialogClientWindow;

var R6MenuOperativeDetailRadioArea  m_TopButtons;

var R6MenuOperativeHistory          m_HistoryPage;
var R6MenuOperativeSkills           m_SkillsPage;
var R6MenuOperativeBio              m_BioPage;
var R6MenuOperativeStats            m_StatsPage;

var R6WindowBitMap					m_OperativeFace; 

var UWindowWindow                   m_CurrentPage;  

var bool                            m_bUpdateOperativeText;

var INT                             m_ITopLineYPos, m_IBottomLineYPos;

function Created()
{
	local FLOAT fYOffset, fHeight;
    
    m_BorderColor = Root.Colors.GrayLight;

    //Creating the top Buttons
    m_TopButtons    = R6MenuOperativeDetailRadioArea(CreateWindow(class'R6MenuOperativeDetailRadioArea',0,0,WinWidth,23,self));	
    m_TopButtons.m_BorderColor = m_BorderColor;

	fYOffset = m_TopButtons.WinTop + m_TopButtons.WinHeight;

    m_OperativeFace = R6WindowBitMap(CreateWindow(class'R6WindowBitMap',0, fYOffset, WinWidth, 81, self));    
    m_OperativeFace.m_BorderColor = m_BorderColor;
	m_OperativeFace.m_bDrawBorder = false;
    m_OperativeFace.bCenter = true;
    
	fYOffset = m_OperativeFace.WinTop + m_OperativeFace.WinHeight;
	fHeight  = WinHeight - (m_TopButtons.WinHeight + m_OperativeFace.WinHeight);

    //Creating the pages
    m_HistoryPage   = R6MenuOperativeHistory(CreateWindow(class'R6MenuOperativeHistory', 0, fYOffset, WinWidth, fHeight, self));
    m_HistoryPage.SetBorderColor(m_BorderColor);
	m_HistoryPage.HideWindow();
    
    m_SkillsPage    = R6MenuOperativeSkills(CreateWindow(class'R6MenuOperativeSkills', 0, fYOffset, WinWidth, fHeight,self));	
    m_SkillsPage.m_BorderColor = m_BorderColor;
    m_SkillsPage.HideWindow();

    m_BioPage       = R6MenuOperativeBio(CreateWindow(class'R6MenuOperativeBio', 0, fYOffset, WinWidth, fHeight,self));	
    m_BioPage.SetBorderColor(m_BorderColor);
    m_BioPage.HideWindow();

    m_StatsPage     = R6MenuOperativeStats(CreateWindow(class'R6MenuOperativeStats', 0, fYOffset, WinWidth, fHeight,self));	
    m_StatsPage.m_BorderColor = m_BorderColor;
	m_StatsPage.HideWindow();

	m_CurrentPage	= m_SkillsPage;
	m_CurrentPage.ShowWindow();    

    m_ITopLineYPos = m_TopButtons.WinTop + m_TopButtons.WinHeight;   //So it overlaps
    m_IBottomLineYPos = m_OperativeFace.WinTop + m_OperativeFace.WinHeight -1;   //So it overlaps

}

function UpdateDetails()
{
    local R6Operative currentOperative;
    local Region      RMenuFace;

    currentOperative = R6MenuGearWidget(OwnerWindow).m_currentOperative;

    //Update History Page
    RMenuFace.X = currentOperative.m_RMenuFaceX;
    RMenuFace.Y = currentOperative.m_RMenuFaceY;
    RMenuFace.W = currentOperative.m_RMenuFaceW;
    RMenuFace.H = currentOperative.m_RMenuFaceH;

	SetFace(currentOperative.m_TMenuFace, RMenuFace);
    m_bUpdateOperativeText = true;
    

    //Update Skills Page
    m_SkillsPage.m_fAssault         =currentOperative.m_fAssault;
    m_SkillsPage.m_fDemolitions     =currentOperative.m_fDemolitions;
    m_SkillsPage.m_fElectronics     =currentOperative.m_fElectronics;
    m_SkillsPage.m_fSniper          =currentOperative.m_fSniper;
    m_SkillsPage.m_fStealth         =currentOperative.m_fStealth;
    m_SkillsPage.m_fSelfControl     =currentOperative.m_fSelfControl;
    m_SkillsPage.m_fLeadership      =currentOperative.m_fLeadership;
    m_SkillsPage.m_fObservation     =currentOperative.m_fObservation;
    m_SkillsPage.ResizeCharts( currentOperative);
    
    //Updating Bio Page
    m_BioPage.SetBirthDate(currentOperative.GetBirthDate());
    m_BioPage.SetHeight(currentOperative.GetHeight());
    m_BioPage.SetWeight(currentOperative.GetWeight());
    m_BioPage.SetHairColor(currentOperative.GetHairColor());
    m_BioPage.SetEyesColor(currentOperative.GetEyesColor());
    m_BioPage.SetGender(currentOperative.GetGender());
    m_BioPage.SetHealthStatus(currentOperative.GetHealthStatus());

    //Updating Stats Page
    m_StatsPage.SetNbMissions(currentOperative.GetNbMissionPlayed());
    m_StatsPage.SeTTerroKilled(currentOperative.GetNbTerrokilled());
    m_StatsPage.SetRoundsFired(currentOperative.GetNbRoundsfired());
    m_StatsPage.SetRoundsOnTarget(currentOperative.GetNbRoundsOnTarget());
    m_StatsPage.SetShootPercent(currentOperative.GetShootPercent());


}

function ChangePage( int buttonId)
{
    m_CurrentPage.HideWindow();

    switch(buttonId)
    {
        case 1 :
            m_CurrentPage = m_HistoryPage;
            break;
        case 2 :
            m_CurrentPage = m_SkillsPage;
            break;
        case 3 :
            m_CurrentPage = m_BioPage;
            break;
        case 4 :
            m_CurrentPage = m_StatsPage;
            break;
    }
    
    m_CurrentPage.ShowWindow();
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{

    local R6Operative currentOperative;

    currentOperative = R6MenuGearWidget(OwnerWindow).m_currentOperative;

    if(m_bUpdateOperativeText)
    {
        m_HistoryPage.SetText(C, currentOperative.GetHistory());
        m_bUpdateOperativeText=false;

    }    
}

function AfterPaint(Canvas C, FLOAT X, FLOAT Y)
{
    DrawSimpleBorder(C);

      //Draw Buttons Contour
    C.Style = ERenderStyle.STY_Alpha;
        
	C.SetDrawColor( m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);       

    DrawStretchedTexture( C, 0, m_ITopLineYPos, WinWidth, 1, Texture'UWindow.WhiteTexture');

    DrawStretchedTexture( C, 0, m_IBottomLineYPos, WinWidth, 1, Texture'UWindow.WhiteTexture');
}

    
function SetFace(Texture newFace, Region _r)
{
    m_OperativeFace.T = newFace;
    m_OperativeFace.R = _r;
}

defaultproperties
{
}
