class FinalBlend extends Modifier
	showcategories(Material)
	native;

enum EFrameBufferBlending
{
	FB_Overwrite,
	FB_Modulate,
	FB_AlphaBlend,
	FB_AlphaModulate_MightNotFogCorrectly,
	FB_Translucent,
	FB_Darken,
	FB_Brighten,
	FB_Invisible,
    FB_Modulate1X,
    FB_Highlight
};

var() EFrameBufferBlending FrameBufferBlending;
var() bool ZWrite;
var() bool ZTest;
var() bool AlphaTest;
var() bool TwoSided;
var() byte AlphaRef;
//R6CODE
var() bool m_bAddZBias;

defaultproperties
{
     ZWrite=True
     ZTest=True
}
