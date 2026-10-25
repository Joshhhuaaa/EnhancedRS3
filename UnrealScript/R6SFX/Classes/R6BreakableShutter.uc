//============================================================================//
// Class            R6BreakableShutter
// Created By       Carl Lavoie
//============================================================================//
class R6BreakableShutter extends R6SFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitterBShutter_01
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=30
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=3000.000000
         SecondsBeforeInactive=0.000000
         WarmupTicksPerSecond=5.000000
         Texture=Texture'R6SFX_T.Impact.Smoke_Impact_04'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=20.000000)
         Acceleration=(Z=-400.000000)
         StartLocationOffset=(X=64.000000)
         StartLocationRange=(Y=(Min=-22.000000,Max=22.000000),Z=(Min=-60.000000,Max=60.000000))
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=5.000000,Max=10.000000))
         LifetimeRange=(Min=1.500000,Max=1.500000)
         StartVelocityRange=(X=(Min=-150.000000,Max=150.000000),Y=(Min=-150.000000,Max=150.000000),Z=(Min=-150.000000,Max=150.000000))
         VelocityLossRange=(X=(Min=3.000000,Max=5.000000),Y=(Min=15.000000,Max=15.000000),Z=(Min=15.000000,Max=15.000000))
         Name="SpriteEmitterBShutter_01"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteEmitterBShutter_01'
     Begin Object Class=MeshEmitter Name=MeshEmitterBShutter_02
         StaticMesh=StaticMesh'R6SFX_SM.BreakableDoor.BreakableDoor01'
         UseRotationFrom=PTRS_Actor
         MaxParticles=15
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
         StartLocationOffset=(X=-64.000000)
         StartLocationRange=(Y=(Min=-64.000000,Max=64.000000),Z=(Min=-130.000000,Max=130.000000))
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=0.100000),Y=(Min=0.100000),Z=(Min=0.500000))
         StartVelocityRange=(X=(Min=200.000000,Max=-200.000000),Y=(Min=-800.000000,Max=800.000000),Z=(Max=500.000000))
         VelocityLossRange=(Y=(Max=0.500000))
         Name="MeshEmitterBShutter_02"
     End Object
     Emitters(1)=MeshEmitter'R6SFX.MeshEmitterBShutter_02'
     bAlwaysRelevant=True
     LifeSpan=10.000000
}
