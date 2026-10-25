//=============================================================================
// R6SNowImpact.
//=============================================================================
class R6SnowImpact extends R6SFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitterSnow1
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=120.000000
         SecondsBeforeInactive=0.000000
         WarmupTicksPerSecond=5.000000
         Texture=Texture'R6SFX_T.Impact.Smoke_Impact'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=20.000000)
         Acceleration=(Z=-700.000000)
         StartLocationOffset=(X=5.000000)
         StartLocationRange=(X=(Min=5.000000,Max=5.000000))
         SpinCCWorCW=(X=0.200000,Y=0.200000,Z=0.200000)
         SpinsPerSecondRange=(X=(Min=-0.400000,Max=0.400000))
         StartSizeRange=(X=(Min=3.000000,Max=3.000000))
         LifetimeRange=(Min=0.800000,Max=0.800000)
         StartVelocityRange=(X=(Max=300.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
         VelocityLossRange=(X=(Max=6.000000))
         Name="SpriteEmitterSnow1"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteEmitterSnow1'
}
