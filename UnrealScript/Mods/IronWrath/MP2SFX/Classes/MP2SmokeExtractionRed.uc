class MP2SmokeExtractionRed extends R6SFX;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Textures\MP2SFX_T.utx PACKAGE=MP2SFX_T

defaultproperties
{
    Begin Object Class=SpriteEmitter Name=SpriteEmitterSmokeExtraction2
        DrawStyle=PTDS_AlphaBlend
        MaxParticles=20
        FadeOut=true
        FadeIn=true
        SpinParticles=true
        UseSizeScale=true
        UseRegularSizeScale=false
        AutomaticInitialSpawning=false
        FadeOutStartTime=15.0
        FadeInEndTime=2.0
        InitialParticlesPerSecond=1.0
        SecondsBeforeInactive=0.0
        Texture=Texture'MP2SFX_T.Grenade.Smoke_Extraction_red'
        SizeScale[0]=(RelativeTime=1.0,RelativeSize=10.0)
        Acceleration=(X=-5.0,Y=0.0,Z=5.0)
        DampingFactorRange=(X=(Min=-1.0,Max=1.0),Y=(Min=-1.0,Max=1.0),Z=(Min=-1.0,Max=1.0))
        StartLocationOffset=(X=20.0,Y=0.0,Z=0.0)
        SpinCCWorCW=(X=0.0,Y=0.0,Z=0.0)
        SpinsPerSecondRange=(X=(Min=-0.05,Max=0.05),Y=(Min=-0.05,Max=0.05))
        StartSizeRange=(X=(Min=5.0,Max=20.0),Y=(Min=100.0,Max=100.0),Z=(Min=100.0,Max=100.0))
        LifetimeRange=(Min=20.0,Max=25.0)
        StartVelocityRange=(X=(Min=20.0,Max=50.0),Y=(Min=-10.0,Max=10.0))
        VelocityLossRange=(X=(Max=1.5),Y=(Max=1.0),Z=(Min=0.2,Max=0.2))
        Name="SpriteEmitterSmokeExtraction2"
    End Object
    Emitters[0]=SpriteEmitter'MP2SFX.SpriteEmitterSmokeExtraction2'
    bNetDirty=true
    bAlwaysRelevant=true
    m_bDeleteOnReset=false
}
