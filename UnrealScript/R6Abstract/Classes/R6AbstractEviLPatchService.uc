//================================================================================
// R6AbstractEviLPatchService.
//================================================================================

class R6AbstractEviLPatchService extends Object
    native;

enum PatchState
{
    PS_Unknown,
    PS_Initializing,
    PS_DownloadVersionFile,
    PS_SelectPatch,
    PS_DownloadPatch,
    PS_Terminate,
    PS_RunPatch
};

native static function PatchState GetState();
