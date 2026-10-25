//=============================================================================
//  R6MuzzleGadget.uc : This is the base Class for all Silencer.
//                        this class uses the Subgun silencer.  
//                        For other meshes overload this one
//  Copyright 2001-2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/3/20 * Created by Serge Dore
//=============================================================================
class R6MuzzleGadget extends R6AbstractGadget;

var Actor m_FPMuzzelModel;
var (R6Attachment) class<Actor> m_pFPMuzzleClass;

replication
{
    reliable if (bNetOwner && Role==Role_Authority)
        m_FPMuzzelModel;
}

simulated event Destroyed()
{
    Super.Destroyed();
    DestroyFPGadget();
}

simulated function UpdateAttachment( R6EngineWeapon weapOwner )
{
    local vector vTagLocation;
    local rotator rTagRotator;    

    Super.UpdateAttachment( weapOwner );

    SetBase( none );
    SetBase( weapOwner, weapOwner.Location );

    //Use Muzzle tag for the silencer.
    weapOwner.GetTagInformations( "TagMuzzle", vTagLocation, rTagRotator );
    SetRelativeLocation(vTagLocation);
    SetRelativeRotation(rTagRotator);
}

simulated function AttachFPGadget()
{
    if((m_WeaponOwner == none) || (R6AbstractWeapon(m_WeaponOwner).m_FPWeapon == none))
    {
        return;
    }

    if (m_FPMuzzelModel == none)
    {
        if (m_pFPMuzzleClass != none)
        {
            m_FPMuzzelModel = Spawn(m_pFPMuzzleClass);
        }
    }
    if (m_FPMuzzelModel != none)
    {
        R6AbstractWeapon(m_WeaponOwner).m_FPWeapon.AttachToBone(m_FPMuzzelModel, 'TagMuzzle');
    }

}

simulated function DestroyFPGadget()
{
    local actor temp;
    if (m_FPMuzzelModel != none)
    {
        temp = m_FPMuzzelModel;
        m_FPMuzzelModel = none;
        temp.Destroy();
    }
}

defaultproperties
{
     m_eGadgetType=GAD_Muzzle
     m_NameID="Muzzle"
     m_bDrawFromBase=True
}
