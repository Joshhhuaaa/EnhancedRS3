//=============================================================================
//  R6MenuEscObjectives.uc : Objectives window in the esc menu of single player
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/07/04 * Created by Alexandre Dionne
//=============================================================================

class R6MenuEscObjectives extends UWindowWindow;

const C_MAXOBJ  = 10; // MPF_9_2_2003 - was 8, bug fixing for countdown game type

var R6WindowTextLabel			m_Title, m_NoObj;
var FLOAT                       m_fXTitleOffset, m_fYTitleOffset, m_fLabelHeight;
var R6MenuObjectiveLabel        m_Objectives[C_MAXOBJ];
var FLOAT                       m_fObjHeight, m_fObjYOffset;

var string						m_szTextFailed;

function Created()
{
    local INT i, y;

    m_Title = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                m_fXTitleOffset, 
                                                m_fYTitleOffset, 
		                                        WinWidth - m_fXTitleOffset, 
                                                m_fLabelHeight, 
                                                self));
    
    m_Title.SetProperties( Localize("ESCMENUS","MISSIONOBJ","R6Menu"),
                              TA_LEFT, Root.Fonts[F_SmallTitle], Root.Colors.BlueLight, false);
    
    y = m_Title.WinTop + m_Title.WinHeight + m_fObjYOffset;

    /////////////////////////////////////////////////////////////////
    //When we do not have any objective
    m_NoObj = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                m_fXTitleOffset, 
                                                y, 
		                                        WinWidth - m_fXTitleOffset, 
                                                m_fObjHeight, 
                                                self));
    
    m_NoObj.SetProperties( Localize("ESCMENUS","NOMISSIONOBJ","R6Menu"),
                              TA_LEFT, Root.Fonts[F_Normal], Root.Colors.White, false);
    m_NoObj.HideWindow();

    /////////////////////////////////////////////////////////////////////////

    //Creating the Objective Labels
    for(i=0; i<C_MAXOBJ; i++)
    {
        m_Objectives[i] = R6MenuObjectiveLabel(CreateWindow(class'R6MenuObjectiveLabel', 
                                                m_fXTitleOffset, 
                                                y, 
		                                        WinWidth - m_fXTitleOffset, 
                                                m_fObjHeight, 
                                                self));
        m_Objectives[i].HideWindow();
        y += m_fObjHeight;
    }

	m_szTextFailed = " (" $ Localize( "OBJECTIVES", "FAILED", "R6Menu") $ ")";
}

function UpdateObjectives()
{
    local R6MissionObjectiveMgr moMgr;
	local R6GameOptions pGameOptions;
	local string szTemp;
    local INT i, j;

	pGameOptions = class'Actor'.static.GetGameOptions();

    moMgr = R6AbstractGameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_missionMgr;
    
    //Set up all displayable objectives
    for(i=0; i<C_MAXOBJ; i++)
    {
        m_Objectives[i].HideWindow();
    }

    
    if(moMgr.m_aMissionObjectives.Length <= 0)
    {
        m_NoObj.ShowWindow();
    }
    else
    {
        m_NoObj.HideWindow();
		j = 0;
        for ( i = 0; i < moMgr.m_aMissionObjectives.Length && i<C_MAXOBJ; ++i )
        {
            if ( !moMgr.m_aMissionObjectives[i].m_bMoralityObjective && moMgr.m_aMissionObjectives[i].m_bVisibleInMenu )
            {
				szTemp = Localize( "Game", moMgr.m_aMissionObjectives[i].m_szDescriptionInMenu, moMgr.Level.GetMissionObjLocFile( moMgr.m_aMissionObjectives[i] ));

				if ((pGameOptions.UnlimitedPractice) && moMgr.m_aMissionObjectives[i].isFailed())
				{
                    m_Objectives[j].SetProperties(  szTemp, false, m_szTextFailed); 
				}
				else
				{
                    m_Objectives[j].SetProperties(  szTemp, moMgr.m_aMissionObjectives[i].isCompleted()); 
				}

                m_Objectives[j].ShowWindow();
				j++;
            }     
        } 

    }   
}

defaultproperties
{
     m_fXTitleOffset=10.000000
     m_fYTitleOffset=10.000000
     m_fLabelHeight=15.000000
     m_fObjHeight=15.000000
     m_fObjYOffset=2.000000
}
