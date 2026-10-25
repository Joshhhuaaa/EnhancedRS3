//============================================================================//
// Class            R6BreakableGlass_70x68
// Created By       Carl Lavoie
// Date             12/19/2001
// Description      Breakable glass material default properties
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6BreakableGlass_70x68 extends R6SFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=MeshEmitter Name=MeshEmitterB70x68Glass1
         StaticMesh=StaticMesh'R6SFX_SM.Glass.Glass_Piece'
         UseRotationFrom=PTRS_Actor
         MaxParticles=20
         UseCollision=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=1.000000
         InitialParticlesPerSecond=1000.000000
         Acceleration=(Z=-1000.000000)
         ExtentMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
         DampingFactorRange=(X=(Min=0.700000,Max=0.700000),Y=(Min=0.700000,Max=0.700000),Z=(Min=0.300000,Max=0.300000))
         StartLocationRange=(Y=(Min=-35.000000,Max=35.000000),Z=(Min=-34.000000,Max=34.000000))
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Max=16.000000),Y=(Max=16.000000))
         StartVelocityRange=(X=(Min=-500.000000,Max=500.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Max=300.000000))
         VelocityLossRange=(X=(Max=0.500000),Y=(Max=0.500000))
         Name="MeshEmitterB70x68Glass1"
     End Object
     Emitters(0)=MeshEmitter'R6SFX.MeshEmitterB70x68Glass1'
     bAlwaysRelevant=True
     LifeSpan=10.000000
}
