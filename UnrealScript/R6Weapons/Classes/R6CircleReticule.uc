//=============================================================================
//  R6CircleReticule.uc : Simple circular reticule
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/27 * Eric Begin				- Creation
//=============================================================================
class R6CircleReticule extends R6CrossReticule;

#exec OBJ LOAD FILE=..\textures\R6TexturesReticule.utx PACKAGE=R6TexturesReticule

var (Textures) texture m_Circle;
var (Temp) FLOAT m_fBaseReticuleHeight; // This is the size that we want the texture has when we are at the best accuracy

// Speed gives us the current speed.
simulated function PostRender( canvas C)
{
	// Draw in the middle of the screen

	local FLOAT X;
	local FLOAT Y;
    local FLOAT fScale;

    Super.PostRender(C);

    fScale = 64/m_Circle.VSize * m_fZoomScale;

	X = m_fReticuleOffsetX - m_Circle.USize*0.5 * fScale;
	Y = m_fReticuleOffsetY - m_Circle.VSize*0.5 * fScale;

	// Circle
    C.Style = ERenderStyle.STY_Alpha;
	C.SetPos(X, Y);
	C.DrawIcon(m_Circle, fScale);
}

defaultproperties
{
     m_fBaseReticuleHeight=5.000000
     m_Circle=Texture'R6TexturesReticule.Small_Cercle'
}
