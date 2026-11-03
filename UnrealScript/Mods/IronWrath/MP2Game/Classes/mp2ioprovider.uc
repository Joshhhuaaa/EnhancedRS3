class mp2ioprovider extends R6IOObject;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Textures\MP2ActionIcons.utx PACKAGE=MP2ActionIcons
#exec OBJ LOAD FILE=..\Sounds\Foley_Bomb.uax PACKAGE=Foley_Bomb
#exec OBJ LOAD FILE=..\Mods\IronWrath\StaticMeshes\MP2ActionObjects.usx PACKAGE=MP2ActionObjects

var int m_iMP2DeviceAnim;
var(Debug) bool bShowLog;
var float m_fTimeLeft;
var float m_fRepTimeLeft;
var float m_fLastLevelTime;
var float m_fOxygeneLevelCAStart;
var(R6ActionObject) float m_fAugmentationPerSecond;
var float m_fTimeElapsed;
var(R6ActionObject) float m_fDisarmBombTimeMin;
var(R6ActionObject) float m_fDisarmBombTimeMax;

replication
{
    reliable if(Role == ROLE_Authority)
        m_fRepTimeLeft;
}

simulated function ResetOriginalData()
{
    if(m_bResetSystemLog)
    {
        LogResetSystem(false);
    }
    super.ResetOriginalData();
    m_fTimeLeft = 0.0;
    m_fRepTimeLeft = 0.0;
    m_fLastLevelTime = 0.0;
}

simulated function float GetTimeLeft()
{
    if(Level.NetMode == NM_Client)
    {
        return m_fRepTimeLeft;
    }
    else
    {
        return m_fTimeLeft;
    }
}

simulated function Timer()
{
    local int iRemaining;

    super(R6InteractiveObject).Timer();
}

function ForceTimeLeft(float fTime)
{
    m_fTimeLeft = fTime;
    m_fRepTimeLeft = fTime;
    m_fLastLevelTime = Level.TimeSeconds;
}

simulated event R6QueryCircumstantialAction(float fDistance, out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController)
{
    local bool bDisplayBombIcon;
    local Vector vActorDir, vFacingDir;
    local R6Pawn aPawn;

    if(((CanToggle()) == false) || !m_bRainbowCanInteract)
    {
        return;
    }
    Query.iHasAction = 0;
    aPawn = R6Pawn(PlayerController.Pawn);
    if(m_bIsActivated)
    {
        Query.iHasAction = 1;
        Query.textureIcon = Texture'MP2ActionIcons.breathe';
        Query.iPlayerActionID = 1;
        Query.iTeamActionID = 1;
        Query.iTeamActionIDList[0] = 1;
    }
    Query.iTeamActionIDList[1] = 0;
    Query.iTeamActionIDList[2] = 0;
    Query.iTeamActionIDList[3] = 0;
    if(fDistance < m_fCircumstantialActionRange)
    {
        vFacingDir = Vector(Rotation);
        vFacingDir.Z = 0.0;
        vActorDir = Normal(Location - PlayerController.Pawn.Location);
        vActorDir.Z = 0.0;
        if((vActorDir Dot vFacingDir) < -0.4)
        {
            Query.iInRange = 1;
        }
        else
        {
            Query.iInRange = 0;
        }
    }
    else
    {
        Query.iInRange = 0;
    }
    Query.bCanBeInterrupted = true;
    Query.fPlayerActionTimeRequired = GetTimeRequired(R6PlayerController(PlayerController).m_pawn);
}

simulated function ToggleDevice(R6Pawn aPawn)
{
    if((CanToggle()) == false)
    {
        return;
    }
    super.ToggleDevice(aPawn);
    SetTimer(1.0, true);
}

simulated function float GetMaxTimeRequired()
{
    return m_fDisarmBombTimeMax;
}

simulated function float GetTimeRequired(R6Pawn aPawn)
{
    local float fDisarmingBombTime;

    fDisarmingBombTime = (Level.m_fOxygeneTopLevel - MP2PlayerController(aPawn.Controller).m_fOxygeneLevel) / m_fAugmentationPerSecond;
    return fDisarmingBombTime;
}

simulated function R6CircumstantialActionProgressStart(R6AbstractCircumstantialActionQuery Query)
{
    m_fPlayerCAStartTime = Level.TimeSeconds;
    m_fOxygeneLevelCAStart = MP2PlayerController(Query.aQueryOwner).m_fOxygeneLevel;
    m_fTimeElapsed = 0.0;
    PerformSoundAction(SIO_Start);
    LockObjectUse(true);
}

simulated function R6CircumstantialActionCancel()
{
    LockObjectUse(false);
    PerformSoundAction(SIO_Interrupt);
}

simulated function int R6GetCircumstantialActionProgress(R6AbstractCircumstantialActionQuery Query, Pawn actingPawn)
{
    local float fPercentage, foxlevel, fTimeElapsed;

    fPercentage = (Level.TimeSeconds - m_fPlayerCAStartTime) / Query.fPlayerActionTimeRequired;
    fTimeElapsed = (Level.TimeSeconds - m_fTimeElapsed) - m_fPlayerCAStartTime;
    if(fTimeElapsed > 0.5)
    {
        foxlevel = float(int(Level.TimeSeconds - m_fPlayerCAStartTime));
        foxlevel *= m_fAugmentationPerSecond;
        foxlevel += m_fOxygeneLevelCAStart;
        if(foxlevel < Level.m_fOxygeneTopLevel)
        {
            MP2PlayerController(actingPawn.Controller).addToOxygenLevel(foxlevel);
        }
        m_fTimeElapsed = fTimeElapsed;
    }
    fPercentage *= float(100);
    if(fPercentage >= float(100))
    {
        MP2PlayerController(actingPawn.Controller).addToOxygenLevel(Level.m_fOxygeneTopLevel);
        LockObjectUse(false);
    }
    if((fPercentage >= float(100)) && m_ObjectState != SIO_Complete)
    {
        PerformSoundAction(SIO_Complete);
    }
    return int(fPercentage);
}

defaultproperties
{
    m_iMP2DeviceAnim=2
    m_fAugmentationPerSecond=20.0
    m_fDisarmBombTimeMax=12.0
    m_eAnimToPlay=BA_Custom
    m_bIsActivated=true
    m_StartSnd=Sound'Foley_Bomb.Play_Bomb_Defusing'
    m_InterruptedSnd=Sound'Foley_Bomb.Stop_Go_Bomb_Defusing'
    m_CompletedSnd=Sound'Foley_Bomb.Stop_Go_Bomb_Defused'
    m_bRainbowCanInteract=true
    m_fSoundRadiusActivation=5600.0
    m_fCircumstantialActionRange=60.0
    StaticMesh=StaticMesh'MP2ActionObjects.Provider.Provider'
}
