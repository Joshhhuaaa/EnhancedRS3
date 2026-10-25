//=============================================================================
//  R6MenuCarreerOperative.uc : In debriefing room the little control bottom right with face
//                              of the operative and his carreer stats
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/08/02 * Created by Alexandre Dionne
//=============================================================================


class R6MenuCarreerOperative extends UWindowWindow;

var R6WindowBitmap   m_OperativeFace;

//Borders Region
var Region RTopRight, RMidRight, RTopLeft, RMidLeft;
var FLOAT m_fXPos, m_fXFacePos, m_fYFacePos, m_fTileHeight;

function Created()
{

    m_fXPos = (WinWidth - RTopLeft.W - RTopRight.W) / 2;
    m_OperativeFace = R6WindowBitMap(CreateWindow(class'R6WindowBitMap',m_fXPos+m_fXFacePos,m_fYFacePos,WinWidth - m_fXPos - m_fXFacePos,WinHeight - (2*m_fYFacePos),self));
    m_OperativeFace.m_iDrawStyle = 5;
    m_BorderColor = Root.Colors.Yellow;    
    m_fTileHeight = WinHeight - RTopLeft.H - RTopLeft.H;
}

function AfterPaint(Canvas C, FLOAT X, FLOAT Y)
{
    local INT i, j;

    C.Style = ERenderStyle.STY_Alpha;
    C.SetDrawColor(m_BorderColor.R, m_BorderColor.G, m_BorderColor.B, m_BorderColor.A);

    //Top Border
    DrawStretchedTextureSegment(C, m_fXPos, 0, RTopLeft.W, RTopLeft.H, RTopLeft.X, RTopLeft.Y, RTopLeft.W, RTopLeft.H, m_BorderTexture);
    DrawStretchedTextureSegment(C, m_fXPos + RTopLeft.W, 0, RTopRight.W, RTopRight.H, RTopRight.X, RTopRight.Y, RTopRight.W, RTopRight.H, m_BorderTexture);

    i=0;
    while( i +  RMidLeft.H < m_fTileHeight)
    {
        DrawStretchedTextureSegment(C, m_fXPos, RTopLeft.H + i, RMidLeft.W, RMidLeft.H, RMidLeft.X, RMidLeft.Y, RMidLeft.W, RMidLeft.H, m_BorderTexture);
        DrawStretchedTextureSegment(C, m_fXPos + RMidLeft.W, RTopLeft.H + i, RMidRight.W, RMidRight.H, RMidRight.X, RMidRight.Y, RMidRight.W, RMidRight.H, m_BorderTexture);

        i += RMidLeft.H;
    }

    j = m_fTileHeight - i;

    //Left overs ;)
    if(j > 0)
    {
         DrawStretchedTextureSegment(C, m_fXPos, RTopLeft.H + i, RMidLeft.W, j, RMidLeft.X, RMidLeft.Y, RMidLeft.W, j, m_BorderTexture);
         DrawStretchedTextureSegment(C, m_fXPos + RMidLeft.W, RTopLeft.H + i, RMidRight.W, j, RMidRight.X, RMidRight.Y, RMidRight.W, j, m_BorderTexture);

    }

    //Bottom Border
    DrawStretchedTextureSegment(C, m_fXPos, WinHeight - RTopLeft.H, RTopLeft.W, RTopLeft.H, RTopLeft.X, RTopLeft.Y + RTopLeft.H, RTopLeft.W, -RTopLeft.H, m_BorderTexture);
    DrawStretchedTextureSegment(C, m_fXPos + RTopLeft.W, WinHeight - RTopRight.H, RTopRight.W, RTopRight.H, RTopRight.X, RTopRight.Y + RTopRight.H, RTopRight.W, -RTopRight.H, m_BorderTexture);
    
    
    
}

function SetFace(Texture _OperativeFace, Region _FaceRegion)
{
    m_OperativeFace.T = _OperativeFace;
    m_OperativeFace.R = _FaceRegion;
}

function SetTeam(int _team)
{
    m_BorderColor = Root.Colors.TeamColor[_team];
}

defaultproperties
{
     m_fXFacePos=2.000000
     m_fYFacePos=2.000000
     RTopRight=(Y=89,W=170,H=3)
     RMidRight=(Y=92,W=170,H=2)
     RTopLeft=(Y=95,W=123,H=3)
     RMidLeft=(Y=98,W=123,H=2)
     m_BorderTexture=Texture'R6MenuTextures.Gui_BoxScroll'
}
