//============================================================================//
// Class            R6Decal.uc 
// Created By       Cyrille Lauzon
// Date             2001/01/18
// Description      R6 base class for wall Decals made with guns.
//----------------------------------------------------------------------------//
// Modification History
//      2002/04/26  Jean-Francois Dube (added ScaleProjector state)
//============================================================================//
class R6Decal extends Projector
	native;

import class R6DecalGroup;
var bool m_bActive;
var bool m_bNeedScale;

State ScaleProjector
{
    function BeginState()
    {
        bStasis = false;
        bClipBSP = false;
        m_bClipStaticMesh = false;
    }

    function EndState()
    {
        bStasis = true;
    }

	simulated function Tick(float DeltaTime)
	{
        local vector NewScale3D;
        local rotator NewRotation;
        local RandomTweenNum RandomValue;

        if(m_bNeedScale == false || (DrawScale3D.X >= 1.0f && DrawScale3D.Y >= 1.0f))
        {
            bClipBSP = true;
            m_bClipStaticMesh = true;
            DetachProjector(true);
            AttachProjector();
    		GotoState('');
        }
        else
        {
            DetachProjector(true);
            
            NewScale3D = DrawScale3D;
            RandomValue.m_fMin = 8.0f;
            RandomValue.m_fMax = 16.0f;
            NewScale3D.X += (DeltaTime / (GetRandomTweenNum(RandomValue) + (NewScale3D.X * 25.0f)));
            NewScale3D.Y += (DeltaTime / (GetRandomTweenNum(RandomValue) + (NewScale3D.Y * 25.0f)));
            SetDrawScale3D(NewScale3D);

            NewRotation = Rotation;
            NewRotation.Roll += (DeltaTime * 65536.0f) / 256.0f;
            SetRotation(NewRotation);

            AttachProjector();
        }
	}
}

defaultproperties
{
     FOV=1
     MaxTraceDistance=5
     bProjectParticles=False
     bProjectActor=False
     bProjectOnParallelBSP=True
     RemoteRole=ROLE_None
     DrawType=DT_None
     bStatic=False
     bStasis=True
     DrawScale=0.400000
}
