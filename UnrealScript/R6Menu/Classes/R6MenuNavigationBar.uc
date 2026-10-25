//=============================================================================
//  R6MenuNavigationBar.uc : (add small description)
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/26 * Created by Alexandre Dionne
//=============================================================================


class R6MenuNavigationBar extends UWindowDialogClientWindow;

var R6WindowButton             m_MainMenuButton, m_OptionsButton, m_BriefingButton, m_GearButton, 
							   m_PlanningButton, m_PlayButton,    m_SaveButton, m_LoadButton, m_QuickPlayButton;


var Texture                    m_TMainMenuTexture;
 
var Region                     m_RMainMenuButtonUp, m_RMainMenuButtonDown, m_RMainMenuButtonDisabled, m_RMainMenuButtonOver;
var Region                     m_ROptionsButtonUp,  m_ROptionsButtonDown,  m_ROptionsButtonDisabled,  m_ROptionsButtonOver;
var Region                     m_RBriefingButtonUp, m_RBriefingButtonDown, m_RBriefingButtonDisabled, m_RBriefingButtonOver;
var Region                     m_RGearButtonUp,     m_RGearButtonDown,     m_RGearButtonDisabled,     m_RGearButtonOver;
var Region                     m_RPlanningButtonUp, m_RPlanningButtonDown, m_RPlanningButtonDisabled, m_RPlanningButtonOver;
var Region                     m_RPlayButtonUp,     m_RPlayButtonDown,     m_RPlayButtonDisabled,     m_RPlayButtonOver;
var Region                     m_RSaveButtonUp,     m_RSaveButtonDown,     m_RSaveButtonDisabled,     m_RSaveButtonOver;
var Region                     m_RLoadButtonUp,     m_RLoadButtonDown,     m_RLoadButtonDisabled,     m_RLoadButtonOver;
var Region                     m_RQuickPlayButtonUp,m_RQuickPlayButtonDown,m_RQuickPlayButtonDisabled,m_RQuickPlayButtonOver;

var INT						   m_iNavBarLocation[9];
var INT						   m_iBigButtonHeight;


function Created()
{
    m_MainMenuButton    = R6WindowButton(CreateControl( class'R6WindowButton', m_iNavBarLocation[0], m_iBigButtonHeight, m_RMainMenuButtonUp.W, m_RMainMenuButtonUp.H, self));
    
    m_MainMenuButton.UpTexture          =   m_TMainMenuTexture;
    m_MainMenuButton.OverTexture        =   m_TMainMenuTexture;
    m_MainMenuButton.DownTexture        =   m_TMainMenuTexture;
    m_MainMenuButton.DisabledTexture    =   m_TMainMenuTexture;
    m_MainMenuButton.UpRegion           =   m_RMainMenuButtonUp;
    m_MainMenuButton.OverRegion         =   m_RMainMenuButtonOver;    
    m_MainMenuButton.DownRegion         =   m_RMainMenuButtonDown;   
    m_MainMenuButton.DisabledRegion     =   m_RMainMenuButtonDisabled;    
    m_MainMenuButton.bUseRegion         =   true;
    m_MainMenuButton.ToolTipString      =   Localize("PlanningMenu","Home","R6Menu");
    m_MainMenuButton.m_iDrawStyle       =   5; //Alpha


    m_OptionsButton     = R6WindowButton(CreateControl( class'R6WindowButton', m_iNavBarLocation[1], m_iBigButtonHeight, m_ROptionsButtonUp.W, m_ROptionsButtonUp.H, self));   
    m_OptionsButton.UpTexture          =   m_TMainMenuTexture;
    m_OptionsButton.OverTexture        =   m_TMainMenuTexture;
    m_OptionsButton.DownTexture        =   m_TMainMenuTexture;
    m_OptionsButton.DisabledTexture    =   m_TMainMenuTexture;
    m_OptionsButton.UpRegion           =   m_ROptionsButtonUp;
    m_OptionsButton.DownRegion         =   m_ROptionsButtonDown;   
    m_OptionsButton.DisabledRegion     =   m_ROptionsButtonDisabled;
    m_OptionsButton.OverRegion         =   m_ROptionsButtonOver;    
    m_OptionsButton.bUseRegion         =   true;
    m_OptionsButton.ToolTipString      =   Localize("PlanningMenu","Option","R6Menu");
    m_OptionsButton.m_iDrawStyle       =   5; //Alpha

    m_BriefingButton        = R6WindowButton(CreateControl( class'R6WindowButton', m_iNavBarLocation[2], m_iBigButtonHeight, m_RBriefingButtonUp.W, m_RBriefingButtonUp.H, self));
    m_BriefingButton.UpTexture          =   m_TMainMenuTexture;
    m_BriefingButton.OverTexture        =   m_TMainMenuTexture;
    m_BriefingButton.DownTexture        =   m_TMainMenuTexture;
    m_BriefingButton.DisabledTexture    =   m_TMainMenuTexture;   
    m_BriefingButton.UpRegion           =   m_RBriefingButtonUp;
    m_BriefingButton.OverRegion         =   m_RBriefingButtonOver;    
    m_BriefingButton.DownRegion         =   m_RBriefingButtonDown;   
    m_BriefingButton.DisabledRegion     =   m_RBriefingButtonDisabled;    
    m_BriefingButton.bUseRegion         =   true;
    m_BriefingButton.ToolTipString      =   Localize("PlanningMenu","Breifing","R6Menu");
    m_BriefingButton.m_iDrawStyle       =   5; //Alpha

	m_GearButton       = R6WindowButton(CreateControl( class'R6WindowButton', m_iNavBarLocation[3], m_iBigButtonHeight, m_RGearButtonUp.W, m_RGearButtonUp.H, self));
    m_GearButton.UpTexture          =   m_TMainMenuTexture;
    m_GearButton.OverTexture        =   m_TMainMenuTexture;
    m_GearButton.DownTexture        =   m_TMainMenuTexture;
    m_GearButton.DisabledTexture    =   m_TMainMenuTexture;        
    m_GearButton.UpRegion           =   m_RGearButtonUp;
    m_GearButton.OverRegion         =   m_RGearButtonOver;    
    m_GearButton.DownRegion         =   m_RGearButtonDown;   
    m_GearButton.DisabledRegion     =   m_RGearButtonDisabled;    
    m_GearButton.bUseRegion         =   true;
    m_GearButton.ToolTipString      =   Localize("PlanningMenu","Gear","R6Menu");
    m_GearButton.m_iDrawStyle       =   5; //Alpha

    
    m_PlanningButton    = R6WindowButton(CreateControl( class'R6WindowButton', m_iNavBarLocation[4], m_iBigButtonHeight, m_RPlanningButtonUp.W, m_RPlanningButtonUp.H, self));
    m_PlanningButton.UpTexture          =   m_TMainMenuTexture;
    m_PlanningButton.OverTexture        =   m_TMainMenuTexture;
    m_PlanningButton.DownTexture        =   m_TMainMenuTexture;
    m_PlanningButton.DisabledTexture    =   m_TMainMenuTexture;      
    m_PlanningButton.UpRegion           =   m_RPlanningButtonUp;
    m_PlanningButton.OverRegion         =   m_RPlanningButtonOver;    
    m_PlanningButton.DownRegion         =   m_RPlanningButtonDown;   
    m_PlanningButton.DisabledRegion     =   m_RPlanningButtonDisabled;    
    m_PlanningButton.bUseRegion         =   true;
    m_PlanningButton.ToolTipString      =   Localize("PlanningMenu","Planning","R6Menu");
    m_PlanningButton.m_iDrawStyle       =   5; //Alpha   


    m_PlayButton        = R6WindowButton(CreateControl( class'R6WindowButton', m_iNavBarLocation[5], m_iBigButtonHeight, m_RPlayButtonUp.W, m_RPlayButtonUp.H, self));
    m_PlayButton.UpTexture          =   m_TMainMenuTexture;
    m_PlayButton.OverTexture        =   m_TMainMenuTexture;
    m_PlayButton.DownTexture        =   m_TMainMenuTexture;
    m_PlayButton.DisabledTexture    =   m_TMainMenuTexture;    
    m_PlayButton.UpRegion           =   m_RPlayButtonUp;
    m_PlayButton.OverRegion         =   m_RPlayButtonOver;    
    m_PlayButton.DownRegion         =   m_RPlayButtonDown;   
    m_PlayButton.DisabledRegion     =   m_RPlayButtonDisabled;    
    m_PlayButton.bUseRegion         =   true;
    m_PlayButton.ToolTipString      =   Localize("PlanningMenu","Play","R6Menu");
    m_PlayButton.m_iDrawStyle       =   5; //Alpha

    m_SaveButton    = R6WindowButton(CreateControl( class'R6WindowButton', m_iNavBarLocation[6], m_iBigButtonHeight, m_RSaveButtonUp.W, m_RSaveButtonUp.H, self));
    m_SaveButton.UpTexture          =   m_TMainMenuTexture;
    m_SaveButton.OverTexture        =   m_TMainMenuTexture;
    m_SaveButton.DownTexture        =   m_TMainMenuTexture;
    m_SaveButton.DisabledTexture    =   m_TMainMenuTexture;       
    m_SaveButton.UpRegion           =   m_RSaveButtonUp;
    m_SaveButton.OverRegion         =   m_RSaveButtonOver;    
    m_SaveButton.DownRegion         =   m_RSaveButtonDown;   
    m_SaveButton.DisabledRegion     =   m_RSaveButtonDisabled;    
    m_SaveButton.bUseRegion         =   true;
    m_SaveButton.ToolTipString      =   Localize("PlanningMenu","Save","R6Menu");
    m_SaveButton.m_iDrawStyle       =   5; //Alpha

	m_LoadButton    = R6WindowButton(CreateControl( class'R6WindowButton', m_iNavBarLocation[7], m_iBigButtonHeight, m_RSaveButtonUp.W, m_RSaveButtonUp.H, self));
    m_LoadButton.UpTexture          =   m_TMainMenuTexture;
    m_LoadButton.OverTexture        =   m_TMainMenuTexture;
    m_LoadButton.DownTexture        =   m_TMainMenuTexture;
    m_LoadButton.DisabledTexture    =   m_TMainMenuTexture;       
    m_LoadButton.UpRegion           =   m_RLoadButtonUp;
    m_LoadButton.OverRegion         =   m_RLoadButtonOver;    
    m_LoadButton.DownRegion         =   m_RLoadButtonDown;   
    m_LoadButton.DisabledRegion     =   m_RLoadButtonDisabled;    
    m_LoadButton.bUseRegion         =   true;
    m_LoadButton.ToolTipString      =   Localize("PlanningMenu","Load","R6Menu");
    m_LoadButton.m_iDrawStyle       =   5; //Alpha
    
	m_QuickPlayButton    = R6WindowButton(CreateControl( class'R6WindowButton', m_iNavBarLocation[8], m_iBigButtonHeight, m_RQuickPlayButtonUp.W, m_RQuickPlayButtonUp.H, self));
    m_QuickPlayButton.UpTexture          =   m_TMainMenuTexture;
    m_QuickPlayButton.OverTexture        =   m_TMainMenuTexture;
    m_QuickPlayButton.DownTexture        =   m_TMainMenuTexture;
    m_QuickPlayButton.DisabledTexture    =   m_TMainMenuTexture;       
    m_QuickPlayButton.UpRegion           =   m_RQuickPlayButtonUp;
    m_QuickPlayButton.OverRegion         =   m_RQuickPlayButtonOver;    
    m_QuickPlayButton.DownRegion         =   m_RQuickPlayButtonDown;   
    m_QuickPlayButton.DisabledRegion     =   m_RQuickPlayButtonDisabled;    
    m_QuickPlayButton.bUseRegion         =   true;
    m_QuickPlayButton.ToolTipString      =   Localize("PlanningMenu","QuickPlay","R6Menu");
    m_QuickPlayButton.m_iDrawStyle       =   5; //Alpha

    m_BorderColor = Root.Colors.BlueLight;
}

function Notify(UWindowDialogControl C, byte E)
{        
	local R6MenuRootWindow R6Root;	
    local R6GameOptions pGameOptions;

    if( E == DE_Click )
    {
		R6Root = R6MenuRootWindow(Root);

        switch(C)
        {
        case m_MainMenuButton:
            R6Root.StopPlayMode();
            R6Root.ClosePopups();
            R6Root.SimplePopUp(Localize("POPUP","PopUpTitle_QuitToMain","R6Menu"),Localize("ESCMENUS","MAINCONFIRM","R6Menu"),EPopUpID_LeavePlanningToMain);
            break;
        case m_OptionsButton:
			R6Root.ChangeCurrentWidget(OptionsWidgetID);            
            break;
        case m_BriefingButton:    
			R6Root.ChangeCurrentWidget(IntelWidgetID);
            break;
		case m_GearButton:
			R6Root.ChangeCurrentWidget(GearRoomWidgetID);            
            break;  
        case m_PlanningButton:
			R6Root.ChangeCurrentWidget(PlanningWidgetID); 
            break;
		case m_PlayButton:            
			//Bring up the execute screen if we have at least 1 operative assigned
#ifndefMPDEMO        
			if(R6Root.m_GearRoomWidget.IsTeamConfigValid())
			{                 
                R6Root.m_PlanningWidget.m_PlanningBar.m_TimeLine.Reset();
				Root.ChangeCurrentWidget(ExecuteWidgetID);      
			}    
            else
            {
                R6Root.StopPlayMode();
                R6Root.ClosePopups();
                R6Root.SimplePopUp(Localize("POPUP","INCOMPLETEPLANNING","R6Menu"),Localize("POPUP","INCOMPLETEPLANNINGPROBLEM","R6Menu"),EPopUpID_PlanningIncomplete, MessageBoxButtons.MB_OK);
            }
#endif
            break;         
        case m_SaveButton:			
            R6Root.StopPlayMode();
            R6Root.ClosePopups();
            R6Root.m_ePopUpID = EPopUpID_SavePlanning;
			R6Root.PopUpMenu(); 
            break;                      
		case m_LoadButton:      			
            R6Root.StopPlayMode();
            R6Root.ClosePopups();
			R6Root.m_ePopUpID = EPopUpID_LoadPlanning;
			R6Root.PopUpMenu();      
            break;                   
        case m_QuickPlayButton:	

            R6Root.ClosePopups();
            pGameOptions = class'Actor'.static.GetGameOptions();
            
            if( (pGameOptions.PopUpQuickPlay == true) && 
                ( R6Root.m_GearRoomWidget.IsTeamConfigValid() || (R6Root.IsPlanningEmpty() == false) ) 
              )
                R6Root.SimplePopUp(Localize("POPUP","PopUpTitle_QuiPlay","R6Menu"),Localize("POPUP","PopUpMsg_QuiPlay","R6Menu"),EPopUpID_QuickPlay, MessageBoxButtons.MB_YesNo, true);
            else
                R6Root.LaunchQuickPlay();
            
			break;
        }
    }

}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    R6MenuRSLookAndFeel(LookAndFeel).DrawNavigationBar(self,C);
}

defaultproperties
{
     m_iNavBarLocation(0)=22
     m_iNavBarLocation(1)=74
     m_iNavBarLocation(2)=170
     m_iNavBarLocation(3)=252
     m_iNavBarLocation(4)=338
     m_iNavBarLocation(5)=420
     m_iNavBarLocation(6)=466
     m_iNavBarLocation(7)=510
     m_iNavBarLocation(8)=559
     m_iBigButtonHeight=1
     m_TMainMenuTexture=Texture'R6MenuTextures.Gui_01'
     m_RMainMenuButtonUp=(X=113,Y=120,W=29,H=30)
     m_RMainMenuButtonDown=(X=113,Y=180,W=29,H=30)
     m_RMainMenuButtonDisabled=(X=113,Y=210,W=29,H=30)
     m_RMainMenuButtonOver=(X=113,Y=150,W=29,H=30)
     m_ROptionsButtonUp=(X=87,Y=120,W=25,H=30)
     m_ROptionsButtonDown=(X=87,Y=180,W=25,H=30)
     m_ROptionsButtonDisabled=(X=87,Y=210,W=25,H=30)
     m_ROptionsButtonOver=(X=87,Y=150,W=25,H=30)
     m_RBriefingButtonUp=(W=30,H=30)
     m_RBriefingButtonDown=(Y=60,W=30,H=30)
     m_RBriefingButtonDisabled=(Y=90,W=30,H=30)
     m_RBriefingButtonOver=(Y=30,W=30,H=30)
     m_RGearButtonUp=(X=30,W=34,H=30)
     m_RGearButtonDown=(X=30,Y=60,W=34,H=30)
     m_RGearButtonDisabled=(X=30,Y=90,W=34,H=30)
     m_RGearButtonOver=(X=30,Y=30,W=34,H=30)
     m_RPlanningButtonUp=(X=64,W=29,H=30)
     m_RPlanningButtonDown=(X=64,Y=60,W=29,H=30)
     m_RPlanningButtonDisabled=(X=64,Y=90,W=29,H=30)
     m_RPlanningButtonOver=(X=64,Y=30,W=29,H=2830)
     m_RPlayButtonUp=(Y=120,W=25,H=30)
     m_RPlayButtonDown=(Y=180,W=25,H=30)
     m_RPlayButtonDisabled=(Y=210,W=25,H=30)
     m_RPlayButtonOver=(Y=150,W=25,H=30)
     m_RSaveButtonUp=(X=173,Y=120,W=29,H=30)
     m_RSaveButtonDown=(X=173,Y=180,W=29,H=30)
     m_RSaveButtonDisabled=(X=173,Y=210,W=29,H=30)
     m_RSaveButtonOver=(X=173,Y=150,W=29,H=30)
     m_RLoadButtonUp=(X=143,Y=120,W=29,H=30)
     m_RLoadButtonDown=(X=143,Y=180,W=29,H=30)
     m_RLoadButtonDisabled=(X=143,Y=210,W=30,H=30)
     m_RLoadButtonOver=(X=143,Y=150,W=29,H=30)
     m_RQuickPlayButtonUp=(X=52,Y=120,W=34,H=30)
     m_RQuickPlayButtonDown=(X=52,Y=180,W=34,H=30)
     m_RQuickPlayButtonDisabled=(X=52,Y=210,W=34,H=30)
     m_RQuickPlayButtonOver=(X=52,Y=150,W=34,H=30)
}
