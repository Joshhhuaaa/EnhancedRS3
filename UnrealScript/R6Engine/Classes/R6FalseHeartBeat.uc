class R6FalseHeartBeat extends R6GenericHB
    native;

var float       m_fHeartBeatTime[2];        // Heart Beat time in ms, one for each cicle
var float       m_fHeartBeatFrequency;      // Number of heart beat by minutes.
var int         m_iNoCircleBeat;            // Current circle to be start display

var Pawn		m_HeartBeatPuckOwner;		// set to the player pawn that threw the puck (used instead of Instigator)


simulated function FirstPassReset()
{
    Super.FirstPassReset();
    Destroy();
}

simulated event PostBeginPlay()
{
    if (Level.NetMode != NM_Client)
    {
        m_fHeartBeatTime[0] = Rand(1000/(m_fHeartBeatFrequency/60));
        m_fHeartBeatTime[1] = m_fHeartBeatTime[0];
    }
}

simulated event BOOL ProcessHeart(FLOAT DeltaSeconds, out FLOAT fMul1, out FLOAT fMul2)
{
    local int index;
    local FLOAT fHeartBeatFrenquency;
    local FLOAT fRest;
    local FLOAT fMul[2];
	local BOOL bStartNewBeat;

	bStartNewBeat= false;

    for (index=0; index<2; index++)
        m_fHeartBeatTime[index] += DeltaSeconds * 1000;


    fHeartBeatFrenquency = 1000 / (m_fHeartBeatFrequency / 60);
    if (m_fHeartBeatTime[m_iNoCircleBeat]  > fHeartBeatFrenquency)
    {
        fRest = m_fHeartBeatTime[m_iNoCircleBeat] - fHeartBeatFrenquency;
        m_iNoCircleBeat++;
        if (m_iNoCircleBeat >= 2)
            m_iNoCircleBeat = 0;
        m_fHeartBeatTime[m_iNoCircleBeat] = fRest;
		bStartNewBeat = true;
    }
    
    // Set the size of the scale.
    if (m_fHeartBeatTime[0] < 500)
        fMul1 = 0.0012f * m_fHeartBeatTime[0]; // formule 0.6 / 500 = 0.0012 
    else
        fMul1 = 0.6f;
    if (m_fHeartBeatTime[1] < 500)
        fMul2 = 0.0012f * m_fHeartBeatTime[1]; // formule 0.6 / 500 = 0.0012 
    else
        fMul2 = 0.6f;

	return bStartNewBeat;
}

defaultproperties
{
     m_fHeartBeatFrequency=70.000000
     m_iCurrentState=-1
     m_StateList(0)=(RandomMeshes=((fPercentage=100.000000)),ActorList=((ActorToSpawn=Class'R6SFX.R6BreakablePhone')),SoundList=(Sound'CommonGadget_Explosion.Play_PuckExplode'))
     bBounce=True
     StaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdFalseHBPuck'
}
