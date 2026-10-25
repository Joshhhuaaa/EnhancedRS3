//=============================================================================
// R6WoodImpact.
//=============================================================================
class R6WoodImpact extends R6SFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitterWood1
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=2
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
         Name="SpriteEmitterWood1"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteEmitterWood1'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterWood2
         UseRotationFrom=PTRS_Actor
         MaxParticles=2
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=60.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Impact.Wood_Piece_01'
         Acceleration=(Z=-800.000000)
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=0.500000,Max=1.000000))
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=50.000000,Max=100.000000),Y=(Min=-250.000000,Max=250.000000),Z=(Max=250.000000))
         VelocityLossRange=(X=(Max=0.500000),Y=(Max=0.500000),Z=(Max=0.500000))
         Name="SpriteEmitterWood2"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SpriteEmitterWood2'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterWood3
         UseRotationFrom=PTRS_Actor
         MaxParticles=2
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=60.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Impact.Wood_Piece_02'
         Acceleration=(Z=-800.000000)
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=0.500000,Max=1.000000))
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=50.000000,Max=100.000000),Y=(Min=-250.000000,Max=250.000000),Z=(Max=250.000000))
         VelocityLossRange=(X=(Max=0.500000),Y=(Max=0.500000),Z=(Max=0.500000))
         Name="SpriteEmitterWood3"
     End Object
     Emitters(2)=SpriteEmitter'R6SFX.SpriteEmitterWood3'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterWood4
         UseRotationFrom=PTRS_Actor
         MaxParticles=2
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=60.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Impact.Wood_Piece_03'
         Acceleration=(Z=-800.000000)
         SpinsPerSecondRange=(X=(Min=-5.000000,Max=5.000000),Y=(Min=-5.000000,Max=5.000000))
         StartSizeRange=(X=(Min=0.500000,Max=1.000000))
         LifetimeRange=(Min=2.000000,Max=2.000000)
         StartVelocityRange=(X=(Min=50.000000,Max=100.000000),Y=(Min=-250.000000,Max=250.000000),Z=(Max=250.000000))
         VelocityLossRange=(X=(Max=0.500000),Y=(Max=0.500000),Z=(Max=0.500000))
         Name="SpriteEmitterWood4"
     End Object
     Emitters(3)=SpriteEmitter'R6SFX.SpriteEmitterWood4'
     bDynamicLight=True
}
