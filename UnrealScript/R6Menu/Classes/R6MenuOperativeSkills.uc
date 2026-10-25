//=============================================================================
//  R6MenuOperativeSkills.uc : This Window Will display the skills of an operative
//                              and is created by R6MenuOperativeDetailControl
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/19 * Created by Alexandre Dionne
//=============================================================================


class R6MenuOperativeSkills extends UWindowWindow;

//Skills
var FLOAT  m_fAssault;
var FLOAT  m_fDemolitions;
var FLOAT  m_fElectronics;
var FLOAT  m_fSniper;
var FLOAT  m_fStealth;
var FLOAT  m_fSelfControl;
var FLOAT  m_fLeadership;
var FLOAT  m_fObservation;

//Titles
var R6MenuOperativeSkillsLabel  m_TAssault;
var R6MenuOperativeSkillsLabel  m_TDemolitions;
var R6MenuOperativeSkillsLabel  m_TElectronics;
var R6MenuOperativeSkillsLabel  m_TSniper;
var R6MenuOperativeSkillsLabel  m_TStealth;
var R6MenuOperativeSkillsLabel  m_TSelfControl;
var R6MenuOperativeSkillsLabel  m_TLeadership;
var R6MenuOperativeSkillsLabel  m_TObservation;

//LineCharts
var R6MenuOperativeSkillsBitmap  m_LCAssault;
var R6MenuOperativeSkillsBitmap  m_LCDemolitions;
var R6MenuOperativeSkillsBitmap  m_LCElectronics;
var R6MenuOperativeSkillsBitmap  m_LCSniper;
var R6MenuOperativeSkillsBitmap  m_LCStealth;
var R6MenuOperativeSkillsBitmap  m_LCSelfControl;
var R6MenuOperativeSkillsBitmap  m_LCLeadership;
var R6MenuOperativeSkillsBitmap  m_LCObservation;

//Maximum Width for line charts
var FLOAT                        m_fMaxChartWidth;

//Display settings
var FLOAT                        m_fNLeftPadding;        //Horizontal padding where we start drawing from left
var FLOAT                        m_fBetweenLabelPadding; //Horizontal Padding Between the numeric values and the charts
var FLOAT                        m_fTopYPadding;         //Vertical Padding from the top of the window
var FLOAT                        m_fTitleHeight;         //Titles Height
var FLOAT                        m_fYPaddingBetweenElements;  //Vertical Padding Between Lines
var FLOAT                        m_fNumericLabelWidth;

//Debug
var bool                         bshowlog;


function Created()
{
    local FLOAT X, Y, W, H, TotItemHeight, Offset;
    
	X = m_fNLeftPadding;
	Y = m_fTopYPadding;
	W = WinWidth - (2*m_fNLeftPadding);
	H = m_fTitleHeight;
    TotItemHeight = m_fTitleHeight + class'R6MenuOperativeSkillsBitmap'.Default.R.H + (2 * m_fYPaddingBetweenElements);

    //Titles
	m_TAssault      = CreateTitle( X, Y, W, H, "Assault");
	Y += TotItemHeight;
	m_TDemolitions  = CreateTitle( X, Y, W, H, "Demolitions");
	Y += TotItemHeight;
	m_TElectronics  = CreateTitle( X, Y, W, H, "Electronics");
	Y += TotItemHeight;
	m_TSniper		= CreateTitle( X, Y, W, H, "Sniper"); 
	Y += TotItemHeight;
	m_TStealth		= CreateTitle( X, Y, W, H, "Stealth");
	Y += TotItemHeight;
	m_TSelfControl	= CreateTitle( X, Y, W, H, "SelfControl");
	Y += TotItemHeight;
	m_TLeadership	= CreateTitle( X, Y, W, H, "Leadership");
	Y += TotItemHeight;
	m_TObservation	= CreateTitle( X, Y, W, H, "Observation");

    //Calculate Max size that a line chart take
    m_fMaxChartWidth = class'R6MenuOperativeSkillsBitmap'.Default.R.W; //WinWidth - m_NAssault.WinWidth - m_fNLeftPadding - m_fBetweenLabelPadding; 

	Offset = m_fTitleHeight + m_fYPaddingBetweenElements;
    Y = m_TAssault.WinTop + Offset;
	H = class'R6MenuOperativeSkillsBitmap'.Default.R.H;

    //LineCharts
    m_LCAssault=R6MenuOperativeSkillsBitmap(CreateWindow(class'R6MenuOperativeSkillsBitmap', X, Y, W, H, self));
    Y= m_TDemolitions.WinTop + Offset;
    m_LCDemolitions=R6MenuOperativeSkillsBitmap(CreateWindow(class'R6MenuOperativeSkillsBitmap',X, Y, W, H, self));
    Y= m_TElectronics.WinTop + Offset;
    m_LCElectronics=R6MenuOperativeSkillsBitmap(CreateWindow(class'R6MenuOperativeSkillsBitmap',X, Y, W, H, self));
    Y= m_TSniper.WinTop + Offset;
    m_LCSniper=R6MenuOperativeSkillsBitmap(CreateWindow(class'R6MenuOperativeSkillsBitmap',X, Y, W, H, self));
    Y= m_TStealth.WinTop + Offset;
    m_LCStealth=R6MenuOperativeSkillsBitmap(CreateWindow(class'R6MenuOperativeSkillsBitmap',X, Y, W, H, self));
    Y= m_TSelfControl.WinTop + Offset;
    m_LCSelfControl=R6MenuOperativeSkillsBitmap(CreateWindow(class'R6MenuOperativeSkillsBitmap',X, Y, W, H, self));
    Y= m_TLeadership.WinTop + Offset;
    m_LCLeadership=R6MenuOperativeSkillsBitmap(CreateWindow(class'R6MenuOperativeSkillsBitmap',X, Y, W, H, self));
    Y= m_TObservation.WinTop + Offset;
    m_LCObservation=R6MenuOperativeSkillsBitmap(CreateWindow(class'R6MenuOperativeSkillsBitmap',X, Y, W, H, self));
}

function R6MenuOperativeSkillsLabel CreateTitle( FLOAT _fX, FLOAT _fY, FLOAT _fW, FLOAT _fH, string _szTitle)
{
	local R6MenuOperativeSkillsLabel pWSkillLabel;

	pWSkillLabel = R6MenuOperativeSkillsLabel(CreateWindow(class'R6MenuOperativeSkillsLabel', _fX, _fY, _fW, _fH, self));
	pWSkillLabel.Text = Localize("R6Operative", _szTitle, "R6Menu");
	pWSkillLabel.m_fWidthOfFixArea = 60;
	pWSkillLabel.m_NumericValueColor = Root.Colors.BlueLight;

	return pWSkillLabel;
}


function ResizeCharts( R6Operative _CurrentOperative)
{
    //Call this function after you have set the different skills
    //values it will resize every line chart

#ifdefDEBUG
    if(bshowlog)
    {
        log("////////////////////////////////////////////");
        log("///////  ResizeCharts() Before Fmin  ///////");
        log("////////////////////////////////////////////");
        log("m_fAssault"@m_fAssault);
        log("m_fDemolitions"@m_fDemolitions);
        log("m_fElectronics"@m_fElectronics);
        log("m_fSniper"@m_fSniper);
        log("m_fStealth"@m_fStealth);
        log("m_fSelfControl"@m_fSelfControl);
        log("m_fLeadership"@m_fLeadership);
        log("m_fObservation"@m_fObservation);
        log("////////////////////////////////////////////");
    }
#endif

    //First Veryfy that we have valide Values
    m_fAssault=     FMin( m_fAssault + 0.5,100.0);
    m_fDemolitions= FMin( m_fDemolitions + 0.5,100.0);
    m_fElectronics= FMin( m_fElectronics + 0.5,100.0);
    m_fSniper=      FMin( m_fSniper + 0.5,100.0);
    m_fStealth=     FMin( m_fStealth + 0.5,100.0);
    m_fSelfControl= FMin( m_fSelfControl + 0.5,100.0);
    m_fLeadership=  FMin( m_fLeadership + 0.5,100.0);
    m_fObservation= FMin( m_fObservation + 0.5,100.0);

    //Put the right text in the Labels
#ifdefDEBUG
    if(bshowlog)
    {
	log("_CurrentOperative.Default.m_szOperativeClass "@_CurrentOperative.Default.m_szOperativeClass);
	log("_CurrentOperative.Default.m_fAssault"@_CurrentOperative.Default.m_fAssault@m_fAssault);
	log("_CurrentOperative.Default.m_fDemolitions"@_CurrentOperative.Default.m_fDemolitions@m_fDemolitions);
	log("_CurrentOperative.Default.m_fElectronics"@_CurrentOperative.Default.m_fElectronics@m_fElectronics);
	log("_CurrentOperative.Default.m_fSniper"@_CurrentOperative.Default.m_fSniper@m_fSniper);
	log("_CurrentOperative.Default.m_fStealth"@_CurrentOperative.Default.m_fStealth@m_fStealth);
	log("_CurrentOperative.Default.m_fSelfControl"@_CurrentOperative.Default.m_fSelfControl@m_fSelfControl);
	log("_CurrentOperative.Default.m_fLeadership"@_CurrentOperative.Default.m_fLeadership@m_fLeadership);
	log("_CurrentOperative.Default.m_fObservation"@_CurrentOperative.Default.m_fObservation@m_fObservation);
	}
#endif

	m_TAssault.SetNumericValue( INT(_CurrentOperative.Default.m_fAssault + 0.5), INT(m_fAssault));
	m_TDemolitions.SetNumericValue( INT(_CurrentOperative.Default.m_fDemolitions + 0.5), INT(m_fDemolitions));
	m_TElectronics.SetNumericValue( INT(_CurrentOperative.Default.m_fElectronics + 0.5), INT(m_fElectronics));
	m_TSniper.SetNumericValue( INT(_CurrentOperative.Default.m_fSniper + 0.5), INT(m_fSniper));
	m_TStealth.SetNumericValue( INT(_CurrentOperative.Default.m_fStealth + 0.5), INT(m_fStealth));
	m_TSelfControl.SetNumericValue( INT(_CurrentOperative.Default.m_fSelfControl + 0.5), INT(m_fSelfControl));
	m_TLeadership.SetNumericValue( INT(_CurrentOperative.Default.m_fLeadership + 0.5), INT(m_fLeadership));
	m_TObservation.SetNumericValue( INT(_CurrentOperative.Default.m_fObservation + 0.5), INT(m_fObservation));

    //Now we resize the window witch will strech
    //the chart properly

    m_LCAssault.WinWidth=       m_fAssault* m_fMaxChartWidth/100.00;
    m_LCDemolitions.WinWidth=   m_fDemolitions* m_fMaxChartWidth/100.00;
    m_LCElectronics.WinWidth=   m_fElectronics* m_fMaxChartWidth/100.00;
    m_LCSniper.WinWidth=        m_fSniper* m_fMaxChartWidth/100.00;
    m_LCStealth.WinWidth=       m_fStealth* m_fMaxChartWidth/100.00;
    m_LCSelfControl.WinWidth=   m_fSelfControl* m_fMaxChartWidth/100.00;
    m_LCLeadership.WinWidth=    m_fLeadership* m_fMaxChartWidth/100.00;
    m_LCObservation.WinWidth=   m_fObservation* m_fMaxChartWidth/100.00;

#ifdefDEBUG
    if(bshowlog)
    {
        log("////////////////////////////////////");
        log("///////   ResizeCharts()     ///////");
        log("////////////////////////////////////");
        log("m_fMaxChartWidth"@m_fMaxChartWidth);       
        
        log("m_fAssault"@m_fAssault);    
        log("m_LCAssault.WinWidth"@m_LCAssault.WinWidth);
        
        log("m_fDemolitions"@m_fDemolitions);    
        log("m_LCDemolitions.WinWidth"@m_LCDemolitions.WinWidth);

        log("m_fElectronics"@m_fElectronics);    
        log("m_LCElectronics.WinWidth"@m_LCElectronics.WinWidth);

        log("////////////////////////////////////");
    }
#endif
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{    	
    R6WindowLookAndFeel(LookAndFeel).DrawBGShading(Self, C, 0, 0, WinWidth, WinHeight);    
}

defaultproperties
{
     m_fAssault=100.000000
     m_fDemolitions=100.000000
     m_fElectronics=100.000000
     m_fSniper=100.000000
     m_fStealth=100.000000
     m_fSelfControl=100.000000
     m_fLeadership=100.000000
     m_fObservation=100.000000
     m_fNLeftPadding=7.000000
     m_fBetweenLabelPadding=7.000000
     m_fTopYPadding=7.000000
     m_fTitleHeight=12.000000
     m_fYPaddingBetweenElements=6.000000
     m_fNumericLabelWidth=30.000000
}
