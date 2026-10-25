//=============================================================================
//  R6MenuInGameEsc.uc : This pops in single player when we presse ESC 
//                              in single player
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/5/16 * Created by Alexandre Dionne
//=============================================================================
class R6MenuInGameEsc extends R6MenuWidget;


//Top Labels showing location of the current mission
var R6WindowTextLabel			m_CodeName, 
                                m_DateTime, 
                                m_Location;
var FLOAT                       m_fLabelHeight;

// the nav bar 
var R6MenuInGameEscSinglePlayerNavBar	m_pInGameNavBar;               
var FLOAT   m_fNavBarHeight;

var R6MenuSingleTeamBar         m_pR6RainbowTeamBar;   // the rainbows for the mission with their stats
var FLOAT                       m_fRainbowStatsHeight;

var R6MenuEscObjectives         m_EscObj;

function Created()
{
	if (R6MenuInGameRootWindow(Root).m_bInTraining)
	{
		InitTrainingEsc();
	}
	else
	{
		InitInGameEsc();
	}
}

function InitInGameEsc()
{
    local FLOAT                         LabelWidth;
    local R6MenuInGameRootWindow        R6Root;
    
    R6Root = R6MenuInGameRootWindow(Root);

    //////////////////////////////////     Title Labels     /////////////////////////////////////////////
	LabelWidth = R6Root.m_REscMenuWidget.W/3;
    // CODE NAME
	m_CodeName = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                R6Root.m_REscMenuWidget.X, 
                                                R6Root.m_REscMenuWidget.Y + R6Root.m_fTopLabelHeight, 
		                                        LabelWidth, 
                                                m_fLabelHeight, 
                                                self));
    

    // DATE TIME
	m_DateTime = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                m_CodeName.WinLeft + m_CodeName.WinWidth,
                                                m_CodeName.WinTop, 
                                                LabelWidth,
                                                m_fLabelHeight, 
                                                self));


    // LOCATION
	m_Location = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                m_DateTime.WinLeft + m_DateTime.WinWidth, 
                                                m_CodeName.WinTop, 
                                        		m_DateTime.WinWidth, 
                                                m_fLabelHeight, 
                                                self));


    ////////////////////////////////////// NAV BAR //////////////////////////////////////////////////////////
	m_pInGameNavBar = R6MenuInGameEscSinglePlayerNavBar( CreateWindow(class'R6MenuInGameEscSinglePlayerNavBar',                                            
											R6Root.m_REscMenuWidget.X,
											R6Root.m_REscMenuWidget.Y + R6Root.m_fTopLabelHeight + R6Root.m_REscMenuWidget.H - m_fNavBarHeight,
											R6Root.m_REscMenuWidget.W,
											m_fNavBarHeight,
											self));

    m_BorderColor = Root.Colors.Red;

    //Team stats
    m_pR6RainbowTeamBar = R6MenuSingleTeamBar( CreateWindow(class'R6MenuSingleTeamBar', m_CodeName.WinLeft, m_CodeName.WinTop + m_CodeName.WinHeight, R6Root.m_REscMenuWidget.W, m_fRainbowStatsHeight, self));    
    m_pR6RainbowTeamBar.m_IGPlayerInfoListBox.m_bIgnoreUserClicks = true;

    //Mission Objectives
    m_EscObj = R6MenuEscObjectives(CreateWindow(class'R6MenuEscObjectives', 
                                                m_pR6RainbowTeamBar.WinLeft, 
                                                m_pR6RainbowTeamBar.WinTop + m_pR6RainbowTeamBar.WinHeight, 
                                                m_pR6RainbowTeamBar.WinWidth, 
                                                m_pInGameNavBar.WinTop - m_pR6RainbowTeamBar.WinTop - m_pR6RainbowTeamBar.WinHeight));
}

function InitTrainingEsc()
{
    local R6MenuInGameRootWindow        R6Root;
    
    R6Root = R6MenuInGameRootWindow(Root);

    ////////////////////////////////////// NAV BAR //////////////////////////////////////////////////////////
	m_pInGameNavBar = R6MenuInGameEscSinglePlayerNavBar( CreateWindow(class'R6MenuInGameEscSinglePlayerNavBar',                                            
											R6Root.m_REscTraining.X,
											R6Root.m_REscTraining.Y + R6Root.m_fTopLabelHeight + R6Root.m_REscTraining.H - m_fNavBarHeight,
											R6Root.m_REscTraining.W,
											m_fNavBarHeight,
											self));
	m_pInGameNavBar.SetTrainingNavbar();
}

function ShowWindow()
{
    local R6MissionDescription CurrentMission;
    local R6MenuInGameRootWindow        R6Root;

    Super.ShowWindow();

    R6Root = R6MenuInGameRootWindow(Root);

    if (!R6Root.m_bInEscMenu)
    {
        GetPlayerOwner().SetPause(true);
        GetPlayerOwner().SaveCurrentFadeValue();
    
        R6PlayerController(GetPlayerOwner()).ClientFadeCommonSound(0.5, 0);

        GetPlayerOwner().FadeSound(0.5, 0, SLOT_Music);
        GetPlayerOwner().FadeSound(0.5, 0, SLOT_Speak);
    }

	if (R6Root.m_bInTraining)
	{
		return;
	}

    CurrentMission = R6MissionDescription(R6Console(Root.console).master.m_StartGameInfo.m_CurrentMission);

	m_CodeName.SetProperties( Localize(CurrentMission.m_MapName,"ID_CODENAME",CurrentMission.LocalizationFile),
							  TA_Center, Root.Fonts[F_Normal], Root.Colors.White, false);

	m_DateTime.SetProperties( Localize(CurrentMission.m_MapName,"ID_DATETIME",CurrentMission.LocalizationFile),
							  TA_Center, Root.Fonts[F_Normal], Root.Colors.White, false);

	m_Location.SetProperties( Localize(CurrentMission.m_MapName,"ID_LOCATION",CurrentMission.LocalizationFile),
							  TA_Center, Root.Fonts[F_Normal], Root.Colors.White, false);

    m_pR6RainbowTeamBar.RefreshTeamBarInfo();

    m_EscObj.UpdateObjectives();
}


function HideWindow()
{
    local R6MenuInGameRootWindow        R6Root;

    Super.HideWindow();

    R6Root = R6MenuInGameRootWindow(Root);

    if (!R6Root.m_bInEscMenu)
    {
        GetPlayerOwner().SetPause(false);

        GetPlayerOwner().ReturnSavedFadeValue(0.5);
    }
}

defaultproperties
{
     m_fLabelHeight=18.000000
     m_fNavBarHeight=55.000000
     m_fRainbowStatsHeight=166.000000
}
