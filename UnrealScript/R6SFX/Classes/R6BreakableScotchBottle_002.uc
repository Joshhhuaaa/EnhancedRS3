//=============================================================================
// R6BreakableScotchBottle_002.
//=============================================================================
class R6BreakableScotchBottle_002 extends R6SFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitterBScotchBottle21
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=5
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
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=10.000000)
         StartLocationRange=(X=(Min=5.000000,Max=5.000000))
         SpinCCWorCW=(X=0.200000,Y=0.200000,Z=0.200000)
         SpinsPerSecondRange=(X=(Min=-0.400000,Max=0.400000))
         StartSizeRange=(X=(Min=5.000000,Max=8.000000),Y=(Min=2.000000,Max=3.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=-150.000000,Max=150.000000),Y=(Min=-150.000000,Max=150.000000),Z=(Max=150.000000))
         VelocityLossRange=(X=(Max=20.000000),Y=(Max=20.000000),Z=(Max=20.000000))
         Name="SpriteEmitterBScotchBottle21"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteEmitterBScotchBottle21'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterBScotchBottle22
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
         Texture=Texture'R6SFX_T.Impact.Scotch_Bottle_Piece_002'
         Acceleration=(Z=-800.000000)
         ExtentMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
         DampingFactorRange=(X=(Min=0.700000,Max=0.700000),Y=(Min=0.700000,Max=0.700000),Z=(Min=0.300000,Max=0.300000))
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000))
         RotationDampingFactorRange=(X=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=0.200000,Max=3.000000))
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Max=500.000000))
         VelocityLossRange=(X=(Max=3.000000),Y=(Max=0.500000),Z=(Max=0.500000))
         Name="SpriteEmitterBScotchBottle22"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SpriteEmitterBScotchBottle22'
     bDynamicLight=True
     bNetDirty=True
     bAlwaysRelevant=True
     LifeSpan=10.000000
}
