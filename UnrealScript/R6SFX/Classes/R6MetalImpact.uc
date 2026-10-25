//=============================================================================
// R6MetalImpact.
//=============================================================================
class R6MetalImpact extends R6SFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitterMetal1
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=3
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=60.000000
         SecondsBeforeInactive=0.000000
         WarmupTicksPerSecond=5.000000
         Texture=Texture'R6SFX_T.Impact.Smoke_Impact_04'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=10.000000)
         Acceleration=(Z=100.000000)
         StartLocationOffset=(X=5.000000)
         StartLocationRange=(X=(Min=5.000000,Max=5.000000))
         SpinCCWorCW=(X=0.200000,Y=0.200000,Z=0.200000)
         SpinsPerSecondRange=(X=(Min=-0.400000,Max=0.400000))
         StartSizeRange=(X=(Min=2.000000,Max=3.000000),Y=(Min=2.000000,Max=3.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Max=150.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
         VelocityLossRange=(X=(Max=20.000000),Y=(Max=20.000000),Z=(Max=20.000000))
         Name="SpriteEmitterMetal1"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteEmitterMetal1'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterMetal2
         UseDirectionAs=PTDU_Up
         UseRotationFrom=PTRS_Actor
         MaxParticles=3
         FadeOut=True
         RespawnDeadParticles=False
         DampRotation=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.500000
         InitialParticlesPerSecond=1000.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Impact.Metal_Impact'
         Acceleration=(Z=-1000.000000)
         StartSizeRange=(X=(Min=0.100000,Max=0.100000),Y=(Min=5.000000,Max=5.000000))
         LifetimeRange=(Min=0.500000,Max=3.000000)
         StartVelocityRange=(X=(Min=250.000000,Max=400.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Min=-250.000000,Max=800.000000))
         VelocityLossRange=(X=(Max=2.000000),Y=(Max=2.000000),Z=(Max=2.000000))
         Name="SpriteEmitterMetal2"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SpriteEmitterMetal2'
}
