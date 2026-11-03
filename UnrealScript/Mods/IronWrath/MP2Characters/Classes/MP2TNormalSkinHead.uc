class MP2TNormalSkinHead extends MP2TNormal01;

#exec OBJ LOAD FILE=..\Mods\IronWrath\Textures\MP2Characters_T.utx PACKAGE=MP2Characters_T

defaultproperties
{
    m_eTerroType=TTYPE_T1T3
    Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel469
        KConvulseSpacing=(Min=0.5,Max=2.2)
        KSkeleton="terroskel"
        KStartEnabled=true
        bHighDetailOnly=false
        KLinearDamping=0.5
        KAngularDamping=0.5
        KBuoyancy=1.0
        KVelDropBelowThreshold=50.0
        KFriction=0.6
        KRestitution=0.3
        KImpactThreshold=150.0
        Name="KarmaParamsSkel469"
    End Object
    KParams=KarmaParamsSkel'MP2Characters.KarmaParamsSkel469'
    Skins[0]=Texture'MP2Characters_T.terrorist.MP2TNormalSkinHead'
}
