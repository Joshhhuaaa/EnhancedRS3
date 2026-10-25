//=============================================================================
// R6BreakableSugarBottle.
//=============================================================================
class R6BreakableSugarBottle extends R6SFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitterBSugarBottle1
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=500.000000
         SecondsBeforeInactive=0.000000
         WarmupTicksPerSecond=5.000000
         Texture=Texture'R6SFX_T.Impact.Smoke_Impact'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=20.000000)
         Acceleration=(Z=-700.000000)
         StartLocationOffset=(Z=15.000000)
         StartLocationRange=(Z=(Min=5.000000,Max=10.000000))
         SpinCCWorCW=(X=0.200000,Y=0.200000,Z=0.200000)
         SpinsPerSecondRange=(X=(Min=-0.400000,Max=0.400000))
         StartSizeRange=(X=(Min=3.000000,Max=3.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Max=400.000000))
         VelocityLossRange=(Z=(Max=6.000000))
         Name="SpriteEmitterBSugarBottle1"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteEmitterBSugarBottle1'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterBSugarBottle2
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=20
         UseCollision=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=800.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Impact.Sugar_Bottle_Piece'
         Acceleration=(Z=-800.000000)
         ExtentMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
         DampingFactorRange=(X=(Min=0.700000,Max=0.700000),Y=(Min=0.700000,Max=0.700000),Z=(Min=0.300000,Max=0.300000))
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000))
         RotationDampingFactorRange=(X=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=0.200000,Max=3.000000))
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Max=500.000000))
         VelocityLossRange=(X=(Max=3.000000),Y=(Max=0.500000),Z=(Max=0.500000))
         Name="SpriteEmitterBSugarBottle2"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SpriteEmitterBSugarBottle2'
     bDynamicLight=True
     bNetDirty=True
     bAlwaysRelevant=True
     LifeSpan=10.000000
}
