//=============================================================================
//  R6GameColors.uc : Define for all game colors, this will assure unifications of colors
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/05/13 * Created by Alexandre Dionne
//=============================================================================

class R6GameColors extends Object
	native;

var config Color   Black,
            BlueLight,
            Blue,
            BlueDark,
            Gold,
            GrayDark,
            GrayLight,
			GreenLight,
            Green,
			GreenDark,
            Orange,
			RedLight,
            Red,
			RedDark,
            White,
            Yellow;

// colors for the player's HUD
var config Color   TeamHUDColor[3]; 
var config Color   HUDWhite; // White with transparency
var config Color   HUDGrey;  // Grey with transparency

// colors to be used for the menus
var config Color   TeamColor[3];           //RED, GREEN, GOLD
var config Color   TeamColorLight[3];
var config Color   TeamColorDark[3];

var config Color   ButtonTextColor[4];                   //Normal, Disabled, Over, Selected

var config Color   ToolTipColor;		                 //the tooltip color for the menu

var config INT     PopUpAlphaFactor;                     //50% transparent for all pop ups in planning 

var config Color   m_cBGPopUpContour, m_cBGPopUpWindow;  //Pop up back ground color

var config Color   m_ComboBGColor;                       //Combo box fill up background color

var config INT     EditBoxSelectAllAlpha;
var config INT     DarkBGAlpha;

//*********************************
//List Box
//*********************************
var config Color m_LisBoxNormalTextColor, m_LisBoxSelectedTextColor, m_LisBoxSeparatorTextColor, m_LisBoxSelectionColor, m_LisBoxDisabledTextColor, m_LisBoxSpectatorTextColor;

defaultproperties
{
     PopUpAlphaFactor=128
     EditBoxSelectAllAlpha=132
     DarkBGAlpha=77
     BlueLight=(B=239,G=209,R=129)
     Blue=(B=195,G=125,R=90)
     BlueDark=(B=50,G=30,R=25)
     Gold=(B=95,G=140,R=155)
     GrayDark=(B=50,G=50,R=50)
     GrayLight=(B=120,G=120,R=120)
     GreenLight=(B=112,G=168,R=119)
     Green=(G=182,R=60)
     GreenDark=(G=43,R=4)
     Orange=(G=192,R=255)
     RedLight=(B=142,G=150,R=255)
     Red=(R=182)
     RedDark=(B=8,G=6,R=47)
     White=(B=255,G=255,R=255)
     Yellow=(G=255,R=255)
     TeamHUDColor(0)=(B=9,G=31,R=196,A=75)
     TeamHUDColor(1)=(B=60,G=200,R=60,A=50)
     TeamHUDColor(2)=(B=8,G=165,R=216,A=50)
     HUDWhite=(B=255,G=255,R=255,A=255)
     HUDGrey=(B=255,G=255,R=255,A=100)
     TeamColor(0)=(R=182,A=255)
     TeamColor(1)=(G=182,R=60,A=255)
     TeamColor(2)=(G=150,R=204,A=255)
     TeamColorLight(0)=(B=51,G=64,R=215,A=255)
     TeamColorLight(1)=(B=51,G=215,R=94,A=255)
     TeamColorLight(2)=(B=51,G=184,R=215,A=255)
     TeamColorDark(0)=(R=51,A=255)
     TeamColorDark(1)=(G=51,R=17,A=255)
     TeamColorDark(2)=(G=60,R=82,A=255)
     ButtonTextColor(0)=(B=255,G=255,R=255)
     ButtonTextColor(1)=(B=120,G=120,R=120)
     ButtonTextColor(2)=(B=239,G=209,R=129)
     ButtonTextColor(3)=(B=239,G=209,R=129)
     ToolTipColor=(B=190,G=190,R=190)
     m_cBGPopUpContour=(A=180)
     m_ComboBGColor=(B=50,G=30,R=25)
     m_LisBoxNormalTextColor=(B=255,G=255,R=255)
     m_LisBoxSelectedTextColor=(B=255,G=255,R=255)
     m_LisBoxSeparatorTextColor=(B=239,G=209,R=129)
     m_LisBoxSelectionColor=(B=195,G=125,R=90)
     m_LisBoxDisabledTextColor=(B=120,G=120,R=120)
     m_LisBoxSpectatorTextColor=(B=120,G=120,R=120)
}
