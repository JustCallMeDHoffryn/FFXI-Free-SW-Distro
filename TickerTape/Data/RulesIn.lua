
local NewRules = {

--	Standard Header -----------------------------------------------------------

[0xFFF] = {

	[1]		=	{ {},	{0},		'Packet ID',					},
	[2]		=	{ {},	{1,2,0,9},	'Data Size',	{ 'psize' },	},
	[3]		=	{ {},	{2, 2},		'Sync',							},
	[4]		=	{ {'return' } 										},

	},	--	[[ COMPLETE ]]
	
--	Zone In -------------------------------------------------------------------

[0x00A] = {

	[1]		=	{ { 'call', 0xFFF }, 									},
	[2]		=	{ {},  {4,4},			'Unique ID',					},
	[3]		=	{ {},  {8,2},			'Actor ID',		{'eid', 'raw'},	},
	[4]		=	{ {},  {0x00B},			'Direction',	{'dir'},	    },
	[5]		=	{ {},  {0x00C},			'Position',		{'xyz'},		},
	[6]		=	{ {},  {0x018,4},		'Flags_1',						},
	[7]		=	{ {},  {0x01C},			'Speed',						},
	[8]		=	{ {},  {0x01D},			'Base Speed',					},
	[9]		=	{ {},  {0x01E},			' HP %%',						},
	[10]	=	{ {},  {0x01F},			'Animation',					},
	[11]	=	{ {},  {0x020},			'Mount ID',						},

	[12]	=	{ {},  {0x021,1,7,1},	'Gender',						},
	[13]	=	{ {},  {0x021,1,0,3},	'Size',							},
	[14]	=	{ {},  {0x084,16},		'Name',			{'string'},		},

	[15]	=	{ {},  {0x030},			'Zone ID',		{'zone'},		},
	[16]	=	{ {},  {0x056,2},		'Music 1',		{'music'}, 		},
	[17]	=	{ {},  {0x058,2},		'Music 2',		{'music'}, 		},
	[18]	=	{ {},  {0x05A,2},		'Music 3',		{'music'}, 		},
	[19]	=	{ {},  {0x05C,2},		'Music 4',		{'music'}, 		},
	[20]	=	{ {},  {0x05E,2},		'Music 5',		{'music'}, 		},

	[21]	=	{ {},  {0x068,2},		'Weather',		{'weather'},	},
	[22]	=	{ {},  {0x06A,4},		'Weather Time',					},

	[23]	=	{ {},  {0x064,2},		'Event ID',						},
	[24]	=	{ {},  {0x066,2},		'Event Flags',					},

	[25]	=	{ {},  {0x080},			'Valid MH ID'					},
	[26]	=	{ {},  {0x0A8,2},		'MH Floor 2',					},
	[27]	=	{ {},  {0x0AA,2},		'MH Model ID',	{ 'house' }		},
	[28]	=	{ {},  {0x0AC},			'In CS',						},
	[29]	=	{ {},  {0x0AF},			'MH Menu Opts',					},

	[30]	=	{ {},  {0x0A0,4},		'Play Time',	{'time', 'raw'}	},

	},
	
}

local AllRules = {

--	Standard Header -----------------------------------------------------------

--	Zone Out ------------------------------------------------------------------

[0x00B] = {

	[1]  =  {  { 'call', 0xFFF }, 											},
	[2]   =	{  {},  {4},      'rdword',      'raw',  'Type',     			},
	[3]   =	{  {},  {8},      'byte', 	     'ip',   'Address',    			},
	[4]   =	{  {},  {12},     'rword',       'raw',  'Port',     			},

	},	--[[ COMPLETE ]]

--	NPC Update ----------------------------------------------------------------

[0x00E] = T{

	--	   	   Cmd	Offsets	  Format         Decode     Name            {Logic,flag} Table  Extra

	[1]   =	{  {},  {0},      'byte',        'raw',     'Packet ID',  },
	[2]   =	{  {},  {1},      'byte',        'raw',     'Size',       },
	[3]   =	{  {},  {2},      'rword',       'raw',     'Sync',       },
	[4]   =	{  {},  {4},      'rdword',      'entity',  'NPC ID',     },
	[5]   =	{  {},  {8},      'rword',       'raw',     'Index',      },
	[6]   =	{  {},  {10,1},   'bit',         'bool',    'Bit Flag',     {'set', 1},  0,  '[Position etc]' },
	[7]   =	{  {},  {10,2},   'bit',         'bool',    'Bit Flag',     {'set', 2},  0,  '[Claimer ID]' },
	[8]   =	{  {},  {10,4},   'bit',         'bool',    'Bit Flag',     {'set', 3},  0,  '[HP, Status]' },
	[9]   =	{  {},  {10,8},   'bit',         'bool',    'Bit Flag',     {'set', 4},  0,  '[Name]' },
	[10]  =	{  {},  {12},     '12bytes',     'xyz',     'Position',     {'use', 1} },
	[11]  =	{  {},  {11},     'byte',        'dir',     'Direction',    {'use', 1} },
	[12]  =	{  {},  {24},     'rword',       'raw',     'Walk Count',   {'use', 1} },
	[13]  =	{  {},  {28},     'byte',        'raw',     'Speed',        {'use', 1} },
	[14]  =	{  {},  {29},     'byte',        'raw',     'S-Speed',      {'use', 1} },
	[15]  =	{  {},  {44},     'rdword',      'player',  'Claimer',      {'use', 2} },
	[16]  =	{  {},  {30},     'byte',        'raw',     ' HP %%',       {'use', 3} },
	[17]  =	{  {},  {32},     'byte',        'raw',     'Status',       {'use', 3} },
	[18]  =	{  {},  {31},     'byte',        'raw',     'Animation',  },
	[19]  =	{  {},  {42},     'byte',        'raw',     'Anim Sub',   },
	[20]  =	{  {},  {41},     'byte',        'raw',     'Allegiance', },
	[21]  =	{  {},  {50},     'rword',       'raw',     'Model ID',   },

	},	--[[ COMPLETE ]]

--	Inventory Finished ----------------------------------------------------

[0x01D] = {

		[1]  =  {  { 'call', 0xFFF }, 										},
		[2]   =	{  {},  {5},   'byte', 	     'store',	'Bag', 				},
	
		},	--[[ COMPLETE ]]


--	Item Assign ---------------------------------------------------------------

[0x01F] = {

	[1] =   {	{ 'call', 0xFFF }, 							   			},
	[2] =   {	{},  {4},   	'rdword',	'raw', 		'Quantity'		},
	[3] =   {	{},  {8},   	'rword',	'item',    	'Item (ID)'		},
	[4] =   {   {},  {0x0A},	'byte', 	'store',	'Bag', 			},
	[5] =   {   {},  {0x0B},	'byte',		'raw',  	'Index', 		},
	[6] =   {   {},  {0x0C},	'byte',		'raw',  	'Flag', 		},

	},	--	[[ COMPLETE ]]

--	Item Update -----------------------------------------------------------

[0x020] = {

	[1]  =  {  { 'call', 0xFFF }, 											},
	[2]   =	{  {},  {4},      'rdword',      'raw',  	'Count',     		},
	[3]   =	{  {},  {8},      'rdword',      'raw',  	'Bazaar GIL', 		},
	[4]   =	{  {},  {0x0C},   'rword', 	     'item', 	'Item (ID)', 		},
	[5]   =	{  {},  {0x0E},   'byte', 	     'store',	'Bag', 				},
	[6]   =	{  {},  {0x0F},   'byte', 	     'raw',  	'Index', 			},

	},	--[[ COMPLETE ]]

--	NPC Action ----------------------------------------------------------------

[0x028] = {

	[1]  =  {  { 'call', 0xFFF },													},
	[2]  =	{  {}, {4},        'byte',    'raw',     'Data Size'					},
	[3]  =	{  {}, {5},        'rdword',  'entity',  'Actor'						},
	[4]  =	{  {}, {9},        'byte',    'raw',     'Target Cnt'					},
	[5]  =	{  {}, {10,2,4},   'rdword',  'bits',    'Category',  {'set', 1},  1	},

	[6]  =  {  { 'fswitch', 1 },													},

	[7]  =  {  { 'case', 1 },	     											},
	[8]  =	{  {}, {0x24},   'rword',   'info',    'Type', 		{},  0,	'Mode 1' },
	[9]  =  {  { 'break' }, },  

	[10] =  {  { 'case', 4 },	     											},
	[11] =	{  {}, {10,6,10}, 'rdword',  'bits',    'Spell', 	},
	[12]  =  {  { 'break' }, },  

	[13] =  {  { 'case', 8 },	     											},
	[14] =	{  {}, {0x24},   'rword',   'info',    'Type', 		{},  0,	'Mode 8' },
	[15]  =  {  { 'break' }, },  
	
	--[7]  =	{  {}, {10,6,16},  'rdword',   'bits',    'Action ID',  {},  2  },

	[16] =  {  { 'end' },          												},

	},	--	PART - Needs flag decode

--	Action Message ------------------------------------------------------------

[0x029] = {

	[1]  =  {  { 'call', 0xFFF }, 											},
	[2]  =	{  {}, {4},   'rword',     'eid',     'Actor'                   },
	[3]  =	{  {}, {8},   'rword',     'eid',     'Target'                  },
	[4]  =	{  {}, {12},  'rdword',    'raw',     'Param 1'                 },
	[5]  =	{  {}, {16},  'rdword',    'raw',     'Param 2'                 },
	[6]  =	{  {}, {20},  'rword',     'raw',     'Actor Index'             },
	[7]  =	{  {}, {22},  'rword',     'raw',     'Target Index'            },
	[8]  =	{  {}, {22},  'rword',     'raw',     'Message'                 },

	},	--[[ COMPLETE ]]

--	Update Char ---------------------------------------------------------------

[0x037] = {

	[1]   =  {  { 'call', 0xFFF }, 											},
	[2]   =	 {  {}, {36},      'rword',    'player',  'Player ID'	 },
	[3]   =	 {  {}, {42},      'byte',     'raw',     ' HP %%'       },
	[4]   =	 {  {}, {40,1},    'byte',     'bool',    'Bit Flag',   {'set', 1},  0,  'Hide Flag'  			},
	[5]   =	 {  {}, {40,2},    'byte',     'bool',    'Bit Flag',   {'set', 1},  0,  'Sleep Flag' 			},
	[6]   =	 {  {}, {40,4},    'byte',     'bool',    'Bit Flag',   {'set', 1},  0,  'Ground Flag'			},
	[7]   =	 {  {}, {40,8},    'byte',     'bool',    'Bit Flag',   {'set', 1},  0,  'CLI Pos Init Flag'   	},
	[8]   =	 {  {}, {40,16},   'byte',     'bool',    'Bit Flag',   {'set', 1},  0,  'LFG Flag'   			},
	[9]   =	 {  {}, {40,32},   'byte',     'bool',    'Bit Flag',   {'set', 1},  0,  'Anonymous Flag'  		},
	[10]  =	 {  {}, {40,64},   'byte',     'bool',    'Bit Flag',   {'set', 1},  0,  'CFH Flag'   			},
	[11]  =	 {  {}, {40,128},  'byte',     'bool',    'Bit Flag',   {'set', 1},  0,  'Away Flag'  			},
	[12]  =	 {  {}, {41,1},    'byte',     'bool',    'Bit Flag',   {'set', 1},  0,  'Gender Flag'  		},
	[13]  =	 {  {}, {41,5,3},  'byte',     'bits',    'Choco Index'	},
	[14]  =	 {  {}, {91},      'byte',     'raw',     'Mount ID'    },
	[15]  =	 {  {}, {43,5,3},  'byte',     'bits',    'GM Level',   },
	[16]  =	 {  {}, {44,0,12}, 'rword',    'bits',    'Speed', 		},
	[17]  =	 {  {}, {45,16},   'byte',     'bool',    'Bit Flag',	{'set', 1},  0,  'Wall Hack' 			},

	},

--	Job Info Extra ------------------------------------------------------------

[0x044] = {

	[1]  =  {  { 'call', 0xFFF }, 												},

	[2]  =  {  { 'switch', 4, 1},										    	},

	[3]  =  {  { 'case', 16 },	     											},
	[4]  =	{  {}, {4},  'byte',   'raw',     'Mode (BLU)'          			},

	[5]  =  {  { 'loop', 20, 1, 0 },                        					},
	[6]  =	{  { 'ifnot', 0 },  {8},  'byte',    'bluspell',    'BLU Spell'		},
	[7]  =  {  { 'end' },                                   					},

	[8]  =  {  { 'break' },          											},

	[9]  =  {  { 'case', 18 },	     											},
	[10] =	{  {}, {4},  'byte',   'raw',     'Mode (PUP)'          			},
	[11]  =	{  { '@', 100 }, {8},  'byte',    'raw',     'Puppet Head',  {},  5 },
	[12]  =	{  { '@', 100 }, {9},  'byte',    'raw',     'Puppet Body',  {},  6 },

	[13]  = {  { 'loop', 12, 1, 0 },                        					},
	[14]  =	{  { 'ifnot', 0 },  {10}, 'byte', 'attach',    'Attachment'			},
	[15]  = {  { 'end' },                                   					},

	[16] =  {  { 'break' },          											},

	[17] =  {  { 'default' },	     											},
	[18] =	{  {}, {4},  'byte',   'raw',     'Mode (Var)'	      				},
	[19] =  {  { 'break' },          											},

	[20] =  {  { 'end' },          												},

	},

--	Auction House Menu --------------------------------------------------------

[0x04C] = {

	[1]  = { { 'call', 0xFFF }, 							    		},
	[2]  = { {},  {4},  'byte',		'raw',		'Command'				},
	[3]  = { {},  {5},  'byte',		'raw',		'AucWorkIndex'			},
	[4]  = { {},  {6},  'byte',		'raw',		'Result'				},
	[5]  = { {},  {7},  'byte',		'raw',		'ResultStatus'			},

	},

--	Quest / Mission Log -------------------------------------------------------

[0x056] = {

	[1]  =  {  { 'call', 0xFFF }, 													},

	[2]  =  {  { 'switch', 0x24, 2},										    		},

	[3]  =  {  { 'case', 0xFFFF },	     												},
	[4]  =	{  {}, {0x24},   'rword',   'info',    'Type', 		{},  0,	'Current Mission' },
	[5]  =  {  { 'break' },          											},

	[6]  =  {  { 'case', 0x00D0 },	     												},
	[7]  =	{  {}, {0x24},   'rword',   'info',    'Type', 		{},  0,	'Completed Mission' },
	[8]  =  {  { 'break' },          											},

	[9]  =  {  { 'case', 0x0080 },	     												},
	[10]  =	{  {}, {0x24},   'rword',   'info',    'Type', 		{},  0,	'Active ToaU/WotG Mission' },
	[11] =  {  { 'break' },          											},

	[12] =  {  { 'case', 0x00D8 },	     												},
	[13]  =	{  {}, {0x24},   'rword',   'info',    'Type', 		{},  0,	'Completed ToaU/WotG Mission' },
	[14] =  {  { 'break' },          											},

	[15] =  {  { 'case', 0x00C0 },	     												},
	[16]  =	{  {}, {0x24},   'rword',   'info',    'Type', 		{},  0,	'Completed Assault Mission' },
	[17] =  {  { 'break' },          											},

	[18] =  {  { 'case', 0x0030 },	     												},
	[19]  =	{  {}, {0x24},   'rword',   'info',    'Type', 		{},  0,	'Campaign - One' },
	[20] =  {  { 'break' },          											},

	[21] =  {  { 'case', 0x0038 },	     												},
	[22]  =	{  {}, {0x24},   'rword',   'info',    'Type', 		{},  0,	'Campaign - Two' },
	[23] =  {  { 'break' },          											},

	[24]  =  {  { 'default' },	     											},
	[25]  =	{  {}, {0x24},   'rword',   'info',    'Type', 		{},  0,	'General Missions' },
	[26]  =  {  { 'break' },          											},

	[27]  =  {  { 'end' },          												},

	},
	
--	Weather Change ------------------------------------------------------------

[0x057] = {

	[1]  =  {  { 'call', 0xFFF }, 											},
	[2]  =	{  {}, {-1},   'byte',   'info',    'ERROR', 		{},  0,	'This date seems to be wrong' },
	[3]  =	{  {}, {4},   'rdword',  'vdate',   'Change Time'             },
	[4]  =	{  {}, {8},   'rword',   'raw',     'New Weather',  {},  4    },
	[5]  =	{  {}, {10},  'rword',   'raw',     'Transition'              },

	},	--[[ COMPLETE ]]

--	Lock Target ---------------------------------------------------------------

[0x058] = {

	[1]  =  {  { 'call', 0xFFF }, 											},
	[2]  =	{  {}, {4},   'rdword',    'eid',     'ID'                      },
	[3]  =	{  {}, {12},  'rword',     'raw',     'Index'                   },
	[4]  =	{  {}, {8},   'rdword',    'entity',  'Target ID'               },
	[5]  =	{  {}, {14},  'rword',     'raw',     'Target Index'            },

	},	--[[ COMPLETE ]]

--	Skills Update -------------------------------------------------------------

[0x062] = {

	[1]  =  {  { 'call', 0xFFF }, 									},

	[2]  =	{  {}, {-1},   'byte',   'info',    'WEAPONS', 		{},  0,	'Values >= 0x8000 Are Capped' },

	[3]  =	{  {}, {0x82},  'rword',  'raw',     'H-2-H'            	},
	[4]  =	{  {}, {0x84},  'rword',  'raw',     'Dagger' 	        },
	[5]  =	{  {}, {0x86},  'rword',  'raw',     'Sword'		        },
	[6]  =	{  {}, {0x88},  'rword',  'raw',     'G-Sword'           },
	[7]  =	{  {}, {0x8A},  'rword',  'raw',     'Axe'		        },
	[8]  =	{  {}, {0x8C},  'rword',  'raw',     'G-Axe' 		    },
	[9]  =	{  {}, {0x8E},  'rword',  'raw',     'Scythe'            },
	[10] =	{  {}, {0x90},  'rword',  'raw',     'Polearm'           },
	[11] =	{  {}, {0x92},  'rword',  'raw',     'Katana'            },
	[12] =	{  {}, {0x94},  'rword',  'raw',     'G-Katana'          },
	[13] =	{  {}, {0x96},  'rword',  'raw',     'Club'            	},
	[14] =	{  {}, {0x98},  'rword',  'raw',     'Staff'           	},

	[15] =	{  {}, {-1},   'byte',   'info',    'PUPPETS', 		{},  0,	'Values >= 0x8000 Are Capped' },

	[16] =	{  {}, {0xAC},  'rword',  'raw',     'Auto Melee'     	},
	[17] =	{  {}, {0xAE},  'rword',  'raw',     'Auto Ranged'     	},
	[18] =	{  {}, {0xB0},  'rword',  'raw',     'Auto Magic'      	},

	[19] =	{  {}, {-1},    'byte',   'info',    'SKILLS', 		{},  0,	'Values >= 0x8000 Are Capped' },

	[20] =	{  {}, {0xB2},  'rword',  'raw',     'Archery'      	},
	[21] =	{  {}, {0xB4},  'rword',  'raw',     'Marksmanship'    	},
	[22] =	{  {}, {0xB6},  'rword',  'raw',     'Throwing'      	},
	[23] =	{  {}, {0xB8},  'rword',  'raw',     'Guarding'      	},
	[24] =	{  {}, {0xBA},  'rword',  'raw',     'Evasion'      	},
	[25] =	{  {}, {0xBC},  'rword',  'raw',     'Shield'      		},
	[26] =	{  {}, {0xBE},  'rword',  'raw',     'Parrying'      	},
	[27] =	{  {}, {0xC0},  'rword',  'raw',     'Divine'      		},

	[28] =	{  {}, {-1},   'byte',   'info',     'MAGIC', 		{},  0,	'Values >= 0x8000 Are Capped' },

	[29] =	{  {}, {0xC2},  'rword',  'raw',     'Healing'      	},
	[30] =	{  {}, {0xC4},  'rword',  'raw',     'Enhancing'      	},
	[31] =	{  {}, {0xC6},  'rword',  'raw',     'Enfeebling'      	},
	[32] =	{  {}, {0xC8},  'rword',  'raw',     'Elemental'      	},
	[33] =	{  {}, {0xCA},  'rword',  'raw',     'Dark'      		},
	[34] =	{  {}, {0xCC},  'rword',  'raw',     'Summoning'      	},
	[35] =	{  {}, {0xCE},  'rword',  'raw',     'Ninjutsu'      	},
	[36] =	{  {}, {0xD6},  'rword',  'raw',     'Blue'      		},

	[37] =	{  {}, {-1},   'byte',   'info',     'MUSIC', 		{},  0,	'Values >= 0x8000 Are Capped' },

	[38] =	{  {}, {0xD0},  'rword',  'raw',     'Singing'      	},
	[39] =	{  {}, {0xD2},  'rword',  'raw',     'String'      		},
	[40] =	{  {}, {0xD4},  'rword',  'raw',     'Wind'      		},

	[41] =	{  {}, {-1},   'byte',   'info',     'CRAFT', 		{},  0,	'Contains Cap / Rank / Level' },

	[42] =	{  {}, {0xE0},  'rword',  'craft',   'Fishing'      	},
	[43] =	{  {}, {0xE2},  'rword',  'craft',   'Woodworking'      },
	[44] =	{  {}, {0xE4},  'rword',  'craft',   'Smithing'      	},
	[45] =	{  {}, {0xE6},  'rword',  'craft',   'Goldsmithing'     },
	[46] =	{  {}, {0xE8},  'rword',  'craft',   'Clothcraft'      	},
	[47] =	{  {}, {0xEA},  'rword',  'craft',   'Leathercraft'     },
	[48] =	{  {}, {0xEC},  'rword',  'craft',   'Bonecraft'      	},
	[49] =	{  {}, {0xEE},  'rword',  'craft',   'Alchemy'      	},
	[50] =	{  {}, {0xF0},  'rword',  'craft',   'Cooking'      	},

	[51] =	{  {}, {-1},   'byte',   'info',     'MISC', 		{},  0,	'Values >= 0x8000 are capped' },

	[52] =	{  {}, {0xF2},  'rword',  'raw',     'Synergy'      	},
	[53] =	{  {}, {0xF4},  'rword',  'raw',     'Riding'      		},

	},	--[[ COMPLETE ]]


--	Job Info Extra ------------------------------------------------------------

[0x063] = {

	[1]  =  {  { 'call', 0xFFF }, 													},

	[2]  =  {  { 'switch', 4, 1},										    		},

	[3]  =  {  { 'case', 2 },										    		},
	[4]  =	{  {}, {-1},   'byte',   'info',     'Mode', 		{},  0,	'Merits' 	},
	[5]  =  {  { 'break', },										    			},

	[6]  =  {  { 'case', 3 },										    		},
	[7]  =	{  {}, {-1},   'byte',   'info',     'Mode', 		{},  0,	'Monstrosity 1' 	},
	[8]  =  {  { 'break', },										    			},

	[9]  =  {  { 'case', 4 },										    		},
	[10]  =	{  {}, {-1},   'byte',   'info',     'Mode', 		{},  0,	'Monstrosity 2' 	},
	[11]  =  {  { 'break', },										    			},

	[12]  =  {  { 'case', 5 },										    		},
	[13]  =	{  {}, {-1},   'byte',   'info',     'Mode', 		{},  0,	'Job Points' 	},
	[14]  =  {  { 'break', },										    			},

	[15]  =  {  { 'case', 6 },										    		},
	[16]  =	{  {}, {-1},   'byte',   'info',     'Mode', 		{},  0,	'Homepoints' 	},
	[17]  =  {  { 'break', },										    			},

	[18]  =  {  { 'case', 7 },										    		},
	[19]  =	{  {}, {-1},   'byte',   'info',     'Mode', 		{},  0,	'Unity' 	},
	[20]  =  {  { 'break', },										    			},

	--	Status Icons ---------------------------------------------------------------

	[21] = { { 'case', 9 },										    		},
	[22] = { {}, {-1},   'byte',   'info',     'Mode', 		{},  0,	'Status Icons' 	},

	[23]  = {  { 'loop', 32, -1, 0 },                        					},
	[24]  =	{  { 'ifnot', 255 },  {0x08},      'rword',  'status',  'Status'		},
	[25]  =	{  { 'ifnot', 0 },    {0x48},      'rdword', 'time',    	'Expires'		},
	[26]  = {  { 'end' },                                   					},

	[27] = { { 'break', },										    			},

	[28]  =  {  { 'case', 10 },										    		},
	[29]  =	{  {}, {-1},   'byte',   'info',     'Mode', 		{},  0,	'Unknown' 	},
	[30]  =  {  { 'break', },										    			},

	[31]  =  {  { 'default', 2 },										    		},
	[32]  =	{  {}, {-1},   'byte',   'info',     'Mode', 		{},  0,	'Invalid' 	},
	[33]  =  {  { 'break', },										    			},

	[34]  =  {  { 'end' },										    				},

},

--	Job Info Extra ------------------------------------------------------------

[0x067] = {

	[1]  =  {  { 'call', 0xFFF }, 													},

	[2]  =  {  { 'switch', 4, 1},										    		},

	[3]  =  {  { 'case', 2 },	     												},
	[4]  =	{  {}, {4},  		'byte',   	'raw',     'Mode (Player)'          	},
	[5]  =	{  {}, {6},  		'rword',  	'raw',     'Target ID' 	         		},
	[6]  =	{  {}, {8},  		'rdword', 	'raw',     'Player ID' 	         		},
	[7]  =	{  {}, {0x0c},  	'rword',  	'raw',     'Fellow ID' 	         		},
	[8]  =	{  {}, {0x10,4},	'byte',   	'bool',    'Bit Flag',   {'set', 1},  0,  'Level Sync' 	},
	[9]  =	{  {}, {0x26},  	'byte',   	'raw',     'Lvl Restrict' 		   		},
	[10]  =	{  {}, {0x13}, 		'rword',  	'raw',     'Mount Sub'     				},
	[11]  =	{  {}, {0x18}, 		'rdword', 	'raw',     'Field Choco'   	  			},

	[12]  =	 { {}, {0x18,0,3},  'rdword',   'bits',    'Choco Head'				},
	[13]  =	 { {}, {0x18,3,3},  'rdword',   'bits',    'Choco Feet'				},
	[14]  =	 { {}, {0x18,6,3},  'rdword',   'bits',    'Choco Tail'				},
	[15]  =	 { {}, {0x18,9,3},  'rdword',   'bits',    'Choco Colour'			},

	[16]  =	{  {}, {0x27}, 		'byte', 	'raw',     'Floor Change'  	  		},
	[17]  =  {  { 'break' },          											},

	[18]  =  {  { 'case', 3 },	     											},
	[19]  =	{  {}, {4},  'byte',   'raw',     'Mode (NPC)'          			},
	[20]  =  {  { 'break' },          											},

	[21]  =  {  { 'case', 4 },	     											},
	[22]  =	{  {}, {4},  'byte',   'raw',     'Mode (Pet)'          			},
	[23]  =  {  { 'break' },          											},

	[24]  =  {  { 'default' },	     											},
	[25]  =	{  {}, {4},  'byte',   'raw',     'Mode (???)'		   				},
	[26]  =  {  { 'break' },          											},

	[27]  =  {  { 'end' },          												},

	},

--	Pet Status ----------------------------------------------------------------

[0x068] = {

	[1]  =  {  { 'call', 0xFFF }, 									},
	[2]  =	{  {}, {4,0,6},    'rword',    'bits',    'Type'		},
	[3]  =	{  {}, {4,6,10},   'rword',    'bits',    'Length'		},
	[4]  =	{  {}, {6},        'rword',    'player',  'Owner Index'	},
	[5]  =	{  {}, {8},        'rword',    'player',  'Owner ID'	},
	[6]  =	{  {}, {12},       'rword',    'raw',     'Pet Index'	},
	[7]  =	{  {}, {14},       'byte',     'raw',     ' HP %%'		},
	[8]  =	{  {}, {15},       'byte',     'raw',     ' HP %%'		},
	[9]  =	{  {}, {16},       'rword',    'raw',     'TP'			},
	[10] =	{  {}, {20},       'rdword',   'entity',  'Target ID'	},
	[11] =	{  {}, {24},       'byte',     'string',  'Pet Name'	},

	},	--	[[ COMPLETE ]]

--	Job Points ----------------------------------------------------------------

[0x08D] = {

	[1]  =  {  { 'call', 0xFFF }, 									},
	[2] =   {  { 'loop', 10, 4, 0 },                		        },
	[3]  =	{  {}, {4},    'rdword',  'jpoint',  'Job Point'	    },
	[4] =   {  { 'end' },                                   		},
	[5] =   {  { 'loop', 10, 4, 0 },                		        },
	[6]  =	{  {}, {0x54}, 'rdword',  'jpoint',  'Job Point'	    },
	[7] =   {  { 'end' },                                   		},

	},	--	[[ COMPLETE ]]

--	Merits --------------------------------------------------------------------

[0x08C] = {

	[1]  =  {  { 'call', 0xFFF }, 										},
	[2]  =	{  {}, {0x04}, 'rword',  'raw',  'Point Count'	    		},
	[3]  =  {  { 'loop', 31, 4, 0 },                		        	},
	[4]  =	{  {}, {0x08}, 'rword',  'merit', 	'Merit ID'	    		},
	[5]  =	{  { 'ifnot', 0 }, {0x0B}, 'byte',   'raw', 	'Level'	    },
	[6]  =	{  { 'ifnot', 0 }, {0x0A}, 'byte',   'raw', 	'Next'	    },
	[7]  =  {  { 'end' },                                   			},

	},	--	[[ COMPLETE ]]

--	Mount List ----------------------------------------------------------------

[0x0AE] = {

	[1]  =  {  { 'call', 0xFFF }, 										},

	[2]  =	 { {}, {0x04,1},   'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Chocobo'		},
	[3]  =	 { {}, {0x04,2},   'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Raptor'			},
	[4]  =	 { {}, {0x04,4},   'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Tiger'			},
	[5]  =	 { {}, {0x04,8},   'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Crab'			},
	[6]  =	 { {}, {0x04,16},  'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Red Crab'		},
	[7]  =	 { {}, {0x04,32},  'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Bomb'			},
	[8]  =	 { {}, {0x04,64},  'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Sheep'			},
	[9]  =	 { {}, {0x04,128}, 'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Morbol'			},

	[10] =	 { {}, {0x05,1},   'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Crawler'		},
	[11] =	 { {}, {0x05,2},   'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Fenrir'			},
	[12] =	 { {}, {0x05,4},   'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Beetle'			},
	[13] =	 { {}, {0x05,8},   'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Moogle'			},
	[14] =	 { {}, {0x05,16},  'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Magic Pot'		},
	[15] =	 { {}, {0x05,32},  'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Tulfaire'		},
	[16] =	 { {}, {0x05,64},  'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Warmachine'		},
	[17] =	 { {}, {0x05,128}, 'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Xzomit'			},

	[18] =	 { {}, {0x06,1},   'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Hippogryph'		},
	[19] =	 { {}, {0x06,2},   'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Spectral Chair'	},
	[20] =	 { {}, {0x06,4},   'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Spheroid'		},
	[21] =	 { {}, {0x06,8},   'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Omega'			},
	[22] =	 { {}, {0x06,16},  'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Coeurl'			},
	[23] =	 { {}, {0x06,32},  'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Goobbue'		},
	[24] =	 { {}, {0x06,64},  'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Raaz'			},
	[25] =	 { {}, {0x06,128}, 'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Levitus'		},

	[26] =	 { {}, {0x07,1},   'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Adamantoise'	},
	[27] =	 { {}, {0x07,2},   'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Dhalmel'		},
	[28] =	 { {}, {0x07,4},   'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Doll'			},
	[29] =	 { {}, {0x07,8},   'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Golden Bomb'	},
	[30] =	 { {}, {0x07,16},  'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Buffalo'		},
	[31] =	 { {}, {0x07,32},  'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Wivre'			},
	[32] =	 { {}, {0x07,64},  'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Red Raptor'		},
	[33] =	 { {}, {0x07,128}, 'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Iron Giant'		},

	[34] =	 { {}, {0x08,1},   'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Byakko'			},
	[35] =	 { {}, {0x08,2},   'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Noble Chocobo'	},
	[36] =	 { {}, {0x08,4},   'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Ixion'			},
	[37] =	 { {}, {0x08,8},   'byte',  'bool',  'Bit Flag',  {'set', 1},  0,  'Phuabo'			},

	},	--	[[ COMPLETE ]]

--	Char Update ---------------------------------------------------------------

[0x0DF] = {

	[1]  =  {  { 'call', 0xFFF }, 								},
	[2]  =	{  {}, {4},   	'rdword',  'raw',  	'ID'           	},
	[3]  =	{  {}, {8},   	'rdword',  'raw',  	'HP'           	},
	[4]  =	{  {}, {12},  	'rdword',  'raw',  	'MP'           	},
	[5]  =	{  {}, {16},  	'rdword',  'raw',  	'TP'           	},
	[6]  =	{  {}, {20},  	'rword',   'raw',  	'Index'        	},
	[7]  =	{  {}, {22},  	'byte',    'raw',  	' HP %%'       	},
	[8]  =	{  {}, {23},  	'byte',    'raw',  	' MP %%'       	},
	[9]  =	{  {}, {32},  	'byte',    'job',  	'Main Job'     	},
	[10] =	{  {}, {33},  	'byte',    'raw',  	'Main Level'   	},
	[11] =	{  {}, {34},  	'byte',    'job',  	'Sub Job'      	},
	[12] =	{  {}, {35},   	'byte',    'raw',  	'Sub Level'    	},
	[13] =	{  {}, {0x25,1},'byte',    'bool',	'Bit Flag',  {'set', 1},  0,  'Job Mastery Unlocked'	},
	[14] =	{  {}, {0x25,2},'byte',    'bool',	'Bit Flag',  {'set', 1},  0,  'This Job Capped'			},
	[15] =	{  {}, {0x24}, 	'byte',    'raw',  	'Master Level' 	},

	},	--	[[ COMPLETE ]]

--	Ability Recasts -----------------------------------------------------------

[0x119] = {

	[1] =   {  { 'call', 0xFFF }, 							},
	[2] =   {  { 'loop', 30, 8, 0 },                        },
	[3] =	{  {},  {15},  'byte',    'raw',    'Ability',	{},  3,  '' },
	[4] =	{  {},  {12},  'rword',   'raw',    'Timer'		},
	[5] =   {  { 'end' },                                   },

},	--	[[ COMPLETE ]]

}

return NewRules
