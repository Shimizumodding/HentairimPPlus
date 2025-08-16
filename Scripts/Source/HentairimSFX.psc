Scriptname HentairimSFX extends ActiveMagicEffect  

SexLabFramework Property SexLab Auto 
SexLabThread CurrentThread = None
actor playerref
actor actorref
actor[] actorlist
IVDTControllerScript Property MasterScript Auto
Actor FuckingPartner ;Actor who the person with penis is fucking
Int FuckingPartnerInteractionType
SoundCategory HentairimSFXCategory
int Gender
string SFXTag
int position
int[] MasterInteractiontypes
int[] MasterPartnerInteractiontypes
bool StageShouldplayClap = false
bool isplayer
bool isReceiver ; position 0
Event OnEffectStart(Actor akTarget, Actor akCaster)
	actorref = akTarget
	PrintDebug("Effect Start")	
	
	PerformInitialization()
	
EndEvent
 
Function PerformInitialization()

	PrintDebug("Perform Initialization")	
	playerref =  game.getplayer()
	CurrentThread = Sexlab.GetThreadByActor(playerref)
	actorlist = CurrentThread.GetPositions()
	Gender = sexlab.GetGender(actorref)
	IsPlayer = actorref == playerref
	isReceiver = actorref == actorlist[0]
		;establish positions
	int x = 0
	while x < actorlist.length
		if actorref == actorlist[x]
			position = X
			x += 1000
		Endif
		x += 1
	endwhile
	
	RegisterForTheEventsWeNeed()
	
	if sexlab == none
		WritetoErrorlogs("SFX", "Sexlab Not Found!")	
	endif
	
	if CurrentThread == none
		WritetoErrorlogs("SFX", "Sexlab Thread Not Found!")	
	endif
	
	PrintDebug("actorlist" + actorlist)

	;Base Hentairim Preparation
	InitializeConfigandForms()
	HentairimPrepare()	
	
	;SFX Initialize
	HentairimSFXCategory.setvolume(volume)
	printdebug("initialized complete")
	RegisterForSingleUpdate(0.1)
EndFunction

Function RegisterForTheEventsWeNeed()
	printdebug("Registering Event")
	RegisterForModEvent("AnimationEnd", "SFXSceneEnd")
	
	RegisterForModEvent("SexLabOrgasmSeparate", "SFXOrgasm")
	
	RegisterForModEvent("StageStart", "SFXOnStageStart")
	
EndFunction

Event SFXSceneEnd(string eventName, string argString, float argNum, form sender);
	PrintDebug("Scene end")
	RemoveSFX()
EndEvent

Event SFXOnStageStart(string eventName, string argString, float argNum, form sender);
	
EndEvent

Event SFXOrgasm(Form actorhavingorgasm, Int thread) 
	;miscutil.printconsole("SFXOnStageStart On Orgasm Fire")	
EndEvent


Event OnUpdate()	
	
	HentairimUpdateStageData()
	;Ends if player is no longer in scene but magic stuck for some reason
	if Sexlab.GetThreadByActor(playerref) == none
		PrintDebug("no thread. remove Hentairim SFX")	
		RemoveSFX()
	endif

	if (IsGivingAnalPenetration() || IsGivingVaginalPenetration()) && !HasCreature() && usevelocity == 1 ;only use velocityfx for non creatures scene as no data is available
		printdebug("Running Velocity SFX")
		CalculateAndPlayVelocitySFX() ;Velocity Based SFX from reversal
	else
		printdebug("Running Normal SFX")
		PlayHentairimSFX()
	endif
	if Isintense
		updateRate = 0.05
	else
		updateRate = 0.1
	endif
	RegisterForSingleUpdate(updateRate)
	
EndEvent

String ConfigFile  = "HentairimSFX/Config.json"

int volume
int enableprintdebug
;Velocity Based Sound Forms
Sound SmallWetSlush
Sound SmallWetSlush2
Sound SmallFastSlush
Sound SmallFastSlush2
Sound MediumSlush
Sound FastSlush
Sound BigSlush
Sound SmallImpact
Sound MediumImpact1
Sound MediumImpact2
Sound MediumImpact3
Sound MediumImpact4
Sound MediumImpact5Wet
Sound FastImpact1
Sound FastImpact2
Sound FastImpact3

;Sound for random selection
Sound SmallS
SOund MediumS
Sound FastS
Sound Smalli
Sound MediumI
Sound FastI

;Normal SFX Sound Forms
Sound FastClap
Sound HeavySlushing
Sound LightSlushing
Sound MediumClap
Sound MediumSlushing
Sound RapidSlushing
Sound SlowClap
Sound Kiss1
Sound Kiss2
Sound Kiss3
Sound Kiss4
Sound Kiss5
Sound Blowjob1
Sound Blowjob2
Sound Blowjob3
Sound Blowjob4
Sound Blowjob5
Sound Blowjob6
Sound FasTBlowjob1
Sound FasTBlowjob2
Sound FasTBlowjob3
Sound FasTBlowjob4
Sound FasTBlowjob5

;Normal Sound for random selection

Sound SlowBlowjob
Sound FastBlowjob
Sound Kissing
Sound SFXtoPlay

int usevelocity

Function InitializeConfigandForms()
volume = JsonUtil.GetIntValue(ConfigFile, "volume" ,100)
usevelocity = JsonUtil.GetIntValue(ConfigFile, "usevelocity" ,0)
enableprintdebug = JsonUtil.GetIntValue(ConfigFile, "printdebug" ,0)

HentairimSFXCategory =  Game.GetFormFromFile(0x803, "HentairimSFX.esp") as Soundcategory

;Velocity SFX
SmallWetSlush = Game.GetFormFromFile(0x80B, "HentairimSFX.esp") as Sound
SmallWetSlush2 = Game.GetFormFromFile(0x80C, "HentairimSFX.esp") as Sound
SmallFastSlush = Game.GetFormFromFile(0x80D, "HentairimSFX.esp") as Sound
SmallFastSlush2 = Game.GetFormFromFile(0x80E, "HentairimSFX.esp") as Sound
MediumSlush = Game.GetFormFromFile(0x80F, "HentairimSFX.esp") as Sound
FastSlush = Game.GetFormFromFile(0x810, "HentairimSFX.esp") as Sound
BigSlush = Game.GetFormFromFile(0x811, "HentairimSFX.esp") as Sound
SmallImpact = Game.GetFormFromFile(0x812, "HentairimSFX.esp") as Sound
MediumImpact1 = Game.GetFormFromFile(0x81B, "HentairimSFX.esp") as Sound
MediumImpact2 = Game.GetFormFromFile(0x81C, "HentairimSFX.esp") as Sound
MediumImpact3 = Game.GetFormFromFile(0x81D, "HentairimSFX.esp") as Sound
MediumImpact4 = Game.GetFormFromFile(0x81E, "HentairimSFX.esp") as Sound
MediumImpact5Wet = Game.GetFormFromFile(0x81F, "HentairimSFX.esp") as Sound
FastImpact1 = Game.GetFormFromFile(0x820, "HentairimSFX.esp") as Sound
FastImpact2 = Game.GetFormFromFile(0x821, "HentairimSFX.esp") as Sound
FastImpact3 = Game.GetFormFromFile(0x822, "HentairimSFX.esp") as Sound

;Normal
FastClap = Game.GetFormFromFile(0x82B, "HentairimSFX.esp") as Sound
HeavySlushing = Game.GetFormFromFile(0x82c, "HentairimSFX.esp") as Sound
LightSlushing  = Game.GetFormFromFile(0x82E, "HentairimSFX.esp") as Sound
MediumClap  = Game.GetFormFromFile(0x82F, "HentairimSFX.esp") as Sound
MediumSlushing  = Game.GetFormFromFile(0x830, "HentairimSFX.esp") as Sound
RapidSlushing  = Game.GetFormFromFile(0x831, "HentairimSFX.esp") as Sound
SlowClap  = Game.GetFormFromFile(0x832, "HentairimSFX.esp") as Sound

Kiss1 = Game.GetFormFromFile(0x834, "HentairimSFX.esp") as Sound
Kiss2 = Game.GetFormFromFile(0x836, "HentairimSFX.esp") as Sound
Kiss3 = Game.GetFormFromFile(0x838, "HentairimSFX.esp") as Sound
Kiss4 = Game.GetFormFromFile(0x83A, "HentairimSFX.esp") as Sound
Kiss5 = Game.GetFormFromFile(0x83C, "HentairimSFX.esp") as Sound
Blowjob1 = Game.GetFormFromFile(0x83E, "HentairimSFX.esp") as Sound
Blowjob2 = Game.GetFormFromFile(0x840, "HentairimSFX.esp") as Sound
Blowjob3 = Game.GetFormFromFile(0x842, "HentairimSFX.esp") as Sound
Blowjob4 = Game.GetFormFromFile(0x844, "HentairimSFX.esp") as Sound
Blowjob5 = Game.GetFormFromFile(0x846, "HentairimSFX.esp") as Sound
Blowjob6 = Game.GetFormFromFile(0x848, "HentairimSFX.esp") as Sound
FastBlowjob1 = Game.GetFormFromFile(0x84A, "HentairimSFX.esp") as Sound
FastBlowjob2 = Game.GetFormFromFile(0x84C, "HentairimSFX.esp") as Sound
FastBlowjob3 = Game.GetFormFromFile(0x84E, "HentairimSFX.esp") as Sound
FastBlowjob4 = Game.GetFormFromFile(0x850, "HentairimSFX.esp") as Sound
FastBlowjob5 = Game.GetFormFromFile(0x852, "HentairimSFX.esp") as Sound


printdebug("volume : " + volume)
endfunction

;-------------------------------Hentairim SFX Functions START---------------------------------
;/

int Property CTYPE_ANY					= -1 	AutoReadOnly
int Property CTYPE_Vaginal 			= 1 	AutoReadOnly	; Position is being penetrated by partner
int Property CTYPE_Anal 				= 2 	AutoReadOnly	; Position is being penetrated by partner
int Property CTYPE_Oral 				= 3 	AutoReadOnly	; Position is licking/sucking partner
int Property CTYPE_Grinding 		= 4 	AutoReadOnly	; Position is being grinded against by partner (crotch area)
int Property CTYPE_Deepthroat 	= 5 	AutoReadOnly	; Implies Oral, partner's penis close to/at maximum depth
int Property CTYPE_Skullfuck 		= 6 	AutoReadOnly	; Positions head penetrated in an unexpected way by partner (Usually gore)
int Property CTYPE_LickingShaft = 7 	AutoReadOnly	; Position licking partners shaft
int Property CTYPE_FootJob 			= 8 	AutoReadOnly	; Position pleasuring partner using at least one foot
int Property CTYPE_HandJob 			= 9 	AutoReadOnly	; Position pleasuring partner using at least one hand
int Property CTYPE_Kissing 			= 10 	AutoReadOnly	; Position kissing partner
int Property CTYPE_Facial 			= 11 	AutoReadOnly	; Positions face in front of partner penis
int Property CTYPE_AnimObjFace 	= 12 	AutoReadOnly	; Position mouth close to partner anim object node
int Property CTYPE_SuckingToes	= 13	AutoReadOnly	; Position mouth close to partner toes
/;
Function RandomizeVariousVelocitySounds()

; initiate small slush
int rand = Utility.randomint(1,2)
if rand == 1
	SmallS = SmallWetSlush
elseif rand == 2
	SmallS = SmallWetSlush2
endif

; initiate Medium slush
MediumS = MediumSlush

; initialize fast slush
rand = Utility.randomint(1,3)
if rand == 1
	FastS = SmallFastSlush
elseif rand == 2
	FastS = SmallFastSlush2
elseif rand == 3
	FastS = FastSlush
endif

;initialize small impact
SmallI = SmallImpact

; initialize medium impact
rand = Utility.randomint(1,5)
if rand == 1
	MediumI = MediumImpact1
elseif rand == 2
	MediumI = MediumImpact2
elseif rand == 3
	MediumI = MediumImpact3
elseif rand == 4
	MediumI = MediumImpact4
elseif rand == 5
	MediumI = MediumImpact5Wet
endif


; initialize Fast impact
rand = Utility.randomint(1,3)
if rand == 1
	FastI = FastImpact1
elseif rand == 2
	FastI = FastImpact2
elseif rand == 3
	FastI = FastImpact3
endif

; checks to make sure there is SOund
if !SmallS
	WritetoErrorlogs("SFX","Small Slush is None! Make sure the Mod is properly installed and HentairimSFX.esp plugin enabled.")
Endif
if !MediumS
	WritetoErrorlogs("SFX","Medium Slush is None! Make sure the Mod is properly installed and HentairimSFX.esp plugin enabled.")
Endif
if !FastS
	WritetoErrorlogs("SFX","Fast Slush is None! Make sure the Mod is properly installed and HentairimSFX.esp plugin enabled.")
Endif
if !Smalli
	WritetoErrorlogs("SFX","Small Impact is None! Make sure the Mod is properly installed and HentairimSFX.esp plugin enabled.")
Endif
if !MediumI
	WritetoErrorlogs("SFX","Medium Impact is None! Make sure the Mod is properly installed and HentairimSFX.esp plugin enabled.")
Endif
if !FastI
	WritetoErrorlogs("SFX","Fast Impact is None! Make sure the Mod is properly installed and HentairimSFX.esp plugin enabled.")
Endif

;initialize Kiss
rand = utility.randomint(1,5)
if rand == 1
	Kissing = Kiss1
elseif rand == 2
	Kissing = Kiss2
elseif rand == 3
	Kissing = Kiss3
elseif rand == 4
	Kissing = Kiss4
elseif rand == 5
	Kissing = Kiss5
endif

;initialize blowjob
rand = utility.randomint(1,6)
if rand == 1
	SlowBlowjob = Blowjob1
elseif rand == 2
	SlowBlowjob = Blowjob2
elseif rand == 3
	SlowBlowjob = Blowjob3
elseif rand == 4
	SlowBlowjob = Blowjob4
elseif rand == 5
	SlowBlowjob = Blowjob5
elseif rand == 6
	SlowBlowjob = Blowjob6
endif

;initialize fast blowjob
rand = utility.randomint(1,5)
if rand == 1
	FastBlowjob = Blowjob1
elseif rand == 2
	FastBlowjob = FastBlowjob2
elseif rand == 3
	FastBlowjob = FastBlowjob3
elseif rand == 4
	FastBlowjob = FastBlowjob4
elseif rand == 5
	FastBlowjob = FastBlowjob5

endif

; checks to make sure there is SOund
if !Kissing
	miscutil.printconsole("Kissing is None! Check the Files or Forms")
Endif
if !SlowBlowjob
	miscutil.printconsole("Blowjob is None! Check the Files or Forms")
Endif
if !FastBlowjob
	miscutil.printconsole("Fast Blowjob is None! Check the Files or Forms")
Endif


EndFunction


Sound Function GetSlushSoundToPlay(int InteractionType, float TimetoThrust)
    PRINTDEBUG("GetSlushSound | TimetoThrust: " + TimetoThrust)

    if InteractionType == 1 ; vaginal
        if TimetoThrust <= 0.25
            return FastS
        elseif TimetoThrust <= 0.45
            return MediumS
        else
            return SmallS
        endif

    elseif InteractionType == 2 ; anal
        if TimetoThrust <= 0.25
            return MediumS
        elseif TimetoThrust <= 0.45
            return SmallS
        else
            return SmallS
        endif

    elseif InteractionType == 3 ; oral (TBD)
        return none ; no sound yet
    endif

    return none
EndFunction

Sound Function GetImpactSoundToPlay(float TimetoThrust)
    if !StageShouldplayClap
        return none
    endif

    PRINTDEBUG("GetImpactSound | TimetoThrust: " + TimetoThrust)

    if TimetoThrust <= 0.25
        return FastI
    elseif TimetoThrust <= 0.45
        return MediumI
    elseif TimetoThrust <= 0.75
        return Smalli
	else
		return none
    endif
EndFunction


Bool Function HasVelocityData()
	return Currentthread.GetVelocity(FuckingPartner, Actorref, FuckingPartnerInteractionType) != 0
EndFunction

float updateRate = 0.1
Float Rate 
float TimeLastReverseIn
Float TimeLastReverseOut
Bool CanPlayReverseIn
;Calculate play sound 
Function CalculateAndPlayVelocitySFX()
    if FuckingPartner == none || FuckingPartnerInteractionType == 0
		
        printdebug("NO Fucking Partner or INteraction! Updating...")
		printdebug("Masterscript interaction types : " + masterscript.GetActorInteractiontypes(actorref))
		UpdateFuckingPartner()
        return
    endif
	Float TimetoThrust = 0
    Float velocity
	Float LastVelocity
	Sound SlushVelocitySFX
	Sound ImpactVelocitySFX
;	Bool CanImpact = True ;must reverse slush from outside before impact
	;Bool CanReverseSlushFromInside = False ;must CanImpact before CanReverseSlushFromInside
;	Bool CanReverseSlushFromOutside = False ;must CanReverseSlushFromInside before CanReverseSlushFromOutside

	while Currentthread.getstatus() == 3 && DirectorLastLabelTime == MasterScript.GetDirectorLastLabelTime()  ; CurrentSceneID == CurrentThread.GetActiveScene() && currentStageID == CurrentThread.GetActiveStage()

			velocity = Currentthread.GetVelocity(FuckingPartner, Actorref, FuckingPartnerInteractionType)
			
			PrintDebug("lastVelocity=" + lastVelocity as String + " | velocity=" + velocity as String)
			
			if lastVelocity >= 0 && velocity < 0 ; Reversal From Inside
				Float CurrentReverseOutTIme = CurrentThread.GetTimeTotal()
				PrintDebug("Seconds Since Last Reverse Out : " + (CurrentReverseOutTime - TimeLastReverseOut) as String + " Seconds | CurrentReverseOutTime=" + CurrentReverseOutTime as String + " | TimeLastReverseOut=" + TimeLastReverseOut as String)
				if StageShouldplayClap
					printdebug("playing Impact Velocity")
					ImpactVelocitySFX = GetImpactSoundToPlay(TimetoThrust)
					if ImpactVelocitySFX != none
						ImpactVelocitySFX.Play(FuckingPartner)
					else
						printdebug("ImpactVelocitySFX : is none!")
					endif
				Endif	

					SlushVelocitySFX = GetSlushSoundToPlay(FuckingPartnerInteractionType, TimetoThrust)
					if SlushVelocitySFX != none
						printdebug("playing Slush Velocity")
						SlushVelocitySFX.Play(FuckingPartner)
					else
						printdebug("SlushVelocitySFX : is none!")
					endif
				TimeLastReverseOut = CurrentReverseOutTIme
				TimetoThrust = 0
			elseif CanPlayReverseIn && lastVelocity <= 0 && velocity > 0  ;reversal from outside
				printdebug("Velocity : " + Velocity + " | lastVelocity : " + LastVelocity + " | FuckingPartnerInteractionType : " + FuckingPartnerInteractionType)
				Float CurrentReverseInTIme = CurrentThread.GetTimeTotal()
				
				PrintDebug("CurrentReverseInTime=" + CurrentReverseInTime as String + " | TimeLastReverseOut=" + TimeLastReverseOut as String + " | Seconds Since Last Reverse In=" + (CurrentReverseInTime - TimeLastReverseOut) as String + " Seconds")
				SlushVelocitySFX = GetSlushSoundToPlay(FuckingPartnerInteractionType, TimetoThrust)
				if SlushVelocitySFX != none
					printdebug("playing Slush Velocity")
					SlushVelocitySFX.Play(FuckingPartner)
				else
					printdebug("SlushVelocitySFX : is none!")
				endif
				TimeLastReverseIn = CurrentReverseInTIme
			else
				printdebug("Wait")
				if Velocity > 0
					TimetoThrust += updateRate
				endif
			endif
			
			Utility.wait(updateRate)
			
			LastVelocity = velocity
	endwhile

EndFunction

;Partner whose actorref's Penis that goes into
Function UpdateFuckingPartner()
	
	FuckingPartner = None
	FuckingPartnerInteractionType = 0
	int[] Interactionarr

	
	; For more than 2 actors, loop to find a valid interaction
	int z = 0
	while z < actorList.length
		if actorList[z] != actorref ; skip self
			Interactionarr = currentthread.GetInteractionTypes(actorList[z], actorref)
			if Interactionarr.length > 0
				;has vaginal interaction
				if findint(Interactionarr , 1) > -1
					FuckingPartner = actorList[z]
					FuckingPartnerInteractionType = 1
					;has anal interaction
				elseif findint(Interactionarr , 2) > -1
					FuckingPartner = actorList[z]
					FuckingPartnerInteractionType = 2
				endif
			endif
		endif
		z += 1
	endwhile
	printdebug("GetInteractionTypes : " + currentthread.GetInteractionTypes(actorlist[0], actorref))

	; Optional: print result
	if FuckingPartner
		printdebug("Found partner: " + FuckingPartner + " with interaction type: " + FuckingPartnerInteractionType)
	else
		printdebug("No valid interaction partner found.")
	endif
	

endfunction

Function PlayHentairimSFX()
	printdebug("Playing Normal Hentairim SFX")
	while Currentthread.getstatus() == 3 && SFXtoPlay && CurrentSceneID == CurrentThread.GetActiveScene() && currentStageID == CurrentThread.GetActiveStage()
		
		PlaySound( SFXtoPlay , actorlist[0] , true)
		utility.wait(0.1)
	endwhile
EndFunction

Function HentairimSFXRefreshSound()
;refreshing

	SFXTag = HentaiRimTags.GetSFX(CurrentSceneID, currentstage)
	printdebug("SFXTag :" + SFXTag )
	;Play from  Tags If Any
	if SFXTag != "None" && SFXTag != ""
		if SFXTag == "SS"
			SFXtoPlay = LightSlushing
		elseif SFXTag == "MS" || (SFXTag == "SS" && GetAnimationSpeed() >= 1.2) 
			SFXtoPlay = MediumSlushing
		elseif SFXTag == "FS" || (SFXTag == "MS" && GetAnimationSpeed() >= 1.2) 
			SFXtoPlay = HeavySlushing
		elseif SFXTag == "RS" || (SFXTag == "FS" && GetAnimationSpeed() >= 1.2) 
			SFXtoPlay = RapidSlushing
		elseif SFXTag == "SC"
			SFXtoPlay = SlowClap
		elseif SFXTag == "MC" || (SFXTag == "SC" && GetAnimationSpeed() >= 1.2) 
			SFXtoPlay = MediumClap
		elseif SFXTag == "FC" || (SFXTag == "MC" && GetAnimationSpeed() >= 1.2) 
			SFXtoPlay = FastClap
		elseif SFXTag == "KS"
			SFXtoPlay = Kissing ; KISSING SOUND
		endif
	
	elseif IsGettingDoublePenetrated()
	printdebug("Is Getting Double Penetrated" )
		if	isintense
			SFXtoPlay = HeavySlushing
		else
			SFXtoPlay = RapidSlushing
		endif
	elseif IsgettingPenetrated()
	printdebug("Is getting Penetrated" )
		if isintense
			printdebug("Isintense" )
			if	ishugepp
				SFXtoPlay = HeavySlushing
			else
				SFXtoPlay = MediumSlushing
			endif
		else
			if	ishugepp
				SFXtoPlay = MediumSlushing
			else
				SFXtoPlay = LightSlushing
			endif
		endif
	elseif IsSuckingoffOther()
		if isintense
			SFXtoPlay = FastBlowjob
		else
			SFXtoPlay = SlowBlowjob
		endif
	elseif IsGettingStimulated()
	printdebug("IsGettingStimulated" )
		if isintense
			SFXtoPlay = MediumSlushing
		else
			SFXtoPlay = LightSlushing
		endif

	elseif IsCunnilingus()
	printdebug("IsCunnilingus" )
		SFXtoPlay = LightSlushing
	elseif IsKissing()
		printdebug("IsKissing" )
		SFXtoPlay = Kissing
		
	elseif !Shouldplaysound()
		printdebug("Dont play sound" )
		
		SFXtoPlay = none
	endif

endfunction

Bool Function Shouldplaysound()

return IsCunnilingus() || IsKissing() || IsGivingAnalPenetration() || IsGivingVaginalPenetration() || IsGettingStimulated() || IsGettingSuckedoff()

endfunction


Function RemoveSFX()

spell SFXSpell = Game.GetFormFromFile(0x800, "HentairimSFX.esp") as spell
actorref.RemoveSpell(SFXSpell)
	
EndFunction

;-------------------------------Hentairim  SFX Functions END---------------------------------

;-----------------------BASE HENTAIRIM Update Functions-----------------------------

Bool IsHugePP
string CurrentSceneID = ""
string currentStageID = ""
Int currentStage = -1
Int ThreadID = -1
Faction HentairimBroken
bool IsVictim

Function HentairimPrepare()

	;HentairimBroken = Game.GetFormFromFile(0x123, "HentairimTOBEDECIDED.esp") as Faction
	ThreadID = CurrentThread.GetThreadID()
	IsHugePP = IsHugePP()
	HentairimUpdateStageData()
	RandomizeVariousVelocitySounds()
	IsVictim = IsVictim(actorref)

endfunction
bool isintense 
Function HentairimUpdateStageData()

	if DirectorLastLabelTime != MasterScript.GetDirectorLastLabelTime()
		printdebug("Animation or Stage is Different. Updating Stage Data")
		CurrentSceneID = CurrentThread.GetActiveScene()
		currentStageID = CurrentThread.GetActiveStage()
		currentstage = GetLegacyStageNum(CurrentSceneID, currentStageID)
		
		UpdateLabels(actorref)
		isintense = Isintense()
		if isintense
			CanPlayReverseIn = false
		else
			CanPlayReverseIn = true
		endif
		
		printdebug("Thread Position : " + CurrentThread.GetPositionIdx(actorref))
		printdebug("current Animation : " + CurrentSceneID)
		printdebug("current StageID : " + currentStageID)
		printdebug("current stage number: " + currentstage)
		
		HentairimSFXRefreshSound()
		UpdateFuckingPartner()
		StageShouldplayClap = EndingLabel != "ENO" && EndingLabel != "ENI" && (SFXTag == "FC" || SFXTag == "MC"|| SFXTag == "SC" || CurrentThread.HasStageTag("Doggy") || CurrentThread.HasStageTag("DoggyStyle")) && (IsGivingVaginalPenetration() || IsGivingAnalPenetration())
		
		
		DirectorLastLabelTime = MasterScript.GetDirectorLastLabelTime()
		PrintDebug("Stage Should play Impact : " + StageShouldplayClap)
		
	endif


endfunction

String Stimulationlabel
String PenisActionLabel
string OralLabel
string EndingLabel
string PenetrationLabel
string Labelsconcat
;sexLabThreadController.ActorAlias(actorInQuestion).GetFullEnjoyment()


float DirectorLastLabelTime
Function UpdateLabels(actor char)
 printdebug("Updating Labels")
  Stimulationlabel = MasterScript.GetStimulationlabel(char)
 PenisActionLabel  = MasterScript.GetPenisActionLabel(char)
 OralLabel  = MasterScript.GetOralLabel(char)
 EndingLabel  = MasterScript.GetEndingLabel(char)
 PenetrationLabel = MasterScript.GetPenetrationLabel(char)
 MasterInteractiontypes = MasterScript.GetActorInteractiontypes(actorref) ;update interaction types for current stage
MasterPartnerInteractiontypes = MasterScript.GetActorPartnerInteractiontypes(actorref) ;update Partner interaction types for current stage
 
 
 printdebug("MasterInteractiontypes : " + MasterInteractiontypes)
 printdebug("MasterPartnerInteractiontypes : " + MasterPartnerInteractiontypes)
 Labelsconcat = "1" +Stimulationlabel + "1" + PenisActionLabel + "1" + OralLabel + "1" + PenetrationLabel + "1" + EndingLabel
 PrintDebug("Stimulationlabel :" + Stimulationlabel + ", PenisActionLabel :" +  PenisActionLabel  + ", OralLabel :" +  OralLabel  + ", PenetrationLabel :" +  PenetrationLabel  + ", EndingLabel :" +  EndingLabel)

endfunction
;-----------------------BASE HENTAIRIM Update Functions END-----------------------------


;-----------------------Hentairim Common Utilities START--------------------------------------

Bool Function Isintense()
	return stringutil.find(Labelsconcat ,"1F") > -1 || stringutil.find(Labelsconcat ,"BST") > -1
endfunction

Bool Function IsGettingStimulated()
	return Stimulationlabel == "SST" ||  Stimulationlabel == "FST"
endfunction

Bool Function IsSuckingoffOther()
	return OralLabel == "SBJ" ||  OralLabel == "FBJ" || FindInt(MasterInteractiontypes,3) > -1 || FindInt(MasterInteractiontypes,5) > -1
endfunction

Bool Function IsGettingDoublePenetrated()

return PenetrationLabel == "SDP" || PenetrationLabel == "FDP" || (FindInt(MasterInteractiontypes,1) > -1 && FindInt(MasterInteractiontypes,2) > -1)
endfunction 

Bool Function IsgettingPenetrated()
	return IsGettingAnallyPenetrated() || IsGettingVaginallyPenetrated()
endfunction

Bool Function IsGivingAnalPenetration()
	return FindInt(MasterPartnerInteractiontypes,2) > -1 || PenisActionLabel == "FDA" || PenisActionLabel == "SDA"
endfunction

Bool Function IsGettingSuckedoff()
	return FindInt(MasterPartnerInteractiontypes,5) > -1 || FindInt(MasterPartnerInteractiontypes,3) > -1 || PenisActionLabel == "SMF" ||  PenisActionLabel == "FMF"	 
endfunction

Bool Function IsGivingVaginalPenetration()
	return FindInt(MasterPartnerInteractiontypes,1) > -1 || PenisActionLabel =="FDV" || PenisActionLabel == "SDV"
endfunction

Bool Function Isgivinghandjoborfootjob()
	return FindInt(MasterInteractiontypes,8) > -1 || FindInt(MasterInteractiontypes,9) > -1
endfunction

Bool Function IsGettingVaginallyPenetrated() 
	return FindInt(MasterInteractiontypes,1) > -1 || PenetrationLabel == "SVP" || PenetrationLabel == "FVP" || PenetrationLabel == "SCG" || PenetrationLabel == "FCG" || PenetrationLabel == "SDP" || PenetrationLabel == "FDP"
endfunction

Bool Function IsGettingAnallyPenetrated() 
	return FindInt(MasterInteractiontypes,2) > -1 || PenetrationLabel == "SAP" || PenetrationLabel == "FAP"  || PenetrationLabel == "SAC" || PenetrationLabel == "FAC" || PenetrationLabel == "SDP" || PenetrationLabel == "FDP"
endfunction

Bool Function IsKissing()
	return OralLabel == "KIS" || FindInt(MasterInteractiontypes,10) > -1
endfunction

Bool Function IsCunnilingus()
	return FindInt(MasterPartnerInteractiontypes,13) > -1 || FindInt(MasterPartnerInteractiontypes,7) > -1 || OralLabel == "CUN"
endfunction

Bool Function IsLeadIN()
	return stringutil.find(Labelsconcat ,"1F") == -1 || stringutil.find(Labelsconcat ,"1S") == -1
endfunction 

Bool Function isEnding()
	PenisActionLabel = "ENI"
endfunction


Bool function isDependencyReady(String modname)
  int index = Game.GetModByName(modname)
  if index == 255 || index == -1
    return false
  else
    return true
  endif
endfunction

Bool function IshugePP()

	return MasterScript.ishugepp(actorref)
;/
	;no Huge PP effects if not receiving in position 0
	;SOS
	faction SchlongFaction = Game.GetFormFromFile(0xAFF8 , "Schlongs of Skyrim.esp") as Faction
	;TNG
	keyword TNG_XL
	keyword TNG_L
	keyword TNG_Gentlewoman
	;get hugepp size from director Config
	String ControlConfigFile  = "HentairimDirector/Config.json"
	 int HugePPSchlongSize = JsonUtil.GetIntValue(ControlConfigFile, "soshugeppsize" ,6)
    if !TNG_Gentlewoman && isDependencyReady("TheNewGentleman.esp")
      TNG_XL = Game.GetFormFromFile(0xFE5, "TheNewGentleman.esp") as Keyword
      TNG_L = Game.GetFormFromFile(0xFE4, "TheNewGentleman.esp") as Keyword
      TNG_Gentlewoman = Game.GetFormFromFile(0xFF8, "TheNewGentleman.esp") as Keyword
    endif

  String MaleRaceName = actorList[1].GetRace().getName()
  if stringutil.find(MaleRaceName, "Brute") > -1 || stringutil.find(MaleRaceName, "Spider") > -1 || stringutil.find(MaleRaceName, "Lurker") > -1 || stringutil.find(MaleRaceName, "Daedroth") > -1 || stringutil.find(MaleRaceName, "Horse") > -1 || stringutil.find(MaleRaceName, "Bear") > -1 || stringutil.find(MaleRaceName, "Chaurus") > -1 || stringutil.find(MaleRaceName, "Dragon") > -1 || MaleRaceName == "Frost Atronach" || stringutil.find(MaleRaceName, "Giant") > -1 || MaleRaceName == "Mammoth" || MaleRaceName == "Sabre Cat" || stringutil.find(MaleRaceName, "Troll") > -1 || MaleRaceName == "Werewolf" || stringutil.find(MaleRaceName, "Gargoyle") > -1 || MaleRaceName == "Dwarven Centurion" || stringutil.find(MaleRaceName, "Ogre") > -1 || MaleRaceName == "Ogrim" || MaleRaceName == "Nest Ant Flier" || stringutil.find(MaleRaceName, "OGrim") > -1
    return True
  else
    ;if Schlong is big
    if (SchlongFaction)
      return actorList[1].GetFactionRank(SchlongFaction) >= HugePPSchlongSize
    elseif (TNG_XL)
      ;keywords can explicitly overwrite value
      int TNG_Size = TNG_PapyrusUtil.GetActorSize(actorList[1])
      bool tngxl = actorList[1].HasKeyword(TNG_XL)
      bool tngl = actorList[1].HasKeyword(TNG_L)
      bool isBig = tngxl || TNG_Size >= HugePPSchlongSize || tngl

      return isBig
    endif
    return false
  endif
  /;
EndFunction

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

float Function GetAnimationSpeed()
return AnimSpeedHelper.GetAnimationSpeed(game.getplayer() , true)

endFunction

Function PlaySound(Sound theSound, Actor actorMakingSound, Bool waitForCompletion = True)

	If waitForCompletion
		theSound.PlayAndWait(actorMakingSound)
	Else
		theSound.Play(actorMakingSound)
	EndIf
EndFunction

Bool Function IsVictim(actor char)
  CurrentThread.GetSubmissive(char)
endFunction

Bool Function IsBroken()
	return actorref.GetFactionRank(HentairimBroken) > 0
endfunction

Function PrintDebug(string Contents = "")
if enableprintdebug == 1 && !isplayer
miscutil.printconsole(actorref.getdisplayname() + " - HentaiRim SFX " + Contents)
endif
endfunction 

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

Bool Function HasCreature()

	return sexlab.CountCreatures(actorList) > 0
endfunction

function WritetoErrorlogs(string Header = "Not Specified" ,String contents = "")
	JsonUtil.StringListAdd("ErrorLog.json", Header, " : " + contents, TRUE)
endfunction
;-----------------------Hentairim Common Utilities END--------------------------------------