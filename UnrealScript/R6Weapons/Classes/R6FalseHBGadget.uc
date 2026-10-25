//===============================================================================
// [R6FalseHBGadget.uc] False Heart Beat Gadget
//===============================================================================

class R6FalseHBGadget extends R6GrenadeWeapon; 

function ThrowGrenade()
{
    local vector    vStart; 
    local rotator   rFiringDir; 
    local R6Pawn    PawnOwner;
    local R6FalseHeartBeat aFalseHeartBeat;

    PawnOwner = R6Pawn(Owner);
	
    if (m_iNbBulletsInWeapon > 0)
    {
        m_iNbBulletsInWeapon--;

        if (m_iNbBulletsInWeapon==0)
        {
            SetStaticMesh(none);
        }
        
        //Get the firing direction vStart is used as temporary variable
        GetFiringDirection(vStart, rFiringDir);

        //Get start location.
		if(PawnOwner.m_bIsPlayer)
			vStart = PawnOwner.GetGrenadeStartLocation(m_eThrow);
		else
		    vStart = PawnOwner.GetHandLocation();

	    aFalseHeartBeat = Spawn( class'R6FalseHeartBeat', Self,, vStart,rFiringDir );
		
		// IMPORTANT : Instigator must be set to none.  Otherwise, false HB Puck (PHYS_Falling) will start to rotate when Instigator dies.
		aFalseHeartBeat.Instigator = none;
		aFalseHeartBeat.m_HeartBeatPuckOwner = Pawn(Owner);

        if(PawnOwner.m_bIsProne == true)
        {
            aFalseHeartBeat.SetSpeed(m_fMuzzleVelocity*0.5);
        }
        else
        {
            aFalseHeartBeat.SetSpeed(m_fMuzzleVelocity);
        }
        ClientThrowGrenade();
    }
}

defaultproperties
{
     m_bPinToRemove=False
     m_fMuzzleVelocity=1000.000000
     m_pFPHandsClass=Class'R61stWeapons.R61stHandsGripFalseHBPuck'
     m_pFPWeaponClass=Class'R61stWeapons.R61stFalseHBPuck'
     m_EquipSnd=Sound'Foley_FragGrenade.Play_Frag_Equip'
     m_UnEquipSnd=Sound'Foley_FragGrenade.Play_Frag_Unequip'
     m_HUDTexture=Texture'R6HUD.HUDElements'
     m_AttachPoint="TagHBPuck"
     m_HUDTexturePos=(W=32.000000,Y=353.000000,Z=100.000000)
     m_NameID="FalseHBGadget"
     DrawScale=1.100000
     StaticMesh=StaticMesh'R63rdWeapons_SM.Items.R63rdFalseHBPuck'
}
