//=============================================================================
// R6Breakable_TV
//=============================================================================
class R6Breakable_TV extends R6SFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitterR6Breakable_TV_01
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=8
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=1000.000000
         SecondsBeforeInactive=0.000000
         WarmupTicksPerSecond=5.000000
         Texture=Texture'R6SFX_T.Impact.Smoke_Impact_04'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=20.000000)
         Acceleration=(Z=-400.000000)
         StartLocationOffset=(X=5.000000)
         SpinCCWorCW=(X=0.200000,Y=0.200000,Z=0.200000)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=3.000000,Max=5.000000))
         LifetimeRange=(Min=1.500000,Max=1.500000)
         StartVelocityRange=(X=(Min=100.000000,Max=800.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
         VelocityLossRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=10.000000,Max=10.000000))
         Name="SpriteEmitterR6Breakable_TV_01"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteEmitterR6Breakable_TV_01'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterR6Breakable_TV_02
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=5
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
         StartLocationOffset=(X=5.000000)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=3.000000,Max=5.000000))
         LifetimeRange=(Min=1.500000,Max=1.500000)
         StartVelocityRange=(X=(Min=30.000000,Max=50.000000),Y=(Min=-150.000000,Max=150.000000),Z=(Min=-150.000000,Max=150.000000))
         VelocityLossRange=(X=(Min=3.000000,Max=5.000000),Y=(Min=15.000000,Max=15.000000),Z=(Min=15.000000,Max=15.000000))
         Name="SpriteEmitterR6Breakable_TV_02"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SpriteEmitterR6Breakable_TV_02'
     Begin Object Class=MeshEmitter Name=MeshEmitterR6Breakable_TV_03
         StaticMesh=StaticMesh'R6SFX_SM.Glass.Glass_Piece'
         UseRotationFrom=PTRS_Actor
         MaxParticles=30
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
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Max=5.000000),Y=(Max=5.000000))
         StartVelocityRange=(X=(Max=500.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Max=300.000000))
         VelocityLossRange=(X=(Max=1.000000),Y=(Max=0.500000))
         Name="MeshEmitterR6Breakable_TV_03"
     End Object
     Emitters(2)=MeshEmitter'R6SFX.MeshEmitterR6Breakable_TV_03'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterR6Breakable_TV_04
         MaxParticles=1
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=3000.000000
         Texture=Texture'R6SFX_T.Flare.Glare'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=0.500000)
         LifetimeRange=(Min=0.050000,Max=0.050000)
         Name="SpriteEmitterR6Breakable_TV_04"
     End Object
     Emitters(4)=SpriteEmitter'R6SFX.SpriteEmitterR6Breakable_TV_04'
     bNetDirty=True
     bAlwaysRelevant=True
     LifeSpan=10.000000
}
