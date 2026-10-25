//=============================================================================
//  R6WindowFramedWindow.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/09 * Created by Chaouky Garram
//=============================================================================

class R6WindowFramedWindow extends UWindowWindow;


var class<UWindowWindow>    m_ClientClass;
var UWindowWindow           m_ClientArea;
var UWindowButton           m_CloseBoxButton;

var localized string        m_szWindowTitle;
var string                  m_szStatusBarText;
var FLOAT                   m_fMoveX, m_fMoveY;	// co-ordinates where the move was requested
var FLOAT                   m_fMinWinWidth, m_fMinWinHeight;
var FLOAT                   m_fTitleOffSet;
var TextAlign               m_TitleAlign;

var bool                    m_bTLSizing;
var bool                    m_bTSizing;
var bool                    m_bTRSizing;
var bool                    m_bLSizing;
var bool                    m_bRSizing;
var bool                    m_bBLSizing;
var bool                    m_bBSizing;
var bool                    m_bBRSizing;

var bool                    m_bMoving;
var bool                    m_bSizable;
var bool                    m_bMovable;

var bool                    m_bDisplayClose;

function Created()
{
	m_ClientArea = CreateWindow(m_ClientClass, LookAndFeel.FrameL.W, LookAndFeel.FrameT.H, WinWidth - (LookAndFeel.FrameL.W + LookAndFeel.FrameR.W), WinHeight - (LookAndFeel.FrameB.H + LookAndFeel.FrameT.H), OwnerWindow);
    if(m_bDisplayClose)
    {
	    m_CloseBoxButton = UWindowFrameCloseBox(CreateWindow(class'UWindowFrameCloseBox', WinWidth-LookAndFeel.FrameTL.W-R6WindowLookAndFeel(LookAndFeel).m_CloseBoxUp.W-1, 1, R6WindowLookAndFeel(LookAndFeel).m_CloseBoxUp.W, R6WindowLookAndFeel(LookAndFeel).m_CloseBoxUp.H, self));
    }
}

function Texture GetLookAndFeelTexture()
{
	return R6WindowLookAndFeel(LookAndFeel).R6GetTexture(self);
}

function bool IsActive()
{
	return ParentWindow.ActiveWindow == self;
}

function BeforePaint(Canvas C, FLOAT X, FLOAT Y)
{	
    local FLOAT W, H;

    Super.BeforePaint(C, X, Y);

    if(m_bSizable)
    {
	    Resized();
    }
    if(m_CloseBoxButton != NONE)
    {
	    R6WindowLookAndFeel(LookAndFeel).R6FW_SetupFrameButtons(self, C);
    }
	
    if(m_szWindowTitle != "")
    {
        C.Font = Root.Fonts[F_PopUpTitle];
    	TextSize(C, m_szWindowTitle, W, H);
        
	    switch(m_TitleAlign)
	    {
	    case TA_Left:
		    m_fTitleOffSet = LookAndFeel.FrameTL.W;
		    break;
	    case TA_Right:
		    m_fTitleOffSet = WinWidth - W - LookAndFeel.FrameTL.W;
		    break;
	    case TA_Center:
		    m_fTitleOffSet = (WinWidth - W) / 2;
		    break;
	    }
    }
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
	R6WindowLookAndFeel(LookAndFeel).R6FW_DrawWindowFrame(self, C);
}

function LMouseDown(FLOAT X, FLOAT Y)
{
    local FrameHitTest H;
    Super.LMouseDown(X, Y);

    H = R6WindowLookAndFeel(LookAndFeel).R6FW_HitTest(self, X, Y);

    if(m_bMovable)
    {
	    if(H == HT_TitleBar)
	    {
		    m_fMoveX = X;
		    m_fMoveY = Y;
		    m_bMoving = true;
		    Root.CaptureMouse();

		    return;
	    }
    }

	if(m_bSizable) 
	{
		switch(H)
		{
		case HT_NW:
			m_bTLSizing = true;
			Root.CaptureMouse();
			return;
		case HT_NE:
			m_bTRSizing = true;
			Root.CaptureMouse();
			return;
		case HT_SW:
			m_bBLSizing = true;
			Root.CaptureMouse();
			return;		
		case HT_SE:
			m_bBRSizing = true;
			Root.CaptureMouse();
			return;
		case HT_N:
			m_bTSizing = true;
			Root.CaptureMouse();
			return;
		case HT_S:
			m_bBSizing = true;
			Root.CaptureMouse();
			return;
		case HT_W:
			m_bLSizing = true;
			Root.CaptureMouse();
			return;
		case HT_E:
			m_bRSizing = true;
			Root.CaptureMouse();
			return;
		}
	}
}

function Resized()
{
	local Region R;

	if(m_ClientArea == None)
	{
		//Log("Client Area is None for "$self);
		return;
	}

	R = R6WindowLookAndFeel(LookAndFeel).R6FW_GetClientArea(self);

	m_ClientArea.WinLeft = R.X;
	m_ClientArea.WinTop = R.Y;

	if((R.W != m_ClientArea.WinWidth) || (R.H != m_ClientArea.WinHeight)) 
	{
		m_ClientArea.SetSize(R.W, R.H);
	}

}

function MouseMove(FLOAT X, FLOAT Y)
{
    local FLOAT fOldW, fOldH;
    local FrameHitTest H;

    H = R6WindowLookAndFeel(LookAndFeel).R6FW_HitTest(self, X, Y);

    if(m_bMovable)
    {
	    if(m_bMoving && bMouseDown)
	    {
		    WinLeft = Int(WinLeft + X - m_fMoveX);
		    WinTop = Int(WinTop + Y - m_fMoveY);
	    }
	    else
        {
		    m_bMoving = false;
        }
    }

	Cursor = Root.NormalCursor;

	if(m_bSizable && !m_bMoving)
	{
		switch(H)
		{
		case HT_NW:
		case HT_SE:
			Cursor = Root.DiagCursor1;
			break;
		case HT_NE:
		case HT_SW:
			Cursor = Root.DiagCursor2;
			break;
		case HT_W:
		case HT_E:
			Cursor = Root.WECursor;
			break;
		case HT_N:
		case HT_S:
			Cursor = Root.NSCursor;
			break;
		}
	}	

    if(bMouseDown)
    {
	    // Top Left
	    if(m_bTLSizing)
	    {
		    Cursor = Root.DiagCursor1;	
		    fOldW = WinWidth;
		    fOldH = WinHeight;
		    SetSize(Max(m_fMinWinWidth, WinWidth - X), Max(m_fMinWinHeight, WinHeight - Y));
		    WinLeft = Int(WinLeft + fOldW - WinWidth);
		    WinTop = Int(WinTop + fOldH - WinHeight);
	    }

	    // Top
	    if(m_bTSizing)
	    {
		    Cursor = Root.NSCursor;
		    fOldH = WinHeight;
		    SetSize(WinWidth, Max(m_fMinWinHeight, WinHeight - Y));
		    WinTop = Int(WinTop + fOldH - WinHeight);
	    }

	    // Top Right
	    if(m_bTRSizing)
	    {
		    Cursor = Root.DiagCursor2;
		    fOldH = WinHeight;
		    SetSize(Max(m_fMinWinWidth, X), Max(m_fMinWinHeight, WinHeight - Y));
		    WinTop = Int(WinTop + fOldH - WinHeight);
	    }

	    // Left
	    if(m_bLSizing)
	    {
		    Cursor = Root.WECursor;
		    fOldW = WinWidth;
		    SetSize(Max(m_fMinWinWidth, WinWidth - X), WinHeight);
		    WinLeft = Int(WinLeft + fOldW - WinWidth);
	    }

	    // Right
	    if(m_bRSizing)
	    {
		    Cursor = Root.WECursor;
		    SetSize(Max(m_fMinWinWidth, X), WinHeight);
	    }

	    // Bottom Left
	    if(m_bBLSizing)
	    {
		    Cursor = Root.DiagCursor2;
		    fOldW = WinWidth;
		    SetSize(Max(m_fMinWinWidth, WinWidth - X), Max(m_fMinWinHeight, Y));
		    WinLeft = Int(WinLeft + fOldW - WinWidth);
	    }

	    // Bottom
	    if(m_bBSizing)
	    {
		    Cursor = Root.NSCursor;
		    SetSize(WinWidth, Max(m_fMinWinHeight, Y));
	    }

	    // Bottom Right
	    if(m_bBRSizing)
	    {
		    Cursor = Root.DiagCursor1;
		    SetSize(Max(m_fMinWinWidth, X), Max(m_fMinWinHeight, Y));
	    }
    }
	else 
    {
        m_bTLSizing = false;
        m_bTSizing  = false;
        m_bTRSizing = false;
        m_bLSizing  = false;
        m_bRSizing  = false;
        m_bBLSizing = false;
        m_bBSizing  = false;
        m_bBRSizing = false;
    }
}

function ToolTip(string strTip)
{
	m_szStatusBarText = strTip;
}

function WindowEvent(WinMessage Msg, Canvas C, FLOAT X, FLOAT Y, INT iKey) 
{
    /*
	if(Msg == WM_Paint || !WaitModal())
    {
		Super.WindowEvent(Msg, C, X, Y, iKey);
    }
    */
    if(Msg == WM_Paint || !WaitModal())
    {
        Super.WindowEvent(Msg, C, X, Y, iKey);
    }	    
    else if(WaitModal())
    {
         ModalWindow.WindowEvent(Msg, C, X - ModalWindow.WinLeft, Y - ModalWindow.WinTop, iKey);        
    }  
}

function WindowHidden()
{
	Super.WindowHidden();
	LookAndFeel.PlayMenuSound(self, MS_WindowClose);
}

function SetDisplayClose(bool bNewDisplay)
{
	m_bDisplayClose = bNewDisplay;

	if(m_bDisplayClose)
	{	
        if(m_CloseBoxButton == NONE)
        {
    	    m_CloseBoxButton = UWindowFrameCloseBox(CreateWindow(class'UWindowFrameCloseBox', WinWidth-LookAndFeel.FrameTL.W-R6WindowLookAndFeel(LookAndFeel).m_CloseBoxUp.W-1, 1, R6WindowLookAndFeel(LookAndFeel).m_CloseBoxUp.W, R6WindowLookAndFeel(LookAndFeel).m_CloseBoxUp.H, self));
            m_CloseBoxButton.ShowWindow();
        }
	}
	else
	{
        if(m_CloseBoxButton != NONE)
        {
    	    m_CloseBoxButton.Close();
        }
	}
}

defaultproperties
{
     m_bDisplayClose=True
     m_fMinWinWidth=20.000000
     m_fMinWinHeight=20.000000
     m_ClientClass=Class'UWindow.UWindowClientWindow'
}
