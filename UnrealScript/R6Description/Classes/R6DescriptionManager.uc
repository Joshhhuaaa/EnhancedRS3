//=============================================================================
//  R6DescriptionManager.uc : Class providing manipulation tools
//  Copyright 2002 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2002/09/10 * Created by Alexandre Dionne
//=============================================================================


class R6DescriptionManager extends object;


static final function  class<R6Description> findPrimaryDefaultAmmo(class<R6PrimaryWeaponDescription> WeaponDescriptionClass )
{
    local int i;
    local bool found;
    
    found = false;
    i =0;   
    
    //Look for FMJ
    while((i < WeaponDescriptionClass.Default.m_Bullets.Length ) && (found == false))
    {       
        if( class<R6BulletDescription>(WeaponDescriptionClass.Default.m_Bullets[i]).Default.m_NameTag == "FMJ")
            found = true;
        else
            i++;
    }
    if(found) 
        return class<R6Description>(WeaponDescriptionClass.Default.m_Bullets[i]);

    i=0;
    //Look for Buck
    while((i < WeaponDescriptionClass.Default.m_Bullets.Length ) && (found == false))
    {
        if( class<R6BulletDescription>(WeaponDescriptionClass.Default.m_Bullets[i]).Default.m_NameTag == "BUCK")
            found = true;
        else
            i++;
    }
    if(found) 
        return class<R6Description>(WeaponDescriptionClass.Default.m_Bullets[i]);
    
    //Return first ammo in the weapon ammo list should not happen
    return class<R6Description>(WeaponDescriptionClass.Default.m_Bullets[0]);    
}

static final function  class<R6Description> findSecondaryDefaultAmmo(class<R6SecondaryWeaponDescription> WeaponDescriptionClass )
{
    local int i;
    local bool found;
    
    found = false;   
    i=0;
    //Look for FMJ
    while((i < WeaponDescriptionClass.Default.m_Bullets.Length ) && (found == false))
    {
        if( class<R6BulletDescription>(WeaponDescriptionClass.Default.m_Bullets[i]).Default.m_NameTag == "FMJ")
            found = true;
        else
            i++;
    }
    if(found) 
        return class<R6Description>(WeaponDescriptionClass.Default.m_Bullets[i]);
    
    //Return first ammo in the weapon ammo list should not happen
    return class<R6Description>(WeaponDescriptionClass.Default.m_Bullets[0]);    
}

static final function class<R6BulletDescription> GetPrimaryBulletDesc(class<R6PrimaryWeaponDescription> WeaponDescription, string token)
{
    local int   i;
    local bool  found;
    local string caps_Token;
    
    caps_Token = caps(token);

    while((i < WeaponDescription.Default.m_Bullets.Length ) && (found == false))
    {        
        if(  class<R6BulletDescription>(WeaponDescription.Default.m_Bullets[i]).Default.m_NameTag == caps_Token)
            found = true;
        else
            i++;
    }
    
   
    if(found)
           return class<R6BulletDescription>(WeaponDescription.Default.m_Bullets[i]);
    else return class'R6DescBulletNone';     //Should not happen if the default classes are filled correctly with the none classes values

}

static final function class<R6WeaponGadgetDescription> GetPrimaryWeaponGadgetDesc(class<R6PrimaryWeaponDescription> WeaponDescription, string token)
{
    local int   i;
    local bool  found;
    local string caps_Token;
    
    caps_Token = caps(token);

    if(caps_Token == "NONE")
        return class'R6DescWeaponGadgetNone';
    
    while((i < WeaponDescription.Default.m_MyGadgets.Length ) && (found == false))
    {
        if ( (WeaponDescription.Default.m_MyGadgets[i] != none) && 
             (class<R6WeaponGadgetDescription>(WeaponDescription.Default.m_MyGadgets[i]).Default.m_NameID == caps_Token))
            found = true;
        else
            i++;
    }
    
    if(found)
        return class<R6WeaponGadgetDescription>(WeaponDescription.Default.m_MyGadgets[i]);
    else 
        return class'R6DescWeaponGadgetNone';     //Should not happen if the default classes are filled correctly with the none classes values
    
}

static final function class<R6BulletDescription> GetSecondaryBulletDesc(class<R6SecondaryWeaponDescription> WeaponDescription, string token)
{
    local int   i;
    local bool  found;
    local string caps_Token;

    caps_Token = caps(token);
    while((i < WeaponDescription.Default.m_Bullets.Length ) && (found == false))
    {        
        if(  class<R6BulletDescription>(WeaponDescription.Default.m_Bullets[i]).Default.m_NameTag == caps_Token)
            found = true;
        else
            i++;
    }
    
   
    if(found)
           return class<R6BulletDescription>(WeaponDescription.Default.m_Bullets[i]);
    else return class'R6DescBulletNone';     //Should not happen if the default classes are filled correctly with the none classes values

}

static final function class<R6WeaponGadgetDescription> GetSecondaryWeaponGadgetDesc(class<R6SecondaryWeaponDescription> WeaponDescription, string token)
{
    local int   i;
    local bool  found;
    local string caps_Token;
    
    caps_Token = caps(token);
    if(caps_Token == "NONE")
        return class'R6DescWeaponGadgetNone';
    
    while((i < WeaponDescription.Default.m_MyGadgets.Length ) && (found == false))
    {       
        if(  class<R6WeaponGadgetDescription>(WeaponDescription.Default.m_MyGadgets[i]).Default.m_NameID == caps_Token)
            found = true;
        else
            i++;
    }
    
    if(found)
           return class<R6WeaponGadgetDescription>(WeaponDescription.Default.m_MyGadgets[i]);
    else return class'R6DescWeaponGadgetNone';     //Should not happen if the default classes are filled correctly with the none classes values

}

defaultproperties
{
}
