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

	Attach    = T{

		[8449]	=	'Strobe',
		[8450]	=	'Tension Spring',
		[8451]	=	'Inhibitor',
		[8452]	=	'Tension Spring II',
		[8453]	=	'Attuner',
		[8454]	=	'Reactive Shield',
		[8455]	=	'Flame Holder',
		[8456]	=	'Heat Capacitor',
		[8457]	=	'Strobe II',
		[8458]	=	'Tension Spring III',
		[8459]	=	'Inhibitor II',
		[8460]	=	'Tension Spring IV',
		[8461]	=	'Heat Capacitor II',
		[8462]	=	'Speedloader',
		[8463]	=	'Speedloader II',
		[8464]	=	'Tension Spring V',
		[8465]	=	'Magniplug',
		[8466]	=	'Magniplug II',
		[8481]	=	'Mana Booster',
		[8482]	=	'Loudspeaker',
		[8483]	=	'Scanner',
		[8484]	=	'Loudspeaker II',
		[8485]	=	'Tactical Processor',
		[8486]	=	'Tranquilizer',
		[8487]	=	'Ice Maker',
		[8488]	=	'Power Cooler',
		[8489]	=	'Loudspeaker III',
		[8490]	=	'Tranquilizer II',
		[8491]	=	'Amplifier',
		[8492]	=	'Loudspeaker IV',
		[8493]	=	'Tranquilizer III',
		[8494]	=	'Amplifier II',
		[8495]	=	'Loudspeaker V',
		[8496]	=	'Tranquilizer IV',
		[8497]	=	'Arcanoclutch',
		[8498]	=	'Arcanoclutch II',
		[8513]	=	'Accelerator',
		[8514]	=	'Scope',
		[8515]	=	'Pattern Reader',
		[8516]	=	'Accelerator II',
		[8517]	=	'Drum Magazine',
		[8518]	=	'Turbo Charger',
		[8519]	=	'Replicator',
		[8520]	=	'Barrage Turbine',
		[8521]	=	'Turbo Charger II',
		[8522]	=	'Accelerator III',
		[8523]	=	'Scope II',
		[8524]	=	'Repeater',
		[8525]	=	'Accelerator IV',
		[8526]	=	'Scope III',
		[8527]	=	'Scope IV',
		[8528]	=	'Truesights',
		[8545]	=	'Shock Absorber',
		[8546]	=	'Armor Plate',
		[8547]	=	'Analyzer',
		[8548]	=	'Armor Plate II',
		[8549]	=	'Equalizer',
		[8550]	=	'Schurzen',
		[8551]	=	'Hammermill',
		[8552]	=	'Barrier Module II',
		[8553]	=	'Shock Absorber II',
		[8554]	=	'Armor Plate III',
		[8555]	=	'Barrier Module',
		[8556]	=	'Armor Plate IV',
		[8557]	=	'Shock Absorber III',
		[8577]	=	'Stabilizer',
		[8578]	=	'Volt Gun',
		[8579]	=	'Heat Seeker',
		[8580]	=	'Stabilizer II',
		[8581]	=	'Target Marker',
		[8582]	=	'Dynamo',
		[8583]	=	'Coiler',
		[8584]	=	'Galvanizer',
		[8585]	=	'Stabilizer III',
		[8586]	=	'Coiler II',
		[8587]	=	'Dynamo II',
		[8588]	=	'Stabilizer IV',
		[8589]	=	'Dynamo III',
		[8590]	=	'Stabilizer V',
		[8609]	=	'Mana Jammer',
		[8610]	=	'Heatsink',
		[8611]	=	'Stealth Screen',
		[8612]	=	'Mana Jammer II',
		[8613]	=	'Mana Channeler',
		[8614]	=	'Condenser',
		[8615]	=	'Steam Jacket',
		[8616]	=	'Percolator',
		[8617]	=	'Mana Jammer III',
		[8618]	=	'Stealth Screen II',
		[8619]	=	'Resister',
		[8620]	=	'Resister II',
		[8621]	=	'Mana Jammer IV',
		[8622]	=	'Mana Channeler II',
		[8641]	=	'Auto Repair Kit',
		[8642]	=	'Flashbulb',
		[8643]	=	'Damage Gauge',
		[8644]	=	'Auto Repair Kit II',
		[8645]	=	'Eraser',
		[8646]	=	'Optic Fiber',
		[8648]	=	'Vivi Valve',
		[8649]	=	'Vivi Valve II',
		[8650]	=	'Auto Repair Kit III',
		[8651]	=	'Arcanic Cell',
		[8652]	=	'Arcanic Cell II',
		[8653]	=	'Auto Repair Kit IV',
		[8654]	=	'Optic Fiber II',
		[8655]	=	'Damage Gauge II',
		[8673]	=	'Mana Tank',
		[8674]	=	'Mana Converter',
		[8675]	=	'Mana Conserver',
		[8676]	=	'Mana Tank II',
		[8677]	=	'Smoke Screen',
		[8678]	=	'Economizer',
		[8680]	=	'Disruptor',
		[8681]	=	'Mana Tank III',
		[8682]	=	'Regulator',
		[8683]	=	'Mana Tank IV',
		
		},

	Jobs	  = T{	'WAR', 'MNK', 'WHM', 'BLM', 'RDM', 'THF', 'PLD', 'DRK', 'BST', 'BRD', 'RNG', 
					'SAM', 'NIN', 'DRG', 'SMN', 'BLU', 'COR', 'PUP', 'DNC', 'SCH', 'GEO', 'RUN',	
				},

	Merits	= T{

				--   HP
						
				[0x0040]	=	'Max HP',
				[0x0042]	=	'Max MP',
				[0x0044]	=	'Max Merit',
					
				--   ATTRIBUTES
						
				[0x0080]	=	'STR',
				[0x0082]	=	'DEX',
				[0x0084]	=	'VIT',
				[0x0086]	=	'AGI',
				[0x0088]	=	'INT',
				[0x008A]	=	'MND',
				[0x008C]	=	'CHR',
					
				--   COMBAT SKILLS
				
				[0x00c0]	=	'H2H',
				[0x00c2]	=	'Dagger',
				[0x00c4]	=	'Sword',
				[0x00c6]	=	'Gsword',
				[0x00c8]	=	'Axe',
				[0x00ca]	=	'Gaxe',
				[0x00cc]	=	'Scythe',
				[0x00ce]	=	'Polearm',
				[0x00d0]	=	'Katana',
				[0x00d2]	=	'Gkatana',
				[0x00d4]	=	'Club',
				[0x00d6]	=	'Staff',
				[0x00d8]	=	'Archery',
				[0x00da]	=	'Marksmanship',
				[0x00dc]	=	'Throwing',
				[0x00de]	=	'Guarding',
				[0x00e0]	=	'Evasion',
				[0x00e2]	=	'Shield',
				[0x00e4]	=	'Parrying',
					
				--   Magic Skills
				
				[0x0100]	=	'Divine',
				[0x0102]	=	'Healing',
				[0x0104]	=	'Enhancing',
				[0x0106]	=	'Enfeebling',
				[0x0108]	=	'Elemental',
				[0x010a]	=	'Dark',
				[0x010c]	=	'Summoning',
				[0x010e]	=	'Ninjitsu',
				[0x0110]	=	'Singing',
				[0x0112]	=	'String',
				[0x0114]	=	'Wind',
				[0x0116]	=	'Blue',
				[0x0118]	=	'Geo',
				[0x011a]	=	'Handbell',
					
				--   Others
				
				[0x0140]	=	'Enmity Increase',
				[0x0142]	=	'Enmity Decrease',
				[0x0144]	=	'Crit Hit Rate',
				[0x0146]	=	'Enemy Crit Rate',
				[0x0148]	=	'Spell Interuption Rate',
					
				--   War 1
				
				[0x0180]	=	'Berserk Recast',
				[0x0182]	=	'Defender Recast',
				[0x0184]	=	'Warcry Recast',
				[0x0186]	=	'Aggressor Recast',
				[0x0188]	=	'Double Attack Rate',
					
				--   Mnk 1
				
				[0x01c0]	=	'Focus Recast',
				[0x01c2]	=	'Dodge Recast',
				[0x01c4]	=	'Chakra Recast',
				[0x01c6]	=	'Counter Rate',
				[0x01c8]	=	'Kick Attack Rate',
					
				--   Whm 1
				
				[0x0200]	=	'Divine Seal Recast',
				[0x0202]	=	'Cure Cast Time',
				[0x0204]	=	'Bar Spell Effect',
				[0x0206]	=	'Banish Effect',
				[0x0208]	=	'Regen Effect',
					
				--   Blm 1
				
				[0x0240]	=	'Elemental Seal Recast',
				[0x0242]	=	'Fire Magic Potency',
				[0x0244]	=	'Ice Magic Potency',
				[0x0246]	=	'Wind Magic Potency',
				[0x0248]	=	'Earth Magic Potency',
				[0x024a]	=	'Lightning Magic Potency',
				[0x024c]	=	'Water Magic Potency',
					
				--   Rdm 1
				
				[0x0280]	=	'Convert Recast',
				[0x0282]	=	'Fire Magic Accuracy',
				[0x0284]	=	'Ice Magic Accuracy',
				[0x0286]	=	'Wind Magic Accuracy',
				[0x0288]	=	'Earth Magic Accuracy',
				[0x028a]	=	'Lightning Magic Accuracy',
				[0x028c]	=	'Water Magic Accuracy',
					
				--   Thf 1
				
				[0x02c0]	=	'Flee Recast',
				[0x02c2]	=	'Hide Recast',
				[0x02c4]	=	'Sneak Attack Recast',
				[0x02c6]	=	'Trick Attack Recast',
				[0x02c8]	=	'Triple Attack Rate',
					
				--   Pld 1
				
				[0x0300]	=	'Shield Bash Recast',
				[0x0302]	=	'Holy Circle Recast',
				[0x0304]	=	'Sentinel Recast',
				[0x0306]	=	'Cover Effect Length',
				[0x0308]	=	'Rampart Recast',
					
				--   Drk 1
				
				[0x0340]	=	'Souleater Recast',
				[0x0342]	=	'Arcane Circle Recast',
				[0x0344]	=	'Last Resort Recast',
				[0x0346]	=	'Last Resort Effect',
				[0x0348]	=	'Weapon Bash Effect',
					
				--   Bst 1
				
				[0x0380]	=	'Killer Effects',
				[0x0382]	=	'Reward Recast',
				[0x0384]	=	'Call Beast Recast',
				[0x0386]	=	'Sic Recast',
				[0x0388]	=	'Tame Recast',
					
				--   Brd 1
				
				[0x03c0]	=	'Lullaby Recast',
				[0x03c2]	=	'Finale Recast',
				[0x03c4]	=	'Minne Effect',
				[0x03c6]	=	'Minuet Effect',
				[0x03c8]	=	'Madrigal Effect',
					
				--   Rng 1
				
				[0x0400]	=	'Scavenge Effect',
				[0x0402]	=	'Camouflage Recast',
				[0x0404]	=	'Sharpshot Recast',
				[0x0406]	=	'Unlimited Shot Recast',
				[0x0408]	=	'Rapid Shot Rate',
					
				--   Sam 1
				
				[0x0440]	=	'Third Eye Recast',
				[0x0442]	=	'Warding Circle Recast',
				[0x0444]	=	'Store TP Effect',
				[0x0446]	=	'Meditate Recast',
				[0x0448]	=	'Zashin Attack Rate',
					
				--   Nin 1
				
				[0x0480]	=	'Subtle Blow Effect',
				[0x0482]	=	'Katon Effect',
				[0x0484]	=	'Hyoton Effect',
				[0x0486]	=	'Huton Effect',
				[0x0488]	=	'Doton Effect',
				[0x048a]	=	'Raiton Effect',
				[0x048c]	=	'Suiton Effect',
					
				--   Drg 1
				
				[0x04c0]	=	'Ancient Circle Recast',
				[0x04c2]	=	'Jump Recast',
				[0x04c4]	=	'High Jump Recast',
				[0x04c6]	=	'Super Jump Recast',
				[0x04c8]	=	'Spirit Link Recast',
					
				--   Smn 1
				
				[0x0500]	=	'Avatar Physical Accuracy',
				[0x0502]	=	'Avatar Physical Attack',
				[0x0504]	=	'Avatar Magical Accuracy',
				[0x0506]	=	'Avatar Magical Attack',
				[0x0508]	=	'Summoning Magic Cast Time',
					
				--   Blu 1
				
				[0x0540]	=	'Chain Affinity Recast',
				[0x0542]	=	'Burst Affinity Recast',
				[0x0544]	=	'Monster Correlation',
				[0x0546]	=	'Physical Potency',
				[0x0548]	=	'Magical Accuracy',
					
				--   Cor 1
				
				[0x0580]	=	'Phantom Roll Recast',
				[0x0582]	=	'Quick Draw Recast',
				[0x0584]	=	'Quick Draw Accuracy',
				[0x0586]	=	'Random Deal Recast',
				[0x0588]	=	'Bust Duration',
					
				--   Pup 1
				
				[0x05c0]	=	'Automaton Skills',
				[0x05c2]	=	'Maintenace Recast',
				[0x05c4]	=	'Repair Effect',
				[0x05c6]	=	'Activate Recast',
				[0x05c8]	=	'Repair Recast',
					
				--   Dnc 1
				
				[0x0600]	=	'Step Accuracy',
				[0x0602]	=	'Haste Samba Effect',
				[0x0604]	=	'Reverse Flourish Effect',
				[0x0606]	=	'Building Flourish Effect',
					
				--   Sch 1
				
				[0x0640]	=	'Grimoire Recast',
				[0x0642]	=	'Modus Veritas Duration',
				[0x0644]	=	'Helix Magic Acc Att',
				[0x0646]	=	'Max Sublimation',
					
				--   Geo 1
				
				[0x06c0]	=	'Full Circle Effect',
				[0x06c2]	=	'Ecliptic Att Recast',
				[0x06c4]	=	'Life Cycle Recast',
				[0x06c6]	=	'Blaze Of Glory Recast',
				[0x06c8]	=	'Dematerialize Recast',
					
				--   Run 1
				
				[0x0700]	=	'Rune Enhance',
				[0x0702]	=	'Vallation Effect',
				[0x0704]	=	'Lunge Effect',
				[0x0706]	=	'Pflug Effect',
				[0x0708]	=	'Gambit Effect',
					
				--   Weapon Skills
				
				[0x0680]	=	'Shijin Spiral',
				[0x0682]	=	'Exenterator',
				[0x0684]	=	'Requiescat',
				[0x0686]	=	'Resolution',
				[0x0688]	=	'Ruinator',
				[0x068a]	=	'Upheaval',
				[0x068c]	=	'Entropy',
				[0x068e]	=	'Stardiver',
				[0x0690]	=	'Blade Shun',
				[0x0692]	=	'Tachi Shoha',
				[0x0694]	=	'Realmrazer',
				[0x0696]	=	'Shattersoul',
				[0x0698]	=	'Apex Arrow',
				[0x069a]	=	'Last Stand',
					
				--   War 2
				
				[0x0800]	=	'Warriors Charge',
				[0x0802]	=	'Tomahawk',
				[0x0804]	=	'Savagery',
				[0x0806]	=	'Aggressive Aim',
					
				--   Mnk 2
				
				[0x0840]	=	'Mantra',
				[0x0842]	=	'Formless Strikes',
				[0x0844]	=	'Invigorate',
				[0x0846]	=	'Penance',
					
				--   Whm 2
				
				[0x0880]	=	'Martyr',
				[0x0882]	=	'Devotion',
				[0x0884]	=	'Protectra V',
				[0x0886]	=	'Shellra V',
				[0x0888]	=	'Animus Solace',
				[0x088a]	=	'Animus Misery',
					
				--   Blm 2
				
				[0x08c0]	=	'Flare II',
				[0x08c2]	=	'Freeze II',
				[0x08c4]	=	'Tornado II',
				[0x08c6]	=	'Quake II',
				[0x08c8]	=	'Burst II',
				[0x08ca]	=	'Flood II',
				[0x08cc]	=	'Ancient Magic Atk Bonus',
				[0x08ce]	=	'Ancient Magic Burst Dmg',
				[0x08d0]	=	'Elemental Magic Accuracy',
				[0x08d2]	=	'Elemental Debuff Duration',
				[0x08d4]	=	'Elemental Debuff Effect',
				[0x08d6]	=	'Aspir Absorption Amount',
					
				--   Rdm 2
				
				[0x0900]	=	'Dia III',
				[0x0902]	=	'Slow II',
				[0x0904]	=	'Paralyze II',
				[0x0906]	=	'Phalanx II',
				[0x0908]	=	'Bio III',
				[0x090a]	=	'Blind II',
				[0x090c]	=	'Enfeebling Magic Duration',
				[0x090e]	=	'Magic Accuracy',
				[0x0910]	=	'Enhancing Magic Duration',
				[0x0912]	=	'Immunobreak Chance',
				[0x0914]	=	'Enspell Damage',
				[0x0916]	=	'Accuracy',
					
				--   Thf 2
				
				[0x0940]	=	'Assassins Charge',
				[0x0942]	=	'Feint',
				[0x0944]	=	'Aura Steal',
				[0x0946]	=	'Ambush',
					
				--   Pld 2
				
				[0x0980]	=	'Fealty',
				[0x0982]	=	'Chivalry',
				[0x0984]	=	'Iron Will',
				[0x0986]	=	'Guardian',
					
				--   Drk 2
				
				[0x09c0]	=	'Dark Seal',
				[0x09c2]	=	'Diabolic Eye',
				[0x09c4]	=	'Muted Soul',
				[0x09c6]	=	'Desperate Blows',
					
				--   Bst 2
				
				[0x0a00]	=	'Feral Howl',
				[0x0a02]	=	'Killer Instinct',
				[0x0a04]	=	'Beast Affinity',
				[0x0a06]	=	'Beast Healer',
					
				--   Brd 2
				
				[0x0a40]	=	'Nightingale',
				[0x0a42]	=	'Troubadour',
				[0x0a44]	=	'Foe Sirvente',
				[0x0a46]	=	'Adventurers Dirge',
				[0x0a48]	=	'Con Anima',
				[0x0a4a]	=	'Con Brio',
					
				--   Rng 2
				
				[0x0a80]	=	'Stealth Shot',
				[0x0a82]	=	'Flashy Shot',
				[0x0a84]	=	'Snapshot',
				[0x0a86]	=	'Recycle',
					
				--   Sam 2
				
				[0x0ac0]	=	'Shikikoyo',
				[0x0ac2]	=	'Blade Bash',
				[0x0ac4]	=	'Ikishoten',
				[0x0ac6]	=	'Overwhelm',
					
				--   Nin 2
				
				[0x0b00]	=	'Sange',
				[0x0b02]	=	'Ninja Tool Expertise',
				[0x0b04]	=	'Katon San',
				[0x0b06]	=	'Hyoton San',
				[0x0b08]	=	'Huton San',
				[0x0b0a]	=	'Doton San',
				[0x0b0c]	=	'Raiton San',
				[0x0b0e]	=	'Suiton San',
				[0x0b10]	=	'Yonin Effect',
				[0x0b12]	=	'Innin Effect',
				[0x0b14]	=	'Nin Magic Accuracy',
				[0x0b16]	=	'Nin Magic Bonus',
					
				--   Drg 2
				
				[0x0b40]	=	'Deep Breathing',
				[0x0b42]	=	'Angon',
				[0x0b44]	=	'Empathy',
				[0x0b46]	=	'Strafe Effect',
					
				--   Smn 2
				
				[0x0b80]	=	'Meteor Strike',
				[0x0b82]	=	'Heavenly Strike',
				[0x0b84]	=	'Wind Blade',
				[0x0b86]	=	'Geocrush',
				[0x0b88]	=	'Thunderstorm',
				[0x0b8a]	=	'Grandfall',
					
				--   Blu 2
				
				[0x0bc0]	=	'Convergence',
				[0x0bc2]	=	'Diffusion',
				[0x0bc4]	=	'Enchainment',
				[0x0bc6]	=	'Assimilation',
					
				--   Cor 2
				
				[0x0c00]	=	'Snake Eye',
				[0x0c02]	=	'Fold',
				[0x0c04]	=	'Winning Streak',
				[0x0c06]	=	'Loaded Deck',
					
				--   Pup 2
				
				[0x0c40]	=	'Role Reversal',
				[0x0c42]	=	'Ventriloquy',
				[0x0c44]	=	'Fine Tuning',
				[0x0c46]	=	'Optimization',
					
				--   Dnc 2
				
				[0x0c80]	=	'Saber Dance',
				[0x0c82]	=	'Fan Dance',
				[0x0c84]	=	'No Foot Rise',
				[0x0c86]	=	'Closed Position',
					
				--   Sch 2
				
				[0x0cc0]	=	'Altruism',
				[0x0cc2]	=	'Focalization',
				[0x0cc4]	=	'Tranquility',
				[0x0cc6]	=	'Equanimity',
				[0x0cc8]	=	'Enlightenment',
				[0x0cca]	=	'Stormsurge',
					
				--   Geo 2
				
				[0x0d40]	=	'Mending Halation',
				[0x0d42]	=	'Radial Arcana',
				[0x0d44]	=	'Curative Recantation',
				[0x0d46]	=	'Primeval Zeal',
					
				--   Run 2
				
				[0x0d80]	=	'Battuta',
				[0x0d82]	=	'Rayke',
				[0x0d84]	=	'Inspiration',
				[0x0d86]	=	'Sleight Of Sword',
		 

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

	[5]	=	T{	    [1] = 'Harlequin Head',
					[2] = 'Valoredge Head',
					[3] = 'Sharpshot Head',
					[4] = 'Stormwaker Head',
					[5] = 'Soulsoother Head',
					[6] = 'Spiritreaver Head',
		},

	[6]	=	T{	    [32] = 'Harlequin Frame',
					[33] = 'Valoredge Frame',
					[34] = 'Sharpshot Frame',
					[35] = 'Stormwaker Frame',
		},


	[7] =	T{

			[0x00]	=	'Chocobo',
			[0x01]	=	'Raptor',
			[0x02]	=	'Tiger',
			[0x03]	=	'Crab',
			[0x04]	=	'Red Crab',
			[0x05]	=	'Bomb',
			[0x06]	=	'Sheep',
			[0x07]	=	'Morbol',
			[0x08]	=	'Crawler',
			[0x09]	=	'Fenrir',
			[0x0A]	=	'Beetle',
			[0x0B]	=	'Moogle',
			[0x0C]	=	'Magic Pot',
			[0x0D]	=	'Tulfaire',
			[0x0E]	=	'Warmachine',
			[0x0F]	=	'Xzomit',
			[0x10]	=	'Hippogryph',
			[0x11]	=	'Spectral Chair',
			[0x12]	=	'Spheroid',
			[0x13]	=	'Omega',
			[0x14]	=	'Coeurl',
			[0x15]	=	'Goobbue',
			[0x16]	=	'Raaz',
			[0x17]	=	'Levitus',
			[0x18]	=	'Adamantoise',
			[0x19]	=	'Dhalmel',
			[0x1A]	=	'Doll',
			[0x1B]	=	'Golden Bomb',
			[0x1C]	=	'Buffalo',
			[0x1D]	=	'Wivre',
			[0x1E]	=	'Red Raptor',
			[0x1F]	=	'Iron Giant',
			[0x20]	=	'Byakko',
			[0x21]	=	'Noble Chocobo',
			[0x22]	=	'Ixion',
			[0x23]	=	'Phuabo',
			
		},
	
		[8] = T{

			[40] = 'Cloister of Time and Souls',
			[41] = 'Royal Wanderlust',
			[42] = 'Snowdrift Waltz',
			[43] = 'Troubled Shadows',
			[44] = 'Where Lords Rule Not',
			[45] = 'Summers Lost',
			[46] = 'Goddess Divine',
			[47] = 'Echoes of Creation',
			[48] = 'Main Theme',
			[49] = 'Luck of the Mog',
			[50] = 'Feast of the Ladies',
			[51] = 'Scarlet Skies',
			[52] = 'Melodies Errant',
			[53] = 'Shinryu',
			[54] = 'Everlasting Bonds',
			[55] = 'Provenance Watcher',
			[56] = 'Where it All Begins',
			[57] = 'Steel Sings',
			[58] = 'A New Direction',
			[59] = 'The Pioneers',
			[60] = 'Into Lands Primeval',
			[61] = 'Waters Umbral Knell',
			[62] = 'Keepers of the Wild',
			[63] = 'The Sacred City of Adoulin',
			[64] = 'Breaking Ground',
			[65] = 'Hades',
			[66] = 'Arciela',
			[67] = 'Mog Resort',
			[68] = 'Worlds Away',
			[69] = 'Unknown',
			[70] = 'Monstrosity',
			[71] = 'The Pioneers (Piano)',
			[72] = 'The Divine',
			[73] = 'The Serpentine Labyrinth',
			[74] = 'Clouds Over Ulbuka',
			[75] = 'The Price',
			[76] = 'Forever Today',
			[77] = 'Unused ID',
			[78] = 'Forever Today (EP. Ver - Instrumental)',
			[79] = 'Unknown',
			[80] = 'Unknown',
			[81] = 'Isle of the Gods',
			[82] = 'Wail of the Void',
			[83] = 'Rhapsodies of Vanadiel',
			[84] = 'Unknown name',
			[101] = 'Battle Theme',
			[102] = 'Battle in the Dungeon #2',
			[103] = 'Battle Theme #2',
			[104] = 'A Road Once Travelled',
			[105] = 'Mhaura',
			[106] = 'Voyager',
			[107] = 'The Kingdom of SandOria',
			[108] = 'Vandiel March',
			[109] = 'Ronfaure',
			[110] = 'The Grand Duchy of Jeuno',
			[111] = 'Blackout',
			[112] = 'Selbina',
			[113] = 'Sarutabaruta',
			[114] = 'Batallia',
			[115] = 'Battle in the Dungeon',
			[116] = 'Gustaberg',
			[117] = 'ReLude Gardens',
			[118] = 'Rolanberry Fields',
			[119] = 'Awakening',
			[120] = 'Vanadiel March #2',
			[121] = 'Shadow Lord',
			[122] = 'One Last Time',
			[123] = 'Hopelessness',
			[124] = 'Recollection',
			[125] = 'Tough Battle',
			[126] = 'Mog House',
			[127] = 'Anxiety',
			[128] = 'Airship',
			[129] = 'Hook',
			[130] = 'Tarutaru Female',
			[131] = 'Elvaan Female',
			[132] = 'Elvaan Male',
			[133] = 'Hume Male',
			[134] = 'Yuhtunga Jungle',
			[135] = 'Kazham',
			[136] = 'The Big One',
			[137] = 'A Realm of Emptiness',
			[138] = 'Mercenaries Delight',
			[139] = 'Delve',
			[140] = 'Wings of the Goddess',
			[141] = 'The Cosmic Wheel',
			[142] = 'Fated Strife',
			[143] = 'Hellriders',
			[144] = 'Rapid Onslaught',
			[145] = 'Encampment Dreams',
			[146] = 'The Colosseum',
			[147] = 'Eastward Bound',
			[148] = 'Forbidden Seal',
			[149] = 'Jeweled Boughs',
			[150] = 'Ululations from Beyond',
			[151] = 'The Federation of Windurst',
			[152] = 'The Republic of Bastok',
			[153] = 'Prelude',
			[154] = 'Metalworks',
			[155] = 'Castle Zvahl',
			[156] = 'Chateau dOraguille',
			[157] = 'Fury',
			[158] = 'Sauromugue Champaign',
			[159] = 'Sorrow',
			[160] = 'Repression (Memoro)',
			[161] = 'Despair (Memoro)',
			[162] = 'Heavens Tower',
			[163] = 'Sometime',
			[164] = 'Xarcabard',
			[165] = 'Galka',
			[166] = 'Mithra',
			[167] = 'Tarutaru Male',
			[168] = 'Tarutaru Female',
			[169] = 'Regeneracy',
			[170] = 'Buccaneers',
			[171] = 'Altepa Desert',
			[172] = 'Black Coffin',
			[173] = 'Illusions in the Mist',
			[174] = 'Whispers of the Gods',
			[175] = 'Bandits Market',
			[176] = 'Circuit de Chocobo',
			[177] = 'Run Chocobo',
			[178] = 'Bustle of the Capital',
			[179] = 'Vanadiel March #4',
			[180] = 'Thunder of the March',
			[181] = 'Unknown',
			[182] = 'Stargazing',
			[183] = 'A Puppets Slumber',
			[184] = 'Eternal Gravestone',
			[185] = 'Ever-turning Wheels',
			[186] = 'Iron Colossus',
			[187] = 'Ragnarok',
			[188] = 'Choc-a-bye Baby',
			[189] = 'An Invisible Crown',
			[190] = 'The Sanctuary of ZiTah',
			[191] = 'Battle Theme #3',
			[192] = 'Battle in the Dungeon #3',
			[193] = 'Tough Battle #2',
			[194] = 'Bloody Promises',
			[195] = 'Belief',
			[196] = 'Fighters of the Crystal',
			[197] = 'To the Heavens',
			[198] = 'Ealdnarche',
			[199] = 'Graviton',
			[200] = 'Hidden Truths',
			[201] = 'End Theme',
			[202] = 'Moongate (Memoro)',
			[203] = 'Unknown',
			[204] = 'Unknown',
			[205] = 'Unknown',
			[206] = 'Unknown',
			[207] = 'VeLugannon Palace',
			[208] = 'Rabao',
			[209] = 'Norg',
			[210] = 'RuAun Gardens',
			[211] = 'RoMaeve',
			[212] = 'Dash de Chocobo',
			[213] = 'Hall of the Gods',
			[214] = 'Eternal Oath',
			[215] = 'Clash of Standards',
			[216] = 'On This Blade',
			[217] = 'Kindred Cry',
			[218] = 'Depths of the Soul',
			[219] = 'Onslaught',
			[220] = 'Turmoil',
			[221] = 'Moblin Menagerie',
			[222] = 'Faded Memories',
			[223] = 'March of the Hero',
			[224] = 'Dusk and Dawn',
			[225] = 'Words Unspoken',
			[226] = 'You Want to Live Forever',
			[227] = 'Sunbreeze Shuffle',
			[228] = 'Gates of Paradise',
			[229] = 'Currents of Time',
			[230] = 'A New Horizon',
			[231] = 'Celestial Thunder',
			[232] = 'The Ruler of the Skies',
			[233] = 'The Celestial Capital',
			[234] = 'Happily Ever After',
			[235] = 'Nocturne of the Gods',
			[236] = 'Clouded Dawn',
			[237] = 'Memoria de la Stona',
			[238] = 'A New Morning',
			[239] = 'Starlight Celebration',
			[240] = 'Distant Promises',
			[241] = 'A Time for Prayer',
			[242] = 'Unity',
			[243] = 'Unknown',
			[244] = 'Unknown',
			[245] = 'The Forgotten City',
			[246] = 'March of the Allied Forces',
			[247] = 'Roar of the Battle Drums',
			[248] = 'Young Griffons in Flight',
			[249] = 'Run maggot',
			[250] = 'Under a Clouded Moon',
			[251] = 'Autumn Footfalls',
			[252] = 'Flowers on the Battlefield',
			[253] = 'Echoes of a Zephyr',
			[254] = 'Griffons Never Die',
			
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
--	Merit points
--	---------------------------------------------------------------------------

function Decode.MeritPoints(Packet, PacketDisplay, RuleTable, Value)

	imgui.SetCursorPosX(imgui.GetCursorPosX()+10)

	local Ability = Decode.Merits[Value]

	imgui.TextColored( { 0.9, 0.9, 0.9, 1.0 }, ('0x%04X'):fmt(Value) )
	imgui.SameLine()
	
	if (nil ~= Ability) then
		imgui.TextColored( ETC.Green, ('%s'):fmt(Ability) )
	else
		imgui.TextColored( ETC.Red, ('UNKNOWN') )
	end
		
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

					if nil ~= RuleTable.Command and '@' == RuleTable.Command then

						--print(string.format('Cmd: %s, Table: %d, Off: %d', RuleTable.Command, RuleTable.TableID, RuleTable.CMDOpt1))
						imgui.SameLine()
						
						local XPos = 220 + RuleTable.CMDOpt1
						imgui.SetCursorPosX(XPos)
						imgui.TextColored( ETC.Yellow, ('%s'):fmt(ThisTable) )

					else
						--	Start of new line
						imgui.SetCursorPosX(imgui.GetCursorPosX()+10)
						imgui.TextColored( ETC.Yellow, ('%s'):fmt(ThisTable) )
					end
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

--	---------------------------------------------------------------------------
--	This converts a string into a table of words
--	---------------------------------------------------------------------------

function Decode.BuildWordList(Status, Words)

	local count		= 0
	local offset	= 1
	local index		= 0

	repeat

		index = string.find(Status, ' ', offset)

		if nil ~= index then

			part = ''

			for i=offset, (index - 1) do
				part = part .. Status[i]
			end

			count  = count + 1

			table.insert( Words , { index = count,
									text = part } )

			offset = index + 1

		end

	until nil == index

	--	We now have the last word to add

	part = ''

	repeat

		part = part .. Status[offset]
		offset = offset + 1

	until offset > string.len(Status)

	table.insert( Words , { index = count + 1,
							text = part } )

end

--	---------------------------------------------------------------------------
--	This decodes a status effect
--	---------------------------------------------------------------------------

function Decode.Status(PacketDisplay, RuleTable, Packet, value)

	local resource = AshitaCore:GetResourceManager():GetStatusIconById(value)

	if nil ~= resource then
	
		local Status = resource.Description[1]

		if imgui.CalcTextSize(Status) < 300 then

			imgui.SetCursorPosX(imgui.GetCursorPosX()+10)
			imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%s'):fmt(Status) )

		else

			--	Build a list of spaces

			local Used  = 0
			local Words = {}
			Decode.BuildWordList(Status, Words)

			local Try1 = ''
			local Try2 = ''

			repeat
				
				Try1 = Try2
				Try2 = Try2 .. ' ' .. Words[Used+1].text

				if imgui.CalcTextSize(Try2) > 300 then
					imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%s'):fmt(Try1) )
					Try1 = Words[Used+1].text
					Try2 = Words[Used+1].text
					imgui.SetCursorPosX(imgui.GetCursorPosX()+10)
				end

				Used = Used + 1

			until Used == #Words

			imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%s'):fmt(Try2) )

		end

	else

		--	We have no idea

		imgui.SetCursorPosX(imgui.GetCursorPosX()+10)
		imgui.TextColored(ETC.Red, ('UNKNOWN') )

	end

end

--	---------------------------------------------------------------------------
--	This decodes a song name
--	---------------------------------------------------------------------------

function Decode.Music(PacketDisplay, RuleTable, Packet, value)

	local OurTable	= Decode.Tables[8]		--	Table of music
	local Name		= 'Unknown'
	
	if nil ~= OurTable then
		for i, ThisTable in pairs(OurTable) do
			if i == math.floor(value) then
				Name = ThisTable
			end
		end
	end

	if imgui.CalcTextSize(Name) < 300 then

		imgui.SetCursorPosX(imgui.GetCursorPosX()+10)
		imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%s'):fmt(Name) )

	else

		--	Build a list of spaces

		local Used  = 0
		local Words = {}
		
		Decode.BuildWordList(Name, Words)

		local Try1 = ''
		local Try2 = ''

		repeat
			
			Try1 = Try2
			Try2 = Try2 .. ' ' .. Words[Used+1].text

			if imgui.CalcTextSize(Try2) > 300 then
				imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%s'):fmt(Try1) )
				Try1 = Words[Used+1].text
				Try2 = Words[Used+1].text
				imgui.SetCursorPosX(imgui.GetCursorPosX()+10)
			end

			Used = Used + 1

		until Used == #Words

		imgui.TextColored({ 0.9, 0.9, 0.9, 1.0 }, ('%s'):fmt(Try2) )

	end

end

return Decode
