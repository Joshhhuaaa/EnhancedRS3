//=============================================================================
//  R6PlayerCustomMission.uc : Will be in a file to keep a status of what map
//                             you have unlock in the campaign.
//						  
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================


class R6PlayerCustomMission extends Object native;

var Array<string>				m_aCampaignFileName;
var Array<int>					m_iNbMapUnlock;

defaultproperties
{
}
