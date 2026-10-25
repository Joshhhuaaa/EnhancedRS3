//=============================================================================
//  R6RMediumWinterHelmet.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/24 * Created by Rima Brek
//=============================================================================
class R6RMediumWinterHelmet extends R6RHelmet;

#exec NEW StaticMesh File="models\R6RMediumHelm.ASE" Name="R6RMediumWinterHat" YAW=32768

defaultproperties
{
     DrawScale=1.100000
     StaticMesh=StaticMesh'R6Characters.R6RMediumWinterHat'
     Skins(0)=Texture'R6Characters_T.Rainbow.R6RWinterHelm'
}
