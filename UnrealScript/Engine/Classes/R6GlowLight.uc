//=============================================================================
//  R6GlowLight.uc : Fading light depending on the view angle.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/01 * Created by Jean-Francois Dube
//    2001/10/30 * Added fading with distance (jfd)
//=============================================================================
class R6GlowLight extends Light
    native;

var(R6Glow)     FLOAT               m_fAngle;
var(R6Glow)     FLOAT               m_fFadeValue;
var(R6Glow)     BOOL                m_bFadeWithDistance;
var(R6Glow)     BOOL                m_bInverseScale;
var(R6Glow)     FLOAT               m_fDistanceValue;
var             Actor               m_pOwnerNightVision;

defaultproperties
{
     m_fAngle=90.000000
     m_fFadeValue=3.000000
     m_fDistanceValue=1000.000000
     LightType=LT_None
     bStatic=False
     bCorona=True
     bDirectional=True
}
