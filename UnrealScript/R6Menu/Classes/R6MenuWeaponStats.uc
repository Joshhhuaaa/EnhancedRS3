//=============================================================================
//  R6MenuWeaponStats.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/02 * Created by Alexandre Dionne
//=============================================================================


class R6MenuWeaponStats extends UWindowWindow;

//Stats
var FLOAT m_fInitRangePercent;
var FLOAT m_fInitDamagePercent;
var FLOAT m_fInitAccuracyPercent;
var FLOAT m_fInitRecoilPercent;
var FLOAT m_fInitRecoveryPercent;

var FLOAT m_fRangePercent;
var FLOAT m_fDamagePercent;
var FLOAT m_fAccuracyPercent;
var FLOAT m_fRecoilPercent;
var FLOAT m_fRecoveryPercent;

//Titles
var R6MenuOperativeSkillsLabel  m_TRange;
var R6MenuOperativeSkillsLabel  m_TDamage;
var R6MenuOperativeSkillsLabel  m_TAccuracy;
var R6MenuOperativeSkillsLabel  m_TRecoil;
var R6MenuOperativeSkillsLabel  m_TRecovery;

//LineCharts
var R6MenuOperativeSkillsBitmap  m_LCRange;
var R6MenuOperativeSkillsBitmap  m_LCDamage;
var R6MenuOperativeSkillsBitmap  m_LCAccuracy;
var R6MenuOperativeSkillsBitmap  m_LCRecoil;
var R6MenuOperativeSkillsBitmap  m_LCRecovery;


//Maximum Width for line charts
var FLOAT                        m_fMaxChartWidth;

//Display settings
var FLOAT                        m_fNLeftPadding;        //Horizontal padding where we start drawing from left
var FLOAT                        m_fBetweenLabelPadding; //Horizontal Padding Between the numeric values and the charts
var FLOAT                        m_fTopYPadding;         //Vertical Padding from the top of the window
var FLOAT                        m_fTitleHeight;         //Titles Height
var FLOAT                        m_fYPaddingBetweenElements;  //Vertical Padding Between Lines
var FLOAT                        m_fNumericLabelWidth;

var     BOOL    m_bDrawBorders;                         
var     BOOL    m_bDrawBg;

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
	m_TRange    = CreateTitle( X, Y, W, H, "Range");
	Y += TotItemHeight;
	m_TDamage	= CreateTitle( X, Y, W, H, "Damage");
	Y += TotItemHeight;
	m_TAccuracy = CreateTitle( X, Y, W, H, "Accuracy");
	Y += TotItemHeight;
	m_TRecoil	= CreateTitle( X, Y, W, H, "Recoil"); 
	Y += TotItemHeight;
	m_TRecovery	= CreateTitle( X, Y, W, H, "Recovery");

    //Calculate Max size that a line chart take
    m_fMaxChartWidth = class'R6MenuOperativeSkillsBitmap'.Default.R.W; //WinWidth - m_NAssault.WinWidth - m_fNLeftPadding - m_fBetweenLabelPadding; 

	Offset = m_fTitleHeight + m_fYPaddingBetweenElements;
    Y = m_TRange.WinTop + Offset;
	H = class'R6MenuOperativeSkillsBitmap'.Default.R.H;

    //LineCharts
    m_LCRange=R6MenuOperativeSkillsBitmap(CreateWindow(class'R6MenuOperativeSkillsBitmap', X, Y, W, H, self));
    Y= m_TDamage.WinTop + Offset;
    m_LCDamage=R6MenuOperativeSkillsBitmap(CreateWindow(class'R6MenuOperativeSkillsBitmap',X, Y, W, H, self));
    Y= m_TAccuracy.WinTop + Offset;
    m_LCAccuracy=R6MenuOperativeSkillsBitmap(CreateWindow(class'R6MenuOperativeSkillsBitmap',X, Y, W, H, self));
    Y= m_TRecoil.WinTop + Offset;
    m_LCRecoil=R6MenuOperativeSkillsBitmap(CreateWindow(class'R6MenuOperativeSkillsBitmap',X, Y, W, H, self));
    Y= m_TRecovery.WinTop + Offset;
    m_LCRecovery=R6MenuOperativeSkillsBitmap(CreateWindow(class'R6MenuOperativeSkillsBitmap',X, Y, W, H, self));
}

function R6MenuOperativeSkillsLabel CreateTitle( FLOAT _fX, FLOAT _fY, FLOAT _fW, FLOAT _fH, string _szTitle)
{
	local R6MenuOperativeSkillsLabel pWSkillLabel;

	pWSkillLabel = R6MenuOperativeSkillsLabel(CreateWindow(class'R6MenuOperativeSkillsLabel', _fX, _fY, _fW, _fH, self));
	pWSkillLabel.Text = Localize("GearRoom", _szTitle, "R6Menu");
	pWSkillLabel.m_fWidthOfFixArea = 60;
	pWSkillLabel.m_NumericValueColor = Root.Colors.BlueLight;

	return pWSkillLabel;
}

function ResizeCharts( )
{
    //Call this function after you have set the different skills
    //values it will resize every line chart

    if(bshowlog)
    {
        log("////////////////////////////////////////////");
        log("///////  ResizeCharts() Before Fmin  ///////");
        log("////////////////////////////////////////////");
        log("m_fRangePercent"@m_fRangePercent);
        log("m_fDamagePercent"@m_fDamagePercent);
        log("m_fAccuracyPercent"@m_fAccuracyPercent);
        log("m_fRecoilPercent"@m_fRecoilPercent);
        log("m_fRecoveryPercent"@m_fRecoveryPercent);        
        log("////////////////////////////////////////////");
    }

    //First Veryfy that we have valide Values
    m_fRangePercent=    FMin( m_fRangePercent,100.0);
    m_fDamagePercent=   FMin( m_fDamagePercent,100.0);
    m_fAccuracyPercent= FMin( m_fAccuracyPercent,100.0);
    m_fRecoilPercent=   FMin( m_fRecoilPercent,100.0);
    m_fRecoveryPercent= FMin( m_fRecoveryPercent,100.0);
    
	m_TRange.SetNumericValue( INT(m_fInitRangePercent), INT(m_fRangePercent));
	m_TDamage.SetNumericValue( INT(m_fInitDamagePercent), INT(m_fDamagePercent));
	m_TAccuracy.SetNumericValue( INT(m_fInitAccuracyPercent), INT(m_fAccuracyPercent));
	m_TRecoil.SetNumericValue( INT(m_fInitRecoilPercent), INT(m_fRecoilPercent));
	m_TRecovery.SetNumericValue( INT(m_fInitRecoveryPercent), INT(m_fRecoveryPercent));

    //Now we resize the window witch will strech
    //the chart properly

    m_LCRange.WinWidth=    m_fRangePercent* m_fMaxChartWidth/100.00;
    m_LCDamage.WinWidth=   m_fDamagePercent* m_fMaxChartWidth/100.00;
    m_LCAccuracy.WinWidth= m_fAccuracyPercent* m_fMaxChartWidth/100.00;
    m_LCRecoil.WinWidth=   m_fRecoilPercent* m_fMaxChartWidth/100.00;
    m_LCRecovery.WinWidth= m_fRecoveryPercent* m_fMaxChartWidth/100.00;
    
    

}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{    
    if(m_bDrawBg)
    {
        R6WindowLookAndFeel(LookAndFeel).DrawBGShading(Self, C, 0, 0, WinWidth, WinHeight);    
    }

    if(m_bDrawBorders)
        DrawSimpleBorder(C);         
}

defaultproperties
{
     m_bDrawBorders=True
     m_bDrawBG=True
     m_fRangePercent=100.000000
     m_fDamagePercent=100.000000
     m_fAccuracyPercent=100.000000
     m_fRecoilPercent=100.000000
     m_fRecoveryPercent=100.000000
     m_fNLeftPadding=7.000000
     m_fBetweenLabelPadding=7.000000
     m_fTopYPadding=7.000000
     m_fTitleHeight=12.000000
     m_fYPaddingBetweenElements=6.000000
     m_fNumericLabelWidth=30.000000
}
