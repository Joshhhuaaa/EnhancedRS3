//=============================================================================
//  R6CircleDotReticule.uc : Circular reticule with a dot
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/08/27 * Eric Begin				- Creation
//=============================================================================
class R6CircleDotReticule extends R6CircleReticule;

#exec OBJ LOAD FILE=..\textures\R6TexturesReticule.utx PACKAGE=R6TexturesReticule

var (Textures) texture m_Dot;

simulated function PostRender( canvas C)
{
    local FLOAT fScale;

    Super.PostRender(C);

    C.Style = ERenderStyle.STY_Alpha;
    
    fScale = 16 / m_Dot.VSize * m_fZoomScale;
    C.SetPos(m_fReticuleOffsetX - (m_Dot.USize * fScale *0.5), m_fReticuleOffsetY - (m_Dot.VSize * fScale*0.5));
    C.DrawIcon(m_Dot, fScale);
}

defaultproperties
{
     m_Dot=Texture'R6TexturesReticule.Dot'
}
