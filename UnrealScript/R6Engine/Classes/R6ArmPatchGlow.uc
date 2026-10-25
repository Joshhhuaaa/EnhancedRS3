//=============================================================================
//  R6ArmPatchGlow.uc : 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/02/12 * Created by Jean-Francois Dube
//=============================================================================
class R6ArmPatchGlow extends R6GlowLight;

// Joshua - A group package here breaks the texture paths with retail UCC
//#exec OBJ LOAD FILE="..\textures\Inventory_t.utx" Package="Inventory_t.ArmPatches"
#exec OBJ LOAD FILE="..\textures\Inventory_t.utx" Package="Inventory_t"

var     name                m_AttachedBoneName;
var     float               m_fMatrixMul;

function Tick(float fDeltaTime)
{
    local Pawn OwnerPawn;
    local Pawn ViewPawn;
    local PlayerController ViewActor;
    local coords TempCoord;
    local vector Temp;
    local rotator TempRot;

    bCorona = false;
    bHidden = true;

    if(Level.m_bNightVisionActive == false)
        return;

    ViewActor = GetCanvas().Viewport.Actor;
    if(ViewActor == none)
        return;

    OwnerPawn = Pawn(m_pOwnerNightVision);
    ViewPawn = ViewActor.Pawn;
    if((ViewPawn != none) && (OwnerPawn.m_iTeam == ViewPawn.m_iTeam))
    {
        TempCoord = OwnerPawn.GetBoneCoords(m_AttachedBoneName, true);
        Temp = TempCoord.Origin;

        Temp += TempCoord.XAxis * 14.0;
        Temp -= TempCoord.YAxis * 2.0;
        Temp += TempCoord.ZAxis * 8.0 * m_fMatrixMul;

        SetLocation(Temp);
        TempRot = OrthoRotation(TempCoord.ZAxis*m_fMatrixMul, TempCoord.YAxis*m_fMatrixMul, TempCoord.XAxis*m_fMatrixMul);
        SetRotation(TempRot);
        bCorona = true;
        bHidden = false;
    }
}

defaultproperties
{
     m_fMatrixMul=1.000000
     m_AttachedBoneName="'"
     m_bInverseScale=True
     RemoteRole=ROLE_None
     LightHue=255
     bNoDelete=False
     bCanTeleport=True
     bMovable=True
     DrawScale=0.600000
     LightBrightness=255.000000
     LightRadius=96.000000
     Texture=None
     Skins(0)=Texture'Inventory_t.ArmPatches.ArmPatchFlare'
}
