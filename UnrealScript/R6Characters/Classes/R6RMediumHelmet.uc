//=============================================================================
//  R6RMediumHelmet.uc : (add small description)
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/09/24 * Created by Rima Brek
//=============================================================================
class R6RMediumHelmet extends R6RHelmet;

#exec NEW StaticMesh File="models\R6RMediumHelm.ASE" Name="R6RMediumHat" YAW=32768

defaultproperties
{
     DrawScale=1.100000
     StaticMesh=StaticMesh'R6Characters.R6RMediumHat'
     Skins(0)=Texture'R6Characters_T.Rainbow.R6RHelm'
}
