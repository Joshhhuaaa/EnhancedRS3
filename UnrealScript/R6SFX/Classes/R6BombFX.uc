//=============================================================================
// R6BombFX.
//=============================================================================
class R6BombFX extends R6SFX;

defaultproperties
{
     AutoDestroy=True
     Begin Object Class=SpriteEmitter Name=SpriteSmoke_001
         DrawStyle=PTDS_AlphaBlend
         FadeOut=True
         FadeIn=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         FadeOutStartTime=3.000000
         FadeInEndTime=1.000000
         InitialParticlesPerSecond=5000.000000
         Texture=Texture'R6SFX_T.Grenade.Smoke_Grenade_03'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=3.000000)
         Acceleration=(Z=500.000000)
         SpinsPerSecondRange=(X=(Min=-0.050000,Max=0.050000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Max=250.000000))
         LifetimeRange=(Min=5.000000,Max=5.000000)
         StartVelocityRange=(X=(Min=-3000.000000,Max=3000.000000),Y=(Min=-3000.000000,Max=3000.000000),Z=(Max=8000.000000))
         VelocityLossRange=(X=(Min=10.000000,Max=10.000000),Y=(Min=10.000000,Max=10.000000),Z=(Min=8.000000,Max=8.000000))
         Name="SpriteSmoke_001"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteSmoke_001'
     Begin Object Class=SpriteEmitter Name=SpriteExplosion_001
         MaxParticles=1
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         RespawnDeadParticles=False
         UseRegularSizeScale=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         FadeInEndTime=4.000000
         SizeScaleRepeats=1.000000
         InitialParticlesPerSecond=5000.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Explosion.explode_01'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=1.500000)
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=512.000000,Max=512.000000))
         LifetimeRange=(Min=0.900000,Max=0.900000)
         VelocityLossRange=(X=(Min=1.000000,Max=5.000000),Y=(Min=1.000000,Max=5.000000),Z=(Min=12.000000,Max=12.000000))
         Name="SpriteExplosion_001"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SpriteExplosion_001'
     Begin Object Class=SpriteEmitter Name=SpriteExplosion_002
         MaxParticles=1
         TextureUSubdivisions=4
         TextureVSubdivisions=4
         RespawnDeadParticles=False
         UniformSize=True
         AutomaticInitialSpawning=False
         BlendBetweenSubdivisions=True
         InitialParticlesPerSecond=5000.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Explosion.explode_02'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=1.500000)
         StartLocationOffset=(Y=-80.000000,Z=300.000000)
         StartSizeRange=(X=(Min=-600.000000,Max=-600.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         VelocityLossRange=(X=(Min=1.000000,Max=5.000000),Y=(Min=1.000000,Max=5.000000),Z=(Min=12.000000,Max=12.000000))
         Name="SpriteExplosion_002"
     End Object
     Emitters(2)=SpriteEmitter'R6SFX.SpriteExplosion_002'
     Begin Object Class=MeshEmitter Name=Mesh_debris_001
         StaticMesh=StaticMesh'R6SFX_SM.BreakableDoor.BreakableMetalDoor'
         MaxParticles=50
         UseCollision=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         AutomaticInitialSpawning=False
         FadeOutStartTime=5.000000
         InitialParticlesPerSecond=5000.000000
         SecondsBeforeInactive=0.000000
         Acceleration=(Z=-1000.000000)
         ExtentMultiplier=(X=0.000000,Y=0.000000,Z=0.000000)
         DampingFactorRange=(X=(Min=0.250000,Max=0.500000),Y=(Min=0.250000,Max=0.500000),Z=(Min=0.250000,Max=0.500000))
         SpinsPerSecondRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000),Y=(Min=-1.000000,Max=1.000000),Z=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=0.100000,Max=4.000000),Y=(Min=0.100000,Max=4.000000),Z=(Min=0.100000,Max=4.000000))
         LifetimeRange=(Min=10.000000,Max=10.000000)
         StartVelocityRange=(X=(Min=-1000.000000,Max=1000.000000),Y=(Min=-1000.000000,Max=1000.000000),Z=(Min=100.000000,Max=3000.000000))
         VelocityLossRange=(Z=(Max=2.000000))
         Name="Mesh_debris_001"
     End Object
     Emitters(4)=MeshEmitter'R6SFX.Mesh_debris_001'
     bAlwaysRelevant=True
     LifeSpan=15.000000
}
