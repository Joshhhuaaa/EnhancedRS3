class MP2BreakVase extends R6SFX;

defaultproperties
{
    AutoDestroy=true
    Begin Object Class=MeshEmitter Name=MeshEmitter0
        MaxParticles=6
        UseCollision=true
        RespawnDeadParticles=false
        SpinParticles=true
        DampRotation=true
        AutomaticInitialSpawning=false
        FadeOutStartTime=5.0
        InitialParticlesPerSecond=5000.0
        SecondsBeforeInactive=0.0
        Acceleration=(X=0.0,Y=0.0,Z=-1000.0)
        ExtentMultiplier=(X=0.0,Y=0.0,Z=0.0)
        DampingFactorRange=(X=(Min=0.25,Max=0.5),Y=(Min=0.25,Max=0.5),Z=(Min=0.25,Max=0.5))
        SpinsPerSecondRange=(X=(Min=-1.0,Max=1.0),Y=(Min=-1.0,Max=1.0),Z=(Min=-1.0,Max=1.0))
        StartSpinRange=(X=(Min=-1.0,Max=1.0),Y=(Min=-1.0,Max=1.0),Z=(Min=-1.0,Max=1.0))
        StartSizeRange=(X=(Min=1.0,Max=1.5),Y=(Min=1.0,Max=1.5),Z=(Min=1.0,Max=1.5))
        LifetimeRange=(Min=10.0,Max=10.0)
        StartVelocityRange=(X=(Min=-100.0,Max=100.0),Y=(Min=-100.0,Max=100.0),Z=(Min=100.0,Max=400.0))
        VelocityLossRange=(Z=(Max=2.0))
        Name="MeshEmitter0"
    End Object
    Emitters[0]=MeshEmitter'MP2SFX.MeshEmitter0'
    bNetDirty=true
}
