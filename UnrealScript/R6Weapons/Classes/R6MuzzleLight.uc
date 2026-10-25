//=============================================================================
// R6MuzzleLight.
//=============================================================================
class R6MuzzleLight extends Light;

var FLOAT   m_fExistForHowlong;

const LightExistence=0.04;

//Tick is used to make sure the light is displayed at least once under low FPS
simulated function Tick(FLOAT fDeltaTime)
{
    super.Tick(fDeltatime);

    m_fExistForHowlong += fDeltaTime;
    if(m_fExistForHowlong > LightExistence)
    {
        Destroy();
    }
}

defaultproperties
{
     DrawType=DT_None
     LightHue=33
     LightSaturation=209
     bStatic=False
     bNoDelete=False
     bDynamicLight=True
     LightBrightness=232.000000
     LightRadius=40.000000
}
