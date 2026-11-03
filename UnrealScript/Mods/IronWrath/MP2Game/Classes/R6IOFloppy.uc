class R6IOFloppy extends R6IOObject
    native;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Textures\MP2ActionIcons.utx PACKAGE=MP2ActionIcons
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

event PostBeginPlay()
{
    bHidden = true;
    SetTimer(1.0, true);
    SetCollision(false, false, false);
    SetCollisionSize(0.0, 0.0);
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

event Tick(float DeltaTime)
{
    if(Role == ROLE_Authority)
    {
        if(((Owner != none) && Level.m_bShowFloppy == false) && MP2PlayerController(Owner).m_pawn != none)
        {
            SetLocation(MP2PlayerController(Owner).m_pawn.Location);
        }
    }
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

    if(R6PlayerController(PlayerController).m_TeamSelection != PTS_Alpha)
    {
        return;
    }
    if(((CanToggle()) == false) || !m_bRainbowCanInteract)
    {
        return;
    }
    Query.iHasAction = 0;
    aPawn = R6Pawn(PlayerController.Pawn);
    if(m_bIsActivated)
    {
        Query.iHasAction = 1;
        Query.textureIcon = Texture'MP2ActionIcons.icones_disquette';
        Query.iPlayerActionID = 1;
        Query.iTeamActionID = 1;
        Query.iTeamActionIDList[0] = 1;
    }
    Query.iTeamActionIDList[1] = 0;
    Query.iTeamActionIDList[2] = 0;
    Query.iTeamActionIDList[3] = 0;
    if(fDistance < m_fCircumstantialActionRange)
    {
        Query.iInRange = 1;
    }
    else
    {
        Query.iInRange = 0;
    }
    Query.bCanBeInterrupted = true;
    Query.fPlayerActionTimeRequired = GetTimeRequired(R6PlayerController(PlayerController).m_pawn);
}

simulated function bool CanToggle()
{
    local bool bCanToggle;

    bCanToggle = (sm_bIsActivated == m_bIsActivated) || m_bToggleType == true;
    return bCanToggle;
}

function int R6GetCircumstantialActionProgress(R6AbstractCircumstantialActionQuery Query, Pawn actingPawn)
{
    local name Anim;
    local float fFrame, fRate;

    actingPawn.GetAnimParams(R6Pawn(actingPawn).C_iBaseBlendAnimChannel, Anim, fFrame, fRate);
    Clamp(int(fFrame), 0, 100);
    return int(fFrame * float(100));
}

simulated function ToggleDevice(R6Pawn aPawn)
{
    if((CanToggle()) == false)
    {
        return;
    }
    super.ToggleDevice(aPawn);
    MP2Rainbow(aPawn).TakeObject1();
    m_eAnimToPlay = BA_Custom;
    if(Role == ROLE_Authority)
    {
        if(aPawn.Controller != none)
        {
            SetOwner(R6PlayerController(aPawn.Controller));
            bHidden = true;
            SetCollision(false, false, false);
        }
    }
}

simulated function float GetMaxTimeRequired()
{
    return m_fDisarmBombTimeMax;
}

simulated function float GetTimeRequired(R6Pawn aPawn)
{
    local float fDisarmingBombTime;

    fDisarmingBombTime = 2.0;
    return fDisarmingBombTime;
}

simulated function StartFalling(Vector vPawnLocWhenKilled)
{
    local Vector vLocation, vDir;
    local Rotator rRot;

    bHidden = false;
    SetCollisionSize(35.0, 55.0);
    vLocation = Location;
    if(FindSpot(vLocation))
    {
        SetLocation(vLocation);
        SetCollision(true, false, false);
        bCollideWorld = true;
        bBounce = true;
        Enable('HitWall');
        SetPhysics(PHYS_Falling);
        vDir = Vector(Rotation);
        vDir.X += RandRange(-0.4, 0.4);
        vDir.Y += RandRange(-0.4, 0.4);
        vDir *= RandRange(100.0, 400.0);
        vDir.Z = -600.0;
        Acceleration = vDir;
        bFixedRotationDir = true;
        RotationRate.Pitch = 0;
        RotationRate.Yaw = int(RandRange(-65535.0, 65535.0));
        RotationRate.Roll = int(RandRange(-65535.0, 65535.0));
        rRot = Rotation;
        rRot.Pitch = 0;
        SetRotation(rRot);
    }
    else
    {
        SetLocation(vPawnLocWhenKilled, true);
    }
}

defaultproperties
{
    m_iMP2DeviceAnim=1
    m_fDisarmBombTimeMin=5.0
    m_fDisarmBombTimeMax=12.0
    m_eAnimToPlay=BA_Custom
    m_bIsActivated=true
    m_bRainbowCanInteract=true
    bNoDelete=false
    bUpdateSimulatedPosition=true
    bCollideWorld=true
    CollisionRadius=35.0
    StaticMesh=StaticMesh'MP2ActionObjects.Floppy.Floppy'
}
