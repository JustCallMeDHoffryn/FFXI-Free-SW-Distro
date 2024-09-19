
local NewRules = {

--	Decode EID and Entity (from 0x1A) -----------------------------------------

[0xFFE] = {

	[1]		=	{ {},	{4, 4},	'Target ID',	{'entity', 'raw'}	},
	[2]		=	{ {},	{8, 2},	'Target Index',	{'eid',    'raw'}	},
	[3]		=	{ {'return' } },

	},	--	[[ COMPLETE ]]

--	Standard Header -----------------------------------------------------------

[0xFFF] = {

	[1]		=	{ {},	{0},		'Packet ID',					},
	[2]		=	{ {},	{1,1,1,7},	'Data Size',	{ 'psize' },	},
	[3]		=	{ {},	{2, 2},		'Sync',							},
	[4]		=	{ {'return' } 										},

	},	--	[[ COMPLETE ]]

--	Client Connect ------------------------------------------------------------

[0x00A] = {

	[1]		=	{ { 'call', 0xFFF },							},
	[2]		=	{ {},  {34, 15},	'Name',		{ 'string' },	},
	[3]		=	{ {},  {49, 15},	'Account',	{ 'string' },	},
	[4]		=	{ {},  {80, 4},		'Version'					},
	[5]		=	{ {},  {84, 4},		'Platform',	{ 'string' },	},
	[6]		=	{ {},  {88, 2},		'Language'					},

	},	--	[[ COMPLETE ]]

--	Zone In 1 -----------------------------------------------------------------

[0x00C] = {

	[1]		=	{{ 'call', 0xFFF } },
	[2]		=	{ {},  {4,4},	'Client State'	},
	[3]		=	{ {},  {8,4},	'Debug State'	},

	},	--	[[ COMPLETE ]]

--	Client Leave --------------------------------------------------------------

[0x00D] = {

	[1]		=   { { 'call', 0xFFF } },
	[2]		=	{ {}, {-1},   'INFO', {'info'},  {}, 'There is no data in this packet' },
	[3]		=	{ {}, {-1},   'INFO', {'info'},  {}, 'that is used by the server' },

	},	--	[[ COMPLETE ]]

--	Zone In 2 -----------------------------------------------------------------

[0x00F] = {

	[1]		=   {{ 'call', 0xFFF } },
	[2]		=	{ {}, {-1},   'INFO', {'info'},	{}, 'The status flags can be used by'   },
	[3]		=	{ {}, {-1},   'INFO', {'info'},	{}, 'the client if in a race condition' },
	[4]		=	{ { 'loop', 8, 4, 0 } },
	[5]		=	{ {},  {4,4},  'Status Flag'	},
	[6]		=	{ { 'end' } },

	},	--	[[ COMPLETE ]]

--	Zone In 3 -----------------------------------------------------------------

[0x011] = {

	[1]		=   { { 'call', 0xFFF } },
	[2]		=	{ {}, {-1},   'INFO', {'info'},	{},  'There is no data in this packet' },
	[3]		=	{ {}, {-1},   'INFO', {'info'},	{},  'that is used by the server' },

	},	--	[[ COMPLETE ]]
	
--	Standard Client -----------------------------------------------------------

[0x015] = {

	[1] 	=   { { 'call', 0xFFF } },
	[2]		=	{ {},		{4},  			'Position',			{ 'xyz'   },			},
	[3]		=	{ {},		{0x14},			'Direction',		{ 'dir'   },			},
	[4]		=	{ {},		{0x12},			'Run Count',								},
	[5]		=	{ {},		{0x16, 2},		'Target ID',		{ 'eid', 	'raw' },	},
	[6]		=	{ {},		{0x18, 4},		'Timestamp',		{ 'mstime', 'raw' },	},

	},	--	[[ COMPLETE ]]

--	Update Request ------------------------------------------------------------

[0x016] = {

	[1]		=   { { 'call', 0xFFF } },
	[2]		=	{ {},  {4, 2}, 'Actor ID', {'eid'}	},

	},	--	[[ COMPLETE ]]

--	NPC Race Error ------------------------------------------------------------

[0x017] = {

	[1]		=   { { 'call', 0xFFF } },
	[2]		=   { {},  {4,2}, 	'Actor ID',	{'eid'}  		},
	[3]		=   { {},  {8,4}, 	'Unique No 2' },
	[4]		=   { {},  {12,4},	'Unique No 3' },
	[5]		=   { {},  {16,2},	'Flag'   },
	[6]		=   { {},  {18,2},	'Flag 2' },

	},	--	[[ COMPLETE ]]


--	Action	-------------------------------------------------------------------

[0x01A] = {

	[1]		=	{ { 'call', 0xFFF } },
	[2]		=	{ {},  {10},  'Action Type',	{'action'} 	},

	[3]		=	{ { 'switch', 0x0A, 1} },

	[4]		=	{ { 'case', 0x03 } },
	[5]		=	{ { 'call', 0xFFE } },
	[6]		=	{ {}, {12,2}, 'Spell ID', {'spell'} },
	[7]		=	{ { 'break' } },

	[8]		=	{  { 'case', 0x1A } },
	[9]		=	{  {}, {0x1A},   'Mode (Mounts)'    },
	[10]	=	{  {}, {0x0C,2}, 'Type',  {'mount'}	},
	[11]	=	{  { 'break' } },

	[12]	=	{ { 'case', 0x00  } },	--	Deliberate drop through
	[13]	=	{ { 'case', 0x02  } },
	[14]	=	{ { 'case', 0x05  } },
	[15]	=	{ { 'case', 0x0C  } },
	[16]	=	{ { 'case', 0x0D  } },
	[17]	=	{ { 'case', 0x0F  } },
	[18]	=	{ { 'case', 0x10  } },
	[19]	=	{ { 'case', 0x13  } },
	[20]	=	{ { 'case', 0x14  } },
	[21]	=	{ { 'call', 0xFFE } },
	[22]	=	{ { 'break' } },

	[23]	=	{ { 'case', 0x07  } },
	[24]	=	{ { 'call', 0xFFE } },
	[25]	=	{ {}, {12, 2}, 'WS ID',	{'wskill'} },
	[26]	=	{ { 'break' } },

	[27]	=	{ { 'case', 0x09 }  },
	[28]	=	{ { 'call', 0xFFE } },
	[29]	=	{ {}, {12,2}, 'JA ID',  {'ability'} },
	[30]	=	{ { 'break' } },

	[31]	=	{ { 'end' } },

	},

--	Drop Item -----------------------------------------------------------------

[0x028] = {

	[1]		=   { { 'call', 0xFFF }, 							},
	[2]		=   { {},  {4,4}, 		'Item Count'				},
	[3]		=   { {},  {8}, 		'Container',	{'store'}	},
	[4]		=   { {},  {9}, 		'Item Index'				},

	},	--	[[ COMPLETE ]]

--	Move Item -----------------------------------------------------------------

[0x029] = {

	[1]		=   { { 'call', 0xFFF }, 								},
	[2] 	=   { {},  {4,4},  		'Item Count'					},
	[3] 	=   { {},  {8},  		'Src Container',	{'store'}	},
	[4] 	=   { {},  {10}, 		'Src Index'						},
	[5] 	=   { {},  {9},  		'Dst Container',    {'store'}	},
	[6] 	=	{ {},  {11}, 		'Dst Index' 					},

	},	--	[[ COMPLETE ]]

--	Item Search ---------------------------------------------------------------

[0x02C] = {

	[1]		=	{ { 'call', 0xFFF }, 							},
	[2]		=	{ {},  {4}, 	'Language', 					},
	[3]		=	{ {},  {8,64}, 	'Name',			{'string'}		},

	},	--	[[ COMPLETE ]]

--	Offer Trade ---------------------------------------------------------------

[0x032] = {

	[1]		=	{ { 'call', 0xFFF }, 							    	},
	[2]		=	{ {},  {4,4}, 	'Unique No'								},
	[3]		=	{ {},  {8,2}, 	'Actor ID',		{'eid'}					},

	},	--	[[ COMPLETE ]]

--	Trade Tell ----------------------------------------------------------------

[0x033] = {

	[1]		=   { { 'call', 0xFFF }, 							    	},
	[2]		=   { {},  {4,4}, 	'Trade Type'							},
	[3]		=	{ {},  {8,2}, 	'Counter'								},

	},	--	[[ COMPLETE ]]

--	Trade Item ----------------------------------------------------------------

[0x034] = {

	[1]		=	{ { 'call', 0xFFF }, 							    	},
	[2]		=	{ {},  {4,4}, 	'Item Count'							},
	[3]		=	{ {},  {8,2}, 	'Item ID',		{'item'}				},
	[4]		=	{ {},  {10},	'Inv Index'								},
	[5]		=	{ {},  {11}, 	'Trade Slot'							},

	},	--	[[ COMPLETE ]]

--	Menu Item ----------------------------------------------------------------

[0x036] = {

	[1]		=	{ { 'call', 0xFFF } },
	[2]		=	{ {}, {4,4},	'NPC Name',		{'entity'}			},
	[3]		=	{ {}, {58,2}, 	'Actor Index',	{'eid'}				},
	[4]		=	{ {}, {60}, 	'Active Slots'						},

	[5]		=	{ { 'loop', 10, 4, 0 },                        		},
	[6]		=	{ { 'ifnot', 0, }, {8,4},  	'Item Count' 			},
	[7]		=	{ { 'end' },                                   		},
	
	[8]		=	{ { 'loop', 10, 1, 0 },                     	   	},
	[9]		=	{ { 'ifnot', 0 }, {48},  	'Item Index'	 		},
	[10]	=	{ { 'end' },                                   		},

	},	--	[[ COMPLETE ]]

--	Use Item ------------------------------------------------------------------

[0x037] = {

	[1]		=	{ { 'call', 0xFFF } },
	[2]		=	{ {},  {4,4},	'Unique ID'					},
	[3]		=	{ {},  {8,4},	'Item Count',	{'item'}	},
	[4]		=	{ {},  {12,2},	'Actor Index',	{'eid'}		},
	[5]		=	{ {},  {16,2},	'Container',	{'store'}	},
	[6]		=	{ {},  {14}, 	'Item Index'				},

	},	--	[[ COMPLETE ]]


--	Sort Item -----------------------------------------------------------------

[0x03A] = {

	[1]		=	{ { 'call', 0xFFF }, 					    		},
	[2]		=	{ {},  {4,2},	'Container',	{'store'}			},

	},	--	[[ COMPLETE ]]

--	Blacklist -----------------------------------------------------------------

[0x03D] = {

	[1]		=	{ { 'call', 0xFFF } },
	[2]		=	{ {}, {4,2},	'ID', 			{'player'}	},
	[3]		=	{ {}, {8,16},	'Player Name',	{'string'}	},
	[4]		=	{ {}, {24},		'Mode'						},

	},	--	[[ COMPLETE ]]


--	Lot Item ------------------------------------------------------------------

[0x041] = {

	[1]		=   { { 'call', 0xFFF } },
	[2]		=   { {},  {4}, 	'Trophy Index'			},
	[3]		=   { {},  {5}, 	'Inv Index'				},

	},	--	[[ COMPLETE ]]

--	Pass Item -----------------------------------------------------------------

[0x042] = {

	[1]		=	{ { 'call', 0xFFF } },
	[2]		=   { {},  {4},		'Trophy Index'			},

	},	--	[[ COMPLETE ]]

--	Servmes -------------------------------------------------------------------

[0x04B] = {

	[1]		=   { { 'call', 0xFFF }				},
	[2]		=   { {},  {4},		'Command'		},
	[3]		=   { {},  {5},  	'Result'		},
	[4]		=   { {},  {6},		'Frag No'		},
	[5]		=   { {},  {7},		'Frag Total'	},
	[6]		=   { {},  {8},		'Timestamp',	{'time'}	},
	[7]		=   { {},  {12,4},	'Total Size'	},
	[8]		=   { {},  {16,4},	'Offset'		},
	[9]		=   { {},  {20,4},	'Data Size'		},

	},	--	[[ COMPLETE ]]

--	Delivery Box --------------------------------------------------------------

[0x04D] = {

	[1]		= { { 'call', 0xFFF }, 							},
	[2]		= { {},  {4},		'Command',		{'dbox'}	},
	[3]		= { {},  {5},		'Box No'					},
	[4]		= { {},  {6},		'Post Work No'				},
	[5]		= { {},  {7},  		'Item Work No'				},
	[6]		= { {},  {8,4}		'Item Stacks'				},
	[7]		= { {},  {12},		'Result'					},
	[8]		= { {},  {13},		'Param 1'					},
	[9]		= { {},  {14},		'Param 2'					},
	[10]	= { {},  {15},		'Param 3'					},
	[11]	= { {},  {16,16},	'Target Name'				},

	},	--	[[ COMPLETE ]]


--	Auction -------------------------------------------------------------------

[0x04E] = {

	[1]		= { { 'call', 0xFFF } },
	[2]		= { {},  {4},	'Command'			},
	[3]		= { {},  {5},  	'AucWorkIndex'		},
	[4]		= { {},  {6},  	'Result'			},
	[5]		= { {},  {7},  	'ResultStatus'		},

	[6]		= { { 'switch', 4, 1} },

	[7]		= { { 'case', 4 } },
	[8]		= { {}, {-1},		'MODE 4', {'info'}, 	'Before sale confirmation' },
	[9]		= { {}, {8,4},		'Asking Price'			},
	[10]	= { {}, {12,2},		'Inv Location'			},
	[11]	= { {}, {14,2},		'ItemNo', {'item'}		},
	[12]	= { {}, {16,4},		'Stack Flag'			},
	[13]	= { { 'break' } },

	[14]	= { { 'case', 5 } },
	[15]	= { {}, {-1},		'MODE 5', {'info'}, 	'When opening the sales status window' },
	[16]	= { {}, {-1},		'',		  {'info'},    	'No other data in this packet' },
	[17]	= { { 'break' } },

	[18]	= { { 'case', 0x0A } },
	[19]	= { {}, {-1},		'MODE A', {'info'},  	'When opening the auction house' },
	[20]	= { {}, {-1},		'', 	  {'info'},    	'No other data in this packet' },
	[21]	= { { 'break' } },

	[22]	= { { 'case', 0x0B } },
	[23]	= { {}, {-1},		'MODE B', {'info'},		'After sale confirmation'	},
	[24]	= { {}, {8,4},		'Selling Price'			},
	[25]	= { {}, {12,2},		'Inv Location'			},
	[26]	= { {}, {16,4},		'Stack Flag'			},
	[27]	= { { 'break' } },

	[28]	= { { 'case', 0x0C } },
	[29]	= { {}, {-1},		'MODE C', {'info'},		'Cancelling an item sale' },
	[30]	= { {}, {-1},		'', 	  {'info'},  	'No other data in this packet' },
	[31]	= { { 'break' } },

	[32]	= { { 'case', 0x0D } },
	[33]	= { {}, {-1},		'MODE D', {'info'},  	'Item sale status request' },
	[34]	= { {}, {-1},		'', 	  {'info'},  	'No other data in this packet' },
	[35]	= { { 'break' } },

	[36]	= { { 'case', 0x0E } },
	[37]	= { {}, {-1},		'MODE E', {'info'},  	'Bidding on an item' },
	[38]	= { {}, {8,4},		'Bid Price' 			},
	[39]	= { {}, {12,2},		'Item ID',	{'item'}	},
	[40]	= { {}, {16,4}, 	'Stack Flag'			},
	[41]	= { { 'break' } },

	[42]	= { { 'end' } },

	},	--	[[ COMPLETE ]]

--	Speach --------------------------------------------------------------------

[0x0B5] = {

	[1]		=	{ { 'call', 0xFFF }, 				},
	[2]		=	{ {}, {6}, 	'Command',	'string'  	},

	},	--	[[ COMPLETE ]]
	
}

-- ============================================================================

return NewRules
