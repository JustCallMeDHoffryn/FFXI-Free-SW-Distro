local AllRules = {

	--      CMD     {Offset    Format   Decode   Name  {Logic, Flag}  Table  Extra
	--                bit
	--                 #bits}

--	Standard Header -----------------------------------------------------------

[0xFFF] = {

	[1]  =  {  {},  {0},   'byte',    'raw',    'Packet ID'	},
	[2]  =  {  {},  {1},   'byte',    'psize',  'Data Size'	},
	[3]  =  {  {},  {2},   'rword',   'raw',    'Sync'	    },
	[4]  =  {  {'return' } },

	},	--	[[ COMPLETE ]]

--	Zone Out ------------------------------------------------------------------

[0x00B] = T{

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

	[1]  =  {  { 'call', 0xFFF }, 											},
	[2]  =	{  {}, {4},        'byte',    'raw',     'Data Size'			},
	[3]  =	{  {}, {5},        'rdword',  'entity',  'Actor'    			},
	[4]  =	{  {}, {9},        'byte',    'raw',     'Target Cnt'			},
	[5]  =	{  {}, {10,2,4},   'rword',   'bits',    'Category',   {},  1   },
	[6]  =	{  {}, {10,6,16},  'rword',   'bits',    'Action ID',  {},  2   },

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
	[13]  =	 {  {}, {41,5,3},  'byte',     'bits',    'Choco Flag', {'set', 1},  0,  'Chocobo Flag' 		},
	[14]  =	 {  {}, {43,5,3},  'byte',     'bits',    'GM Level',   },
	[15]  =	 {  {}, {44,0,12}, 'rword',    'bits',    'Speed', 		{'set', 1},  0,  'Speed' 				},
	[16]  =	 {  {}, {45,16},   'byte',     'bool',    'Bit Flag',	{'set', 1},  0,  'Wall Hack' 			},

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
	[13] =  {  { 'break' },          											},

	[14] =  {  { 'default' },	     											},
	[15] =	{  {}, {4},  'byte',   'raw',     'Mode (Var)'	      				},
	[16] =  {  { 'break' },          											},

	[17] =  {  { 'end' },          												},

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

--	Char Update ---------------------------------------------------------------

[0x0DF] = {

	[1]  =  {  { 'call', 0xFFF }, 							},
	[2]  =	{  {}, {4},   'rdword',  'raw',  'ID'           },
	[3]  =	{  {}, {8},   'rdword',  'raw',  'HP'           },
	[4]  =	{  {}, {12},  'rdword',  'raw',  'MP'           },
	[5]  =	{  {}, {16},  'rdword',  'raw',  'TP'           },
	[6]  =	{  {}, {20},  'rword',   'raw',  'Index'        },
	[7]  =	{  {}, {22},  'byte',    'raw',  ' HP %%'       },
	[8]  =	{  {}, {23},  'byte',    'raw',  ' MP %%'       },
	[9]  =	{  {}, {32},  'byte',    'job',  'Main Job'     },
	[10] =	{  {}, {33},  'byte',    'raw',  'Main Level'   },
	[11] =	{  {}, {34},  'byte',    'job',  'Sub Job'      },
	[12] =	{  {}, {35},  'byte',    'raw',  'Sub Level'    },

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

return AllRules
