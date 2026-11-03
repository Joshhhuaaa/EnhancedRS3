class MP2PrisonersExtractionZone extends R6AbstractExtractionZone
    placeable;

#exec OBJ LOAD FILE=..\Textures\R6Planning.utx PACKAGE=R6Planning

var(LimitSeats) int m_iTeamNum;
var(LimitSeats) bool m_bKnownForOtherTeam;

function Touch(Actor Other)
{
    if((R6Hostage(Other) != none) && Level.Game != none)
    {
        if(((R6Hostage(Other).m_iPrisonierTeam == 5) && m_iTeamNum == 0) || ((R6Hostage(Other).m_iPrisonierTeam == 6) && m_iTeamNum == 1))
        {
            R6Pawn(Other).EnteredExtractionZone(self);
            R6AbstractGameInfo(Level.Game).EnteredExtractionZone(Other);
        }
    }
}

function UnTouch(Actor Other)
{
    if((R6Pawn(Other) != none) && Level.Game != none)
    {
        R6AbstractGameInfo(Level.Game).LeftExtractionZone(Other);
        R6Pawn(Other).LeftExtractionZone(self);
    }
}

defaultproperties
{
    bHidden=false
    m_bUseR6Availability=true
    m_bSkipHitDetection=true
    bCollideActors=true
    bCollideWorld=true
    DrawScale=12.0
    CollisionRadius=128.0
    CollisionHeight=20.0
    Texture=Texture'R6Planning.Icons.PlanIcon_ZoneDefault'
    m_PlanningColor=(R=24,G=134,B=181,A=255)
}
