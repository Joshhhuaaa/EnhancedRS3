class MP2IODevice extends R6IODevice
    placeable;

var(IntruderMode) INT m_iTerminalIndex;

simulated event R6QueryCircumstantialAction( FLOAT fDistance, Out R6AbstractCircumstantialActionQuery Query, PlayerController playerController )
{
    local BOOL      bDisplayBombIcon;
	local vector	vActorDir;
	local vector    vFacingDir;

    if (R6PlayerController(playerController).m_TeamSelection != PTS_Alpha)
        return;

    if (CanToggle() == false || !m_bRainbowCanInteract )
        return;

	if(m_bIsActivated)
	{
		Query.iHasAction = 1;
	}
	else
	{
		Query.iHasAction = 0;
		return;
	}

    Query.textureIcon = m_InteractionIcon;
    Query.iPlayerActionID      = eDeviceCircumstantialAction.DCA_Device;
    Query.iTeamActionID        = eDeviceCircumstantialAction.DCA_Device;
    Query.iTeamActionIDList[0] = eDeviceCircumstantialAction.DCA_Device;
    Query.iTeamActionIDList[1] = eDeviceCircumstantialAction.DCA_None;
    Query.iTeamActionIDList[2] = eDeviceCircumstantialAction.DCA_None;
    Query.iTeamActionIDList[3] = eDeviceCircumstantialAction.DCA_None;

    // check if player is within interaction range
    if( fDistance < m_fCircumstantialActionRange )
    {
    	vFacingDir = vector(rotation);
        vFacingDir.Z = 0;
        vFacingDir = Normal(vFacingDir);
		vActorDir = location - playerController.Pawn.Location;
        vActorDir.Z = 0;
        vActorDir = Normal(vActorDir);
		if((vActorDir dot vFacingDir) > 0.85)
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

simulated function FLOAT GetTimeRequired(R6Pawn aPawn)
{
    local FLOAT fPlantingTime;

    if (bShowLog) log("GetTimeRequired"@ m_fPlantTimeMin @ aPawn @ aPawn.GetSkill(SKILL_Electronics));
    fPlantingTime = m_fPlantTimeMin + ((1 - aPawn.GetSkill(SKILL_Electronics)) * (m_fPlantTimeMax-m_fPlantTimeMin));

    if(HasKit(aPawn) && (fPlantingTime - m_fGainTimeWithElectronicsKit > 0))
        fPlantingTime -= m_fGainTimeWithElectronicsKit;

    if(R6Rainbow(aPawn).m_bIsTheIntruder == true)
        fPlantingTime = m_fPlantTimeMin;
    else
        fPlantingTime = m_fPlantTimeMax;

    return fPlantingTime;
}

function INT R6TakeDamage( INT iKillValue, INT iStunValue, Pawn instigatedBy, vector vHitLocation, vector vMomentum, INT iBulletToArmorModifier, optional INT iBulletGoup )
{
    if(m_bBulletGoThrough == true)
        return iKillValue;
    else
        return 0;
}

defaultproperties
{
     m_iTerminalIndex=1
     m_fPlantTimeMin=1.000000
     m_bRainbowCanInteract=True
     CollisionRadius=45.000000
     CollisionHeight=45.000000
     m_fCircumstantialActionRange=28.000000
}
