Scriptname sslExpressionUtil Hidden

;mfg modifier
;BlinkL 0
;BlinkR 1
;BrowDownL 2
;BrownDownR 3
;BrowInL 4
;BrowInR 5
;BrowUpL 6
;BrowUpR 7
;LookDown 8
;LookLeft 9
;LookRight 10
;LookUp 11
;SquintL 12
;SquintR 13
;for changing 2 values at the same time (e.g. eyes squint)
;set -1 to mod2 if not needed 



Function SmoothSetModifier(Actor act, Int mod1, Int str_dest, float strModifier = 1.0) global
	
		mod1 = PapyrusUtil.ClampInt(mod1, 0, 13)
		str_dest = (str_dest * strModifier) as Int
		MfgConsoleFuncExt.SetModifier(act,mod1,str_dest, 1)

EndFunction

;Aah 0    BigAah 1
;BMP 2    ChjSh 3
;DST 4    Eee 5
;Eh 6     FV 7
;i 8      k 9
;N 10     Oh 11
;OohQ 12  R 13
;Th 14    W 15
;https://steamcommunity.com/sharedfiles/filedetails/?l=english&id=187155077


;HENTAIRIM Modifications to prevent sexlab from fighting to update MFG when it is enabled. for some reason
;MFG still gets reset even when expressions are disabled in sexlab

Function SmoothSetPhoneme(Actor act, Int id, Int str_dest, float modifier = 1.0) global
		Spell ExpressionsSpell = Game.GetFormFromFile(0x800, "HentairimExpressions.esp") as Spell
		if !Act.hasspell(ExpressionsSpell)
			str_dest = (str_dest * modifier) as Int
			id = PapyrusUtil.ClampInt(id, 0, 15)
			MfgConsoleFuncExt.SetPhoneme(act,id,str_dest, 1)
		endif
EndFunction

Function ApplyExpressionPreset(Actor akActor, float[] expression, bool openMouth) global
	
		Spell ExpressionsSpell = Game.GetFormFromFile(0x800, "HentairimExpressions.esp") as Spell
		if !akActor.hasspell(ExpressionsSpell)
			float randomSpeed= Utility.RandomFloat(0.65, 1.0)
			MfgConsoleFuncExt.ApplyExpressionPresetSmooth(akActor, expression, openMouth, 0, 1, 1, 1, randomSpeed)
		endif
EndFunction

;mfg expression
;Sets an expression to override any other expression other systems may give this actor.
;7 - Mood Neutral
;0 - Dialogue Anger 8 - Mood Anger 15 - Combat Anger
;1 - Dialogue Fear 9 - Mood Fear 16 - Combat Shout
;2 - Dialogue Happy 10 - Mood Happy
;3 - Dialogue Sad 11 - Mood Sad
;4 - Dialogue Surprise 12 - Mood Surprise
;5 - Dialogue Puzzled 13 - Mood Puzzled
;6 - Dialogue Disgusted 14 - Mood Disgusted
;aiCurrentStrength can be used if current expression is the same or we want to start with an offset
Function SmoothSetExpression(Actor act, Int aiMood, Int aiStrength, float aiModifier = 1.0) global

	Spell ExpressionsSpell = Game.GetFormFromFile(0x800, "HentairimExpressions.esp") as Spell
	if !Act.hasspell(ExpressionsSpell)
		aiMood = PapyrusUtil.ClampInt(aiMood, 0, 16)
		MfgConsoleFuncExt.SetExpression(act, aiMood, aiStrength)
	endif
EndFunction

Function resetMFGSmooth(Actor ac) global
	Spell ExpressionsSpell = Game.GetFormFromFile(0x800, "HentairimExpressions.esp") as Spell
	if !Ac.hasspell(ExpressionsSpell)
		MfgConsoleFuncExt.ResetMFG(ac) 
	endif
endfunction
Function resetPhonemesSmooth(Actor ac) global
	Spell ExpressionsSpell = Game.GetFormFromFile(0x800, "HentairimExpressions.esp") as Spell
	if !Ac.hasspell(ExpressionsSpell)
		MfgConsoleFuncExt.resetPhonemes(ac)
	endif
endfunction
Function resetModifiersSmooth(Actor ac) global

	Spell ExpressionsSpell = Game.GetFormFromFile(0x800, "HentairimExpressions.esp") as Spell
	if !Ac.hasspell(ExpressionsSpell)
		MfgConsoleFuncExt.resetModifiers(ac)
	endif
endfunction









