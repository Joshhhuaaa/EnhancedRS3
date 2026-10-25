//=============================================================================
//  R6StoryModeGame.uc : Single player and Coop game info.
//						 See mission objectives and morality design docs.
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//	  2002/02/19 * Created by Sébastien Lussier
//=============================================================================

class R6StoryModeGame extends R6GameInfo;

/************************************************************************
 if you add something here, you should also add it in MissionMode.
************************************************************************/

//------------------------------------------------------------------
// InitObjectives
//	 Story Mode Objective
//------------------------------------------------------------------
function InitObjectives()
{
    InitObjectivesOfStoryMode();

    // Init: add morality and init the manager
    Super.InitObjectives();
}

///////////////////////////////////////////////////////////////////////////////
// EndGame()
///////////////////////////////////////////////////////////////////////////////
function EndGame( PlayerReplicationInfo Winner, string Reason ) 
{
    local R6GameReplicationInfo gameRepInfo;
    local R6MissionObjectiveBase obj;

    // This function has already been called
    if( m_bGameOver )
        return;

    gameRepInfo = R6GameReplicationInfo(GameReplicationInfo);
    if ( m_missionMgr.m_eMissionObjectiveStatus == eMissionObjStatus_success )
    {
        BroadcastMissionObjMsg( "", "", "", m_Player.Level.m_sndMissionComplete);
        BroadcastMissionObjMsg( "", "", "MissionSuccesfulObjectivesCompleted", Level.m_sndPlayMissionExtro);
    }
    else
    {
        obj = m_missionMgr.GetMObjFailed();
        BroadcastMissionObjMsg( "", "", "MissionFailed" );
        if ( obj != none ) // no failure
            BroadcastMissionObjMsg( Level.GetMissionObjLocFile( obj ), "", 
                                    obj.GetDescriptionFailure(), obj.GetSoundFailure() );
    }

    Super.EndGame( Winner, Reason );

    if ( m_bUsingPlayerCampaign )
        UpdatePlayerCampaign();
}

//------------------------------------------------------------------
// UpdatePlayerCampaign()
//	
//------------------------------------------------------------------
function UpdatePlayerCampaign()
{
    local R6PlayerCampaign          MyCampaign;    
    local R6MissionRoster           oDetailOfTheOperative;
    
    local R6Operative               oOperative;
    local R6Operative               oOperativeTmp;
    local Array<INT>                iOperativeInMission;
    local BOOL                      bAlreadyUpdate;
    
    local INT                       i, j;
    local R6Rainbow                 aR6Rainbow;    
    local R6RainbowTeam             aR6Team;
    local R6Console                 r6Console;

    // ***************************************************************************************************************************

    r6Console    = R6Console(m_Player.Player.Console);
    MyCampaign   = r6Console.m_PlayerCampaign;         
    oDetailOfTheOperative = MyCampaign.m_OperativesMissionDetails;    
    
    
    //****************************************************************************************************************************
       
    // Ajust all operative stats
    if(bShowlog)log("===== Update operative skills in mission =====");
    for (i=0; i<3; i++)
    {   
        //aR6Team = R6RainbowTeam(R6AbstractGameInfo(Root.Console.ViewportOwner.Actor.Level.Game).GetRainbowTeam(i)); // Get the rainbow team
        aR6Team = R6RainbowTeam(GetRainbowTeam(i)); // Get the rainbow team
        if (aR6Team != None)
        {
            if(bShowlog)log("R6Team "$aR6Team);
            for (j=0; j<4; j++)
            {
                aR6Rainbow = aR6Team.m_Team[j];
                if(bShowlog)log("R6Rainbow "$aR6Rainbow);
                if (aR6Rainbow == None)
                    break;

                aR6Rainbow.UpdateRainbowSkills();
                if(bShowlog)log("aR6Rainbow.m_iOperativeID"@aR6Rainbow.m_iOperativeID);

                iOperativeInMission[iOperativeInMission.Length] = aR6Rainbow.m_iOperativeID;
                oOperative = oDetailOfTheOperative.m_MissionOperatives[aR6Rainbow.m_iOperativeID];
                
                oOperative.m_fAssault	  = aR6Rainbow.m_fSkillAssault * 100;
                oOperative.m_fDemolitions = aR6Rainbow.m_fSkillDemolitions * 100;
                oOperative.m_fElectronics = aR6Rainbow.m_fSkillElectronics * 100;
                oOperative.m_fSniper	  = aR6Rainbow.m_fSkillSniper * 100;
                oOperative.m_fStealth	  = aR6Rainbow.m_fSkillStealth * 100;
                oOperative.m_fSelfControl = aR6Rainbow.m_fSkillSelfControl * 100;
                oOperative.m_fLeadership  = aR6Rainbow.m_fSkillLeadership * 100;
                oOperative.m_fObservation = aR6Rainbow.m_fSkillObservation * 100;
                oOperative.m_iHealth = aR6Rainbow.m_eHealth;
                oOperative.m_iNbMissionPlayed++;
                oOperative.m_iTerrokilled    += aR6Rainbow.m_iKills;
                oOperative.m_iRoundsfired    += aR6Rainbow.m_iBulletsFired;
                oOperative.m_iRoundsOntarget += aR6Rainbow.m_iBulletsHit;              
                
//				log("oOperative.m_szSpecialityID:  "$oOperative.m_szSpecialityID);
//                switch(aR6Rainbow.m_eSpecialty)
//                {
//                    case SPEC_Assault:
//                        oOperative.m_szSpecialityID = "ID_ASSAULT";                        
//                        break;
//                    case SPEC_Sniper:
//                        oOperative.m_szSpecialityID = "ID_SNIPER";                        
//                        break;
//                    case SPEC_Demolitions:
//                        oOperative.m_szSpecialityID = "ID_DEMOLITIONS";                        
//                        break;
//                    case SPEC_Electronics:
//                        oOperative.m_szSpecialityID = "ID_ELECTRONICS";                        
//                        break;
//                    case SPEC_Recon:
//                        oOperative.m_szSpecialityID = "ID_RECON";                        
//                        break;
//                }

                if(bShowlog)oOperative.DisplayStats();

                if(oOperative.m_iHealth > 1) //The operative is no more available is is incapacitated or dead
                {
                    //we need to create a backup operative;
                    switch(aR6Rainbow.m_szSpecialityID)
                    {
                    case "ID_ASSAULT":                        
                        oOperative = new(None) class'R6RookieAssault';
                        oOperative.m_szOperativeClass = "R6RookieAssault";
                        break;
                    case "ID_SNIPER":                        
                        oOperative = new(None) class'R6RookieSniper';
                        oOperative.m_szOperativeClass = "R6RookieSniper";
                        break;
                    case "ID_DEMOLITIONS":
                        oOperative = new(None) class'R6RookieDemolitions';
                        oOperative.m_szOperativeClass = "R6RookieDemolitions";
                        break;
                    case "ID_ELECTRONICS":
                        oOperative = new(None) class'R6RookieElectronics';
                        oOperative.m_szOperativeClass = "R6RookieElectronics";
                        break;
                    case "ID_RECON":                        
                        oOperative = new(None) class'R6RookieRecon';
                        oOperative.m_szOperativeClass = "R6RookieRecon";
                        break;
                    }
					
					if(bShowlog)log("aR6Rainbow.m_szSpecialityID: "$aR6Rainbow.m_szSpecialityID);
					if(bShowlog)log("oOperative.m_szOperativeClass: "$oOperative.m_szOperativeClass);

                    //Add R6Operative to the array
                    oOperative.m_iUniqueID = oDetailOfTheOperative.m_MissionOperatives.Length;
					oOperative.m_iRookieID = GetNextRookieIndex( oOperative.m_szOperativeClass);
                    iOperativeInMission[iOperativeInMission.Length] = oDetailOfTheOperative.m_MissionOperatives.Length;
                    oDetailOfTheOperative.m_MissionOperatives[oDetailOfTheOperative.m_MissionOperatives.Length] = oOperative;
                }
            }
        }
    }

    // Update all other operatives skills

    if(bShowlog)log("===== Update operative skills in training =====");
    for (i=0; i<MyCampaign.m_OperativesMissionDetails.m_MissionOperatives.Length;i++)
    {
        bAlreadyUpdate = false;
        for (j=0;j<iOperativeInMission.Length;j++)
        {
            if (i==iOperativeInMission[j])
            {
                bAlreadyUpdate = true;
                break;
            }
        }
        if (!bAlreadyUpdate)
        {
            oOperative = MyCampaign.m_OperativesMissionDetails.m_MissionOperatives[i];

            oOperative.UpdateSkills();
            if(bShowlog)oOperative.DisplayStats();
        }
    }


    if ( m_missionMgr.m_eMissionObjectiveStatus == eMissionObjStatus_success )
    {
        // Save the file here
        if( MyCampaign.m_iNoMission < r6Console.m_CurrentCampaign.m_missions.Length-1 )
        {
            MyCampaign.m_iNoMission++;
            MyCampaign.m_bCampaignCompleted = 0;
        }
        else    
        {
            MyCampaign.m_bCampaignCompleted = 1;
        }
    
    }   
    
}

function INT GetNextRookieIndex( string _szOperativeClass)
{
    local R6PlayerCampaign          MyCampaign;    
    local R6MissionRoster           oDetailOfTheOperative;
	local INT i, iNbOfOperatives, iTemp, iRookieIndex;

    MyCampaign			  = R6Console(m_Player.Player.Console).m_PlayerCampaign;         
    oDetailOfTheOperative = MyCampaign.m_OperativesMissionDetails;

	iNbOfOperatives = oDetailOfTheOperative.m_MissionOperatives.Length;
	iRookieIndex	= 0;

	for ( i=0; i < iNbOfOperatives; i++)
	{
		if ( oDetailOfTheOperative.m_MissionOperatives[i].m_szOperativeClass == _szOperativeClass)
		{
			if ( oDetailOfTheOperative.m_MissionOperatives[i].m_iRookieID != -1)
			{
				iRookieIndex = Max( iRookieIndex, oDetailOfTheOperative.m_MissionOperatives[i].m_iRookieID);
			}
		}
	}

	iRookieIndex++;

	return iRookieIndex;
}

function string GetIntelVideoName( R6MissionDescription desc )
{
    return desc.m_MapName;
}

defaultproperties
{
     m_bUsingPlayerCampaign=True
     m_bUsingCampaignBriefing=True
     m_szDefaultActionPlan="_MISSION_ACTION"
     m_bUseClarkVoice=True
     m_bPlayIntroVideo=True
     m_bPlayOutroVideo=True
     m_szGameTypeFlag="RGM_StoryMode"
}
