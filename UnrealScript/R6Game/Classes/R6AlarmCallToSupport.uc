/********************************************************************
	created:	2001/11/06
	filename: 	R6AlarmCallToSupport.uc
	author:		Jean-Francois Dube
*********************************************************************/

class R6AlarmCallToSupport extends R6Alarm
    placeable;

var(R6AlarmSettings) enum ETerroristTarget
{
	TT_AlarmPosition,                       // terrorists will go to the alarm position
	TT_GivenPosition                        // terrorists will go to the given position received in parameters
} m_eTerroristTarget;

var(R6AlarmSettings)    INT                  m_iTerroristGroup;
var(R6AlarmSettings)    R6Pawn.eMovementPace m_ePace;
var(R6AlarmSettings)    Array<R6IOSound>     m_IOSoundList;
var(R6AlarmSettings)    Sound                m_sndAlarmSound;
var(R6AlarmSettings)    Sound                m_sndAlarmSoundStop;
var(R6AlarmSettings)    FLOAT                m_fActivationTime;

var                     FLOAT                m_fTimeStart;


//------------------------------------------------------------------
// ResetOriginalData
//	
//------------------------------------------------------------------
simulated function ResetOriginalData()
{
    local INT i;

    if ( m_bResetSystemLog ) LogResetSystem( false );
    Super.ResetOriginalData();

    Disable('Tick');

    for (i=0;i<m_IOSoundList.Length; i++)
    {
        m_IOSoundList[i].AmbientSound = none;
        m_IOSoundList[i].AmbientSoundStop = none;
    }
    m_fTimeStart = 0;
    Disable('Tick');
}


function SetAlarm(vector vLocation)
{
    local R6TerroristAI C;
    local BOOL bStartAlarm;
    local INT i;

    bStartAlarm = false;

    ForEach AllActors(class'R6TerroristAI', C)
    {
        
        if(C.m_pawn.IsAlive() && C.m_pawn.m_iGroupID == m_iTerroristGroup)
        {
            bStartAlarm = true;
            // log("================= SetAlarm called!");
            if(m_eTerroristTarget == TT_AlarmPosition)
            {
                C.GotoPointAndSearch(Location, m_ePace, true);
            }
            else if(m_eTerroristTarget == TT_GivenPosition)
            {
                C.GotoPointAndSearch(vLocation, m_ePace, true);
            }
        }
    }
    
    // Check if the arlarm is activated and play the the sound
    if (bStartAlarm)
    {
        for (i=0;i<m_IOSoundList.Length; i++)
        {
            m_IOSoundList[i].AmbientSound = m_sndAlarmSound;
            m_IOSoundList[i].AmbientSoundStop = m_sndAlarmSoundStop;
        }

        m_fTimeStart = 0;
        Enable('Tick');
    }
}


function Tick(FLOAT fDeltaTime)
{
    local INT i;

    m_fTimeStart += fDeltaTime;

    if ( m_fTimeStart > m_fActivationTime)
    {
        // Stop the arlarm after a certain time
        for (i=0;i<m_IOSoundList.Length; i++)
        {
            m_IOSoundList[i].AmbientSound = none;
        }
        Disable('Tick');
    }
}

Auto State StartUp
{
Begin:
    Disable('Tick');
}

defaultproperties
{
     m_eTerroristTarget=TT_GivenPosition
     m_ePace=PACE_Run
}
