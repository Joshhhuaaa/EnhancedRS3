//=============================================================================
// R6WaterImpact.
//=============================================================================
class R6WaterImpact extends R6SFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitterWater1
         UseDirectionAs=PTDU_Normal
         ProjectionNormal=(Y=1.000000,Z=0.000000)
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=5
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=120.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Impact.Smoke_Impact_02'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=20.000000)
         Acceleration=(Z=-600.000000)
         StartLocationOffset=(X=5.000000)
         StartLocationRange=(X=(Min=5.000000,Max=5.000000))
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         StartSizeRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=3.000000,Max=3.000000))
         LifetimeRange=(Min=1.500000,Max=1.500000)
         StartVelocityRange=(X=(Max=400.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
         VelocityLossRange=(X=(Max=6.000000))
         Name="SpriteEmitterWater1"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteEmitterWater1'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterWater2
         UseDirectionAs=PTDU_Normal
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=5
         FadeOut=True
         RespawnDeadParticles=False
         AutoDestroy=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=120.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Impact.Smoke_Impact_02'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=20.000000)
         Acceleration=(Z=-600.000000)
         StartLocationOffset=(X=5.000000)
         StartLocationRange=(X=(Min=5.000000,Max=5.000000))
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         StartSizeRange=(X=(Min=3.000000,Max=3.000000),Y=(Min=10.000000,Max=10.000000))
         LifetimeRange=(Min=1.500000,Max=1.500000)
         StartVelocityRange=(X=(Max=400.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
         VelocityLossRange=(X=(Max=6.000000))
         Name="SpriteEmitterWater2"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SpriteEmitterWater2'
     bDynamicLight=True
}
