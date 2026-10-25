//=============================================================================
//  eviLPatchService.uc : This class provides a script front-end to the
//  patch service client facilities.
//
//============================================================================//

class eviLPatchService extends R6AbstractEviLPatchService
	native;

enum ExitCause{
	EC_Unknown,
	EC_PatchStarted,
	EC_NoPatchNeeded,
	EC_FatalDownloadError,
	EC_PartialDownloadError,
	EC_UserAborted,
	EC_UserQuit
};

var FLOAT m_bLastUpdateTime;

native(3102) final static function 				StartPatch();
native(3105) final static function 				GetDownloadProgress(out float totalBytes, out float totalRecvdBytes, out float fileBytes, out float fileRecvdBytes);
native(3106) final static function 				AbortPatchService();
native(3107) final static function ExitCause	GetExitCause();
native(3109) final static function BOOL			CanRunUpdateService();
native static function PatchState 				GetState();

defaultproperties
{
}
