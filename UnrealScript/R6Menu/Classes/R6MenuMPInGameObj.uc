//=============================================================================
//  R6MenuMPInGameObj.uc : Window with the Objectives in-game
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/09/26 * Created by Yannick Joly
//=============================================================================

class R6MenuMPInGameObj extends R6MenuEscObjectives;

var R6WindowWrappedTextArea			m_pGreenTeam;
var R6WindowWrappedTextArea			m_pRedTeam;
var array<R6MenuObjectiveLabel>		m_AObjectives;

var string							m_AAdvLoc[2];

// overwrite the fct in R6MenuEscObjectives
function Created()
{
	local INT iTemp;

    m_Title = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                m_fXTitleOffset, 
                                                m_fYTitleOffset, 
		                                        WinWidth - m_fXTitleOffset, 
                                                m_fLabelHeight, 
                                                self));

    m_Title.SetProperties( Localize("Briefing","Objectives","R6Menu"),
                           TA_LEFT, Root.Fonts[F_SmallTitle], Root.Colors.BlueLight, false);

	// total space that the title take
	iTemp = m_Title.WinTop + m_Title.WinHeight + m_fObjYOffset;
	// total space left
	iTemp = (WinHeight - iTemp) * 0.5;

    m_pGreenTeam = R6WindowWrappedTextArea(CreateWindow(class'R6WindowWrappedTextArea', 
														m_fXTitleOffset, 
														m_Title.WinTop + m_Title.WinHeight + m_fObjYOffset, 
														WinWidth - m_fXTitleOffset, 
														iTemp, 
														self));
	m_pGreenTeam.m_HBorderTexture = None;
	m_pGreenTeam.m_VBorderTexture = None;
	m_pGreenTeam.SetScrollable(false);
	m_pGreenTeam.HideWindow();

    m_pRedTeam = R6WindowWrappedTextArea(CreateWindow(class'R6WindowWrappedTextArea', 
													  m_fXTitleOffset, 
													  m_pGreenTeam.WinTop + m_pGreenTeam.WinHeight, 
													  WinWidth - m_fXTitleOffset, 
													  iTemp, 
													  self));
	m_pRedTeam.m_HBorderTexture = None;
	m_pRedTeam.m_VBorderTexture = None;
	m_pRedTeam.SetScrollable(false);
	m_pRedTeam.HideWindow();

	m_AAdvLoc[0] = Localize("MPInGame","AlphaTeam","R6Menu") $ " : ";
	m_AAdvLoc[1] = Localize("MPInGame","BravoTeam","R6Menu") $ " : ";
}

function CreateObjWindow()
{
	local INT y, iNbOfObj;

	iNbOfObj = m_AObjectives.Length;

	y = m_Title.WinTop + m_Title.WinHeight + m_fObjYOffset + (m_fObjHeight * iNbOfObj);
	m_AObjectives[iNbOfObj] = R6MenuObjectiveLabel(CreateWindow(class'R6MenuObjectiveLabel', m_fXTitleOffset, y, WinWidth - m_fXTitleOffset, m_fObjHeight, self));
	m_AObjectives[iNbOfObj].HideWindow();
}

function SetNewObjWindowSizes( FLOAT _X, FLOAT _Y, FLOAT _W, FLOAT _H, bool _bCoopType)
{
	local INT i, iNbOfObj;

	m_Title.WinLeft   = m_fXTitleOffset;
	m_Title.WinTop    = m_fYTitleOffset;
	m_Title.WinWidth  = _W;

	if (_bCoopType)
	{
		iNbOfObj = m_AObjectives.Length;
		for(i=0; i < iNbOfObj; i++)
		{
			m_AObjectives[i].WinLeft   = m_fXTitleOffset;
			m_AObjectives[i].WinWidth  = _W;
			m_AObjectives[i].WinHeight = _H;

			m_AObjectives[i].SetNewLabelWindowSizes( m_fXTitleOffset, _Y, _W, _H);
		}
	}
}


function UpdateObjectives()
{
	local string szObjectiveDesc, szLocalization;
    local int i;
    local GameReplicationInfo repInfo;
	local R6MenuInGameMultiPlayerRootWindow R6Root; 

	R6Root = R6MenuInGameMultiPlayerRootWindow(Root);

	if (R6Root.m_eCurrentGameMode == GetLevel().EGameModeInfo.GMI_Adversarial)
	{
		m_pGreenTeam.clear();
		m_pRedTeam.HideWindow();
    
		m_pGreenTeam.m_fXOffset=10;

		if (GetLevel().IsGameTypeTeamAdversarial( R6Root.m_szCurrentGameType))
		{
			m_pGreenTeam.AddText( m_AAdvLoc[0] $ GetLevel().GetGreenTeamObjective(R6Root.m_szCurrentGameType), Root.Colors.White, Root.Fonts[F_SmallTitle]);

			m_pRedTeam.clear();
    		m_pRedTeam.m_fXOffset=10;
			m_pRedTeam.AddText( m_AAdvLoc[1] $ GetLevel().GetRedTeamObjective(R6Root.m_szCurrentGameType), Root.Colors.White, Root.Fonts[F_SmallTitle]);
			m_pRedTeam.ShowWindow();
		}
		else
		{
			m_pGreenTeam.AddText( GetLevel().GetGreenTeamObjective(R6Root.m_szCurrentGameType), Root.Colors.White, Root.Fonts[F_SmallTitle]);
		}

		m_pGreenTeam.ShowWindow();
	}
	else
	{
		///////////////////////////////// Update Mission Objectives /////////////////////////////////
		repInfo = root.Console.ViewportOwner.Actor.GameReplicationInfo;
        
		//Set up all displayable objectives
		for(i=0; i < m_AObjectives.Length; i++)
		{
			m_AObjectives[i].HideWindow();
		}

		for ( i = 0; i < repInfo.GetRepMObjInfoArraySize(); ++i )
		{
			szObjectiveDesc = repInfo.GetRepMObjString( i );
    
			if ( szObjectiveDesc == "" )
				break;
    
			szObjectiveDesc = Localize( "Game", szObjectiveDesc, repInfo.GetRepMObjStringLocFile( i ) );

			if ( i == m_AObjectives.Length)
			{
				CreateObjWindow();
			}

			m_AObjectives[i].SetProperties( szObjectiveDesc,	
											repInfo.IsRepMObjCompleted( i ));  
			m_AObjectives[i].ShowWindow();
		}
	}
}

defaultproperties
{
     m_fYTitleOffset=3.000000
}
