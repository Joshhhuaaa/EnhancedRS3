class MP2MObjCaptureTerrorist extends R6MObjNeutralizeTerrorist
    editinlinenew;

function PawnSecure(Pawn secured)
{
    local float fNeutralized;
    local int iTotal;
    local R6Terrorist aTerrorist;
    local int i, iResult;

    if(secured.m_ePawnType != PAWN_Terrorist)
    {
        return;
    }
    if(m_depZone != none)
    {
        aTerrorist = R6Terrorist(secured);
        if(m_depZone != aTerrorist.m_DZone)
        {
            return;
        }
        i = 0;

        while(i < m_depZone.m_aTerrorist.Length)
        {
            aTerrorist = m_depZone.m_aTerrorist[i];
            if(m_bMustSecureTerroInDepZone)
            {
                if(!aTerrorist.IsAlive())
                {
                    R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, false, true);
                    if(m_bShowLog)
                    {
                        logX(("PawnKilled failed=" $ string(m_bFailed)) $ " should have been secured");
                    }
                    return;
                }
                if(aTerrorist.m_bIsKneeling || aTerrorist.m_bIsUnderArrest)
                {
                    aTerrorist.SetCollision(false, false, false);
                    fNeutralized += float(1);
                }
            }
            else
            {
                if((!aTerrorist.IsAlive() || aTerrorist.m_bIsKneeling) || aTerrorist.m_bIsUnderArrest)
                {
                    fNeutralized += float(1);
                }
            }
            ++iTotal;
            ++i;
        }
    }
    else
    {
        fNeutralized = float(R6GameInfo(m_mgr.Level.Game).GetNbTerroNeutralized());
        foreach m_mgr.DynamicActors(Class'R6Engine.R6Terrorist', aTerrorist)
        {
            ++iTotal;
        }
    }
    if(iTotal > 0)
    {
        iResult = int((fNeutralized / float(iTotal)) * 100.0);
        if(iResult >= m_iNeutralizePercentage)
        {
            R6MissionObjectiveMgr(m_mgr).SetMissionObjCompleted(self, true, true);
        }
    }
    if(m_bShowLog)
    {
        logX(((((((("PawnSecured/Killed. completed=" $ string(m_bCompleted)) $ " neutralized=") $ string(secured.Name)) $ " ") $ string(iResult)) $ "/") $ string(m_iNeutralizePercentage)) $ "%");
    }
}

defaultproperties
{
    m_bMoralityObjective=true
    m_szDescriptionFailure="TheLeaderWasKilled"
}
