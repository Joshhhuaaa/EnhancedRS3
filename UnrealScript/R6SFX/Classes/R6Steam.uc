//=============================================================================
// R6Extincteur.
//=============================================================================
class R6Steam extends R6SFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=SpriteEmitter Name=SpriteEmitterSteam
         CoordinateSystem=PTCS_Relative
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=400
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         FadeOutStartTime=0.500000
         FadeInEndTime=1.000000
         InitialParticlesPerSecond=25.000000
         Texture=Texture'R6SFX_T.Impact.Water_Smoke'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=75.000000)
         Acceleration=(Z=-20.000000)
         StartMassRange=(Max=10.000000)
         SpinCCWorCW=(X=1.000000,Y=1.000000,Z=1.000000)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000),Y=(Min=-0.080000,Max=0.080000))
         StartSizeRange=(X=(Min=1.000000,Max=0.500000))
         LifetimeRange=(Min=5.000000,Max=5.000000)
         StartVelocityRange=(X=(Min=-10.000000,Max=10.000000),Y=(Min=-10.000000,Max=10.000000),Z=(Min=-50.000000,Max=-100.000000))
         VelocityLossRange=(Z=(Max=1.200000))
         Name="SpriteEmitterSteam"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteEmitterSteam'
     Begin Object Class=MeshEmitter Name=MeshEmitterSteam1
         StaticMesh=StaticMesh'R6SFX_SM.Other.Gauge'
         MaxParticles=1
         UseCollision=True
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=4.000000
         InitialParticlesPerSecond=1000.000000
         Acceleration=(Z=-1000.000000)
         ExtentMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
         DampingFactorRange=(X=(Min=0.500000,Max=0.500000),Y=(Min=0.500000,Max=0.500000),Z=(Min=0.250000,Max=0.250000))
         SpinsPerSecondRange=(X=(Min=-0.500000,Max=0.500000),Y=(Min=-0.500000,Max=0.500000),Z=(Min=-0.500000,Max=0.500000))
         RotationDampingFactorRange=(X=(Min=0.200000,Max=0.200000),Y=(Min=0.200000,Max=0.200000),Z=(Min=0.200000,Max=0.200000))
         LifetimeRange=(Min=5.000000,Max=5.000000)
         StartVelocityRange=(Z=(Min=100.000000,Max=500.000000))
         Name="MeshEmitterSteam1"
     End Object
     Emitters(1)=MeshEmitter'R6SFX.MeshEmitterSteam1'
     bAlwaysRelevant=True
     LifeSpan=60.000000
}
