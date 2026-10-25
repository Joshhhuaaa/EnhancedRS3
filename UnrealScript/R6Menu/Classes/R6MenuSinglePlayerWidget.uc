//=============================================================================
//  R6MenuSinglePlayerWidget.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/22 * Created by Alexandre Dionne
//=============================================================================
class R6MenuSinglePlayerWidget extends R6MenuWidget;

var color  m_HelpTextColor;
var int    m_iFont;
var int    m_iSelectedButtonID;
var bool   bShowlog;


var R6WindowButton	m_ButtonMainMenu, m_ButtonOptions, m_ButtonStart;
var R6WindowSimpleFramedWindow  m_Map;
var R6WindowTextLabel			m_LMenuTitle; 

var String	m_ButtonStartText[2];
var String	m_ButtonStartHelpText[2];

var  R6MenuSinglePlayerCampaignSelect   m_CampaignSelect;
var  R6WindowSimpleCurvedFramedWindow   m_CampaignCreate;
var  R6MenuHelpWindow                   m_pHelpWindow;            // the help window (tooltip)
var  R6FileManagerCampaign              m_pFileManager;
var  R6WindowSimpleFramedWindow         m_CampaignDescription;

var R6WindowButton						m_pButResumeCampaign;
var R6WindowButton						m_pButNewCampaign;
var R6WindowButton						m_pButDelCampaign;
var R6WindowButton						m_pButCurrent;

var   Font    m_LeftButtonFont;
var   Font    m_LeftDownSizeFont;

enum eWidgetID
{
    CampaignSelect,
	CampaignCreate
};

enum ECampaignButID
{
    ButtonResumeID,
    ButtonNewID,
    ButtonDeleteID,
	ButtonAccept
};

function Created()
{
	
	local Font buttonFont;	
	local UWindowWrappedTextArea localHelpZone;    
    local INT   XPos;


	
    m_pFileManager = new class'R6FileManagerCampaign'; // New(None) class<R6FileManagerCampaign>(DynamicLoadObject("R6Game.R6FileManagerCampaign", class'Class'));
    
	buttonFont		= Root.Fonts[F_MainButton];

	m_ButtonStartText[0]            = Localize("CustomMission","ButtonStart1","R6Menu");
	m_ButtonStartText[1]            = Localize("CustomMission","ButtonStart2","R6Menu");	
	m_ButtonStartHelpText[0]        = Localize("Tip","ButtonStart","R6Menu");
	m_ButtonStartHelpText[1]        = Localize("Tip","ButtonDelete","R6Menu");	

    m_HelpTextColor                 = Root.Colors.GrayLight;
	
//=================================================================================
// Help Zone
//=================================================================================
    // create the help window
    m_pHelpWindow = R6MenuHelpWindow(CreateWindow(class'R6MenuHelpWindow', 150, 429, 340, 42, self)); //std param is set in help window    
    

//=================================================================================
// Default Buttons
//=================================================================================
	
	m_ButtonMainMenu = R6WindowButton(CreateControl( class'R6WindowButton', 10, 421, 250, 25, self));
    m_ButtonMainMenu.ToolTipString      = Localize("Tip","ButtonMainMenu","R6Menu");
	m_ButtonMainMenu.Text               = Localize("SinglePlayer","ButtonMainMenu","R6Menu");	
	m_ButtonMainMenu.Align              = TA_LEFT;
	m_ButtonMainMenu.m_buttonFont       = buttonFont;
	m_ButtonMainMenu.ResizeToText();
    

	m_ButtonOptions = R6WindowButton(CreateControl( class'R6WindowButton', 10, 452, 250, 25, self));
    m_ButtonOptions.ToolTipString       = Localize("Tip","ButtonOptions","R6Menu");
	m_ButtonOptions.Text                = Localize("SinglePlayer","ButtonOptions","R6Menu");	
	m_ButtonOptions.Align               = TA_LEFT;		
	m_ButtonOptions.m_buttonFont        = buttonFont;
	m_ButtonOptions.ResizeToText();	
        

    XPos = m_pHelpWindow.WinLeft + m_pHelpWindow.WinWidth;

	m_ButtonStart = R6WindowButton(CreateControl( class'R6WindowButton', XPos, 452, WinWidth - XPos - 20, 25, self));
    m_ButtonStart.ToolTipString         = m_ButtonStartHelpText[0];
	m_ButtonStart.Text                  = m_ButtonStartText[0];
	m_ButtonStart.Align                 = TA_RIGHT;		
	m_ButtonStart.m_buttonFont          = buttonFont;
	m_ButtonStart.ResizeToText();		
    m_ButtonStart.m_iButtonID           = ECampaignButID.ButtonAccept;
    m_ButtonStart.m_bWaitSoundFinish    = true;

    m_Map = R6WindowSimpleFramedWindow(CreateWindow(class'R6WindowSimpleFramedWindow', 390, 268, 230, 130, self));
    m_Map.CreateClientWindow(class'R6WindowBitMap');
    m_Map.m_eCornerType                 = All_Corners;
    m_Map.HideWindow();

	
	m_LMenuTitle            = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 0, 18, WinWidth - 8, 25, self));
	m_LMenuTitle.Text                   = Localize("SinglePlayer","Title","R6Menu");
	m_LMenuTitle.Align                  = TA_Right;
	m_LMenuTitle.m_Font                 = Root.Fonts[F_MenuMainTitle];
	m_LMenuTitle.TextColor              = Root.Colors.White;
    m_LMenuTitle.m_BGTexture            = None;
    m_LMenuTitle.m_bDrawBorders         = False;




//=================================================================================
// The two poping windows
//=================================================================================


	m_CampaignSelect = R6MenuSinglePlayerCampaignSelect(CreateWindow(class'R6MenuSinglePlayerCampaignSelect', 198, 72, 156, 327, self));	
	m_CampaignSelect.HideWindow();
	

	m_CampaignCreate = R6WindowSimpleCurvedFramedWindow(CreateWindow(class'R6WindowSimpleCurvedFramedWindow', m_CampaignSelect.WinLeft, m_CampaignSelect.WinTop, m_CampaignSelect.WinWidth, 326, self));
	m_CampaignCreate.CreateClientWindow(class'R6MenuSinglePlayerCampaignCreate');
	m_CampaignCreate.m_title            = Localize("SinglePlayer","TitleCampaign","R6Menu"); 
	m_CampaignCreate.m_TitleAlign       = TA_Center;
	m_CampaignCreate.m_Font             = Root.Fonts[F_PopUpTitle];//buttonFont;
	m_CampaignCreate.m_TextColor        = Root.Colors.White;	
    m_CampaignCreate.SetCornerType(All_Corners);


    m_CampaignDescription = R6WindowSimpleFramedWindow(CreateWindow(class'R6WindowSimpleFramedWindow', m_Map.WinLeft, m_CampaignSelect.WinTop, m_Map.WinWidth, 122, self));
    m_CampaignDescription.CreateClientWindow(class'R6MenuCampaignDescription');        
    m_CampaignDescription.SetCornerType(All_Corners);   
		
}

function ShowWindow()
{
    Super.ShowWindow();
	m_CampaignSelect.RefreshListBox();

	if(m_CampaignSelect.m_CampaignListBox.Items.Count() ==0 )
	{	
		switchWidget(CampaignCreate);
		SetCurrentBut( ECampaignButID.ButtonNewID);
	}
	else
	{
		m_iSelectedButtonID = ECampaignButID.ButtonNewID;
		ButtonClicked(ECampaignButID.ButtonResumeID);
	}

}

function HideWindow()
{
    Super.HideWindow();
    m_CampaignSelect.m_CampaignListBox.Clear();
}

//=================================================================================
// Changing the poping window
//=================================================================================
function switchWidget(eWidgetID newWidget)
{
	switch(newWidget)
	{
		case CampaignSelect:
			m_CampaignCreate.HideWindow();
			m_CampaignSelect.ShowWindow();
            m_CampaignDescription.ShowWindow();
            m_Map.ShowWindow();
			break;
		case CampaignCreate:
			m_CampaignSelect.HideWindow();
			m_CampaignCreate.ShowWindow();
            R6MenuSinglePlayerCampaignCreate(m_CampaignCreate.m_ClientArea).Reset();
            m_ButtonStart.ToolTipString = m_ButtonStartHelpText[0];
			m_ButtonStart.Text = m_ButtonStartText[0];
            m_ButtonStart.ResizeToText();
            m_iSelectedButtonID = ECampaignButID.ButtonNewID;
            m_CampaignDescription.HideWindow();
            m_Map.HideWindow();
			break;
	}
	
}

//=================================================================================
// Button clicked
//=================================================================================
function ButtonClicked(int ButtonID)
{
	if(ButtonID != m_iSelectedButtonID)
	{
		switch(ButtonID)
		{
		case ECampaignButID.ButtonResumeID:		//ButtonResumeID
            if(m_CampaignSelect.m_CampaignListBox.Items.Count() ==0)
                break;
			if(m_iSelectedButtonID == ECampaignButID.ButtonNewID)
				switchWidget(CampaignSelect);						
			m_ButtonStart.ToolTipString = m_ButtonStartHelpText[0];
			m_ButtonStart.Text = m_ButtonStartText[0];
            m_ButtonStart.ResizeToText();
            m_iSelectedButtonID = ButtonID ; 
			break;
		case ECampaignButID.ButtonNewID:		//ButtonNewID
			switchWidget(CampaignCreate);						
			break;		
		case ECampaignButID.ButtonDeleteID:		//ButtonDeleteID
            if(m_CampaignSelect.m_CampaignListBox.Items.Count() ==0)
                break;
			if(m_iSelectedButtonID == ECampaignButID.ButtonNewID)
				switchWidget(CampaignSelect);						
			m_ButtonStart.ToolTipString = m_ButtonStartHelpText[1];
			m_ButtonStart.Text = m_ButtonStartText[1];
            m_ButtonStart.ResizeToText();
            m_iSelectedButtonID = ButtonID ; 
			break;	
		case ECampaignButID.ButtonAccept :		
            //Accept button
            switch(m_iSelectedButtonID)
            {
                case ECampaignButID.ButtonResumeID: //ButtonResumeID
                    if(m_CampaignSelect.SetupCampaign())
                    {
                        Root.ResetMenus();
                        Root.ChangeCurrentWidget(CampaignPlanningID);                        
                    }
                    break;
                case ECampaignButID.ButtonNewID: //ButtonNewID                    
                    if(CampaignExists())
                    {
                        R6MenuRootWindow(Root).SimplePopUp(Localize("POPUP","CAMPAIGNEXISTTITLE","R6Menu"),Localize("POPUP","CAMPAIGNEXISTMSG","R6Menu"),EPopUpID_OverWriteCampaign);
                    }
                    else
                        TryCreatingCampaign();
                    break;
                case ECampaignButID.ButtonDeleteID: //ButtonDeleteID                    
                    if(m_CampaignSelect.m_CampaignListBox.m_SelectedItem != None)      
                        R6MenuRootWindow(Root).SimplePopUp(Localize("SinglePlayer","ButtonDelete","R6Menu"),Localize("POPUP","DELETECAMPAIGN","R6Menu"),EPopUpID_DeleteCampaign);
                    break;
            }			
				
			break;		
		}
		
		SetCurrentBut( m_iSelectedButtonID);
	}

}

function BOOL CampaignExists()
{    

    local string temp, szDir;
    local R6MenuSinglePlayerCampaignCreate R6PCC;

    R6PCC = R6MenuSinglePlayerCampaignCreate(m_CampaignCreate.m_ClientArea);

    szDir = class'Actor'.static.GetModMgr().GetCampaignDir();
    temp = szDir $R6PCC.m_CampaignNameEdit.GetValue()$".cmp";
        
    return m_pFileManager.FindFile(temp);            
    
}


function TryCreatingCampaign()
{
    if(R6MenuSinglePlayerCampaignCreate(m_CampaignCreate.m_ClientArea).CreateCampaign())
    {
        Root.ResetMenus();
        Root.ChangeCurrentWidget(CampaignPlanningID);                                             
    }       
}

function DeleteCurrentSelectedCampaign()
{    
    m_CampaignSelect.DeleteCampaign();                    
    //If no more campaign available we switch to create
    if(m_CampaignSelect.m_CampaignListBox.Items.Count() ==0 )
	{               	
		switchWidget(CampaignCreate);
		SetCurrentBut(ECampaignButID.ButtonNewID); //ButtonNewID		                
	}
}


//Updates text for the current selected Campaign
function UpdateSelectedCampaign( R6PlayerCampaign _PlayerCampaign)
{    
    local R6MenuCampaignDescription     tempVar;
    local R6Campaign                    CampaignType;
    local R6MissionDescription          CurrentMission;
    local R6WindowBitMap                mapBitmap;

    tempVar = R6MenuCampaignDescription(m_CampaignDescription.m_ClientArea);
    mapBitmap = R6WindowBitMap(m_Map.m_ClientArea);
    
 
    if(_PlayerCampaign == None)
    {
        tempVar.m_MissionValue.Text     =   "";
        tempVar.m_NameValue.Text        =   "";    
        tempVar.m_DifficultyValue.Text  =   "";
        mapBitmap.T                     = None;  
        return;
    }
    CampaignType = new(none) class'R6Campaign'; 
    CampaignType.InitCampaign( GetLevel(), _PlayerCampaign.m_CampaignFileName, R6Console(Root.Console) );
    CurrentMission = CampaignType.m_missions[_PlayerCampaign.m_iNoMission];
    
    tempVar.m_MissionValue.SetNewText( string(_PlayerCampaign.m_iNoMission +1), true);
    tempVar.m_NameValue.SetNewText( Localize(CurrentMission.m_MapName,"ID_CODENAME", CurrentMission.LocalizationFile), true);    
    tempVar.m_DifficultyValue.SetNewText( Localize("SinglePlayer","Difficulty"$_PlayerCampaign.m_iDifficultyLevel,"R6Menu"), true);

    //This is for the current mission overview texture
    //Bottom right og the page
    mapBitmap.R       = CurrentMission.m_RMissionOverview;
    mapBitmap.T       = CurrentMission.m_TMissionOverview;
    
}


function KeyDown(int Key, float X, float Y)
{    
    Super.KeyDown(Key, X, Y);

    if(Key == Root.Console.EInputKey.IK_Enter)
        ButtonClicked(ECampaignButID.ButtonAccept);
}


function Notify(UWindowDialogControl C, byte E)
{ 
    if( E == DE_Click )
    {
		switch(C)
		{
		case m_ButtonMainMenu:
			Root.ChangeCurrentWidget(MainMenuWidgetID);
			break;
		case m_ButtonOptions:
			Root.ChangeCurrentWidget(OptionsWidgetID);
			break;		
		default:
            if( R6WindowButton(C) != None)
			    ButtonClicked(R6WindowButton(C).m_iButtonID);
			break;
		}
    }    
}


//=================================================================================
// Setup Help Text
//=================================================================================
function ToolTip(string strTip) 
{
    m_pHelpWindow.ToolTip(strTip);
} 

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
	//DrawBackGround
	Root.PaintBackground( C, self);	
}

function CreateButtons()
{
	local FLOAT fXOffset, fYOffset, fWidth, fHeight, fYPos;	    

	fXOffset = 10;
    fYPos    = 64;
	//fYOffset = 36;
    fYOffset = 26;
	fWidth   = 200;
	fHeight  = 25; 

	// define Resume campaign button
	m_pButResumeCampaign = R6WindowButton(CreateControl( class'R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
	m_pButResumeCampaign.ToolTipString		= Localize("Tip","ButtonResumeCampaign","R6Menu");
	m_pButResumeCampaign.Text				= Localize("SinglePlayer","ButtonResume","R6Menu");
	m_pButResumeCampaign.m_iButtonID		= ECampaignButID.ButtonResumeID;
	m_pButResumeCampaign.Align				= TA_Left;	
	m_pButResumeCampaign.m_buttonFont		= m_LeftButtonFont;
    m_pButResumeCampaign.CheckToDownSizeFont(m_LeftDownSizeFont,0);
	m_pButResumeCampaign.ResizeToText();
	m_pButResumeCampaign.m_bSelected = true;

	fYPos += fYOffset;

	// define New campaign button
	m_pButNewCampaign = R6WindowButton(CreateControl( class'R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
	m_pButNewCampaign.ToolTipString		= Localize("Tip","ButtonNewCampaign","R6Menu");
	m_pButNewCampaign.Text				= Localize("SinglePlayer","ButtonNew","R6Menu");
	m_pButNewCampaign.m_iButtonID		= ECampaignButID.ButtonNewID;
	m_pButNewCampaign.Align				= TA_Left;	
	m_pButNewCampaign.m_buttonFont		= m_LeftButtonFont;
    m_pButNewCampaign.CheckToDownSizeFont(m_LeftDownSizeFont,0);
	m_pButNewCampaign.ResizeToText();

	fYPos += fYOffset;

	// define Delete campaign button
	m_pButDelCampaign = R6WindowButton(CreateControl( class'R6WindowButton', fXOffset, fYPos, fWidth, fHeight, self));
	m_pButDelCampaign.ToolTipString		= Localize("Tip","ButtonDeleteCampaign","R6Menu");
	m_pButDelCampaign.Text				= Localize("SinglePlayer","ButtonDelete","R6Menu");
	m_pButDelCampaign.m_iButtonID		= ECampaignButID.ButtonDeleteID;
	m_pButDelCampaign.Align				= TA_Left;
	m_pButDelCampaign.m_buttonFont		= m_LeftButtonFont;
    m_pButDelCampaign.CheckToDownSizeFont(m_LeftDownSizeFont,0);
	m_pButDelCampaign.ResizeToText();

	m_pButCurrent = m_pButResumeCampaign;
}


function BOOL ButtonsUsingDownSizeFont()
{
    local BOOL result;

    if( m_pButResumeCampaign.IsFontDownSizingNeeded()   ||
        m_pButNewCampaign.IsFontDownSizingNeeded()      ||
        m_pButDelCampaign.IsFontDownSizingNeeded()
      )
        result = true;   

    return result;
}



function ForceFontDownSizing()
{
    
    m_pButResumeCampaign.m_buttonFont   = m_LeftDownSizeFont;
    m_pButNewCampaign.m_buttonFont      = m_LeftDownSizeFont;
    m_pButDelCampaign.m_buttonFont      = m_LeftDownSizeFont;    

    m_pButResumeCampaign.ResizeToText();
    m_pButNewCampaign.ResizeToText();
    m_pButDelCampaign.ResizeToText();
    
}

function SetCurrentBut( INT _iNewCurBut)
{
	m_pButCurrent.m_bSelected = false;
	m_iSelectedButtonID = _iNewCurBut;

	switch(_iNewCurBut)
	{
		case ECampaignButID.ButtonResumeID:
			m_pButCurrent = m_pButResumeCampaign;
			Root.SetLoadRandomBackgroundImage("CampResume");
			break;
		case ECampaignButID.ButtonNewID:
			m_pButCurrent = m_pButNewCampaign;
			Root.SetLoadRandomBackgroundImage("CampNew");
			break;
		case ECampaignButID.ButtonDeleteID:
			m_pButCurrent = m_pButDelCampaign;
			Root.SetLoadRandomBackgroundImage("CampResume");
			break;
	}

	m_pButCurrent.m_bSelected = true;
}

defaultproperties
{
}
