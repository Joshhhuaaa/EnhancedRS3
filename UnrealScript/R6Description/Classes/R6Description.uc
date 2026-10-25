//=============================================================================
//  R6Description.uc : This classes will provide displayable information about
//                      selectable menu equipment
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/03/22 * Created by Alexandre Dionne
//=============================================================================


class R6Description extends object;

var string m_NameID;    //Name of the object to be displayed in the menus

var texture m_2DMenuTexture;   //The 2d image for the menus
var UWindowBase.Region  m_2dMenuRegion;    //Region in the texture  

var string m_NameTag; //This is used to select the correct class to spawn in the class name Array
                    //Ex: Muzzle, Silencer, CMag, ThermalScope, TacticalLight
                    //FMJ,AP,JHP

var string m_ClassName; //Class of item to spawn

defaultproperties
{
}
