class R6MObjKillBombMan extends R6MissionObjectiveBase
    editinlinenew;

var R6Pawn m_pawnBombMan;

function Init()
{
}

function SetBombManPawn(R6Pawn aPawn)
{
    m_pawnBombMan = aPawn;
}

function Reset()
{
    super.Reset();
    m_pawnBombMan = none;
}

function PawnKilled(Pawn killedPawn)
{
    if(R6Pawn(killedPawn) != m_pawnBombMan)
    {
        return;
    }
    R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
    if(m_bShowLog)
    {
        log((("PawnKilled: m_pawnBombMan= " $ string(m_pawnBombMan.Name)) $ " bFailed=") $ string(m_bFailed));
    }
}

defaultproperties
{
    m_bIfCompletedMissionIsSuccessfull=true
    m_bIfFailedMissionIsAborted=true
    m_szDescription="Kill the BombMan"
}
