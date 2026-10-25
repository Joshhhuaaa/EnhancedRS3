//=============================================================================
//  R6GrenadeReticule.uc : Grenade reticule
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/06 * Eric Begin				- Creation
//=============================================================================
class R6GrenadeReticule extends R6Reticule;

#exec OBJ LOAD FILE=..\textures\R6TexturesReticule.utx PACKAGE=R6TexturesReticule

var (Textures) texture m_Circle;
var (Textures) texture m_Dot;


// Speed gives us the current speed.
simulated function PostRender( canvas C)
{
	// Draw in the middle of the screen

    local INT X;
    local INT Y;
    local FLOAT fScale;
    
    C.UseVirtualSize(true, 640, 480);

	SetReticuleInfo(C);

    X = C.HalfClipX;
    Y = C.HalfClipY;

    C.Style = ERenderStyle.STY_Alpha;
	// Circle
   fScale = 64 / m_Circle.VSize * m_fZoomScale;
    C.SetPos(X - (m_Circle.USize * fScale /2) + 1, Y - (m_Circle.VSize * fScale/2) + 1);
    C.DrawIcon(m_Circle, fScale);

/*
    // Inner Circle
    fScale = 32 / m_Circle.VSize * m_fZoomScale;

    C.SetPos(X - (m_Circle.USize * fScale /2) + 1, Y - (m_Circle.VSize * fScale/2) + 1);
    C.DrawIcon(m_Circle, fScale);
*/
    // Dot
    fScale = 16 / m_Dot.VSize * m_fZoomScale;
    C.SetPos(X - (m_Dot.USize * fScale /2) + 1, Y - (m_Dot.VSize * fScale/2) + 1);
    C.DrawIcon(m_Dot, fScale);
}

defaultproperties
{
     m_Circle=Texture'R6TexturesReticule.Small_Cercle'
     m_Dot=Texture'R6TexturesReticule.Dot'
}
