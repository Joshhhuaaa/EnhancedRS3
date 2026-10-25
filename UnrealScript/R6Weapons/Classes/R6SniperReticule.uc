//=============================================================================
//  R6SniperReticule.uc : Reticle for sniper rifle
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/11/30 * Joel Tremblay				- Creation
//=============================================================================
class R6SniperReticule extends R6CrossReticule;

#exec OBJ LOAD FILE=..\textures\R6TexturesReticule.utx PACKAGE=R6TexturesReticule

var (Textures) texture m_FixedPart;

// Speed gives us the current speed.
simulated function PostRender( canvas C)
{
	// Draw in the middle of the screen

	local FLOAT X;
	local FLOAT Y;
    local FLOAT fScale;

    Super.PostRender(C);

    fScale = C.ClipX/256;

	X = m_fReticuleOffsetX * 0.25;
	Y = m_fReticuleOffsetY * 0.5 - X;

    C.Style = ERenderStyle.STY_Alpha;
    C.SetPos(X, Y);
	C.DrawIcon(m_FixedPart, fScale);
}

defaultproperties
{
     m_FixedPart=Texture'R6TexturesReticule.SniperReticule'
}
