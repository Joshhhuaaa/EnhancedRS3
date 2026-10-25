//=============================================================================
//  R6CircleReticule.uc : Simple circular reticule
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/27 * Eric Begin				- Creation
//=============================================================================
class R6WReticule extends R6CrossReticule;

#exec OBJ LOAD FILE=..\textures\R6TexturesReticule.utx PACKAGE=R6TexturesReticule

var (Textures) texture m_FixedPart;
var (Temp) FLOAT m_fBaseReticuleHeight; // This is the size that we want the texture has when we are at the best accuracy

// Speed gives us the current speed.
simulated function PostRender( canvas C)
{
	// Draw in the middle of the screen

	local FLOAT X;
	local FLOAT Y;
    local FLOAT fScale;

    Super.PostRender(C);

    fScale = 32/m_FixedPart.VSize * m_fZoomScale;

	X = m_fReticuleOffsetX - m_FixedPart.USize/2 * fScale;
	Y = m_fReticuleOffsetY;

	// Circle
    C.Style = ERenderStyle.STY_Alpha;
	C.SetPos(X, Y + 1);
	C.DrawIcon(m_FixedPart, fScale);
}

defaultproperties
{
     m_fBaseReticuleHeight=5.000000
     m_FixedPart=Texture'R6TexturesReticule.Machine_Gun'
}
