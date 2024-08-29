--	---------------------------------------------------------------------------
--	This file contains the data decoding functions
--	---------------------------------------------------------------------------

require('common')

local chat	= require('chat')
local imgui	= require('imgui')

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

	Jobs	  = T{	'WAR', 'MNK', 'WHM', 'BLM', 'RDM', 'THF', 'PLD', 'DRK', 'BST', 'BRD', 'RNG', 
					'SAM', 'NIN', 'DRG', 'SMN', 'BLU', 'COR', 'PUP', 'DNC', 'SCH', 'GEO', 'RUN',	
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

	local Bracket = UI.Dirty
	local AngTxt  = UI.Green
	local Direct  = UI.OffW

	if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
		Bracket = UI.Grey1
		AngTxt  = UI.Grey1
		Direct  = UI.Grey1
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
--	Position decode (X,Y,Z) as 12 bytes (3 x 4) - Can use flags
--	---------------------------------------------------------------------------

function Decode.XYZ_12Bytes(Packet, PacketDisplay, RuleTable)

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	local B1 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset)
	local B2 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 1)
	local B3 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 2)
	local B4 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 3)

	if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
		imgui.TextColored( { 0.5, 0.5, 0.5, 1.0 }, ('X:%.2f  '):fmt( PacketDisplay.BinToFloat32( B1, B2, B3, B4 ) ) )
	else
		imgui.TextColored( { 0.9, 0.9, 0.0, 1.0 }, ('X:%.2f  '):fmt( PacketDisplay.BinToFloat32( B1, B2, B3, B4 ) ) )
	end
	
	imgui.SameLine()

	local B1 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 4)
	local B2 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 5)
	local B3 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 6)
	local B4 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 7)

	if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
		imgui.TextColored( { 0.5, 0.5, 0.5, 1.0 }, ('Y:%.2f  '):fmt( PacketDisplay.BinToFloat32( B1, B2, B3, B4 ) ) )
	else
		imgui.TextColored( { 0.9, 0.9, 0.0, 1.0 }, ('Y:%.2f  '):fmt( PacketDisplay.BinToFloat32( B1, B2, B3, B4 ) ) )
	end
	
	imgui.SameLine()

	local B1 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 8)
	local B2 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 9)
	local B3 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 10)
	local B4 = PacketDisplay.ExtractByte(Packet, RuleTable.Offset + 11)

	if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
		imgui.TextColored( { 0.5, 0.5, 0.5, 1.0 }, ('Z:%.2f'):fmt( PacketDisplay.BinToFloat32( B1, B2, B3, B4 ) ) )
	else
		imgui.TextColored( { 0.9, 0.9, 0.0, 1.0 }, ('Z:%.2f'):fmt( PacketDisplay.BinToFloat32( B1, B2, B3, B4 ) ) )
	end
		
end

--	---------------------------------------------------------------------------
--	This decodes a single byte as a JOB
--	This data type can be flag controlled
--	---------------------------------------------------------------------------

function Decode.JobByte(PacketDisplay, RuleTable, Packet, value)

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
		
		imgui.TextColored({ 0.5, 0.5, 0.5, 1.0 }, ('%d'):fmt(value) )
		imgui.SameLine()
		imgui.TextColored({ 0.4, 0.4, 0.4, 1.0 }, ('(0x%.2X)'):fmt(value) )

		if value > 0 and value < 23 then
			imgui.SameLine()
			imgui.TextColored({ 0.5, 0.5, 0.5, 1.0 }, ('%s'):fmt(Decode.Jobs[value]) )
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
					imgui.TextColored( UI.Yellow, ('%s'):fmt(ThisTable) )
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

function Decode.String(PacketDisplay, RuleTable, Packet)

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
		imgui.TextColored({ 0.4, 0.4, 0.4, 1.0 }, ('%c%s%c'):fmt(34, strText, 34) )
	else
		imgui.TextColored({ 0.0, 1.0, 0.0, 1.0 }, ('%c%s%c'):fmt(34, strText, 34) )
	end

end


--	---------------------------------------------------------------------------
--	This decodes the craft skill and rank
--	This data type can be flag controlled
--	---------------------------------------------------------------------------

function Decode.Craft(UI, PacketDisplay, RuleTable, Packet, value)

	local	SavedIn	 = math.floor(value)
	local	Level	 = math.floor(value / 32)
	local	Rank 	 = math.floor(value) % 32

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	if (('use' == RuleTable.Logic) and (0 == PacketDisplay.Flags[RuleTable.Flag])) then
		imgui.TextColored({ 0.4, 0.4, 0.4, 1.0 }, ('Rank:') )
		imgui.SameLine()
		imgui.TextColored({ 0.4, 0.4, 0.4, 1.0 }, ('%d'):fmt(Rank) )
		imgui.SameLine()

		imgui.TextColored({ 0.4, 0.4, 0.4, 1.0 }, ('Level:') )
		imgui.SameLine()
		imgui.TextColored({ 0.4, 0.4, 0.4, 1.0 }, ('%d'):fmt(Level) )
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
