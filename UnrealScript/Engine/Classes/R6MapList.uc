//=============================================================================
//  R6MapList.uc : Map List
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//  Used to create a list of maps to cycyle through in adversarial mode.
//
//  Revision history:
//    2002/04/22 * Created by John Bennett
//=============================================================================
class R6MapList extends Maplist
    native;

var config string GameType[32];

var bool m_bInit;

event PreBeginPlay()
{
    local string serverIni;
    Super.PreBeginPlay();

    if ( !m_bInit ) // load only once
    {
        serverIni = class'Actor'.static.GetModMgr().getServerIni();
        LoadConfig( serverIni$".ini" );
        m_bInit = true;
    }
}

//function int GetNextMapIndex(OPTIONAL int iNextMapNum)
function int GetNextMapIndex(int iNextMapNum)
{
    local int iNextNum;

    if (iNextMapNum<-1)
        iNextNum = Level.Game.GetCurrentMapNum() + 1;
    else
        iNextNum = iNextMapNum - 1;

    
    if ( iNextNum > ArrayCount(Maps) - 1 )
    {
        return 0;
    }

    if (iNextNum < 0)
    {
        iNextNum = 0;
        while (Maps[iNextNum+1] != "" && iNextNum < ArrayCount(Maps) - 1)
            iNextNum++;
    }

    if ( Maps[iNextNum] == "" )
    {
        return 0;
    }

    return iNextNum;
}


function string CheckNextMap()
{
    return Maps[ GetNextMapIndex(K_NextDefaultMap) ];
}

function string CheckNextMapIndex(int iMapIndex)
{
    return Maps[ GetNextMapIndex(iMapIndex+1) ];
}

function string CheckNextGameType()
{
    return GameType[ GetNextMapIndex(K_NextDefaultMap) ];
}

function string CheckNextGameTypeIndex(int iMapIndex)
{
    return GameType[ GetNextMapIndex(iMapIndex+1) ];
}


function string CheckCurrentMap()
{
    return Maps[Level.Game.GetCurrentMapNum()];
}

function string CheckCurrentGameType()
{
    return GameType[Level.Game.GetCurrentMapNum()];
}

//------------------------------------------------------------------
// GetNextMapIndex: Get the next map, increase the counter and save
//	the setting
//------------------------------------------------------------------
function string GetNextMap(int iNextMapNum)
{
    local INT _iMapNum;

    _iMapNum = GetNextMapIndex(iNextMapNum);

    Level.Game.SetCurrentMapNum(_iMapNum);
	return Maps[_iMapNum];
}

defaultproperties
{
}
