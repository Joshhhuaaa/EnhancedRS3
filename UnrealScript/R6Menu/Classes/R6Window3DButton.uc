//=============================================================================
//  R6Window3DButton.uc : Window under the 3D view for planning, has to be a button
//                          to be able to click on it
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/27/04 * Created by Joel Tremblay
//=============================================================================

class R6Window3DButton extends UWindowButton;

#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning

var INT		m_iDrawStyle;
var BOOL    m_bDisplayWindow;
var BOOL    m_bLMouseDown;
var color   m_cButtonColor;

function Created()
{	
    m_cButtonColor = Root.Colors.GrayLight;
    ToolTipString = Localize("PlanningMenu","3DWindow","R6Menu");
}

function BeforePaint(Canvas C, FLOAT X, FLOAT Y)
{
//	Super.BeforePaint(C, X, Y);
}


function Paint(Canvas C, float X, float Y)
{
	local float tempSpace;
    local Color vBorderColor;
	
	C.Style = m_iDrawStyle;
    C.SetDrawColor(m_cButtonColor.R,m_cButtonColor.G,m_cButtonColor.B);

	if(UpTexture != None)
	{
        DrawStretchedTextureSegment( C, ImageX, ImageY, WinWidth, WinHeight, 
							        UpRegion.X, UpRegion.Y, 
							        UpRegion.W, UpRegion.H, UpTexture );
	}
}

function MouseLeave()
{
    if(m_bLMouseDown == true)
    {
        //Mouse is moving too fast, it leaved the window, reset the 3D view
        m_bLMouseDown = false;
        R6PlanningCtrl(GetPlayerOwner()).TurnOff3DMove();
    }
    Super.MouseLeave();
    
    m_cButtonColor = Root.Colors.GrayLight;
}

function MouseEnter()
{
    Super.MouseEnter();
    m_cButtonColor = Root.Colors.BlueLight;
}

function MouseMove(FLOAT X, FLOAT Y)
{
    if(m_bLMouseDown == true)
    {
        R6PlanningCtrl(GetPlayerOwner()).Ajust3DRotation(WinLeft + X, WinTop + Y);
        //Reset mouse position 
        R6MenuRootWindow(Root).m_CurrentWidget.SetMousePos(WinLeft + WinWidth*0.5f, WinTop + WinHeight*0.5f);
    }
}

function LMouseDown(float X, float Y) 
{
    m_bLMouseDown = true;
    R6MenuRootWindow(Root).m_CurrentWidget.SetMousePos(WinLeft + WinWidth*0.5f, WinTop + WinHeight*0.5f);
    R6PlanningCtrl(GetPlayerOwner()).TurnOn3DMove(WinLeft + WinWidth*0.5f, WinTop + WinHeight*0.5f);
}

function LMouseUp(float X, float Y)
{
    m_bLMouseDown = false;
    R6PlanningCtrl(GetPlayerOwner()).TurnOff3DMove();
}

function Toggle3DWindow()
{
    m_bDisplayWindow = !m_bDisplayWindow;
    if(m_bDisplayWindow == true)
    {
        ShowWindow();
    }
    else
    {
        HideWindow();
    }
}

function Close3DWindow()
{
    m_bDisplayWindow = false;
    HideWindow();
}

function SetButtonColor( Color cButtonColor)
{
    m_cButtonColor = cButtonColor;
}

defaultproperties
{
     m_iDrawStyle=1
     m_cButtonColor=(B=255,G=255,R=255)
     UpTexture=Texture'R6Planning.Icons.PlanIcon_White'
}
