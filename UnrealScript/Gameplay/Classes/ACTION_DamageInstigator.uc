class ACTION_DamageInstigator extends ScriptedAction;

var(Action) int m_iKillValue;
var(Action) int m_iStunValue;

function bool InitActionFor(ScriptedController C)
{
	local pawn Damaged;

	Damaged = C.GetInstigator();
	Damaged.R6TakeDamage( m_iKillValue, m_iStunValue, Damaged, Damaged.Location, vect(0,0,0), 0 );
	return false;	
}

function string GetActionString()
{
	return ActionString@m_iKillValue@m_iStunValue;
}

defaultproperties
{
     m_iKillValue=500
     m_iStunValue=1000
     ActionString="Damage instigator"
}
