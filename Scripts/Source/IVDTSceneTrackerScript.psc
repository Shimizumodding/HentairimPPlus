Scriptname IVDTSceneTrackerScript extends ActiveMagicEffect  

import b612

;References
SexLabFramework Property SexLab Auto
sslThreadController ThreadController 
IVDTControllerScript Property MasterScript Auto
SoundCategory Property LowPrioritySounds Auto
SoundCategory Property HighPrioritySounds Auto
SoundCategory Property LowPrioritySoundsMale auto
SoundCategory Property HighPrioritySoundsMale Auto
Spell Property SceneTrackerSpell Auto
IVDTVoiceFemaleScript Property FakeFemaleVoice Auto 

;References for determining if its a stealth scene
Keyword Property PlayerHomeKeyword Auto
Keyword Property CityKeyword Auto
Keyword Property TownKeyword Auto
Keyword Property ClearableKeyword Auto

Actor actorWithSceneTrackerSpell = None
Actor mainFemaleActor = None
Actor mainMaleActor = None
Actor playerCharacter = None

IVDTVoiceFemaleScript mainFemaleVoice = None
IVDTVoiceMaleScript mainMaleVoice = None
IVDTVoiceMaleScript DefaultMaleVoice = None
Int ThreadID = -1
SexLabThread CurrentThread = None
string CurrentSceneid = ""
string previousAnimation = ""
bool GreetedMalePartner = false

;Config

float timeOfLastKneeJerkReaction
Bool withMaleLover = False

AssociationType Property SpouseAssocation Auto
Faction Property PlayerMarriedFaction Auto
Faction Property PlayerHousecarlFaction Auto


Bool foundASoundToPlay = False
Bool maleOnlyScene = False
Float hoursSinceLastSex = 0.0 ;For the main female. In game hours. Doesn't include current scene.
Bool currentlyIntense = False ;I consider the opposite phase "soft". Soft is when gentle voices are used, intense is when combative voices are used
Int mainFemaleEnjoyment = 0
Int mainMaleEnjoyment = 0
Bool femaleCloseToOrgasm = False
Bool socializedNeedToCum = False
Int maleOrgasmCount = 0
Int femaleRecordedOrgasmCount = 0
Int orgasmTalkStage = 0 ;0 - 1st possible hint male is close, 1 - 2nd possible hint, 2 - last hint and female acknowledges, 3 - female teasing male for cum, 4 - male came, 5 - female reacted to orgasm
Int cumLocationDecision = 0 ;0 - no decision (yet), 1 = oral, 2 = vaginal, 3 = anal
Bool socializedCumLocationDecision = False
Bool lastMaleOrgasmWasUnexpected = False
Int locationOfLastMaleOrgasm = 0 ;0 - not set (or other), 1 - oral, 2 - vaginal, 3 = anal
Int currentStage = -1 ;Current stage of the sslBaseAnimation (SexLab animation) that is currently playing
string SFXTag
string currentStageID = ""

Float timeOfLastStageStart = 0.0
Float timeOfLastMaleOrgasm = -20.0
Float timeOfLastRecordedFemaleOrgasm = -20.0
Float timeOfLastRomanticRemark = 0.0
Float timeOfLastJoke = 0.0
Float penetrativeStreakDuration = 0.0 ;How long the current level of penetration as defined by CurrentPenetrationLvl() has lasted in irl seconds
Float streakTooLongDuration = 0.0 ;When penetrativeStreakDuration gets longer than this, the female will begin asking for a change up. Set when streak resets
Float totalPenetrativeSexDuration = 0.0
Float totalAnalSexDuration = 0.0
Bool acknowledgedAnal = False
Int timesGaped = 0 ;Number of times the female has been gaped for the current scene
Int attackStage = 0 ;0 - not currently attacking, 1 - currently attacking, 2 - currently retreating
Bool inRefractoryPeriod = False ;When satisfied after the male orgasm (not left demanding more), the female actor may be in temporary limbo remarking on the orgasm, unsure if the male wants more
Int currentlyPlayingSoundCount = 0
Int currentlyPlayingSoundCountMale = 0
Sound queuedSound = None ;Sounds attempting to play with a priority of 1 when another sound is playing will be queued up to play afterwards
Float timeSoundWasQueued = 0.0 ;The timestamp at which queuedSound originally attempted to play
Float queuedSoundMaxWait = 0.0 ;The longest the queuedSound can sit in the queue before we give up on trying to play it
bool inserted = false
;for new anim stage label
string Primarystagelabel = ""
String Stagelabelminusone = ""
bool teasedClosetoorgasm = true
bool ASLpreviouslyintense = False
bool commentedcumlocation = false
bool MaleCommentsonEN = false
bool commentedorgasmremark = false
float ASLStagetimetoadvance = 0.0
Bool ASLCurrentlyintense = false

Bool ASLIsinSpanking = false
int CameInsideCount = 0
Bool ReacttoFemaleOrgasmNext = false
Bool ReacttoMaleOrgasmNext = false
Float Volume

Sound PreviousSound = none
	
Actor[] ActorsInPlay
;JSONUtil configs
String ConfigFile  = "IVDTHentai/Config.json"
String TimerConfigFile  = "IVDTHentai/Timers.json"
String VoiceVariationFile  = "IVDTHentai/VoiceVariation.json"
String DDGagFile  = "IVDTHentai/DDGagConfig.json"
String OninusLactisFile  = "IVDTHentai/OninusLactis.json"
int cumleakcount = 0
Bool MaleisCommenting = false
int	EnableBrokenStatus ;done
;int MinOrgasmsToBroken ;done
;int MaxOrgasmsToBroken ;done
int	EnableHugePPScenario ;done
int	EnableVictimScenario ;done
float	ChanceToCommentUnamused  ;done
float	ChanceToCommentonLeadinStage ;done
float	ChanceToCommentonNonIntenseStage  ;done
float	chancetocommentonintensestage ;done
float	ChanceToCommentononAttackingStage  ;done
float	ChanceToCommentonBlowjobStage ;done
float	ChanceToCommentWhenCloseToOrgasm ;done
float	ChanceToCommentWhenMaleCloseToOrgasm   ;done
float ChanceToOrgasmSquirt ;done
int EnableThickCumLeak ;done
float ChanceToLeakThickCum ;done

int FemaleOrgasmHypeEnjoyment ;done
int MaleOrgasmHypeEnjoyment ;done
int EnableDDGagVoice ;done
Int EnableMaleVoice ;done
float ChanceForMaleToComment ; done

String[] ArmorSlotsToSwitch
Int[] ValidSlots
form[] BaseArmorArr 
form[] LewdArmorArr 
Bool SwappedLowerArmor = false
Bool SwappedUpperArmor = false
Keyword TNG_Gentlewoman
Keyword TNG_L
Keyword TNG_XL
String VoiceVariation 
Bool ShouldInitialize = false
Int Type = 0
Faction SchlongFaction
int MoanOnly
int donotadvanceifpcclosetoorgasm 
int donotadvanceifnpcclosetoorgasm 
bool LinearSceneDonePostOrgasmComments

	Float nextUpdateInterval = 1.0

Armor MilkR
Armor MilkL
EffectShader NippleLeakCBBE
int donotadvanceifpartnerclosetoorgasm
String Property NINODE_ROOT = "NPC" AutoReadOnly
String Property RACEMENUHH_KEY = "RaceMenuHH.esp" AutoReadOnly
String Property INTERNAL_KEY = "internal" AutoReadOnly
Bool CommentedClosetoOrgasm = false
;SOS

Form ArmortoSwitch

Faction HentairimResistanceFaction
Faction HentairimBroken

	
int gender = 0	
Bool NotifiedBrokenstatus = false
int hypebeforeorgasm

Event OnEffectStart(Actor akTarget, Actor akCaster)
	playerCharacter = Game.GetPlayer()
	actorWithSceneTrackerSpell = akTarget
	mainFemaleActor = playerCharacter ;Temporary default until FindActorsAndVoices is called
	ThreadController = sexlab.GetPlayerController()
	;threadcontroller.ActorAlias[z]
	PerformInitialization()

EndEvent

int EnablePrintDebug
int useblowjobsoundforkissing
float	pcvolume
float	partnervolume
int enableivdtgamevoicecontrol
Function InitializeConfigValues()

ActorsInPlay = CurrentThread.GetPositions()
donotadvanceifpartnerclosetoorgasm =  JsonUtil.GetIntValue(ConfigFile,"donotadvanceifpartnerclosetoorgasm",0)
donotadvanceifpcclosetoorgasm =  JsonUtil.GetIntValue(ConfigFile,"donotadvanceifpcclosetoorgasm",0)
donotadvanceifnpcclosetoorgasm =  JsonUtil.GetIntValue(ConfigFile,"donotadvanceifnpcclosetoorgasm",0)
ChanceToOrgasmSquirt = JsonUtil.GetIntValue(ConfigFile,"chancetoorgasmsquirt",0) as float/100
EnableBrokenStatus = JsonUtil.GetIntValue(ConfigFile,"enablebrokenstatus",0)
EnableThickCumLeak = JsonUtil.GetIntValue(ConfigFile,"enablethickcumleak",0)
ChanceToLeakThickCum = JsonUtil.GetIntValue(ConfigFile,"chancetoleakthickcum",0) as float/100
EnableHugePPScenario = JsonUtil.GetIntValue(ConfigFile,"enablehugeppscenario",0)
EnableVictimscenario = JsonUtil.GetIntValue(ConfigFile,"enablevictimscenario",0)
ChanceToCommentUnamused = JsonUtil.GetIntValue(ConfigFile,"chancetocommentunamused",0) as float/100
ChanceToCommentonLeadinStage = JsonUtil.GetIntValue(ConfigFile,"chancetocommentonleadinstage",0) as float/100
ChanceToCommentonNonIntenseStage = JsonUtil.GetIntValue(ConfigFile,"chancetocommentonnonintensestage",0) as float /100
chancetocommentonintensestage = JsonUtil.GetIntValue(ConfigFile,"chancetocommentonintensestage",0) as float /100
ChanceToCommentononAttackingStage = JsonUtil.GetIntValue(ConfigFile,"chancetocommentononattackingstage",0) as float /100
ChanceToCommentonBlowjobStage = JsonUtil.GetIntValue(ConfigFile,"ChanceToCommentonBlowjobStage",0) as float /100
ChanceToCommentWhenCloseToOrgasm = JsonUtil.GetIntValue(ConfigFile,"chancetocommentwhenclosetoorgasm",0) as float /100
ChanceToCommentWhenMaleCloseToOrgasm = JsonUtil.GetIntValue(ConfigFile,"chancetocommentwhenmaleclosetoorgasm",0) as float /100
FemaleOrgasmHypeEnjoyment = JsonUtil.GetIntValue(ConfigFile,"femaleorgasmhypeenjoyment",0) 
MaleOrgasmHypeEnjoyment = JsonUtil.GetIntValue(ConfigFile,"maleorgasmhypeenjoyment",0) 
EnableDDGagVoice = JsonUtil.GetIntValue(DDGagFile,"enableddgagvoice",0) 
EnableMaleVoice = JsonUtil.GetIntValue(ConfigFile,"enablemalevoice",0)  
ChanceForMaleToComment = JsonUtil.GetIntValue(ConfigFile,"chanceformaletocomment",0) as float /100  

VoiceVariation = JsonUtil.GetStringValue(VoiceVariationFile,"voicevariation","NA")  
MoanOnly  = JsonUtil.GetIntValue(ConfigFile,"moanonly",0) 
hypebeforeorgasm = JsonUtil.GetIntValue(ConfigFile,"hypebeforeorgasm",0)  
useblowjobsoundforkissing = JsonUtil.GetIntValue(ConfigFile,"useblowjobsoundforkissing",0)
pcvolume = JsonUtil.GetIntValue(ConfigFile,"pcvolume",0) as float /100
partnervolume = JsonUtil.GetIntValue(ConfigFile,"partnervolume",0) as float /100
EnablePrintDebug =  JsonUtil.GetIntValue(ConfigFile,"printdebug",1)  
 
endfunction

Function PerformInitialization()

	ShouldInitialize = false

	LowPrioritySounds.UnMute()
	LowPrioritySoundsMale.UnMute()
	;First, find the scene we're supposed to track
	CurrentThread = Sexlab.GetThreadByActor(actorWithSceneTrackerSpell)
	ThreadID = CurrentThread.GetThreadID()
	CurrentSceneid = CurrentThread.GetActiveScene()
	currentStageID = CurrentThread.GetActiveStage()
	currentstage = GetLegacyStageNum(CurrentSceneid, currentStageID)
	
	;Second, get all the information we need on the actors in the scene and their voices
	FindActorsAndVoices()
	
	;Third, announce we are tracking this scene (this needs to come AFTER FindActorsAndVoices(), b/c that function populates the bool maleOnlyScene)
	MasterScript.RegisterThatSceneIsStarting(maleOnlyScene)
	
	;Fourth, pull the MCM settings we need to cache
	;PullMCMConfigOptions()
	
	;Then, set up some other one-time config on scene start
	hoursSinceLastSex = SexLab.HoursSinceLastSex(mainFemaleActor)
		
	;Last item of set up: register for events
	RegisterForTheEventsWeNeed()

	;After set up, greet our partner if applicable

	InitializeConfigValues()
	
	 ;Make sure everything is up to date before we make our greeting

	;Block Orgasm first if hype first before orgasm is enabled
	if hypebeforeorgasm == 1
		DisableOrgasm()
	else
		EnableOrgasm()
	endif

	;set volume
	LowPrioritySoundsMale.setvolume(partnervolume)
	HighPrioritySoundsMale.setvolume(partnervolume)
	LowPrioritySounds.setvolume(pcvolume)
	HighPrioritySounds.setvolume(pcvolume)
	
	
	IVDTUpdate()
	
	  ;TNG
  if isDependencyReady("TheNewGentleman.esp") && !TNG_Gentlewoman
    TNG_XL = Game.GetFormFromFile(0xFE5, "TheNewGentleman.esp") as Keyword
    TNG_L = Game.GetFormFromFile(0xFE4, "TheNewGentleman.esp") as Keyword
    TNG_Gentlewoman = Game.GetFormFromFile(0xFF8, "TheNewGentleman.esp") as Keyword
  endif
	
	;Set Schlong Faction
	if isDependencyReady("Schlongs of Skyrim.esp")
		schlongfaction = Game.GetFormFromFile(0xAFF8 , "Schlongs of Skyrim.esp") as Faction
		
		if !schlongfaction
			WritetoErrorlogs("IVDT" , "Schlong Faction Not Found. Ensure Mod is Properly Installed and Schlongs of Skyrim.esp Plugin Enabled")
		endif
	endif
	;Hentairim Enjoyment
	if isDependencyReady("HentairimResistance.esp")	
		HentairimResistanceFaction = Game.GetFormFromFile(0x803, "HentairimResistance.esp") as Faction	
		HentairimBroken = Game.GetFormFromFile(0x802, "HentairimResistance.esp") as Faction
		
		if !HentairimResistanceFaction
			WritetoErrorlogs("IVDT" , "Hentairim Resistance Faction Not Found. Ensure Mod is Properly Installed and HentairimResistance.esp Plugin Enabled")
		endif
		
		if !HentairimResistanceFaction
			WritetoErrorlogs("IVDT" , "Hentairim Broken Faction Not Found. Ensure Mod is Properly Installed and HentairimResistance.esp Plugin Enabled")
		endif
	endif
	
	;Oninus Lactis
	InitializeOninusLactis()
	printdebug("initialized complete")
	
	RegisterForSingleUpdate(Utility.RandomFloat(0.5, 1.0))
EndFunction


int PCPosition

Function FindActorsAndVoices()
	
	
	Actor[] actorList = CurrentThread.GetPositions()
	Int actorCount = actorList.Length
	Int actorIndex = 0

	mainFemaleVoice = MasterScript.GetVoiceForActress(playerCharacter)
	if !mainFemaleVoice
		WritetoErrorlogs("IVDT","Female Voice Not Found. Ensure Mod is properly installed and Plugin Enabled.")
	EndIf
	
	;Go through the list of all actors in the scene and get data on their gender and voices
	;PC is always main female
	While actorIndex < actorCount
	
		Actor actorInQuestion = actorList[actorIndex]
		if actorInQuestion == playerCharacter
			PCPosition = actorIndex
		endif
		
		if DefaultMaleVoice == none
			DefaultMaleVoice = MasterScript.GetDefaultMaleVoice(actorInQuestion)
		endif
		If (MasterScript.IsMale(actorInQuestion) || hasSchlong(actorInQuestion)) && actorInQuestion != playerCharacter
			;If mainMaleVoice == None
				mainMaleVoice = MasterScript.GetVoiceForActor(actorInQuestion)
				
				If mainMaleVoice != None && mainMaleActor == None
					mainMaleActor = actorInQuestion
				EndIf
			;EndIf
			
		EndIf

		actorIndex += 1
	EndWhile
			
	if mainMaleActor == None
		if mainFemaleActor == actorList[0]
			mainMaleActor = actorList[1]
		else
			mainMaleActor = actorList[0]
		endif
	endif
	
	printdebug("mainfemaleactor :" + mainFemaleActor.getleveledactorbase().GetName())
	printdebug("mainmaleactor :" + mainMaleActor.getleveledactorbase().GetName())
EndFunction

Function RegisterForTheEventsWeNeed()

	RegisterForModEvent("AnimationEnd", "IVDTSceneEnd")
	
	RegisterForModEvent("SexLabOrgasmSeparate", "IVDTOnOrgasm") 
	
	RegisterForModEvent("StageStart", "IVDTOnStageStart")
	
EndFunction


Event IVDTSceneEnd(string eventName, string argString, float argNum, form sender);
	If argString as Int != ThreadID ;If true, this isn't our scene that just ended but another scene. So, ignore it.
		Return
	EndIf
	;MasterScript.RegisterThatSceneIsEnding(maleOnlyScene)
	RemoveTracker()

EndEvent

Function ASLEndScene()	;manually end scene
	
	;MasterScript.RegisterThatSceneIsEnding(maleOnlyScene)
	RemoveTracker()

endfunction

Bool FemaleisProcessingMaleOrgasm

Event IVDTOnOrgasm(Form actorRef, Int thread)

	  PrintDebug("IVDTOnOrgasm : " + thread + " (expected " + ThreadID + "), SceneActorMatch=" + (actorWithSceneTrackerSpell == mainFemaleActor) + ", TimeSinceLastFemaleOrgasm=" + (CurrentThread.GetTimeTotal() - timeOfLastRecordedFemaleOrgasm))
	If thread != ThreadID  || actorWithSceneTrackerSpell != mainFemaleActor || CurrentThread.GetTimeTotal() - timeOfLastRecordedFemaleOrgasm <= 5
		printdebug("Exiting early: Thread mismatch, wrong actor, or orgasm cooldown active.")
		Return
	EndIf

	Actor actorHavingOrgasm = actorRef as Actor
	printdebug("Actor having orgasm: " + actorHavingOrgasm)

	if isLinearScene()
		printdebug("Processing in Linear Scene branch.")

		if (IsSuckingoffOther() || IsgettingPenetrated()) && actorHavingOrgasm != mainFemaleActor && sexlab.getsex(actorHavingOrgasm) != 1
			printdebug("Detected male orgasm during penetration/oral. Playing DefaultMaleOrgasm.")
			PlaySound(DefaultMaleVoice.Orgasm, mainFemaleActor, requiredChemistry = 0, soundPriority = 3, waitForCompletion = False, debugtext ="DefaultMaleOrgasm")

			if IsgettingPenetrated() && Utility.RandomFloat(0.0, 1.0) < ChanceToLeakThickCum && CameInsideCount > 0
				printdebug("Triggering thick cum leak effect.")
				ASLAddThickCumleak()
			endif
		endif

		if !FemaleisProcessingMaleOrgasm
			printdebug("Processing female reaction to male orgasm.")
			FemaleisProcessingMaleOrgasm = true
			if IsSuckingoffOther()
				printdebug("Playing MaleOrgasmOral sound.")
				PlaySound(mainFemaleVoice.MaleOrgasmOral, mainFemaleActor, requiredChemistry = 0, soundPriority = 3 , debugtext= "MaleOrgasmOral")
			else
				if IsHugePP
					printdebug("Playing SurprisedByMaleOrgasm sound (HugePP).")
					PlaySound(mainFemaleVoice.SurprisedByMaleOrgasm, mainFemaleActor, requiredChemistry = 0 , soundPriority = 3 , debugtext ="SurprisedByMaleOrgasm")
				else
					if moanonly == 1
						printdebug("Playing simple 'Oh' reaction to male orgasm.")
						PlaySound(mainFemaleVoice.Oh, mainFemaleActor, requiredChemistry = 0, soundPriority = 3 , debugtext= "MaleOrgasmNonOral")
					else
						printdebug("Playing MaleOrgasmNonOral sound.")
						PlaySound(mainFemaleVoice.MaleOrgasmNonOral, mainFemaleActor, requiredChemistry = 0, soundPriority = 3, debugtext= "MaleOrgasmNonOral")
					endif
				endif
			endif
			FemaleisProcessingMaleOrgasm = false
		endif

		if actorHavingOrgasm == mainFemaleActor && !IsUnconcious() && CurrentThread.GetTimeTotal() - timeOfLastRecordedFemaleOrgasm > 5
			printdebug("Main female orgasm detected. Starting orgasm sequence.")
			FemaleisProcessingMaleOrgasm = True
			int waitCounter = 0

			ASLAddOrgasmSSquirt()
			printdebug("Added orgasm squirt effect.")

			if moanonly == 1
				printdebug("Playing simple 'Oh' for female orgasm.")
				PlaySound(mainFemaleVoice.Oh, mainFemaleActor, requiredChemistry = 0, soundPriority = 3 , debugtext= "Oh")
			else
				printdebug("Playing FemaleOrgasm sound.")
				RecordFemaleOrgasm()
				PlaySound(mainFemaleVoice.Orgasm, mainFemaleActor, requiredChemistry = 0, soundPriority = 3, debugtext ="FemaleOrgasm" , Force = true)
			endif

			CommentedClosetoOrgasm = false
			printdebug("Recording female orgasm in stats.")
			ASLRemoveOrgasmSSquirt()
			printdebug("Removed orgasm squirt effect.")
			FemaleisProcessingMaleOrgasm = false
		endif
	else
		printdebug("Processing in Non-Linear Scene branch.")

		If actorHavingOrgasm != mainFemaleActor 
			printdebug("Male orgasm detected (Non-linear). Recording and reacting.")
			RecordMaleOrgasm()

			if IsSuckingoffOther() || IsgettingPenetrated()
				printdebug("Playing DefaultMaleOrgasm sound.")
				PlaySound(DefaultMaleVoice.Orgasm, mainFemaleActor, requiredChemistry = 0, soundPriority = 3, waitForCompletion = False, debugtext ="DefaultMaleOrgasm")
			endif

			if  CurrentThread.GetTimeTotal() - timeOfLastKneeJerkReaction > 2.0 && mainFemaleEnjoyment <= FemaleOrgasmHypeEnjoyment
				if MainFemaleisBurstingAtSeams() && CurrentPenetrationLvl() > 1
					float AdditionalHugePPChanceLeak = 1
					if ishugePP
						AdditionalHugePPChanceLeak = 2
					endif
					printdebug("Female surprised by male orgasm, adding cum leak & pool.")
					PlaySound(mainFemaleVoice.SurprisedByMaleOrgasm, mainFemaleActor, requiredChemistry = 0 , soundPriority = 3 , debugtext ="SurprisedByMaleOrgasm")
					ASLAddThickCumleak()
					ASLAddCumPool()
				elseif !IsSuckingoffOther() || !IsgettingPenetrated() && !femaleisvictim() && moanonly != 1
					printdebug("Playing ReadyToGetGoing sound.")
					PlaySound(mainFemaleVoice.ReadyToGetGoing, mainFemaleActor, requiredChemistry = 2 , debugtext= "ReadyToGetGoing")
				ElseIf IsSuckingoffOther()
					Utility.Wait(Utility.RandomFloat(0.5, 1.5))
					printdebug("Playing MaleOrgasmOral sound.")
					PlaySound(mainFemaleVoice.MaleOrgasmOral, mainFemaleActor, requiredChemistry = 0, soundPriority = 3 , debugtext= "MaleOrgasmOral")
				elseif ishugepp
					printdebug("Playing SurprisedByMaleOrgasm sound.")
					PlaySound(mainFemaleVoice.SurprisedByMaleOrgasm, mainFemaleActor, requiredChemistry = 0 , soundPriority = 3 , debugtext= "SurprisedByMaleOrgasm")
				elseif CurrentPenetrationLvl() > 1
					if moanonly == 1
						printdebug("Playing 'Oh' reaction.")
						PlaySound(mainFemaleVoice.Oh, mainFemaleActor, requiredChemistry = 0, soundPriority = 3 , debugtext= "MaleOrgasmNonOral")
					else
						printdebug("Playing MaleOrgasmNonOral sound.")
						PlaySound(mainFemaleVoice.MaleOrgasmNonOral, mainFemaleActor, requiredChemistry = 0, soundPriority = 3, debugtext= "MaleOrgasmNonOral")
					endif
				EndIf
			endif

			timeOfLastKneeJerkReaction = CurrentThread.GetTimeTotal()
			printdebug("Updated knee jerk reaction timer.")

			if Utility.RandomFloat(0.0, 1.0) <= 0.5
				printdebug("Setting ReacttoMaleOrgasmNext to true.")
				ReacttoMaleOrgasmNext = true
			endif
			teasedClosetoorgasm = false
		ElseIf actorHavingOrgasm == mainFemaleActor
			printdebug("Female orgasm detected (Non-linear).")
			if HasOninusLactis() && utility.randomint(1,100) <= oninuslactischancetolactateduringorgasm
				printdebug("Triggering Oninus Lactis lactation during orgasm.")
				OninusLactislactate()
			endif

			ASLAddOrgasmSSquirt()
			printdebug("Added orgasm squirt effect.")

			if !IsUnconcious()
				if moanonly == 1
					printdebug("Playing simple 'Oh' for female orgasm.")
					PlaySound(mainFemaleVoice.Oh, mainFemaleActor, requiredChemistry = 0, soundPriority = 3 , debugtext= "Oh")
				else
					printdebug("Playing FemaleOrgasm sound.")
					PlaySound(mainFemaleVoice.Orgasm, mainFemaleActor, requiredChemistry = 0, soundPriority = 3, debugtext ="FemaleOrgasm")
				endif
			endif

			if hypebeforeorgasm == 1
				printdebug("Disabling orgasm due to hypebeforeorgasm setting.")
				DisableOrgasm()
			endif

			CommentedClosetoOrgasm = false
			timeOfLastKneeJerkReaction = CurrentThread.GetTimeTotal()
			printdebug("Recording female orgasm in stats.")
			RecordFemaleOrgasm()
			ASLRemoveOrgasmSSquirt()
			printdebug("Removed orgasm squirt effect.")

			float ChancetoReact = 0.6
			if ASLCurrentlyintense
				ChancetoReact = ChancetoReact / 2
			endif

			if ChancetoReact <= Utility.RandomFloat(0.0, 1.0)
				printdebug("Setting ReacttoFemaleOrgasmNext to true.")
				ReacttoFemaleOrgasmNext = true
			endif 
		EndIf
	endif
EndEvent


Event IVDTOnStageStart(string eventName, string argString, float argNum, form sender)
	;sound.stopinstance(123)
	;int instanceID = mySFX.play(self)          ; play mySFX sound from my self
    ;Sound.SetInstanceVolume(instanceID, 0.5)   ; play at half volume
EndEvent

Event OnUpdate()
printdebug(" Updating")

if !Sexlab.GetThreadByActor(playerCharacter)
	EnableOrgasm()
	ASLEndScene()
endif

if actorWithSceneTrackerSpell == mainFemaleActor

	if ShouldInitialize == true && currentstage == 1
		PerformInitialization()
	endif
	
	;update enjoyment
	mainFemaleEnjoyment = GetActorEnjoyment(mainFemaleActor)
	mainMaleEnjoyment = GetActorEnjoyment(mainMaleActor)
	printdebug(" PC Enjoyment = " + mainFemaleEnjoyment)
	printdebug(" main Male Enjoyment = " + mainMaleEnjoyment)
	
	if !isShortenedScene()
		ProcessReadytoAdvanceStage()
	endif
	
	while MasterScript.isUpdating() ;wait for director to finish updating
		Utility.wait(0.1)
		printdebug("Waiting for Director to finish Updating")
	endwhile
	IVDTUpdate()

;=========================run Dirty Talk & sex Effects=======================	
	;usually IVDT is the slowest to be ready. dont do anything until advancing, unless someone really wants to cum first as set in config		
	if SomeoneNeedstoOrgasm || StorageUtil.GetIntValue(None, "DirectorAdvanceStage", 0) == 0
		MasterScript.IVDTAllowsAdvance(false)
		nextUpdateInterval = 0.1
		
		;run lactating
		if HasOninusLactis() && (IsgettingPenetrated() || IsGivingAnalPenetration() || IsGivingVaginalPenetration())
			if Isintense() && utility.randomint(1,100) <= oninuslactischancetolactateduringintense
				OninusLactislactate()
			elseif !Isintense() && utility.randomint(1,100) <= oninuslactischancetolactateduringnonintense
				OninusLactislactate()
			endif
		endif
		
		;chance for male voice
		if AllowMaleVoice()
			PlayMaleComments()
		endif
		
		;Linear Stage : Play Pre FInal Stage Orgasm Hype
		if MasterScript.isAlmostFinalStage() && isLinearScene() && !HasDeviousGag(mainFemaleActor) && !CommentedClosetoOrgasm && !isShortenedScene() && !Masterscript.LinearSceneCanOrgasm(MainfemaleActor)
			printdebug("Playing Linear Scene Pre Final Stage")
			LinearScenePlayFemalePreFinalStage()
			CommentedClosetoOrgasm = true
		elseif isLinearScene() && IsfinalStage() && !LinearSceneDonePostOrgasmComments && !isShortenedScene()
			;wait for orgasm to complete
			while !MasterScript.DoneLinearSceneOrgasm() && CurrentThread.GetTimeTotal() - timeOfLastRecordedFemaleOrgasm <= 5 
				Utility.wait(1)
			endwhile
			printdebug("Playing Linear Scene Post Orgasm")
			LinearScenePlayFemalePostOrgasm()
			
			LinearSceneDonePostOrgasmComments = true
			commentedcumlocation = true
			commentedorgasmremark = true
			teasedClosetoorgasm = true
			
		;if gagged, override everything else
		elseif HasDeviousGag(mainFemaleActor) 
		
			EnableOrgasm()
			if EnableDDGagVoice == 1
				PlayGaggedSound()
			endif 
		elseif IsKissing()  ;kissing 
		
			PlayKissing()
		
		elseif MoanOnly == 1 || isShortenedScene()	
			PlayMoanonly()
		;if reacting to female orgasm
		elseif ReacttoFemaleOrgasmNext == true 
		
			ASLHandleFemaleOrgasmReaction()
			
		;if reacting to male orgasm
		elseif	ReacttoMaleOrgasmNext == true

			ASLHandleMaleOrgasmReaction()
			
		elseif IsSuckingoffOther() ;blowjob always first because muffled by cock
		
			PlayBlowjob()
				
		elseif IsCunnilingus() && !ASLcurrentlyintense ;Cunnilingus
			
			PlayCunnilingus()
		elseif ASLisBroken() && !ASLCurrentlyintense
		
			PlayBroken()
		
		elseif IsCowgirl() ;cowgirl or femdom
		
			PlayCowgirl()
			
		elseif IsgettingPenetrated() && IshugePP ; Huge pp Penetration
		
			PlayGettingFuckedbyHugePP()	
			
		elseif IsGettingDoublePenetrated() ; double penetratino
		
			PlayGettingFuckedDouble()
			
		elseif IsGettingInsertedBig() ; Fisting or huge objects
		
			PlayStimulatedHard() 
			
		elseif IsgettingPenetrated() ; Penetration

			PlayGettingFucked()
		
		elseif IsGivingAnalPenetration() || IsGivingVaginalPenetration() ;fucking others with penis
			
			PlayFuckingOthers()
		
		elseif IsGettingStimulated() ;Getting Stimulated like fingering but no penetration
		
			PlayGettingStimulated()
			
		elseif IsStimulatingOthers() ;Stimulating others with finger handjob footjob titfuck
			
			PlayStimulatingOthers()
			
		elseif IsEnding()
			
			PlayEnding()
			
		elseif IsLeadIN()
			
			PlayLeadIn()
		endif
		
	endif
	nextUpdateInterval = NextUpdateInterval()
endif

if actorWithSceneTrackerSpell == mainMaleActor
	nextUpdateInterval = 1.1
endif

MasterScript.IVDTAllowsAdvance(true)

RegisterForSingleUpdate(nextUpdateInterval)
	
;miscutil.PrintConsole ("-----------------End CYCLE-------------------- " )
EndEvent

Function RemoveTracker()
	; Debug.Notification("Removing IVDT tracker from " + mainFemaleActor.GetActorBase().GetName())

	StorageUtil.unSetStringValue(None, "Scenario")
	ASLRemoveOrgasmSSquirt()
	ASLRemoveThickCumleak()
	ASLRemoveCumPool()
	;Perform needed clean up first
	UnregisterForUpdate()
	LowPrioritySounds.UnMute()
	
	;Do this very last, but make sure to do it (it's what actually removes the tracker)
	actorWithSceneTrackerSpell.RemoveSpell(SceneTrackerSpell)

EndFunction



Function RecordMaleOrgasm()
	;Ordering of some these statements matter because some depend on the others...
	
	if IsgettingPenetrated()
		CameInsideCount = CameInsideCount + 1
	endif
	
	locationOfLastMaleOrgasm = CurrentPenetrationLvl()
	

	maleOrgasmCount += 1
	timeOfLastMaleOrgasm = CurrentThread.GetTimeTotal()
	
EndFunction

Function RecordFemaleOrgasm()
	femaleRecordedOrgasmCount += 1
	timeOfLastRecordedFemaleOrgasm = CurrentThread.GetTimeTotal()
	
EndFunction

Int Function GetActorEnjoyment(Actor actorInQuestion)
	If actorInQuestion == None
		Return -1
	Else
		Return CurrentThread.GetEnjoyment(actorInQuestion)
	EndIf
EndFunction

Function PlaySound(Sound theSound, Actor actorMakingSound, Int requiredChemistry = 0, Int soundPriority = 0, Float maxQueueDuration = 5.0, Bool waitForCompletion = True , string debugtext = "None" , Bool Force = false , Bool SkipWait = false)

	Sound soundToPlay = thesound

	If soundToPlay == None
	
		Return
	EndIf
	; male or other playing sound
	if actorMakingSound != mainFemaleActor && (currentlyPlayingSoundCountMale == 0 || soundpriority > 1) ;others playing sound. 
		Printdebug("Non PC Playing voice : " + debugtext)
		currentlyPlayingSoundCountMale = currentlyPlayingSoundCountMale + 1
		
		;lower down voice of female moan when male says something
	
		
		MasterScript.PlaySound(soundToPlay, actorMakingSound, waitForCompletion)
	
		currentlyPlayingSoundCountMale = currentlyPlayingSoundCountMale - 1
		

		
	;female playing sound
	elseif actorMakingSound == mainFemaleActor && (currentlyPlayingSoundCount == 0 || soundpriority > 1)	 ;Female play sound
		Printdebug("PC Playing voice : " + debugtext)
				
		ChangePCExpressions(debugtext)
		
		currentlyPlayingSoundCount = currentlyPlayingSoundCount + 1

		if SoundPriority <= 1 && soundToPlay != PreviousSound && SkipWait == false
			if ASLcurrentlyIntense
				utility.wait(utility.randomint(0,1))
			else
				utility.wait(utility.randomint(1,2))
			endif
		endif
		;track previous sound
		PreviousSound = soundToPlay

		if soundPriority >2 
			LowPrioritySounds.mute()
		endif
		
		if IsUnconcious()
			LowPrioritySounds.mute()
			HighPrioritySounds.mute()
		endif
		
		MasterScript.PlaySound(soundToPlay, actorMakingSound, waitForCompletion)
	
		currentlyPlayingSoundCount = currentlyPlayingSoundCount - 1
		
		if currentlyPlayingSoundCount ==0
			if !IsUnconcious()
				LowPrioritySounds.unmute()
				HighPrioritySounds.unmute()
			endif
		endif
	
	else
		Utility.Wait(Utility.RandomFloat(1, 2))
	EndIf

EndFunction


Bool Function IsEarlyToCum()
	Return currentstage <= 2 && maleOrgasmCount < 2
EndFunction

Bool Function ShouldPlayMaleOrgasmHype()
	return mainMaleEnjoyment >= MaleOrgasmHypeEnjoyment && teasedClosetoorgasm == false  && !isLinearScene()

EndFunction

;make romantic comment
Function MakeRomanticCommentIfRightTime(Bool forceComment = False)

	PlaySound(mainFemaleVoice.LoveyDovey, mainFemaleActor, requiredChemistry = 0, debugtext="LoveyDovey")
	
	timeOfLastRomanticRemark = CurrentThread.GetTimeTotal()
	
EndFunction

Bool Function ShouldMakeRomanticComment()
	if femaleisvictim()
		return false
	elseIf CurrentThread.GetTimeTotal() - timeOfLastRomanticRemark < 60 ;Too soon. Romantic comments should be spaced out and rare
		Return False
	ElseIf !IsgettingPenetrated() && Currentstage <= 2
		Return Utility.RandomFloat(0.0, 1.0) < 0.1
	else 
		return false
	EndIf
EndFunction


Bool Function FemaleIsSatisfied()

	Return femaleRecordedOrgasmCount > utility.randomint(2,3)
endfunction

Bool Function MaleIsSatisfied()

	Return maleOrgasmCount >  utility.randomint(2,4)
endfunction


Bool Function PossiblyAskForCumInSpecificLocation()

	if IsGettingDoublePenetrated()
		if Utility.RandomFloat(0.0, 1.0) < 0.3
			PlaySound(mainFemaleVoice.AskForAnalCum, mainFemaleActor, requiredChemistry = 3 , debugtext = "AskForAnalCum")
		else	
			PlaySound(mainFemaleVoice.AskForVaginalCum, mainFemaleActor, requiredChemistry = 4 , debugtext = "AskForVaginalCum")
		endif
	elseif IsGettingVaginallyPenetrated()
		PlaySound(mainFemaleVoice.AskForVaginalCum, mainFemaleActor, requiredChemistry = 4 , debugtext = "AskForVaginalCum")
	elseif IsGettingAnallyPenetrated()
		PlaySound(mainFemaleVoice.AskForAnalCum, mainFemaleActor, requiredChemistry = 3 , debugtext = "AskForAnalCum")
   
	elseif IsSuckingoffOther()
		PlaySound(mainFemaleVoice.AskForOralCum, mainFemaleActor, requiredChemistry = 2 , debugtext = "AskForOralCum")	
	endif


EndFunction

Bool Function PossiblyRemarkOnCumLocation()
	;Go ahead with remark
	If locationOfLastMaleOrgasm == 1
		PlaySound(mainFemaleVoice.CameInMouth, mainFemaleActor, requiredChemistry = 0 , debugtext = "CameInMouth")
		Utility.Wait(Utility.RandomFloat(0.75, 1.75))
		Return True
	ElseIf locationOfLastMaleOrgasm == 2 
		PlaySound(mainFemaleVoice.CameInPussy, mainFemaleActor, requiredChemistry = 0 , debugtext = "CameInPussy")
		Utility.Wait(Utility.RandomFloat(0.75, 1.75))
		Return True
	ElseIf locationOfLastMaleOrgasm == 3 
		PlaySound(mainFemaleVoice.CameInAss, mainFemaleActor, requiredChemistry = 0 , debugtext = "CameInAss")
		
		Utility.Wait(Utility.RandomFloat(0.75, 1.75))
		
		
		Return True
	Else
		Return False ;Can't figure out where the hell we came so just uh pass on remarking
	EndIf
EndFunction

bool ishugepp

Bool function IshugePP()

  if EnableHugePPScenario != 1
    return false
  endif
	return MasterScript.IsHugePP(mainMaleActor)
  ;/
  int HugePPSchlongSize
  String ControlConfigFile  = "HentairimDirector/Config.json"
HugePPSchlongSize = JsonUtil.GetIntValue(ControlConfigFile, "soshugeppsize" ,6)
  Race MaleActorRace = mainMaleActor.GetRace()
  String MaleRaceName = MaleActorRace.GetName()
  if stringutil.find(MaleRaceName, "Brute") > -1 || stringutil.find(MaleRaceName, "Spider") > -1 || stringutil.find(MaleRaceName, "Lurker") > -1 || stringutil.find(MaleRaceName, "Daedroth") > -1 || stringutil.find(MaleRaceName, "Horse") > -1 || stringutil.find(MaleRaceName, "Bear") > -1 || stringutil.find(MaleRaceName, "Chaurus") > -1 || stringutil.find(MaleRaceName, "Dragon") > -1 || MaleRaceName == "Frost Atronach" || stringutil.find(MaleRaceName, "Giant") > -1 || MaleRaceName == "Mammoth" || MaleRaceName == "Sabre Cat" || stringutil.find(MaleRaceName, "Troll") > -1 || MaleRaceName == "Werewolf" || stringutil.find(MaleRaceName, "Gargoyle") > -1 || MaleRaceName == "Dwarven Centurion" || stringutil.find(MaleRaceName, "Ogre") > -1 || MaleRaceName == "Ogrim" || MaleRaceName == "Nest Ant Flier" || stringutil.find(MaleRaceName, "OGrim") > -1
    return True
  else
    ;if Schlong is big
    if (SchlongFaction)
      return mainMaleActor.GetFactionRank(SchlongFaction) >= HugePPSchlongSize
    elseif (TNG_XL)
      ;keywords can explicitly overwrite value
      int TNG_Size = TNG_PapyrusUtil.GetActorSize(mainMaleActor)
      bool tngxl = mainMaleActor.HasKeyword(TNG_XL)
      bool tngl = mainMaleActor.HasKeyword(TNG_L)
      bool isBig = tngxl || TNG_Size >= HugePPSchlongSize || tngl

      ;miscutil.PrintConsole ("DEBUG : current TNG_XL : " + tngxl)
      ;miscutil.PrintConsole ("DEBUG : current TNG_PapyrusUtil.GetActorSize : " + TNG_Size)
      ;miscutil.PrintConsole ("DEBUG : current TNG_L : " + tngl)
      ;miscutil.PrintConsole ("DEBUG : current isBig : " + isBig)
      return isBig
    endif
    return false
  endif
  /;
EndFunction


Bool Function IsLeadIN()
	return Stimulationlabel == "LDI" && PenisActionlabel == "LDI" && Penetrationlabel == "LDI" && OralLabel == "LDI" && EndingLabel == "LDI" 
endfunction 


Bool Function Ishumanoidrace()

Race MaleActorRace = mainMaleActor.GetRace()
String MaleRaceName = MaleActorRace.GetName()

if MaleRaceName ==  "Wood Elf" || MaleRaceName ==  "Draugr" || MaleRaceName ==  "Redguard" || MaleRaceName ==  "Old People Race" || MaleRaceName ==  "Khajiit" || MaleRaceName ==  "High Elf" || MaleRaceName ==  "Dremora" || MaleRaceName ==  "Draugr" || MaleRaceName ==  "Dark Elf" || MaleRaceName ==  "Giant" || MaleRaceName ==  "Orc" || MaleRaceName ==  "Troll" || MaleRaceName ==  "Werewolf" || MaleRaceName ==  "Gargoyle" || MaleRaceName ==  "Snow Troll" || MaleRaceName ==  "Nord" || MaleRaceName ==  "Imperial" || MaleRaceName ==  "Breton" || MaleRaceName ==  "Argonian"
Return True 
else 
Return False
endif
EndFunction

Bool Function FemaleIsVictim()
return CurrentThread.GetSubmissive(mainFemaleActor) && !ASLisBroken() && EnableVictimScenario == 1
EndFunction

Bool Function MaleIsVictim()
return CurrentThread.GetSubmissive(mainMaleActor) && EnableVictimScenario == 1
EndFunction


Function IVDTUpdate()
;check if thread is still running for PC
bool StageTransitioning = false

	if DirectorLastLabelTime != MasterScript.GetDirectorLastLabelTime()
		CurrentSceneid = CurrentThread.GetActiveScene()
		currentStageID = CurrentThread.GetActiveStage()
		currentstage = GetLegacyStageNum(CurrentSceneid, currentStageID)
		timeOfLastStageStart = CurrentThread.GetTimeTotal()
		
		ishugepp = ishugePP()
		printdebug("ishugepp Scenario : " + ishugepp) 
		UpdateLabels(CurrentSceneid , currentstage , PCPosition) ;update only for PC	
		StageTransitioning = true
		;set intensity
		ASLpreviouslyintense = ASLcurrentlyIntense

		if Isintense() 
			ASLCurrentlyintense = true
		else
			ASLCurrentlyintense = false
		endif
		
		DirectorLastLabelTime = MasterScript.GetDirectorLastLabelTime()
		printdebug("Stage is intense? : " + ASLCurrentlyintense)
	endif
	
;Play advance stage words
	if StageTransitioning && actorWithSceneTrackerSpell == mainFemaleActor && !isShortenedScene() && !Masterscript.isPlayingForeplayScene()

		printdebug("Stage Transitioning")
		ASLPlayStageTransition()
	endif

endfunction

Function PlayLeadIn() ;no relevant tags
printdebug("Play Lead In")

if currentstage < 3 && !femaleisvictim() ;greets only on first 2 stages	

	if  ShouldMakeRomanticComment()
		MakeRomanticCommentIfRightTime()
	elseif ishugepp && Utility.RandomFloat(0.0, 1.0) < ChanceToCommentonLeadinStage
		PlaySound(mainFemaleVoice.GreetLoadedFamiliar, mainFemaleActor, requiredChemistry = 1, debugtext = "GreetLoadedFamiliar")
	;make greeting at 7% chance at 1st stage
	elseif Utility.RandomFloat(0.0, 1.0) < ChanceToCommentonLeadinStage && Currentstage == 1
		ASLMakeGreetingToMalePartner()
	endif
endif	
	
	if PrevEndingLabel == "ENO" || PrevEndingLabel == "ENI"; for some reason if the EN stage was extended into LI	
		PlaySound(mainFemaleVoice.AfterOrgasmExclamations, mainFemaleActor, requiredChemistry = 0 , debugtext = "AfterOrgasmExclamations")
	elseif Utility.RandomFloat(0.0, 1.0) < ChanceToCommentonLeadinStage * 2 && mainFemaleEnjoyment >= 50 && !FemaleIsVictim()
		PlaySound(mainFemaleVoice.ReadyToGetGoing, mainFemaleActor, requiredChemistry = 0 , debugtext = "ReadyToGetGoing")	
	else
		
		PlayBreathyorforeplaysound()

	endif

endfunction

Function PlayKissing()
printdebug("Play Kissing")

if  ShouldMakeRomanticComment()
	MakeRomanticCommentIfRightTime()
else		
;dont say make any noise while kissing. let Enjoyment make the kissing sound
if useblowjobsoundforkissing == 1
	PlaySound(mainFemaleVoice.BlowjobActionSoft, mainFemaleActor, requiredChemistry = 0 , debugtext = "BlowjobActionSoft")
else
	Utility.wait(3)
endif
;PlayBreathyorforeplaysound()

endif
endfunction

Function PlayCunnilingus()
printdebug("Play Cunnilingus")

if ShouldPlayMaleOrgasmHype() && Utility.RandomFloat(0.0, 1.0) < ChanceToCommentWhenMaleCloseToOrgasm ; when male close to orgasm
	ASLPlayMaleClosetoOrgasmComments()
else
	PlaySound(mainFemaleVoice.BlowjobActionSoft, mainFemaleActor, requiredChemistry = 0 , debugtext = "BlowjobActionSoft")
endif
endfunction

Function PlayMaleComments()
	
	if (Primarystagelabel == "LDI" || IsGettingStimulated()) && !IsgettingPenetrated() && Currentstage < 3
	
		PlaySound(mainMaleVoice.Aroused, mainFemaleActor, requiredChemistry = 0, soundPriority = 2 ) 		

		if	ASLisBroken()
			PlaySound(mainFemaleVoice.AfterOrgasmExclamations, mainFemaleActor, requiredChemistry = 0, soundPriority = 1 , debugtext = "AfterOrgasmExclamations")	
		else
			PlaySound(mainFemaleVoice.Foreplaysoft, mainFemaleActor, requiredChemistry = 0 , debugtext = "Foreplaysoft")
		endif	

	elseif ShouldPlayMaleOrgasmHype() 

		
		PlaySound(mainMaleVoice.AboutToCum, mainFemaleActor, requiredChemistry = 0,  soundPriority = 2 , waitForCompletion = False , debugtext = "AboutToCum")
		;female background moaning
		
		if IsUnconcious()
			return
		elseif ASLisBroken()
			PlaySound(mainFemaleVoice.AfterOrgasmExclamations, mainFemaleActor, requiredChemistry = 0, soundPriority = 1 , debugtext = "AfterOrgasmExclamations")	
		else
			if ASLCurrentlyintense 

				PlaySound(mainFemaleVoice.NearOrgasmNoises, mainFemaleActor, requiredChemistry = 0 , soundPriority = 1 , debugtext = "NearOrgasmNoises")
				else
				PlaySound(mainFemaleVoice.PenetrativeGrunts, mainFemaleActor, requiredChemistry = 0 ,soundPriority = 1 , debugtext = "PenetrativeGrunts")
			endif	
		endif
		
	elseif MaleIsVictim() || IsFemdom()
		;miscutil.PrintConsole ("Playing Male Comments male victim On the attack")
		;male say something
		PlaySound(mainMaleVoice.TeaseAggressivePartner, mainFemaleActor, soundPriority = 2 , waitForCompletion = False )
		;female background moaning
		if IsUnconcious()
			return
		elseif ASLisBroken()
			PlaySound(mainFemaleVoice.AfterOrgasmExclamations, mainFemaleActor, requiredChemistry = 0, soundPriority = 1 , debugtext = "AfterOrgasmExclamations")	
		else
			PlaySound(mainFemaleVoice.PenetrativeGrunts, mainFemaleActor, requiredChemistry = 0 ,soundPriority = 1 , debugtext = "PenetrativeGrunts")
			
		endif
		
		
			
	elseif  CurrentPenetrationLvl() >= 2 && ASLCurrentlyintense 
		;miscutil.PrintConsole ("Playing Male Comments intense penetration")
		
		;male say something
		if IsUnconcious()
			return
		elseif femaleisvictim()
			PlaySound(mainMaleVoice.Aggressive, mainFemaleActor, requiredChemistry = 0, soundPriority = 2 , waitForCompletion = False  , debugtext="Aggressive")
		else
			PlaySound(mainMaleVoice.StrugglingSubtle, mainMaleActor, requiredChemistry = 0, soundPriority = 2 , waitForCompletion = False  , debugtext="StrugglingSubtle")
		endif
		;female background moaning
		
		PlaySound(mainFemaleVoice.NearOrgasmNoises, mainFemaleActor, requiredChemistry = 0 , soundPriority = 1 , debugtext = "NearOrgasmNoises")
	
	elseif	CurrentPenetrationLvl() >= 2 && !ASLCurrentlyintense 
		;miscutil.PrintConsole ("Playing Male Comments non Intense Penetration")
				;female background moaning
		PlaySound(mainMaleVoice.StrugglingEarly, mainFemaleActor, requiredChemistry = 0, soundPriority = 2 , waitForCompletion = False , debugtext = "StrugglingEarly")

		if IsUnconcious()
			return
		elseif ASLisBroken()
			PlaySound(mainFemaleVoice.AfterOrgasmExclamations, mainFemaleActor, requiredChemistry = 0, soundPriority = 1 , debugtext = "AfterOrgasmExclamations" )	
		else
			PlaySound(mainFemaleVoice.PenetrativeGrunts, mainFemaleActor, requiredChemistry = 0 ,soundPriority = 1 , debugtext = "PenetrativeGrunts")
			        
		endif
		
		
	endif		

endfunction

Function LinearScenePlayFemalePreFinalStage()
	if mainMaleEnjoyment > mainFemaleEnjoyment || MaleIsVictim()
		ASLPlayMaleClosetoOrgasmComments()
	else
		ASLPlayFemaleOrgasmHype()
	endif
endfunction
	

Function LinearScenePlayFemalePostOrgasm()
	if FemaleIsVictim()
		PlaySound(mainFemaleVoice.UnamusedEnd, mainFemaleActor, requiredChemistry = 0, soundPriority = 1 ,debugtext = "UnamusedEnd")
	else
		if MaleIsVictim()
			ASLHandlemaleOrgasmreaction()
		elseif Utility.Randomint(1,2) == 1
			ASLHandleFemaleOrgasmReaction()
		else
			PossiblyRemarkOnCumLocation()
			
		endif
	endif
endfunction

Function PlayBlowjob()

	If femaleCloseToOrgasm() && IsgettingPenetrated() ;When female close to orgasm
		ASLPlayFemaleOrgasmHype()	
	else	

		if VoiceVariation == "A"
			if ShouldPlayMaleOrgasmHype() && Utility.RandomFloat(0.0, 1.0) < ChanceToCommentWhenMaleCloseToOrgasm ; when male close to orgasm
				ASLPlayMaleClosetoOrgasmComments()
			elseif Utility.RandomFloat(0.0, 1.0) <= ChanceToCommentonBlowjobStage && ASLcurrentlyIntense
				PlaySound(mainFemaleVoice.AppreciatePartner, mainFemaleActor, requiredChemistry = 0 , debugtext = "AppreciatePartner")
			elseif Utility.RandomFloat(0.0, 1.0) <= ChanceToCommentonBlowjobStage && !femaleisvictim() && !ASLIsBroken() && !ASLcurrentlyIntense
				PlaySound(mainFemaleVoice.BlowjobRemarks, mainFemaleActor, requiredChemistry = 0 , debugtext = "BlowjobRemarks")
			elseif ASLcurrentlyIntense
				PlaySound(mainFemaleVoice.BlowjobActionIntense, mainFemaleActor, requiredChemistry = 0 , debugtext = "BlowjobActionIntense")
			else
				PlaySound(mainFemaleVoice.BlowjobActionSoft, mainFemaleActor, requiredChemistry = 0 , debugtext = "BlowjobActionSoft")
			endif
		else	
			if ShouldPlayMaleOrgasmHype() && Utility.RandomFloat(0.0, 1.0) < ChanceToCommentWhenMaleCloseToOrgasm ; when male close to orgasm
				ASLPlayMaleClosetoOrgasmComments()
			elseif Utility.RandomFloat(0.0, 1.0) < ChanceToCommentonBlowjobStage && currentstage > 1 && !femaleisvictim() && !ASLIsBroken()
				PlaySound(mainFemaleVoice.BlowjobRemarks, mainFemaleActor, requiredChemistry = 0 , debugtext = "BlowjobRemarks")
			elseif ASLcurrentlyIntense
				PlaySound(mainFemaleVoice.BlowjobActionIntense, mainFemaleActor, requiredChemistry = 0 , debugtext = "BlowjobActionIntense")
			else
				PlaySound(mainFemaleVoice.BlowjobActionSoft, mainFemaleActor, requiredChemistry = 0 , debugtext = "BlowjobActionSoft")
			endif
		endif

	endif	

endfunction

Function PlayStimulatingOthers() 
printdebug("Play Stimulating Others")

If ShouldPlayMaleOrgasmHype() && Utility.RandomFloat(0.0, 1.0) < ChanceToCommentWhenMaleCloseToOrgasm  ;if male close or orgasm
	ASLPlayMaleClosetoOrgasmComments()
else
	;after close to orgasm handling
	if	Utility.RandomFloat(0.0, 1.0) < ChanceToCommentononAttackingStage/3 && !FemaleIsVictim()
		PlaySound(mainFemaleVoice.Amused, mainFemaleActor, requiredChemistry = 0 , debugtext = "Amused")
	else
		PlayBreathyorforeplaysound()
	EndIf
			
endif
EndFunction


Function PlayStimulatedHard() 
printdebug("Play Stimulated Hard (Huge non Penile insertion)")


if CommentedClosetoOrgasm
	PlaySound(mainFemaleVoice.SensitivePleasure, mainFemaleActor, requiredChemistry = 0 , debugtext = "SensitivePleasure")
elseif femaleCloseToOrgasm() 
	ASLPlayFemaleOrgasmHype()
else
	if Utility.RandomFloat(0.0, 1.0) < 0.8
			PlaySound(mainFemaleVoice.SensitivePleasure, mainFemaleActor, requiredChemistry = 0 , debugtext = "SensitivePleasure")
	
	else	
		PlaySound(mainFemaleVoice.Oh, mainFemaleActor, requiredChemistry = 0 ,soundPriority = 3 , debugtext = "Oh")
		Utility.Wait(Utility.RandomFloat(1.0, 2.0))
		PlaySound(mainFemaleVoice.AfterGape, mainFemaleActor, requiredChemistry = 0 , soundPriority = 3 , debugtext = "AfterGape")
	endif
endif

EndFunction

Function PlayGettingStimulated() 

printdebug("Play Getting Stimulated")
;------------------INTENSE-------------------
if ASLCurrentlyintense
	
	if CommentedClosetoOrgasm
		PlaySound(mainFemaleVoice.NearOrgasmNoises, mainFemaleActor, requiredChemistry = 0 , debugtext = "NearOrgasmNoises")
	elseIf femaleCloseToOrgasm()  ;When female close to orgasm
		ASLPlayFemaleOrgasmHype()
	else ;After Handling close to Orgasm
		PlaySound(mainFemaleVoice.PenetrativeGrunts, mainFemaleActor, requiredChemistry = 0 , debugtext = "PenetrativeGrunts")
	EndIf
	
;------------------ NOt INTENSE-------------------
else	
	if CommentedClosetoOrgasm
		PlaySound(mainFemaleVoice.PenetrativeGrunts, mainFemaleActor, requiredChemistry = 0 , debugtext = "PenetrativeGrunts")
	elseIf femaleCloseToOrgasm() ;When female close to orgasm
		ASLPlayFemaleOrgasmHype()
	else
		;after handling close to orgasm
		If femaleisvictim() && Utility.RandomFloat(0.0, 1.0) < ChanceToCommentUnamused
			PlaySound(mainFemaleVoice.Unamused, mainFemaleActor, requiredChemistry = 0 , debugtext = "Unamused")
		else
			PlayBreathyorforeplaysound()
		EndIf
	endif
endif

EndFunction

Function PlayFuckingOthers() 
printdebug("Play Fucking Others")

if CommentedClosetoOrgasm
	if ASLcurrentlyintense
		PlaySound(mainFemaleVoice.PenetrativeGrunts, mainFemaleActor, requiredChemistry = 0 , debugtext = "PenetrativeGrunts")
	else
		PlayBreathyorforeplaysound()
	endif
elseIf femaleCloseToOrgasm() ;When female close to orgasm
	ASLPlayFemaleOrgasmHype()
elseIf ShouldPlayMaleOrgasmHype() && Utility.RandomFloat(0.0, 1.0) < ChanceToCommentWhenMaleCloseToOrgasm  ;if male close or orgasm
	ASLPlayMaleClosetoOrgasmComments()
else
	;after close to orgasm handling
	if	Utility.RandomFloat(0.0, 1.0) < ChanceToCommentononAttackingStage/3
		PlaySound(mainFemaleVoice.Amused, mainFemaleActor, requiredChemistry = 0 , debugtext = "Amused")
	else
		if ASLcurrentlyintense
			PlaySound(mainFemaleVoice.PenetrativeGrunts, mainFemaleActor, requiredChemistry = 0 , debugtext = "PenetrativeGrunts")
		else
			PlayBreathyorforeplaysound()
		endif
	EndIf
			
endif

EndFunction

Function PlayBroken()
printdebug("Play Broken")
if CommentedClosetoOrgasm
	PlaySound(mainFemaleVoice.PenetrativeGrunts, mainFemaleActor, requiredChemistry = 0 , debugtext = "PenetrativeGrunts")
elseIf femaleCloseToOrgasm() ;When female close to orgasm
	ASLPlayFemaleOrgasmHype()
elseif  Utility.RandomFloat(0.0, 1.0) < 0.15	&& !ASLcurrentlyintense

	PlaySound(mainFemaleVoice.AfterOrgasmExclamations, mainFemaleActor, requiredChemistry = 0, soundPriority = 1 , debugtext = "AfterOrgasmExclamations")	
elseif IsFemdom() && Utility.RandomFloat(0.0, 1.0) < ChanceToCommentononAttackingStage/2

	PlaySound(mainFemaleVoice.OnTheAttack, mainFemaleActor, requiredChemistry = 0 , debugtext = "OnTheAttack") 	
elseif  Utility.RandomFloat(0.0, 1.0) < ChanceToCommentononAttackingStage/4

	PlaySound(mainFemaleVoice.Amused, mainFemaleActor, requiredChemistry = 0, soundPriority = 1 , debugtext = "Amused") 
elseif  Utility.RandomFloat(0.0, 1.0) < ChanceToCommentononAttackingStage/4	

	PlaySound(mainFemaleVoice.InAwe, mainFemaleActor, requiredChemistry = 0 , debugtext = "InAwe")	
else

	PlaySound(mainFemaleVoice.AfterOrgasmArouse, mainFemaleActor, requiredChemistry = 0 , soundPriority = 1 , debugtext = "AfterOrgasmArouse")
endif
endfunction

Function PlayCowgirl() 

printdebug("Play Cowgirl")

if CommentedClosetoOrgasm
	if ASLcurrentlyintense
		PlaySound(mainFemaleVoice.NearOrgasmNoises, mainFemaleActor, requiredChemistry = 0 , debugtext = "NearOrgasmNoises")
	else
		PlaySound(mainFemaleVoice.PenetrativeGrunts, mainFemaleActor, requiredChemistry = 0 , debugtext = "PenetrativeGrunts")
	endif
elseIf femaleCloseToOrgasm() ;When female close to orgasm
	ASLPlayFemaleOrgasmHype()
elseIf ShouldPlayMaleOrgasmHype() && Utility.RandomFloat(0.0, 1.0) < ChanceToCommentWhenMaleCloseToOrgasm  ;if male close or orgasm
	ASLPlayMaleClosetoOrgasmComments()
else
	;after close to orgasm handling

	;make greeting 
	if Utility.RandomFloat(0.0, 1.0)  < ChanceToCommentonNonIntenseStage && currentstage == 1 && GreetedMalePartner == false && !ASLCurrentlyintense
		ASLMakeGreetingToMalePartner() 
		GreetedMalePartner = true
	endif
	
	If Utility.RandomFloat(0.0, 1.0) < ChanceToCommentononAttackingStage ; femdom comments
		if Utility.RandomInt(1,2) == 1
			PlaySound(mainFemaleVoice.OnTheAttack, mainFemaleActor, requiredChemistry = 0 , debugtext = "OnTheAttack")	
		else 
			PlaySound(mainFemaleVoice.Amused, mainFemaleActor, requiredChemistry = 0 , debugtext = "Amused")
		endif
	elseif ishugepp && Utility.RandomFloat(0.0, 1.0)  < ChanceToCommentonNonIntenseStage && !ASLcurrentlyIntense
		PlaySound(mainFemaleVoice.InAwe, mainFemaleActor, requiredChemistry = 1 , debugtext = "InAwe")
	elseif Utility.RandomFloat(0.0, 1.0)  < ChanceToCommentonNonIntenseStage && !ASLcurrentlyIntense
		if Utility.randomint(1,2) == 1
			PossiblyAskForCumInSpecificLocation()
		else
			PlaySound(mainFemaleVoice.PenetrativeCommentssoft, mainFemaleActor, requiredChemistry = 0 , debugtext = "PenetrativeCommentssoft")	
		endif
	elseif Utility.RandomFloat(0.0, 1.0)  < ChanceToCommentonIntenseStage && ASLcurrentlyIntense
		PlaySound(mainFemaleVoice.PenetrativeCommentsIntense, mainFemaleActor, requiredChemistry = 0 , debugtext = "PenetrativeCommentsIntense")	
	else	
		if ASLcurrentlyintense
			PlaySound(mainFemaleVoice.NearOrgasmNoises, mainFemaleActor, requiredChemistry = 0 , debugtext = "NearOrgasmNoises")
		else
			PlaySound(mainFemaleVoice.PenetrativeGrunts, mainFemaleActor, requiredChemistry = 0 , debugtext = "PenetrativeGrunts")
		endif
	EndIf
			
endif

EndFunction


Function PlayGettingFuckedbyHugePP() ; when on huge pp scenario
printdebug("Play Getting Fucked by Huge PP")

if CommentedClosetoOrgasm
	PlaySound(mainFemaleVoice.SensitivePleasure, mainFemaleActor, requiredChemistry = 0 , debugtext = "SensitivePleasure")
elseif femaleCloseToOrgasm() 
	ASLPlayFemaleOrgasmHype()
else
	if IsGettingDoublePenetrated()
	
		PlaySound(mainFemaleVoice.SensitivePleasure, mainFemaleActor, requiredChemistry = 0 , debugtext = "SensitivePleasure")
		
	elseif ASLCurrentlyintense	
		if IsGettingAnallyPenetrated() && utility.RandomFloat(0.0, 1.0) < chancetocommentonintensestage
			PlaySound(mainFemaleVoice.IntenseAnal, mainFemaleActor, requiredChemistry = 0 , debugtext = "IntenseAnal")
		elseif Utility.RandomFloat(0.0, 1.0) < chancetocommentonintensestage
			PlaySound(mainFemaleVoice.TeaseAggressivePartner, mainFemaleActor, requiredChemistry = 0)
		else
			PlaySound(mainFemaleVoice.SensitivePleasure, mainFemaleActor, requiredChemistry = 0 , debugtext = "SensitivePleasure")
		endif
	else

		; breath and gape breath and gape. ASL SA FA reserved for large pp creature piston cycle time > 2 seconds
		if Utility.RandomFloat(0.0, 1.0) < 0.5
			PlayBreathyorforeplaysound()
		else
			PlaySound(mainFemaleVoice.PenetrativeGrunts, mainFemaleActor, requiredChemistry = 0 , debugtext = "PenetrativeGrunts")
		endif
		
		if Utility.RandomFloat(0.0, 1.0) < 0.2
			Utility.Wait(Utility.RandomFloat(1.0, 2.0))

			PlaySound(mainFemaleVoice.Oh, mainFemaleActor, requiredChemistry = 0 ,soundPriority = 3 , debugtext = "Oh")
			Utility.Wait(1.0)

			PlaySound(mainFemaleVoice.AfterGape, mainFemaleActor, requiredChemistry = 0 , soundPriority = 3 , debugtext = "AfterGape")
		endif
	endif
endif

EndFunction


Function PlayMoanonly()
printdebug("Play Moan only")

EnableOrgasm()

if ASLCurrentlyintense
	if IsSuckingoffOther()
		PlaySound(mainFemaleVoice.BlowjobActionIntense, mainFemaleActor, requiredChemistry = 0 , debugtext = "BlowjobActionIntense")
	elseif IsgettingPenetrated()
		PlaySound(mainFemaleVoice.NearOrgasmNoises, mainFemaleActor, requiredChemistry = 0 , debugtext = "NearOrgasmNoises")
	elseif IsGettingStimulated()
		PlaySound(mainFemaleVoice.PenetrativeGrunts, mainFemaleActor, requiredChemistry = 0 , debugtext = "PenetrativeGrunts")
	else
		PlayBreathyorforeplaysound()
	endif

else
	if IsSuckingoffOther()
		PlaySound(mainFemaleVoice.BlowjobActionSoft, mainFemaleActor, requiredChemistry = 0 , debugtext = "BlowjobActionSoft")
	elseif IsgettingPenetrated()
		PlaySound(mainFemaleVoice.PenetrativeGrunts, mainFemaleActor, requiredChemistry = 0 , debugtext = "PenetrativeGrunts")
	elseif isending()
		PlaySound(mainFemaleVoice.AfterOrgasmExclamations, mainFemaleActor, requiredChemistry = 0  , debugtext = "AfterOrgasmExclamations")
	else
		PlayBreathyorforeplaysound()
	endif
	
endif
endfunction


Function PlayGettingFucked() 
printdebug("Play Getting Fucked")

;------------------ INTENSE-------------------
if ASLCurrentlyintense
	
	if CommentedClosetoOrgasm
		PlaySound(mainFemaleVoice.NearOrgasmNoises, mainFemaleActor, requiredChemistry = 0 , debugtext = "NearOrgasmNoises")
	elseIf femaleCloseToOrgasm()  ;When female close to orgasm
		ASLPlayFemaleOrgasmHype()
	elseif ShouldPlayMaleOrgasmHype() && Utility.RandomFloat(0.0, 1.0) < ChanceToCommentWhenMaleCloseToOrgasm 
		ASLPlayMaleClosetoOrgasmComments()
	else ;After Handling close to Orgasm
		if FemaleIsVictim() && Utility.RandomFloat(0.0, 1.0) < chancetocommentonintensestage
			PlaySound(mainFemaleVoice.TeaseAggressivePartner, mainFemaleActor, requiredChemistry = 0)
		elseIf IsGettingAnallyPenetrated() && Utility.RandomFloat(0.0, 1.0) < chancetocommentonintensestage
			PlaySound(mainFemaleVoice.IntenseAnal, mainFemaleActor, requiredChemistry = 0 , debugtext = "IntenseAnal")
		elseIf IsGettingVaginallyPenetrated() && Utility.RandomFloat(0.0, 1.0) < chancetocommentonintensestage
			PlaySound(mainFemaleVoice.PenetrativeCommentsIntense, mainFemaleActor, requiredChemistry = 0 , debugtext = "PenetrativeCommentsIntense")	
		else
			PlaySound(mainFemaleVoice.NearOrgasmNoises, mainFemaleActor, requiredChemistry = 0 , debugtext = "NearOrgasmNoises")
		endif
	EndIf
	
;------------------ NOT INTENSE-------------------
else	
	if CommentedClosetoOrgasm
		PlaySound(mainFemaleVoice.PenetrativeGrunts, mainFemaleActor, requiredChemistry = 0 , debugtext = "PenetrativeGrunts")
	elseIf femaleCloseToOrgasm() ;When female close to orgasm
		ASLPlayFemaleOrgasmHype()
	elseif ShouldPlayMaleOrgasmHype() && Utility.RandomFloat(0.0, 1.0) < ChanceToCommentWhenMaleCloseToOrgasm ; when male close to orgasm
		ASLPlayMaleClosetoOrgasmComments()
	else
		;after handling close to orgasm
		If femaleisvictim() && Utility.RandomFloat(0.0, 1.0) < ChanceToCommentUnamused
			PlaySound(mainFemaleVoice.Unamused, mainFemaleActor, requiredChemistry = 0 , debugtext = "Unamused")
		elseIf  Utility.RandomFloat(0.0, 1.0) < ChanceToCommentonNonIntenseStage
			PlaySound(mainFemaleVoice.PenetrativeCommentssoft, mainFemaleActor, requiredChemistry = 0 , debugtext = "PenetrativeCommentssoft")	
		else
			PlaySound(mainFemaleVoice.PenetrativeGrunts, mainFemaleActor, requiredChemistry = 0 , debugtext = "PenetrativeGrunts")
		EndIf

	endif
endif
endfunction

Function PlayGettingFuckedDouble() 
printdebug("Play Getting Double Fucked")

if ASLCurrentlyintense

	
	if CommentedClosetoOrgasm
		PlaySound(mainFemaleVoice.NearOrgasmNoises, mainFemaleActor, requiredChemistry = 0 , debugtext = "NearOrgasmNoises")
	elseIf femaleCloseToOrgasm()  ;When female close to orgasm
		ASLPlayFemaleOrgasmHype()
	elseif ShouldPlayMaleOrgasmHype() && Utility.RandomFloat(0.0, 1.0) < ChanceToCommentWhenMaleCloseToOrgasm 
		ASLPlayMaleClosetoOrgasmComments()
	else ;After Handling close to Orgasm
		If IsGettingAnallyPenetrated() && Utility.RandomFloat(0.0, 1.0) < chancetocommentonintensestage
			if Utility.Randomint(1,2) == 1
				PlaySound(mainFemaleVoice.IntenseAnal, mainFemaleActor, requiredChemistry = 0 , debugtext = "IntenseAnal")
			else
				PlaySound(mainFemaleVoice.PenetrativeCommentsIntense, mainFemaleActor, requiredChemistry = 0 , debugtext = "PenetrativeCommentsIntense")
			endif	
		else
			if CurrentThread.HasSceneTag("Tentacles")
				PlaySound(mainFemaleVoice.NearOrgasmNoises, mainFemaleActor, requiredChemistry = 0 , debugtext = "NearOrgasmNoises")
			else
				PlaySound(mainFemaleVoice.SensitivePleasure, mainFemaleActor, requiredChemistry = 0 , debugtext = "SensitivePleasure")
			endif
		endif
	EndIf
	
	;Not Intense
else	
	if CommentedClosetoOrgasm
		PlaySound(mainFemaleVoice.PenetrativeGrunts, mainFemaleActor, requiredChemistry = 0 , debugtext = "PenetrativeGrunts")
	elseIf femaleCloseToOrgasm() ;When female close to orgasm
		ASLPlayFemaleOrgasmHype()
	elseif ShouldPlayMaleOrgasmHype() && Utility.RandomFloat(0.0, 1.0) < ChanceToCommentWhenMaleCloseToOrgasm ; when male close to orgasm
		ASLPlayMaleClosetoOrgasmComments()
	else
		;after handling close to orgasm
		If femaleisvictim() && Utility.RandomFloat(0.0, 1.0) < ChanceToCommentUnamused
			PlaySound(mainFemaleVoice.Unamused, mainFemaleActor, requiredChemistry = 0 , debugtext = "Unamused")
		elseIf  Utility.RandomFloat(0.0, 1.0) < ChanceToCommentonNonIntenseStage
			PlaySound(mainFemaleVoice.TeaseAggressivePartner, mainFemaleActor, requiredChemistry = 0 , debugtext = "TeaseAggressivePartner")
		else
			if CurrentThread.HasSceneTag("Tentacles")
				PlaySound(mainFemaleVoice.PenetrativeGrunts, mainFemaleActor, requiredChemistry = 0 , soundPriority = 1 , debugtext = "PenetrativeGrunts")
			else
				PlaySound(mainFemaleVoice.NearOrgasmNoises, mainFemaleActor, requiredChemistry = 0 , debugtext = "NearOrgasmNoises")
			endif
		EndIf
	endif
endif

endfunction

Function PlayEnding()
printdebug("PLay Ending")
;chance to leak cum 
if  Utility.RandomFloat(0.0, 1.0) < ChanceToLeakThickCum && CameInsideCount > 0
	ASLAddThickCumleak()

endif
if !isLinearScene()
	EnableOrgasm()
endif
	if commentedcumlocation == false && !femaleisvictim() && CameInsideCount > 0
		commentedcumlocation = true
		PossiblyRemarkOnCumLocation()
	elseif MaleCommentsonEN == false && AllowMaleVoice() 
		;miscutil.PrintConsole ("Playing Male Comments EN stage")
		if MaleIsVictim()
			PlaySound(mainMaleVoice.TeaseAggressivePartner, mainFemaleActor, soundPriority = 2 , waitForCompletion = False ,debugtext = "TeaseAggressivePartner")
		else
			PlaySound(mainMaleVoice.PostNutRemark, mainFemaleActor, requiredChemistry = 0, soundPriority = 2 , waitForCompletion = false ,debugtext = "PostNutRemark")
		endif
		Utility.Wait(Utility.RandomFloat(1.0, 2.0))
		PlaySound(mainFemaleVoice.AfterOrgasmExclamations, mainFemaleActor, requiredChemistry = 0 ,debugtext = "AfterOrgasmExclamations")
	elseif commentedorgasmremark == false  && Utility.RandomFloat(0.0, 1.0) < ChanceToCommentonNonIntenseStage	
			If	femaleisvictim() && Utility.RandomFloat(0, 1.0) < ChanceToCommentUnamused * 3
				PlaySound(mainFemaleVoice.UnamusedEnd, mainFemaleActor, requiredChemistry = 0, soundPriority = 1 ,debugtext = "UnamusedEnd")
		elseif	femaleRecordedOrgasmCount > Utility.RandomInt(2, 3) && Utility.RandomFloat(0.0, 1.0) < ChanceToCommentonNonIntenseStage
				PlaySound(mainFemaleVoice.MadeMeCumSoMuch, mainFemaleActor, requiredChemistry = 0, soundPriority = 1 , debugtext = "MadeMeCumSoMuch")
		EndIf
	elseif CurrentThread.HasSceneTag("femdom") && Utility.RandomFloat(0.0, 1.0) < ChanceToCommentononAttackingStage
		PlaySound(mainFemaleVoice.Amused, mainFemaleActor, requiredChemistry = 0 ,debugtext = "Amused")
	else
		PlaySound(mainFemaleVoice.AfterOrgasmExclamations, mainFemaleActor, requiredChemistry = 0 ,debugtext = "AfterOrgasmExclamations")
	endif

endfunction

function PlayBreathyorforeplaysound()

	if ASLCurrentlyintense
		if Utility.RandomFloat(0.0, 1.0) <= 0.5
			PlaySound(mainFemaleVoice.Foreplayintense, mainFemaleActor, requiredChemistry = 0 , debugtext ="Foreplayintense")
		else
			PlaySound(mainFemaleVoice.BreathyIntense, mainFemaleActor, requiredChemistry = 0 , debugtext ="BreathyIntense")
		endif
	else
		if Utility.RandomFloat(0.0, 1.0) <= 0.5 
			PlaySound(mainFemaleVoice.Foreplaysoft, mainFemaleActor, requiredChemistry = 0 , debugtext ="Foreplaysoft")
		else
			PlaySound(mainFemaleVoice.BreathySoft, mainFemaleActor, requiredChemistry = 0 , debugtext ="BreathySoft")
		endif
	endif

endfunction

function ASLPlayMaleClosetoOrgasmComments()
			;miscutil.PrintConsole ("Teasing Male Close to Orgasm")
		if IsStimulatingOthers() && !IsgettingPenetrated() && !IsGettingStimulated()
			PlaySound(mainFemaleVoice.ReadyToGetGoing, mainFemaleActor, requiredChemistry = 0 , debugtext = "ReadyToGetGoing")
		elseif	mainFemaleEnjoyment > femaleorgasmhypeenjoyment && !femaleisvictim() && IsgettingPenetrated()

		PlaySound(mainFemaleVoice.CumTogetherTease, mainFemaleActor, requiredChemistry = 0 , soundPriority = 1 , debugtext = "CumTogetherTease")
		
		elseif  FemaleIsVictim() && IsgettingPenetrated()

			PlaySound(mainFemaleVoice.PullOut, mainFemaleActor, requiredChemistry = 0, soundPriority = 2 , debugtext = "PullOut")
		elseif IsEarlyToCum()	&& !ASLCurrentlyintense && !femaleisvictim() && IsgettingPenetrated()

			PlaySound(mainFemaleVoice.MaleCloseAlready, mainFemaleActor, requiredChemistry = 1, soundPriority = 1 , debugtext = "MaleCloseAlready" )
		elseif IsFemdom() && !ASLCurrentlyintense

			PlaySound(mainFemaleVoice.MaleCloseNotice, mainFemaleActor, requiredChemistry = 0, soundPriority = 1 , debugtext = "MaleCloseNotice")
			
		elseif ASLCurrentlyintense  && IsgettingPenetrated()
		
			PlaySound(mainFemaleVoice.TeaseMaleCloseToOrgasmIntense, mainFemaleActor, requiredChemistry = 1 , soundPriority = 1 , debugtext = "TeaseMaleCloseToOrgasmIntense")
		elseif  IsgettingPenetrated()

			PlaySound(mainFemaleVoice.TeaseMaleCloseToOrgasmSoft, mainFemaleActor, requiredChemistry = 1 , soundPriority = 1 , debugtext = "TeaseMaleCloseToOrgasmSoft")
		
		endif
				
		if Utility.RandomFloat(0.0, 1.0) < chancetocommentwhenmaleclosetoorgasm && !femaleisvictim()
			Utility.Wait(Utility.RandomFloat(1.0, 3.0))
			PossiblyAskForCumInSpecificLocation() 
		endif

		teasedClosetoorgasm = true 
		
endfunction

Function ASLPlayFemaleOrgasmHype()
;skip commenting orgasm if orgasm in quick succession
if CurrentThread.GetTimeTotal() - timeOfLastRecordedFemaleOrgasm <= 8 
	EnableOrgasm()
	CommentedClosetoOrgasm = true
	return
endif

;-----------------------NOT INTENSE------------------

	if !ASLCurrentlyintense
		if (IsStimulatingOthers() || IsGettingStimulated()) && !femaleisvictim() && !IsgettingPenetrated()
			PlaySound(mainFemaleVoice.ReadyToGetGoing, mainFemaleActor, requiredChemistry = 0 , debugtext = "ReadyToGetGoing")	
		elseif maleOrgasmCount > femaleRecordedOrgasmCount && Utility.RandomFloat(0.0, 1.0) < ChanceToCommentWhenCloseToOrgasm && !FemaleIsVictim()
			PlaySound(mainFemaleVoice.MyTurnToCum, mainFemaleActor, requiredChemistry = 3 , soundPriority = 1 , debugtext = "MyTurnToCum")
		Elseif Utility.RandomFloat(0.0, 1.0) < ChanceToCommentWhenCloseToOrgasm  && CommentedClosetoOrgasm == false
			PlaySound(mainFemaleVoice.NearOrgasmExclamations, mainFemaleActor, requiredChemistry = 0 , soundPriority = 1 , debugtext = "NearOrgasmExclamations")
		else
			PlaySound(mainFemaleVoice.PenetrativeGrunts, mainFemaleActor, requiredChemistry = 0 , soundPriority = 1 , debugtext = "PenetrativeGrunts")
		endif
;-----------------------INTENSE------------------
	elseif ASLcurrentlyIntense 
		If IshugePP && IsgettingPenetrated() && Utility.RandomFloat(0.0, 1.0) < ChanceToCommentWhenCloseToOrgasm
			PlaySound(mainFemaleVoice.SensitivePleasure, mainFemaleActor, requiredChemistry = 0 , soundPriority = 1 , debugtext = "SensitivePleasure")	
		EndIf
	elseif IsgettingPenetrated() || IsGettingStimulated()
		If Utility.RandomFloat(0.0, 1.0) < ChanceToCommentWhenCloseToOrgasm && CommentedClosetoOrgasm == false
			PlaySound(mainFemaleVoice.NearOrgasmExclamations, mainFemaleActor, requiredChemistry = 0 , soundPriority = 1 , debugtext = "NearOrgasmExclamations")
		Else 
			PlaySound(mainFemaleVoice.NearOrgasmNoises, mainFemaleActor, requiredChemistry = 0 , soundPriority = 1 , debugtext = "NearOrgasmNoises")
		EndIf
		
	endif
EnableOrgasm()
printdebug("Allow Female Orgasm")
CommentedClosetoOrgasm = true

EndFunction

bool function Malewantsmore()

	return mainMaleEnjoyment >= 30 || maleOrgasmCount <= Utility.randomint(1,4)

endfunction

function ASLHandlemaleOrgasmreaction()

	
	if maleOrgasmCount > 1 && !femaleisvictim() && !IsSuckingoffOther() && Utility.RandomFloat(0.0, 1.0) < chancetocommentonnonintensestage
		PlaySound(mainFemaleVoice.InAwe, mainFemaleActor, requiredChemistry = 0 , soundPriority = 1 , debugtext = "InAwe")
	endif

	;a chance to react to male orgasm
		
	if IsSuckingoffOther()
					
		if AllowMaleVoice()
			PlaySound(mainMaleVoice.JokeAfterOrgasm, mainFemaleActor, requiredChemistry = 0 , soundPriority = 2, waitForCompletion = false , debugtext = "JokeAfterOrgasm")
		endif	
				
		PlaySound(mainFemaleVoice.CameInMouth, mainFemaleActor, requiredChemistry = 0 , soundPriority = 2 , debugtext = "CameInMouth")
				
	elseif IsCowgirl() || IsGivingAnalPenetration() || IsGivingVaginalPenetration()
	
		PlaySound(mainFemaleVoice.MaleOrgasmReactionSoft, mainFemaleActor, requiredChemistry = 0, soundPriority = 2 , debugtext = "MaleOrgasmReactionSoft")
		
	elseIf 	ASLCurrentlyintense && IsgettingPenetrated()
				
		;Chance for male comments	
		if AllowMaleVoice()

			PlaySound(mainMaleVoice.JokeAfterOrgasm, mainFemaleActor, requiredChemistry = 0 , soundPriority = 1 , debugtext = "JokeAfterOrgasm")
			Utility.Wait(Utility.RandomFloat(0.5, 1.0))
		endif
		
		if Utility.RandomFloat(0.0, 1.0) < chancetocommentonnonintensestage
			PlaySound(mainFemaleVoice.MaleOrgasmReactionIntense, mainFemaleActor, requiredChemistry = 0, soundPriority = 2 , debugtext = "MaleOrgasmReactionIntense")
		endif

	Elseif IsgettingPenetrated()
		if AllowMaleVoice()
			PlaySound(mainMaleVoice.JokeAfterOrgasm, mainFemaleActor, requiredChemistry = 0 , soundPriority = 1 , debugtext = "JokeAfterOrgasm")
			Utility.Wait(Utility.RandomFloat(0.5, 2.0))
		endif
		
		if Utility.RandomFloat(0.0, 1.0) <= 0.4	
			if femaleisvictim()

				PlaySound(mainFemaleVoice.Unamused, mainFemaleActor, requiredChemistry = 0 , debugtext = "Unamused")
			else

				PlaySound(mainFemaleVoice.MaleOrgasmReactionSoft, mainFemaleActor, requiredChemistry = 0, soundPriority = 2)
			endif
		endif
	EndIf


	ReacttoMaleOrgasmNext = false

	
endfunction

Function ASLHandleFemaleOrgasmReaction()

;chance to react after orgasm

if IsSuckingoffOther() ;blowjob always first because muffled by cock
	
	PlayBlowjob()

elseif VoiceVariation == "A"

	if	ASLIsBroken() && mainMaleActor != None
	
		PlaySound(mainFemaleVoice.AfterOrgasmArouse, mainFemaleActor, requiredChemistry = 0 , soundPriority = 1 , debugtext="AfterOrgasmArouse")
		
	elseif (IsGivingAnalPenetration() || IsGivingVaginalPenetration() ) && mainMaleActor != None

		PlaySound(mainFemaleVoice.Amused, mainFemaleActor, requiredChemistry = 0, soundPriority = 1 , debugtext="Amused")
		
	elseif ASLCurrentlyintense  && Utility.RandomFloat(0.0, 1.0) < chancetocommentonintensestage && mainMaleActor != None
		if IsCowgirl()
			PlaySound(mainFemaleVoice.Amused, mainFemaleActor, requiredChemistry = 0 , soundPriority = 1 , debugtext="Amused")
		else
			PlaySound(mainFemaleVoice.AskForPacingBreak, mainFemaleActor, requiredChemistry = 0, soundPriority = 1 , debugtext="AskForPacingBreak")
		endif
	elseif !ASLCurrentlyintense && Utility.RandomFloat(0.0, 1.0) < chancetocommentonnonintensestage && mainMaleActor != None

		PlaySound(mainFemaleVoice.AfterOrgasmRemarks, mainFemaleActor, requiredChemistry = 0, soundPriority = 1 , debugtext="AfterOrgasmRemarks")
	else
		PlaySound(mainFemaleVoice.AfterOrgasmExclamations, mainFemaleActor, requiredChemistry = 0, soundPriority = 1 , debugtext="AfterOrgasmExclamations")
	endif

else
	if	ASLIsBroken()

		PlaySound(mainFemaleVoice.AfterOrgasmArouse, mainFemaleActor, requiredChemistry = 0 , soundPriority = 1 , debugtext="AfterOrgasmArouse")
	elseif IsFemdom() && Utility.RandomFloat(0.0, 1.0) < chancetocommentonnonintensestage

		PlaySound(mainFemaleVoice.Amused, mainFemaleActor, requiredChemistry = 0, soundPriority = 1 , debugtext="Amused")
		
	elseif !ASLCurrentlyintense && Utility.RandomFloat(0.0, 1.0) < chancetocommentonnonintensestage
	
		PlaySound(mainFemaleVoice.AfterOrgasmRemarks, mainFemaleActor, requiredChemistry = 0, soundPriority = 1 , debugtext="AfterOrgasmRemarks")
		
	else
		PlaySound(mainFemaleVoice.AfterOrgasmExclamations, mainFemaleActor, requiredChemistry = 0, soundPriority = 1 , debugtext="AfterOrgasmExclamations")	
	endif
endif
	
If mainMaleActor != None && Utility.RandomFloat(0.0, 1.0) < 0.5 && !FemaleIsVictim()  && !ASLCurrentlyintense
	If !FemaleIsSatisfied() && IsgettingPenetrated()
			Utility.Wait(Utility.RandomFloat(1.0, 2.0))

			PlaySound(mainFemaleVoice.WantMore, mainFemaleActor, requiredChemistry = 1, soundPriority = 1 , debugtext = "WantMore")
	else

		PlaySound(mainFemaleVoice.Satisfied, mainFemaleActor, requiredChemistry = 0, soundPriority = 1 , debugtext = "Satisfied")
	EndIf
EndIf	

ReacttoFemaleOrgasmNext = false


endfunction

Function ASLPlayStageTransition()

if currentStage >= 3
	ShouldInitialize = true
endif

if IsgettingPenetrated()
	timesGaped += 1
endif	
	
	Utility.Wait(Utility.RandomFloat(0.5, 1.0)) ; wait up to 1 second for transition to complete before playing voice

	if isShortenedScene() || moanonly == 1 
		if !PreviousStageHasPenetration() && IsgettingPenetrated()
			PlaySound(MasterScript.Sounds.PullOutGape, mainFemaleActor, requiredChemistry = 0, soundPriority = 2, waitForCompletion = false , debugtext="PullOutGape")
			if ishugepp

				PlaySound(mainFemaleVoice.AfterGape, mainFemaleActor, requiredChemistry = 0 , soundPriority = 3 , debugtext = "AfterGape")
			else
				PlaySound(mainFemaleVoice.Oh, mainFemaleActor, requiredChemistry = 0 , soundPriority = 3 , debugtext = "Oh")
			endif
			Utility.Wait(Utility.RandomFloat(0.5, 1.0))
		endif
		return
	elseif HasDeviousGag(mainFemaleActor) 
		EnableOrgasm()
		if EnableDDGagVoice == 1
			PlayGaggedSound()
		endif 	
	;male fucking somemore  from ending
	elseif	!IsEnding() && PrevEndingLabel == "ENO" && MainMaleCanControl()

			PlaySound(mainFemaleVoice.Oh, mainFemaleActor, requiredChemistry = 0 , soundPriority = 3 , SkipWait = true , debugtext="Oh")
			Utility.Wait(Utility.RandomFloat(0.5, 1.5))
			PlaySound(mainFemaleVoice.NoticeMaleWantsMore, mainFemaleActor, requiredChemistry = 0, soundPriority = 1 , debugtext="NoticeMaleWantsMore")
				
			if !MainFemaleisBurstingAtSeams()
				ASLRemoveThickCumleak()
			endif	
				
	;-------------Transition from no penetration to penetration----------------------
	elseif !PreviousStageHasPenetration() && IsgettingPenetrated()
		printdebug("Stage Transition - No Penetration to Penetration")
		PlaySound(MasterScript.Sounds.PullOutGape, mainFemaleActor, requiredChemistry = 0, soundPriority = 2, waitForCompletion = false , debugtext="PullOutGape")
		
		if ishugepp

			PlaySound(mainFemaleVoice.AfterGape, mainFemaleActor, requiredChemistry = 0 , soundPriority = 3 , debugtext = "AfterGape")
		else
			PlaySound(mainFemaleVoice.Oh, mainFemaleActor, requiredChemistry = 0 , soundPriority = 3 , debugtext = "Oh")
		endif
		Utility.Wait(Utility.RandomFloat(0.5, 1.0))

		
		if AllowMaleVoice()
			PlaySound(mainMaleVoice.StrugglingEarly, mainFemaleActor, requiredChemistry = 0, soundPriority = 2, debugtext="StrugglingEarly")
		endif
		
		IF !IsSuckingoffOther() && Utility.RandomFloat(0.0, 1.0) < chancetocommentonnonintensestage
			if IsCowgirl()

				PlaySound(mainFemaleVoice.Amused, mainFemaleActor, requiredChemistry = 0, soundPriority = 1 , debugtext="Amused")
			elseif ASLCurrentlyintense || ishugePP

				PlaySound(mainFemaleVoice.TeaseAggressivePartner, mainFemaleActor, requiredChemistry = 0 , debugtext="TeaseAggressivePartner")
				
			elseif femaleisvictim() && Utility.RandomFloat(0.5, 1.0) < 0.5
			
				PlaySound(mainFemaleVoice.Unamused, mainFemaleActor, requiredChemistry = 0 , debugtext="Unamused")	
			elseif IsGettingAnallyPenetrated()

				PlaySound(mainFemaleVoice.InsertionAnalSlow, mainFemaleActor, requiredChemistry = 0, soundPriority = 1 , debugtext="InsertionAnalSlow")
			
			else

				PlaySound(mainFemaleVoice.InsertionGeneric, mainFemaleActor, requiredChemistry = 0 ,  soundPriority = 1 , debugtext="InsertionGeneric")
			endif
				
		endif
		
	;------------maintain Fast Penetration during Transition---------------- 
	elseif ASLpreviouslyintense && ASLCurrentlyintense 
		printdebug(" Stage Transition - Maintain Intensity")
		
			if AllowMaleVoice()
				PlaySound(mainMaleVoice.Aggressive, mainFemaleActor, soundPriority = 2, debugtext="Aggressive" )
			endif
			
			if  !IsSuckingoffOther() && IsgettingPenetrated() && Utility.randomfloat(0.0,1.0) < chancetocommentonintensestage
				PlaySound(mainFemaleVoice.InAwe, mainFemaleActor, requiredChemistry = 0 , soundPriority = 1 , debugtext="InAwe" )
			endif
	;------------------Transition from Slow Penetration to Fast Penetration-----------------
	elseif !ASLpreviouslyintense && PreviousStageHasPenetration() && ASLcurrentlyintense && IsgettingPenetrated()
		
		if AllowMaleVoice() 
				PlaySound(mainMaleVoice.StrugglingSubtle, mainFemaleActor, soundPriority = 2 , waitForCompletion = false, debugtext="StrugglingSubtle" )
				
		endif		

		
		if ishugepp || IsGettingDoublePenetrated()

			PlaySound(mainFemaleVoice.AfterGape, mainFemaleActor, requiredChemistry = 0 , soundPriority = 3 , debugtext="AfterGape")

		elseif !FemaleIsVictim()
			
			if Utility.randomfloat(0.0,1.0) < chancetocommentonintensestage
				PlaySound(mainFemaleVoice.MaleHalfwayIntense, mainFemaleActor, requiredChemistry = 0 , soundPriority = 1 , debugtext="MaleHalfwayIntense")	
			endif		
		else

			if AllowMaleVoice() 
				PlaySound(mainMaleVoice.Aggressive, mainFemaleActor, soundPriority = 2 , debugtext = "Aggressive")
			endif
			
			IF Utility.randomfloat(0.0,1.0) < chancetocommentonintensestage
			Utility.Wait(Utility.RandomFloat(0.5, 1.5))
				PlaySound(mainFemaleVoice.TeaseAggressivePartner, mainFemaleActor, requiredChemistry = 0 , soundPriority = 1 , debugtext = "TeaseAggressivePartner")	
			endif
			
		endif

;----------------------------if non intense after intense penetrative action--------------
	elseif	ASLpreviouslyintense && !ASLcurrentlyIntense 
			printdebug(" Stage Transition - Non Intense to Intense")
				PlaySound(mainFemaleVoice.AfterOrgasmExclamations, mainFemaleActor, requiredChemistry = 0, soundPriority = 1 , debugtext = "AfterOrgasmExclamations")
	
	endif

endfunction

Function ASLMakeGreetingToMalePartner()

	 Bool partnerLoaded = mainMaleEnjoyment > 50 
	 
	If hoursSinceLastSex < 5.0
		Return
	EndIf

	if partnerLoaded 
		PlaySound(mainFemaleVoice.GreetLoadedFamiliar, mainFemaleActor, requiredChemistry = 4 , debugtext = "GreetLoadedFamiliar")
	elseif withMaleLover	
		PlaySound(mainFemaleVoice.GreetLover, mainFemaleActor, requiredChemistry = 6 , debugtext = "GreetLover")
	else
		PlaySound(mainFemaleVoice.GreetFamiliar, mainFemaleActor, requiredChemistry = 4 , debugtext = "GreetFamiliar")
	endif

EndFunction

Function ASLAddOrgasmSSquirt()
if Utility.RandomFloat(0.0, 1.0) < ChanceToOrgasmSquirt

if	!mainFemaleActor.IsEquipped(Game.GetFormFromFile(0xD7B19, "sr_fillherup.esp") as Armor) && Game.GetModbyName("sr_fillherup.esp") != 255 
	mainFemaleActor.addItem(Game.GetFormFromFile(0xD7B19, "sr_fillherup.esp") as Armor , abSilent=true)
	mainFemaleActor.EquipItem(Game.GetFormFromFile(0xD7B19, "sr_fillherup.esp") as Armor)
endif

endif
endfunction

Function ASLRemoveOrgasmSSquirt()
if	mainFemaleActor.IsEquipped(Game.GetFormFromFile(0xD7B19, "sr_fillherup.esp") as Armor) 
	mainFemaleActor.unEquipItem(Game.GetFormFromFile(0xD7B19, "sr_fillherup.esp") as Armor , abSilent=true)
	mainFemaleActor.removeItem(Game.GetFormFromFile(0xD7B19, "sr_fillherup.esp") as Armor)
endif

endfunction

Function ASLAddThickCumleak()
if EnableThickCumLeak != 1 
	Return
endif

	if	!mainFemaleActor.IsEquipped(Game.GetFormFromFile(0xE1D1C, "sr_fillherup.esp") as Armor) && Game.GetModbyName("sr_fillherup.esp") != 255 
		mainFemaleActor.addItem(Game.GetFormFromFile(0xE1D1C, "sr_fillherup.esp") as Armor , abSilent=true)
		mainFemaleActor.EquipItem(Game.GetFormFromFile(0xE1D1C, "sr_fillherup.esp") as Armor)
	endif

endfunction

Function ASLRemoveThickCumleak()

	if	mainFemaleActor.IsEquipped(Game.GetFormFromFile(0xE1D1C, "sr_fillherup.esp") as Armor) 
		mainFemaleActor.unEquipItem(Game.GetFormFromFile(0xE1D1C, "sr_fillherup.esp") as Armor , abSilent=true)
		mainFemaleActor.removeItem(Game.GetFormFromFile(0xE1D1C, "sr_fillherup.esp") as Armor)
	endif

endfunction

Function ASLAddCumPool()
if EnableThickCumLeak != 1 
	Return
endif

if	!mainFemaleActor.IsEquipped(Game.GetFormFromFile(0x633D5, "sr_fillherup.esp") as Armor) && Game.GetModbyName("sr_fillherup.esp") != 255 
	mainFemaleActor.addItem(Game.GetFormFromFile(0x633D5, "sr_fillherup.esp") as Armor , abSilent=true)
	mainFemaleActor.EquipItem(Game.GetFormFromFile(0x633D5, "sr_fillherup.esp") as Armor)
endif

endfunction

Function ASLRemoveCumPool()
if	mainFemaleActor.IsEquipped(Game.GetFormFromFile(0x633D5, "sr_fillherup.esp") as Armor) 
	mainFemaleActor.unEquipItem(Game.GetFormFromFile(0x633D5, "sr_fillherup.esp") as Armor , abSilent=true)
	mainFemaleActor.removeItem(Game.GetFormFromFile(0x633D5, "sr_fillherup.esp") as Armor)
endif

endfunction

bool function ASLIsBroken()	
	return GetBrokenPoints() > 0 && EnableBrokenStatus == 1
endfunction

int function GetBrokenPoints()
	return mainfemaleactor.GetFactionRank(HentairimBroken)
endFunction

Bool SomeoneNeedstoOrgasm = false

Bool Function ProcessReadytoAdvanceStage()
	
	if donotadvanceifnpcclosetoorgasm  == 1 && MainMaleCanControl() && mainMaleEnjoyment >= MaleOrgasmHypeEnjoyment && IsgettingPenetrated() ;main male busy fucking and is going to cum
		Printdebug("IVDT dont allow advance : Male Enjoyment > Orgasm Hype Enjoymen . is FUcking someone.")
		MasterScript.IVDTAllowsAdvance(false)
		SomeoneNeedstoOrgasm = true
	elseif donotadvanceifpcclosetoorgasm == 1 && mainFemaleEnjoyment >= FemaleOrgasmHypeEnjoyment && CurrentPenetrationLvl() >= 1 && !MainMaleCanControl() ;main female busy fucking and is going to cum
		Printdebug("IVDT dont allow advance : Female Enjoyment > Orgasm Hype Enjoymen . is femdom someone.")
		MasterScript.IVDTAllowsAdvance(false)
		SomeoneNeedstoOrgasm = true
	elseif donotadvanceifpartnerclosetoorgasm == 1 && mainMaleEnjoyment >= MaleOrgasmHypeEnjoyment && (IsStimulatingOthers() || IsgettingPenetrated()) && !MainMaleCanControl() ;main female wants to drain male before advancing
		Printdebug("IVDT dont allow advance : donotadvanceifpartnerclosetoorgasm = 1 . is femdom someone. Male Enjoyment > Male Enjoyment Hype. is fucking or stimulating main male")
		MasterScript.IVDTAllowsAdvance(false)
		SomeoneNeedstoOrgasm = true
	elseif  CurrentThread.GetTimeTotal() - timeOfLastRecordedFemaleOrgasm <= 7
		Printdebug("Stage not advancing After Female orgasm for 7 seconds")
		MasterScript.IVDTAllowsAdvance(false)
		SomeoneNeedstoOrgasm = true
	elseif currentlyPlayingSoundCount == 0 && currentlyPlayingSoundCountMale == 0
		MasterScript.IVDTAllowsAdvance(true)
		SomeoneNeedstoOrgasm = false
	else 
		MasterScript.IVDTAllowsAdvance(false)
		SomeoneNeedstoOrgasm = false
	endif
endfunction

Bool Function MainFemaleisBurstingAtSeams()

if has_spell(mainFemaleActor, 0x387D, "sr_fillherup.esp") 	
	return true
endif

endfunction

Bool function femaleCloseToOrgasm()
	return mainFemaleEnjoyment >= FemaleOrgasmHypeEnjoyment && CommentedClosetoOrgasm == false && !isLinearScene()
endfunction

Bool function MaleCloseToOrgasm()
	mainMaleEnjoyment >= MaleOrgasmHypeEnjoyment
endfunction

Bool function HasSchlong(Actor char)
  if !char
    return false
  endif
  if (schlongfaction)
    return char.isinfaction(schlongfaction)
  elseif (TNG_Gentlewoman)
    if SexLab.GetSex(char) == 1 && !char.HasKeyword(TNG_Gentlewoman)
      return false ; Female
    else
      return true ; Male or Futa
    endif
  else
    return SexLab.GetSex(char) == 0
  endif
endfunction

Bool Function HasDeviousGag(Actor char)
	if has_MagicEffect(char, 0x2b077, "Devious Devices - Integration.esm") 	&& Char == MainfemaleActor			;devious gag
	
			return true
		endif
endfunction


bool function has_MagicEffect(actor a, int id, string filename)
	MagicEffect ME = get_form(id, filename) as MagicEffect
	if !ME
		return false
	endif
	return a.HasMagicEffect(ME)
endfunction

bool function has_spell(actor a, int id, string filename)
	spell sp = get_form(id, filename) as spell
	if !sp
		return false
	endif
	return a.HasSpell(sp)
endfunction

form function get_form(int id, string filename)
	if Game.GetModbyName(filename) == 255 
		return None
	endif
	return Game.GetFormFromFile(id, filename)
endfunction

Bool Function AllowMaleVoice()

	return  Utility.RandomFloat(0.0, 1.0) <= ChanceForMaleToComment && EnableMaleVoice == 1 && Gender == 0 && mainMaleVoice != None ;gender must be male only
	
endfunction

Int Function CurrentPenetrationLvl()

		if Primarystagelabel == "LDI" || IsStimulatingOthers()
			return 0
		elseif IsGettingAnallyPenetrated()  ||  IsGivingAnalPenetration()
			return 3
		elseif IsGettingVaginallyPenetrated() || IsGivingVaginalPenetration()
			return 2
		elseif IsSuckingoffOther() || IsGettingSuckedoff()
			return 1
		elseif IsEnding() && (PreviouslyIsSuckingoffOther())
			return 1
		elseif IsEnding() && PreviouslyIsGettingAnallyPenetrated()
			return 3
		elseif IsEnding() && PreviouslyIsGettingVaginallyPenetrated()
			return 2
		else 
			return 0
		endif
		
	
EndFunction

Bool Function IsUnconcious()
	if (CurrentThread.HasSceneTag("faint") || CurrentThread.HasSceneTag("sleep") || CurrentThread.HasSceneTag("necro") || CurrentThread.HasSceneTag("unconscious"))
		EnableOrgasm()
		Return true
	else
		return false
	endif
endfunction


Bool Function MainMaleCanControl()
	;cowgirl femdom and non forced blowjob -> false
	if (CurrentThread.HasSceneTag("Cowgirl") || CurrentThread.HasSceneTag("femdom") || CurrentThread.HasSceneTag("Amazon") || (IsSuckingoffOther() && !CurrentThread.HasSceneTag("Forced")))  && ActorsInPlay[0] == mainFemaleActor

		return false
	else
		return true
	endif
endfunction

Bool Function Isintense()
		return stringutil.find(Labelsconcat ,"1F") > -1 || IsGettingInsertedBig()
endfunction

Bool Function IsEnding()
	return EndingLabel == "ENI" || EndingLabel == "ENO"
endfunction

Bool Function IsGivingAnalPenetration()
	return PenisActionLabel == "FDA" || PenisActionLabel == "SDA"
endfunction

Bool Function IsGivingVaginalPenetration()
	return PenisActionLabel =="FDV" || PenisActionLabel == "SDV"
endfunction

Bool Function PreviouslyIsGivingVaginalPenetration()
	return PrevPenisActionLabel =="FDV" || PrevPenisActionLabel == "SDV"
endfunction

Bool Function PreviouslyIsGivingAnalPenetration()
	return PrevPenisActionLabel =="FDA" || PrevPenisActionLabel == "FDV" 
endfunction

Bool Function IsgettingPenetrated()
	return IsGettingAnallyPenetrated() || IsGettingVaginallyPenetrated()
endfunction

Bool Function PreviouslyIsgettingPenetrated()
	return PreviouslyIsGettingAnallyPenetrated() || PreviouslyIsGettingVaginallyPenetrated()
endfunction

Bool Function IsGettingDoublePenetrated()

return PenetrationLabel == "SDP" || PenetrationLabel == "FDP" 
endfunction 

Bool Function IsGettingVaginallyPenetrated() 
	return PenetrationLabel == "SVP" || PenetrationLabel == "FVP" || PenetrationLabel == "SCG" || PenetrationLabel == "FCG" || PenetrationLabel == "SDP" || PenetrationLabel == "FDP"
endfunction

Bool Function PreviouslyIsGettingVaginallyPenetrated()
	return PrevPenetrationLabel == "SVP" || PrevPenetrationLabel == "FVP" || PrevPenetrationLabel == "SCG" || PrevPenetrationLabel == "FCG" || PrevPenetrationLabel == "SDP" || PrevPenetrationLabel == "FDP"
endfunction

Bool Function PreviouslyIsFemdom() 
	return PrevPenetrationLabel == "SCG" || PrevPenetrationLabel == "FCG" 
endfunction

Bool Function IsGettingAnallyPenetrated() 
	return PenetrationLabel == "SAP" || PenetrationLabel == "FAP"  || PenetrationLabel == "SAC" || PenetrationLabel == "FAC" || PenetrationLabel == "SDP" || PenetrationLabel == "FDP"
endfunction

Bool Function PreviouslyIsGettingAnallyPenetrated()
	return PrevPenetrationLabel == "SAP" || PrevPenetrationLabel == "FAP"  || PrevPenetrationLabel == "SAC" || PrevPenetrationLabel == "FAC" || PrevPenetrationLabel == "SDP" || PrevPenetrationLabel == "FDP"
endfunction

Bool Function IsGettingInsertedBig()
	return Stimulationlabel == "BST"
endfunction

Bool Function IsGettingSuckedoff()
	return PenisActionLabel == "SMF" ||  PenisActionLabel == "FMF"	 
endfunction

Bool Function IsGettingStimulated()
	return Stimulationlabel == "SST" ||  Stimulationlabel == "FST"
endfunction

Bool Function IsSuckingoffOther()
	return OralLabel == "SBJ" ||  OralLabel == "FBJ"
endfunction

Bool Function PreviouslyIsSuckingoffOther() 
	return PrevOralLabel == "SBJ" ||  PrevOralLabel == "FBJ"
endfunction

Bool Function IsCowgirl() 
	return (PenetrationLabel == "SCG" ||  PenetrationLabel == "FCG" ||  PenetrationLabel == "SAC" ||  PenetrationLabel == "FAC") && !femaleisvictim()	
endfunction

Bool Function PreviouslyIsCowgirl()
	return (PrevPenetrationLabel == "SCG" ||  PrevPenetrationLabel == "FCG" ||  PrevPenetrationLabel == "SAC" ||  PrevPenetrationLabel == "FAC")&& !femaleisvictim()			
endfunction

Bool Function IsKissing()
	return OralLabel == "KIS"
endfunction

;for Femdom or penetrating others
Bool Function IsFemdom()

	if	femaleisvictim() 
		return false
	else
		return IsCowgirl() || IsGivingAnalPenetration() || IsStimulatingOthers() || IsGivingOthersIntenseStimulation || IsGivingVaginalPenetration()
	endif
EndFunction


Bool Function IsCunnilingus()
	return OralLabel == "CUN"
endfunction

Bool Function PreviousStageHasPenetration()
	return PreviouslyIsGettingAnallyPenetrated() || PreviouslyIsGettingVaginallyPenetrated()
endfunction

Bool Function IsStimulatingOthers()

 return isTitfuckOthers || isHandjobOthers || IsFootjobOthers || IsCunnilingus()

endfunction

Function PrintDebug(string Contents = "")
if EnablePrintDebug == 1
;bool function WriteToFile(string fileName, string text, bool append = true, bool timestamp = false) global native
	miscutil.printconsole("HentaiRim IVDT : " + Contents)
endif
endfunction 

String Stimulationlabel
String PenisActionLabel
string OralLabel
string EndingLabel
string PenetrationLabel
String PrevStimulationlabel
String PrevPenisActionLabel
string PrevOralLabel
string PrevEndingLabel
string PrevPenetrationLabel
string Labelsconcat
Bool isTitfuckOthers = false
Bool isHandjobOthers = false
Bool IsFootjobOthers = false
Bool IsGivingOthersIntenseStimulation = false

Float  DirectorLastLabelTime
Function UpdateLabels(string anim , int stage , int actorpos = 0 )

 PrevStimulationlabel = Stimulationlabel
 PrevPenisActionLabel = PenisActionLabel
 PrevOralLabel = OralLabel
 PrevEndingLabel = EndingLabel
 PrevPenetrationLabel = PenetrationLabel
 
 SFXTag = HentaiRimTags.GetSFX(CurrentSceneID, currentstage)
 
 Stimulationlabel = MasterScript.GetStimulationlabel(mainFemaleActor)
 PenisActionLabel  = MasterScript.GetPenisActionLabel(mainFemaleActor)
 OralLabel  = MasterScript.GetOralLabel(mainFemaleActor)
 EndingLabel  = MasterScript.GetEndingLabel(mainFemaleActor)
 PenetrationLabel = MasterScript.GetPenetrationLabel(mainFemaleActor)
 
 Labelsconcat = "1" +Stimulationlabel + "1" + PenisActionLabel + "1" + OralLabel + "1" + PenetrationLabel + "1" + EndingLabel
 
 PrintDebug("Stimulationlabel :" + Stimulationlabel + ", PenisActionLabel :" +  PenisActionLabel  + ", OralLabel :" +  OralLabel  + ", PenetrationLabel :" +  PenetrationLabel  + ", EndingLabel :" +  EndingLabel)
 PrintDebug("PrevStimulationlabel :" + PrevStimulationlabel + ", PrevPenisActionLabel :" +  PrevPenisActionLabel  + ", PrevOralLabel :" +  PrevOralLabel  + ", PrevPenetrationLabel :" +  PrevPenetrationLabel  + ", PrevEndingLabel :" +  PrevEndingLabel)

;find NPC getting tit fucked
int counter = 0
string Result
 isTitfuckOthers = false
 isHandjobOthers = false
 IsFootjobOthers = false
 IsGivingOthersIntenseStimulation = false

while counter < ActorsInPlay.length && PCPosition == 0
	if counter != Actorpos ;ignore PC position
		Result = HentairimTags.PenisActionLabel(anim , stage , counter)
		
		if Result == "STF"
			isTitfuckOthers = true
			printdebug("isTitfuckOthers TRUE")
		elseif Result == "FTF"
			isTitfuckOthers = true
			IsGivingOthersIntenseStimulation = true
			printdebug("isTitfuckOthers TRUE")
			printdebug("IsGivingOthersIntenseStimulation TRUE")
		elseif Result == "SHJ"
			isHandjobOthers = true
			printdebug("isHandjobOthers TRUE")
			printdebug("IsGivingOthersIntenseStimulation TRUE")
		elseif Result == "FHJ"
			isHandjobOthers = true
			IsGivingOthersIntenseStimulation = true
			
			printdebug("isHandjobOthers TRUE")
			printdebug("IsGivingOthersIntenseStimulation TRUE")
		elseif Result == "SFJ"
			IsFootjobOthers = true
			printdebug("IsFootjobOthers TRUE")
		elseif Result == "FFJ"
			IsFootjobOthers = true
			IsGivingOthersIntenseStimulation = true
			printdebug("IsFootjobOthers TRUE")
			printdebug("IsGivingOthersIntenseStimulation TRUE")
		endif
	endif
	counter += 1
endwhile

endfunction

float function NextUpdateInterval()

if ASLcurrentlyIntense
	return Utility.RandomFloat(0.1, 1.0)
else
	return Utility.RandomFloat(1.0, 2.0)
endif

endfunction

Function PlayGaggedSound()

;intense gag noise
if ASLCurrentlyintense
	PlaySound(mainFemaleVoice.AssFlattering, mainFemaleActor, requiredChemistry =0 , debugtext = "AssFlattering")
else; less intense gag noises
	PlaySound(mainFemaleVoice.AssToMouth, mainFemaleActor, requiredChemistry = 0, debugtext = "AssToMouth")
endif

endfunction

Function ChangeHentaiExpression(String Scenario)

;ChangeHentaiExpression("hugeppgape")
;ChangeHentaiExpression("wantmore")
;ChangeHentaiExpression("kneejerk")
;ChangeHentaiExpression("orgasm")
;ChangeHentaiExpression("Amused")
;ChangeHentaiExpression("Ending")
;ChangeHentaiExpression("intensepenetrationcomments")
;ChangeHentaiExpression("grunt")
;ChangeHentaiExpression("Greeting")
;ChangeHentaiExpression("Panting")
;ChangeHentaiExpression("penetrationcomments")
;ChangeHentaiExpression("intensegrunt")
;ChangeHentaiExpression("unamused")
;ChangeHentaiExpression("unamusedending")
;ChangeHentaiExpression("inawe")
;ChangeHentaiExpression("overthetop")
;ChangeHentaiExpression("attackingcomments")
;ChangeHentaiExpression("LeadIn")
;ChangeHentaiExpression("pullout")
;ChangeHentaiExpression("maleclosetoorgasm")
;ChangeHentaiExpression("maleclosetoorgasmintense")
;ChangeHentaiExpression("closetoorgasmintense")
;ChangeHentaiExpression("closetoorgasm")
;ChangeHentaiExpression("intenseafterorgasmcomments")
;ChangeHentaiExpression("afterorgasmcomments")
;ChangeHentaiExpression("initialinsertioncomments")

StorageUtil.SetStringValue(None, "HentaiScenario" ,Scenario)

EndFunction

Function ChangePCExpressions(String debugtext = "")
if debugtext =="Oh"
	ChangeHentaiExpression("kneejerk")
elseif debugtext =="SurprisedByMaleOrgasm" || debugtext =="AfterGape"
	ChangeHentaiExpression("hugeppgape")
elseif debugtext == "InsertionAnalSlow" || debugtext == "InsertionGeneric"
	ChangeHentaiExpression("initialinsertioncomments")
elseif debugtext == "WantMore" || debugtext == "AskForAnalCum" || debugtext == "AskForVaginalCum" || debugtext == "AskForOralCum"
	ChangeHentaiExpression("wantmore")
elseif debugtext =="FemaleOrgasm" 
	ChangeHentaiExpression("orgasm")
elseif debugtext =="MaleOrgasmReactionSoft" || debugtext =="MaleHalfwayIntense" 
	ChangeHentaiExpression("penetrationcomments")
elseif debugtext =="MaleOrgasmReactionIntense" 
	ChangeHentaiExpression("intensepenetrationcomments")		
elseif debugtext == "Amused"
	ChangeHentaiExpression("Amused")				
elseif debugtext == "intensepenetrationcomments"
	ChangeHentaiExpression("Ending")
elseif debugtext == "PenetrativeCommentsIntense" || debugtext == "AskForPacingBreak" || debugtext == "TeaseAggressivePartner" || debugtext == "IntenseAnal"
	ChangeHentaiExpression("intensepenetrationcomments")
elseif debugtext == "GreetLoadedFamiliar" || debugtext == "GreetFamiliar" || debugtext == "GreetLover"
	ChangeHentaiExpression("Greeting")
elseif (debugtext == "CameInAss" || debugtext == "CameInPussy" || debugtext == "CameInMouth") && IsFemdom()
	ChangeHentaiExpression("Amused")
elseif debugtext == "CameInAss" || debugtext == "CameInPussy" || debugtext == "CameInMouth"
	ChangeHentaiExpression("penetrationcomments")
elseif debugtext == "PenetrativeCommentssoft"
	ChangeHentaiExpression("penetrationcomments")
elseif  debugtext == "Unamused"
	ChangeHentaiExpression("unamused") || (debugtext == "NoticeMaleWantsMore" && femaleisvictim())
elseif debugtext == "UnamusedEnd"
	ChangeHentaiExpression("unamusedending")
elseif debugtext == "ReadyToGetGoing" || debugtext == "InAwe" || (debugtext == "NoticeMaleWantsMore" && !femaleisvictim())
	ChangeHentaiExpression("inawe")
elseif debugtext == "SensitivePleasure" || debugtext == "AfterOrgasmArouse" 
	ChangeHentaiExpression("overthetop")
elseif debugtext == "OnTheAttack"
	ChangeHentaiExpression("attackingcomments")
elseif debugtext == "PullOut"
	ChangeHentaiExpression("pullout")
elseif debugtext == "TeaseMaleCloseToOrgasmSoft" || debugtext == "MaleCloseNotice" || debugtext == "MaleCloseAlready" || debugtext == "CumTogetherTease"
	ChangeHentaiExpression("maleclosetoorgasm")
elseif debugtext == "TeaseMaleCloseToOrgasmIntense"
	ChangeHentaiExpression("maleclosetoorgasmintense")
elseIf debugtext == "MyTurnToCum"
	ChangeHentaiExpression("closetoorgasm")
elseif debugtext == "NearOrgasmExclamations"
	ChangeHentaiExpression("closetoorgasmintense")
elseif debugtext == "AfterOrgasmRemarks" && ASLcurrentlyintense
	ChangeHentaiExpression("intenseafterorgasmcomments")
elseif debugtext == "AfterOrgasmRemarks" || debugtext == "Satisfied"
	ChangeHentaiExpression("afterorgasmcomments")
elseif debugtext == "PenetrativeGrunts"
	ChangeHentaiExpression("grunt")
elseif debugtext == "NearOrgasmNoises"
	ChangeHentaiExpression("intensegrunt")
elseif debugtext == "AfterOrgasmExclamations"
	ChangeHentaiExpression("Panting")	
elseif IsFemdom()
	ChangeHentaiExpression("attacking")
elseif IsGettingStimulated() && ASLCurrentlyintense	
	ChangeHentaiExpression("grunt")
elseif IsGettingStimulated() || debugtext == "BreathySoft" || debugtext == "Foreplaysoft"
    ChangeHentaiExpression("LeadIn")
else 
	if !IsSuckingoffOther() && debugtext != "PullOutGape"
		miscutil.PrintConsole(" IVDT " + debugtext + " Has No Expressions conditions ")
	endif
	ChangeHentaiExpression("")
endif

Endfunction

Bool Function IsfinalStage()
	return currentstage == GetLegacyStagesCount(CurrentThread.GetActiveScene())
endfunction

Quest OninusLactisQuest
int enableoninuslactislactate
int oninuslactischancetolactateduringorgasm
int oninuslactischancetolactateduringnonintense
int oninuslactischancetolactateduringintense
int mintimetolactate
int maxtimetolactate
int levelduringnonintense
int levelduringintense

	
Function InitializeOninusLactis()
	OninusLactisQuest = Game.GetFormFromFile(0xD61, "OninusLactis.esp") as Quest
	
 enableoninuslactislactate = JsonUtil.GetIntValue(OninusLactisFile,"enableoninuslactislactate",0)
 oninuslactischancetolactateduringorgasm = JsonUtil.GetIntValue(OninusLactisFile,"chancetolactateduringorgasm",0)
 oninuslactischancetolactateduringnonintense = JsonUtil.GetIntValue(OninusLactisFile,"chancetolactateduringnonintense",0)
 oninuslactischancetolactateduringintense = JsonUtil.GetIntValue(OninusLactisFile,"chancetolactateduringintense",0)
 mintimetolactate = JsonUtil.GetIntValue(OninusLactisFile,"mintimetolactate",0)
 maxtimetolactate  = JsonUtil.GetIntValue(OninusLactisFile,"maxtimetolactate",0)
 levelduringnonintense = JsonUtil.GetIntValue(OninusLactisFile,"levelduringnonintense",0)
 levelduringintense  = JsonUtil.GetIntValue(OninusLactisFile,"levelduringintense",0)
if OninusLactisQuest == none
	printdebug("Oninus Lactis not enabled or installed")
	enableoninuslactislactate = 0
else 
	printdebug("Oninus Lactis detected")
endif

endfunction

Bool function HasOninusLactis()

	if enableoninuslactislactate == 1 && Game.GetModbyName("OninusLactis.esp") != 255
		return true
	else	
		
		return false
	endif
endfunction

function OninusLactislactate()
if !HasOninusLactis()
	return
endif
	int lactatetime = utility.randomint(mintimetolactate , maxtimetolactate)
	int lactatelevel
	
	if isIntense()
		lactatelevel = levelduringintense
	else
		lactatelevel = levelduringnonintense
	endif
	
	;if HasOninusLactisNG()
    OninusLactis squirtScript = OninusLactisQuest as OninusLactis
	
	
	if squirtScript != none
		squirtScript.PlayNippleSquirt(MainfemaleActor, lactatetime ,lactatelevel)
	else
		printdebug("Something is Wrong! OninusLactis Script is none!")
	endif
	
endfunction

Bool function isDependencyReady(String modname)
  int index = Game.GetModByName(modname)
  if index == 255 || index == -1
    return false
  else
    return true
  endif
endfunction

bool Function isShortenedScene()
	return storageutil.Getfloatvalue(none,"HentairimTimerModifier",1.0) < 0.70
endfunction

bool Function isLinearScene()
	return MasterScript.isLinearScene()
endfunction

Function DisableOrgasm()
	MasterScript.DisableOrgasm(MainfemaleActor)
EndFunction

Function EnableOrgasm()
	MasterScript.DisableOrgasm(MainfemaleActor)
EndFunction

;------------------
Int Function FindInt(Int[] arr, Int target)
    Int i = 0
    While i < arr.Length
        If arr[i] == target
            Return i ; Found, return index
        EndIf
        i += 1
    EndWhile
    Return -1 ; Not found
EndFunction


function WritetoErrorlogs(string Header = "Not Specified" ,String contents = "")
	JsonUtil.StringListAdd("ErrorLog.json", Header, " : " + contents, TRUE)
endfunction

Function Announce(String Content , string icon = "icon.dds" )
	GetAnnouncement().Show(Content,"icon.dds", aiDelay = 2.0)
endfunction

int Function GetLegacyStageNum(String asScene, String asStage)
	string[] all_stages = SexlabRegistry.GetAllStages(asScene)
	if SexlabRegistry.StageExists(asScene, asStage)
		int stage_num = all_stages.find(asStage)+1
		return stage_num
	endif
	return 0
EndFunction

int Function GetLegacyStagesCount(String asScene)
	int stages_count = SexlabRegistry.GetAllStages(asScene).Length
	return stages_count
EndFunction


;/
SurprisedByMaleOrgasm - Over the top kneejerk. usually for huge pp cum inside (used by Moan Only)
ReadyToGetGoing - stage is lead in and female enjoyment is high
MaleOrgasmOral - Female reaction when male cum into mouth
Oh - kneejerk noise
MaleOrgasmNonOral - female reaction when male came inside
Orgasm - orgasm
LoveyDovey - romantic comments to when kissing 
AskForAnalCum - asking for anal cum if stage is anal penetration
AskForVaginalCum - asking for vaginal cum if stage is vaginal penetration
AskForOralCum - asking for oral cum if stage is oral penetration
CameInMouth  - Female Comments after male came in mouth
CameInPussy - Female Comments after male came in pussy
CameInAss - Female Comments after male came in ass
GreetLoadedFamiliar - Female first comments in leadin with male high enjoyment
AfterOrgasmExclamations - Female panting after non intense orgasm (used by Moan Only)
BlowjobActionSoft - blowjob sound (used by Moan Only)
Foreplaysoft - soft foreplay moan sound (used by Moan Only)
NearOrgasmNoises - intense female moans (used by Moan Only)
PenetrativeGrunts - Non Intense Female Moans (used by Moan Only)
AppreciatePartner - intense blowjob comments
BlowjobRemarks - non intense blowjob comments
BlowjobActionIntense - intense blowjob sound
Amused - Female laughs or smirks
SensitivePleasure - Over the top moans and comments. usually for huge PP penetration
AfterGape - over the top kneejerk, usually for huge PP (used by Moan Only)
Unamused - unhappy female comments. usually for female as victim scenarios.
OnTheAttack - Female says Femdom Comments
InAwe - Female goes "Wow"
AfterOrgasmArouse - Female Broken Comments
PenetrativeCommentssoft - Female comments during non intense penetration
PenetrativeCommentsIntense - Female comments during  intense penetration
IntenseAnal - Female comments during intense anal penetration
TeaseAggressivePartner - Female Comments male being aggressive
UnamusedEnd - Female Final comments at the ending
MadeMeCumSoMuch - Female comments after cumming a lot
Foreplayintense - Female Intense Foreplay moan (used by Moan Only)
BreathyIntense - Female Intense breathy moan (used by Moan Only)
BreathySoft - Female breathy moan (used by Moan Only)
CumTogetherTease - ask to cum together
PullOut - ask to pull out when male close to cumming inside
MaleCloseAlready  - Male Going to Cum Early
MaleCloseNotice  - Male is going to cum soon. for femdom
TeaseMaleCloseToOrgasmIntense  -Intense Male is going to cum soon
TeaseMaleCloseToOrgasmSoft  - Male is going to cum soon
MyTurnToCum  - Male Orgasm more than Female
NearOrgasmExclamations - Intense female comments when close to orgasm 
MaleOrgasmReactionSoft -  Reaction to Male Orgasm
MaleOrgasmReactionIntense -  Intense Reaction to Male Orgasm
AskForPacingBreak- Intense Female Comments After Orgasm
AfterOrgasmRemarks- Female Comments After Orgasm
WantMore - Female comments havent orgasm enough
Satisfied - Female comments enough orgasm
NoticeMaleWantsMore - Female Comments when Male going back a stage from Ending 
InsertionAnalSlow - Female Comments when getting first insert anally
InsertionGeneric - Female Comments when getting first insert vaginally
MaleHalfwayIntense intense Female Comments when transition from non intense to intense
GreetLover - Female Comments when they first start scene when male is lover
GreetFamiliar - Female Comments when they first start scene
AssFlattering - Intense Gag Noise
AssToMouth - Non Intense Gag Noise


male
Aroused - comments before starting penetration
AboutToCum - Near Cumming
Aggressive - Male says something during aggressive
StrugglingSubtle - male says something not so aggressive
TeaseAggressivePartner - Says Something when he is victim
orgasm - orgasm
postnutremark - comments after orgasm
StrugglingEarly - male comments during non intense
PlaySound(mainMaleVoice.AboutToCum, mainFemaleActor, requiredChemistry = 0,  soundPriority = 1 , waitForCompletion = False )
/;