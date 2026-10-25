//=============================================================================
//  R6MachinePistolsDescription.uc : This is mainly to accelerate the foreach search 
//                                   when populating menu restriction lists 
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/06/20 * Created by Joel Tremblay
//=============================================================================


class R6MachinePistolsDescription extends R6SecondaryWeaponDescription;

defaultproperties
{
     m_MyGadgets(0)=Class'R6Description.R6DescWeaponGadgetNone'
     m_Bullets(0)=Class'R6Description.R6DescBulletNone'
     m_NameID="NONE"
}
