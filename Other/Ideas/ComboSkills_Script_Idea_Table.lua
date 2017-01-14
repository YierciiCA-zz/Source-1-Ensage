														ComboSkills Script Idea Table
HeroInitiator[Spellname]		➜		MyHeroWhoMakesCombo[Spellname]				➜		Special Description	
————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
Faceless Void[Chronosphere]		➜		Witch Doctor[Death Ward]					➜		WardAim: Lowest HP. Optional: item[Blink], Glimmer Cape.
																							Minimum freezed enemies to combo: 2
Faceless Void[Chronosphere]		➜		Skywrath[Mystic Flare]						➜		Target: Highest HP.
																							AghanimTarget[UltiLevel_3]: Every highest HP (cast by descending).
Faceless Void[Chronosphere]		➜		Disruptor[Kinetic Field+Static Storm]		➜		Cast time = Chronosphere[duration] - Kinetic Field[Effect Delay].
																							Minimum freezed enemies to combo: 3
Faceless Void[Chronosphere]		➜		Invoker[Sunstrike/Chaos Meteor]				➜		For spell[Sunstrike]:
																							Target: Lowest HP (stealer mode) or Highest HP (support mode).
Faceless Void[Chronosphere]		➜		Lich[Chain Frost]							➜		Minimum freezed enemies to combo: 3
																							Optional: item[Blink].
Faceless Void[Chronosphere]		➜		Warlock[Fatal Bonds/Chaotic Offering]		➜		Minimum freezed enemies fоr combo with spell[Chaotic Offering]:
																																					3 else 2
																							cast spell[Chaotic Offering] after pass Chronosphere
Faceless Void[Chronosphere]		➜		Jakiro[Macropyre]							➜		Minimum freezed enemies to combo: 3
Faceless Void[Chronosphere]		➜		Ancient Apparition[Ice Blast]				➜		Minimum freezed enemies to combo: 3
																							Optional: spell[Cold Feet], spell[Ice Vortex]
Faceless Void[Chronosphere]		➜		Queen of Pain[Sonic Wave]					➜		Minimum freezed enemies to combo: 2
Faceless Void[Chronosphere]		➜		Troll Warlord[Battle Trance]				➜		Minimum freezed enemies to combo: 1
————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
Dark Seer[Vacuum]				➜		Dark Seer[Wall of Replica]					➜		Optional.
Dark Seer[Vacuum]				➜		Faceless Void[Time Walk+Chronosphere]		➜		Minimum vacuumed enemies to combo: 2
Dark Seer[Vacuum]				➜		Enigma[Black Hole]							➜		Minimum vacuumed enemies to combo: 3
																							Optional: item[Blink]. 
Dark Seer[Vacuum]				➜		Witch Doctor[Death Ward]					➜		WardAim: Lowest HP. Aghanim check.
																							Optional: item[Blink], item[Glimmer Cape].
Dark Seer[Vacuum]				➜		Eathshaker[Echo Slam]						➜		Minimum enemy entities to combo: 5, of them minimum 2 heroes
																							valid entities type: TYPE_HERO and TYPE_CREEP
																											 and TYPE_NPC  and TARGET_TEAM_ENEMY
																							Optional: item[Blink], item[Veil of Discord]
————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
Clockwerk[Power Cogs]			➜		Skywrath[Mystic Flare]						➜		If targets has item[Blade Mail] thеn dо it safe.
Clockwerk[Power Cogs]			➜		Invoker[Sunstrike/Chaos Meteor]				➜		Empty.
Clockwerk[Power Cogs]			➜		Pugna[Life Drain]							➜		Optional: spell[Decrepify], spell[Nether Blast].
Clockwerk[Power Cogs]			➜		Dark Seer[Vacuum]							➜		Optional: spell[Wall of Replica].
Clockwerk[Power Cogs]			➜		Ancient Apparition[Cold Feet]				➜		Optional: spell[Ice Vortex], spell[Chilling Touch,Clockwerk].
————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
Mirana[Sacred Arrow]			➜		Skywrath[Mystic Flare]						➜		Target: victim.position
Mirana[Sacred Arrow]			➜		Pugna[Life Drain]							➜		Optional: spell[Decrepify], spell[Nether Blast].
Mirana[Sacred Arrow]			➜		Invoker[Sunstrike]							➜		Target: victim.position
Mirana[Sacred Arrow]			➜		Ancient Apparition[Cold Feet+Ice Vortex]	➜		Cast time = Arrow Stun[duration] - Cold Feet[Freezing Duration].
————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
Pudge[Success Hook]				➜		Omniknight[Purification]					➜		Do it іf Distance(Pudge,victim) <= 260
																							Optional: item[Blink].
Pudge[Dismember]				➜		Mirana[Sacred Arrow]						➜		Empty.
Pudge[Dismember]				➜		Skywrath[Mystic Flare]						➜		Empty.
Pudge[Dismember]				➜		Invoker[Sunstrike]							➜		Target: victim.position.
Pudge[Dismember]				➜		Pugna[Life Drain]							➜		Optional: spell[Decrepify], spell[Nether Blast].
Pudge[Success Hook/Dismember]	➜		Dark Seer[Ion Shell]						➜		Target: Pudge.
————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
Tiny[Toss(me)]					➜		Centaur Warrunner[Hoof Stomp]				➜		Do it іf Distance(me,victim) < 315, optional: spell[Double Edge]
Tiny[Toss(ally.TYPE_HERO)]		➜		Dark Seer[Ion Shell]						➜		Target: Tossed ally hero.
Tiny[Toss(me)]					➜		Eathshaker[Echo Slam]						➜		Minimum enemy entities to combo: 5, of them minimum 2 heroes
																							valid entities type: TYPE_HERO and TYPE_CREEP
																											 and TYPE_NPC  and TARGET_TEAM_ENEMY
																							Optional: item[Veil of Discord]
Tiny[Toss(me)]					➜		Techies[Land Mines+Suicide]					➜		Empty.
Tiny[Toss(me)]					➜		Troll Warlord[Whirling Axes(Melee)]			➜		Optional: spell[Battle Trance].
Tiny[Toss(me)]					➜		Axe[Berserker's Call]						➜		Optional: item[Blade Mail].
Tiny[Toss(me)]					➜		Juggernaut[Blade Fury or Omnislash]			➜		іf #creeps іn search range < 3 thеn cast spell[Omnislash]
																														   elsе cast spell[Blade Fury]
Tiny[Toss(me)]					➜		Slardar[Slithereen Crush]					➜		Optional: spell[Amplify Damage].
————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
Tidehunter[Ravage]				➜		Lich[Chain Frost]							➜		Optional: item[Blink].
																							Minimum stunned enemies to combo: 3
Tidehunter[Ravage]				➜		Venomancer[Poison Nova]						➜		Optional: item[Blink].
																							Minimum stunned enemies to combo: 3
Tidehunter[Ravage]				➜		Shadow Fiend[Requiem of Souls]				➜		Optional: item[Blink].
																							Minimum stunned enemies to combo: 3
Tidehunter[Ravage]				➜		Enigma[Black Hole]							➜		Optional: item[Blink].
																							Minimum stunned enemies to combo: 3
																							
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
																Other actions
TeamAction[attributes]			➜		MyHeroWhoMakesCombo[Spellname]				➜		Special Description	
————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
Stun[victim]					➜		Invoker[Sunstrike]							➜		If stun GetDuration>spellDelay[sunstrike] thеn cast spell[sunstrike]
Stun[victim]					➜		Pugna[Life Drain]							➜		If stun GetDuration>timeToDie(victim,LD) thеn cast spell[Life Drain]
																							functiоn timeToDie(vic,spell) returns time fоr which victim take
																							enough Life Drain[dmgPerSecond] to die.
Stun[victim]					➜		Skywrath[Mystic Flare]						➜		If stun GetDuration>timeToDie(victim,LD) thеn cast spell[Mystic Flare]
																							functiоn timeToDie(vic,spell) See line 42 to get more info.
Stun/Can'tMove[victim]			➜		Mirana[Sacred Arrow]						➜		If stun GetDuration>flightTime[Sacred Arrow] and IsCleanDirection thеn
																							cast spell[Sacred Arrow].

																							