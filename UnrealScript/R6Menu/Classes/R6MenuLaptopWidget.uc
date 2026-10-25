//=============================================================================
//  R6MenuLaptopWidget.uc : Class to be derived in order to get the laptop borders
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/12 * Created by Alexandre Dionne
//=============================================================================
class R6MenuLaptopWidget extends R6MenuWidget;


var R6MenuNavigationBar         m_NavBar;
var R6MenuHelpTextFrameBar      m_HelpTextBar;
var R6MenuSimpleWindow          m_EmptyBox1;
var R6MenuSimpleWindow          m_EmptyBox2;
var UWindowWindow m_Right;
var UWindowWindow m_Left;
var UWindowWindow m_Bottom;
var UWindowWindow m_Top;
var float m_fLaptopPadding;
var Texture                     m_TBackGround;
var Region                      m_RBackGround;


function Created()
{
	local R6MenuRSLookAndFeel LAF;    
	local Region R;
	
	LAF = R6MenuRSLookAndFeel(OwnerWindow.LookAndFeel);

    // Create LapTop Frame
	
    m_Left = CreateWindow(class'UWindowWindow',0, LAF.m_stLapTopFrame.T.H, LAF.m_stLapTopFrame.L.W, LAF.m_stLapTopFrame.L.H + LAF.m_stLapTopFrame.L2.H + LAF.m_stLapTopFrame.L3.H + LAF.m_stLapTopFrame.L4.H, self);
    m_Right = CreateWindow(class'UWindowWindow',LAF.m_stLapTopFrame.BL.W + LAF.m_stLapTopFrame.B.W + LAF.m_stLapTopFrame.BR.W- LAF.m_stLapTopFrame.R.W, LAF.m_stLapTopFrame.T.H, LAF.m_stLapTopFrame.R.W, LAF.m_stLapTopFrame.R.H + LAF.m_stLapTopFrame.R2.H + LAF.m_stLapTopFrame.R3.H + LAF.m_stLapTopFrame.R4.H, self);	
    m_Bottom = CreateWindow(class'UWindowWindow',0, LAF.m_stLapTopFrame.T.H + LAF.m_stLapTopFrame.L.H + LAF.m_stLapTopFrame.L2.H + LAF.m_stLapTopFrame.L3.H + LAF.m_stLapTopFrame.L4.H, LAF.m_stLapTopFrame.BL.W + LAF.m_stLapTopFrame.B.W + LAF.m_stLapTopFrame.BR.W, LAF.m_stLapTopFrame.B.H, self);
	m_Top = CreateWindow(class'UWindowWindow', 0,0,LAF.m_stLapTopFrame.BL.W + LAF.m_stLapTopFrame.B.W + LAF.m_stLapTopFrame.BR.W, LAF.m_stLapTopFrame.T.H, self);

    m_Left.HideWindow();
    m_Right.HideWindow();
    m_Bottom.HideWindow();
    m_Top.HideWindow();
    
	// Create Navigation Bar
    R.H = 33;                                          //LAF.m_NavBarBack[0].H + 4;
    R.X = LAF.m_stLapTopFrame.L.W + 2;
    R.Y = m_Bottom.WinTop - R.H - m_fLaptopPadding;    //480 - LAF.m_stLapTopFrame.B.H - 4 - LAF.m_NavBarBack[0].H;
    R.W = 640 - (2*R.X);    
    m_NavBar   = R6MenuNavigationBar(CreateWindow(class'R6MenuNavigationBar', R.X, R.Y, R.W, R.H, self));

    // Create two fake box near (each side of the text bar)
	R.H = 16;
	R.Y = m_NavBar.WinTop - R.H - m_fLaptopPadding;        	
    R.X = m_NavBar.WinLeft;
    R.W = 35;
    
    // draw the two box each side of the main frame box
    m_EmptyBox1 = R6MenuSimpleWindow(CreateWindow(class'R6MenuSimpleWindow', R.X, R.Y, R.W, R.H, self));
    m_EmptyBox1.m_BorderColor = Root.Colors.BlueLight;
    R.X = m_NavBar.WinLeft + m_NavBar.WinWidth - R.W;
    m_EmptyBox2 = R6MenuSimpleWindow(CreateWindow(class'R6MenuSimpleWindow', R.X, R.Y, R.W, R.H, self));
    m_EmptyBox2.m_BorderColor = Root.Colors.BlueLight;

    // Create Help Text Bar
	R.H = 16;
	R.Y = m_NavBar.WinTop - R.H - m_fLaptopPadding;        	
    R.X = m_NavBar.WinLeft + R.W + 2; //2 pixels after the first box
    R.W = m_NavBar.WinWidth - (2*R.W) - 4; //4 is 2 pixels * 2 case (one box left and one box right)

	m_HelpTextBar = R6MenuHelpTextFrameBar(CreateWindow(class'R6MenuHelpTextFrameBar', R.X, R.Y, R.W, R.H, self));

	m_fRightMouseXClipping = m_Right.WinLeft;
	m_fRightMouseYClipping = m_Bottom.WinTop;

}

//-----------------------------------------------------------//
//                      Mouse functions                      //
//-----------------------------------------------------------//
function SetMousePos(FLOAT X, FLOAT Y)
{
    local FLOAT fMouseX;
    local FLOAT fMouseY;
    
    fMouseX=X;
    fMouseY=Y;
    if(fMouseX < m_Left.WinWidth)
    {
        fMouseX = m_Left.WinWidth;
    }
    else if(fMouseX > m_Right.WinLeft)
    {
        fMouseX = m_Right.WinLeft;
    }

    if(fMouseY < m_Top.WinHeight)
    {
        fMouseY = m_Top.WinHeight;
    }
    else if(fMouseY > m_Bottom.WinTop)
    {
        fMouseY = m_Bottom.WinTop;
    }

    Root.Console.MouseX = fMouseX;
    Root.Console.MouseY = fMouseY;
}

function Paint(Canvas C, FLOAT X, FLOAT Y)
{
    //Draw BackGround
    C.Style=1;
    DrawStretchedTextureSegment( C, 0, 0, WinWidth, WinHeight, 0, 0, WinWidth, WinHeight, m_TBackGround );    

    DrawLaptopFrame( C );
    
}

function DrawLaptopFrame(Canvas C)
{
    C.Style = ERenderStyle.STY_Alpha;

    DrawStretchedTextureSegment( C, 0, 0, 256, 480, 0, 0, 256, 480, Texture'R6MenuTextures.Gui_00L' );
    DrawStretchedTextureSegment( C, 256, 0, 128, 480, 0, 0, 128, 480, Texture'R6MenuTextures.Gui_00C_a00' );
    DrawStretchedTextureSegment( C, 384, 0, 256, 480, 0, 0, 256, 480, Texture'R6MenuTextures.Gui_00R' );
}

defaultproperties
{
     m_fLaptopPadding=2.000000
     m_TBackGround=Texture'R6MenuTextures.LaptopTileBG'
     m_RBackGround=(X=232,Y=172,W=22,H=22)
}
