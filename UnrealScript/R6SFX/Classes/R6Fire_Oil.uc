//============================================================================//
// Class            R6Fire_Oil
// Created By       Carl Lavoie
//============================================================================//
class R6Fire_Oil extends R6SFX;

defaultproperties
{
     Begin Object Class=SpriteEmitter Name=SpriteFire_Oil_01
         DrawStyle=PTDS_Modulated
         FadeOut=True
         FadeIn=True
         Disabled=True
         SpinParticles=True
         DampRotation=True
         UseSizeScale=True
         UseRegularSizeScale=False
         Texture=Texture'R6SFX_T.Flame.Tower_Flame01'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=2.000000)
         Acceleration=(Z=10.000000)
         StartLocationOffset=(Z=10.000000)
         StartLocationRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000))
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000),Y=(Min=-0.200000,Max=0.200000),Z=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=150.000000,Max=200.000000),Y=(Min=60.000000,Max=60.000000))
         LifetimeRange=(Min=7.000000,Max=7.000000)
         StartVelocityRange=(X=(Min=100.000000,Max=150.000000),Z=(Min=130.000000,Max=150.000000))
         Name="SpriteFire_Oil_01"
     End Object
     Emitters(0)=SpriteEmitter'R6SFX.SpriteFire_Oil_01'
     Begin Object Class=SpriteEmitter Name=SpriteFire_Oil_02
         DrawStyle=PTDS_Modulated
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         DampRotation=True
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         InitialParticlesPerSecond=1.000000
         Texture=Texture'R6SFX_T.Flame.Tower_Flame02'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=2.000000)
         StartLocationOffset=(Z=10.000000)
         StartLocationRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000))
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000),Y=(Min=-0.200000,Max=0.200000),Z=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=150.000000,Max=200.000000),Y=(Min=60.000000,Max=60.000000))
         LifetimeRange=(Min=1.000000,Max=5.000000)
         StartVelocityRange=(X=(Min=100.000000,Max=150.000000),Z=(Min=130.000000,Max=150.000000))
         Name="SpriteFire_Oil_02"
     End Object
     Emitters(1)=SpriteEmitter'R6SFX.SpriteFire_Oil_02'
     Begin Object Class=SpriteEmitter Name=SpriteFire_Oil_03
         DrawStyle=PTDS_Modulated
         FadeOut=True
         FadeIn=True
         SpinParticles=True
         DampRotation=True
         UseSizeScale=True
         UseRegularSizeScale=False
         Texture=Texture'R6SFX_T.Flame.Tower_Flame03'
         SizeScale(0)=(RelativeTime=1.000000,RelativeSize=2.000000)
         Acceleration=(Z=10.000000)
         StartLocationOffset=(Z=10.000000)
         StartLocationRange=(X=(Min=-15.000000,Max=15.000000),Y=(Min=-15.000000,Max=15.000000))
         SpinsPerSecondRange=(X=(Min=-0.200000,Max=0.200000),Y=(Min=-0.200000,Max=0.200000),Z=(Min=-1.000000,Max=1.000000))
         StartSizeRange=(X=(Min=150.000000,Max=200.000000),Y=(Min=60.000000,Max=60.000000))
         LifetimeRange=(Min=7.000000,Max=7.000000)
         StartVelocityRange=(X=(Min=100.000000,Max=150.000000),Z=(Min=130.000000,Max=150.000000))
         Name="SpriteFire_Oil_03"
     End Object
     Emitters(2)=SpriteEmitter'R6SFX.SpriteFire_Oil_03'
     Emitters(3)=None
     m_bDeleteOnReset=False
}
