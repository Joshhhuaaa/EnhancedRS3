//=============================================================================
//  R6MenuPlanningWidget.uc : Planning phase Menu
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/12 * Created by Alexandre Dionne
//=============================================================================
class R6MenuPlanningWidget extends R6MenuLaptopWidget;

var R6MenuPlanningBar           m_PlanningBar;
var R6Menu3DViewOnOffButton     m_3DButton;
var R6MenuLegendButton          m_LegendButton;
var R6Window3DButton            m_3DWindow;
var R6WindowLegend              m_LegendWindow;

var R6WindowTextLabel			m_CodeName, 
                                m_DateTime, 
                                m_Location;
var Font                        m_labelFont;
var FLOAT                       m_fLabelHeight;


var R6MenuActionPointMenu       m_PopUpMenuPoint;
var R6MenuModeMenu              m_PopUpMenuMode;
var bool                        m_bPopUpMenuPoint; //Action PopUp menu is beeing displayed
var bool                        m_bPopUpMenuSpeed;      //Speed PopUp Menu is beeing displayed

var FLOAT                       m_fLMouseDownX;
var FLOAT                       m_fLMouseDownY;
var bool                        m_bMoveUDByLaptop;
var bool                        m_bMoveRLByLaptop;

var bool                        m_bClosePopup;

// var R6WindowPopUpBox            m_PopUpWrapTextArea; 


// Debug vars
var UWindowWindow               DEB_FocusedWindow;
var bool                        bShowLog;
// End Debug

const R6InputKey_ActionPopup    = 1024;
const R6InputKey_NewNode        = 1025;
const R6InputKey_PathFlagPopup  = 1026;

function Created()
{ 
    local INT i;
    local R6MenuRSLookAndFeel LAF;
    local Region TheRegion;
    local FLOAT fLaptopPadding;

    local INT    LabelWidth;
    
    local R6WindowWrappedTextArea       WrapTextArea;
    
   
    LAF = R6MenuRSLookAndFeel(OwnerWindow.LookAndFeel);

    Super.Created();

    fLaptopPadding = 2; //is m_fLaptopPadding; see intel widget
    
	//Resized();
    //SetMousePos(WinWidth*0.5f,WinHeight*0.5f);	
    
    TheRegion.Y = 480 - LAF.m_stLapTopFrame.B.H - 4 - LAF.m_NavBarBack[0].H;        

    //Create 3D View button.
	TheRegion.H = 16;
	TheRegion.Y = m_NavBar.WinTop - TheRegion.H - fLaptopPadding;        	
    TheRegion.X = m_NavBar.WinLeft;
    TheRegion.W = 35;
    m_3DButton = R6Menu3DViewOnOffButton(CreateWindow(class'R6Menu3DViewOnOffButton',TheRegion.X, TheRegion.Y, TheRegion.W, TheRegion.H,self));
	// Create Legend Button
	TheRegion.H = 16;
	TheRegion.Y = m_NavBar.WinTop - TheRegion.H - fLaptopPadding;        	
    TheRegion.X = m_NavBar.WinLeft + m_NavBar.WinWidth - 35; // 35 is the width
    TheRegion.W = 35;
    m_LegendButton = R6MenuLegendButton(CreateWindow(class'R6MenuLegendButton', TheRegion.X, TheRegion.Y, TheRegion.W, TheRegion.H, self));
    // Create Planning Tool Bar
    TheRegion.X = LAF.m_stLapTopFrame.L.W + 1;
    TheRegion.H = 2 + 23; //23 is the standart height of the planning bar.
    TheRegion.Y -= 2 + TheRegion.H;
    TheRegion.W = 640 - m_Right.WinWidth;
    m_PlanningBar = R6MenuPlanningBar(CreateWindow(class'R6MenuPlanningBar', TheRegion.X, TheRegion.Y, TheRegion.W, TheRegion.H, self));

    //Create 3D view window
    TheRegion.W = ((m_Right.WinLeft - m_Left.WinWidth) / 3) + 2; //the 3D window has a border of one pixel, that's why we need the + 2
    TheRegion.H = ((m_Bottom.WinTop - m_Top.WinHeight) / 3) + 2;
    TheRegion.X = m_Left.WinWidth + 2;
    TheRegion.Y = m_Top.WinHeight + m_fLabelHeight + 1;
    m_3DWindow = R6Window3DButton(CreateWindow(class'R6Window3DButton', TheRegion.X, TheRegion.Y, TheRegion.W, TheRegion.H, self));
    m_3DWindow.HideWindow();

    //Create the Legend window, position is the bottom left corner, size varies with localisation
    m_LegendWindow = R6WindowLegend(CreateWindow(class'R6WindowLegend', m_Right.WinLeft-103 , m_Top.WinHeight + m_fLabelHeight + 1, 100, 100, self));
    m_LegendWindow.HideWindow();

    /////////////////////////////////////////////
    //Creating the pop ups
    ////////////////////////////////////////////
    
   
//    m_PopUpWrapTextArea = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480));
//    m_PopUpWrapTextArea.CreateStdPopUpWindow( Localize("PlanningMenu","WAYPOINTS","R6Menu"), 30, 207, 152, 226, 176);
//    m_PopUpWrapTextArea.CreateClientWindow( class'R6WindowWrappedTextArea' );
//    WrapTextArea                   = R6WindowWrappedTextArea(m_PopUpWrapTextArea.m_ClientArea);     
//	WrapTextArea.m_HBorderTexture	= None;
//	WrapTextArea.m_VBorderTexture	= None;	                
//	WrapTextArea.m_fHBorderHeight = 0;
//	WrapTextArea.m_fVBorderWidth = 0;
//	WrapTextArea.m_BorderColor = Root.Colors.GrayLight;
//    WrapTextArea.SetScrollable(true);
//	WrapTextArea.VertSB.SetBorderColor(Root.Colors.GrayLight);  
//    WrapTextArea.VertSB.SetHideWhenDisable(true);
//    m_PopUpWrapTextArea.HideWindow();
//    
//    m_PopUpWrapTextArea = R6WindowPopUpBox(CreateWindow( class'R6WindowPopUpBox', 0, 0, 640, 480));
//    m_PopUpWrapTextArea.CreateStdPopUpWindow( Localize("PlanningMenu","WAYPOINTS","R6Menu"), 30, 207, 152, 226, 176);
//    m_PopUpWrapTextArea.CreateClientWindow( class'R6WindowWrappedTextArea' );
//    WrapTextArea                   = R6WindowWrappedTextArea(m_PopUpWrapTextArea.m_ClientArea);
//	WrapTextArea.m_HBorderTexture	= None;
//	WrapTextArea.m_VBorderTexture	= None;	                
//	WrapTextArea.m_fHBorderHeight = 0;
//	WrapTextArea.m_fVBorderWidth = 0;
//	WrapTextArea.m_BorderColor = Root.Colors.GrayLight;
//    WrapTextArea.SetScrollable(true);
//	WrapTextArea.VertSB.SetBorderColor(Root.Colors.GrayLight);  
//    WrapTextArea.VertSB.SetHideWhenDisable(true);
//    m_PopUpWrapTextArea.HideWindow();    


            
    /////////////////////////////////////////////
    //  END OF POP UPS CREATION                //
    /////////////////////////////////////////////

    //*******************************************************************************************
    //                                 Title Labels
    //*******************************************************************************************
	m_labelFont = Root.Fonts[F_IntelTitle];
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
    
    m_NavBar.m_PlanningButton.bDisabled = true;

}

function Reset()
{
    m_PlanningBar.Reset();
}

function ResetTeams(INT iWhatToReset)
{
    CloseAllPopup();
    m_PlanningBar.ResetTeams(iWhatToReset);
}


function HideWindow()
{
    local LevelInfo li;
 
    Hide3DAndLegend();

    R6MenuRootWindow(Root).StopPlayMode();
    
    Super.HideWindow();

    li = GetLevel();
    li.m_bAllow3DRendering = false;
}

function Hide3DAndLegend()
{
   //close the 3D window, if open
    if(R6PlanningCtrl(GetPlayerOwner())!=none)
        R6PlanningCtrl(GetPlayerOwner()).TurnOff3DView();
    m_3DWindow.Close3DWindow();
    m_LegendWindow.CloseLegendWindow();
    //Reset the 3dbutton
    m_3DButton.m_bSelected = false;
    //Reset Legend button
    m_LegendButton.m_bSelected = false;
    
    CloseAllPopup();
}

function ShowWindow()
{
    local LevelInfo li;
    local R6MissionDescription        CurrentMission;        
    local R6GameOptions pGameOptions;
    local R6MenuRootWindow  R6Root;


    R6Root = R6MenuRootWindow(Root);
    //Reset the 3dbutton
    if(R6Root.m_bPlayerPlanInitialized && !R6Root.m_bPlayerDoNotWant3DView)
    {
        m_3DButton.m_bSelected = true;
        m_3DWindow.Toggle3DWindow();
        R6PlanningCtrl(GetPlayerOwner()).Toggle3DView();
    }
    else
    {
        R6PlanningCtrl(GetPlayerOwner()).TurnOff3DView();
        m_3DWindow.Close3DWindow();
        m_3DButton.m_bSelected = false;
    }
    
    //Reset Legend button
    if(R6Root.m_bPlayerPlanInitialized && R6Root.m_bPlayerWantLegend)
    {
        m_LegendButton.m_bSelected = true;
        m_LegendWindow.ToggleLegend();
    }
    else
        m_LegendButton.m_bSelected = false;

    Super.ShowWindow();
    li = GetLevel();

    li.m_bAllow3DRendering = true;

    CurrentMission = R6MissionDescription(R6Console(Root.console).master.m_StartGameInfo.m_CurrentMission);

    m_CodeName.SetProperties( Localize(CurrentMission.m_MapName,"ID_CODENAME", CurrentMission.LocalizationFile),
                              TA_Center, m_labelFont, Root.Colors.White, false);

    m_DateTime.SetProperties( Localize(CurrentMission.m_MapName,"ID_DATETIME", CurrentMission.LocalizationFile),
                              TA_Center, m_labelFont, Root.Colors.White, false);
    
    m_Location.SetProperties( Localize(CurrentMission.m_MapName,"ID_LOCATION", CurrentMission.LocalizationFile),
                              TA_Center, m_labelFont, Root.Colors.White, false);

    if(R6Root.m_bPlayerPlanInitialized == false)
    {
        pGameOptions = class'Actor'.static.GetGameOptions();
        if( pGameOptions.PopUpLoadPlan == true)
        {
            R6Root.m_ePopUpID = EPopUpID_LoadPlanning;
            R6Root.PopUpMenu(true);      
        }   
    }
}


function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    //Super.Paint(C, X, Y); To prevent BackGround to be displayed
    
    C.Style = ERenderStyle.STY_Normal;

    C.SetDrawColor(Root.Colors.GrayLight.R,Root.Colors.GrayLight.G,Root.Colors.GrayLight.B);
    //Draw Lines
    DrawStretchedTextureSegment( C, m_Left.WinWidth + 1, m_Top.WinHeight+m_fLabelHeight, WinWidth - m_Right.WinWidth - 2, 1, 
                                    18, 56, 1, 1, Texture'R6MenuTextures.Gui_BoxScroll' );
    DrawStretchedTextureSegment( C, m_Left.WinWidth + 1, m_Top.WinHeight+m_fLabelHeight, 1, 364 - m_Top.WinHeight - m_fLabelHeight, 
                                    18, 56, 1, 1, Texture'R6MenuTextures.Gui_BoxScroll' );
    DrawStretchedTextureSegment( C, WinWidth - m_Right.WinWidth - 2, m_Top.WinHeight+m_fLabelHeight, 1, 364 - m_Top.WinHeight - m_fLabelHeight, 
                                    18, 56, 1, 1, Texture'R6MenuTextures.Gui_BoxScroll' );
    C.SetDrawColor(Root.Colors.GrayDark.R,Root.Colors.GrayDark.G,Root.Colors.GrayDark.B);
    //Draw BackGround under the planning bar
    DrawStretchedTextureSegment( C, 0, 364, m_PlanningBar.WinWidth, m_PlanningBar.WinHeight, 
                                    0, 364, m_PlanningBar.WinWidth, m_PlanningBar.WinHeight, m_TBackGround );
    C.SetDrawColor(Root.Colors.White.R,Root.Colors.White.G,Root.Colors.White.B);
    
    //Draw BackGround on top of the screen 
    DrawStretchedTextureSegment( C, 0, m_Top.WinHeight, WinWidth, m_fLabelHeight, 
                                    0, m_Top.WinHeight, WinWidth, m_fLabelHeight, m_TBackGround );
    //Draw side textures
    DrawStretchedTextureSegment( C, m_Left.WinWidth, m_Top.WinHeight+m_fLabelHeight, 1, 364, 
                                    m_Left.WinWidth, m_Top.WinHeight+m_fLabelHeight, 1, 364, m_TBackGround );
    DrawStretchedTextureSegment( C, WinWidth - m_Right.WinWidth - 1, m_Top.WinHeight+m_fLabelHeight, 1, 364, 
                                    WinWidth - m_Right.WinWidth - 1, m_Top.WinHeight+m_fLabelHeight, 1, 364, m_TBackGround );

    //Draw Rest of the background BackGround 
    DrawStretchedTextureSegment( C, 0, 364+m_PlanningBar.WinHeight, WinWidth, 96, 
                                    0, 364+m_PlanningBar.WinHeight, WinWidth, 96, m_TBackGround );

    m_HelpTextBar.m_HelpTextBar.m_szDefaultText = Localize("PlanningMenu","LevelText","R6Menu");
    m_HelpTextBar.m_HelpTextBar.m_szDefaultText = m_HelpTextBar.m_HelpTextBar.m_szDefaultText @ (R6PlanningCtrl(GetPlayerOwner()).m_iLevelDisplay - 100);

    if(bShowLog)
    {
        if(DEB_FocusedWindow != Root.FocusedWindow)
        {
            Log("-->FocusedWindow: "$Root.FocusedWindow);
            DEB_FocusedWindow = Root.FocusedWindow;
        }
    }    
    
    DrawLaptopFrame( C );
}

function Tick(FLOAT fDelta)
{
    local R6PlanningCtrl PlanningCtrl;
    local Region TheRegion;

    Super.Tick(fDelta);

    if(GetPlayerOwner().IsA('R6PlanningCtrl'))
    {
        PlanningCtrl = R6PlanningCtrl(GetPlayerOwner());

        if(Root.m_bUseDragIcon == false)
        {
            // Move the map when the mouse touch the laptop border
            if(Root.MouseX < (m_Left.WinWidth+1))
            {
                PlanningCtrl.m_bMoveLeft = 1;
                m_bMoveRLByLaptop=true;
                m_bClosePopup=true;
            }
            else if(Root.MouseX > (m_Right.WinLeft-1))
            {
                PlanningCtrl.m_bMoveRight = 1;
                m_bMoveRLByLaptop=true;
            }
            else if(m_bMoveRLByLaptop == true)
            {
                m_bMoveRLByLaptop = false;
                PlanningCtrl.m_bMoveLeft = 0;
                PlanningCtrl.m_bMoveRight  = 0;
                m_bClosePopup=true;
            }
   
            if(Root.MouseY < (m_Top.WinHeight+1))
            {
                PlanningCtrl.m_bMoveUp = 1;
                m_bMoveUDByLaptop=true;
                m_bClosePopup=true;
            }
            else if(Root.MouseY > (m_Bottom.WinTop-1))
            {
                PlanningCtrl.m_bMoveDown = 1;
                m_bMoveUDByLaptop=true;
                m_bClosePopup=true;
            }
            else if(m_bMoveUDByLaptop == true)
            {
                m_bMoveUDByLaptop = false;
                PlanningCtrl.m_bMoveDown = 0;
                PlanningCtrl.m_bMoveUp = 0;
                m_bClosePopup=true;
            }
        }
        else // if drag/drop limit the mouse movement
        {
            // Move the map when the mouse touch the laptop border
            if(Root.MouseX < 23)
            {
                PlanningCtrl.m_bMoveLeft = 1;
                m_bMoveRLByLaptop=true;
                m_bClosePopup=true;
            }
            else if(Root.MouseX > 616)
            {
                PlanningCtrl.m_bMoveRight = 1;
                m_bMoveRLByLaptop=true;
            }
            else if(m_bMoveRLByLaptop == true)
            {
                m_bMoveRLByLaptop = false;
                PlanningCtrl.m_bMoveLeft = 0;
                PlanningCtrl.m_bMoveRight  = 0;
                m_bClosePopup=true;
            }

            if(Root.MouseY < 52)
            {
                PlanningCtrl.m_bMoveUp = 1;
                m_bMoveUDByLaptop=true;
                m_bClosePopup=true;
            }
            else if(Root.MouseY > 362)
            {
                PlanningCtrl.m_bMoveDown = 1;
                m_bMoveUDByLaptop=true;
                m_bClosePopup=true;
            }
            else if(m_bMoveUDByLaptop == true)
            {
                m_bMoveUDByLaptop = false;
                PlanningCtrl.m_bMoveDown = 0;
                PlanningCtrl.m_bMoveUp = 0;
                m_bClosePopup=true;
            }
        }

        if(PlanningCtrl.m_bFirstTick == true)
        {
            PlanningCtrl.m_bFirstTick = false;
            //Send the coordinates to the planning controller for the 3D view.
            TheRegion.W = (m_Right.WinLeft - m_Left.WinWidth) / 3;
            TheRegion.H = (m_Bottom.WinTop - m_Top.WinHeight) / 3;
            TheRegion.X = m_Left.WinWidth + 3;
            TheRegion.Y = m_Top.WinHeight + m_fLabelHeight + 2;
            //Do it here because we know planning ctrl is avalaible here.
            PlanningCtrl.Set3DViewPosition(TheRegion.X, TheRegion.Y, TheRegion.H, TheRegion.W);
        }
    }

    if(m_bClosePopup)
    {
        CloseAllPopup();
        m_bClosePopup=false;
    }
}

function LMouseDown( FLOAT fMouseX, FLOAT fMouseY)
{
    local R6PlanningCtrl PlanningCtrl;

    super.LMouseDown(fMouseX,fMouseY);

    if(m_bPopUpMenuPoint || m_bPopUpMenuSpeed)
    {
        CloseAllPopup();
    }
    else
    {
        PlanningCtrl = R6PlanningCtrl(GetPlayerOwner());
        if(PlanningCtrl!=NONE)
        {
            PlanningCtrl.LMouseDown( fMouseX*Root.GUIScale, fMouseY*Root.GUIScale);
        }
    }
}

function LMouseUp( FLOAT fMouseX, FLOAT fMouseY)
{
    local R6PlanningCtrl PlanningCtrl;

    super.LMouseUp(fMouseX,fMouseY);

    PlanningCtrl = R6PlanningCtrl(GetPlayerOwner());
    if(PlanningCtrl!=NONE)
    {
        PlanningCtrl.LMouseUp( fMouseX*Root.GUIScale, fMouseY*Root.GUIScale);
    }
}

function RMouseDown( FLOAT fMouseX, FLOAT fMouseY)
{
    local R6PlanningCtrl PlanningCtrl;

    super.RMouseDown(fMouseX,fMouseY);

    if(m_bPopUpMenuPoint || m_bPopUpMenuSpeed)
    {
        CloseAllPopup();
    }
    else
    {
        PlanningCtrl = R6PlanningCtrl(GetPlayerOwner());
        if(PlanningCtrl!=NONE)
        {
            PlanningCtrl.RMouseDown( fMouseX*Root.GUIScale, fMouseY*Root.GUIScale);
        }
    }
}

function RMouseUp( FLOAT fMouseX, FLOAT fMouseY)
{
    local R6PlanningCtrl PlanningCtrl;

    super.RMouseUp(fMouseX,fMouseY);

    PlanningCtrl = R6PlanningCtrl(GetPlayerOwner());
    if(PlanningCtrl!=NONE)
    {
        PlanningCtrl.RMouseUp( fMouseX*Root.GUIScale, fMouseY*Root.GUIScale);
    }
}

function MouseMove( FLOAT fMouseX, FLOAT fMouseY)
{
    local R6PlanningCtrl PlanningCtrl;

    super.MouseMove(fMouseX,fMouseY);

    PlanningCtrl = R6PlanningCtrl(GetPlayerOwner());
    if(PlanningCtrl!=NONE)
    {
        PlanningCtrl.MouseMove( fMouseX*Root.GUIScale, fMouseY*Root.GUIScale);
    }
}
 
//-----------------------------------------------------------//
//                      Mouse functions                      //
//-----------------------------------------------------------//
function SetMousePos(FLOAT X, FLOAT Y)
{
    local FLOAT fMouseX;
    local FLOAT fMouseY;

    //limit the mouse move when dragging
    if(Root.m_bUseDragIcon == true)
    {
        fMouseX=X;
        fMouseY=Y;
        if(fMouseX < 22)
        {
            fMouseX = 22;
        }
        else if(fMouseX > 617)
        {
            fMouseX = 617;
        }

        if(fMouseY < 51)
        {
            fMouseY = 51;
        }
        else if(fMouseY > 363)
        {
            fMouseY = 363;
        }

        Root.Console.MouseX = fMouseX;
        Root.Console.MouseY = fMouseY;
    }
    else
    {
        Super.SetMousePos(X,Y);
    }
}


//-----------------------------------------------------------//
//                      External commands                    //
//-----------------------------------------------------------//
function KeyType(int iInputKey, float X, float Y)
{
    switch(iInputKey)
    {
    case R6InputKey_ActionPopup:    // Action Popup menu called
        DisplayActionTypePopUp(X, Y);
        return;
    case R6InputKey_PathFlagPopup:  // Path flat pop up
        DisplayPathFlagPopUp(X, Y);
        return;
    }
}

function DisplayActionTypePopUp(float X, float Y)
{
    local BOOL bDisplayUp;
    local BOOL bDisplayLeft;

    if(X / (m_Right.WinLeft - m_Left.WinWidth) > 0.5)
    {
        bDisplayLeft = true;
    }
    if(Y / (m_Bottom.WinTop - m_Top.WinHeight) > 0.5 )
    {
        bDisplayUp = true;
    }
    
    if(m_3DButton.m_bSelected == true)
    {
        Y = 200;
        bDisplayUp = false;
    }

    if(m_PopUpMenuPoint==None)
    {
        m_PopUpMenuPoint = R6MenuActionPointMenu(CreateWindow(Root.MenuClassDefines.ClassActionPointPupUpMenu, X, Y, 100.0, 100.0, self));
    }
    else
    {
        m_PopUpMenuPoint.WinLeft = X;
        m_PopUpMenuPoint.WinTop  = Y;
    }

    m_PopUpMenuPoint.AjustPosition(bDisplayUp, bDisplayLeft);
    R6MenuListActionTypeButton(m_PopUpMenuPoint.m_ButtonList).DisplayMilestoneButton();
    m_PopUpMenuPoint.ShowWindow();
    m_bPopUpMenuPoint=true;
}

function DisplayPathFlagPopUp(float X, float Y)
{
    local BOOL bDisplayUp;
    local BOOL bDisplayLeft;

    if(X / (m_Right.WinLeft - m_Left.WinWidth) > 0.5)
    {
        bDisplayLeft = true;
    }
    if(Y / (m_Bottom.WinTop - m_Top.WinHeight) > 0.5 )
    {
        bDisplayUp = true;
    }

    if(m_3DButton.m_bSelected == true)
    {
        Y = 200;
        bDisplayUp = false;
    }

    if(m_PopUpMenuMode==None)
    {
        m_PopUpMenuMode = R6MenuModeMenu(CreateWindow(Root.MenuClassDefines.ClassMovementModePupUpMenu, X, Y, 100.0, 100.0, self));
        m_PopUpMenuMode.AjustPosition(bDisplayUp, bDisplayLeft);
    }
    else
    {
        m_PopUpMenuMode.WinLeft = X;
        m_PopUpMenuMode.WinTop  = Y;
        m_PopUpMenuMode.AjustPosition(bDisplayUp, bDisplayLeft);
        m_PopUpMenuMode.ShowWindow();
    }
    m_bPopUpMenuSpeed=true;
}

function CloseAllPopup()
{
    if(bShowLog) log("Closing all Popups!");
    if((m_PopUpMenuPoint!=None) && (m_PopUpMenuPoint.bWindowVisible))
    {
        m_PopUpMenuPoint.HideWindow();
        m_bPopUpMenuPoint=false;

    }
    if((m_PopUpMenuMode!=None) && (m_PopUpMenuMode.bWindowVisible))
    {
        m_PopUpMenuMode.HideWindow();
        m_bPopUpMenuSpeed=false;
    }
}


// Ideally Key would be a EInputKey but I can't see that class here.
function WindowEvent(WinMessage Msg, Canvas C, float X, float Y, int Key) 
{
    local R6PlanningCtrl PlanningCtrl;


    if(R6MenuRootWindow(Root).m_ePopUpID != EPopUpID_None)
    {
        //Pop up want the inputs
        super.WindowEvent(Msg, C, X, Y, Key) ;
        return;
    }
    

    switch(Msg)
	{
	case WM_KeyDown:
        if(GetPlayerOwner().IsA('R6PlanningCtrl'))
        {
            PlanningCtrl = R6PlanningCtrl(GetPlayerOwner());
//          PlanningCtrl.KeyWasPressed(Key);
            CloseAllPopup();
        }
		break;	
	case WM_KeyUp:
        if(GetPlayerOwner().IsA('R6PlanningCtrl'))
        {
            PlanningCtrl = R6PlanningCtrl(GetPlayerOwner());
//            PlanningCtrl.KeyWasReleased(Key);
            CloseAllPopup();
        }
		break;	
	default:
        super.WindowEvent(Msg, C, X, Y, Key) ;
		break;
	}
}

defaultproperties
{
     m_fLabelHeight=18.000000
}
