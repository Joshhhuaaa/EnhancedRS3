//=============================================================================
// R6BreakableCup.
//=============================================================================
class R6BreakableCup extends R6SFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitterBreakableCup2
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
         Texture=Texture'R6SFX_T.Impact.Glass_Piece_02'
         Acceleration=(Z=-800.000000)
         ExtentMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
         DampingFactorRange=(X=(Min=0.700000,Max=0.700000),Y=(Min=0.700000,Max=0.700000),Z=(Min=0.300000,Max=0.300000))
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000))
         RotationDampingFactorRange=(X=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=0.200000,Max=3.000000))
         LifetimeRange=(Min=3.000000,Max=3.000000)
         StartVelocityRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Max=500.000000))
         VelocityLossRange=(X=(Max=3.000000),Y=(Max=0.500000),Z=(Max=0.500000))
         Name="SpriteEmitterBreakableCup2"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SpriteEmitterBreakableCup2'
     bAlwaysRelevant=True
     LifeSpan=10.000000
}
