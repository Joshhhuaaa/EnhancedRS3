//=============================================================================
//  R6TacticalGlowLight.uc : Fading light depending on the view angle.
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/04/03 * Created by Jean-Francois Dube
//    2001/11/02 * Added net support (Aristo Kolokathis)
//=============================================================================
class R6TacticalGlowLight extends R6GlowLight;

// Joshua - A group package here breaks the texture paths with retail UCC
//#exec OBJ LOAD FILE="..\textures\Inventory_t.utx" Package="Inventory_t.TacticalLight"
#exec OBJ LOAD FILE="..\textures\Inventory_t.utx" Package="Inventory_t"

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
     LightEffect=LE_Spotlight
     LightHue=255
     LightCone=20
     bNoDelete=False
     bDynamicLight=True
     bCanTeleport=True
     bAlwaysRelevant=True
     m_bDrawFromBase=True
     bMovable=True
     LightBrightness=255.000000
     LightRadius=96.000000
     bCoronaMUL2XFactor=1.000000
     Texture=None
     Skins(0)=Texture'R6SFX_T.Flare.Tactical_Flare'
}
