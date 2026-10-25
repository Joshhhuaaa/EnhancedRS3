//=============================================================================
//  R6DescPrimaryWeaponNone.uc : No primary weapon selected
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/27 * Created by Alexandre Dionne
//=============================================================================


class R6DescPrimaryWeaponNone extends R6PrimaryWeaponDescription;

defaultproperties
{
     m_ARangePercent(0)=0
     m_ADamagePercent(0)=0
     m_AAccuracyPercent(0)=0
     m_ARecoilPercent(0)=0
     m_ARecoveryPercent(0)=0
     m_MyGadgets(0)=Class'R6Description.R6DescWeaponGadgetNone'
     m_Bullets(0)=Class'R6Description.R6DescBulletNone'
     m_NameID="NONE"
     m_ClassName="R63rdWeapons.None"
}
