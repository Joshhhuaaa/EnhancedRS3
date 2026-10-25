//============================================================================//
// Class            R6MuzzleFlash50M33
// Created By       Carl Lavoie
// Date             12/18/2001
// Description      Smoke and Muzzle for 50M33 caliber
//----------------------------------------------------------------------------//
// Modification History
//
//============================================================================//
class R6MuzzleFlash50M33 extends R6SFX;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SmokeEmitter50a
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
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=5.000000,Max=15.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Max=5.000000),Y=(Min=-500.000000,Max=500.000000),Z=(Min=-500.000000,Max=500.000000))
         VelocityLossRange=(X=(Min=20.000000,Max=20.000000),Y=(Min=20.000000,Max=20.000000),Z=(Min=20.000000,Max=20.000000))
         Name="SmokeEmitter50a"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SmokeEmitter50a'
     Begin Object Class=SpriteEmitter Name=SmokeEmitter50b
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
         SpinsPerSecondRange=(X=(Min=-0.100000,Max=0.100000))
         StartSizeRange=(X=(Min=10.000000,Max=15.000000),Y=(Min=10.000000,Max=10.000000))
         LifetimeRange=(Min=1.000000,Max=1.000000)
         StartVelocityRange=(X=(Min=50.000000,Max=1000.000000),Y=(Min=-50.000000,Max=50.000000),Z=(Min=-50.000000,Max=50.000000))
         VelocityLossRange=(X=(Min=15.000000,Max=15.000000),Y=(Min=15.000000,Max=15.000000),Z=(Min=15.000000,Max=15.000000))
         Name="SmokeEmitter50b"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SmokeEmitter50b'
     Begin Object Class=SpriteEmitter Name=NoMuzzleEmitter50
         UseDirectionAs=PTDU_Right
         CoordinateSystem=PTCS_Relative
         MaxParticles=1
         FadeOut=True
         RespawnDeadParticles=False
         DampRotation=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Texture=Texture'R6SFX_T.Muzzleflash.MuzzleFlashB'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=1.000000)
         Acceleration=(X=6000.000000)
         StartLocationOffset=(X=20.000000)
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000),Y=(Min=-0.200000,Max=0.200000),Z=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=10.000000,Max=50.000000),Y=(Min=10.000000,Max=15.000000))
         LifetimeRange=(Min=0.100000,Max=0.100000)
         Name="NoMuzzleEmitter50"
     End Object
     Emitters(2)=SpriteEmitter'R6SFX.NoMuzzleEmitter50'
     Begin Object Class=SpriteEmitter Name=WithMuzzleEmitter50
         MaxParticles=1
         FadeOut=True
         RespawnDeadParticles=False
         SpinParticles=True
         DampRotation=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Texture=Texture'R6SFX_T.Muzzleflash.MuzzleFlashC'
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000),Y=(Min=-0.200000,Max=0.200000),Z=(Min=-1.000000,Max=1.000000))
         StartSpinRange=(X=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=10.000000,Max=30.000000))
         LifetimeRange=(Min=0.100000,Max=0.100000)
         Name="WithMuzzleEmitter50"
     End Object
     Emitters(3)=SpriteEmitter'R6SFX.WithMuzzleEmitter50'
     Begin Object Class=SpriteEmitter Name=R61stMuzzleFlash50
         CoordinateSystem=PTCS_Relative
         DrawStyle=PTDS_AlphaBlend
         MaxParticles=5
         FadeOut=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         Texture=Texture'R6SFX_T.Muzzleflash.1stMuzzle_C'
         SpinCCWorCW=(X=0.000000,Y=0.000000,Z=0.000000)
         StartSizeRange=(X=(Min=60.000000,Max=75.000000))
         LifetimeRange=(Min=0.100000,Max=0.200000)
         Name="R61stMuzzleFlash50"
     End Object
     Emitters(4)=SpriteEmitter'R6SFX.R61stMuzzleFlash50'
     RemoteRole=ROLE_None
     m_bDrawFromBase=True
     m_bTickOnlyWhenVisible=True
}
