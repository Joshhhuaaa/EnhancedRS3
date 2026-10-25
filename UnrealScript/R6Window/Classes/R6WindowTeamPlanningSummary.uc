//=============================================================================
//  R6WindowTeamPlanningSummary.uc : Top of each team summary in Execute screen
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/13 * Created by Alexandre Dionne
//=============================================================================


class R6WindowTeamPlanningSummary extends UWindowWindow;

var R6WindowTextLabel m_Team, m_GoCode, m_WayPoint, m_GoCodeVal, m_WayPointVal;

var Texture           m_TTopBG;
var Region            m_RTopBG;
var FLOAT             m_fTopBGHeight;

var FLOAT             m_fLabelXOffset, m_fVlabelWidth;

var BYTE              m_BTopAlpha;
var BYTE              m_BBottomAlpha;

var Color             m_CDarkTeamColor;

function Created()
{
    local Float labelWidth, RightLabelXPos, fLabelHeight;

    
    labelWidth  =   WinWidth  - (2 * m_fLabelXOffset) - m_fVlabelWidth;
    RightLabelXPos = WinWidth - m_fVlabelWidth;
    fLabelHeight = (WinHeight - m_fTopBGHeight) /2;

    m_Team                       = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 0, 0, WinWidth, m_fTopBGHeight, self));
    m_Team.m_bDrawBorders        = False;
    m_Team.Align                 = TA_CENTER;
    m_Team.TextColor             = Root.Colors.White;
    m_Team.m_Font                = Root.Fonts[F_MainButton];
    m_Team.m_BGTexture           = None;
    m_Team.m_bFixedYPos          = true;
    m_Team.TextY                 = 2;

    
    m_GoCode                     = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', m_fLabelXOffset, m_fTopBGHeight, labelWidth, fLabelHeight, self));
    m_GoCode.m_bDrawBorders      = false;
    m_GoCode.Align               = TA_LEFT;
    m_GoCode.TextColor           = Root.Colors.White;
    m_GoCode.m_Font              = Root.Fonts[F_SmallTitle];
    m_GoCode.m_BGTexture         = None;
    m_GoCode.Text                = Localize("ExecuteMenu","GOCODE","R6Menu");
    m_GoCode.m_fLMarge           = 2;    

    m_WayPoint                   = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', m_fLabelXOffset, m_GoCode.WinTop + m_GoCode.WinHeight, labelWidth, fLabelHeight, self));
    m_WayPoint.m_bDrawBorders    = false;
    m_WayPoint.Align             = TA_LEFT;
    m_WayPoint.TextColor         = Root.Colors.White;
    m_WayPoint.m_Font            = Root.Fonts[F_SmallTitle];
    m_WayPoint.m_BGTexture       = None; 
    m_WayPoint.Text              = Localize("ExecuteMenu","WAYPOINT","R6Menu");
    m_WayPoint.m_fLMarge         = m_GoCode.m_fLMarge;   
    

    m_GoCodeVal                  = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', RightLabelXPos, m_GoCode.WinTop, m_fVlabelWidth, fLabelHeight, self));
    m_GoCodeVal.m_bDrawBorders   = false;
    m_GoCodeVal.Align            = TA_CENTER;    
    m_GoCodeVal.TextColor        = Root.Colors.White;
    m_GoCodeVal.m_Font           = Root.Fonts[F_SmallTitle];
    m_GoCodeVal.m_BGTexture      = None;     

    m_WayPointVal                = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', RightLabelXPos, m_WayPoint.WinTop, m_fVlabelWidth, fLabelHeight, self));
    m_WayPointVal.m_bDrawBorders = false;
    m_WayPointVal.Align          = TA_CENTER;    
    m_WayPointVal.TextColor      = Root.Colors.White;
    m_WayPointVal.m_Font         = Root.Fonts[F_SmallTitle];
    m_WayPointVal.m_BGTexture    = None;     

}

function SetTeamColor( Color _c, Color _DarkColor)
{
    m_Team.TextColor        = _c;
    m_GoCode.TextColor      = _c;
    m_WayPoint.TextColor    = _c;
    m_GoCodeVal.TextColor   = _c;   
    m_WayPointVal.TextColor = _c;
    m_BorderColor           = _c;
    m_CDarkTeamColor        = _DarkColor;
}


function SetPlanningValues( string szWayPoint, string szGoCode)
{    
    m_WayPointVal.SetNewText(szWayPoint, true);
    m_GoCodeVal.SetNewText(szGoCode, true);
    
}


function SetTeamName( string szTeamName)
{
    m_Team.SetNewText(szTeamName, true);
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{    
  
    //Draw top Label background
    C.Style = ERenderStyle.STY_Alpha;
    C.SetDrawColor(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B, m_BTopAlpha);
    DrawStretchedTexture( C, 0, 0, WinWidth, m_fTopBGHeight, m_TTopBG );

    C.SetDrawColor(m_CDarkTeamColor.R, m_CDarkTeamColor.G, m_CDarkTeamColor.B, m_BBottomAlpha);
    DrawStretchedTexture( C, 0, m_fTopBGHeight, WinWidth, WinHeight - m_fTopBGHeight, m_TTopBG );

    //Draw Middle Line
    C.Style = ERenderStyle.STY_Normal;
    C.SetDrawColor(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B, m_BorderColor.A);
    DrawStretchedTexture( C, 0, m_fTopBGHeight, WinWidth, 1, m_TTopBG );   
    
    DrawSimpleBorder(C);
}

defaultproperties
{
     m_BTopAlpha=51
     m_BBottomAlpha=128
     m_fTopBGHeight=18.000000
     m_fLabelXOffset=2.000000
     m_fVlabelWidth=35.000000
     m_TTopBG=Texture'UWindow.WhiteTexture'
     m_RTopBG=(W=10,H=10)
}
