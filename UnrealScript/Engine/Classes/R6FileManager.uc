class R6FileManager extends Object
	native;

var Array<String> m_pFileList;

native(1525) final function INT GetNbFile(string szPath, string szExt);
native(1526) final function GetFileName(INT iFileID, out string szFileName);
native(1527) final function BOOL DeleteFile(string szPathFile);
native(1528) final function BOOL FindFile(string szPathAndFilename);

defaultproperties
{
}
