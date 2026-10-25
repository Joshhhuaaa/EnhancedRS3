//=============================================================================
//  R6PlayerCampaign.uc : A player campaing keeps tacks of the evolution of a 
//							user specific saved campaign, allow reloading and 
//							resuming of a player campaign
//						  
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/18 * Created by Alexandre Dionne
//=============================================================================


class R6PlayerCampaign extends Object native;

var	string						m_FileName;
var INT							m_iDifficultyLevel;
var string						m_CampaignFileName;
var INT				            m_iNoMission;
var R6MissionRoster     		m_OperativesMissionDetails;
var BYTE     		            m_bCampaignCompleted;

defaultproperties
{
}
