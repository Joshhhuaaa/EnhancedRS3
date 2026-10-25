//=============================================================================
//  R6MenuDebriefNavBar.uc : Bottom nav bar in debreifing room
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/17 * Created by Alexandre Dionne
//=============================================================================


class R6MenuDebriefNavBar extends UWindowDialogClientWindow;

var R6WindowButton             m_MainMenuButton, m_OptionsButton, m_ActionButton, m_PlanningButton;
var R6WindowButton             m_ContinueButton;

var Texture                    m_TMainMenuButton, m_TOptionsButton, m_TActionButton, m_TPlanningButton, m_TContinueButton;


var Region                     m_RMainMenuButtonUp, m_RMainMenuButtonDown, m_RMainMenuButtonDisabled, m_RMainMenuButtonOver;
var Region                     m_ROptionsButtonUp,  m_ROptionsButtonDown,  m_ROptionsButtonDisabled,  m_ROptionsButtonOver;
var Region                     m_RActionButtonUp,     m_RActionButtonDown,     m_RActionButtonDisabled,     m_RActionButtonOver;
var Region                     m_RPlanningButtonUp, m_RPlanningButtonDown, m_RPlanningButtonDisabled, m_RPlanningButtonOver;
var Region                     m_RContinueButtonUp, m_RContinueButtonDown, m_RContinueButtonDisabled, m_RContinueButtonOver;

var FLOAT                      m_fButtonsYPos;
var FLOAT                      m_fMainMenuXPos, m_fOptionsXPos, m_fActionXPos, m_fPlanningXPos, m_fContinueXPos;

function Created()
{

    m_MainMenuButton    = R6WindowButton(CreateControl( class'R6WindowButton', m_fMainMenuXPos, m_fButtonsYPos, m_RMainMenuButtonUp.W, m_RMainMenuButtonUp.H, self));
    
    m_MainMenuButton.UpTexture          =   m_TMainMenuButton;
    m_MainMenuButton.OverTexture        =   m_TMainMenuButton;
    m_MainMenuButton.DownTexture        =   m_TMainMenuButton;
    m_MainMenuButton.DisabledTexture    =   m_TMainMenuButton;
    m_MainMenuButton.UpRegion           =   m_RMainMenuButtonUp;
    m_MainMenuButton.OverRegion         =   m_RMainMenuButtonOver;    
    m_MainMenuButton.DownRegion         =   m_RMainMenuButtonDown;   
    m_MainMenuButton.DisabledRegion     =   m_RMainMenuButtonDisabled;    
    m_MainMenuButton.bUseRegion         =   true;
    m_MainMenuButton.ToolTipString      =   Localize("ESCMENUS","MAIN","R6Menu");
    m_MainMenuButton.m_iDrawStyle       =   5; //Alpha
    m_MainMenuButton.m_bWaitSoundFinish =   true;
    m_OptionsButton     = R6WindowButton(CreateControl( class'R6WindowButton', m_fOptionsXPos, m_fButtonsYPos, m_ROptionsButtonUp.W, m_ROptionsButtonUp.H, self));   
    m_OptionsButton.UpTexture          =   m_TOptionsButton;
    m_OptionsButton.OverTexture        =   m_TOptionsButton;
    m_OptionsButton.DownTexture        =   m_TOptionsButton;
    m_OptionsButton.DisabledTexture    =   m_TOptionsButton;
    m_OptionsButton.UpRegion           =   m_ROptionsButtonUp;
    m_OptionsButton.DownRegion         =   m_ROptionsButtonDown;   
    m_OptionsButton.DisabledRegion     =   m_ROptionsButtonDisabled;
    m_OptionsButton.OverRegion         =   m_ROptionsButtonOver;    
    m_OptionsButton.bUseRegion         =   true;
    m_OptionsButton.ToolTipString      =   Localize("ESCMENUS","ESCOPTIONS","R6Menu");
    m_OptionsButton.m_iDrawStyle       =   5; //Alpha    
    m_OptionsButton.m_bWaitSoundFinish =   true;

    m_ActionButton        = R6WindowButton(CreateControl( class'R6WindowButton', m_fActionXPos, m_fButtonsYPos, m_RActionButtonUp.W, m_RActionButtonUp.H, self));
    m_ActionButton.UpTexture          =   m_TActionButton;
    m_ActionButton.OverTexture        =   m_TActionButton;
    m_ActionButton.DownTexture        =   m_TActionButton;
    m_ActionButton.DisabledTexture    =   m_TActionButton;   
    m_ActionButton.UpRegion           =   m_RActionButtonUp;
    m_ActionButton.OverRegion         =   m_RActionButtonOver;    
    m_ActionButton.DownRegion         =   m_RActionButtonDown;   
    m_ActionButton.DisabledRegion     =   m_RActionButtonDisabled;    
    m_ActionButton.bUseRegion         =   true;
    m_ActionButton.ToolTipString      =   Localize("DebriefingMenu","ACTION","R6Menu");
    m_ActionButton.m_iDrawStyle       =   5; //Alpha
    m_ActionButton.m_bWaitSoundFinish =   true;
    
    m_PlanningButton    = R6WindowButton(CreateControl( class'R6WindowButton', m_fPlanningXPos, m_fButtonsYPos, m_RPlanningButtonUp.W, m_RPlanningButtonUp.H, self));
    m_PlanningButton.UpTexture          =   m_TPlanningButton;
    m_PlanningButton.OverTexture        =   m_TPlanningButton;
    m_PlanningButton.DownTexture        =   m_TPlanningButton;
    m_PlanningButton.DisabledTexture    =   m_TPlanningButton;      
    m_PlanningButton.UpRegion           =   m_RPlanningButtonUp;
    m_PlanningButton.OverRegion         =   m_RPlanningButtonOver;    
    m_PlanningButton.DownRegion         =   m_RPlanningButtonDown;   
    m_PlanningButton.DisabledRegion     =   m_RPlanningButtonDisabled;    
    m_PlanningButton.bUseRegion         =   true;
    m_PlanningButton.ToolTipString      =   Localize("DebriefingMenu","PLAN","R6Menu");
    m_PlanningButton.m_iDrawStyle       =   5; //Alpha        
    m_PlanningButton.m_bWaitSoundFinish =   true;

    m_ContinueButton    = R6WindowButton(CreateControl( class'R6WindowButton', m_fContinueXPos, m_fButtonsYPos, m_RContinueButtonUp.W, m_RContinueButtonUp.H, self));
    m_ContinueButton.UpTexture          =   m_TContinueButton;
    m_ContinueButton.OverTexture        =   m_TContinueButton;
    m_ContinueButton.DownTexture        =   m_TContinueButton;
    m_ContinueButton.DisabledTexture    =   m_TContinueButton;       
    m_ContinueButton.UpRegion           =   m_RContinueButtonUp;
    m_ContinueButton.OverRegion         =   m_RContinueButtonOver;    
    m_ContinueButton.DownRegion         =   m_RContinueButtonDown;   
    m_ContinueButton.DisabledRegion     =   m_RContinueButtonDisabled;    
    m_ContinueButton.bUseRegion         =   true;
    m_ContinueButton.ToolTipString      =   Localize("DebriefingMenu","CONTINUE","R6Menu");
    m_ContinueButton.m_iDrawStyle       =   5; //Alpha    
    m_ContinueButton.m_bWaitSoundFinish =   true;

    m_BorderColor = Root.Colors.BlueLight;
}


function Notify(UWindowDialogControl C, byte E)
{
    local R6GameInfo    GameInfo;
    local R6PlayerCampaign          MyCampaign;    
    local R6FileManagerCampaign     pFileManager;	

    GameInfo = R6GameInfo(Root.Console.ViewportOwner.Actor.Level.Game);    
        
    if( E == DE_Click )
    {
        switch(C)
        {
        case m_MainMenuButton:
            R6MenuInGameRootWindow(Root).SimplePopUp(Localize("POPUP","PopUpTitle_QuitToMain","R6Menu"),Localize("ESCMENUS","MAINCONFIRM","R6Menu"),EPopUpID_LeaveInGameToMain);            
            break;
        case m_OptionsButton:
            Root.ChangeCurrentWidget(OptionsWidgetID);            
            break;
        case m_ActionButton:    //Restart Action
            if(GameInfo.m_bUsingPlayerCampaign)
            {                
                DenyMissionOutcome();            
            }
            Root.Console.Master.m_StartGameInfo.m_SkipPlanningPhase = true;
            Root.Console.Master.m_StartGameInfo.m_ReloadPlanning = true;
            Root.Console.Master.m_StartGameInfo.m_ReloadActionPointOnly = true;
            
            R6Console(Root.Console).ResetR6Game();
            break;
        case m_PlanningButton: //Restart Planning         
            Root.Console.Master.m_StartGameInfo.m_SkipPlanningPhase = false;
            Root.Console.Master.m_StartGameInfo.m_ReloadPlanning = true;
            Root.Console.Master.m_StartGameInfo.m_ReloadActionPointOnly = false;
            if(GameInfo.m_bUsingPlayerCampaign)
            {                
                DenyMissionOutcome();
                R6Console(Root.console).LeaveR6Game(R6Console(Root.console).eLeaveGame.LG_RetryPlanningCampaign);    
            }
            else
                R6Console(Root.console).LeaveR6Game(R6Console(Root.console).eLeaveGame.LG_RetryPlanningCustomMission);
            break;
        case m_ContinueButton:
            
            //Accept mission outcome and continue 
            Root.Console.master.m_StartGameInfo.m_SkipPlanningPhase = false;
            Root.Console.Master.m_StartGameInfo.m_ReloadPlanning = false;
            Root.Console.Master.m_StartGameInfo.m_ReloadActionPointOnly = false;
            
            if(GameInfo.m_bUsingPlayerCampaign)
            {
                if(AcceptMissionOutcome() == true)
                {
                    R6Console(Root.console).LeaveR6Game(R6Console(Root.console).eLeaveGame.LG_NextLevel);    
                }                    
            }
            else
            {
                R6Console(Root.console).LeaveR6Game(R6Console(Root.console).eLeaveGame.LG_CustomMissionMenu); //Leave for custom mission Menu                
            }            
            break;                       
        }
    }

}

function DenyMissionOutcome()
{
    local R6FileManagerCampaign     FileManager;	
    local R6PlayerCampaign          MyCampaign;    

     FileManager = new(none) class'R6FileManagerCampaign';
     MyCampaign   = R6Console(Root.Console).m_PlayerCampaign;     
     MyCampaign.m_OperativesMissionDetails = None;
     MyCampaign.m_OperativesMissionDetails = new(none) class'R6MissionRoster';
        
	 FileManager.LoadCampaign(MyCampaign);  
}
function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    DrawSimpleBorder(C);

    C.Style = ERenderStyle.STY_Alpha;

    // draw a line between option and briefing
    C.SetDrawColor( m_BorderColor.R, m_BorderColor.G, m_BorderColor.B);
    DrawStretchedTextureSegment(C, 120, 0, 1, 33, 
                                     m_BorderTextureRegion.X, m_BorderTextureRegion.Y, m_BorderTextureRegion.W, m_BorderTextureRegion.H, m_BorderTexture);
}

function bool AcceptMissionOutcome()
{
    local R6PlayerCampaign MyCampaign;
    local R6FileManagerCampaign pFileManager;
    local R6Console R6Console;

    R6Console = R6Console(Root.Console);
    MyCampaign = R6Console.m_PlayerCampaign;
    pFileManager = new Class'R6Game.R6FileManagerCampaign';
    if(pFileManager.SaveCampaign(MyCampaign) == false)
    {
        R6MenuInGameRootWindow(Root).SimplePopUp(Localize("POPUP", "FILEERROR", "R6Menu"), (MyCampaign.m_FileName @ ":") @ (Localize("POPUP", "FILEERRORPROBLEM", "R6Menu")), EPopUpID_FileWriteError, MessageBoxButtons.MB_OK);
        return false;
    }
    return true;
}

defaultproperties
{
     m_fButtonsYPos=1.000000
     m_fMainMenuXPos=22.000000
     m_fOptionsXPos=74.000000
     m_fActionXPos=217.000000
     m_fPlanningXPos=344.000000
     m_fContinueXPos=467.000000
     m_TMainMenuButton=Texture'R6MenuTextures.Gui_01'
     m_TOptionsButton=Texture'R6MenuTextures.Gui_01'
     m_TActionButton=Texture'R6MenuTextures.Gui_01'
     m_TPlanningButton=Texture'R6MenuTextures.Gui_01'
     m_TContinueButton=Texture'R6MenuTextures.Gui_01'
     m_RMainMenuButtonUp=(X=113,Y=120,W=29,H=30)
     m_RMainMenuButtonDown=(X=113,Y=180,W=29,H=30)
     m_RMainMenuButtonDisabled=(X=113,Y=210,W=29,H=30)
     m_RMainMenuButtonOver=(X=113,Y=150,W=29,H=30)
     m_ROptionsButtonUp=(X=87,Y=120,W=25,H=30)
     m_ROptionsButtonDown=(X=87,Y=180,W=25,H=30)
     m_ROptionsButtonDisabled=(X=87,Y=210,W=25,H=30)
     m_ROptionsButtonOver=(X=87,Y=150,W=25,H=30)
     m_RActionButtonUp=(X=93,W=32,H=30)
     m_RActionButtonDown=(X=93,Y=60,W=32,H=30)
     m_RActionButtonDisabled=(X=93,Y=90,W=32,H=30)
     m_RActionButtonOver=(X=93,Y=30,W=32,H=30)
     m_RPlanningButtonUp=(X=125,W=30,H=30)
     m_RPlanningButtonDown=(X=125,Y=60,W=30,H=30)
     m_RPlanningButtonDisabled=(X=125,Y=90,W=30,H=30)
     m_RPlanningButtonOver=(X=125,Y=30,W=30,H=30)
     m_RContinueButtonUp=(Y=120,W=25,H=30)
     m_RContinueButtonDown=(Y=180,W=25,H=30)
     m_RContinueButtonDisabled=(Y=210,W=25,H=30)
     m_RContinueButtonOver=(Y=150,W=25,H=30)
}
