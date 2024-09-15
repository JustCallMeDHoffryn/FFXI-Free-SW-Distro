local MyTable = T{

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

	}
	
return MyTable
