//=============================================================================
//  R6WindowListBoxCreditsItem.uc : list box credits item
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/01/08 * Created by Yannick Joly
//=============================================================================

class R6WindowListBoxCreditsItem extends UWindowList;

var Font	m_Font;
var Color   m_TextColor;

var string	m_szName;

var FLOAT   m_fHeight;

var INT		m_iFont;							// a int because we not have access to root to specify the font
var INT		m_iColor;							// a int because we not have access to root to specify the color

var INT		m_iXPosOffset;						// the offset of the text in this item
var INT		m_iYPosOffset;						// the offset of the text in this item

var BOOL    m_bDrawALineUnderText;
var BOOL	m_bConvertItemValue;

function Init( string _szCreditsLine)
{
	local string szTemp;
	local INT iMarkerPos1, iMarkerPos2;

	szTemp = _szCreditsLine;

	// decompose the creditsline to see what's to display
	iMarkerPos1 = InStr( szTemp, "[");

	if (iMarkerPos1 == -1)
	{
#ifdefDEBUG	log("CreditsName: "@_szCreditsLine@"was not valid!!! Should be on the form CreditsName=[T0]text"); #endif
		return;
	}

	iMarkerPos2 = InStr( szTemp, "]");

	if (iMarkerPos2 == -1)
	{
#ifdefDEBUG	log("CreditsName: "@_szCreditsLine@"was not valid!!! Should be on the form CreditsName=[T0]text"); #endif
		return;
	}

	iMarkerPos1+=1; // increment by 1 to elimitate the "["
	
	szTemp = Mid( szTemp, iMarkerPos1, iMarkerPos2 - iMarkerPos1);

	iMarkerPos2+=1; // increment by 1 to elimitate the "]"

	switch( szTemp)
	{
		case "T0": // TEMPLATE T0
			m_szName  = Mid(_szCreditsLine, iMarkerPos2);
			m_fHeight = 40;
			m_iFont	  = F_MenuMainTitle;
			m_iColor  = 0; // BlueLight
			m_bDrawALineUnderText = true;
			break;

		case "T1": // TEMPLATE T1
			m_szName  = Mid(_szCreditsLine, iMarkerPos2);
			m_fHeight = 20;
			m_iFont	  = F_PrincipalButton;
			m_iColor  = 0; // BlueLight
			break;

		case "T2": // TEMPLATE T2
			m_szName  = Mid(_szCreditsLine, iMarkerPos2);
			m_fHeight = 20;
			m_iFont	  = F_SmallTitle;
			m_iColor  = 1; // White
			break;
		default:
			m_szName  = "";
			m_fHeight = FLOAT(szTemp);
			break;
	}
}

defaultproperties
{
}
