//=============================================================================
//  R6CircleDotReticule.uc : Circular reticule with a dot
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/27 * Eric Begin				- Creation
//=============================================================================
class R6CircleDotLineReticule extends R6CircleDotReticule;

#exec OBJ LOAD FILE=..\textures\R6TexturesReticule.utx PACKAGE=R6TexturesReticule

// Speed gives us the current speed.
simulated function PostRender( canvas C)
{
    Super.PostRender(C);

    C.Style = ERenderStyle.STY_Alpha;
    C.SetPos(m_fReticuleOffsetX - 1.0, m_fReticuleOffsetY + 1.0);
	C.DrawRect(m_LineTexture, c_iLineWidth * m_fZoomScale, c_iLineHeight * m_fZoomScale);
}

defaultproperties
{
}
