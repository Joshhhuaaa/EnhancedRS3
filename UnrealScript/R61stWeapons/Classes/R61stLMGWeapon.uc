//===============================================================================
//  [R61stLMGWeapon] 
//===============================================================================

class R61stLMGWeapon extends R6AbstractFirstPersonWeapon;

var R61stWeaponStaticMesh m_Bullets[8];

var StaticMesh m_RWing;
var StaticMesh m_2Wing;
var StaticMesh m_LWing;

var name m_BipodFireBurstBegin;
var name m_BipodFireBurstCycle;
var name m_BipodFireBurstEnd;
var name m_FireBurstBegin;
var name m_FireBurstCycle;
var name m_FireBurstEnd;

function PlayFireAnim(){}
function PlayFireLastAnim(){}

function LoopWeaponBurst() 
{
    if(m_bWeaponBipodDeployed)
    {
        LoopAnim(m_BipodFireBurstCycle);
    }
    else
    {
        LoopAnim(m_FireBurstCycle);
    }
}

function StartWeaponBurst()
{
    if(m_bWeaponBipodDeployed)
    {
        PlayAnim(m_BipodFireBurstBegin);
    }
    else
    {
        PlayAnim(m_FireBurstBegin);
    }
}

function StopWeaponBurst()
{
    if(m_bWeaponBipodDeployed)
    {
        PlayAnim(m_BipodFireBurstEnd);
    }
    else
    {
        PlayAnim(m_FireBurstEnd);
    }
}

function HideBullet(INT iWhichBullet)
{
    while(iWhichBullet < 8)
    {
        m_Bullets[7-iWhichBullet].bHidden = TRUE;
        iWhichBullet++;
    }
}

function ShowBullets()
{
    local INT i;

    for(i = 0;i<8; i++)
    {
        m_Bullets[i].bHidden = FALSE;
    }
}

function PostBeginPlay()
{
    local INT i;
    Super.PostBeginPlay();

    for(i = 0;i<8; i++)
    {
        m_Bullets[i] = spawn(class'R61stWeaponStaticMesh');
        if(i < 3)
            m_Bullets[i].SetStaticMesh(m_LWing);
        else if(i == 3)
            m_Bullets[i].SetStaticMesh(m_2Wing);
        else 
            m_Bullets[i].SetStaticMesh(m_RWing);

        m_Bullets[i].SetDrawScale3D(vect(-1,-1,1));
    }

    AttachToBone(m_Bullets[0], 'Ball_01'); 
    AttachToBone(m_Bullets[1], 'Ball_02'); 
    AttachToBone(m_Bullets[2], 'Ball_03'); 
    AttachToBone(m_Bullets[3], 'Ball_04'); 
    AttachToBone(m_Bullets[4], 'Ball_05'); 
    AttachToBone(m_Bullets[5], 'Ball_06'); 
    AttachToBone(m_Bullets[6], 'Ball_07'); 
    AttachToBone(m_Bullets[7], 'Ball_08'); 

    if(!HasAnim('BipodFireBurst_b'))
    {
        m_BipodFireBurstBegin = m_BipodNeutral;
    }
    if(!HasAnim('BipodFireBurst_c'))
    {
        m_BipodFireBurstCycle = m_BipodNeutral;
    }
    if(!HasAnim('BipodFireBurst_e'))
    {
        m_BipodFireBurstEnd = m_BipodNeutral;
    }
    if(!HasAnim('FireBurst_b'))
    {
        m_FireBurstBegin = m_Neutral;
    }
    if(!HasAnim('FireBurst_c'))
    {
        m_FireBurstCycle = m_Neutral;
    }
    if(!HasAnim('FireBurst_e'))
    {
        m_FireBurstEnd = m_Neutral;
    }

}

function DestroyBullets() 
{
    local INT i;
    for(i = 0;i<8; i++)
    {
        if ( m_Bullets[i] != none )
            m_Bullets[i].Destroy();
        m_Bullets[i]=none;
    }
}

defaultproperties
{
     m_BipodFireBurstBegin="BipodFireBurst_b"
     m_BipodFireBurstCycle="BipodFireBurst_c"
     m_BipodFireBurstEnd="BipodFireBurst_e"
     m_FireBurstBegin="Fireburst_b"
     m_FireBurstCycle="Fireburst_c"
     m_FireBurstEnd="Fireburst_e"
}
