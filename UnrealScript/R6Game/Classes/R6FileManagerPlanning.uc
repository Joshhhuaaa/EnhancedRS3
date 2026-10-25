//=============================================================================
//  R6FileManagerPlanning.uc : Actor to list file, load and save a file
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//  Revision history:
//    2001/10/18 * Created by Chaouky Garram
//    2002/03/07 * taken over by Joel Tremblay
//=============================================================================

class R6FileManagerPlanning extends R6FileManager
	native;

var INT m_iCurrentTeam;

native(1416) final function BOOL LoadPlanning(string szMapName, string szLocalizedMapName, string szEnglishGT, string szGameType, string szFileName, R6StartGameInfo SGI, optional out string LoadErrorMsgMapName, optional out string LoadErrorMsgGameType);
native(1417) final function BOOL SavePlanning(string szMapName, string szLocalizedMapName, string szEnglishGT, string szGameType, string szFileName, R6StartGameInfo SGI);

native(1418) final function INT GetNumberOfFiles(string MapName, string szGameType);

defaultproperties
{
}
