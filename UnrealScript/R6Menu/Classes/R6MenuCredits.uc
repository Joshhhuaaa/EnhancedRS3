//=============================================================================
//  R6MenuCredits.uc : Auto-scroll and display of the credits
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2003/01/08 * Created by Yannick Joly
//=============================================================================
class R6MenuCredits extends UWindowListControl;

var UWindowList							m_FirstItemOnScreen;

var FLOAT								m_fScrollSpeed;
var FLOAT								m_fTexScrollSpeed;
var FLOAT								m_fScrollIndex;
var FLOAT								m_fYScrollEffect;
var FLOAT								m_fDelta;


var INT									m_iScrollIndex;	// The index of the scroll
var INT									m_iScrollStep;

var BOOL								m_bStopScroll;

function Tick(float fDelta)
{
	m_fDelta = fDelta;

	/*
	//#ifdefDEBUG
	m_iScrollStep = 1;

	if ( (m_fDelta * m_fScrollSpeed) > m_iScrollStep)
		m_iScrollStep += 1;
	//#endif
	*/
}

function Paint( Canvas C, FLOAT X, FLOAT Y)
{
	PaintCredits(C);
	PaintTexEffect(C);
}

function PaintTexEffect(Canvas C)
{
	local Texture TexScrollEffect;

	// draw the texture effect
	C.Style = ERenderStyle.STY_Highlight;

	// scroll the texture too 
	TexScrollEffect = texture'R6MenuTextures.Credits.Line';

	if(!m_bStopScroll)
	{
		m_fYScrollEffect -= (m_fDelta * m_fScrollSpeed * 2); 

		if(m_fYScrollEffect < -TexScrollEffect.VSize)
			m_fYScrollEffect += TexScrollEffect.VSize;
	}

	C.SetDrawColor( Root.Colors.White.R, Root.Colors.White.G, Root.Colors.White.B);

	C.SetPos( 0, 0);
    C.DrawTile( TexScrollEffect, WinWidth, WinHeight, 0, m_fYScrollEffect, TexScrollEffect.USize, TexScrollEffect.VSize);
}

function PaintCredits( Canvas C)
{
	local UWindowList CurItem;
	local R6WindowListBoxCreditsItem R6CurItem;
	local FLOAT y1, iCurrentYPos;
	local BOOL bStopNextTime;

	if (m_FirstItemOnScreen == None)
	{
		m_FirstItemOnScreen = Items.Next;
		m_iScrollIndex = 0;
	}
	else if (!m_bStopScroll)
	{
			m_fScrollIndex += (m_fDelta * m_fScrollSpeed);
			
			m_iScrollIndex -= INT(m_fScrollIndex);

			if (m_fScrollIndex > m_iScrollStep)
				m_fScrollIndex = 0;

			if (Abs(m_iScrollIndex) > R6WindowListBoxCreditsItem(m_FirstItemOnScreen).m_fHeight)
			{
				m_FirstItemOnScreen = m_FirstItemOnScreen.Next;
				m_iScrollIndex = -1;
			}

	}

	CurItem = m_FirstItemOnScreen;
	R6CurItem = R6WindowListBoxCreditsItem(CurItem);

	y1 = m_iScrollIndex;

	while(CurItem != None)
	{
		DrawItem(C, CurItem, 0, y1, WinWidth, R6CurItem.m_fHeight);

		y1 = y1 + R6CurItem.m_fHeight;

		CurItem = CurItem.Next;

		if ( (CurItem == None) || (bStopNextTime) )
			break;

		R6CurItem = R6WindowListBoxCreditsItem(CurItem);

		if ( y1 + R6CurItem.m_fHeight > WinHeight)
		{
			// one more draw to do -- it will be clipped by drawitem
			bStopNextTime = true;
		}
	}
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H)
{
	local FLOAT fXPos, fYPos, fW, fH;
	local R6WindowListBoxCreditsItem pItem;

	pItem = R6WindowListBoxCreditsItem( Item);

	if (!pItem.m_bConvertItemValue)
	{
		if (!ConvertItemValue( C, pItem))
			return;

		pItem.m_bConvertItemValue = true;
	}

	C.Style = ERenderStyle.STY_Alpha;
	C.Font = pItem.m_Font;

#ifdefDEBUG
    if (C.Font == None)    
    {
		log("Font for"@pItem.m_szName@"is none");
		pItem.m_Font = Root.Fonts[F_SmallTitle];
		C.Font = Root.Fonts[F_SmallTitle];
	}
#endif

	C.SetDrawColor( pItem.m_TextColor.R, pItem.m_TextColor.G, pItem.m_TextColor.B, 225);

	fXPos = X + pItem.m_iXPosOffset;
	fYPos = Y + pItem.m_iYPosOffset;

	//	if (pItem.m_CLItem.szName )
	ClipText( C, fXPos, fYPos, pItem.m_szName); 

	if (pItem.m_bDrawALineUnderText)
	{
		TextSize( C, pItem.m_szName, fW, fH);
		fYPos += fH;

		if ( (fYPos > 0) && (fYPos < WinHeight))
		{
			DrawStretchedTextureSegment(C, fXPos, fYPos, fW, m_BorderTextureRegion.H , 
										   m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
		}
	}
}

function BOOL ConvertItemValue( Canvas C, out R6WindowListBoxCreditsItem _pItemToConvert)
{
	local string szTemp;
	local FLOAT fTemp, fTextW, fTextH;

	if (_pItemToConvert == None)
		return false;

	// set the font
	_pItemToConvert.m_Font = Root.Fonts[_pItemToConvert.m_iFont];

	// set the color
	switch( _pItemToConvert.m_iColor)
	{
		case 0: 
			_pItemToConvert.m_TextColor = Root.Colors.BlueLight;
			break;
		case 1:
			_pItemToConvert.m_TextColor = Root.Colors.White;
			break;
		default:
			_pItemToConvert.m_TextColor = Root.Colors.White;
			break;
	}

	C.Font = _pItemToConvert.m_Font;

	// align the text
	szTemp = _pItemToConvert.m_szName;
	szTemp = TextSize( C, szTemp, fTextW, fTextH, WinWidth);
	_pItemToConvert.m_szName = szTemp; // clipping done

	// in x
	fTemp = (WinWidth - fTextW) / 2;
	_pItemToConvert.m_iXPosOffset = INT(fTemp + 0.5);

	// in y
	fTemp = (_pItemToConvert.m_fHeight - fTextH) / 2;
	_pItemToConvert.m_iYPosOffset = INT(fTemp + 0.5);

	return true;
}

function ResetCredits()
{
	m_FirstItemOnScreen = None;
	
	m_fScrollIndex = 0;
	m_fYScrollEffect = 0;
	m_bStopScroll = false;
}

defaultproperties
{
     m_iScrollStep=1
     m_fScrollSpeed=25.000000
     m_fTexScrollSpeed=1.000000
     ListClass=Class'R6Window.R6WindowListBoxCreditsItem'
}
