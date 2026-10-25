//=============================================================================
//  R6DotReticule.uc : Basic Dot reticule
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/12/18 * Rima Brek				- Creation
//=============================================================================
class R6DotReticule extends R6Reticule;

#exec OBJ LOAD FILE=..\textures\R6TexturesReticule.utx PACKAGE=R6TexturesReticule

var (Textures) texture m_Dot;

simulated function PostRender( canvas C)
{
    local INT X;
    local INT Y;
    local FLOAT fScale;

    C.UseVirtualSize(true, 640, 480);
    
	SetReticuleInfo(C);

    X = 320;
    Y = 240;

    C.Style = ERenderStyle.STY_Alpha;
	
    fScale = 16 / m_Dot.VSize * m_fZoomScale;
    C.SetPos(X - (m_Dot.USize * fScale /2) + 1, Y - (m_Dot.VSize * fScale/2) + 1);
    C.DrawIcon(m_Dot, fScale);

    C.UseVirtualSize(false);
}

defaultproperties
{
     m_Dot=Texture'R6TexturesReticule.Dot'
}
