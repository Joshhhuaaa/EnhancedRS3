//=============================================================================
//  R6IOSelfDetonatingBomb : MissionPAck1
//  Like IOBomb, but it can self-detonate after a given amount of time
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

class R6IOSelfDetonatingBomb extends R6IOBomb
    placeable;

var(R6ActionObject) FLOAT m_fSelfDetonationTime;   // MissionPack1 - Time required to self-detonate
var FLOAT   m_fDefusedTimeMessage;    // defused message shown for 3 secs
/*
simulated function ResetOriginalData()
{
    Super.ResetOriginalData();

	if(m_fSelfDetonationTime > 0)
	{
		m_fTimeLeft = m_fSelfDetonationTime;
		m_fTimeOfExplosion = m_fSelfDetonationTime;
		m_bIsActivated = false; //to be sure it's activated, when replaying missions
		ArmBomb(none);
	}

}
*/

function StartTimer()
{
    #ifdefDEBUG log("Bomb arming... time="$m_fSelfDetonationTime); #endif//Mp1DEBUG
	if(m_fSelfDetonationTime > 0)
	{
		m_fTimeLeft = m_fSelfDetonationTime;
		m_fTimeOfExplosion = m_fSelfDetonationTime;
		m_bIsActivated = false; //to be sure it's activated, when replaying missions
		ArmBomb(none);
	}

}


simulated function Timer()
{

    if(Level.game != none) // MPF_Milan_8_1_2003 - avoid accessed none for Multiplayer clients
    {
	if(R6AbstractGameInfo(Level.Game).m_missionMgr.m_eMissionObjectiveStatus != eMissionObjStatus_success &&
		R6AbstractGameInfo(Level.Game).m_missionMgr.m_eMissionObjectiveStatus != eMissionObjStatus_failed)
	    Super.Timer();
}
    else
    {
        Super.Timer();
    }

}


simulated function PostRender(canvas C )
{
	local FLOAT fStrSizeX, fStrSizeY;
	local INT X, Y;
	local string sTime;
//	local int iMinsLeft, iSecsLeft;
	local int iTimeLeft;

    if(Level.NetMode == NM_Client)
        iTimeLeft = int(m_fRepTimeLeft);
    else
    	iTimeLeft = int(m_fTimeLeft);
        
    #ifdefDEBUG log("LevelTimeSeconds="$Level.TimeSeconds$" ,m_fDefusedTimeMessage="$m_fDefusedTimeMessage$" time left="$m_fTimeLeft);  #endif
	if(m_bIsActivated)
	{
//		iMinsLeft = int(m_fTimeLeft)/60;//DetonationTime - Level.TimeSeconds)/60;
//		iSecsLeft = int( m_fTimeLeft) - iMinsLeft*60;
		
		sTime=  Localize("Game", "TimeLeft", "R6GameInfo") $ " ";
	    sTime = sTime $ ConvertIntTimeToString( iTimeLeft, true );
		
		C.UseVirtualSize(true, 640, 480);
		X = C.HalfClipX;
        Y = C.HalfClipY/8;//MPF_Milan_9_12_2003 - was /16
		C.Font = font'R6Font.Rainbow6_14pt'; 
		
		if ( iTimeLeft > 20 )
			C.SetDrawColor(255,255,255);    // white
		else if ( iTimeLeft > 10 )
			C.SetDrawColor(255,255,0);      // yellow
		else
			C.SetDrawColor(255,0,0);        // red

		C.StrLen( sTime, fStrSizeX, fStrSizeY );
		C.SetPos( X - fStrSizeX/2, Y + 24 );
		C.DrawText( sTime );
	}
	/*else
	{
		log("LevelTimeSeconds="$Level.TimeSeconds$" ,m_fDefusedTimeMessage="$m_fDefusedTimeMessage);
		if((Level.TimeSeconds - m_fDefusedTimeMessage) < 3)
		{
			sTime=  Localize("Game", "BombDefused", "R6GameInfo") $ " ";
			C.UseVirtualSize(true, 640, 480);
			X = C.HalfClipX;
			Y = C.HalfClipY/16;
			C.Font = font'R6Font.Rainbow6_14pt';
			C.SetDrawColor(255,255,255);    // white
			C.StrLen( sTime, fStrSizeX, fStrSizeY );
			C.SetPos( X - fStrSizeX/2, Y + 48 );
			C.DrawText( sTime );

		}
		
	}
	*/

    /*C.UseVirtualSize(true, 640, 480);
    X = C.HalfClipX;
	Y = C.HalfClipY/16;
	C.Font = font'R6Font.Rainbow6_14pt'; 
	
	if ( iTimeLeft > 20 )
		C.SetDrawColor(255,255,255);    // white
	else if ( iTimeLeft > 10 )
		C.SetDrawColor(255,255,0);      // yellow
	else
		C.SetDrawColor(255,0,0);        // red

	C.StrLen( sTime, fStrSizeX, fStrSizeY );
	C.SetPos( X - fStrSizeX/2, Y + 24 );
	C.DrawText( sTime );*/

}

simulated function PostRender2(canvas C )
{
	local FLOAT fStrSizeX, fStrSizeY;
	local INT X, Y;
	local string sTime;

	if(m_bIsActivated)
		m_fDefusedTimeMessage = Level.TimeSeconds;

	if(!m_bIsActivated)
	{
		if((Level.TimeSeconds - m_fDefusedTimeMessage) < 3)
		{
			sTime=  Localize("Game", "BombDefused", "R6GameInfo") $ " ";
			C.UseVirtualSize(true, 640, 480);
			X = C.HalfClipX;
            Y = C.HalfClipY/8; //MPF_Milan_9_12_2003 - was /16
			C.Font = font'R6Font.Rainbow6_14pt';
			C.SetDrawColor(255,255,255);    // white
			C.StrLen( sTime, fStrSizeX, fStrSizeY );
			C.SetPos( X - fStrSizeX/2, Y + 48 );
			C.DrawText( sTime );

		}
		
	}
}

defaultproperties
{
}
