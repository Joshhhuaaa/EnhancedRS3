//=============================================================================
//  R6IODevice : This should allow action moves on a Recon type device
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

class R6IOAlarmSystem extends R6IODevice
	placeable;

var(R6ActionObject) Material m_DisarmedTexture;
var(R6ActionObject) Sound m_DisarmingSound;

simulated function string R6GetCircumstantialActionString( INT iAction )
{
    switch( iAction )
    {
        case eDeviceCircumstantialAction.DCA_DisarmBomb:    return Localize("RDVOrder", "Order_DisarmSystem", "R6Menu");
    }
	
    return "";
}


simulated function ToggleDevice(R6Pawn aPawn)
{
    local INT iAlarmCount;
    if (CanToggle() == false)
        return;
    if (bShowLog) log("Set Device"@Self@"by pawn"@aPawn@"and his controller"@aPawn.controller);

    m_bIsActivated = false;
    if (m_DisarmedTexture != None)
    {
        SetSkin( m_DisarmedTexture, 0 );
    }
    
    PlaySound(m_DisarmingSound, SLOT_SFX);
    m_bToggleType = FALSE;// Can not toggle it anymore

    R6AbstractGameInfo(Level.Game).IObjectInteract(aPawn, Self);
}

defaultproperties
{
}
