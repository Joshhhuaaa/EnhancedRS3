//=============================================================================
// R6ElectricPanel
//=============================================================================
class R6ElectricPanel extends R6SFX;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteEmitterEP01
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=20
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         FadeOutStartTime=5.000000
         FadeInEndTime=1.000000
         ParticlesPerSecond=2.000000
         Texture=Texture'R6SFX_T.Winter.Breath'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
         StartLocationRange=(X=(Min=-25.000000,Max=25.000000),Y=(Min=-25.000000,Max=25.000000),Z=(Min=-40.000000))
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=20.000000,Max=50.000000))
         LifetimeRange=(Min=10.000000,Max=10.000000)
         StartVelocityRange=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000),Z=(Min=100.000000,Max=150.000000))
         VelocityLossRange=(Z=(Max=0.600000))
         Name="SpriteEmitterEP01"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteEmitterEP01'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterEP02
         StartLocationShape=PTLS_Sphere
         MaxParticles=50
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=40.000000
         Texture=Texture'R6SFX_T.Impact.Electric_Impact_End'
         Acceleration=(Z=-250.000000)
         StartLocationRange=(X=(Min=-100.000000,Max=100.000000),Y=(Min=-100.000000,Max=100.000000),Z=(Min=-100.000000,Max=100.000000))
         SphereRadiusRange=(Min=50.000000,Max=125.000000)
         SpinsPerSecondRange=(X=(Min=-5.000000,Max=5.000000))
         StartSizeRange=(X=(Min=1.000000,Max=2.500000))
         LifetimeRange=(Min=0.100000,Max=0.200000)
         Name="SpriteEmitterEP02"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SpriteEmitterEP02'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterEP03
         UseDirectionAs=PTDU_Up
         UseRotationFrom=PTRS_Actor
         MaxParticles=50
         FadeOut=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.500000
         InitialParticlesPerSecond=40.000000
         Texture=Texture'R6SFX_T.Impact.Electric_Impact_02'
         SubdivisionScale(0)=3.000000
         Acceleration=(Z=-1000.000000)
         StartSizeRange=(X=(Min=0.500000,Max=1.000000),Y=(Min=20.000000,Max=1.000000))
         LifetimeRange=(Min=0.150000,Max=0.300000)
         StartVelocityRange=(X=(Min=-400.000000,Max=400.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Min=-250.000000,Max=800.000000))
         VelocityLossRange=(X=(Max=2.000000),Y=(Max=2.000000),Z=(Max=2.000000))
         Name="SpriteEmitterEP03"
     End Object
     Emitters(2)=SpriteEmitter'R6SFX.SpriteEmitterEP03'
     Begin Object Class=SpriteEmitter Name=SpriteEmitterEP04
         MaxParticles=1
         SpinParticles=True
         InitialParticlesPerSecond=1.000000
         Texture=Texture'R6SFX_T.Impact.Electric_Impact_Base'
         StartLocationRange=(X=(Min=-30.000000,Max=30.000000),Y=(Min=-30.000000,Max=30.000000),Z=(Min=-30.000000,Max=30.000000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=30.000000,Max=50.000000))
         LifetimeRange=(Min=0.050000,Max=0.050000)
         Name="SpriteEmitterEP04"
     End Object
     Emitters(3)=SpriteEmitter'R6SFX.SpriteEmitterEP04'
     bNetDirty=True
     bAlwaysRelevant=True
     m_bDeleteOnReset=False
}
