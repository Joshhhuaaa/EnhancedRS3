class MP2MObjObjectsInteraction extends R6MissionObjectiveBase
    editinlinenew;

#exec OBJ LOAD FILE=..\Sounds\Voices_Control_MissionFailed.uax PACKAGE=Voices_Control_MissionFailed

var() bool m_bIfDeviceIsActivatedObjectiveIsCompleted;
var() bool m_bIfDeviceIsActivatedObjectiveIsFailed;
var() bool m_bIfDeviceIsDeactivatedObjectiveIsCompleted;
var() bool m_bIfDeviceIsDeactivatedObjectiveIsFailed;
var() bool m_bIfDestroyedObjectiveIsCompleted;
var() bool m_bIfDestroyedObjectiveIsFailed;
var string m_szMP2Localization;

function IObjectInteract(Pawn aPawn, Actor anInteractiveObject)
{
    local MP2IODevice ioDevice;
    local int iNbTerminals, iNbTerminalsDesactivated, iNbTerminalsLeft;

    iNbTerminals = 0;
    iNbTerminalsDesactivated = 0;
    foreach aPawn.AllActors(Class'R6Engine.MP2IODevice', ioDevice)
    {
        iNbTerminals++;
        if(ioDevice.m_bIsActivated == false)
        {
            iNbTerminalsDesactivated++;
        }
    }
    if(iNbTerminalsDesactivated == iNbTerminals)
    {
        R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, true, true);
    }
}

defaultproperties
{
    m_szMP2Localization="IronWrathMissionObjectives"
    m_sndSoundFailure=Sound'Voices_Control_MissionFailed.Play_MissionFailed'
    m_szDescription="Interact with object"
}
