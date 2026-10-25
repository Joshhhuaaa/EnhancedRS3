//=============================================================================
//  R6CircumstantialActionQuery.uc : describes action that can be performed on an actor
//                                  originally stCircumstantialActionQuery
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/04/03 * Created by Aristomenis Kolokathis
//=============================================================================
class R6CircumstantialActionQuery extends R6AbstractCircumstantialActionQuery;

var bool bShowLog;
var bool m_bNeedsTick;


simulated event Tick( FLOAT fDelta )
{
	local R6PlayerController playerController;

    //    if (IsLocallyControlled() && 
    if (m_bNeedsTick)
    {
        // Action button is still down
        if( Level.TimeSeconds - m_fPressedTime >= 0.4f )
        {
			playerController = R6PlayerController(aQueryOwner);
            // If in range, player perform action
            if( iInRange == 1 && bCanBeInterrupted )
            {
                playerController.m_InteractionCA.PerformCircumstantialAction( CACTION_Player );
            }
               
            // If there is at least one team action available
            else if( iInRange == 0 && iTeamActionIDList[0] != 0 && playerController.CanIssueTeamOrder() )
            {
                if( bShowLog ) log( "**** Displaying rose des vents ! ****" );        
                playerController.m_InteractionCA.DisplayMenu(true);
            }
            m_bNeedsTick = false;
        }
    }
}

simulated function ClientPerformCircumstantialAction()
{
    if (bShowLog) log( "R6CAQ **** Executing player action ! ****" );        
    R6PlayerController(aQueryOwner).m_InteractionCA.PerformCircumstantialAction( CACTION_Player );
}

simulated function ClientDisplayMenu(BOOL bDisplay)
{
    if (bShowLog) log("setting DisplayMenu "$bDisplay);
    R6PlayerController(aQueryOwner).m_InteractionCA.DisplayMenu(bDisplay);
}

defaultproperties
{
}
