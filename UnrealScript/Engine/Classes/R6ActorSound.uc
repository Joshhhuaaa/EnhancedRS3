//============================================================================//
// Class            R6ActorSound.uc
//----------------------------------------------------------------------------//
//============================================================================//

class R6ActorSound extends Actor;

var ESoundSlot m_eTypeSound;     
var sound m_ImpactSound;
var sound m_ImpactSoundStop;
var FLOAT m_fExplosionDelay;

replication
{
	// Things the server should send to the client.
	unreliable if( Role==ROLE_Authority )
		m_ImpactSound, m_ImpactSoundStop, m_fExplosionDelay, m_eTypeSound;
}

simulated function Timer()
{
    if (m_ImpactSoundStop != none)
    {
        PlaySound(m_ImpactSoundStop, m_eTypeSound);
        m_ImpactSound = m_ImpactSoundStop;
        m_ImpactSoundStop = none;
    }
    else
    {
        if (IsPlayingSound(Self, m_ImpactSound))
            SetTimer(2,false);
        else
		{
            SetTimer(0, false);
		}
	}
}

simulated function SpawnSound()
{
    //ResetVolume_AllTypeSound();

    PlaySound(m_ImpactSound, m_eTypeSound);
    
    SetTimer(m_fExplosionDelay, false);
}
    

Auto State StartUp
{
	simulated function Tick(float DeltaTime)
	{
		if ( Level.NetMode != NM_DedicatedServer )
		{
			SpawnSound();
		}
        LifeSpan = m_fExplosionDelay + 10; // Add 10 seconde for the smoke grenade fade

		Disable('Tick');
	}
}

simulated function FirstPassReset()
{
    Destroy();
}

defaultproperties
{
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_None
     bHidden=True
     bNetOptional=True
     bAlwaysRelevant=True
     m_bDeleteOnReset=True
     m_fSoundRadiusActivation=5600.000000
     Texture=None
}
