//============================================================================//
// Class            R6MuzzleFlashSub
// Created By       Carl Lavoie
// Date             01/16/2002
// Description      Smoke and Muzzle for SubGun
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6MuzzleFlashSub extends R6SFX;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SmokeEmitterSuba
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=20
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Muzzleflash.Smoke_Muzzle_Flash_02'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=3.000000)
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=-0.500000,Max=0.500000))
         StartSizeRange=(X=(Min=5.000000,Max=15.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Max=5.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Min=-500.000000,Max=500.000000))
         VelocityLossRange=(X=(Min=20.000000,Max=20.000000),Y=(Min=20.000000,Max=20.000000),Z=(Min=20.000000,Max=20.000000))
         Name="SmokeEmitterSuba"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SmokeEmitterSuba'
     Begin Object Class=SpriteEmitter Name=SmokeEmitterSubb
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=20
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         FadeInEndTime=4.000000
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Muzzleflash.Smoke_Muzzle_Flash_02'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=3.000000)
         Acceleration=(X=2.000000)
         SpinsPerSecondRange=(X=(Min=-0.500000,Max=0.500000))
         StartSizeRange=(X=(Min=10.000000,Max=15.000000),Y=(Min=10.000000,Max=10.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=50.000000,Max=1000.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-50.000000,Max=50.000000))
         VelocityLossRange=(X=(Min=15.000000,Max=15.000000),Y=(Min=15.000000,Max=15.000000),Z=(Min=15.000000,Max=15.000000))
         Name="SmokeEmitterSubb"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SmokeEmitterSubb'
     Begin Object Class=SpriteEmitter Name=NoMuzzleEmitterSub
         UseDirectionAs=PTDU_Right
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         FadeOut=True
         RespawnDeadParticles=False
         DampRotation=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Texture=Texture'R6SFX_T.Muzzleflash.MuzzleFlashA'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=1.000000)
         Acceleration=(X=3000.000000)
         StartLocationOffset=(X=15.000000)
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000),Y=(Min=-0.200000,Max=0.200000),Z=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=10.000000,Max=30.000000),Y=(Min=5.000000,Max=15.000000))
         LifetimeRange=(Min=0.100000,Max=0.100000)
         Name="NoMuzzleEmitterSub"
     End Object
     Emitters(2)=SpriteEmitter'R6SFX.NoMuzzleEmitterSub'
     Begin Object Class=SpriteEmitter Name=WithMuzzleEmitterSub
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Texture=Texture'R6SFX_T.Muzzleflash.MuzzleFlashC'
         StartLocationOffset=(X=5.000000)
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000),Y=(Min=-0.200000,Max=0.200000),Z=(Min=-1.000000,Max=1.000000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=5.000000,Max=12.000000))
         LifetimeRange=(Min=0.100000,Max=0.100000)
         Name="WithMuzzleEmitterSub"
     End Object
     Emitters(3)=SpriteEmitter'R6SFX.WithMuzzleEmitterSub'
     Begin Object Class=SpriteEmitter Name=R61stMuzzleFlashSub
         CoordinateSystem=PTCS_Relative
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=5
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Texture=Texture'R6SFX_T.Muzzleflash.1stMuzzle_B'
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000),Y=(Min=-0.200000,Max=0.200000),Z=(Min=-1.000000,Max=1.000000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=35.000000,Max=45.000000))
         LifetimeRange=(Min=0.100000,Max=0.200000)
         Name="R61stMuzzleFlashSub"
     End Object
     Emitters(4)=SpriteEmitter'R6SFX.R61stMuzzleFlashSub'
     RemoteRole=ROLE_None
     m_bDrawFromBase=True
     m_bTickOnlyWhenVisible=True
}
