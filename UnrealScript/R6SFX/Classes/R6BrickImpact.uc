//=============================================================================
// R6BrickImpact.
//=============================================================================
class R6BrickImpact extends R6SFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitterBrick1
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
         StartSizeRange=(X=(Min=1.000000,Max=3.000000))
         LifetimeRange=(Min=1.500000,Max=1.500000)
         StartVelocityRange=(X=(Min=100.000000,Max=800.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-10.000000,Max=10.000000))
         VelocityLossRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=10.000000,Max=10.000000))
         Name="SpriteEmitterBrick1"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteEmitterBrick1'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterBrick2
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
         StartSizeRange=(X=(Min=2.000000,Max=3.000000))
         LifetimeRange=(Min=1.500000,Max=1.500000)
         StartVelocityRange=(X=(Min=30.000000,Max=50.000000),Y=(Min=-150.000000,Max=150.000000),Z=(Min=-150.000000,Max=150.000000))
         VelocityLossRange=(X=(Min=3.000000,Max=5.000000),Y=(Min=15.000000,Max=15.000000),Z=(Min=15.000000,Max=15.000000))
         Name="SpriteEmitterBrick2"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SpriteEmitterBrick2'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterBrick3
         UseRotationFrom=PTRS_Actor
         MaxParticles=1
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=180.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Impact.Brick_Piece_01'
         Acceleration=(Z=-800.000000)
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=0.200000,Max=1.000000))
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=50.000000,Max=100.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Max=300.000000))
         VelocityLossRange=(X=(Max=0.500000),Y=(Max=0.500000),Z=(Max=0.500000))
         Name="SpriteEmitterBrick3"
     End Object
     Emitters(2)=SpriteEmitter'R6SFX.SpriteEmitterBrick3'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterBrick4
         UseRotationFrom=PTRS_Actor
         MaxParticles=2
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=60.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Impact.Brick_Piece_02'
         Acceleration=(Z=-800.000000)
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=0.200000,Max=1.000000))
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=50.000000,Max=100.000000),Y=(Min=-300.000000,Max=300.000000),Z=(Max=300.000000))
         VelocityLossRange=(X=(Max=0.500000),Y=(Max=0.500000),Z=(Max=0.500000))
         Name="SpriteEmitterBrick4"
     End Object
     Emitters(3)=SpriteEmitter'R6SFX.SpriteEmitterBrick4'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterBrick5
         UseRotationFrom=PTRS_Actor
         MaxParticles=1
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=60.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Impact.Brick_Piece_03'
         Acceleration=(Z=-800.000000)
         SpinsPerSecondRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000))
         StartSizeRange=(X=(Min=0.200000,Max=1.000000))
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(X=(Max=10.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Max=50.000000))
         VelocityLossRange=(X=(Max=0.500000),Y=(Max=0.500000),Z=(Max=0.500000))
         Name="SpriteEmitterBrick5"
     End Object
     Emitters(4)=SpriteEmitter'R6SFX.SpriteEmitterBrick5'
     bNetDirty=True
}
