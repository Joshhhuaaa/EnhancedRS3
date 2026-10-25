//============================================================================//
// Class            R6MuzzleFlash12Gauge
// Created By       Carl Lavoie
// Date             12/18/2001
// Description      Smoke and Muzzle for 12Gauge caliber
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6MuzzleFlash12Gauge extends R6SFX;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SmokeEmitter12Ga
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
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=5.000000,Max=15.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Max=5.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Min=-500.000000,Max=500.000000))
         VelocityLossRange=(X=(Min=20.000000,Max=20.000000),Y=(Min=20.000000,Max=20.000000),Z=(Min=20.000000,Max=20.000000))
         Name="SmokeEmitter12Ga"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SmokeEmitter12Ga'
     Begin Object Class=SpriteEmitter Name=SmokeEmitter12Gb
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
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=5.000000)
         Acceleration=(X=2.000000)
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=10.000000,Max=15.000000),Y=(Min=10.000000,Max=10.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=50.000000,Max=1000.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-50.000000,Max=50.000000))
         VelocityLossRange=(X=(Min=15.000000,Max=15.000000),Y=(Min=15.000000,Max=15.000000),Z=(Min=15.000000,Max=15.000000))
         Name="SmokeEmitter12Gb"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SmokeEmitter12Gb'
     Begin Object Class=SpriteEmitter Name=NoMuzzleEmitter12G
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_Modulated
         MaxParticles=20
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Muzzleflash.12GaugeSparks'
         Acceleration=(Z=-250.000000)
         StartSizeRange=(X=(Min=1.000000,Max=1.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=10.000000,Max=2000.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-200.000000,Max=200.000000))
         VelocityLossRange=(X=(Min=5.000000,Max=5.000000),Y=(Min=3.000000,Max=3.000000),Z=(Min=3.000000,Max=3.000000))
         Name="NoMuzzleEmitter12G"
     End Object
     Emitters(2)=SpriteEmitter'R6SFX.NoMuzzleEmitter12G'
     Begin Object Class=SpriteEmitter Name=WithMuzzleEmitter12G
         UseRotationFrom=PTRS_Actor
         DrawStyle=PTDS_Modulated
         MaxParticles=20
         RespawnDeadParticles=False
         AutomaticInitialSpawning=False
         SecondsBeforeInactive=0.000000
         Texture=Texture'R6SFX_T.Muzzleflash.12GaugeSparks'
         Acceleration=(Z=-250.000000)
         StartSizeRange=(X=(Min=1.000000,Max=1.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=10.000000,Max=2000.000000),Y=(Min=-200.000000,Max=200.000000),Z=(Min=-200.000000,Max=200.000000))
         VelocityLossRange=(X=(Min=5.000000,Max=5.000000),Y=(Min=3.000000,Max=3.000000),Z=(Min=3.000000,Max=3.000000))
         Name="WithMuzzleEmitter12G"
     End Object
     Emitters(3)=SpriteEmitter'R6SFX.WithMuzzleEmitter12G'
     Begin Object Class=SpriteEmitter Name=R61stMuzzleFlash12G
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
         Name="R61stMuzzleFlash12G"
     End Object
     Emitters(4)=SpriteEmitter'R6SFX.R61stMuzzleFlash12G'
     RemoteRole=ROLE_None
     m_bDrawFromBase=True
     m_bTickOnlyWhenVisible=True
}
