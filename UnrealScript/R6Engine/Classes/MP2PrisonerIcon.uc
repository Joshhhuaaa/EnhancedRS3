class MP2PrisonerIcon extends R6ReferenceIcons
    placeable;

var(LimitSeats) INT  m_iPrisonerTeam;
var(LimitSeats) BOOL m_bKnownForOtherTeam;

defaultproperties
{
     m_bKnownForOtherTeam=True
     bStatic=True
}
