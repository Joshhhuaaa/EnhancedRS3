//=============================================================================
//  R6MenuMPInterHeader.uc : Intermission widget (when you press start during MP game or 
//  the size of the window is 640 * 480. The part in the top of multi menu in-game
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/25 * Created  Yannick Joly
//=============================================================================
class R6MenuMPInterHeader extends UWindowWindow;

const C_iSERVER_NAME			= 0;
const C_iSERVER_IP				= 1;
const C_iMAP_NAME				= 2;
const C_iGAME_TYPE				= 3;
const C_iROUND					= 4;
const C_iTIME_PER_ROUND			= 5;
const C_iTOT_GREEN_TEAM_VICTORY = 6;
const C_iTOT_RED_TEAM_VICTORY	= 7;
const C_iMISSION_STATUS			= 8;

const C_fXBORDER_OFFSET			= 2;  // 2 in x because the real window is 2 pixel left (1 pixel empty and 1 for the border)
const C_fXTEXT_HEADER_OFFSET	= 4;
const C_fYPOS_OF_TEAMSCORE		= 48;

var R6WindowTextLabelExt            m_pTextHeader;			 // all the names for the header

var string							m_szGameResult[5];

var INT                             m_iIndex[9];			 // array of text label (6 is for nb of server info + 2 for team case + 1 mission status)

var BOOL							m_bDisplayTotVictory;	 // display the win games for each team
var BOOL							m_bDisplayCoopStatus;	 // display the coop mission status 
var BOOL							m_bDisplayCoopBox;

function Created()
{
	m_szGameResult[0] = Localize("MPInGame","AlphaTeamScore","R6Menu");
	m_szGameResult[1] = Localize("MPInGame","BravoTeamScore","R6Menu");
	m_szGameResult[2] = Localize("DebriefingMenu","SUCCESS","R6Menu");
	m_szGameResult[3] = Localize("DebriefingMenu","FAILED","R6Menu");
	m_szGameResult[4] = Localize("MPInGame","MissionInProgress","R6Menu");;

	m_bDisplayCoopBox = false;

    InitTextHeader();
}


function Paint(Canvas C, FLOAT X, FLOAT Y)
{
	local FLOAT fX;

	fX = C_fXBORDER_OFFSET + C_fXTEXT_HEADER_OFFSET;
	// if we are in team deathmatch display number of victory for each team
	if (m_bDisplayTotVictory)
	{
		// GreenTeam
		DrawTeamScore( C, Root.Colors.TeamColor[1], Root.Colors.TeamColorDark[1], 
						  fX, C_fYPOS_OF_TEAMSCORE, (WinWidth * 0.5) - (2 * fX), 14);
		// Red Team
		DrawTeamScore( C, Root.Colors.TeamColor[0], Root.Colors.TeamColorDark[0], 
						  (WinWidth * 0.5) + fX, C_fYPOS_OF_TEAMSCORE, (WinWidth * 0.5) - (2 * fX), 14);
	}
	else if (m_bDisplayCoopBox)
	{
		DrawTeamScore( C, m_pTextHeader.GetTextColor(m_iIndex[C_iMISSION_STATUS]), m_pTextHeader.GetTextColor(m_iIndex[C_iMISSION_STATUS]), 
						  fX, C_fYPOS_OF_TEAMSCORE, WinWidth - (2 * fX), 14);
	}
}

//===============================================================================
// DrawTeamScore: Display a box with a background (use for team score and mission progress)
//===============================================================================
function DrawTeamScore( Canvas C, Color _cTeamColor, Color _cBGColor, FLOAT _fX, FLOAT _fY, FLOAT _fW, FLOAT _fH)
{
	DrawSimpleBackGround( C, _fX, _fY, _fW, _fH, _cBGColor);

    C.SetDrawColor(_cTeamColor.R, _cTeamColor.G, _cTeamColor.B);

    //Top
    DrawStretchedTextureSegment(C, _fX, _fY, _fW, m_BorderTextureRegion.H, m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
    //Bottom
    DrawStretchedTextureSegment(C, _fX, _fY + _fH - m_BorderTextureRegion.H, _fW, m_BorderTextureRegion.H , m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
    //Left
    DrawStretchedTextureSegment(C, _fX, _fY + m_BorderTextureRegion.H, m_BorderTextureRegion.W, _fH - (2* m_BorderTextureRegion.H), m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
    //Right
    DrawStretchedTextureSegment(C, _fX + _fW - m_BorderTextureRegion.W, _fY + m_BorderTextureRegion.H, m_BorderTextureRegion.W, _fH - (2* m_BorderTextureRegion.H), m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
}












//===============================================================================
// Init text header
//===============================================================================
function InitTextHeader()
{
    local FLOAT fXOffset, fYOffset, fYStep, fWidth, fHeight, fTemp, fSizeOfCounter;
    local Font ButtonFont;

    // Use text array with R6WindowTextLabelExt
    m_pTextHeader = R6WindowTextLabelExt( CreateWindow(class'R6WindowTextLabelExt', 0, 0, WinWidth, WinHeight, self));
    m_pTextHeader.bAlwaysBehind = true;
    m_pTextHeader.SetNoBorder();

    // text part
    m_pTextHeader.m_Font = Root.Fonts[F_VerySmallTitle];
    m_pTextHeader.m_vTextColor = Root.Colors.White;

    fXOffset = C_fXTEXT_HEADER_OFFSET; // not + C_fXBORDER_OFFSET, because the marge in m_pTextHeader class is already 2 by default
    fYOffset = 4;
    fWidth = WinWidth * 0.5;
    fYStep = 14;
    m_pTextHeader.AddTextLabel( Localize("MPInGame","ServerName","R6Menu"), fXOffset, fYOffset, fWidth, TA_Left, false);
    fYOffset += fYStep;
    m_pTextHeader.AddTextLabel( Localize("MPInGame","ServerIP","R6Menu"), fXOffset, fYOffset, fWidth, TA_Left, false);
    fYOffset += fYStep;
    m_pTextHeader.AddTextLabel( Localize("MPInGame","MapName","R6Menu"), fXOffset, fYOffset, fWidth, TA_Left, false);

    fXOffset = fWidth + C_fXTEXT_HEADER_OFFSET; // not + C_fXBORDER_OFFSET, because the marge in m_pTextHeader class is already 2 by default
    fYOffset = 4;
    m_pTextHeader.AddTextLabel( Localize("MPInGame","GameType","R6Menu"), fXOffset, fYOffset, fWidth, TA_Left, false);
    fYOffset += fYStep;
    m_pTextHeader.AddTextLabel( Localize("MPInGame","Round","R6Menu"), fXOffset, fYOffset, fWidth, TA_Left, false);
    fYOffset += fYStep;
    m_pTextHeader.AddTextLabel( Localize("MPInGame","TimePerRound","R6Menu"), fXOffset, fYOffset, fWidth, TA_Left, false);

    fWidth = WinWidth * 0.25;
    fXOffset = (WinWidth * 0.2);
    fYOffset = 4;
//    fYStep = 15;
    m_pTextHeader.m_vTextColor = Root.Colors.BlueLight;
    m_pTextHeader.m_bUpDownBG = true;
    m_iIndex[C_iSERVER_NAME] = m_pTextHeader.AddTextLabel( "", fXOffset, fYOffset, fWidth, TA_Center, false, 12);
    fYOffset += fYStep;
    m_iIndex[C_iSERVER_IP] = m_pTextHeader.AddTextLabel( "", fXOffset, fYOffset, fWidth, TA_Center, false, 12);
    fYOffset += fYStep;
    m_iIndex[C_iMAP_NAME] = m_pTextHeader.AddTextLabel( "", fXOffset, fYOffset, fWidth, TA_Center, false, 12);

    fXOffset = (WinWidth * 0.5) + fXOffset;
    fYOffset = 4;
    m_iIndex[C_iGAME_TYPE] = m_pTextHeader.AddTextLabel( "", fXOffset, fYOffset, fWidth, TA_Center, false, 12);
    fYOffset += fYStep;
    m_iIndex[C_iROUND] = m_pTextHeader.AddTextLabel( "", fXOffset, fYOffset, fWidth, TA_Center, false, 12);
    fYOffset += fYStep;
    m_iIndex[C_iTIME_PER_ROUND] = m_pTextHeader.AddTextLabel( "", fXOffset, fYOffset, fWidth, TA_Center, false, 12);

	fXOffset = C_fXTEXT_HEADER_OFFSET; // not + C_fXBORDER_OFFSET, because the marge in m_pTextHeader class is already 2 by default
	fYOffset = C_fYPOS_OF_TEAMSCORE + 1; //1 is the offset from the top border
	fWidth = (WinWidth * 0.5) - (2 * fXOffset);
	m_pTextHeader.m_bUpDownBG = false;
    m_pTextHeader.m_vTextColor = Root.Colors.TeamColorLight[1]; // GREEN TEAM
	m_iIndex[C_iTOT_GREEN_TEAM_VICTORY] = m_pTextHeader.AddTextLabel( "", fXOffset, fYOffset, fWidth, TA_Center, false, 14);

	fXOffset = fWidth + 4;
	m_pTextHeader.m_vTextColor = Root.Colors.TeamColorLight[0]; // RED TEAM
	m_iIndex[C_iTOT_RED_TEAM_VICTORY] = m_pTextHeader.AddTextLabel( "", fXOffset, fYOffset, fWidth, TA_Center, false, 14);

	fXOffset = C_fXBORDER_OFFSET + C_fXTEXT_HEADER_OFFSET;
	fWidth	 = WinWidth - (2*fXOffset);
	m_pTextHeader.m_vTextColor = Root.Colors.White; // mission status
	m_iIndex[C_iMISSION_STATUS] = m_pTextHeader.AddTextLabel( "", fXOffset, fYOffset, fWidth, TA_Center, false, 14);
}

//===============================================================================
// Refresh server header info
//===============================================================================
function RefreshInterHeaderInfo()
{
    local R6MenuInGameMultiPlayerRootWindow R6Root;
    local string szIP;
    local string szGameType;
    local string szTemp;
    local FLOAT fCurrentTime;
    local R6GameReplicationInfo r6GameRep;
    local R6MenuMPInterWidget MpInter;

    R6Root = R6MenuInGameMultiPlayerRootWindow(Root);   
 
    
    if (R6Root.m_R6GameMenuCom != None)
    {
		r6GameRep = R6GameReplicationInfo(R6Root.m_R6GameMenuCom.m_GameRepInfo);
		if (r6GameRep == none)
            return;
		
        // The IP will be of the form, 10.10.10.10:1234, just display everything to the left
        // of the ":" (remove the port number).
        szIP = R6Console(Root.console).szStoreIP;  //Left(R6Console(Root.console).szStoreIP,InStr(R6Console(Root.console).szStoreIP,":"));
        m_pTextHeader.ChangeTextLabel( r6GameRep.ServerName, m_iIndex[C_iSERVER_NAME]);
        m_pTextHeader.ChangeTextLabel( szIP, m_iIndex[C_iSERVER_IP]);
		if (!Root.GetMapNameLocalisation( GetLevel().GetURLMap(), szTemp))
			szTemp = GetLevel().GetURLMap();
        m_pTextHeader.ChangeTextLabel( szTemp, m_iIndex[C_iMAP_NAME]);

        szGameType = GetLevel().GetGameNameLocalization( R6Root.m_R6GameMenuCom.GetGameType());
        
        m_pTextHeader.ChangeTextLabel( szGameType, m_iIndex[C_iGAME_TYPE]);

        RefreshRoundInfo();

        MpInter = R6MenuMPInterWidget(OwnerWindow);


		if (R6Root.m_R6GameMenuCom.IsInBetweenRoundMenu())
			fCurrentTime = r6GameRep.TimeLimit;
		else 
			fCurrentTime = r6GameRep.GetRoundTime();

        m_pTextHeader.ChangeTextLabel( class'Actor'.static.ConvertIntTimeToString(fCurrentTime) @ "/" @
 									   class'Actor'.static.ConvertIntTimeToString(r6GameRep.TimeLimit), m_iIndex[C_iTIME_PER_ROUND]);

		if (m_bDisplayTotVictory)
		{
			m_pTextHeader.ChangeTextLabel( m_szGameResult[0] $ " " $ string(r6GameRep.m_aTeamScore[0]), m_iIndex[C_iTOT_GREEN_TEAM_VICTORY]);

			m_pTextHeader.ChangeTextLabel( m_szGameResult[1] $ " " $ string(r6GameRep.m_aTeamScore[1]), m_iIndex[C_iTOT_RED_TEAM_VICTORY]);
		}
		else if (m_bDisplayCoopStatus)
		{
			if ( MpInter.IsMissionInProgress())
			{
				
                if (!R6Root.m_R6GameMenuCom.IsInBetweenRoundMenu( true)) // avoid the display in mission progress
				{
					m_pTextHeader.ChangeColorLabel( Root.Colors.White, m_iIndex[C_iMISSION_STATUS]);
					m_pTextHeader.ChangeTextLabel( m_szGameResult[4], m_iIndex[C_iMISSION_STATUS]);
				}
                else
                {
                    if ( MpInter.GetLastMissionSuccess() == 0)
                        m_pTextHeader.ChangeTextLabel( "", m_iIndex[C_iMISSION_STATUS]);                
				    else if ( R6MenuMPInterWidget(OwnerWindow).GetLastMissionSuccess() == 1)
				    {
					    m_pTextHeader.ChangeColorLabel( Root.Colors.TeamColorLight[1], m_iIndex[C_iMISSION_STATUS]);
					    m_pTextHeader.ChangeTextLabel( m_szGameResult[2], m_iIndex[C_iMISSION_STATUS]);
				    }
				    else
				    {
					    m_pTextHeader.ChangeColorLabel( Root.Colors.TeamColorLight[0], m_iIndex[C_iMISSION_STATUS]);
					    m_pTextHeader.ChangeTextLabel( m_szGameResult[3], m_iIndex[C_iMISSION_STATUS]);
				    }
                    
                }
			}
			else
			{
				if ( MpInter.IsMissionSuccess())
				{
					m_pTextHeader.ChangeColorLabel( Root.Colors.TeamColorLight[1], m_iIndex[C_iMISSION_STATUS]);
					m_pTextHeader.ChangeTextLabel( m_szGameResult[2], m_iIndex[C_iMISSION_STATUS]);
				}
				else
				{
					m_pTextHeader.ChangeColorLabel( Root.Colors.TeamColorLight[0], m_iIndex[C_iMISSION_STATUS]);
					m_pTextHeader.ChangeTextLabel( m_szGameResult[3], m_iIndex[C_iMISSION_STATUS]);
				}
			}

			m_bDisplayCoopBox = (m_pTextHeader.GetTextLabel(m_iIndex[C_iMISSION_STATUS]) != "");
		}
		else
		{
			// in this case display nothing 
			ResetDisplayInfo();
		}

		if (R6Root.m_R6GameMenuCom.IsInBetweenRoundMenu())
		{
            if (r6GameRep.m_bRepMenuCountDownTimePaused)
                R6Root.UpdateTimeInBetRound(0, Localize("MPInGame","PausedMessage","R6Menu"));
            else if (r6GameRep.m_bRepMenuCountDownTimeUnlimited)
                R6Root.UpdateTimeInBetRound(0, Localize("MPInGame","WaitMessage","R6Menu"));
            else
                R6Root.UpdateTimeInBetRound(r6GameRep.GetRoundTime());
		}
		else
		{
			R6Root.UpdateTimeInBetRound(-1);
		}
    }
}

function RefreshRoundInfo()
{
    local R6GameReplicationInfo r6GameRep;
	local R6MenuInGameMultiPlayerRootWindow R6Root;

	R6Root = R6MenuInGameMultiPlayerRootWindow(Root);

	r6GameRep = R6GameReplicationInfo(R6Root.m_R6GameMenuCom.m_GameRepInfo);
	if (r6GameRep == none)
        return;


	// if you`re in a coop game and the option rotate map is on, display this specific string
	if ( GetLevel().IsGameTypeCooperative( R6Root.m_szCurrentGameType) )
	{
		if (r6GameRep.m_bRotateMap)
		{
			m_pTextHeader.ChangeTextLabel( r6GameRep.m_iCurrentRound+1 @ "/ --", m_iIndex[C_iROUND]);
			return;
		}
	}


	if (R6Root.m_R6GameMenuCom.m_GameRepInfo.m_eCurrectServerState == R6Root.m_R6GameMenuCom.m_GameRepInfo.RSS_EndOfMatch)
    {
        m_pTextHeader.ChangeTextLabel( Localize("MPInGame","MatchCompleted","R6Menu"), m_iIndex[C_iROUND]);
    }
	else
	    m_pTextHeader.ChangeTextLabel( r6GameRep.m_iCurrentRound+1 @ "/" @ r6GameRep.m_iRoundsPerMatch, m_iIndex[C_iROUND]);
}

//===============================================================================
// ResetDisplayInfo: 
//===============================================================================
function ResetDisplayInfo()
{
	m_pTextHeader.ChangeTextLabel( "", m_iIndex[C_iTOT_GREEN_TEAM_VICTORY]);
	m_pTextHeader.ChangeTextLabel( "", m_iIndex[C_iTOT_RED_TEAM_VICTORY]);
	m_pTextHeader.ChangeTextLabel( "", m_iIndex[C_iMISSION_STATUS]);
}

//===============================================================================
// Reset: reset all the gametype variables
//===============================================================================
function Reset()
{
	m_bDisplayTotVictory = false;
	m_bDisplayCoopStatus = false;
	m_bDisplayCoopBox	 = false;

	ResetDisplayInfo();
}

defaultproperties
{
}
