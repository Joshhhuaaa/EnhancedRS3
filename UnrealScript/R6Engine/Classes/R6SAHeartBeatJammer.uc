class R6SAHeartBeatJammer extends R6GenericHB
    native;

simulated function FirstPassReset()
{
    Super.FirstPassReset();
    Destroy();
}

defaultproperties
{
     m_iCurrentState=-1
     m_StateList(0)=(RandomMeshes=((fPercentage=100.000000)),ActorList=((ActorToSpawn=Class'R6SFX.R6BreakablePhone')),SoundList=(Sound'CommonGadget_Explosion.Play_PuckExplode'))
     StaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdHBSensorSA_Jamer'
}
