local MyTable = T{

	--  WAR

	[0x0020]	=	    "Mighty Strikes Effect" ,
	[0x0022]	=	    "Brazen Rush Effect"    ,
	[0x0021]	=	    "Berserk Effect"        ,
	[0x0023]	=	    "Defender Effect"       ,
	[0x0024]	=	    "Warcry Effect"         ,
	[0x0025]	=	    "Aggressor Effect"      ,
	[0x0026]	=	    "Retaliation Effect"    ,
	[0x0027]	=	    "Restraint Effect"      ,
	[0x0028]	=	    "Blood Rage Effect"     ,
	[0x0029]	=	    "Double Attack Effect"  ,

	--  MNK

	[0x0040]	=	    "Hundred Fists Effect"   ,
	[0x0042]	=	    "Inner Strength Effect"  ,
	[0x0041]	=	    "Dodge Effect"           ,
	[0x0043]	=	    "Focus Effect"           ,
	[0x0044]	=	    "Chakra Effect"          ,
	[0x0045]	=	    "Counterstance Effect"   ,
	[0x0046]	=	    "Footwork Effect"        ,
	[0x0047]	=	    "Perfect Counter Effect" ,
	[0x0048]	=	    "Impetus Effect"         ,
	[0x0049]	=	    "Kick Attacks Effect"    ,

	--  WHM

	[0x0060]	=	    "Benediction Effect"     ,
	[0x0062]	=	    "Asylum Effect"          ,
	[0x0061]	=	    "Divine Seal Effect"     ,
	[0x0063]	=	    "Whm Magic Acc Bonus"    ,
	[0x0064]	=	    "Afflatus Solace Effect" ,
	[0x0065]	=	    "Afflatus Misery Effect" ,
	[0x0066]	=	    "Divine Caress Duration" ,
	[0x0067]	=	    "Sacrosanctity Effect"   ,
	[0x0068]	=	    "Regen Duration"         ,
	[0x0069]	=	    "Bar Spell Effect"       ,

	--  BLM

	[0x0080]	=	    "Manafont Effect"          ,
	[0x0082]	=	    "Subtle Sorcery Effect"    ,
	[0x0081]	=	    "Elemental Seal Effect"    ,
	[0x0083]	=	    "Magic Burst Dmg Bonus"    ,
	[0x0084]	=	    "Mana Wall Effect"         ,
	[0x0085]	=	    "Blm Magic Acc Bonus"      ,
	[0x0086]	=	    "Emnity Douse Recast"      ,
	[0x0087]	=	    "Manawell Effect"          ,
	[0x0088]	=	    "Magic Burst Emnity Bonus" ,
	[0x0089]	=	    "Magic Dmg Bonus"          ,

	--  RDM

	[0x00a0]	=	    "Chainspell Effect"   ,
	[0x00a2]	=	    "Stymie Effect"       ,
	[0x00a1]	=	    "Convert Effect"      ,
	[0x00a3]	=	    "Rdm Magic Acc Bonus" ,
	[0x00a4]	=	    "Composure Effect"    ,
	[0x00a5]	=	    "Rdm Magic Atk Bonus" ,
	[0x00a6]	=	    "Saboteur Effect"     ,
	[0x00a7]	=	    "Enfeeble Duration"   ,
	[0x00a8]	=	    "Quick Magic Effect"  ,
	[0x00a9]	=	    "Enhancing Duration"  ,

	--  THF

	[0x00c0]	=	    "Perfect Dodge Effect" ,
	[0x00c2]	=	    "Larceny Effect"       ,
	[0x00c1]	=	    "Sneak Attack Effect"  ,
	[0x00c3]	=	    "Trick Attack Effect"  ,
	[0x00c4]	=	    "Steal Recast"         ,
	[0x00c5]	=	    "Mug Effect"           ,
	[0x00c6]	=	    "Despoil Effect"       ,
	[0x00c7]	=	    "Conspirator Effect"   ,
	[0x00c8]	=	    "Bully Effect"         ,
	[0x00c9]	=	    "Triple Attack Effect" ,

	--  PLD

	[0x00e0]	=	    "Invincible Effect"    ,
	[0x00e2]	=	    "Intervene Effect"     ,
	[0x00e1]	=	    "Holy Circle Effect"   ,
	[0x00e3]	=	    "Sentinel Effect"      ,
	[0x00e4]	=	    "Shield Bash Effect"   ,
	[0x00e5]	=	    "Cover Duration"       ,
	[0x00e6]	=	    "Divine Emblem Effect" ,
	[0x00e7]	=	    "Sepulcher Duration"   ,
	[0x00e8]	=	    "Palisade Effect"      ,
	[0x00e9]	=	    "Enlight Effect"       ,

	--  DRK

	[0x0100]	=	    "Blood Weapon Effect"       ,
	[0x0102]	=	    "Soul Enslavement Effect"   ,
	[0x0101]	=	    "Arcane Circle Effect"      ,
	[0x0103]	=	    "Last Resort Effect"        ,
	[0x0104]	=	    "Souleater Duration"        ,
	[0x0105]	=	    "Weapon Bash Effect"        ,
	[0x0106]	=	    "Nether Void Effect"        ,
	[0x0107]	=	    "Arcane Crest Duration"     ,
	[0x0108]	=	    "Scarlet Delirium Duration" ,
	[0x0109]	=	    "Endark Effect"             ,

	--  BST

	[0x0120]	=	    "Familiar Effect"    ,
	[0x0122]	=	    "Unleash Effect"     ,
	[0x0121]	=	    "Pet Acc Bonus"      ,
	[0x0123]	=	    "Charm Success Rate" ,
	[0x0124]	=	    "Reward Effect"      ,
	[0x0125]	=	    "Pet Atk Spd Bonus"  ,
	[0x0126]	=	    "Ready Effect"       ,
	[0x0127]	=	    "Spur Effect"        ,
	[0x0128]	=	    "Run Wild Duration"  ,
	[0x0129]	=	    "Pet Emnity Bonus"   ,

	--  BRD

	[0x0140]	=	    "Soul Voice Effect"   ,
	[0x0142]	=	    "Clarion Call Effect" ,
	[0x0141]	=	    "Minne Effect"        ,
	[0x0143]	=	    "Minuet Effect"       ,
	[0x0144]	=	    "Pianissimo Effect"   ,
	[0x0145]	=	    "Song Acc Bonus"      ,
	[0x0146]	=	    "Tenuto Effect"       ,
	[0x0147]	=	    "Lullaby Duration"    ,
	[0x0148]	=	    "Marcato Effect"      ,
	[0x0149]	=	    "Requiem Effect"      ,

	--  RNG

	[0x0160]	=	    "Eagle Eye Shot Effect" ,
	[0x0162]	=	    "Overkill Effect"       ,
	[0x0161]	=	    "Sharpshot Effect"      ,
	[0x0163]	=	    "Camouflage Effect"     ,
	[0x0164]	=	    "Barrage Effect"        ,
	[0x0165]	=	    "Shadowbind Duration"   ,
	[0x0166]	=	    "Velocity Shot Effect"  ,
	[0x0167]	=	    "Double Shot Effect"    ,
	[0x0168]	=	    "Decoy Shot Effect"     ,
	[0x0169]	=	    "Unlimited Shot Effect" ,

	--  SAM

	[0x0180]	=	    "Meikyo Shisui Effect"  ,
	[0x0182]	=	    "Yaegasumi Effect"      ,
	[0x0181]	=	    "Warding Circle Effect" ,
	[0x0183]	=	    "Hasso Effect"          ,
	[0x0184]	=	    "Meditate Effect"       ,
	[0x0185]	=	    "Seigan Effect"         ,
	[0x0186]	=	    "Konzen Ittai Effect"   ,
	[0x0187]	=	    "Hamanoha Duration"     ,
	[0x0188]	=	    "Hagakure Effect"       ,
	[0x0189]	=	    "Zanshin Effect"        ,

	--  NIN

	[0x01a0]	=	    "Mijin Gaukure Effect"     ,
	[0x01a2]	=	    "Mikage Effect"            ,
	[0x01a1]	=	    "Yonin Effect"             ,
	[0x01a3]	=	    "Innin Effect"             ,
	[0x01a4]	=	    "Ninjitsu Acc Bonus"       ,
	[0x01a5]	=	    "Ninjitsu Cast Time Bonus" ,
	[0x01a6]	=	    "Futae Effect"             ,
	[0x01a7]	=	    "Elem Ninjitsu Effect"     ,
	[0x01a8]	=	    "Issekigan Effect"         ,
	[0x01a9]	=	    "Tactical Parry Effect"    ,

	--  DRG

	[0x01c0]	=	    "Spirit Surge Effect"     ,
	[0x01c2]	=	    "Fly High Effect"         ,
	[0x01c1]	=	    "Ancient Circle Effect"   ,
	[0x01c3]	=	    "Jump Effect"             ,
	[0x01c4]	=	    "Spirit Link Effect"      ,
	[0x01c5]	=	    "Wyvern Max Hp Bonus"     ,
	[0x01c6]	=	    "Dragon Breaker Duration" ,
	[0x01c7]	=	    "Wyvern Breath Effect"    ,
	[0x01c8]	=	    "High Jump Effect"        ,
	[0x01c9]	=	    "Wyvern Attr Bonus"       ,

	--  SMN

	[0x01e0]	=	    "Astral Flow Effect"      ,
	[0x01e2]	=	    "Astral Conduit Effect"   ,
	[0x01e1]	=	    "Summon Acc Bonus"        ,
	[0x01e3]	=	    "Summon Magic Acc Bonus"  ,
	[0x01e4]	=	    "Elemental Siphon Effect" ,
	[0x01e5]	=	    "Summon Phys Atk Bonus"   ,
	[0x01e6]	=	    "Mana Cede Effect"        ,
	[0x01e7]	=	    "Avatars Favor Effect"    ,
	[0x01e8]	=	    "Summon Magic Dmg Bonus"  ,
	[0x01e9]	=	    "Blood Pact Dmg Bonus"    ,

	--  BLU

	[0x0200]	=	    "Azure Lore Effect"       ,
	[0x0202]	=	    "Unbridled Wisdom Effect" ,
	[0x0201]	=	    "Blue Magic Point Bonus"  ,
	[0x0203]	=	    "Burst Affinity Bonus"    ,
	[0x0204]	=	    "Chain Affinity Effect"   ,
	[0x0205]	=	    "Blue Phys Ae Acc Bonus"  ,
	[0x0206]	=	    "Unbridled Lrn Effect"    ,
	[0x0207]	=	    "Unbridled Lrn Effect II" ,
	[0x0208]	=	    "Efflux Effect"           ,
	[0x0209]	=	    "Blu Magic Acc Bonus"     ,

	--  COR

	[0x0220]	=	    "Wild Card Effect"      ,
	[0x0222]	=	    "Cutting Cards Effect"  ,
	[0x0221]	=	    "Phantom Roll Duration" ,
	[0x0223]	=	    "Bust Evasion"          ,
	[0x0224]	=	    "Quick Draw Effect"     ,
	[0x0225]	=	    "Ammo Consumption"      ,
	[0x0226]	=	    "Random Deal Effect"    ,
	[0x0227]	=	    "Cor Ranged Acc Bonus"  ,
	[0x0228]	=	    "Triple Shot Effect"    ,
	[0x0229]	=	    "Optimal Range Bonus"   ,

	--  PUP

	[0x0240]	=	    "Overdrive Effect"        ,
	[0x0242]	=	    "Heady Artifice Effect"   ,
	[0x0241]	=	    "Automaton Hp Mp Bonus"   ,
	[0x0243]	=	    "Activate Effect"         ,
	[0x0244]	=	    "Repair Effect"           ,
	[0x0245]	=	    "Deus Ex Automata Recast" ,
	[0x0246]	=	    "Tactical Switch Bonus"   ,
	[0x0247]	=	    "Cooldown Effect"         ,
	[0x0248]	=	    "Deactivate Effect"       ,
	[0x0249]	=	    "Pup Martial Arts Effect" ,

	--  DNC

	[0x0260]	=	    "Trance Effect"       ,
	[0x0262]	=	    "Grand Pas Effect"    ,
	[0x0261]	=	    "Step Duration"       ,
	[0x0263]	=	    "Samba Duration"      ,
	[0x0264]	=	    "Waltz Potency Bonus" ,
	[0x0265]	=	    "Jig Duration"        ,
	[0x0266]	=	    "Flourish I Effect"   ,
	[0x0267]	=	    "Flourish II Effect"  ,
	[0x0268]	=	    "Flourish III Effect" ,
	[0x0269]	=	    "Contradance Effect"  ,

	--  SCH

	[0x0280]	=	    "Tabula Rasa Effect"       ,
	[0x0282]	=	    "Caper Emmissarius Effect" ,
	[0x0281]	=	    "Light Arts Effect"        ,
	[0x0283]	=	    "Dark Arts Effect"         ,
	[0x0284]	=	    "Strategem Effect I"       ,
	[0x0285]	=	    "Strategem Effect II"      ,
	[0x0286]	=	    "Strategem Effect III"     ,
	[0x0287]	=	    "Strategem Effect IV"      ,
	[0x0288]	=	    "Modus Veritas Effect"     ,
	[0x0289]	=	    "Sublimation Effect"       ,

	--  GEO

	[0x02a0]	=	    "Bolster Effect"          ,
	[0x02a2]	=	    "Widened Compass Effect"  ,
	[0x02a1]	=	    "Life Cycle Effect"       ,
	[0x02a3]	=	    "Blaze Of Glory Effect"   ,
	[0x02a4]	=	    "Geo Magic Atk Bonus"     ,
	[0x02a5]	=	    "Geo Magic Acc Bonus"     ,
	[0x02a6]	=	    "Dematerialize Duration"  ,
	[0x02a7]	=	    "Theurgic Focus Effect"   ,
	[0x02a8]	=	    "Concentric Pulse Effect" ,
	[0x02a9]	=	    "Indi Spell Duration"     ,

	--  RUN

	[0x02c0]	=	    "Elemental Sforzo Effect" ,
	[0x02c2]	=	    "Odyllic Subter Effect"   ,
	[0x02c1]	=	    "Rune Enchantment Effect" ,
	[0x02c3]	=	    "Vallation Duration"      ,
	[0x02c4]	=	    "Swordplay Effect"        ,
	[0x02c5]	=	    "Swipe Effect"            ,
	[0x02c6]	=	    "Embolden Effect"         ,
	[0x02c7]	=	    "Vivacious Pulse Effect"  ,
	[0x02c8]	=	    "One For All Duration"    ,
	[0x02c9]	=	    "Gambit Duration"         ,

	}
	
return MyTable
