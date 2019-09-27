let abi =[
	{
		"constant": false,
		"inputs": [
			{
				"name": "baseID",
				"type": "uint256"
			},
			{
				"name": "cardinal1",
				"type": "bool"
			},
			{
				"name": "cardinal2",
				"type": "bool"
			}
		],
		"name": "spawnUnit",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "baseID",
				"type": "uint256"
			},
			{
				"name": "locationID",
				"type": "uint256"
			}
		],
		"name": "spawnUnit",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "X",
				"type": "int256"
			},
			{
				"name": "Y",
				"type": "int256"
			},
			{
				"name": "width",
				"type": "uint256"
			},
			{
				"name": "height",
				"type": "uint256"
			}
		],
		"name": "getArea",
		"outputs": [
			{
				"name": "locationTerritory",
				"type": "uint256[]"
			},
			{
				"name": "locationOccupierData",
				"type": "uint256[]"
			},
			{
				"name": "locationOccupierStat2",
				"type": "bool[]"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "x",
				"type": "int256"
			},
			{
				"name": "y",
				"type": "int256"
			}
		],
		"name": "claimed",
		"outputs": [
			{
				"name": "claim3d",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "unitID",
				"type": "uint256"
			},
			{
				"name": "alreadyClaimed",
				"type": "bool"
			},
			{
				"name": "locationData",
				"type": "uint256"
			}
		],
		"name": "claim",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "unitID",
				"type": "uint256"
			}
		],
		"name": "getUnitCurrentTerritory",
		"outputs": [
			{
				"name": "territoryID",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "location1",
				"type": "uint256"
			},
			{
				"name": "location2",
				"type": "uint256"
			}
		],
		"name": "sameTerritory",
		"outputs": [
			{
				"name": "same",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "unitID",
				"type": "uint256"
			},
			{
				"name": "locationID",
				"type": "uint256"
			}
		],
		"name": "claimTerritoryLocation",
		"outputs": [
			{
				"name": "toLocationID",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"name": "bases",
		"outputs": [
			{
				"name": "ID",
				"type": "uint256"
			},
			{
				"name": "homeland",
				"type": "uint256"
			},
			{
				"name": "location",
				"type": "uint256"
			},
			{
				"name": "damage",
				"type": "uint256"
			},
			{
				"name": "birthTime",
				"type": "uint256"
			},
			{
				"name": "dead",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "unitID",
				"type": "uint256"
			},
			{
				"name": "cardinal1",
				"type": "bool"
			},
			{
				"name": "cardinal2",
				"type": "bool"
			}
		],
		"name": "claimVoidCoords",
		"outputs": [
			{
				"name": "toLocationID",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"name": "territories",
		"outputs": [
			{
				"name": "ID",
				"type": "uint256"
			},
			{
				"name": "owner",
				"type": "uint256"
			},
			{
				"name": "pocketID",
				"type": "uint256"
			},
			{
				"name": "colors",
				"type": "uint256"
			},
			{
				"name": "taxingTerritory",
				"type": "uint256"
			},
			{
				"name": "basesAlive",
				"type": "uint256"
			},
			{
				"name": "killedBy",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "address"
			}
		],
		"name": "a2p",
		"outputs": [
			{
				"name": "ID",
				"type": "uint256"
			},
			{
				"name": "addr",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "x",
				"type": "int256"
			},
			{
				"name": "y",
				"type": "int256"
			}
		],
		"name": "occupied",
		"outputs": [
			{
				"name": "occupi3d",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "int256"
			},
			{
				"name": "",
				"type": "int256"
			}
		],
		"name": "landMap",
		"outputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "locationID",
				"type": "uint256"
			}
		],
		"name": "occupied",
		"outputs": [
			{
				"name": "occupi3d",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "cardinal1",
				"type": "bool"
			},
			{
				"name": "cardinal2",
				"type": "bool"
			}
		],
		"name": "cardinal",
		"outputs": [
			{
				"name": "x",
				"type": "int256"
			},
			{
				"name": "y",
				"type": "int256"
			}
		],
		"payable": false,
		"stateMutability": "pure",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "unitID",
				"type": "uint256"
			}
		],
		"name": "inHomeland",
		"outputs": [
			{
				"name": "home",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "_territories",
				"type": "uint256[]"
			}
		],
		"name": "getTerritoryColors",
		"outputs": [
			{
				"name": "territoryColors",
				"type": "uint256[]"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"name": "locations",
		"outputs": [
			{
				"name": "ID",
				"type": "uint256"
			},
			{
				"name": "x",
				"type": "int256"
			},
			{
				"name": "y",
				"type": "int256"
			},
			{
				"name": "territory",
				"type": "uint256"
			},
			{
				"name": "occupied",
				"type": "bool"
			},
			{
				"name": "occupierID",
				"type": "uint256"
			},
			{
				"name": "occupierType",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "locationID",
				"type": "uint256"
			}
		],
		"name": "getLocationTerritory",
		"outputs": [
			{
				"name": "territoryID",
				"type": "uint256"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "location1",
				"type": "uint256"
			},
			{
				"name": "location2",
				"type": "uint256"
			}
		],
		"name": "isAdjacent",
		"outputs": [
			{
				"name": "adjacent",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "locationID",
				"type": "uint256"
			}
		],
		"name": "claimed",
		"outputs": [
			{
				"name": "claim3d",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "playerID",
				"type": "uint256"
			}
		],
		"name": "getPlayer",
		"outputs": [
			{
				"name": "addr",
				"type": "address"
			},
			{
				"name": "territoryIDs",
				"type": "uint256[]"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"name": "units",
		"outputs": [
			{
				"name": "ID",
				"type": "uint256"
			},
			{
				"name": "homeID",
				"type": "uint256"
			},
			{
				"name": "homeland",
				"type": "uint256"
			},
			{
				"name": "birthTime",
				"type": "uint256"
			},
			{
				"name": "base",
				"type": "uint256"
			},
			{
				"name": "damage",
				"type": "uint256"
			},
			{
				"name": "location",
				"type": "uint256"
			},
			{
				"name": "kills",
				"type": "uint256"
			},
			{
				"name": "dead",
				"type": "bool"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"constant": true,
		"inputs": [
			{
				"name": "",
				"type": "uint256"
			}
		],
		"name": "players",
		"outputs": [
			{
				"name": "ID",
				"type": "uint256"
			},
			{
				"name": "addr",
				"type": "address"
			}
		],
		"payable": false,
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"name": "colors",
				"type": "uint256"
			}
		],
		"payable": true,
		"stateMutability": "payable",
		"type": "constructor"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"name": "associatedTerritory",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "actionType",
				"type": "uint8"
			},
			{
				"indexed": false,
				"name": "data1",
				"type": "uint256"
			},
			{
				"indexed": false,
				"name": "data2",
				"type": "uint256"
			}
		],
		"name": "action",
		"type": "event"
	}
];

export default abi
