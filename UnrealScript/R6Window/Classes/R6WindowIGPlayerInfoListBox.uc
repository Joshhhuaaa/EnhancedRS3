//=============================================================================
//  R6WindowIGPlayerInfoListBox : Class used to manage the "list box" of players
//      in the in game menus.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/27 * Created by John Bennett
//=============================================================================

class R6WindowIGPlayerInfoListBox extends R6WindowListBox;


var Color   m_BGSelColor;       // BackGround color when selected
var Texture m_BGSelTexture;     // BackGround texture under item when selected
var Region  m_BGSelRegion;      // BackGround texture Region under item when selected
var ERenderStyle m_BGRenderStyle;

//var color   TextColor;          // color for text            N.B. var already define in class UWindowDialogControl
var Color   m_SelTextColor;     // color for selected text
var Color   m_SpectatorColor;	// if the player is a spectator

var Font    m_Font;

var INT		m_fYOffset;			// the initial Y offset

function Created()
{
	Super.Created();
	
    m_Font = Root.Fonts[F_ListItemBig];

    m_VertSB.LookAndFeel = LookAndFeel;
    m_VertSB.UpButton.LookAndFeel = LookAndFeel;
    m_VertSB.DownButton.LookAndFeel = LookAndFeel;
    m_VertSB.SetHideWhenDisable(true);

    TextColor           = Root.Colors.m_LisBoxNormalTextColor;
    m_SelTextColor      = Root.Colors.m_LisBoxSelectedTextColor;
    m_SpectatorColor    = Root.Colors.m_LisBoxSpectatorTextColor;
    m_BGSelColor        = Root.Colors.m_LisBoxSelectionColor;
    m_BGRenderStyle     = ERenderStyle.STY_Alpha;
}


function BeforePaint(Canvas C, FLOAT fMouseX, FLOAT fMouseY)
{    

    m_VertSB.SetBorderColor(m_BorderColor);
    Super.BeforePaint(C, fMouseX, fMouseY);
}


function DrawItem(Canvas C, UWindowList Item, FLOAT X, FLOAT Y, FLOAT W, FLOAT H)
{
	local string szTemp;
	local float TextY, TW,TH, fTemp, fYPos;
	local R6WindowListIGPlayerInfoItem pItem;

	pItem = R6WindowListIGPlayerInfoItem(Item);

    if( pItem.bOwnPlayer )
	{		
        C.SetDrawColor(Root.Colors.BlueLight.r,Root.Colors.BlueLight.g,Root.Colors.BlueLight.b);
	}
	else if (pItem.eStatus == pItem.ePlStatus.ePlayerStatus_Spectator)
	{
		C.SetDrawColor(m_SpectatorColor.r,m_SpectatorColor.g,m_SpectatorColor.b);
	}
	else
	{
		C.SetDrawColor(TextColor.r,TextColor.g,TextColor.b);

	}

    C.Style = ERenderStyle.STY_Alpha;
	C.Font = m_Font;

	szTemp = TextSize(C, pItem.szPlName, TW, TH, pItem.stTagCoord[pItem.ePLInfo.ePL_Name].fWidth - 2);
	

	TextY = (H - TH) / 2;
    TextY = FLOAT(INT(TextY+0.5));

    fYPos = Y + TextY + m_fYOffset;

    // Draw the text
	// READY
	if(pItem.bReady)
	{
		DrawIcon( C, 6, pItem.stTagCoord[pItem.ePLInfo.ePL_Ready].fXPos, fYPos, 
						pItem.stTagCoord[pItem.ePLInfo.ePL_Ready].fWidth, H);
	}
	else
	{
		DrawIcon( C, 5, pItem.stTagCoord[pItem.ePLInfo.ePL_Ready].fXPos, fYPos, 
						pItem.stTagCoord[pItem.ePLInfo.ePL_Ready].fWidth, H);
	}

	// HEALTH
	if (pItem.eStatus != pItem.ePlStatus.ePlayerStatus_TooLate)
		DrawIcon( C, pItem.GetHealth( pItem.eStatus), 
					 pItem.stTagCoord[pItem.ePLInfo.ePL_HealthStatus].fXPos, fYPos, 
					 pItem.stTagCoord[pItem.ePLInfo.ePL_HealthStatus].fWidth, H);

	// NAME
    C.SetPos( pItem.stTagCoord[pItem.ePLInfo.ePL_Name].fXPos + 2, fYPos ); // + 2 corresponding to the margin, to be align with the title
    C.DrawText(szTemp);

	// ROUNDS WON
	if ( pItem.stTagCoord[pItem.ePLInfo.ePL_RoundsWon].bDisplay)
	{
		szTemp = TextSize(C, pItem.szRoundsWon, TW, TH, pItem.stTagCoord[pItem.ePLInfo.ePL_RoundsWon].fWidth);
		fTemp = pItem.stTagCoord[pItem.ePLInfo.ePL_RoundsWon].fXPos + GetCenterXPos( pItem.stTagCoord[pItem.ePLInfo.ePL_RoundsWon].fWidth, TW);
		C.SetPos( fTemp,  fYPos);
		C.DrawText(szTemp);
	}

	// KILLS
	szTemp = TextSize(C, string(pItem.iKills), TW, TH, pItem.stTagCoord[pItem.ePLInfo.ePL_Kill].fWidth);
    fTemp = pItem.stTagCoord[pItem.ePLInfo.ePL_Kill].fXPos + GetCenterXPos( pItem.stTagCoord[pItem.ePLInfo.ePL_Kill].fWidth, TW);
    C.SetPos( fTemp,  fYPos);
    C.DrawText(szTemp);

	// DEATHS
	szTemp = TextSize(C, string(pItem.iMyDeadCounter), TW, TH, pItem.stTagCoord[pItem.ePLInfo.ePL_DeadCounter].fWidth);
    fTemp = pItem.stTagCoord[pItem.ePLInfo.ePL_DeadCounter].fXPos + GetCenterXPos( pItem.stTagCoord[pItem.ePLInfo.ePL_DeadCounter].fWidth, TW);
    C.SetPos( fTemp,  fYPos);
    C.DrawText(szTemp);

	// EFFICIENTY
	szTemp = TextSize(C, string(pItem.iEfficiency), TW, TH, pItem.stTagCoord[pItem.ePLInfo.ePL_Efficiency].fWidth);
    fTemp = pItem.stTagCoord[pItem.ePLInfo.ePL_Efficiency].fXPos + GetCenterXPos( pItem.stTagCoord[pItem.ePLInfo.ePL_Efficiency].fWidth, TW);
    C.SetPos( fTemp,  fYPos);
    C.DrawText(szTemp);

	// ROUNDS FIRED
	szTemp = TextSize(C, string(pItem.iRoundsFired), TW, TH, pItem.stTagCoord[pItem.ePLInfo.ePL_RoundFired].fWidth);
    fTemp = pItem.stTagCoord[pItem.ePLInfo.ePL_RoundFired].fXPos + GetCenterXPos( pItem.stTagCoord[pItem.ePLInfo.ePL_RoundFired].fWidth, TW);
    C.SetPos( fTemp,  fYPos);
    C.DrawText(szTemp);

	// ROUND TAKEN
	szTemp = TextSize(C, string(pItem.iRoundsHit), TW, TH, pItem.stTagCoord[pItem.ePLInfo.ePL_RoundHit].fWidth);
    fTemp = pItem.stTagCoord[pItem.ePLInfo.ePL_RoundHit].fXPos + GetCenterXPos( pItem.stTagCoord[pItem.ePLInfo.ePL_RoundHit].fWidth, TW);
    C.SetPos( fTemp,  fYPos);
    C.DrawText(szTemp);

	// KILLER NAME
	szTemp = TextSize(C, pItem.szKillBy, TW, TH, pItem.stTagCoord[pItem.ePLInfo.ePL_KillerName].fWidth - 2);
    C.SetPos( pItem.stTagCoord[pItem.ePLInfo.ePL_KillerName].fXPos + 2,  fYPos); // + 2 corresponding to the margin, to be align with the title 
    C.DrawText(szTemp);

	// PING TIME
	szTemp = TextSize(C, string(pItem.iPingTime), TW, TH, pItem.stTagCoord[pItem.ePLInfo.ePL_PingTime].fWidth - 2); //-2 for border line
    fTemp = pItem.stTagCoord[pItem.ePLInfo.ePL_PingTime].fXPos + GetCenterXPos( pItem.stTagCoord[pItem.ePLInfo.ePL_PingTime].fWidth, TW);
    C.SetPos( fTemp,  fYPos);
    C.DrawText(szTemp);
}

function DrawIcon( Canvas C, INT _iPlayerStats, FLOAT _fX, FLOAT _fY, FLOAT _fWidth, FLOAT _fHeight)
{
    local Region RIconRegion, RIconToDraw;

	switch( _iPlayerStats)
	{
		case 0: // ePlayerStatus_Alive
			RIconToDraw.X = 31;
		    RIconToDraw.Y = 29;
		    RIconToDraw.W = 10;
		    RIconToDraw.H = 10;
			break;
		case 1: // ePlayerStatus_Wounded
			RIconToDraw.X = 42;
			RIconToDraw.Y = 29;
			RIconToDraw.W = 10;
			RIconToDraw.H = 10;
			break;
        case 2: // ePlayerStatus_Incapacitated
		case 3: // ePlayerStatus_Dead
			RIconToDraw.X = 53;
			RIconToDraw.Y = 29;
			RIconToDraw.W = 10;
			RIconToDraw.H = 10;
			break;
		case 4: // ePlayerStatus_Spectator
			RIconToDraw.X = 13;
			RIconToDraw.Y = 53;
			RIconToDraw.W = 13;
			RIconToDraw.H = 11;
			break;
		case 5: // disable READY
			RIconToDraw.X = 42;
			RIconToDraw.Y = 40;
			RIconToDraw.W = 10;
			RIconToDraw.H = 10;
			break;
		case 6: // enable READY
			RIconToDraw.X = 53;
			RIconToDraw.Y = 40;
			RIconToDraw.W = 10;
			RIconToDraw.H = 10;
			break;
	}	

	RIconRegion = CenterIconInBox( _fX, _fY, _fWidth, _fHeight, RIconToDraw);
    DrawStretchedTextureSegment( C, RIconRegion.X, RIconRegion.Y, RIconToDraw.W, RIconToDraw.H, 
                                    RIconToDraw.X, RIconToDraw.Y, RIconToDraw.W, RIconToDraw.H, m_TIcon);
}

defaultproperties
{
     m_fYOffSet=1
     m_BGSelTexture=Texture'R6MenuTextures.Gui_BoxScroll'
     m_BGSelRegion=(X=253,W=2,H=13)
     m_SelTextColor=(B=255,G=255,R=255)
     m_SpectatorColor=(B=255,G=255,R=255)
     m_fItemHeight=11.000000
     m_fSpaceBetItem=0.000000
     ListClass=Class'R6Window.R6WindowListIGPlayerInfoItem'
}
