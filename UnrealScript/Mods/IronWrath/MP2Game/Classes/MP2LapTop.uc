class MP2LapTop extends R6IODevice;

#exec OBJ LOAD FILE=..\Mods\IronWrath\StaticMeshes\MP2ActionObjects.usx PACKAGE=MP2ActionObjects

simulated event R6QueryCircumstantialAction(float fDistance, out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController)
{
    local bool bDisplayBombIcon;
    local Vector vActorDir, vFacingDir;

    if(R6GameReplicationInfo(PlayerController.GameReplicationInfo).m_szGameTypeFlagRep == "RGM_VirusUploadAdvMode")
    {
        if((R6PlayerController(PlayerController).m_TeamSelection != PTS_Alpha) || !MP2Rainbow(MP2PlayerController(PlayerController).m_pawn).m_bHasDataObject)
        {
            return;
        }
    }
    if(((CanToggle()) == false) || !m_bRainbowCanInteract)
    {
        return;
    }
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
    Query.iPlayerActionID = eDeviceCircumstantialAction.DCA_Device;
    Query.iTeamActionID = eDeviceCircumstantialAction.DCA_Device;
    Query.iTeamActionIDList[0] = eDeviceCircumstantialAction.DCA_Device;
    Query.iTeamActionIDList[1] = eDeviceCircumstantialAction.DCA_None;
    Query.iTeamActionIDList[2] = eDeviceCircumstantialAction.DCA_None;
    Query.iTeamActionIDList[3] = eDeviceCircumstantialAction.DCA_None;
    if(fDistance < m_fCircumstantialActionRange)
    {
        vFacingDir = Vector(Rotation);
        vFacingDir.Z = 0.0;
        vActorDir = Normal(Location - PlayerController.Pawn.Location);
        vActorDir.Z = 0.0;
        if((vActorDir Dot vFacingDir) > 0.85)
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

defaultproperties
{
    m_bRainbowCanInteract=true
    StaticMesh=StaticMesh'MP2ActionObjects.MP2Terminal.LapTop'
}
