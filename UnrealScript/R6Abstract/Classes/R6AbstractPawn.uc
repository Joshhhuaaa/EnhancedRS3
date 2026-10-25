//=============================================================================
//  R6AbstractPawn.uc : This is the abstract class for the r6pawn class.  We
//                      use an abstract class without any declared function.  
//                      This is useful to avoid circular references
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    July 18th, 2001 * Created by Eric Begin
//=============================================================================
class R6AbstractPawn extends Pawn
    native
    abstract;

enum ESkills
{
    SKILL_Assault,
    SKILL_Demolitions,
    SKILL_Electronics,
    SKILL_Sniper,
    SKILL_Stealth,
    SKILL_SelfControl,
    SKILL_Leadership,
    SKILL_Observation
};

var(Debug) BOOL bShowLog;

replication
{
    // we want to replicate this function to the server
//    unreliable if (Role<ROLE_Authority)
//        ServerGetWeapon;
    // we want to replicate this function to the client
    unreliable if (Role==ROLE_Authority)
        ClientGetWeapon;
    
    //unreliable if (Role == ROLE_Authority)
    //    ClientSetDoor;
}

event FLOAT GetSkill( ESkills eSkillName );

function GetWeapon(R6AbstractWeapon NewWeapon)
{
    if(bShowLog) log("ak: GetWeapon "$NEWWEapon);
}

function ClientGetWeapon(R6EngineWeapon NewWeapon)
{
    if ((Level.NetMode == NM_Standalone) || (Level.NetMode == NM_ListenServer))
        return;
    
    if(bShowLog) log("IN: ClientGetWeapon() "$NEWWEapon);
    GetWeapon(R6AbstractWeapon(NewWeapon));
    if(bShowLog) log("OUT: ClientGetWeapon() "$NEWWEapon);
}

//simulated function ServerGetWeapon(R6AbstractWeapon NewWeapon)
//{
//    log("ak: ServerGetWeapon "$NEWWEapon);
//    ClientGetWeapon(NewWeapon);
//    GetWeapon(NewWeapon);
//}

defaultproperties
{
}
