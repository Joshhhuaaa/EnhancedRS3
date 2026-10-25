//=============================================================================
//  R6UPackageMgr.uc : 
//  Copyright 2001 Ubi Soft, Inc. All Rights Reserved.
//
//=============================================================================

// new MPF
class R6UPackageMgr extends Object;

var Array<string>   m_aPackageList;
var bool            bShowLog;

function InitOperativeClassesMgr()
{
	local R6FileManager pFileManager;
	local int iFiles, i;
	local string szPackageFilename;

	pFileManager = new(none) class'R6FileManager';
	iFiles = pFileManager.GetNbFile("..\\Mods\\NewOperative\\", "u" );

	// loop on all .u
	for ( i = 0; i < iFiles; i++ )
	{
		pFileManager.GetFileName( i, szPackageFilename );
		if(bShowLog) log("Found Operative package : "$szPackageFilename);
		m_aPackageList[i] = Left(szPackageFilename, len(szPackageFilename) - 2); //remove the .U at the end
	}
}

function class<object> GetFirstClassFromPackage(int iPackageIndex, class ClassType)
{
	return GetFirstPackageClass(m_aPackageList[iPackageIndex]$".u", ClassType);
}
function class<object> GetNextClassFromPackage()
{
	return GetNextClass();
}

function int GetNbPackage()
{
	return m_aPackageList.Length; 
}

function string GetPackageName(int iPackageIndex)
{
	return m_aPackageList[iPackageIndex];
}

function string GetLocalizedString(int iPackageIndex, String SectionName, String KeyName, bool bMultipleToken)
{
	local String szLocalizedString; 

	szLocalizedString = Localize(SectionName, KeyName, "..\\Mods\\NewOperative\\"$m_aPackageList[iPackageIndex], bMultipleToken);
	if(szLocalizedString == "")
		szLocalizedString = SectionName$" "$Right(SectionName, len(SectionName) - 3);

	return szLocalizedString;
}

defaultproperties
{
}
