//=============================================================================
//  R6ShadowProjector.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/01/21 * Created by Jean-Francois Dube
//=============================================================================
class R6ShadowProjector extends Projector;

// Joshua - A group package here breaks the texture paths with retail UCC
//#exec OBJ LOAD FILE=..\Textures\Inventory_t.utx PACKAGE=Inventory_t.Shadow
#exec OBJ LOAD FILE=..\Textures\Inventory_t.utx PACKAGE=Inventory_t

var     bool        m_bAttached;

function PostBeginPlay()
{
    local Rotator Dir;

    Dir.Pitch = -16384;
    Dir.Yaw = 0;
    Dir.Roll = 0;

    SetRotation(Dir);
}

event UpdateShadow()
{
    SetLocation(R6Pawn(Owner).GetBoneCoords('R6 Spine', true).Origin);
    AttachProjector();
    m_bAttached = true;
}

simulated function Tick(float DeltaTime)
{
    if(m_bAttached)
    {
        m_bAttached = false;
        DetachProjector(true);
    }
}

defaultproperties
{
     FrameBufferBlendingOp=PB_Modulate1X
     MaxTraceDistance=200
     bProjectStaticMesh=False
     bProjectParticles=False
     bProjectActor=False
     m_bDirectionalModulation=True
     m_bProjectTransparent=False
     bGradient=True
     bProjectOnParallelBSP=True
     ProjTexture=Texture'Inventory_t.Shadow.ShadowTexSimple'
     RemoteRole=ROLE_None
     bStatic=False
     DrawScale=1.500000
     CullDistance=1800.000000
}
