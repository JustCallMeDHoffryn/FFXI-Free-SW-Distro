--	---------------------------------------------------------------------------
--	This file contains the data decoding functions
--	---------------------------------------------------------------------------

require('common')

local chat	= require('chat')
local imgui	= require('imgui')
local ETC	= require('ETC')

local Decode = {

	RuleStack	=	{},

	Actions	=	T{		[0x00] = "Trigger",
						[0x02] = "Attack",
						[0x03] = "Spellcast",
						[0x04] = "Disengage",
						[0x05] = "Call for Help",
						[0x07] = "Weaponskill",
						[0x09] = "Job Ability",
						[0x0B] = "Homepoint",
						[0x0C] = "Assist",
						[0x0D] = "Raise",
						[0x0E] = "Fishing",
						[0x0F] = "Change Target",
						[0x10] = "Ranged Attack",
						[0x11] = "Chocobo Digging",
						[0x12] = "Dismount",
						[0x13] = "Tractor Menu",
						[0x14] = "Complete Character Update",
						[0x15] = "Ballista - Quarry",
						[0x16] = "Ballista - Sprint",
						[0x17] = "Ballista - Scout",
						[0x18] = "Blockaid",
						[0x19] = "Monstrosity Monster Skill",
						[0x1A] = "Mounts",
				},

	Storage	  = T{

					[0]  =	 'Inventory',
					[1]  =   'Mog Safe',
					[2]  =   'Storage',
					[3]  =   'Temp Items',
					[4]  =   'Mog Locker',
					[5]  =   'Mog Satchel',
					[6]  =   'Mog Sack',
					[7]  =   'Mog Case',
					[8]  =   'Wardrobe 1',
					[9]  =   'Mogsafe 2',
					[10] =   'Wardrobe 2',
					[11] =   'Wardrobe 3',
					[12] =   'Wardrobe 4',
					[13] =   'Wardrobe 5',
					[14] =   'Wardrobe 6',
					[15] =   'Wardrobe 7',
					[16] =   'Wardrobe 8',
					[17] =   'Recycle Bin',
				
				},

	Jobs	  = T{	'WAR', 'MNK', 'WHM', 'BLM', 'RDM', 'THF', 'PLD', 'DRK', 'BST', 'BRD', 'RNG', 
					'SAM', 'NIN', 'DRG', 'SMN', 'BLU', 'COR', 'PUP', 'DNC', 'SCH', 'GEO', 'RUN',	
				},


	JobPointsEffects = T{

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
					
					},				

	Tables	=	{

		[1]	=	T{	[0] = 'None',
					[1] = 'Attack',
					[2] = 'Ranged Finish',
					[3] = 'Weapon Skill Finish',
					[4] = 'Magic Finish',
					[5] = 'Item Finish',
					[6] = 'Job Ability Finish',
					[7] = 'Weapon Skill Start',
					[8] = 'Magic Start',
					[9] = 'Item Start',
					[10] = 'Job Ability Start',
					[11] = 'Mob Ability Finish',
					[12] = 'Ranged Start',
					[13] = 'Pet Mob Ability Finish',
					[14] = 'Dance',
					[15] = 'Run Ward Effusion',
					[21] = 'Quarry',
					[22] = 'Sprint',
				},

		[2]	=	T{	[16]	=	'Mighty Strikes',
					[17]	=	'Hundred Fists',
					[18]	=	'Benediction',
					[19]	=	'Manafont',
					[20]	=	'Chainspell',
					[21]	=	'Perfect Dodge',
					[22]	=	'Invincible',
					[23]	=	'Blood Weapon',
					[24]	=	'Familiar',
					[25]	=	'Soul Voice',
					[26]	=	'Eagle Eye Shot',
					[27]	=	'Meikyo Shisui',
					[28]	=	'Mijin Gakure',
					[29]	=	'Spirit Surge',
					[30]	=	'Astral Flow',
					[31]	=	'Berserk',
					[32]	=	'Warcry',
					[33]	=	'Defender',
					[34]	=	'Aggressor',
					[35]	=	'Provoke',
					[36]	=	'Focus',
					[37]	=	'Dodge',
					[38]	=	'Chakra',
					[39]	=	'Boost',
					[40]	=	'Counterstance',
					[41]	=	'Steal',
					[42]	=	'Flee',
					[43]	=	'Hide',
					[44]	=	'Sneak Attack',
					[45]	=	'Mug',
					[46]	=	'Shield Bash',
					[47]	=	'Holy Circle',
					[48]	=	'Sentinel',
					[49]	=	'Souleater',
					[50]	=	'Arcane Circle',
					[51]	=	'Last Resort',
					[52]	=	'Charm',
					[53]	=	'Gauge',
					[54]	=	'Tame',
					[55]	=	'Pet Commands',
					[56]	=	'Scavenge',
					[57]	=	'Shadowbind',
					[58]	=	'Camouflage',
					[59]	=	'Sharpshot',
					[60]	=	'Barrage',
					[61]	=	'Call Wyvern',
					[62]	=	'Third Eye',
					[63]	=	'Meditate',
					[64]	=	'Warding Circle',
					[65]	=	'Ancient Circle',
					[66]	=	'Jump',
					[67]	=	'High Jump',
					[68]	=	'Super Jump',
					[69]	=	'Fight',
					[70]	=	'Heel',
					[71]	=	'Leave',
					[72]	=	'Sic',
					[73]	=	'Stay',
					[74]	=	'Divine Seal',
					[75]	=	'Elemental Seal',
					[76]	=	'Trick Attack',
					[77]	=	'Weapon Bash',
					[78]	=	'Reward',
					[79]	=	'Cover',
					[80]	=	'Spirit Link',
					[81]	=	'Enrage',
					[82]	=	'Chi Blast',
					[83]	=	'Convert',
					[84]	=	'Accomplice',
					[85]	=	'Call Beast',
					[86]	=	'Unlimited Shot',
					[87]	=	'Dismiss',
					[88]	=	'Assault',
					[89]	=	'Retreat',
					[90]	=	'Release',
					[91]	=	'Blood Pact Rage',
					[92]	=	'Rampart',
					[93]	=	'Azure Lore',
					[94]	=	'Chain Affinity',
					[95]	=	'Burst Affinity',
					[96]	=	'Wild Card',
					[97]	=	'Phantom Roll',
					[98]	=	'Fighters Roll',
					[99]	=	'Monks Roll',
					[100]	=	'Healers Roll',
					[101]	=	'Wizards Roll',
					[102]	=	'Warlocks Roll',
					[103]	=	'Rogues Roll',
					[104]	=	'Gallants Roll',
					[105]	=	'Chaos Roll',
					[106]	=	'Beast Roll',
					[107]	=	'Choral Roll',
					[108]	=	'Hunters Roll',
					[109]	=	'Samurai Roll',
					[110]	=	'Ninja Roll',
					[111]	=	'Drachen Roll',
					[112]	=	'Evokers Roll',
					[113]	=	'Maguss Roll',
					[114]	=	'Corsairs Roll',
					[115]	=	'Puppet Roll',
					[116]	=	'Dancers Roll',
					[117]	=	'Scholars Roll',
					[118]	=	'Bolters Roll',
					[119]	=	'Casters Roll',
					[120]	=	'Coursers Roll',
					[121]	=	'Blitzers Roll',
					[122]	=	'Tacticians Roll',
					[123]	=	'Double Up',
					[124]	=	'Quick Draw',
					[125]	=	'Fire Shot',
					[126]	=	'Ice Shot',
					[127]	=	'Wind Shot',
					[128]	=	'Earth Shot',
					[129]	=	'Thunder Shot',
					[130]	=	'Water Shot',
					[131]	=	'Light Shot',
					[132]	=	'Dark Shot',
					[133]	=	'Random Deal',
					[135]	=	'Overdrive',
					[136]	=	'Activate',
					[137]	=	'Repair',
					[138]	=	'Deploy',
					[139]	=	'Deactivate',
					[140]	=	'Retrieve',
					[141]	=	'Fire Maneuver',
					[142]	=	'Ice Maneuver',
					[143]	=	'Wind Maneuver',
					[144]	=	'Earth Maneuver',
					[145]	=	'Thunder Maneuver',
					[146]	=	'Water Maneuver',
					[147]	=	'Light Maneuver',
					[148]	=	'Dark Maneuver',
					[149]	=	'Warriors Charge',
					[150]	=	'Tomahawk',
					[151]	=	'Mantra',
					[152]	=	'Formless Strikes',
					[153]	=	'Martyr',
					[154]	=	'Devotion',
					[155]	=	'Assassins Charge',
					[156]	=	'Feint',
					[157]	=	'Fealty',
					[158]	=	'Chivalry',
					[159]	=	'Dark Seal',
					[160]	=	'Diabolic Eye',
					[161]	=	'Feral Howl',
					[162]	=	'Killer Instinct',
					[163]	=	'Nightingale',
					[164]	=	'Troubadour',
					[165]	=	'Stealth Shot',
					[166]	=	'Flashy Shot',
					[167]	=	'Shikikoyo',
					[168]	=	'Blade Bash',
					[169]	=	'Deep Breathing',
					[170]	=	'Angon',
					[171]	=	'Sange',
					[172]	=	'Blood Pact Ward',
					[173]	=	'Hasso',
					[174]	=	'Seigan',
					[175]	=	'Convergence',
					[176]	=	'Diffusion',
					[177]	=	'Snake Eye',
					[178]	=	'Fold',
					[179]	=	'Role Reversal',
					[180]	=	'Ventriloquy',
					[181]	=	'Trance',
					[182]	=	'Sambas',
					[183]	=	'Waltzes',
					[184]	=	'Drain Samba',
					[185]	=	'Drain Samba II',
					[186]	=	'Drain Samba III',
					[187]	=	'Aspir Samba',
					[188]	=	'Aspir Samba II',
					[189]	=	'Haste Samba',
					[190]	=	'Curing Waltz',
					[191]	=	'Curing Waltz II',
					[192]	=	'Curing Waltz III',
					[193]	=	'Curing Waltz IV',
					[194]	=	'Healing Waltz',
					[195]	=	'Divine Waltz',
					[196]	=	'Spectral Jig',
					[197]	=	'Chocobo Jig',
					[198]	=	'Jigs',
					[199]	=	'Steps',
					[200]	=	'Flourishes I',
					[201]	=	'Quickstep',
					[202]	=	'Box Step',
					[203]	=	'Stutter Step',
					[204]	=	'Animated Flourish',
					[205]	=	'Desperate Flourish',
					[206]	=	'Reverse Flourish',
					[207]	=	'Violent Flourish',
					[208]	=	'Building Flourish',
					[209]	=	'Wild Flourish',
					[210]	=	'Tabula Rasa',
					[211]	=	'Light Arts',
					[212]	=	'Dark Arts',
					[213]	=	'Flourishes II',
					[214]	=	'Modus Veritas',
					[215]	=	'Penury',
					[216]	=	'Celerity',
					[217]	=	'Rapture',
					[218]	=	'Accession',
					[219]	=	'Parsimony',
					[220]	=	'Alacrity',
					[221]	=	'Ebullience',
					[222]	=	'Manifestation',
					[223]	=	'Stratagems',
					[224]	=	'Velocity Shot',
					[225]	=	'Snarl',
					[226]	=	'Retaliation',
					[227]	=	'Footwork',
					[228]	=	'Despoil',
					[229]	=	'Pianissimo',
					[230]	=	'Sekkanoki',
					[232]	=	'Elemental Siphon',
					[233]	=	'Sublimation',
					[234]	=	'Addendum White',
					[235]	=	'Addendum Black',
					[236]	=	'Collaborator',
					[237]	=	'Saber Dance',
					[238]	=	'Fan Dance',
					[239]	=	'No Foot Rise',
					[240]	=	'Altruism',
					[241]	=	'Focalization',
					[242]	=	'Tranquility',
					[243]	=	'Equanimity',
					[244]	=	'Enlightenment',
					[245]	=	'Afflatus Solace',
					[246]	=	'Afflatus Misery',
					[247]	=	'Composure',
					[248]	=	'Yonin',
					[249]	=	'Innin',
					[250]	=	'Avatars Favor',
					[251]	=	'Ready',
					[252]	=	'Restraint',
					[253]	=	'Perfect Counter',
					[254]	=	'Mana Wall',
					[255]	=	'Divine Emblem',
					[256]	=	'Nether Void',
					[257]	=	'Double Shot',
					[258]	=	'Sengikori',
					[259]	=	'Futae',
					[260]	=	'Spirit Jump',
					[261]	=	'Presto',
					[262]	=	'Divine Waltz II',
					[263]	=	'Flourishes III',
					[264]	=	'Climactic Flourish',
					[265]	=	'Libra',
					[266]	=	'Tactical Switch',
					[267]	=	'Blood Rage',
					[269]	=	'Impetus',
					[270]	=	'Divine Caress',
					[271]	=	'Sacrosanctity',
					[272]	=	'Enmity Douse',
					[273]	=	'Manawell',
					[274]	=	'Saboteur',
					[275]	=	'Spontaneity',
					[276]	=	'Conspirator',
					[277]	=	'Sepulcher',
					[278]	=	'Palisade',
					[279]	=	'Arcane Crest',
					[280]	=	'Scarlet Delirium',
					[281]	=	'Spur',
					[282]	=	'Run Wild',
					[283]	=	'Tenuto',
					[284]	=	'Marcato',
					[285]	=	'Bounty Shot',
					[286]	=	'Decoy Shot',
					[287]	=	'Hamanoha',
					[288]	=	'Hagakure',
					[291]	=	'Issekigan',
					[292]	=	'Dragon Breaker',
					[293]	=	'Soul Jump',
					[295]	=	'Steady Wing',
					[296]	=	'Mana Cede',
					[297]	=	'Efflux',
					[298]	=	'Unbridled Learning',
					[301]	=	'Triple Shot',
					[302]	=	'Allies Roll',
					[303]	=	'Misers Roll',
					[304]	=	'Companions Roll',
					[305]	=	'Avengers Roll',
					[309]	=	'Cooldown',
					[310]	=	'Deux Ex Automata',
					[311]	=	'Curing Waltz V',
					[312]	=	'Feather Step',
					[313]	=	'Striking Flourish',
					[314]	=	'Ternary Flourish',
					[316]	=	'Perpetuance',
					[317]	=	'Immanence',
					[318]	=	'Smiting Breath',
					[319]	=	'Restoring Breath',
					[320]	=	'Konzen Ittai',
					[321]	=	'Bully',
					[322]	=	'Maintenance',
					[323]	=	'Brazen Rush',
					[324]	=	'Inner Strength',
					[325]	=	'Asylum',
					[326]	=	'Subtle Sorcery',
					[327]	=	'Stymie',
					[328]	=	'Larceny',
					[329]	=	'Intervene',
					[330]	=	'Soul Enslavement',
					[331]	=	'Unleash',
					[332]	=	'Clarion Call',
					[333]	=	'Overkill',
					[334]	=	'Yaegasumi',
					[335]	=	'Mikage',
					[336]	=	'Fly High',
					[337]	=	'Astral Conduit',
					[338]	=	'Unbridled Wisdom',
					[339]	=	'Cutting Cards',
					[340]	=	'Heady Artifice',
					[341]	=	'Grand Pas',
					[342]	=	'Caper Emissarius',
					[343]	=	'Bolster',
					[344]	=	'Swipe',
					[345]	=	'Full Circle',
					[346]	=	'Lasting Emanation',
					[347]	=	'Ecliptic Attrition',
					[348]	=	'Collimated Fervor',
					[349]	=	'Life Cycle',
					[350]	=	'Blaze Of Glory',
					[351]	=	'Dematerialize',
					[352]	=	'Theurgic Focus',
					[353]	=	'Concentric Pulse',
					[354]	=	'Mending Halation',
					[355]	=	'Radial Arcana',
					[356]	=	'Elemental Sforzo',
					[357]	=	'Rune Enchantment',
					[358]	=	'Ignis',
					[359]	=	'Gelus',
					[360]	=	'Flabra',
					[361]	=	'Tellus',
					[362]	=	'Sulpor',
					[363]	=	'Unda',
					[364]	=	'Lux',
					[365]	=	'Tenebrae',
					[366]	=	'Vallation',
					[367]	=	'Swordplay',
					[368]	=	'Lunge',
					[369]	=	'Pflug',
					[370]	=	'Embolden',
					[371]	=	'Valiance',
					[372]	=	'Gambit',
					[373]	=	'Liement',
					[374]	=	'One For All',
					[375]	=	'Rayke',
					[376]	=	'Battuta',
					[377]	=	'Widened Compass',
					[378]	=	'Odyllic Subterfuge',
					[379]	=	'Ward',
					[380]	=	'Effusion',
					[381]	=	'Chocobo Jig II',
					[382]	=	'Relinquish',
					[383]	=	'Vivacious Pulse',
					[384]	=	'Contradance',
					[385]	=	'Apogee',
					[386]	=	'Entrust',
					[387]	=	'Bestial Loyalty',
					[388]	=	'Cascade',
					[389]	=	'Consume Mana',
					[390]	=	'Naturalists Roll',
					[391]	=	'Runeists Roll',
					[392]	=	'Crooked Cards',
					[393]	=	'Spirit Bond',
					[394]	=	'Majesty',
					[512]	=	'Healing Ruby',
					[513]	=	'Poison Nails',
					[514]	=	'Shining Ruby',
					[515]	=	'Glittering Ruby',
					[516]	=	'Meteorite',
					[517]	=	'Healing Ruby II',
					[518]	=	'Searing Light',
					[519]	=	'Holy Mist',
					[520]	=	'Soothing Ruby',
					[521]	=	'Regal Scratch',
					[522]	=	'Mewing Lullaby',
					[523]	=	'Earie Eye',
					[524]	=	'Level Qm Holy',
					[525]	=	'Raise II',
					[526]	=	'Reraise II',
					[527]	=	'Altanas Favor',
					[528]	=	'Moonlit Charge',
					[529]	=	'Crescent Fang',
					[530]	=	'Lunar Cry',
					[531]	=	'Lunar Roar',
					[532]	=	'Ecliptic Growl',
					[533]	=	'Ecliptic Howl',
					[534]	=	'Eclipse Bite',
					[536]	=	'Howling Moon',
					[537]	=	'Lunar Bay',
					[538]	=	'Heavenward Howl',
					[539]	=	'Impact',
					[544]	=	'Punch',
					[545]	=	'Fire II',
					[546]	=	'Burning Strike',
					[547]	=	'Double Punch',
					[548]	=	'Crimson Howl',
					[549]	=	'Fire IV',
					[550]	=	'Flaming Crush',
					[551]	=	'Meteor Strike',
					[552]	=	'Inferno',
					[553]	=	'Inferno Howl',
					[554]	=	'Conflag Strike',
					[560]	=	'Rock Throw',
					[561]	=	'Stone II',
					[562]	=	'Rock Buster',
					[563]	=	'Megalith Throw',
					[564]	=	'Earthen Ward',
					[565]	=	'Stone IV',
					[566]	=	'Mountain Buster',
					[567]	=	'Geocrush',
					[568]	=	'Earthen Fury',
					[569]	=	'Earthen Armor',
					[570]	=	'Crag Throw',
					[576]	=	'Barracuda Dive',
					[577]	=	'Water II',
					[578]	=	'Tail Whip',
					[579]	=	'Spring Water',
					[580]	=	'Slowga',
					[581]	=	'Water IV',
					[582]	=	'Spinning Dive',
					[583]	=	'Grand Fall',
					[584]	=	'Tidal Wave',
					[585]	=	'Tidal Roar',
					[586]	=	'Soothing Current',
					[592]	=	'Claw',
					[593]	=	'Aero II',
					[594]	=	'Whispering Wind',
					[595]	=	'Hastega',
					[596]	=	'Aerial Armor',
					[597]	=	'Aero IV',
					[598]	=	'Predator Claws',
					[599]	=	'Wind Blade',
					[600]	=	'Aerial Blast',
					[601]	=	'Fleet Wind',
					[602]	=	'Hastega II',
					[608]	=	'Axe Kick',
					[609]	=	'Blizzard II',
					[610]	=	'Frost Armor',
					[611]	=	'Sleepga',
					[612]	=	'Double Slap',
					[613]	=	'Blizzard IV',
					[614]	=	'Rush',
					[615]	=	'Heavenly Strike',
					[616]	=	'Diamond Dust',
					[617]	=	'Diamond Storm',
					[618]	=	'Crystal Blessing',
					[624]	=	'Shock Strike',
					[625]	=	'Thunder II',
					[626]	=	'Rolling Thunder',
					[627]	=	'Thunderspark',
					[628]	=	'Lightning Armor',
					[629]	=	'Thunder IV',
					[630]	=	'Chaotic Strike',
					[631]	=	'Thunderstorm',
					[632]	=	'Judgment Bolt',
					[633]	=	'Shock Squall',
					[634]	=	'Volt Strike',
					[639]	=	'Healing Breath IV',
					[640]	=	'Healing Breath',
					[641]	=	'Healing Breath II',
					[642]	=	'Healing Breath III',
					[643]	=	'Remove Poison',
					[644]	=	'Remove Blindness',
					[645]	=	'Remove Paralysis',
					[646]	=	'Flame Breath',
					[647]	=	'Frost Breath',
					[648]	=	'Gust Breath',
					[649]	=	'Sand Breath',
					[650]	=	'Lightning Breath',
					[651]	=	'Hydro Breath',
					[652]	=	'Super Climb',
					[653]	=	'Remove Curse',
					[654]	=	'Remove Disease',
					[656]	=	'Camisado',
					[657]	=	'Somnolence',
					[658]	=	'Nightmare',
					[659]	=	'Ultimate Terror',
					[660]	=	'Noctoshield',
					[661]	=	'Dream Shroud',
					[662]	=	'Nether Blast',
					[663]	=	'Cacodemonia',
					[664]	=	'Ruinous Omen',
					[665]	=	'Night Terror',
					[666]	=	'Pavor Nocturnus',
					[667]	=	'Blindside',
					[668]	=	'Deconstruction',
					[669]	=	'Chronoshift',
					[670]	=	'Zantetsuken',
					[671]	=	'Perfect Defense',
					[672]	=	'Foot Kick',
					[673]	=	'Dust Cloud',
					[674]	=	'Whirl Claws',
					[675]	=	'Head Butt',
					[676]	=	'Dream Flower',
					[677]	=	'Wild Oats',
					[678]	=	'Leaf Dagger',
					[679]	=	'Scream',
					[680]	=	'Roar',
					[681]	=	'Razor Fang',
					[682]	=	'Claw Cyclone',
					[683]	=	'Tail Blow',
					[684]	=	'Fireball',
					[685]	=	'Blockhead',
					[686]	=	'Braincrush',
					[687]	=	'Infrasonics',
					[688]	=	'Secretion',
					[689]	=	'Lamb Chop',
					[690]	=	'Rage',
					[691]	=	'Sheep Charge',
					[692]	=	'Sheep Song',
					[693]	=	'Bubble Shower',
					[694]	=	'Bubble Curtain',
					[695]	=	'Big Scissors',
					[696]	=	'Scissor Gaurd',
					[697]	=	'Metallic Body',
					[698]	=	'Needleshot',
					[699]	=	'Random Needles',
					[700]	=	'Frogkick',
					[701]	=	'Spore',
					[702]	=	'Queasyshroom',
					[703]	=	'Numbshroom',
					[704]	=	'Shakeshroom',
					[705]	=	'Silence Gas',
					[706]	=	'Dark Spore',
					[707]	=	'Power Attack',
					[708]	=	'Hi Freq Field',
					[709]	=	'Rhino Attack',
					[710]	=	'Rhino Gaurd',
					[711]	=	'Spoil',
					[712]	=	'Cursed Sphere',
					[713]	=	'Venom',
					[714]	=	'Sandblast',
					[715]	=	'Sandpit',
					[716]	=	'Venom Spray',
					[717]	=	'Mandibular Bite',
					[718]	=	'Soporific',
					[719]	=	'Gloeosuccus',
					[720]	=	'Palsy Pollen',
					[721]	=	'Geist Wall',
					[722]	=	'Numbing Noise',
					[723]	=	'Nimble Snap',
					[724]	=	'Cyclotail',
					[725]	=	'Toxic Spit',
					[726]	=	'Double Claw',
					[727]	=	'Grapple',
					[728]	=	'Spinning Top',
					[729]	=	'Filamented Hold',
					[730]	=	'Chaotic Eye',
					[731]	=	'Blaster',
					[732]	=	'Suction',
					[733]	=	'Drainkiss',
					[734]	=	'Snow Cloud',
					[735]	=	'Wild Carrot',
					[736]	=	'Sudden Lunge',
					[737]	=	'Spiral Spin',
					[738]	=	'Noisome Powder',
					[740]	=	'Acid Mist',
					[741]	=	'Tp Drainkiss',
					[743]	=	'Scythe Tail',
					[744]	=	'Ripper Fang',
					[745]	=	'Chomp Rush',
					[746]	=	'Charged Whisker',
					[747]	=	'Purulent Ooze',
					[748]	=	'Corrosive Ooze',
					[749]	=	'Back Heel',
					[750]	=	'Jettatura',
					[751]	=	'Choke Breath',
					[752]	=	'Fantod',
					[753]	=	'Tortoise Stomp',
					[754]	=	'Harden Shell',
					[755]	=	'Aqua Breath',
					[756]	=	'Wing Slap',
					[757]	=	'Beak Lunge',
					[758]	=	'Intimidate',
					[759]	=	'Recoil Dive',
					[760]	=	'Water Wall',
					[761]	=	'Sensilla Blades',
					[762]	=	'Tegmina Buffet',
					[763]	=	'Molting Plumage',
					[764]	=	'Swooping Frenzy',
					[765]	=	'Sweeping Gouge',
					[766]	=	'Zealous Snort',
					[767]	=	'Pentapeck',
					[768]	=	'Tickling Tendrils',
					[769]	=	'Stink Bomb',
					[770]	=	'Nectarous Deluge',
					[771]	=	'Nepenthic Plunge',
					[772]	=	'Somersault',
					[773]	=	'Pacifying Ruby',
					[774]	=	'Foul Waters',
					[775]	=	'Pestilent Plume',
					[776]	=	'Pecking Flurry',
					[777]	=	'Sickle Slash',
					[778]	=	'Acid Spray',
					[779]	=	'Spider Web',
					[780]	=	'Regal Gash',
					[781]	=	'Infected Leech',
					[782]	=	'Gloom Spray',
					[786]	=	'Disembowel',
					[787]	=	'Extirpating Salvo',
					[960]	=	'Clarsach Call',
					[961]	=	'Welt',
					[962]	=	'Katabatic Blades',
					[963]	=	'Lunatic Voice',
					[964]	=	'Roundhouse',
					[965]	=	'Chinook',
					[966]	=	'Bitter Elegy',
					[967]	=	'Sonic Buffet',
					[968]	=	'Tornado II',
					[969]	=	'Winds Blessing',
					[970]	=	'Hysteric Assault',

				},

		[3]	=	T{	[1] = 	'Berserk',
					[2] = 	'Warcry',
					[3] = 	'Defender',
					[4] = 	'Aggressor',
					[5] = 	'Provoke',
					[6] = 	'Warriors Charge',
					[7] = 	'Tomahawk',
					[8] = 	'Retaliation',
					[9] = 	'Restraint',
					[10] = 	'Run Elemental Resistance Ja',
					[11] = 	'Blood Rage',
					[12] = 	'Cascade',
					[13] = 	'Focus',
					[14] = 	'Dodge',
					[15] = 	'Chakra',
					[16] = 	'Boost',
					[17] = 	'Counterstance',
					[18] = 	'Chi Blast',
					[19] = 	'Mantra',
					[20] = 	'Formless Strikes',
					[21] = 	'Footwork',
					[22] = 	'Perfect Counter',
					[23] = 	'Vallation',
					[24] = 	'Swordplay',
					[25] = 	'Lunge',
					[26] = 	'Divine Seal',
					[27] = 	'Martyr',
					[28] = 	'Devotion',
					[29] = 	'Afflatus Solace',
					[30] = 	'Afflatus Misery',
					[31] = 	'Impetus',
					[32] = 	'Divine Caress',
					[33] = 	'Sacrosanctity',
					[34] = 	'Enmity Douse',
					[35] = 	'Manawell',
					[36] = 	'Saboteur',
					[37] = 	'Spontaneity',
					[38] = 	'Elemental Seal',
					[39] = 	'Mana Wall',
					[40] = 	'Conspirator',
					[41] = 	'Sepulcher',
					[42] = 	'Palisade',
					[43] = 	'Arcane Crest',
					[44] = 	'Scarlet Delirium',
					[47] = 	'Tenuto',
					[48] = 	'Marcato',
					[49] = 	'Convert',
					[50] = 	'Composure',
					[51] = 	'Bounty Shot',
					[52] = 	'Decoy Shot',
					[53] = 	'Hamanoha',
					[54] = 	'Hagakure',
					[57] = 	'Issekigan',
					[58] = 	'Dragon Breaker',
					[59] = 	'Pflug',
					[60] = 	'Steal',
					[61] = 	'Despoil',
					[62] = 	'Flee',
					[63] = 	'Hide',
					[64] = 	'Sneak Attack',
					[65] = 	'Mug',
					[66] = 	'Trick Attack',
					[67] = 	'Assassins Charge',
					[68] = 	'Feint',
					[69] = 	'Accomplice',
					[69] = 	'Collaborator',
					[70] = 	'Steady Wing',
					[71] = 	'Mana Cede',
					[72] = 	'Embolden',
					[73] = 	'Shield Bash',
					[74] = 	'Holy Circle',
					[75] = 	'Sentinel',
					[76] = 	'Cover',
					[77] = 	'Rampart',
					[78] = 	'Fealty',
					[79] = 	'Chivalry',
					[80] = 	'Divine Emblem',
					[81] = 	'Unbridled Learning',
					[85] = 	'Souleater',
					[86] = 	'Arcane Circle',
					[87] = 	'Last Resort',
					[88] = 	'Weapon Bash',
					[89] = 	'Dark Seal',
					[90] = 	'Diabolic Eye',
					[91] = 	'Nether Void',
					[92] = 	'Rune Enchantment',
					[93] = 	'Entrust',
					[94] = 	'Bestial Loyalty',
					[95] = 	'Consume Mana',
					[96] = 	'Crooked Cards',
					[97] = 	'Charm',
					[98] = 	'Gauge',
					[99] = 	'Tame',
					[100] =	'Fight',
					[101] =	'Bst Pet Ja',
					[102] =	'Monster Attack',
					[103] =	'Monster Spell',
					[104] =	'Call Beast',
					[105] =	'Feral Howl',
					[106] =	'Killer Instinct',
					[107] =	'Snarl',
					[108] =	'Apogee',
					[109] =	'Nightingale',
					[110] =	'Troubadour',
					[112] =	'Pianissimo',
					[113] =	'Valiance',
					[114] =	'Cooldown',
					[115] =	'Deus Ex Automata',
					[116] =	'Gambit',
					[117] =	'Liement',
					[118] =	'One For All',
					[119] =	'Rayke',
					[120] =	'Battuta',
					[121] =	'Scavenge',
					[122] =	'Shadowbind',
					[123] =	'Camouflage',
					[124] =	'Sharpshot',
					[125] =	'Barrage',
					[126] =	'Unlimited Shot',
					[126] =	'Double Shot',
					[127] =	'Stealth Shot',
					[128] =	'Flashy Shot',
					[129] =	'Velocity Shot',
					[130] =	'Widened Compass',
					[131] =	'Odyllic Subterfuge',
					[132] =	'Konzen Ittai',
					[133] =	'Third Eye',
					[134] =	'Meditate',
					[135] =	'Warding Circle',
					[136] =	'Shikikoyo',
					[137] =	'Blade Bash',
					[138] =	'Hasso',
					[139] =	'Seigan',
					[140] =	'Sekkanoki',
					[141] =	'Sengikori',
					[142] =	'Ward',
					[143] =	'Effusion',
					[145] =	'Sange',
					[146] =	'Yonin',
					[147] =	'Innin',
					[148] =	'Futae',
					[149] =	'Spirit Bond',
					[150] =	'Majesty',
					[157] =	'Ancient Circle',
					[158] =	'Jump',
					[159] =	'High Jump',
					[160] =	'Super Jump',
					[161] =	'Dismiss',
					[162] =	'Spirit Link',
					[163] =	'Call Wyvern',
					[164] =	'Deep Breathing',
					[165] =	'Angon',
					[166] =	'Spirit Jump',
					[167] =	'Soul Jump',
					[170] =	'Assault',
					[171] =	'Retreat',
					[172] =	'Release',
					[173] =	'Blood Pact Rage Attacks',
					[174] =	'Blood Pact Ward Effects',
					[175] =	'Elemental Siphon',
					[176] =	'Avatars Favor',
					[181] =	'Chain Affinity',
					[182] =	'Burst Affinity',
					[183] =	'Convergence',
					[184] =	'Diffusion',
					[185] =	'Efflux',
					[186] =	'Curing Waltz II',
					[187] =	'Curing Waltz III',
					[188] =	'Curing Waltz IV',
					[189] =	'Curing Waltz V',
					[190] =	'Divine Waltz II',
					[193] =	'Cor Rolls',
					[194] =	'Double Up',
					[195] =	'Cor Shots',
					[196] =	'Random Deal',
					[197] =	'Snake Eye',
					[198] =	'Fold',
					[199] =	'Quick Draw',
					[205] =	'Activate',
					[206] =	'Repair',
					[207] =	'Deploy',
					[208] =	'Deactivate',
					[209] =	'Retrieve',
					[210] =	'Maneuver',
					[211] =	'Role Reversal',
					[212] =	'Ventriloquy',
					[213] =	'Tactical Switch',
					[214] =	'Maintenance',
					[215] =	'Healing Waltz',
					[216] =	'Sambas',
					[216] =	'Drain Samba',
					[217] =	'Waltzes',
					[218] =	'Jigs',
					[219] =	'Saber Dance',
					[220] =	'Steps',
					[221] =	'Flourish',
					[222] =	'Alt Flourishes',
					[223] =	'No Foot Rise',
					[224] =	'Fan Dance',
					[225] =	'Divine Waltz',
					[226] =	'Flourishes III',
					[228] =	'Light Arts',
					[229] =	'Contradance',
					[230] =	'Modus Veritas',
					[231] =	'Sch Ja',
					[232] =	'Dark Arts',
					[233] =	'Stratagems',
					[234] =	'Sublimation',
					[235] =	'Enlightenment',
					[236] =	'Presto',
					[237] =	'Libra',
					[238] =	'Smiting Breath',
					[239] =	'Restoring Breath',
					[240] =	'Bully',
					[241] =	'Swipe',
					[242] =	'Vivacious Pulse',
					[243] =	'Full Circle',
					[244] =	'Geo Ja',
					[245] =	'Collimated Fervor',
					[246] =	'Life Cycle',
					[247] =	'Blaze Of Glory',
					[248] =	'Dematerialize',
					[249] =	'Theurgic Focus',
					[250] =	'Concentric Pulse',
					[251] =	'Mending Halation',
					[252] =	'Radial Arcana',
					[253] =	'Relinquish',
					[254] =	'Job Abilities (Var)',
					[254] =	'Caper Emissarius',
					[255] =	'Pet Commands',
					[467] =	'Triple Shot',

		},

	[4]	=	T{		[0]   = "None",
					[1]   = "Sunshine",
					[2]   = "Clouds",    
					[3]   = "Fog",      
					[4]   = "Hot Spell",
					[5]   = "Heat Wave",   
					[6]   = "Rain",   
					[7]   = "Squall",
					[8]   = "Dust Storm",
					[9]   = "Sand Storm",
					[10]  = "Wind",  
					[11]  = "Gales",
					[12]  = "Snow",
					[13]  = "Blizzards",
					[14]  = "Thunder",
					[15]  = "Thunderstorms",
					[16]  = "Auroras",
					[17]  = "Stellar Glare",
					[18]  = "Gloom",
					[19]  = "Darkness",
		
		},

	},
}

--	---------------------------------------------------------------------------
--	This decodes a direction
--	This data type can be flag controlled
--	---------------------------------------------------------------------------

function Decode.Direction(UI, PacketDisplay, RuleTable, Packet, value)

	local Angle = value * 360 / 256
	local Comp  = '?'
	
	if value > 240 or value < 16 then Comp = 'E' 
	elseif value >= 16  and value < 48  then Comp = 'SE'
	elseif value >= 48  and value < 80  then Comp = 'S'
	elseif value >= 80  and value < 112 then Comp = 'SW'
	elseif value >= 112 and value < 144 then Comp = 'W'
	elseif value >= 144 and value < 176 then Comp = 'NW'
	elseif value >= 176 and value < 208 then Comp = 'N'
	else Comp = 'NE' end
	
	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	local Bracket = ETC.Dirty
	local AngTxt  = ETC.Green
	local Direct  = ETC.OffW

	if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
		Bracket = ETC.Brown
		AngTxt  = ETC.Brown
		Direct  = ETC.Brown
	end

	imgui.TextColored(Bracket, ('[') )
	imgui.SameLine()
	imgui.TextColored(Direct, ('%s'):fmt(Comp) )
	imgui.SameLine()
	imgui.TextColored(Bracket, (']') )
	imgui.SameLine()

	imgui.TextColored(AngTxt, ('%d°'):fmt(Angle) )
	imgui.SameLine()
	imgui.TextColored(Bracket, (' .. 0x%.2X -> %d'):fmt(value, value) )
	
end


--	---------------------------------------------------------------------------
--	Job points
--	---------------------------------------------------------------------------

function Decode.JobPoints(Packet, PacketDisplay, RuleTable)

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	local B1 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset)
	local B2 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 1)
	local B3 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 2)
	local B4 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 3)

	if B1 == 0 and B2 == 0 then		--	No data
		imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, ('(No data in this slot)') )
	else

		local JobPointID	= (256 * B2) + B1
		local Level			= math.floor(B4 / 4)
		local Job			= math.floor(JobPointID / 32)
		local Id			= math.floor(JobPointID % 32)
		local Name			= 'Unknown'

		local Ability = Decode.JobPointsEffects[JobPointID]
	
		if (nil ~= Ability) then

			imgui.TextColored( ETC.Green, ('%s'):fmt(Ability) )
			imgui.SetCursorPosX(imgui.GetCursorPosX()+10)
			
		end
		
		if Job > 0 and Job < 23 then
			Name = Decode.Jobs[Job]
		end

		local XPos = imgui.GetCursorPosX()
		
		imgui.TextColored( { 0.9, 0.9, 0.0, 1.0 }, ('%s:'):fmt(Name) )
		imgui.SameLine()

		imgui.TextColored( { 0.9, 0.9, 0.9, 1.0 }, ('0x%.3X'):fmt(JobPointID) )
		imgui.SameLine()

		imgui.SetCursorPosX(XPos+120)

		imgui.TextColored( { 0.9, 0.9, 0.0, 1.0 }, ('Lv:') )
		imgui.SameLine()

		imgui.TextColored( { 0.9, 0.9, 0.9, 1.0 }, ('%d'):fmt(Level) )
		imgui.SameLine()

		imgui.SetCursorPosX(XPos+200)

		imgui.TextColored( { 0.9, 0.9, 0.0, 1.0 }, ('Next:') )
		imgui.SameLine()

		imgui.TextColored( { 0.9, 0.9, 0.9, 1.0 }, ('%d'):fmt(B3) )
	
	end
end

--	---------------------------------------------------------------------------
--	Position decode (X,Y,Z) as 12 bytes (3 x 4) - Can use flags
--	---------------------------------------------------------------------------

function Decode.XYZ_12Bytes(Packet, PacketDisplay, RuleTable)

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	local B1 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset)
	local B2 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 1)
	local B3 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 2)
	local B4 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 3)

	if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
		imgui.TextColored( ETC.Brown, ('X:%.2f  '):fmt( PacketDisplay.BinToFloat32( B1, B2, B3, B4 ) ) )
	else
		imgui.TextColored( { 0.9, 0.9, 0.0, 1.0 }, ('X:%.2f  '):fmt( PacketDisplay.BinToFloat32( B1, B2, B3, B4 ) ) )
	end
	
	imgui.SameLine()

	local B1 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 4)
	local B2 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 5)
	local B3 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 6)
	local B4 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 7)

	if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
		imgui.TextColored( ETC.Brown, ('Y:%.2f  '):fmt( PacketDisplay.BinToFloat32( B1, B2, B3, B4 ) ) )
	else
		imgui.TextColored( { 0.9, 0.9, 0.0, 1.0 }, ('Y:%.2f  '):fmt( PacketDisplay.BinToFloat32( B1, B2, B3, B4 ) ) )
	end
	
	imgui.SameLine()

	local B1 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 8)
	local B2 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 9)
	local B3 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 10)
	local B4 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 11)

	if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
		imgui.TextColored( ETC.Brown, ('Z:%.2f'):fmt( PacketDisplay.BinToFloat32( B1, B2, B3, B4 ) ) )
	else
		imgui.TextColored( { 0.9, 0.9, 0.0, 1.0 }, ('Z:%.2f'):fmt( PacketDisplay.BinToFloat32( B1, B2, B3, B4 ) ) )
	end
		
end

--	---------------------------------------------------------------------------
--	This decodes a single byte as a JOB
--	This data type can be flag controlled
--	---------------------------------------------------------------------------

function Decode.JobByte(UI, PacketDisplay, RuleTable, Packet, value)

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
		
		imgui.TextColored(ETC.Brown, ('%d'):fmt(value) )
		imgui.SameLine()
		imgui.TextColored(ETC.Brown, ('(0x%.2X)'):fmt(value) )

		if value > 0 and value < 23 then
			imgui.SameLine()
			imgui.TextColored(ETC.Brown, ('%s'):fmt(Decode.Jobs[value]) )
		end
		
	else

		imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%d'):fmt(value) )
		imgui.SameLine()
		imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, ('(0x%.2X)'):fmt(value) )
		
		if value > 0 and value < 23 then
			imgui.SameLine()
			imgui.TextColored({ 0.0, 1.0, 0.0, 1.0 }, ('%s'):fmt(Decode.Jobs[value]) )
		end
		
	end

end

--	---------------------------------------------------------------------------
--	If this data item can show text from a table (list) it is done here
--	---------------------------------------------------------------------------

function Decode.CheckForTable(UI, RuleTable, value)

	--	This data may be able to point to a table

	if RuleTable.TableID ~= 0 then

		local OurTable = Decode.Tables[RuleTable.TableID]

		if nil ~= OurTable then
			for i, ThisTable in pairs(OurTable) do
				if i == math.floor(value) then
					imgui.SetCursorPosX(imgui.GetCursorPosX()+10)
					imgui.TextColored( ETC.Yellow, ('%s'):fmt(ThisTable) )
				end
			end
		end

	end

end

--	---------------------------------------------------------------------------
--	This decodes bits
--	This data type can be flag controlled
--	---------------------------------------------------------------------------

function Decode.Bits(UI, PacketDisplay, RuleTable, Packet, value)

	local	SavedIn	 = math.floor(value)
	local	vin		 = math.floor(value)
	local	newvalue = 0
	local	bitvalue = 1

	--	If we don't start at bit 0 then shift into position

	if 0 ~= RuleTable.Bit then
		for i=0, (RuleTable.Bit - 1) do
			vin = math.floor(vin / 2)
		end
	end

	local XPos = imgui.GetCursorPosX()

	for i=0, (RuleTable.Len - 1) do

		if (1 == vin % 2) then 
			newvalue = newvalue + bitvalue
		end

		vin = math.floor(vin / 2)
		bitvalue = bitvalue * 2

	end

	imgui.SetCursorPosX(XPos + 10)
	imgui.TextColored({ 0.0, 1.0, 0.0, 1.0 }, ('%d'):fmt(newvalue) )
	imgui.SameLine()

	imgui.SetCursorPosX(XPos + 70)

	if 'byte' == RuleTable.Format then
		imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, ('0x%.2X'):fmt(newvalue) )
	elseif 'word' == RuleTable.Format or 'rword' == RuleTable.Format then
		imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, ('0x%.4X'):fmt(newvalue) )
	elseif 'dword' == RuleTable.Format or 'rdword' == RuleTable.Format then
		imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, ('0x%.8X'):fmt(newvalue) )
	end

	imgui.SameLine()
	imgui.SetCursorPosX(XPos + 200)

	imgui.TextColored({ 0.7, 0.7, 0.7, 1.0 }, ('[%.2d ~ %.2d]'):fmt(RuleTable.Bit, RuleTable.Bit + RuleTable.Len - 1) )

	Decode.CheckForTable(UI, RuleTable, newvalue)

end

--	---------------------------------------------------------------------------
--	This decodes a text string
--	This data type can be flag controlled
--	---------------------------------------------------------------------------

function Decode.String(UI, PacketDisplay, RuleTable, Packet)

	local 	strText		= ""
	local	index		= 0
	local	ThisByte	= ""

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	while 0 ~= ThisByte and index < Packet.size do
		
		ThisByte = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + index)
		ThisChar = string.format('%c', ThisByte)

		if (0 ~= ThisByte) then
			strText = strText .. ThisChar
		end
	
		index = index + 1

	end

	if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
		imgui.TextColored(ETC.Brown, ('%c%s%c'):fmt(34, strText, 34) )
	else
		imgui.TextColored({ 0.0, 1.0, 0.0, 1.0 }, ('%c%s%c'):fmt(34, strText, 34) )
	end

end

--	---------------------------------------------------------------------------
--	This decodes an IP address
--	This data type can be flag controlled
--	---------------------------------------------------------------------------

function Decode.IP(Packet, PacketDisplay, RuleTable)

	local	IP1 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset)
	local	IP2 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 1)
	local	IP3 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 2)
	local	IP4 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 3)

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
		imgui.TextColored(ETC.Brown, ('Address: %d.%d.%d.%d'):fmt(IP1, IP2, IP3, IP4) )
	else
		imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('Address: %d.%d.%d.%d'):fmt(IP1, IP2, IP3, IP4) )
	end

end

--	---------------------------------------------------------------------------
--	This decodes an item ID
--	This data type can be flag controlled
--	---------------------------------------------------------------------------

function Decode.Item(Packet, PacketDisplay, RuleTable, value)

	local resource = AshitaCore:GetResourceManager():GetItemById(value)

	if nil ~= resource then
		
		imgui.SetCursorPosX(imgui.GetCursorPosX()+10)
	
		if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
			imgui.TextColored(ETC.Brown, ('%s'):fmt(resource.Name[1]) )
		else
			imgui.TextColored(ETC.Green, ('%s'):fmt(resource.Name[1]) )
		end

	end

end

--	---------------------------------------------------------------------------
--	This decodes a storge location
--	This data type can be flag controlled
--	---------------------------------------------------------------------------

function Decode.Store(Packet, PacketDisplay, RuleTable, value)

	local	Store = Decode.Storage[value]

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	if nil ~= Store then
			
		if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then

			imgui.TextColored(ETC.Brown, ('%d'):fmt(value) )
			imgui.SameLine()

			imgui.SetCursorPosX(imgui.GetCursorPosX()+50)
			imgui.TextColored(ETC.Brown, ('%s'):fmt(Store) )

		else

			imgui.TextColored(ETC.OffW, ('%d'):fmt(value) )
			imgui.SameLine()

			imgui.SetCursorPosX(imgui.GetCursorPosX()+50)
			imgui.TextColored(ETC.Green, ('%s'):fmt(Store) )
		
		end

	else
		imgui.TextColored(ETC.Red, ('UNKNOWN LOCATION') )
	end

end

--	---------------------------------------------------------------------------
--	This decodes the Vana'Diel date
--	This data type can be flag controlled
--	---------------------------------------------------------------------------

function Decode.VDate(PacketDisplay, RuleTable, Packet, value)

	local	SavedIn	= math.floor(value)
	local	min	 	= 0
	local	hour	= 0
	local	day  	= 0
	local	month	= 0
	local	year	= 0

	min   = math.floor(value) % 60
	value = math.floor(value / 60)

	hour  = math.floor(value) % 24
	value = math.floor(value / 24)

	day   = math.floor(value) % 30
	value = math.floor(value / 30)

	month = math.floor(value) % 12
	year  = math.floor(value / 12)

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
		imgui.TextColored(ETC.Brown, ('Y:%d  M:%.2d  D:%.2d  H:%.2d  M:%.2d'):fmt(year, month, day, hour, min) )
	else
		imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('Y:%d  M:%.2d  D:%.2d  H:%.2d  M:%.2d'):fmt(year, month, day, hour, min) )
	end
end

--	---------------------------------------------------------------------------
--	This decodes the craft skill and rank
--	This data type can be flag controlled
--	---------------------------------------------------------------------------

function Decode.Craft(PacketDisplay, RuleTable, Packet, value)

	local	SavedIn	 = math.floor(value)
	local	Level	 = math.floor(value / 32)
	local	Rank 	 = math.floor(value) % 32

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
		imgui.TextColored(ETC.Brown, ('Rank:') )
		imgui.SameLine()
		imgui.TextColored(ETC.Brown, ('%d'):fmt(Rank) )
		imgui.SameLine()

		imgui.TextColored(ETC.Brown, ('Level:') )
		imgui.SameLine()
		imgui.TextColored(ETC.Brown, ('%d'):fmt(Level) )
		imgui.SameLine()
	else
		imgui.TextColored({ 0.0, 1.0, 0.0, 1.0 }, ('Rank:') )
		imgui.SameLine()
		imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%d'):fmt(Rank) )
		imgui.SameLine()

		imgui.TextColored({ 0.0, 1.0, 0.0, 1.0 }, ('Level:') )
		imgui.SameLine()
		imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%d'):fmt(Level) )
		imgui.SameLine()
	end

	imgui.SameLine()

end

return Decode
