//=============================================================================
// R6GlassImpact.
//=============================================================================
class R6GlassImpact extends R6SFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitterGlass1
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
         Texture=Texture'R6SFX_T.Impact.Smoke_Impact_02'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=10.000000)
         Acceleration=(X=100.000000)
         StartLocationOffset=(X=5.000000)
         StartLocationRange=(X=(Min=5.000000,Max=5.000000))
         SpinCCWorCW=(X=0.200000,Y=0.200000,Z=0.200000)
         SpinsPerSecondRange=(X=(Min=-0.400000,Max=0.400000))
         StartSizeRange=(X=(Min=2.000000,Max=3.000000),Y=(Min=2.000000,Max=3.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Max=150.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
         VelocityLossRange=(X=(Max=20.000000),Y=(Max=20.000000),Z=(Max=20.000000))
         Name="SpriteEmitterGlass1"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteEmitterGlass1'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterGlass2
         UseRotationFrom=PTRS_Actor
         UseCollision=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=2.000000
         InitialParticlesPerSecond=800.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Impact.Glass_Piece_01'
         Acceleration=(Z=-500.000000)
         ExtentMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
         DampingFactorRange=(X=(Min=0.700000,Max=0.700000),Y=(Min=0.700000,Max=0.700000),Z=(Min=0.300000,Max=0.300000))
         StartLocationOffset=(X=-15.000000)
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000))
         RotationDampingFactorRange=(X=(Min=-0.050000,Max=0.050000))
         StartSizeRange=(X=(Min=0.200000,Max=1.000000))
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(X=(Max=-500.000000),Y=(Min=-25.000000,Max=25.000000),Z=(Max=50.000000))
         VelocityLossRange=(X=(Max=2.000000),Y=(Max=0.500000))
         Name="SpriteEmitterGlass2"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SpriteEmitterGlass2'
     bNetDirty=True
}
