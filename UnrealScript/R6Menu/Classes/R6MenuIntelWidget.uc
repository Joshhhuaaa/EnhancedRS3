//=============================================================================
//  R6MenuIntelWidget.uc : This is the Intel menu
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/12 * Created by Alexandre Dionne
//=============================================================================
class R6MenuIntelWidget extends R6MenuLaptopWidget;

enum EMenuIntelButtonID
{
    ButtonControlID,
    ButtonClarkID,
    ButtonSweenyID,
    ButtonNewsID,
    ButtonMissionID
};

const szScrollTextArraySize = 10;                                           // the size of the scroll text area
const K_fVideoWidth         = 438;                                          // the video window width
const K_fVideoHeight        = 230;                                          // the video window height

var R6WindowWrappedTextArea		m_SrcrollingTextArea, 
                                m_MissionObjectives;
var R6MenuVideo                 m_MissionDesc;

var R6WindowBitMap              m_2DSpeaker;
var Region                      m_RControl,
                                m_RClark,
                                m_RSweeney,
                                m_RNewsWire,
                                m_RMissionOrder;

var Texture                     m_TSpeaker;

var R6MenuIntelRadioArea        m_SpeakerControls;
var R6WindowTextLabel			m_CodeName, 
                                m_DateTime, 
                                m_Location;
                                

var Texture                     m_Texture;
var Font                        m_labelFont;
var Font                        m_R6Font14;

var string                      m_szScrollingText;

var FLOAT                       m_fLaptopPadding, 
                                m_fPaddingBetweenElements;
var FLOAT                       m_fVideoLeft,
                                m_fVideoRight,
                                m_fVideoTop,
                                m_fVideoBottom,
                                m_fLabelHeight,
                                m_fSpeakerWidgetWidth,
                                m_fSpeakerWidgetHeight;

var FLOAT                       m_fRightTileModulo,
                                m_fLeftTileModulo,
                                m_fBottomTileModulo,
                                m_fRightBGWidth,
                                m_fUpBGWidth,
                                m_fBottomHeight;

var bool                        m_bAddText;
var bool                        bShowLog;

var INT                         m_iCurrentSpeaker;
var Sound                       m_sndPlayEvent;


function Created()
{
	local INT    LabelWidth;
    
    
    Super.Created();

	m_Texture = Texture(DynamicLoadObject("R6MenuTextures.Gui_BoxScroll", class'Texture'));
	
	m_labelFont = Root.Fonts[F_IntelTitle];
    m_R6Font14  = Root.Fonts[F_SmallTitle]; 	

    
    //*******************************************************************************************
    //                                 Title Labels
    //*******************************************************************************************
	LabelWidth = int(m_Right.WinLeft - m_left.WinWidth )/3;
    // CODE NAME
	m_CodeName = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                m_left.WinWidth, 
                                                m_Top.WinHeight, 
		                                        LabelWidth, 
                                                m_fLabelHeight,
                                                self));
    

    // DATE TIME
	m_DateTime = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                m_CodeName.WinLeft + m_CodeName.WinWidth,
                                                m_Top.WinHeight, 
                                                LabelWidth,
                                                m_fLabelHeight,
                                                self));
    

    // LOCATION
	m_Location = R6WindowTextLabel(CreateWindow(class'R6WindowTextLabel', 
                                                m_DateTime.WinLeft + m_DateTime.WinWidth, 
                                                m_Top.WinHeight, 
                                        		m_DateTime.WinWidth, 
                                                m_fLabelHeight,
                                                self));


    //*******************************************************************************************
    //                                 Speaker Left widget
    //*******************************************************************************************
    m_2DSpeaker = R6WindowBitMap(CreateWindow(class'R6WindowBitMap',
                                       m_Left.WinWidth + m_fLaptopPadding,
                                       m_CodeName.WinTop + m_fLabelHeight,
                                       m_fSpeakerWidgetWidth, 
                                       m_fSpeakerWidgetHeight,
                                       self));
    m_2DSpeaker.m_bDrawBorder = true;
    m_2DSpeaker.m_BorderColor = Root.Colors.GrayLight;
    m_2DSpeaker.T = m_TSpeaker;
    
	 
    
    //*******************************************************************************************
    //                           the Controls under the speaker widget
    //*******************************************************************************************
    m_SpeakerControls = R6MenuIntelRadioArea(CreateWindow(class'R6MenuIntelRadioArea',
                                                          m_2DSpeaker.WinLeft,
                                                          m_2DSpeaker.WinTop + m_2DSpeaker.WinHeight,
                                                          m_2DSpeaker.WinWidth,
                                                          K_fVideoHeight - m_2DSpeaker.WinHeight, 
                                                          self));

    m_SpeakerControls.m_BorderColor = Root.Colors.GrayLight;

    m_iCurrentSpeaker = -1;   

    
   
    
    //*******************************************************************************************
    //                           the video zone
    //*******************************************************************************************

    // these values are needed to display the  background
    m_fVideoTop = m_2DSpeaker.WinTop; 
    m_fVideoLeft = m_Right.WinLeft - K_fVideoWidth -m_fLaptopPadding;
    m_fVideoRight = m_Right.WinLeft - m_fLaptopPadding;
    m_fVideoBottom = m_fVideoTop + K_fVideoHeight;

    //To use less cpu juice for drawing the bg
    m_fRightTileModulo = m_fVideoRight % m_TBackGround.USize;
    m_fLeftTileModulo  = m_fVideoLeft % m_TBackGround.USize;
    m_fBottomTileModulo = m_fVideoBottom % m_TBackGround.VSize;
    m_fRightBGWidth = WinWidth - m_fVideoRight;
    m_fUpBGWidth = m_fVideoRight - m_fVideoLeft;
    m_fBottomHeight = WinHeight - m_fVideoBottom;
    
    
    m_MissionDesc = R6MenuVideo(CreateWindow(class'R6MenuVideo', 
                                             m_fVideoLeft,
                                             m_fVideoTop,
                                             K_fVideoWidth,
                                             K_fVideoHeight, self));
    m_MissionDesc.m_BorderColor = Root.Colors.GrayLight;    


    //*******************************************************************************************
    //                           Big Scrolling text Area under the video
    //*******************************************************************************************
    m_SrcrollingTextArea = R6WindowWrappedTextArea(CreateWindow(class'R6WindowWrappedTextArea', 
                                                                m_fVideoLeft,
                                                          	    m_fVideoBottom + m_fPaddingBetweenElements,
                                                                K_fVideoWidth, 
                                                                m_HelpTextBar.WinTop - m_fPaddingBetweenElements - m_fVideoBottom - m_fPaddingBetweenElements,
                                                                self));
		
	m_SrcrollingTextArea.m_BorderColor = Root.Colors.GrayLight;
    m_SrcrollingTextArea.SetScrollable(true);
    m_SrcrollingTextArea.VertSB.SetBorderColor(Root.Colors.GrayLight);  
    m_SrcrollingTextArea.VertSB.SetHideWhenDisable(true);
    m_SrcrollingTextArea.VertSB.SetEffect(true);

    
    //*******************************************************************************************
    //                           Mission objectives
    //*******************************************************************************************
	m_MissionObjectives = R6WindowWrappedTextArea(CreateWindow(class'R6WindowWrappedTextArea', 
		                                                       m_2DSpeaker.WinLeft, 
                                                               m_SrcrollingTextArea.WinTop, 
                                   	                           m_2DSpeaker.WinWidth,
                                                               m_SrcrollingTextArea.WinHeight,
                                                               self));

	m_MissionObjectives.m_BorderColor = Root.Colors.GrayLight;
    m_MissionObjectives.SetScrollable(true);
	m_MissionObjectives.VertSB.SetBorderColor(Root.Colors.GrayLight);  
    m_MissionObjectives.VertSB.SetHideWhenDisable(true);
    m_MissionObjectives.VertSB.SetEffect(true);
    m_MissionObjectives.m_BorderStyle = ERenderStyle.STY_Normal;    

    GetLevel().m_bPlaySound = false;    
    
    m_NavBar.m_BriefingButton.bDisabled = true;
}

function Reset()
{
    m_iCurrentSpeaker = -1;    
    m_SpeakerControls.Reset();
}

function HideWindow()
{
    Super.HideWindow();
    
	StopIntelWidgetSound();
    GetPlayerOwner().FadeSound(3, 100, SLOT_Music);
}

function ShowWindow()
{
    local int itempSpeaker;
    local int i;
    local R6MissionDescription        CurrentMission;        
    local R6MissionObjectiveMgr moMgr;

    Super.ShowWindow();

    GetLevel().m_bPlaySound = false;    

    if(bShowLog)log("R6MenuIntelWidget::Show()");

    CurrentMission = R6MissionDescription(R6Console(Root.console).master.m_StartGameInfo.m_CurrentMission);

    m_CodeName.SetProperties( Localize(CurrentMission.m_MapName,"ID_CODENAME",CurrentMission.LocalizationFile),
                              TA_Center, m_labelFont, Root.Colors.White, false);

    m_DateTime.SetProperties( Localize(CurrentMission.m_MapName,"ID_DATETIME",CurrentMission.LocalizationFile),
                              TA_Center, m_labelFont, Root.Colors.White, false);
    
    m_Location.SetProperties( Localize(CurrentMission.m_MapName,"ID_LOCATION",CurrentMission.LocalizationFile),
                              TA_Center, m_labelFont, Root.Colors.White, false);

    m_SpeakerControls.AssociateButtons();

    
    m_MissionDesc.PlayVideo( m_Right.WinLeft - K_fVideoWidth -m_fLaptopPadding,
                             m_SrcrollingTextArea.WinTop -230 - m_fPaddingBetweenElements,
                             R6AbstractGameInfo(Root.Console.ViewportOwner.Actor.Level.Game).GetIntelVideoName(CurrentMission)$".bik"); 
    
    m_MissionObjectives.clear();

    //Load Sounds
    GetPlayerOwner().AddSoundBank(CurrentMission.m_AudioBankName, LBS_Gun);
    GetLevel().FinalizeLoading();    
    GetLevel().SetBankSound(BANK_UnloadGun);
    
    m_MissionObjectives.clear();
    m_MissionObjectives.m_fXOffset=10;
    m_MissionObjectives.m_fYOffset=5;
    m_MissionObjectives.AddText( Localize("Briefing","Objectives","R6Menu"), Root.Colors.BlueLight, Root.Fonts[F_SmallTitle]);
    

    moMgr = R6AbstractGameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_missionMgr;
    
    for ( i = 0; i < moMgr.m_aMissionObjectives.Length; ++i )
    {
        if ( (!moMgr.m_aMissionObjectives[i].m_bMoralityObjective)  && (moMgr.m_aMissionObjectives[i].m_bVisibleInMenu))
        {                                
            
            m_MissionObjectives.AddText( Localize( "Game", moMgr.m_aMissionObjectives[i].m_szDescriptionInMenu, moMgr.Level.GetMissionObjLocFile( moMgr.m_aMissionObjectives[i] ) ), 
                                            Root.Colors.White, 
                                            Root.Fonts[F_ListItemSmall]);      

            m_MissionObjectives.AddText( " ", 
                                         Root.Colors.White, 
                                         Root.Fonts[F_ListItemSmall]); 
        }     
    }    
    

    itempSpeaker = m_iCurrentSpeaker;
    m_iCurrentSpeaker = -1;
    if(bShowLog)log("itempSpeaker"@itempSpeaker);

    if( !m_SpeakerControls.m_ControlButton.bDisabled)
    {    
        if(itempSpeaker == -1)
            ManageButtonSelection(0);
        else
            ManageButtonSelection(itempSpeaker);
    }
}


function Paint( Canvas C, FLOAT X, FLOAT Y)
{
    
    // we have to cut in four part the background to see the video (the video display is process before the menu!)
    // left part of the video    
    
    DrawStretchedTextureSegment( C, 0, 0, m_fVideoLeft, WinHeight, 
                                    0, 0, m_fVideoLeft, WinHeight, m_TBackGround );

    // right part of the video
    DrawStretchedTextureSegment( C, m_fVideoRight, 0, m_fRightBGWidth, WinHeight, 
                                    m_fRightTileModulo , 0, m_fRightBGWidth, WinHeight, m_TBackGround );
    // up part of the video
    DrawStretchedTextureSegment( C, m_fVideoLeft, 0, m_fUpBGWidth, m_fVideoTop, 
                                    m_fLeftTileModulo, 0, m_fUpBGWidth, m_fVideoTop, m_TBackGround );
    
    // down part of the video
    DrawStretchedTextureSegment( C, m_fVideoLeft, m_fVideoBottom, m_fUpBGWidth, m_fBottomHeight, 
                                    m_fLeftTileModulo, m_fBottomTileModulo, m_fUpBGWidth, m_fBottomHeight, m_TBackGround );
    
    DrawLaptopFrame( C );
    
}


function DisplayText( FLOAT _X, FLOAT _Y, Font _TextFont, Color _color, R6WindowWrappedTextArea _R6WindowWrappedTextArea)
{

        _R6WindowWrappedTextArea.m_fXOffset = _X;
        _R6WindowWrappedTextArea.m_fYOffset = _Y;
        _R6WindowWrappedTextArea.AddText( m_szScrollingText, _color, _TextFont);
}


// set all the text corresponding with _szOriginal#
// return true if at least we find one valid sentence at _szOriginal
function bool SetMissionText( string _szOriginal)
{
    local string szTemp;
    local INT    i;
    local bool   bFindText;
    local R6MissionDescription        CurrentMission;    
    
    m_szScrollingText = "";
    
    if(R6GameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_bUsingCampaignBriefing == true)
    {
        CurrentMission = R6MissionDescription(R6Console(Root.console).master.m_StartGameInfo.m_CurrentMission);        
        m_szScrollingText = Localize( CurrentMission.m_MapName, _szOriginal, CurrentMission.LocalizationFile, true, true);
    }
    else
    {      
      m_szScrollingText = Localize( GetLevel().GameTypeToString(GetLevel().Game.m_szGameTypeFlag ), _szOriginal, 
                                    GetLevel().GameTypeLocalizationFile(GetLevel().Game.m_szGameTypeFlag), true, true);
    }    
    
    return (m_szScrollingText != "");
}

// depending the selected button, find the text corresponding and fill it in a text array ( this is for R6Mission.int)
// ex ID_CONTROL, ID_CONTROL1, ID_CONTROL2, ID_CONTROL3, etc... 
function ManageButtonSelection( INT _eButtonSelection)
{
    local bool bChangeText;    
    local R6MissionDescription        CurrentMission;
    

    if(bShowLog)log("ManageButtonSelection"@m_iCurrentSpeaker@_eButtonSelection);
    
    if (m_iCurrentSpeaker == _eButtonSelection)
    {
        if(bShowLog)log("Nothing To Do!");
        return;
    }

    m_iCurrentSpeaker = _eButtonSelection;
    CurrentMission = R6MissionDescription(R6Console(Root.console).master.m_StartGameInfo.m_CurrentMission);

    if (m_sndPlayEvent != none)
        GetPlayerOwner().StopSound(m_sndPlayEvent);
    
    m_sndPlayEvent = none;
    // get the specific text and clear the previous one
    switch(_eButtonSelection)
    {
        case EMenuIntelButtonID.ButtonControlID :
            SetMissionText( "ID_CONTROL");      

            if( R6GameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_bUsingCampaignBriefing == true )
            {
                m_sndPlayEvent = CurrentMission.m_PlayEventControl;

            }
            m_2DSpeaker.R = m_RControl;
            break;
        case EMenuIntelButtonID.ButtonClarkID :
            SetMissionText( "ID_CLARK");            

            if( R6GameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_bUsingCampaignBriefing == true )
            {
                m_sndPlayEvent = CurrentMission.m_PlayEventClark;
            }

            m_2DSpeaker.R = m_RClark;
            break;
        case EMenuIntelButtonID.ButtonSweenyID :
            SetMissionText( "ID_SWEENY");   
            
            if( R6GameInfo(Root.Console.ViewportOwner.Actor.Level.Game).m_bUsingCampaignBriefing == true )
            {
                m_sndPlayEvent = CurrentMission.m_PlayEventSweeney;
            }
            m_2DSpeaker.R = m_RSweeney;
            break;
        case EMenuIntelButtonID.ButtonNewsID :
            SetMissionText( "ID_NEWSWIRE");            
            m_2DSpeaker.R = m_RNewsWire;
            break;        
        case EMenuIntelButtonID.ButtonMissionID :
            SetMissionText( "ID_MISSION_ORDER");            
            m_2DSpeaker.R = m_RMissionOrder;
            break;
        default:
            break;
    }

    if(m_sndPlayEvent != none)
    {
        GetPlayerOwner().PlaySound(m_sndPlayEvent, SLOT_Speak);   
        GetPlayerOwner().FadeSound(3, 15, SLOT_Music);
    }

    m_SrcrollingTextArea.Clear();
    DisplayText( 10, 4, Root.Fonts[F_ListItemSmall], Root.Colors.White, m_SrcrollingTextArea);
}

function StopIntelWidgetSound()
{
    m_MissionDesc.StopVideo();
    
    GetPlayerOwner().StopSound(m_sndPlayEvent); 
    m_sndPlayEvent = none;
}

defaultproperties
{
     m_bAddText=True
     m_fLaptopPadding=2.000000
     m_fPaddingBetweenElements=3.000000
     m_fLabelHeight=18.000000
     m_fSpeakerWidgetWidth=156.000000
     m_fSpeakerWidgetHeight=117.000000
     m_TSpeaker=Texture'R6MenuTextures.Gui_04_a00'
     m_RControl=(W=155,H=116)
     m_RClark=(Y=117,W=155,H=116)
     m_RSweeney=(X=156,W=155,H=116)
     m_RNewsWire=(X=156,Y=117,W=155,H=116)
     m_RMissionOrder=(X=312,W=155,H=116)
}
