//============================================================================//
// Class            R6BreakableGlass
// Created By       Carl Lavoie
// Date             10/26/2001
// Description      Breakable glass material default properties
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6BreakableGlass extends R6SFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitterBGlass1
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=5
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=200.000000
         SecondsBeforeInactive=0.000000
         WarmupTicksPerSecond=5.000000
         Texture=Texture'R6SFX_T.Impact.Smoke_Impact_02'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=10.000000)
         Acceleration=(Z=-100.000000)
         StartLocationOffset=(X=5.000000)
         StartLocationRange=(X=(Min=5.000000,Max=5.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-50.000000,Max=50.000000))
         SpinCCWorCW=(X=0.200000,Y=0.200000,Z=0.200000)
         SpinsPerSecondRange=(X=(Min=0.150000,Max=0.150000))
         StartSizeRange=(X=(Min=30.000000,Max=30.000000),Y=(Min=2.000000,Max=3.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=250.000000,Max=500.000000),Y=(Min=-20.000000,Max=20.000000))
         VelocityLossRange=(X=(Max=20.000000),Y=(Max=20.000000),Z=(Max=20.000000))
         Name="SpriteEmitterBGlass1"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteEmitterBGlass1'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterBGlass2
         ProjectionNormal=(Z=0.000000)
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         UseCollision=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=200.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Impact.Glass_Detail_01'
         Acceleration=(Z=-800.000000)
         DampingFactorRange=(X=(Min=0.700000,Max=0.700000),Y=(Min=0.700000,Max=0.700000),Z=(Min=0.300000,Max=0.300000))
         StartLocationRange=(Y=(Min=-70.000000,Max=70.000000),Z=(Min=-70.000000,Max=70.000000))
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000))
         RotationDampingFactorRange=(X=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=1.000000,Max=15.000000))
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(X=(Max=75.000000),Y=(Min=-100.000000,Max=100.000000))
         VelocityLossRange=(X=(Max=0.500000),Y=(Max=0.500000),Z=(Max=0.500000))
         Name="SpriteEmitterBGlass2"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SpriteEmitterBGlass2'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterBGlass3
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         UseCollision=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=200.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Impact.Glass_Detail_02'
         Acceleration=(Z=-800.000000)
         DampingFactorRange=(X=(Min=0.700000,Max=0.700000),Y=(Min=0.700000,Max=0.700000),Z=(Min=0.300000,Max=0.300000))
         StartLocationRange=(Y=(Min=-70.000000,Max=70.000000),Z=(Min=-70.000000,Max=70.000000))
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000))
         RotationDampingFactorRange=(X=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=2.000000,Max=20.000000))
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(X=(Max=75.000000),Y=(Min=100.000000,Max=-100.000000))
         VelocityLossRange=(X=(Max=0.500000),Y=(Max=0.500000),Z=(Max=0.500000))
         Name="SpriteEmitterBGlass3"
     End Object
     Emitters(2)=SpriteEmitter'R6SFX.SpriteEmitterBGlass3'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterBGlass4
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=5
         UseCollision=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=200.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Impact.Glass_Detail_03'
         Acceleration=(Z=-800.000000)
         DampingFactorRange=(X=(Min=0.700000,Max=0.700000),Y=(Min=0.700000,Max=0.700000),Z=(Min=0.300000,Max=0.300000))
         StartLocationRange=(Y=(Min=-70.000000,Max=70.000000),Z=(Min=-70.000000,Max=70.000000))
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000))
         RotationDampingFactorRange=(X=(Min=0.700000,Max=0.700000),Y=(Min=0.700000,Max=0.700000),Z=(Min=0.300000,Max=0.300000))
         StartSizeRange=(X=(Min=2.000000,Max=20.000000))
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(X=(Max=75.000000),Y=(Min=-50.000000,Max=50.000000))
         VelocityLossRange=(X=(Max=0.500000),Y=(Max=0.500000),Z=(Max=0.500000))
         Name="SpriteEmitterBGlass4"
     End Object
     Emitters(3)=SpriteEmitter'R6SFX.SpriteEmitterBGlass4'
}
