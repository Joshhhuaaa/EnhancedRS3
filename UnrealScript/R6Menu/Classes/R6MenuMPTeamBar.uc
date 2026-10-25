//=============================================================================
//  R6MenuMPTeamBar.uc : The team bar with the name of each player and theirs stats
//  the size of the window is 640 * 480
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/25 * Created  Yannick Joly
//=============================================================================
class R6MenuMPTeamBar extends UWindowWindow;

// THIS IS A COPY OF ePLINFO in R6WindowListIGPlayerInfoItem
enum eMenuLayout
{
	eML_Ready,
	eML_HealthStatus,
	eML_Name,
	eML_RoundsWon,
	eML_Kill,
	eML_DeadCounter,
	eML_Efficiency,
	eML_RoundFired,
	eML_RoundHit,
	eML_KillerName,
	eML_PingTime
};

enum eIconType 
{
	IT_Ready,
	IT_Health,
	IT_RoundsWon,
	IT_Kill,		// X icon
	IT_DeadCounter, // Skull icon
	IT_Efficiency,	// % icon
	IT_RoundFired,  // Bullet icon
	IT_RoundTaken,	// Target icon
	IT_KillerName,	// Gun icon
	IT_Ping
};


struct stCoord
{
    var FLOAT    fXPos;
    var FLOAT    fWidth;
};

const C_fTEAMBAR_ICON_HEIGHT = 15; // the height of the team bar at the top of the window 
const C_fTEAMBAR_TOT_HEIGHT  = 12; // the height of the team bar at the bottom of the window 
const C_iMISSION_TITLE_H     = 20; // the height of the mission title

// text array index
const C_iREADY				 = 0;
const C_iTEAM_NAME			 = 1;
const C_iROUNDSWON			 = 2;
const C_iNUMBER_OF_KILLS	 = 3;
const C_iNUMBER_OF_MYDEAD	 = 4;
const C_iPERCENT_EFFICIENT	 = 5;
const C_iROUND_FIRED		 = 6;
const C_iTOT_ROUND_TAKEN	 = 7;
const C_iTOTAL_TEAM_STATUS	 = 8;

const C_iPLAYER_MAX			 = 16; // number of maximum player

var Texture                     m_TIcon;					// where are the icon tex
var Color                       m_vTeamColor;               // the color of the team

var R6WindowTextLabelExt        m_pTextTeamBar;             // display the names of the team and nb of players
var R6WindowIGPlayerInfoListBox m_IGPlayerInfoListBox;      // List of players with scroll bar

var string                      m_szTeamName;

var stCoord						m_stMenuCoord[11];			// the coordinates of all menu

var INT                         m_iIndex[9];                // array of text label
var INT                         m_iTotalKills;              // Team total Number of kills
var INT							m_iTotalNbOfDead;			// Team total Number of Dead
var INT                         m_iTotalEfficiency;         // Team total Efficiency (hits/shot)
var INT                         m_iTotalRoundsFired;        // Team total Rounds fired (Bullets shot by the player)
var INT                         m_iTotalRoundsTaken;        // Team total Rounds taken (Rounds that hits the player)
var INT							m_iTotalRoomTake;

var BOOL						m_bTeamMenuLayout;			// for team menu layout (team deathmatch, tema survivor, team etc!!!)

// COOP
var	R6WindowTextLabel			m_pTitleCoop;   
var R6MenuMPInGameObj			m_pMissionObj;
var bool						m_bDisplayObj;				// display the objectives





function Paint(Canvas C, FLOAT X, FLOAT Y)
{
	C.Style = ERenderStyle.STY_Alpha;

	if (!m_bDisplayObj)
	{
		if ( m_vTeamColor == Root.Colors.TeamColorLight[0])
			DrawSimpleBackGround( C, 2, 0, WinWidth - 4, WinHeight, Root.Colors.TeamColorDark[0]);
		else
			DrawSimpleBackGround( C, 2, 0, WinWidth - 4, WinHeight, Root.Colors.TeamColorDark[1]);

		C.SetDrawColor( m_vTeamColor.R, m_vTeamColor.G, m_vTeamColor.B);
		DrawInGameTeamBar( C, 0, C_fTEAMBAR_ICON_HEIGHT);
		DrawInGameTeamBarUpBorder( C, 2, 0, WinWidth - 4, C_fTEAMBAR_ICON_HEIGHT); // 2 is the frame border 
		DrawInGameTeamBarDownBorder( C, 2, WinHeight - C_fTEAMBAR_TOT_HEIGHT, WinWidth - 4, C_fTEAMBAR_TOT_HEIGHT); // 2 is the frame border 
	}
}


//===============================================================================
// Set the new parameters of this window and the child
//===============================================================================
function SetWindowSize( FLOAT _fX, FLOAT _fY, FLOAT _fW, FLOAT _fH)
{
    local FLOAT fOldTop, fOldLeft;

    fOldTop   = WinTop;
    fOldLeft  = WinLeft;

    WinTop    = _fY;
	WinLeft   = _fX;
	WinWidth  = _fW;
	WinHeight = _fH;

	if (m_bDisplayObj)
	{
		if (m_pTitleCoop != None)
		{
			m_pTitleCoop.WinTop    = 0;
			m_pTitleCoop.WinWidth  = _fW;
			m_pTitleCoop.WinHeight = C_iMISSION_TITLE_H;
		}

		if (m_pMissionObj != None)
		{
			m_pMissionObj.WinTop    = C_iMISSION_TITLE_H;
			m_pMissionObj.WinWidth  = _fW;
			m_pMissionObj.WinHeight = _fH - C_iMISSION_TITLE_H;
			m_pMissionObj.SetNewObjWindowSizes( _fX, _fY, _fW, _fH, true);

			m_pMissionObj.UpdateObjectives(); // max of 5 obj for now -- need dev for more
		}
	}

    if ( m_pTextTeamBar != None)
    {
        // replace the text window pos
        m_pTextTeamBar.WinTop    = 0;//( _fY - fOldTop);
        m_pTextTeamBar.WinWidth  = _fW;
        m_pTextTeamBar.WinHeight = _fH;

        Refresh();
    }

    if ( m_IGPlayerInfoListBox != None)
    {
        m_IGPlayerInfoListBox.WinTop    = C_fTEAMBAR_ICON_HEIGHT;//( _fY - fOldTop);
        m_IGPlayerInfoListBox.WinWidth  = _fW;
        m_IGPlayerInfoListBox.WinHeight = _fH - GetPlayerListBorderHeight();

//        RefreshInfoListBox();
    }
}


//===============================================================================
// Refresh server info
//===============================================================================
function RefreshTeamBarInfo( INT _iTeam)
{
	local INT iTotalOfPlayers;
	local R6MenuInGameMultiPlayerRootWindow R6Root;
	R6Root = R6MenuInGameMultiPlayerRootWindow(Root);


    // update 
    if ( R6Root.m_szCurrentGameType == "RGM_DeathmatchMode")
    {
		iTotalOfPlayers = 16;
    }
    else 
    {
		iTotalOfPlayers = 8;
    }

    m_iTotalKills       = 0;
	m_iTotalNbOfDead	= 0;
    m_iTotalEfficiency  = 0;
    m_iTotalRoundsFired = 0;
    m_iTotalRoundsTaken = 0;
	m_iTotalRoomTake    = 0;
    ClearListOfItem();
    
    AddItems( _iTeam, iTotalOfPlayers);

    // update 
    if ( R6Root.m_szCurrentGameType == "RGM_DeathmatchMode")
    {
        m_pTextTeamBar.ChangeTextLabel( Localize("MPInGame","PlayersName","R6Menu"), m_iIndex[C_iTEAM_NAME]); // players names 
        m_pTextTeamBar.ChangeTextLabel( "", m_iIndex[C_iTOTAL_TEAM_STATUS]); // deathmatch -- only players name 
        m_pTextTeamBar.ChangeTextLabel( "", m_iIndex[C_iNUMBER_OF_KILLS]); // total number of kills 
        m_pTextTeamBar.ChangeTextLabel( "", m_iIndex[C_iNUMBER_OF_MYDEAD]); // total number of kills 
        m_pTextTeamBar.ChangeTextLabel( "", m_iIndex[C_iPERCENT_EFFICIENT]); // total % efficient
        m_pTextTeamBar.ChangeTextLabel( "", m_iIndex[C_iROUND_FIRED]); // total Round fired
        m_pTextTeamBar.ChangeTextLabel( "", m_iIndex[C_iTOT_ROUND_TAKEN]); // total Round taken
    }
    else 
    {
        m_pTextTeamBar.ChangeTextLabel( m_szTeamName, m_iIndex[C_iTEAM_NAME]); // alpha/bravo team 
        m_pTextTeamBar.ChangeTextLabel( Localize("MPInGame","TotalTeamStatus","R6Menu"), m_iIndex[C_iTOTAL_TEAM_STATUS]); // alpha/bravo team 
        m_pTextTeamBar.ChangeTextLabel( string(m_iTotalKills), m_iIndex[C_iNUMBER_OF_KILLS]); // total number of kills 
		m_pTextTeamBar.ChangeTextLabel( string(m_iTotalNbOfDead), m_iIndex[C_iNUMBER_OF_MYDEAD]); // total number my dead -- iDeadCounter 
        m_pTextTeamBar.ChangeTextLabel( string(m_iTotalEfficiency), m_iIndex[C_iPERCENT_EFFICIENT]); // total % efficient
        m_pTextTeamBar.ChangeTextLabel( string(m_iTotalRoundsFired), m_iIndex[C_iROUND_FIRED]); // total Round fired
        m_pTextTeamBar.ChangeTextLabel( string(m_iTotalRoundsTaken), m_iIndex[C_iTOT_ROUND_TAKEN]); // total Round taken
    }
}


//===============================================================================
// Refresh: The fix team bar parameters are refresh (because we change the window size)
//===============================================================================
function Refresh()
{
    local FLOAT fXOffset, fYOffset, fYStep, fWidth;

    m_pTextTeamBar.Clear();

	// at the top
    fYOffset = 2; 
    fXOffset = m_stMenuCoord[ eMenuLayout.eML_Name].fXPos;
    fWidth = m_stMenuCoord[ eMenuLayout.eML_Name].fWidth;
    m_iIndex[C_iTEAM_NAME] = m_pTextTeamBar.AddTextLabel( m_szTeamName, fXOffset, fYOffset, fWidth, TA_Left, false); 

    //score
//	if (!m_bTeamMenuLayout)
//	{
//		fXOffset = m_stMenuCoord[ eMenuLayout.eML_RoundsWon].fXPos;
//		fWidth   = m_stMenuCoord[ eMenuLayout.eML_RoundsWon].fWidth; 
//		m_iIndex[C_iROUNDSWON] = m_pTextTeamBar.AddTextLabel( "ROUNDS WON", fXOffset, fYOffset, fWidth, TA_Center, false);
//	}
	

	// at the bottom
    fXOffset = 4;
    fYOffset = WinHeight - C_fTEAMBAR_TOT_HEIGHT + 1;//fYOffset;
    m_iIndex[C_iTOTAL_TEAM_STATUS] = m_pTextTeamBar.AddTextLabel( "", fXOffset, fYOffset, fWidth, TA_Left, false);

    fXOffset = m_stMenuCoord[ eMenuLayout.eML_Kill].fXPos;
    fWidth   = m_stMenuCoord[ eMenuLayout.eML_Kill].fWidth; 
    m_iIndex[C_iNUMBER_OF_KILLS] = m_pTextTeamBar.AddTextLabel( "00", fXOffset, fYOffset, fWidth, TA_Center, false);

    fXOffset = m_stMenuCoord[ eMenuLayout.eML_DeadCounter].fXPos;
    fWidth   = m_stMenuCoord[ eMenuLayout.eML_DeadCounter].fWidth;
    m_iIndex[C_iNUMBER_OF_MYDEAD] = m_pTextTeamBar.AddTextLabel( "00", fXOffset, fYOffset, fWidth, TA_Center, false);

    fXOffset = m_stMenuCoord[ eMenuLayout.eML_Efficiency].fXPos;
    fWidth   = m_stMenuCoord[ eMenuLayout.eML_Efficiency].fWidth;
    m_iIndex[C_iPERCENT_EFFICIENT] = m_pTextTeamBar.AddTextLabel( "00", fXOffset, fYOffset, fWidth, TA_Center, false);

    fXOffset = m_stMenuCoord[ eMenuLayout.eML_RoundFired].fXPos;
    fWidth   = m_stMenuCoord[ eMenuLayout.eML_RoundFired].fWidth;
    m_iIndex[C_iROUND_FIRED] = m_pTextTeamBar.AddTextLabel( "00", fXOffset, fYOffset, fWidth, TA_Center, false);

    fXOffset = m_stMenuCoord[ eMenuLayout.eML_RoundHit].fXPos;
    fWidth   = m_stMenuCoord[ eMenuLayout.eML_RoundHit].fWidth;
    m_iIndex[C_iTOT_ROUND_TAKEN] = m_pTextTeamBar.AddTextLabel( "00", fXOffset, fYOffset, fWidth, TA_Center, false);
}



function AddItems( INT _iTeam, INT _iTotalOfPlayers)
{
    local R6WindowListIGPlayerInfoItem NewItem;
	local UWindowList CurItem, ParseItem;
	local R6MenuInGameMultiPlayerRootWindow R6Root;
	local R6WindowIGPlayerInfoListBox pListTemp;
    local INT i, iIndex, j;
	local BOOL bAddItem;
    local Actor.PlayerMenuInfo _PlayerMenuInfo;
    local R6MenuMPInterWidget MpInter;

	local int iTeamPlayerCount;
	R6Root = R6MenuInGameMultiPlayerRootWindow(Root);

	//log("AddItems----- team name"$_iTeam);
    if (R6Root.m_R6GameMenuCom != None)
    {
		/*
		if (m_IGPlayerInfoListBox.Items.Next == None)
		{
			log("THIS SHOULD NOT HAPPEN");
		}
		*/
        
        MpInter = R6MenuMPInterWidget(OwnerWindow);
		CurItem = m_IGPlayerInfoListBox.Items.Next;

		iTeamPlayerCount = 0;
        for ( i = 0; i < R6Root.m_R6GameMenuCom.m_iLastValidIndex ; i++ )
        {
			bAddItem = true;

			iIndex   = R6Root.m_R6GameMenuCom.GeTTeamSelection(i);
		    GetLevel().GetFPlayerMenuInfo(i, _PlayerMenuInfo);

            if (iIndex != _iTeam) // not in the same team or in a team
            {
				bAddItem = false;
				if (iIndex == R6Root.m_R6GameMenuCom.ePlayerTeamSelection.PTS_Spectator)
				{
					if (_iTeam == R6Root.m_R6GameMenuCom.ePlayerTeamSelection.PTS_Alpha)
					{
						if ( m_iTotalRoomTake < _iTotalOfPlayers)
						{
							bAddItem = true;	
						}
					}
					else if (MpInter.m_pR6AlphaTeam.m_iTotalRoomTake == _iTotalOfPlayers)// it's BravoTeam so just add it at the end
					{
						bAddItem =  true;
						
						pListTemp = MpInter.m_pR6AlphaTeam.m_IGPlayerInfoListBox;
						ParseItem = pListTemp.Items.Next;

						// check if it's not already in alpha list
						for ( j = 0; j < _iTotalOfPlayers; j++)
						{
							if (Left(_PlayerMenuInfo.szPlayerName, 15) ~= R6WindowListIGPlayerInfoItem(ParseItem).szPlName)
							{
								bAddItem = false;
								break;
							}
							ParseItem = ParseItem.Next;
						}
					}
				}
			}
			
			if (bAddItem)
			{
				NewItem = R6WindowListIGPlayerInfoItem(CurItem);

				iIndex = NewItem.ePLInfo.ePL_Ready;
                NewItem.bReady							= _PlayerMenuInfo.bPlayerReady;
                NewItem.stTagCoord[iIndex].fXPos		= m_stMenuCoord[ eMenuLayout.eML_Ready].fXPos;
                NewItem.stTagCoord[iIndex].fWidth		= m_stMenuCoord[ eMenuLayout.eML_Ready].fWidth;            

				iIndex = NewItem.ePLInfo.ePL_HealthStatus;
				if (_PlayerMenuInfo.bSpectator)
	                NewItem.eStatus						= NewItem.ePlStatus.ePlayerStatus_Spectator; 
				else if (_PlayerMenuInfo.bJoinedTeamLate)
    	                NewItem.eStatus						= NewItem.ePlStatus.ePlayerStatus_TooLate; 
                else
                {
                    switch(_PlayerMenuInfo.iHealth)
					{
					case 0:
						NewItem.eStatus                 = NewItem.ePlStatus.ePlayerStatus_Alive;
						break;
					case 1:
						NewItem.eStatus                 = NewItem.ePlStatus.ePlayerStatus_Wounded;
						break;					
					case 2: //There is no incapacitated state in MP
                    default:
						NewItem.eStatus                 = NewItem.ePlStatus.ePlayerStatus_Dead;
						break;                    
					}
                    
                }
                        

                NewItem.stTagCoord[iIndex].fXPos		= m_stMenuCoord[ eMenuLayout.eML_HealthStatus].fXPos;
                NewItem.stTagCoord[iIndex].fWidth		= m_stMenuCoord[ eMenuLayout.eML_HealthStatus].fWidth;

				iIndex = NewItem.ePLInfo.ePL_Name;
                NewItem.szPlName						= Left(_PlayerMenuInfo.szPlayerName, 15); // max 15 caracteres
                NewItem.stTagCoord[iIndex].fXPos		= m_stMenuCoord[ eMenuLayout.eML_Name].fXPos;
                NewItem.stTagCoord[iIndex].fWidth		= m_stMenuCoord[ eMenuLayout.eML_Name].fWidth;            

				iIndex = NewItem.ePLInfo.ePL_RoundsWon;
				NewItem.stTagCoord[iIndex].bDisplay		= !m_bTeamMenuLayout;
				NewItem.szRoundsWon						= string(_PlayerMenuInfo.iRoundsWon) $ "/" $ string(_PlayerMenuInfo.iRoundsPlayed);
				NewItem.stTagCoord[iIndex].fXPos		= m_stMenuCoord[ eMenuLayout.eML_RoundsWon].fXPos;
				NewItem.stTagCoord[iIndex].fWidth		= m_stMenuCoord[ eMenuLayout.eML_RoundsWon].fWidth;

				iIndex = NewItem.ePLInfo.ePL_Kill;
                NewItem.iKills							= _PlayerMenuInfo.iKills;
                NewItem.stTagCoord[iIndex].fXPos		= m_stMenuCoord[ eMenuLayout.eML_Kill].fXPos;
                NewItem.stTagCoord[iIndex].fWidth		= m_stMenuCoord[ eMenuLayout.eML_Kill].fWidth;

				iIndex = NewItem.ePLInfo.ePL_DeadCounter;
                NewItem.iMyDeadCounter					= _PlayerMenuInfo.iDeathCount; 
                NewItem.stTagCoord[iIndex].fXPos		= m_stMenuCoord[ eMenuLayout.eML_DeadCounter].fXPos;
                NewItem.stTagCoord[iIndex].fWidth		= m_stMenuCoord[ eMenuLayout.eML_DeadCounter].fWidth;

				iIndex = NewItem.ePLInfo.ePL_Efficiency;
                NewItem.iEfficiency						= _PlayerMenuInfo.iEfficiency;
                NewItem.stTagCoord[iIndex].fXPos		= m_stMenuCoord[ eMenuLayout.eML_Efficiency].fXPos;
                NewItem.stTagCoord[iIndex].fWidth		= m_stMenuCoord[ eMenuLayout.eML_Efficiency].fWidth;

				iIndex = NewItem.ePLInfo.ePL_RoundFired;
                NewItem.iRoundsFired					= _PlayerMenuInfo.iRoundsFired;
                NewItem.stTagCoord[iIndex].fXPos		= m_stMenuCoord[ eMenuLayout.eML_RoundFired].fXPos;
                NewItem.stTagCoord[iIndex].fWidth		= m_stMenuCoord[ eMenuLayout.eML_RoundFired].fWidth;

				iIndex = NewItem.ePLInfo.ePL_RoundHit;
                NewItem.iRoundsHit						= _PlayerMenuInfo.iRoundsHit;
                NewItem.stTagCoord[iIndex].fXPos		= m_stMenuCoord[ eMenuLayout.eML_RoundHit].fXPos;
                NewItem.stTagCoord[iIndex].fWidth		= m_stMenuCoord[ eMenuLayout.eML_RoundHit].fWidth;

				iIndex = NewItem.ePLInfo.ePL_KillerName;
                NewItem.szKillBy						= _PlayerMenuInfo.szKilledBy;
                NewItem.stTagCoord[iIndex].fXPos		= m_stMenuCoord[ eMenuLayout.eML_KillerName].fXPos;
                NewItem.stTagCoord[iIndex].fWidth		= m_stMenuCoord[ eMenuLayout.eML_KillerName].fWidth;

				iIndex = NewItem.ePLInfo.ePL_PingTime;
                NewItem.iPingTime						= _PlayerMenuInfo.iPingTime;
                NewItem.stTagCoord[iIndex].fXPos		= m_stMenuCoord[ eMenuLayout.eML_PingTime].fXPos;
                NewItem.stTagCoord[iIndex].fWidth		= m_stMenuCoord[ eMenuLayout.eML_PingTime].fWidth;

				NewItem.bOwnPlayer						= _PlayerMenuInfo.bOwnPlayer;

                m_iTotalKills       += NewItem.iKills;
				m_iTotalNbOfDead	+= NewItem.iMyDeadCounter;
                m_iTotalEfficiency  += NewItem.iEfficiency;
                m_iTotalRoundsFired += NewItem.iRoundsFired;
                m_iTotalRoundsTaken += NewItem.iRoundsHit;

				m_iTotalRoomTake += 1;

				if(!_PlayerMenuInfo.bSpectator && !_PlayerMenuInfo.bJoinedTeamLate)
				{
					iTeamPlayerCount++;
				}
				NewItem.m_bShowThisItem = true;
				// take the next element
				CurItem = CurItem.Next;
            }
        }

		if(iTeamPlayerCount > 0)
		{
			m_iTotalEfficiency = m_iTotalEfficiency / iTeamPlayerCount;
		}
    }
    
}

function ClearListOfItem()
{
    local R6WindowListIGPlayerInfoItem NewItem;
	local UWindowList CurItem;
    local INT i;
	local BOOL bAlreadyCreate;

	if (m_IGPlayerInfoListBox.Items.Next != None)
	{
		bAlreadyCreate = True;
		CurItem = m_IGPlayerInfoListBox.Items.Next;
	}
	
	// create the listitem
	for( i = 0; i < C_iPLAYER_MAX ; i++)
	{
		if (bAlreadyCreate)
		{
			CurItem.m_bShowThisItem = false;
			CurItem = CurItem.Next;
		}
		else
		{
			NewItem = R6WindowListIGPlayerInfoItem(m_IGPlayerInfoListBox.Items.Append(m_IGPlayerInfoListBox.ListClass));
			NewItem.m_bShowThisItem = false;
		}
	}

	//    m_IGPlayerInfoListBox.Items.Clear(); // the item still in memory!!!
}


//===============================================================================
// Get the total height of the header ALPHA TEAM and TOTAL TEAM STATUS
//===============================================================================
function FLOAT GetPlayerListBorderHeight()
{
    return (C_fTEAMBAR_ICON_HEIGHT + C_fTEAMBAR_TOT_HEIGHT);
}


//=================================================================================================
//============================= DRAW FUNCTIONS AND UTILITIES ======================================
//=================================================================================================

//=================================================================================================
// DrawInGameTeamBar: This function draw the in-game team bar, icons and lines
//=================================================================================================
function DrawInGameTeamBar( Canvas C, FLOAT _fY, FLOAT _fHeight)  
{
	local FLOAT fXOffSet, fWidth;

	fXOffset = m_stMenuCoord[ eMenuLayout.eML_Ready].fXPos;
	fWidth	 = m_stMenuCoord[ eMenuLayout.eML_Ready].fWidth;
	AddIcon( C, fXOffset, _fY, fWidth, _fHeight, IT_Ready);	
//	fXOffSet = fXOffSet + fWidth;
//	AddVerticalLine( C, fXOffSet, _fY, m_BorderTextureRegion.W, WinHeight - C_fTEAMBAR_ICON_HEIGHT);

	fXOffset = m_stMenuCoord[ eMenuLayout.eML_HealthStatus].fXPos;
	fWidth	 = m_stMenuCoord[ eMenuLayout.eML_HealthStatus].fWidth;
	AddIcon( C, fXOffset, _fY, fWidth, _fHeight, IT_Health);
//	fXOffSet = fXOffSet + fWidth;
//	AddVerticalLine( C, fXOffSet, _fY, m_BorderTextureRegion.W, WinHeight - C_fTEAMBAR_ICON_HEIGHT);

	fXOffset = m_stMenuCoord[ eMenuLayout.eML_Name].fXPos;
	fWidth	 = m_stMenuCoord[ eMenuLayout.eML_Name].fWidth;
	fXOffSet = fXOffSet + fWidth;
	AddVerticalLine( C, fXOffSet, _fY, m_BorderTextureRegion.W, WinHeight);

	if (!m_bTeamMenuLayout)
	{
		fXOffset = m_stMenuCoord[ eMenuLayout.eML_RoundsWon].fXPos;
		fWidth	 = m_stMenuCoord[ eMenuLayout.eML_RoundsWon].fWidth;
		AddIcon( C, fXOffset, _fY, fWidth, _fHeight, IT_RoundsWon);
		fXOffSet = fXOffSet + fWidth;
		AddVerticalLine( C, fXOffSet, _fY, m_BorderTextureRegion.W, WinHeight);
	}

	fXOffset = m_stMenuCoord[ eMenuLayout.eML_Kill].fXPos;
	fWidth	 = m_stMenuCoord[ eMenuLayout.eML_Kill].fWidth;
	AddIcon( C, fXOffset, _fY, fWidth, _fHeight, IT_Kill);

	fXOffset = m_stMenuCoord[ eMenuLayout.eML_DeadCounter].fXPos;
	fWidth	 = m_stMenuCoord[ eMenuLayout.eML_DeadCounter].fWidth;
	AddIcon( C, fXOffset, _fY, fWidth, _fHeight, IT_DeadCounter);
	fXOffSet = fXOffSet + fWidth;
	AddVerticalLine( C, fXOffSet, _fY, m_BorderTextureRegion.W, WinHeight);

	fXOffset = m_stMenuCoord[ eMenuLayout.eML_Efficiency].fXPos;
	fWidth	 = m_stMenuCoord[ eMenuLayout.eML_Efficiency].fWidth;
	AddIcon( C, fXOffset, _fY, fWidth, _fHeight, IT_Efficiency);

	fXOffset = m_stMenuCoord[ eMenuLayout.eML_RoundFired].fXPos;
	fWidth	 = m_stMenuCoord[ eMenuLayout.eML_RoundFired].fWidth;
	AddIcon( C, fXOffset, _fY, fWidth, _fHeight, IT_RoundFired);

	fXOffset = m_stMenuCoord[ eMenuLayout.eML_RoundHit].fXPos;
	fWidth	 = m_stMenuCoord[ eMenuLayout.eML_RoundHit].fWidth;
	AddIcon( C, fXOffset, _fY, fWidth, _fHeight, IT_RoundTaken);
	fXOffSet = fXOffSet + fWidth;
	AddVerticalLine( C, fXOffSet, _fY, m_BorderTextureRegion.W, WinHeight);

	fXOffset = m_stMenuCoord[ eMenuLayout.eML_KillerName].fXPos;
	fWidth	 = m_stMenuCoord[ eMenuLayout.eML_KillerName].fWidth;
	AddIcon( C, fXOffset, _fY, fWidth, _fHeight, IT_KillerName);
	fXOffSet = fXOffSet + fWidth;
	AddVerticalLine( C, fXOffSet, _fY, m_BorderTextureRegion.W, WinHeight);

	fXOffset = m_stMenuCoord[ eMenuLayout.eML_PingTime].fXPos;
	fWidth	 = m_stMenuCoord[ eMenuLayout.eML_PingTime].fWidth;
	AddIcon( C, fXOffset, _fY, fWidth, _fHeight, IT_Ping);
}

function AddVerticalLine( Canvas C, FLOAT _fX, FLOAT _fY, FLOAT _fWidth, FLOAT _fHeight)
{
    // draw separation
    DrawStretchedTextureSegment(C, _fX, _fY, _fWidth, _fHeight,
                                   m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
}


function AddIcon( Canvas C, FLOAT _fX, FLOAT _fY, FLOAT _fWidth, FLOAT _fHeight, eIconType _eIconType)
{
    local Region RIconRegion, RIconToDraw;
	local R6MenuRSLookAndFeel R6LAF;
	local FLOAT fY;

	R6LAF = R6MenuRSLookAndFeel(LookAndFeel);

	fY = _fY;

	switch( _eIconType)
	{
		case IT_Ready:
			RIconToDraw.X = 18;
			RIconToDraw.Y = 14;
			RIconToDraw.W = 8;
			RIconToDraw.H = 14;		
			break;
		case IT_Health:
			RIconToDraw.X = 0;
			RIconToDraw.Y = 28;
			RIconToDraw.W = 13;
			RIconToDraw.H = 14;
			break;
		case IT_RoundsWon:
			RIconToDraw.X = 27;
			RIconToDraw.Y = 14;
			RIconToDraw.W = 8;
			RIconToDraw.H = 14;
			break;
		case IT_Kill:
			RIconToDraw.X = 36;
			RIconToDraw.Y = 14;
			RIconToDraw.W = 12;
			RIconToDraw.H = 14;
			break;
		case IT_DeadCounter:
			RIconToDraw.X = 14;
			RIconToDraw.Y = 0;
			RIconToDraw.W = 13;
			RIconToDraw.H = 14;
			break;
		case IT_Efficiency:
			RIconToDraw.X = 28;
			RIconToDraw.Y = 0;
			RIconToDraw.W = 14;
			RIconToDraw.H = 14;
			break;
		case IT_RoundFired:
			RIconToDraw.X = 49;
			RIconToDraw.Y = 14;
			RIconToDraw.W = 7;
			RIconToDraw.H = 14;
			break;
		case IT_RoundTaken:
			RIconToDraw.X = 14;
			RIconToDraw.Y = 28;
			RIconToDraw.W = 16;
			RIconToDraw.H = 14;
			break;
		case IT_KillerName:
			RIconToDraw.X = 0;
			RIconToDraw.Y = 14;
			RIconToDraw.W = 17;
			RIconToDraw.H = 14;
			break;
		case IT_Ping:
			RIconToDraw.X = 46; // the zone is reduce because we don't see the beginning
			RIconToDraw.Y = 0;
			RIconToDraw.W = 13;
			RIconToDraw.H = 14;
			break;
	}

	RIconRegion = R6LAF.CenterIconInBox( _fX, fY, _fWidth, _fHeight, RIconToDraw);
    DrawStretchedTextureSegment( C, RIconRegion.X, RIconRegion.Y, RIconToDraw.W, RIconToDraw.H, 
                                    RIconToDraw.X, RIconToDraw.Y, RIconToDraw.W, RIconToDraw.H, m_TIcon);
}



//=======================================================================================================
// Draw in game team bar up border. This function is right now call by DrawInGameTeamBar
//=======================================================================================================
function DrawInGameTeamBarUpBorder( Canvas C, FLOAT _fX, FLOAT _fY, FLOAT _fWidth, FLOAT _fHeight)
{
    C.SetDrawColor( m_vTeamColor.R, m_vTeamColor.G, m_vTeamColor.B);
    //Top
    DrawStretchedTextureSegment(C, _fX, _fY, _fWidth, m_BorderTextureRegion.H, 
                                     m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
    //Bottom
    DrawStretchedTextureSegment(C, _fX, _fY + _fHeight, _fWidth, m_BorderTextureRegion.H , 
                                     m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
    /*
    //Left
    DrawStretchedTextureSegment(C, _fX, _fY, m_BorderTextureRegion.W, _fHeight, 
                                     m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
    //Right
    DrawStretchedTextureSegment(C, WinWidth - m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTextureRegion.W, WinHeight - (2* m_BorderTextureRegion.H), 
                                     m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
                                     */
}


//=======================================================================================================
// Draw in game team bar down border. This function is right now call by DrawInGameTeamBar
//=======================================================================================================
function DrawInGameTeamBarDownBorder( Canvas C, FLOAT _fX, FLOAT _fY, FLOAT _fWidth, FLOAT _fHeight)
{
    C.SetDrawColor( m_vTeamColor.R, m_vTeamColor.G, m_vTeamColor.B);
    /*
    //Top
    DrawStretchedTextureSegment(C, _fX, _fY, WinWidth, m_BorderTextureRegion.H , 
                                     m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
                                     */
    //Bottom
    DrawStretchedTextureSegment(C, _fX, _fY, _fWidth, m_BorderTextureRegion.H , 
                                     m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);

    //Left
//    DrawStretchedTextureSegment(C, 140, _fY, m_BorderTextureRegion.W, _fHeight, 
//                                     m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
    //Right
//    DrawStretchedTextureSegment(C, 340, _fY, m_BorderTextureRegion.W, _fHeight, 
//                                     m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);

}

//=================================================================================================
//=================================================================================================
//=================================================================================================








//***************************** INIT SECTION *******************************

//===============================================================================
// Init text header
//===============================================================================
function InitTeamBar()
{
    local FLOAT fXOffset, fYOffset, fYStep, fWidth, fHeight;
    local Font ButtonFont;

    if (m_pTextTeamBar == None)
    {
        // Use text array with R6WindowTextLabelExt
        m_pTextTeamBar = R6WindowTextLabelExt( CreateWindow(class'R6WindowTextLabelExt', 0, 0, WinWidth, WinHeight, self));
        m_pTextTeamBar.bAlwaysBehind = true;
        m_pTextTeamBar.SetNoBorder();

        // text part
        m_pTextTeamBar.m_Font = Root.Fonts[F_VerySmallTitle];//F_SmallTitle];
        m_pTextTeamBar.m_vTextColor = m_vTeamColor;

        Refresh();

        InitIGPlayerInfoList();
    }
}


function InitIGPlayerInfoList()
{	
	// Create window for serever list
 	m_IGPlayerInfoListBox = R6WindowIGPlayerInfoListBox(CreateWindow( class'R6WindowIGPlayerInfoListBox', 0, C_fTEAMBAR_ICON_HEIGHT, WinWidth, WinHeight -  GetPlayerListBorderHeight(), self));
	m_IGPlayerInfoListBox.SetCornerType(No_Borders);

    // TODO might need to add something for specific fonts, textures, etc.

    m_IGPlayerInfoListBox.m_Font = Root.Fonts[F_VerySmallTitle];//F_ListItemSmall];
	
}

function InitMissionWindows()
{
		m_pTitleCoop = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 0, 0, WinWidth, C_iMISSION_TITLE_H, self));
		m_pTitleCoop.Text			= Localize("MPInGame","Coop_MissionDebr","R6Menu");
		m_pTitleCoop.Align			= TA_Center;
		m_pTitleCoop.m_Font			= Root.Fonts[F_PopUpTitle];
		m_pTitleCoop.TextColor		= Root.Colors.White;
		m_pTitleCoop.m_fHBorderPadding = 2;
		m_pTitleCoop.m_VBorderTexture  = None;

		m_pMissionObj = R6MenuMPInGameObj(CreateWindow(Root.MenuClassDefines.ClassInGameObjectives, 0.0, 20.0, WinWidth, WinHeight - float(20), self));
}

//===================================================================================
// InitMenuLayout: init menu layout (the size of the winwidth is 590)
//===================================================================================
function InitMenuLayout( INT _MenuToDisplay)
{
	m_bTeamMenuLayout = false;

	if (_MenuToDisplay == 1) // team 
	{
		m_bTeamMenuLayout = true;

		m_stMenuCoord[ eMenuLayout.eML_Ready].fXPos			= 4;
		m_stMenuCoord[ eMenuLayout.eML_Ready].fWidth		= 15;

		m_stMenuCoord[ eMenuLayout.eML_HealthStatus].fXPos	= m_stMenuCoord[ eMenuLayout.eML_Ready].fXPos + 
															  m_stMenuCoord[ eMenuLayout.eML_Ready].fWidth;
		m_stMenuCoord[ eMenuLayout.eML_HealthStatus].fWidth	= 21;

		m_stMenuCoord[ eMenuLayout.eML_Name].fXPos			= m_stMenuCoord[ eMenuLayout.eML_HealthStatus].fXPos + 
															  m_stMenuCoord[ eMenuLayout.eML_HealthStatus].fWidth;
		m_stMenuCoord[ eMenuLayout.eML_Name].fWidth			= 153;

		m_stMenuCoord[ eMenuLayout.eML_RoundsWon].fXPos		= 0; // desactivate
		m_stMenuCoord[ eMenuLayout.eML_RoundsWon].fWidth	= 0; // desactivate 

		m_stMenuCoord[ eMenuLayout.eML_Kill].fXPos			= m_stMenuCoord[ eMenuLayout.eML_Name].fXPos + 
															  m_stMenuCoord[ eMenuLayout.eML_Name].fWidth;
		m_stMenuCoord[ eMenuLayout.eML_Kill].fWidth			= 42;

		m_stMenuCoord[ eMenuLayout.eML_DeadCounter].fXPos	= m_stMenuCoord[ eMenuLayout.eML_Kill].fXPos + 
															  m_stMenuCoord[ eMenuLayout.eML_Kill].fWidth;
		m_stMenuCoord[ eMenuLayout.eML_DeadCounter].fWidth	= 41;

		m_stMenuCoord[ eMenuLayout.eML_Efficiency].fXPos	= m_stMenuCoord[ eMenuLayout.eML_DeadCounter].fXPos + 
															  m_stMenuCoord[ eMenuLayout.eML_DeadCounter].fWidth;
		m_stMenuCoord[ eMenuLayout.eML_Efficiency].fWidth	= 40;

		m_stMenuCoord[ eMenuLayout.eML_RoundFired].fXPos	= m_stMenuCoord[ eMenuLayout.eML_Efficiency].fXPos + 
															  m_stMenuCoord[ eMenuLayout.eML_Efficiency].fWidth;
		m_stMenuCoord[ eMenuLayout.eML_RoundFired].fWidth	= 40;

		m_stMenuCoord[ eMenuLayout.eML_RoundHit].fXPos		= m_stMenuCoord[ eMenuLayout.eML_RoundFired].fXPos + 
															  m_stMenuCoord[ eMenuLayout.eML_RoundFired].fWidth;
		m_stMenuCoord[ eMenuLayout.eML_RoundHit].fWidth		= 40;

		m_stMenuCoord[ eMenuLayout.eML_KillerName].fXPos	= m_stMenuCoord[ eMenuLayout.eML_RoundHit].fXPos + 
															  m_stMenuCoord[ eMenuLayout.eML_RoundHit].fWidth;
		m_stMenuCoord[ eMenuLayout.eML_KillerName].fWidth	= m_stMenuCoord[ eMenuLayout.eML_Name].fWidth;

		m_stMenuCoord[ eMenuLayout.eML_PingTime].fXPos		= m_stMenuCoord[ eMenuLayout.eML_KillerName].fXPos + 
															  m_stMenuCoord[ eMenuLayout.eML_KillerName].fWidth;
		m_stMenuCoord[ eMenuLayout.eML_PingTime].fWidth		= 41;
	}
	else // the default one
	{
		m_stMenuCoord[ eMenuLayout.eML_Ready].fXPos			= 2;
		m_stMenuCoord[ eMenuLayout.eML_Ready].fWidth		= 15;

		m_stMenuCoord[ eMenuLayout.eML_HealthStatus].fXPos	= m_stMenuCoord[ eMenuLayout.eML_Ready].fXPos + 
															  m_stMenuCoord[ eMenuLayout.eML_Ready].fWidth;
		m_stMenuCoord[ eMenuLayout.eML_HealthStatus].fWidth	= 15;

		m_stMenuCoord[ eMenuLayout.eML_Name].fXPos			= m_stMenuCoord[ eMenuLayout.eML_HealthStatus].fXPos + 
															  m_stMenuCoord[ eMenuLayout.eML_HealthStatus].fWidth;
		m_stMenuCoord[ eMenuLayout.eML_Name].fWidth			= 153;

		m_stMenuCoord[ eMenuLayout.eML_RoundsWon].fXPos		= m_stMenuCoord[ eMenuLayout.eML_Name].fXPos + 
															  m_stMenuCoord[ eMenuLayout.eML_Name].fWidth;
		m_stMenuCoord[ eMenuLayout.eML_RoundsWon].fWidth	= 37; 

		m_stMenuCoord[ eMenuLayout.eML_Kill].fXPos			= m_stMenuCoord[ eMenuLayout.eML_RoundsWon].fXPos + 
															  m_stMenuCoord[ eMenuLayout.eML_RoundsWon].fWidth;
		m_stMenuCoord[ eMenuLayout.eML_Kill].fWidth			= 36;

		m_stMenuCoord[ eMenuLayout.eML_DeadCounter].fXPos	= m_stMenuCoord[ eMenuLayout.eML_Kill].fXPos + 
															  m_stMenuCoord[ eMenuLayout.eML_Kill].fWidth;
		m_stMenuCoord[ eMenuLayout.eML_DeadCounter].fWidth	= 36;

		m_stMenuCoord[ eMenuLayout.eML_Efficiency].fXPos	= m_stMenuCoord[ eMenuLayout.eML_DeadCounter].fXPos + 
															  m_stMenuCoord[ eMenuLayout.eML_DeadCounter].fWidth;
		m_stMenuCoord[ eMenuLayout.eML_Efficiency].fWidth	= 36;

		m_stMenuCoord[ eMenuLayout.eML_RoundFired].fXPos	= m_stMenuCoord[ eMenuLayout.eML_Efficiency].fXPos + 
															  m_stMenuCoord[ eMenuLayout.eML_Efficiency].fWidth;
		m_stMenuCoord[ eMenuLayout.eML_RoundFired].fWidth	= 36;

		m_stMenuCoord[ eMenuLayout.eML_RoundHit].fXPos		= m_stMenuCoord[ eMenuLayout.eML_RoundFired].fXPos + 
															  m_stMenuCoord[ eMenuLayout.eML_RoundFired].fWidth;
		m_stMenuCoord[ eMenuLayout.eML_RoundHit].fWidth		= 36;

		m_stMenuCoord[ eMenuLayout.eML_KillerName].fXPos	= m_stMenuCoord[ eMenuLayout.eML_RoundHit].fXPos + 
															  m_stMenuCoord[ eMenuLayout.eML_RoundHit].fWidth;
		m_stMenuCoord[ eMenuLayout.eML_KillerName].fWidth	= m_stMenuCoord[ eMenuLayout.eML_Name].fWidth;

		m_stMenuCoord[ eMenuLayout.eML_PingTime].fXPos		= m_stMenuCoord[ eMenuLayout.eML_KillerName].fXPos + 
															  m_stMenuCoord[ eMenuLayout.eML_KillerName].fWidth;
		m_stMenuCoord[ eMenuLayout.eML_PingTime].fWidth		= 35;
	}
}

defaultproperties
{
     m_TIcon=Texture'R6MenuTextures.Credits.TeamBarIcon'
}
