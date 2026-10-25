class R6IOProvider extends R6IOObject
    placeable;

var INT m_iMP2DeviceAnim;
var(Debug) BOOL bShowLog;
var FLOAT m_fTimeLeft;
var FLOAT m_fRepTimeLeft;
var FLOAT m_fLastLevelTime;
var FLOAT m_fOxygeneLevelCAStart;
var(R6ActionObject) FLOAT m_fAugmentationPerSecond;
var FLOAT m_fTimeElapsed;
var(R6ActionObject) FLOAT m_fDisarmBombTimeMin;
var(R6ActionObject) FLOAT m_fDisarmBombTimeMax;
var(R6ActionObject) Texture m_ProviderIcon;

replication
{
    reliable if (Role==ROLE_Authority)
        m_fRepTimeLeft;
}

simulated function ResetOriginalData()
{
    if (m_bResetSystemLog) LogResetSystem( false );
    Super.ResetOriginalData();

    m_fTimeLeft = 0;
    m_fRepTimeLeft = 0;
    m_fLastLevelTime = 0;
}

simulated function FLOAT GetTimeLeft()
{
    if (Level.NetMode == NM_Client)
        return m_fRepTimeLeft;
    else
        return m_fTimeLeft;
}

simulated function Timer()
{
    local INT iRemaining;

    Super(R6InteractiveObject).Timer();
}

function ForceTimeLeft(FLOAT fTime)
{
    m_fTimeLeft = fTime;
    m_fRepTimeLeft = fTime;
    m_fLastLevelTime = Level.TimeSeconds;
}

simulated event R6QueryCircumstantialAction( FLOAT fDistance, Out R6AbstractCircumstantialActionQuery Query, PlayerController playerController )
{
    local BOOL      bDisplayBombIcon;
	local vector	vActorDir;
	local vector    vFacingDir;
    local R6Pawn    aPawn;

    if (CanToggle() == false || !m_bRainbowCanInteract )
        return;

    Query.iHasAction = 0;
    aPawn = R6Pawn(playerController.Pawn);

    if(m_bIsActivated)
    {
        Query.iHasAction = 1;
        Query.textureIcon = m_ProviderIcon;
        Query.iPlayerActionID      = eDeviceCircumstantialAction.DCA_DisarmBomb;
        Query.iTeamActionID        = eDeviceCircumstantialAction.DCA_DisarmBomb;
        Query.iTeamActionIDList[0] = eDeviceCircumstantialAction.DCA_DisarmBomb;
    }
    Query.iTeamActionIDList[1] = eDeviceCircumstantialAction.DCA_None;
    Query.iTeamActionIDList[2] = eDeviceCircumstantialAction.DCA_None;
    Query.iTeamActionIDList[3] = eDeviceCircumstantialAction.DCA_None;

    // check if player is within interaction range
    if( fDistance < m_fCircumstantialActionRange )
    {
    	vFacingDir = vector(rotation);
        vFacingDir.Z = 0;
		vActorDir = Normal(location - playerController.Pawn.Location);
        vActorDir.Z = 0;
		if((vActorDir dot vFacingDir) < -0.4)
            Query.iInRange = 1;
        else
            Query.iInRange = 0;
    }
    else
    {
        Query.iInRange = 0;
    }

    Query.bCanBeInterrupted = true;
    Query.fPlayerActionTimeRequired = GetTimeRequired(R6PlayerController(playerController).m_pawn);
}

simulated function ToggleDevice(R6Pawn aPawn)
{
    if (CanToggle() == false)
        return;

    Super.ToggleDevice(aPawn);
    SetTimer(1.0, true);
}

simulated function FLOAT GetMaxTimeRequired()
{
    return m_fDisarmBombTimeMax;
}

simulated function FLOAT GetTimeRequired(R6Pawn aPawn)
{
    local FLOAT fDisarmingBombTime;

    fDisarmingBombTime = (Level.m_fOxygeneTopLevel - R6PlayerController(aPawn.Controller).m_fOxygeneLevel) / m_fAugmentationPerSecond;
    return fDisarmingBombTime;
}

simulated function R6CircumstantialActionProgressStart( R6AbstractCircumstantialActionQuery Query )
{
    m_fPlayerCAStartTime = Level.TimeSeconds;
    m_fOxygeneLevelCAStart = R6PlayerController(Query.aQueryOwner).m_fOxygeneLevel;
    m_fTimeElapsed = 0;
    PerformSoundAction(SIO_Start);
    LockObjectUse(true);
}

simulated function R6CircumstantialActionCancel()
{
    LockObjectUse(false);
    PerformSoundAction(SIO_Interrupt);
}

simulated function INT R6GetCircumstantialActionProgress( R6AbstractCircumstantialActionQuery Query, Pawn actingPawn )
{
    local FLOAT fPercentage;
    local FLOAT foxlevel;
    local FLOAT fTimeElapsed;

    fPercentage = (Level.TimeSeconds - m_fPlayerCAStartTime) / Query.fPlayerActionTimeRequired;
    fTimeElapsed = Level.TimeSeconds - m_fTimeElapsed - m_fPlayerCAStartTime;
    if (fTimeElapsed > 0.5)
    {
        foxlevel = INT(Level.TimeSeconds - m_fPlayerCAStartTime);
        foxlevel *= m_fAugmentationPerSecond;
        foxlevel += m_fOxygeneLevelCAStart;
        if (foxlevel < Level.m_fOxygeneTopLevel)
            R6PlayerController(actingPawn.Controller).addToOxygenLevel(foxlevel);
        m_fTimeElapsed = fTimeElapsed;
    }

    fPercentage *= 100;
    if (fPercentage >= 100)
    {
        R6PlayerController(actingPawn.Controller).addToOxygenLevel(Level.m_fOxygeneTopLevel);
        LockObjectUse(false);
    }

    if ((fPercentage >= 100) && (m_ObjectState != SIO_Complete))
        PerformSoundAction(SIO_Complete);

    return fPercentage;
}

defaultproperties
{
     m_iMP2DeviceAnim=2
     m_fDisarmBombTimeMax=12.000000
     m_eAnimToPlay=BA_Custom
     m_bIsActivated=True
     m_StartSnd=Sound'Foley_Bomb.Play_Bomb_Defusing'
     m_InterruptedSnd=Sound'Foley_Bomb.Stop_Go_Bomb_Defusing'
     m_CompletedSnd=Sound'Foley_Bomb.Stop_Go_Bomb_Defused'
     m_bRainbowCanInteract=True
     m_fSoundRadiusActivation=5600.000000
     m_fCircumstantialActionRange=60.000000
}
