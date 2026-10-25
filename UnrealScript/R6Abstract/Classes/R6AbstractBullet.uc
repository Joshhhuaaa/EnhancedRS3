//========================================================================================
//  R6AbstractBullet.uc :   This is the abstract class for the r6Bullet class.  We
//                          use an abstract class without any declared function.  
//                          This is useful to avoid circular references and accessing 
//                          classes that are declared in a package that is compiled later
//
//  Copyright 2003 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    Jan 8th, 2003 * Created by Joel Tremblay
//=============================================================================
class R6AbstractBullet extends actor
    native
    abstract;

function DoorExploded(); //To tell the breach charge the door was destroyed

defaultproperties
{
}
