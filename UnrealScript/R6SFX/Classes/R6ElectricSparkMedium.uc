//=============================================================================
// R6ElectricSparkMedium.
//=============================================================================
class R6ElectricSparkMedium extends R6SFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitterR6ElectricSparkMedium_01
         StartLocationShape=PTLS_Sphere
         MaxParticles=2000
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=40.000000
         Texture=Texture'R6SFX_T.Impact.Electric_Impact_End'
         Acceleration=(Z=-250.000000)
         StartLocationRange=(X=(Min=-50.000000,Max=50.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-50.000000,Max=50.000000))
         SphereRadiusRange=(Min=50.000000,Max=125.000000)
         SpinsPerSecondRange=(X=(Min=-5.000000,Max=5.000000))
         StartSizeRange=(X=(Min=1.000000,Max=2.500000))
         LifetimeRange=(Min=0.100000,Max=0.200000)
         Name="SpriteEmitterR6ElectricSparkMedium_01"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteEmitterR6ElectricSparkMedium_01'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterR6ElectricSparkMedium_02
         UseDirectionAs=PTDU_Up
         UseRotationFrom=PTRS_Actor
         MaxParticles=2000
         FadeOut=True
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.500000
         InitialParticlesPerSecond=40.000000
         Texture=Texture'R6SFX_T.Impact.Electric_Impact_02'
         SubdivisionScale(0)=3.000000
         Acceleration=(Z=-1000.000000)
         StartSizeRange=(X=(Min=0.500000,Max=1.000000),Y=(Min=20.000000,Max=1.000000))
         LifetimeRange=(Min=0.150000,Max=0.300000)
         StartVelocityRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Min=-250.000000,Max=800.000000))
         VelocityLossRange=(X=(Max=4.000000),Y=(Max=4.000000),Z=(Max=4.000000))
         Name="SpriteEmitterR6ElectricSparkMedium_02"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SpriteEmitterR6ElectricSparkMedium_02'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterR6ElectricSparkMedium_03
         MaxParticles=500
         RespawnDeadParticles=False
         SpinParticles=True
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=10.000000
         Texture=Texture'R6SFX_T.Impact.Electric_Impact_Base'
         StartLocationRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=-20.000000,Max=20.000000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=15.000000,Max=25.000000))
         LifetimeRange=(Min=0.050000,Max=0.050000)
         Name="SpriteEmitterR6ElectricSparkMedium_03"
     End Object
     Emitters(2)=SpriteEmitter'R6SFX.SpriteEmitterR6ElectricSparkMedium_03'
     bNetDirty=True
}
