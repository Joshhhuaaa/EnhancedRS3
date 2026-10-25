//============================================================================//
// Class            R6BreakableGlass_Alpine
// Created By       Carl Lavoie
// Date             10/26/2001
// Description      Breakable glass material default properties
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6BreakableGlass_Alpine extends R6SFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitterBGlassAlpine1
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
         InitialParticlesPerSecond=200.000000
         SecondsBeforeInactive=0.000000
         WarmupTicksPerSecond=5.000000
         Texture=Texture'R6SFX_T.Impact.Smoke_Impact_02'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=15.000000)
         Acceleration=(Z=-100.000000)
         StartLocationOffset=(X=5.000000)
         StartLocationRange=(X=(Min=5.000000,Max=5.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-50.000000,Max=50.000000))
         SpinCCWorCW=(X=0.200000,Y=0.200000,Z=0.200000)
         SpinsPerSecondRange=(X=(Min=0.150000,Max=0.150000))
         StartSizeRange=(X=(Min=15.000000,Max=15.000000),Y=(Min=2.000000,Max=3.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-500.000000,Max=500.000000),Y=(Min=-20.000000,Max=20.000000))
         VelocityLossRange=(X=(Max=20.000000),Y=(Max=20.000000),Z=(Max=20.000000))
         Name="SpriteEmitterBGlassAlpine1"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteEmitterBGlassAlpine1'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterBGlassAlpine2
         ProjectionNormal=(Z=0.000000)
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=3
         UseCollision=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=200.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Impact.Glass_Detail_01'
         Acceleration=(Z=-800.000000)
         ExtentMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
         DampingFactorRange=(X=(Min=0.700000,Max=0.700000),Y=(Min=0.700000,Max=0.700000),Z=(Min=0.300000,Max=0.300000))
         StartLocationRange=(Y=(Min=-20.000000,Max=20.000000),Z=(Min=-25.000000,Max=25.000000))
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000))
         RotationDampingFactorRange=(X=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=1.000000,Max=7.000000))
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=-150.000000,Max=150.000000),Y=(Min=-100.000000,Max=100.000000))
         VelocityLossRange=(X=(Max=0.500000),Y=(Max=0.500000),Z=(Max=0.500000))
         Name="SpriteEmitterBGlassAlpine2"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SpriteEmitterBGlassAlpine2'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterBGlassAlpine3
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=3
         UseCollision=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=200.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Impact.Glass_Detail_02'
         Acceleration=(Z=-800.000000)
         ExtentMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
         DampingFactorRange=(X=(Min=0.700000,Max=0.700000),Y=(Min=0.700000,Max=0.700000),Z=(Min=0.300000,Max=0.300000))
         StartLocationRange=(Y=(Min=-20.000000,Max=20.000000),Z=(Min=-25.000000,Max=25.000000))
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000))
         RotationDampingFactorRange=(X=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=2.000000,Max=10.000000))
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=-150.000000,Max=150.000000),Y=(Min=-100.000000,Max=100.000000))
         VelocityLossRange=(X=(Max=0.500000),Y=(Max=0.500000),Z=(Max=0.500000))
         Name="SpriteEmitterBGlassAlpine3"
     End Object
     Emitters(2)=SpriteEmitter'R6SFX.SpriteEmitterBGlassAlpine3'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterBGlassAlpine4
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=3
         UseCollision=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=200.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Impact.Glass_Detail_03'
         Acceleration=(Z=-800.000000)
         ExtentMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
         DampingFactorRange=(X=(Min=0.700000,Max=0.700000),Y=(Min=0.700000,Max=0.700000),Z=(Min=0.300000,Max=0.300000))
         StartLocationRange=(Y=(Min=-20.000000,Max=20.000000),Z=(Min=-25.000000,Max=25.000000))
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000))
         RotationDampingFactorRange=(X=(Min=0.700000,Max=0.700000),Y=(Min=0.700000,Max=0.700000),Z=(Min=0.300000,Max=0.300000))
         StartSizeRange=(X=(Min=2.000000,Max=10.000000))
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=-150.000000,Max=150.000000),Y=(Min=-100.000000,Max=100.000000))
         VelocityLossRange=(X=(Max=0.500000),Y=(Max=0.500000),Z=(Max=0.500000))
         Name="SpriteEmitterBGlassAlpine4"
     End Object
     Emitters(3)=SpriteEmitter'R6SFX.SpriteEmitterBGlassAlpine4'
     bAlwaysRelevant=True
     LifeSpan=10.000000
}
