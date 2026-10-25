//============================================================================//
// Class            R6PlayAnim.uc 
// Created By       Cyrille Lauzon
// Date             
// Description      Describes an animation for R6SubActionAnimSequence
//----------------------------------------------------------------------------//
//Revision history:
// 2002/02/19	    Cyrille Lauzon: Creation
//============================================================================//

class R6PlayAnim extends Object
	editinlinenew
	native;
/*
struct stBlendParam
{
    var() INT m_iStage;
    var() FLOAT m_fAlpha;
    var() FLOAT m_fInTime;
    var() FLOAT m_fOutTime; 
    var() name m_BoneName;
};
*/
var(R6PlayAnim)	name		m_Sequence;
var(R6PlayAnim)	float 		m_Rate;
var(R6PlayAnim)	float 		m_TweenTime;
//var(R6PlayAnim) stBlendParam m_BlendParams;

var(R6PlayAnim)	bool		m_bLoopAnim;
var(R6PlayAnim)	int			m_MaxPlayTime;

//Matinee Attach/Detach
var(R6Attach)	Actor		m_AttachActor;
var(R6Attach)	string		m_StaticMeshTag;
var(R6Attach)	name		m_PawnTag;

//Private variables------
var		int					m_PlayedTime;
var		bool				m_bStarted;
var		bool				m_bFirstTime; //true if we are about to start the anim

//Relative Position in Scene:
var		float				m_fBeginPct;
var		float				m_fEndPct;

//Animation Info:
var     int					m_iFrameNumber;

//Events:
event AnimFinished();

defaultproperties
{
     m_MaxPlayTime=1
     m_bLoopAnim=True
     m_bFirstTime=True
     m_Rate=1.000000
}
