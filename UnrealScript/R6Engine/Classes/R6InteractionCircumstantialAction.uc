//=============================================================================
//  R6InteractionCircumstantialAction.uc : Interaction associated with the inventory.
//
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/21 * Created by Sébastien Lussier
//=============================================================================
class R6InteractionCircumstantialAction extends R6InteractionRoseDesVents;


#exec OBJ LOAD FILE=..\Textures\R6ActionIcons.utx PACKAGE=R6ActionIcons
#exec OBJ LOAD FILE=..\Textures\R6HUD.utx PACKAGE=R6HUD
#exec OBJ LOAD FILE=..\textures\R6TexturesReticule.utx PACKAGE=R6TexturesReticule

var     Texture                 m_TexProgressCircle;
var     Texture                 m_TexProgressItem;
var		Texture					m_TexFakeReticule;
var		font					m_SmallFont_14pt;

enum eCircumstantialActionPerformer
{
    CACTION_Player,
    CACTION_Team,
    CACTION_TeamFromList,
    CACTION_TeamFromListZulu,
};


event Initialized()
{
    Super.Initialized();
}


function ActionKeyPressed()
{
    if (m_Player.Level.NetMode!=NM_Standalone)
    {
        m_Player.ServerActionKeyPressed();
    }
    m_Player.SetRequestedCircumstantialAction();

    //check if we have action
    if( m_Player.m_RequestedCircumstantialAction.iHasAction == 1 )
    {
        m_Player.m_RequestedCircumstantialAction.m_bNeedsTick=true;
        m_Player.m_RequestedCircumstantialAction.m_fPressedTime = m_Player.Level.TimeSeconds;
    }
}


// Action button was released
function ActionKeyReleased()
{
    m_Player.ServerActionKeyReleased();
    m_Player.SetRequestedCircumstantialAction();
    m_Player.m_RequestedCircumstantialAction.m_bNeedsTick=false;
    m_Player.m_RequestedCircumstantialAction.m_fPressedTime = 0;

	if(m_Player.PlayerCanSwitchToAIBackup())
	{
		// if dead, switch to next teammate...
		if(m_Player.pawn != none && !m_Player.pawn.IsAlive())
		{
			m_Player.RegroupOnMe();
			return;
		}
	}
	else if( m_Player.m_bReadyToEnterSpectatorMode )
	{
		// in multiplayer, enter spectator mode
		m_Player.EnterSpectatorMode();
		return;
	}

	if( m_Player.m_RequestedCircumstantialAction.iHasAction != 1 )
    {
        DisplayMenu(false);
        return;
    }

    // If not in range, perform team action
    if( m_Player.m_RequestedCircumstantialAction.iInRange != 1)
    {
        #ifdefDEBUG	if( bShowLog ) log( "**** Executing team action ! ****" );	#endif
        m_Player.m_InteractionCA.PerformCircumstantialAction( CACTION_Team );
    }

    // If in range, player perform action
    else if( m_Player.m_pawn.CanInteractWithObjects() && m_Player.m_RequestedCircumstantialAction.iInRange == 1 && 
             !m_Player.m_RequestedCircumstantialAction.bCanBeInterrupted )
    {
        if( m_Player.m_RequestedCircumstantialAction.aQueryTarget == m_Player )
        {
            #ifdefDEBUG if( bShowLog ) log( "**** Regroup on Leader ! ****" );	#endif
            m_Player.RegroupOnMe();                
        }
        else
        {
            #ifdefDEBUG if( bShowLog ) log( "PlayerController **** Executing player action ! ****" );	#endif
            m_Player.m_InteractionCA.PerformCircumstantialAction( CACTION_Player );
        }
    }
    else if (m_Player.m_RequestedCircumstantialAction.aQueryTarget.IsA('R6IORotatingDoor'))
    {
        if (R6IORotatingDoor(m_Player.m_RequestedCircumstantialAction.aQueryTarget).m_bIsDoorLocked)
        {
            R6Pawn(m_Player.Pawn).ServerPerformDoorAction(R6IORotatingDoor(m_Player.m_RequestedCircumstantialAction.aQueryTarget), 14); //SA_Lock
        }
    }

    DisplayMenu(false);
}


simulated function BOOL MenuItemEnabled( INT iItem )
{
    local BOOL  bActionCanBeExecuted;
    local INT   iSubMenuChoice;

	iSubMenuChoice = m_iCurrentSubMnuChoice*4 + iItem;

    if( iItem < 0 || iItem > 3 )
        return false;

    if( m_iCurrentSubMnuChoice != -1 )
    {
        bActionCanBeExecuted = m_Player.m_CurrentCircumstantialAction.aQueryTarget.R6ActionCanBeExecuted( m_Player.m_CurrentCircumstantialAction.iTeamSubActionsIDList[iSubMenuChoice], m_Player );
    }
    else
    {
        if (m_Player.m_CurrentCircumstantialAction.iTeamActionIDList[iItem] != 0)
            bActionCanBeExecuted = m_Player.m_CurrentCircumstantialAction.aQueryTarget.R6ActionCanBeExecuted( m_Player.m_CurrentCircumstantialAction.iTeamActionIDList[iItem], m_Player );
        else
            bActionCanBeExecuted = false;
    }
 
    return bActionCanBeExecuted;
}


function BOOL CurrentItemHasSubMenu()
{
    local INT i;
	
	// We're already in a sub menu.
	if( m_iCurrentSubMnuChoice != -1 )
		return false;

	for( i = m_iCurrentMnuChoice*4; i < (m_iCurrentMnuChoice + 1)*4; i++ )
	{
		// If we find at least one valid item in the sub menu.
		if( m_Player.m_CurrentCircumstantialAction.iTeamSubActionsIDList[i] != 0 )
			return true;
	}

	// No item found in the sub menu.
	return false;
}

function BOOL ItemHasSubMenu(int iItem)
{
    local INT i;

	// We're already in a sub menu.
	if( m_iCurrentSubMnuChoice != -1 )
		return false;

	for( i = iItem*4; i < (iItem + 1) * 4; i++ )
    {
        if (m_Player.m_CurrentCircumstantialAction.iTeamSubActionsIDList[i] != 0)
            return true;
    }

    return false;
}


function GotoSubMenu()
{
    m_Player.m_RequestedCircumstantialAction.iMenuChoice = m_Player.m_RequestedCircumstantialAction.iTeamActionIDList[m_iCurrentMnuChoice];
	m_iCurrentSubMnuChoice = m_iCurrentMnuChoice;
	m_iCurrentMnuChoice=0;
}


function BOOL IsValidMenuChoice( INT iChoice )
{
    local INT iSubMenuChoice;
	iSubMenuChoice = m_iCurrentSubMnuChoice*4 + iChoice;

    if( iChoice < 0 || iChoice > 3 )
    {
        return false;
    }

    if( (m_iCurrentSubMnuChoice != -1 && 
         m_Player.m_CurrentCircumstantialAction.iTeamSubActionsIDList[iSubMenuChoice] != 0 &&
         m_Player.m_CurrentCircumstantialAction.aQueryTarget.R6ActionCanBeExecuted(m_Player.m_CurrentCircumstantialAction.iTeamSubActionsIDList[iSubMenuChoice], m_Player)) ||
	    m_Player.m_CurrentCircumstantialAction.iTeamActionIDList[iChoice] != 0)
    {
        return true;
    }
    
    return false;
}


function SetMenuChoice( INT iChoice )
{
    if( iChoice < 0 || iChoice > 3 )
    {
        m_iCurrentMnuChoice = -1;    // Invalid, don't display
    }
	// Validate for sub menu and main menu
	else if( IsValidMenuChoice(iChoice) )
    {
        m_iCurrentMnuChoice = iChoice;
    }
    else
    {
        SetMenuChoice( iChoice - 1 );
    }   
}


function NoItemSelected()
{
    m_Player.SetRequestedCircumstantialAction();
}


function ItemClicked( INT iItem )
{
	#ifdefDEBUG if( bShowLog ) log( "**** LeftMouse -> Execute team action ! ****" );	#endif
	PerformCircumstantialAction( CACTION_TeamFromList );
}


function ItemRightClicked( INT iItem )
{
    // Right click on orders to give them to your team at Zulu Go Code
	#ifdefDEBUG if( bShowLog ) log( "**** RightMouse -> Execute team action at Zulu Go Code ! ****" );	#endif
	PerformCircumstantialAction( CACTION_TeamFromListZulu );
}


///////////////////////////////////////////////////////////////////////////////
// PerformCircumstantialAction()
//  Execute the action that the player wanted. 
///////////////////////////////////////////////////////////////////////////////


function PerformCircumstantialAction( eCircumstantialActionPerformer ePerformer )
{     
    if ( m_Player.m_RequestedCircumstantialAction == none )
        return;

    if( m_iCurrentSubMnuChoice != -1 )
	{
		m_Player.m_RequestedCircumstantialAction.iMenuChoice = 
            m_Player.m_RequestedCircumstantialAction.iTeamActionIDList[m_iCurrentSubMnuChoice];
		m_Player.m_RequestedCircumstantialAction.iSubMenuChoice = 
			m_Player.m_RequestedCircumstantialAction.iTeamSubActionsIDList[m_iCurrentSubMnuChoice*4+m_iCurrentMnuChoice];
	}
	else if( m_iCurrentMnuChoice != -1 )
	{
		m_Player.m_RequestedCircumstantialAction.iMenuChoice = 
            m_Player.m_RequestedCircumstantialAction.iTeamActionIDList[m_iCurrentMnuChoice];
		m_Player.m_RequestedCircumstantialAction.iSubMenuChoice = -1;
	}

	switch( ePerformer )
    {
    case CACTION_Player:
        // If the action require some time, display the progress
        if( m_Player.m_RequestedCircumstantialAction.bCanBeInterrupted )
        {
            ActionProgressStart();
        }
        else
        {
			m_Player.m_pawn.ActionRequest( m_Player.m_RequestedCircumstantialAction );
        }
        break;

    case CACTION_Team:
        m_Player.m_TeamManager.TeamActionRequest( m_Player.m_RequestedCircumstantialAction);
        break;
        
    case CACTION_TeamFromList:
		m_Player.m_TeamManager.TeamActionRequestFromRoseDesVents( m_Player.m_RequestedCircumstantialAction, m_Player.m_RequestedCircumstantialAction.iMenuChoice, m_Player.m_RequestedCircumstantialAction.iSubMenuChoice );            
        break;

    case CACTION_TeamFromListZulu:
		m_Player.m_TeamManager.TeamActionRequestWaitForZuluGoCode( m_Player.m_RequestedCircumstantialAction, m_Player.m_RequestedCircumstantialAction.iMenuChoice, m_Player.m_RequestedCircumstantialAction.iSubMenuChoice );         
        break;
    }
}
 

///////////////////////////////////////////////////////////////////////////////
// ActionProgressStart()                                                     
///////////////////////////////////////////////////////////////////////////////
function ActionProgressStart()
{
	if(!R6Pawn(m_Player.pawn).CanInteractWithObjects())
		return;

    m_Player.m_PlayerCurrentCA = m_Player.m_RequestedCircumstantialAction;

    GotoState('ActionProgress');
    m_Player.ServerPlayerActionProgress();
	
	if(m_Player.m_PlayerCurrentCA.aQueryTarget.IsA('R6Terrorist'))
		m_Player.GotoState('PlayerSecureTerrorist');
//---MissionPack1 // MPF1 limit 
	else if( class'Actor'.static.GetModMgr().IsMissionPack() &&
                 m_Player.m_PlayerCurrentCA.aQueryTarget.IsA('R6Rainbow'))
    {
		m_Player.GotoState('PlayerSecureRainbow');
    }
//---------------
	else
		m_Player.GotoState('PlayerActionProgress');
}


///////////////////////////////////////////////////////////////////////////////
// ActionProgressStop()                                                      
///////////////////////////////////////////////////////////////////////////////
function ActionProgressStop()
{
    DisplayMenu(false);
    // MPF1 limit 
    if ( class'Actor'.static.GetModMgr().IsMissionPack() )
    {
         if(m_Player.pawn.IsAlive() /*MissionPack1*/&& !m_Player.m_pawn.m_bIsSurrended/* MissionPack1*/) 
               m_Player.GotoState('PlayerWalking');
    }
    else
    {
	if(m_Player.pawn.IsAlive())
		m_Player.GotoState('PlayerWalking');
     }
    m_Player.m_PlayerCurrentCA = none;
}


///////////////////////////////////////////////////////////////////////////////
// ActionProgressDone()                                                      
///////////////////////////////////////////////////////////////////////////////
function ActionProgressDone()
{
    // Execute action
    m_Player.m_pawn.ActionRequest( m_Player.m_PlayerCurrentCA );

    DisplayMenu(false);
    m_bIgnoreNextActionKeyRelease=true;

    m_Player.GotoState('PlayerWalking');
    m_Player.m_PlayerCurrentCA = none;    
}



///////////////////////////////////////////////////////////////////////////////
// state ActionProgress
///////////////////////////////////////////////////////////////////////////////
state ActionProgress 
{
    function bool KeyEvent( EInputKey eKey, EInputAction eAction, FLOAT fDelta )
    {
        if( eKey == m_Player.GetKey(m_ActionKey)) 
        {			
		    if( eAction == IST_Release )
            {
                m_Player.ServerActionProgressStop();
                // MPF1 limit 
                if ( class'Actor'.static.GetModMgr().IsMissionPack() )
                {
                    if(m_Player.pawn.IsAlive()/*MissionPack1*/&& !m_Player.m_pawn.m_bIsSurrended/* MissionPack1*/)
		                m_Player.GotoState('PlayerWalking');               
                }
                else
                {
                    if(m_Player.pawn.IsAlive())
		                m_Player.GotoState('PlayerWalking');               
                }
                DisplayMenu(false);
                m_bActionKeyDown = false;
                return true;
            }    
        }    

        return true; //return Super.KeyEvent(eKey, eAction, fDelta);
    }
}


function PostRender( Canvas C )
{
    local R6GameOptions GameOptions;

    GameOptions = class'Actor'.static.GetGameOptions();
    if( m_Player == none)
        return;

    C.UseVirtualSize(true);
    if (GameOptions.HUDShowActionIcon || m_Player.m_bShowCompleteHUD)
    {
	    if( (m_Player.pawn != none) && !m_Player.pawn.IsAlive() )
	    {
			if(	m_Player.PlayerCanSwitchToAIBackup() )
			{
				DrawDeadCircumstantialIcon( C );
				C.UseVirtualSize(false);
				return;
			}
			else if( m_Player.Level.NetMode != NM_Standalone && m_Player.m_bReadyToEnterSpectatorMode && !m_Player.bOnlySpectator )
			{
				DrawGotoSpectatorModeIcon( C );
				C.UseVirtualSize(false);
				return;
			}
		}
    }

    Super.PostRender( C );
    DrawCircumstantialActionInfo( C );

    C.UseVirtualSize(false);
}

function DrawGotoSpectatorModeIcon( Canvas C )
{
	C.Style = 5;
	C.SetDrawColor( m_Player.m_SpectatorColor.R, 
					m_Player.m_SpectatorColor.G,
					m_Player.m_SpectatorColor.B, 
					m_Player.m_SpectatorColor.A );
	C.SetPos( C.HalfClipX - 16, C.ClipY - 74 );
	C.DrawTile( Texture'R6ActionIcons.GotoSpectator', 32, 32, 0, 0, 32, 32);
}

function DrawDeadCircumstantialIcon( Canvas C )
{
    local string szNextTeamMate; 
    local float  w, h;

	if(m_Player.m_TeamManager != none)	
	{
		C.Style = 5;
		C.SetDrawColor(	m_Player.m_TeamManager.Colors.HUDWhite.R,
						m_Player.m_TeamManager.Colors.HUDWhite.G,
						m_Player.m_TeamManager.Colors.HUDWhite.B,
						m_Player.m_TeamManager.Colors.HUDWhite.A );
		C.SetPos( C.HalfClipX - 16, C.ClipY - 74 );
		C.DrawTile( Texture'R6ActionIcons.NextTeamMate', 32, 32, 0, 0, 32, 32);
    
        if ( R6GameReplicationInfo( m_player.GameReplicationInfo ).m_iDiffLevel == 1 ) // only in recruit
        {
            szNextTeamMate = Localize("Order","NextTeamMate","R6Menu"); 
            szNextTeamMate = m_player.GetLocStringWithActionKey( szNextTeamMate, "Action" );
            C.TextSize( szNextTeamMate, w, h  );
            C.SetPos( (C.HalfClipX - 16) - w/2, C.ClipY - 20 );
            C.DrawText( szNextTeamMate);
        }
	}
}

function DrawSpectatorReticule( Canvas C )
{
	local INT X, Y;
    local FLOAT fScale;
	local FLOAT fStrSizeX, fStrSizeY;
	local R6Pawn OtherPawn;
	local string characterName;

    X = C.HalfClipX;
    Y = C.HalfClipY;

	C.SetDrawColor(255,0,0);
    C.Style = 5;
    fScale = 16 / m_TexFakeReticule.VSize;
    C.SetPos(X - (m_TexFakeReticule.USize * fScale /2) + 1, Y - (m_TexFakeReticule.VSize * fScale/2) + 1);
    C.DrawIcon(m_TexFakeReticule, fScale);

	if(m_Player.bOnlySpectator && (!m_Player.bBehindview || m_Player.bCheatFlying))
	{
		m_Player.UpdateSpectatorReticule();
		characterName = m_Player.m_CharacterName;
	}
	else
	{
		m_Player.m_CharacterName = "";
		characterName = "";
	}
	
	C.Font = m_SmallFont_14pt; 
	C.StrLen(characterName, fStrSizeX, fStrSizeY);
	C.SetPos(X - fStrSizeX/2, Y + 20);
	C.DrawText(characterName);
}	

//===========================================================================//
// DrawCircumstantialActionInfo()                                            //
//  Draw circumstantial action stuff, like the rose des vents and the action //
//  icon if there is one.                                                    //
//===========================================================================//
function DrawCircumstantialActionInfo( Canvas C )
{
    local R6CircumstantialActionQuery   Query;
    local INT                           iMnuChoice;
	local INT	                        iSubMenu;
    local BOOL                          bHasAction;
    local COLOR                         TeamColor;
    local R6GameOptions                 GameOptions;

    if( m_Player == none )
		return;      

    if ( m_Player.m_CurrentCircumstantialAction == none )
        return;

    GameOptions = class'Actor'.static.GetGameOptions();
    
    bHasAction = m_Player.m_CurrentCircumstantialAction.iHasAction == 1;
    Query = m_Player.m_CurrentCircumstantialAction;
    
    C.Style = 5; //STY_Alpha;

    if(m_Player.m_bDisplayMessage && GameOptions.HUDShowActionIcon)
    {
        C.SetDrawColor(m_Player.m_TeamManager.Colors.HUDWhite.R,
					   m_Player.m_TeamManager.Colors.HUDWhite.G,
					   m_Player.m_TeamManager.Colors.HUDWhite.B,
					   m_Player.m_TeamManager.Colors.HUDWhite.A);
	    C.SetPos( C.HalfClipX - 24, C.ClipY - 82 );
	    C.DrawTile( Texture'R6ActionIcons.SkipText', 48, 48, 0, 0, 32, 32);
        
        if( m_Player.m_iPlayerCAProgress > 0 || m_Player.m_bDisplayActionProgress)
        {
            SetPosAndDrawActionProgress( C );
        }
        return;
    }

	if(m_Player.bOnlySpectator &&
		!m_Player.bBehindView &&
        !m_Player.Level.m_bInGamePlanningActive && 
       (GameOptions.HUDShowReticule || m_Player.m_bShowCompleteHUD))
    {
        DrawSpectatorReticule(C);
    }

	if( m_Player.bOnlySpectator && (GameOptions.HUDShowActionIcon || m_Player.m_bShowCompleteHUD))
	{	
		if(m_Player.m_TeamManager != none)
		{
			TeamColor = m_Player.m_TeamManager.Colors.HUDWhite;
		}
		else
		{
			// ghost camera mode
			TeamColor = m_Player.m_SpectatorColor;
		}

		C.SetDrawColor(TeamColor.R, TeamColor.G, TeamColor.B, TeamColor.A);
		C.SetPos( C.HalfClipX - 16, C.ClipY - 74 );
		C.DrawTile( Texture'R6ActionIcons.Spectator', 32, 32, 0, 0, 32, 32);
		return;
	}

	if( m_Player.m_TeamManager == none )
		return;

    // Player is performing an action
    if( m_Player.m_iPlayerCAProgress > 0 || m_Player.m_bDisplayActionProgress)
    {
        SetPosAndDrawActionProgress( C );
    }
    // Verify if no menu is displayed
    else if( bHasAction && !m_Player.m_bAMenuIsDisplayed )
    {
        if (Query.iInRange == 0) 
        {			
            //* Do not display the Icon if there is no team members with the player
			if(!m_Player.CanIssueTeamOrder())
                return;

            TeamColor = m_Player.m_TeamManager.GetTeamColor();
            C.SetDrawColor(	m_Player.m_TeamManager.Colors.HUDGrey.R,
							m_Player.m_TeamManager.Colors.HUDGrey.G,
							m_Player.m_TeamManager.Colors.HUDGrey.B,
							m_Player.m_TeamManager.Colors.HUDGrey.A);
        }	
        else if ( m_Player.pawn != none )
        {
            if(!R6Pawn(m_Player.pawn).CanInteractWithObjects())
				return;

            C.SetDrawColor(	m_Player.m_TeamManager.Colors.HUDWhite.R,
							m_Player.m_TeamManager.Colors.HUDWhite.G,
							m_Player.m_TeamManager.Colors.HUDWhite.B,
							m_Player.m_TeamManager.Colors.HUDWhite.A);

            // Regroup on player icon
            if( Query.aQueryTarget == m_Player )
            {			
                // Do not display the icon if there is no team members with the player
                if(!m_Player.CanIssueTeamOrder())
                    return;    
            }
		}
   
        if (GameOptions.HUDShowActionIcon || m_Player.m_bShowCompleteHUD)
        {
		    C.SetPos( C.HalfClipX - 16, C.ClipY - 74 );
		    C.DrawTile( Query.textureIcon, 32, 32, 0, 0, 32, 32);	
        }
    }
    // Display team action menu
    else if( bHasAction && bVisible && (Query.iInRange == 0))
    {
        //* Do not display the Rose des Vents if there is no team members with the player
        if(!m_Player.CanIssueTeamOrder())
            return;

        DrawTeamActionMnu( C, Query );
    }
}

//===========================================================================//
// SetPosAndDrawActionProgress()                                                       //
//===========================================================================//
function SetPosAndDrawActionProgress( Canvas C )
{
    local COLOR TeamColor;
    local R6GameOptions                 GameOptions;

    GameOptions = class'Actor'.static.GetGameOptions();
    
    if(!m_Player.Level.m_bInGamePlanningActive)
    {
        TeamColor = m_Player.m_TeamManager.GetTeamColor();
        C.SetDrawColor(m_Player.m_TeamManager.Colors.HUDWhite.R,
				       m_Player.m_TeamManager.Colors.HUDWhite.G,
				       m_Player.m_TeamManager.Colors.HUDWhite.B,
				       m_Player.m_TeamManager.Colors.HUDWhite.A);

        if (GameOptions.HUDShowReticule || m_Player.m_bShowCompleteHUD)
        {
            DrawActionProgress( C, m_Player.m_iPlayerCAProgress );
        }
	    
        if ((GameOptions.HUDShowActionIcon || m_Player.m_bShowCompleteHUD) && (m_Player.m_PlayerCurrentCA != none))
        {
		    C.SetPos( C.HalfClipX - 16, C.ClipY - 74 );
		    C.DrawTile( m_Player.m_PlayerCurrentCA.textureIcon, 32, 32, 0, 0, 32, 32);	

		    C.SetPos( C.HalfClipX - 24, C.ClipY - 82 );
		    C.DrawTile( Texture'R6ActionIcons.CancelAction', 48, 48, 0, 0, 32, 32);	
        }
    }
}

//===========================================================================//
// DrawTeamActionMnu()                                                       //
//===========================================================================//
function DrawTeamActionMnu( Canvas C, R6CircumstantialActionQuery Query)
{
    local string    strAction;
    local INT       iAction;
    local FLOAT     fPosX;
    local FLOAT     fPosY;
    local color     TeamColor;
    local FLOAT     fTextSizeX;
    local FLOAT     fTextSizeY;
    local FLOAT     fScaleX;
    local FLOAT     fScaleY;

    DrawRoseDesVents( C, m_iCurrentMnuChoice );

    C.OrgX = 0;
    C.OrgY = 0;

    C.UseVirtualSize(false);    

    fScaleX = C.SizeX / 800.0f;
    fScaleY = C.SizeY / 600.0f;
    
    TeamColor = m_Player.m_TeamManager.GetTeamColor();

    fPosX     = C.SizeX / 2.0f + fScaleX;
    fPosY     = C.SizeY / 2.0f + fScaleY;

    fTextSizeX = 75;
    fTextSizeY = 32;

    for( iAction = 0; iAction < 4; iAction++ ) 
    {
        // Draw the unactive choices darker
        if( MenuItemEnabled(iAction) )
        {
            if( m_iCurrentMnuChoice != iAction )
            {
                C.SetDrawColor( m_Player.m_TeamManager.Colors.HUDGrey.R,
								m_Player.m_TeamManager.Colors.HUDGrey.G,
								m_Player.m_TeamManager.Colors.HUDGrey.B,
								m_Player.m_TeamManager.Colors.HUDGrey.A);
            }
            else
            {
                C.SetDrawColor(m_Player.m_TeamManager.Colors.HUDWhite.R,
					           m_Player.m_TeamManager.Colors.HUDWhite.G,
							   m_Player.m_TeamManager.Colors.HUDWhite.B,
							   m_Player.m_TeamManager.Colors.HUDWhite.A);
            }
        }
        else 
        {
            C.SetDrawColor(m_Player.m_TeamManager.Colors.HUDGrey.R,
					       m_Player.m_TeamManager.Colors.HUDGrey.G,
						   m_Player.m_TeamManager.Colors.HUDGrey.B,
						   m_Player.m_TeamManager.Colors.HUDGrey.A);
        }

		// If in main menu
		if( m_iCurrentSubMnuChoice == -1 )
		{
			strAction = Query.aQueryTarget.R6GetCircumstantialActionString( Query.iTeamActionIDList[iAction] );
		}
		else	// We're in a sub menu
		{
			strAction = Query.aQueryTarget.R6GetCircumstantialActionString( Query.iTeamSubActionsIDList[m_iCurrentSubMnuChoice*4 + iAction] );
		}

		C.Style = 3;    // STY_Translucent

        switch( iAction )
        {
        case 0:
            DrawTextCenteredInBox( C, strAction, fPosX - (fTextSizeX * fScaleX / 2.0f), fPosY - (50 + fTextSizeY) * fScaleY,  fTextSizeX * fScaleX, fTextSizeY * fScaleY);
            break;
        case 1:
            DrawTextCenteredInBox( C, strAction, fPosX + 35 * fScaleX, fPosY - (fTextSizeY / 2) * fScaleY,  fTextSizeX * fScaleX, fTextSizeY * fScaleY);
            break;
        case 2:
            DrawTextCenteredInBox( C, strAction, fPosX - (fTextSizeX *fScaleX / 2.0f), fPosY + 50 * fScaleY,  fTextSizeX * fScaleX, fTextSizeY * fScaleY);
            break;
        case 3:
            DrawTextCenteredInBox( C, strAction, fPosX - (35 + fTextSizeX) * fScaleX, fPosY - (fTextSizeY / 2) * fScaleY,  fTextSizeX * fScaleX, fTextSizeY * fScaleY);
            break;
        }       
    }

    C.OrgX = 0;
    C.OrgY = 0;
    C.SetDrawColor(TeamColor.R, TeamColor.R, TeamColor.R, TeamColor.A);
}


//===========================================================================//
// DrawActionProgress()                                                      //
//===========================================================================//
function DrawActionProgress( Canvas C, FLOAT fProgress )
{
    local INT iItem, fDegreeProgress;

    for(iItem=0; iItem*30<360.0f; iItem++)
    {
        C.SetPos((C.ClipX - m_TexProgressCircle.USize) * 0.5f, (C.ClipY - m_TexProgressCircle.VSize) * 0.5f);
        C.DrawTile(m_TexProgressCircle, m_TexProgressCircle.USize, m_TexProgressCircle.VSize, 0, 0, m_TexProgressCircle.USize, m_TexProgressCircle.VSize, iItem*30*PI/180);
    }

    fDegreeProgress = fProgress * 3.60f;
    for(iItem=1; iItem*30<fDegreeProgress; iItem++)
    {
        C.SetPos((C.ClipX - m_TexProgressItem.USize) * 0.5f, (C.ClipY - m_TexProgressItem.VSize) * 0.5f);
        C.DrawTile(m_TexProgressItem, m_TexProgressItem.USize, m_TexProgressItem.VSize, 0, 0, m_TexProgressItem.USize, m_TexProgressItem.VSize, (iItem-1)*30*PI/180);
    }
}

defaultproperties
{
     m_TexProgressCircle=Texture'R6HUD.ProgressCircle'
     m_TexProgressItem=Texture'R6HUD.ProgressItem'
     m_TexFakeReticule=Texture'R6TexturesReticule.Dot'
     m_SmallFont_14pt=Font'R6Font.Rainbow6_14pt'
     m_ActionKey="Action"
}
