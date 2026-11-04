class R6HCasualMan01Placeable extends R6HCasualMan01
    placeable;

event R6QueryCircumstantialAction(float fDistance, out R6AbstractCircumstantialActionQuery Query, PlayerController PlayerController)
{
    Query.iHasAction = 0;
}

defaultproperties
{
    Begin Object Class=KarmaParamsSkel Name=KarmaParamsSkel350
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
        Name="KarmaParamsSkel350"
    End Object
    KParams=KarmaParamsSkel'ASCharacters.KarmaParamsSkel350'
}
