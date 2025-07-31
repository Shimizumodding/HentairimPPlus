Scriptname IVDTVoiceFemaleScript extends ReferenceAlias  
{This holds all of the dialogue topics for a single female voice. Instances of this script are made as quest aliases under the IVDTMainQuest to support multiple voices.}

;Romantic comments
Sound Property GreetLover Auto
Sound Property GreetFamiliar Auto
Sound Property GreetLoadedFamiliar Auto
Sound Property MissMaleLover Auto
Sound Property WantToBeLover Auto
Sound Property RomanceMaleThane Auto
Sound Property LoveyDovey Auto
Sound Property AppreciatePartner Auto
Sound Property Satisfied Auto

;Foreplay
Sound Property SensitivePleasure Auto
Sound Property ForeplayIntense Auto
Sound Property ForeplaySoft Auto
Sound Property ReadyToGetGoing Auto
Sound Property ReadyToResume Auto

;Blowjob
Sound Property BlowjobRemarks Auto
Sound Property BlowjobActionIntense Auto
Sound Property BlowjobActionSoft Auto
Sound Property AssToMouth Auto

;Insertion
Sound Property InsertionGeneric Auto
Sound Property InsertionAnalSlow Auto
Sound Property InsertionAnalExcited Auto

;Penetrative sex
Sound Property PenetrativeGrunts Auto
Sound Property PenetrativeCommentsIntense Auto
Sound Property PenetrativeCommentsSoft Auto
Sound Property OnTheAttack Auto
Sound Property AssFlattering Auto
Sound Property IntenseAnal Auto
Sound Property BeforeGape Auto
Sound Property AfterGape Auto
Sound Property AskForPacingBreak Auto

;Female orgasm hype
Sound Property NearOrgasmNoises Auto
Sound Property NearOrgasmExclamations Auto
Sound Property CumTogetherTease Auto
Sound Property MyTurnToCum Auto

;Female orgasm
Sound Property Orgasm Auto

;Female orgasm post-nut
Sound Property AfterOrgasmArouse Auto
Sound Property AfterOrgasmExclamations Auto
Sound Property AfterOrgasmRemarks Auto
Sound Property MadeMeCumSoMuch Auto

;Male orgasm hype
Sound Property MaleHalfwayIntense Auto
Sound Property MaleCloseAlready Auto
Sound Property MaleCloseNotice Auto
Sound Property TeaseMaleCloseToOrgasmIntense Auto
Sound Property TeaseMaleCloseToOrgasmSoft Auto
Sound Property AskForVaginalCum Auto
Sound Property AskForAnalCum Auto
Sound Property AskForOralCum Auto
Sound Property PullOut Auto

;Male orgasm
Sound Property MaleOrgasmOral Auto
Sound Property MaleOrgasmNonOral Auto

;Male orgasm post-nut
Sound Property SurprisedByMaleOrgasm Auto
Sound Property MaleOrgasmReactionIntense Auto
Sound Property MaleOrgasmReactionSoft Auto
Sound Property MaleOrgasmReactionLover Auto
Sound Property CameInAss Auto
Sound Property CameInMouth Auto
Sound Property CameInPussy Auto
Sound Property WantMore Auto
Sound Property RefractoryPeriod Auto
Sound Property NoticeMaleWantsMore Auto

;Miscellaneous or generic/multi-purpose
Sound Property BreathyIntense Auto
Sound Property BreathySoft Auto
Sound Property Amused Auto
Sound Property Unamused Auto
Sound Property UnamusedEnd Auto
Sound Property InAwe Auto
Sound Property Oh Auto
Sound Property TeaseAggressivePartner Auto
Sound Property TeaseAnal Auto
Sound Property AskForAnal Auto

;Special sound topic used to sample the voice slot from the MCM menu to help the user pair the voices
Sound Property MCMSampleSounds Auto


;The presence of this function will probably confuse people. I should explain...
;IVDT was originally made with the assumption that there will always be a "main" female voice in the scene. Everything was built around that.
;Fast forward to post-release, I decide to add support for male-only scenes. At this point, its impossible to roll back the assumptions previously made.
;My workaround is to pretend like the female voice is the male voice. All my old code works fine interfacing with the female voice...
;...I just in this one place configure the female voice to secretely be a male voice. One of my most genius innovations (until it breaks something).
Function SetUpVoiceFromMaleVoice(IVDTVoiceMaleScript maleVoice)
	LoveyDovey = maleVoice.LoveyDovey
	
	SensitivePleasure = maleVoice.StrugglingSubtle
	
	InsertionGeneric = maleVoice.StrugglingSubtle
	InsertionAnalExcited = maleVoice.StrugglingSubtle
	InsertionAnalSlow = maleVoice.StrugglingSubtle
	
	PenetrativeCommentsIntense = maleVoice.Aggressive
	PenetrativeCommentsSoft = maleVoice.TeaseAggressivePartner
	
	NearOrgasmNoises = maleVoice.StrugglingSubtle
	NearOrgasmExclamations = maleVoice.StrugglingOvert
	CumTogetherTease = maleVoice.AboutToCum
	MyTurnToCum = maleVoice.StrugglingOvert
	
	Orgasm = maleVoice.Orgasm
	
	AfterOrgasmRemarks = maleVoice.PostNutRemark
	AfterOrgasmArouse = maleVoice.PostNutRemark
	
	MaleHalfwayIntense = maleVoice.Aggressive
	TeaseMaleCloseToOrgasmIntense = maleVoice.Aggressive
	TeaseMaleCloseToOrgasmSoft = maleVoice.Aggressive
	
	MaleOrgasmReactionIntense = maleVoice.AfterFemaleOrgasm
	MaleOrgasmReactionSoft = maleVoice.AfterFemaleOrgasm
	MaleOrgasmReactionLover = maleVoice.AfterFemaleOrgasm
	CameInAss = maleVoice.Aroused
	CameInMouth = maleVoice.Aroused
	CameInPussy = maleVoice.Aroused
	WantMore = maleVoice.Aggressive
	
	Amused = maleVoice.JokeAroused
	InAwe = maleVoice.Aroused
	TeaseAggressivePartner = maleVoice.TeaseAggressivePartner
EndFunction