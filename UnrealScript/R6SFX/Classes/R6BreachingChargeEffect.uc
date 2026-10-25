//=============================================================================
// R6BreachingChargeEffect
//=============================================================================
class R6BreachingChargeEffect extends R6SFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitterBreachingCharge1
         CoordinateSystem=PTCS_Relative
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=20
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         FadeOutStartTime=1.000000
         FadeInEndTime=4.000000
         InitialParticlesPerSecond=3000.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Grenade.Smoke_Grenade_03'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
         Acceleration=(Z=2.000000)
         StartLocationOffset=(Z=25.000000)
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=20.000000,Max=50.000000))
         LifetimeRange=(Min=8.000000,Max=8.000000)
         StartVelocityRange=(X=(Min=-3000.000000,Max=3000.000000),Y=(Min=-1000.000000,Max=1000.000000),Z=(Min=3000.000000,Max=-3000.000000))
         VelocityLossRange=(X=(Min=18.000000,Max=18.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=18.000000,Max=18.000000))
         Name="SpriteEmitterBreachingCharge1"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteEmitterBreachingCharge1'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterBreachingCharge2
         CoordinateSystem=PTCS_Relative
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=20
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         FadeInEndTime=4.000000
         InitialParticlesPerSecond=3000.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Grenade.Smoke_Grenade_03'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=3.000000)
         Acceleration=(Z=2.000000)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=40.000000,Max=60.000000),Y=(Min=10.000000,Max=10.000000))
         LifetimeRange=(Min=8.000000,Max=8.000000)
         StartVelocityRange=(X=(Min=-250.000000,Max=250.000000),Y=(Min=-3000.000000,Max=3000.000000),Z=(Min=250.000000,Max=-250.000000))
         VelocityLossRange=(X=(Min=1.000000,Max=5.000000),Y=(Min=12.000000,Max=12.000000),Z=(Min=1.000000,Max=5.000000))
         Name="SpriteEmitterBreachingCharge2"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SpriteEmitterBreachingCharge2'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterBreachingCharge3
         MaxParticles=5
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=3000.000000
         Texture=Texture'R6SFX_T.Flare.Glare'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartLocationOffset=(Z=-40.000000)
         LifetimeRange=(Min=0.100000,Max=0.200000)
         StartVelocityRange=(X=(Min=-3000.000000,Max=3000.000000),Y=(Min=-1000.000000,Max=1000.000000),Z=(Min=3000.000000,Max=-3000.000000))
         VelocityLossRange=(X=(Min=18.000000,Max=18.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=18.000000,Max=18.000000))
         Name="SpriteEmitterBreachingCharge3"
     End Object
     Emitters(2)=SpriteEmitter'R6SFX.SpriteEmitterBreachingCharge3'
     bDynamicLight=True
     bNetDirty=True
     bAlwaysRelevant=True
     LifeSpan=8.000000
}
