pragma solidity ^ 0.5.1;
contract Conquer3d {
    uint constant scaleFactor = 0x10000000000000000;

    Territory[] public territories;
    Location[] public locations;
    Player[] public players;
    Unit[] public units;
    Base[] public bases;

    mapping(address => Player) public a2p;
    mapping(int => mapping(int => uint)) public landMap;

    constructor(uint256 colors) payable public{//120064160013098128188255045235128080255075064
      if(msg.value==50000000000000000){
        //falsey 0 indices
        newPlayer(0x0000000000000000000000000000000000000000);
        newTerritory(0,0,0,0,0); //comes with falsey Location & Base
        locations[0].occupied = false;


        //first player
        newPlayer(msg.sender);//0x6E710e8B75a45F133489862fCeF6Eb740c4BaD2F
        newTerritory(0,0,1,1,colors);
      }else{
        revert();
      }
    }

      /*function runActions(uint[] memory actions) public{
        //
      }
      function random(uint number) public view returns(uint value){
        return uint( uint( blockhash(block.number) ) % number);
      }*/

      event action(
          uint256 associatedTerritory,
          uint8 actionType,
          uint256 data1,
          uint256 data2
      );

    struct Player{
      uint ID;
      address addr;
      uint[] territories; //all territories the player controls
    }
        function newPlayer(address addr) internal returns(uint playerID){
          Player memory _player;
          _player.addr = addr;
          _player.ID = players.length;
          players.push(_player);
          a2p[addr] = _player;
          return _player.ID;
        }
        function getPlayer(uint playerID) public view returns(address addr,uint[] memory territoryIDs){
          return (players[playerID].addr, players[playerID].territories);
        }

    struct Territory{
      uint ID;
      uint owner; //the player that owns the territory
      uint pocketID; //the index within the owner's territories
      uint256 colors; //for a rich play experience
      uint taxingTerritory; //the guy that brought you in and has allowed for your safe existence

      uint[] territory; //locations claimed
      uint[] population; //for the UI to be able to pull the members of the population
      uint[] bases; //list of bases affiliated with the territory

      uint basesAlive; //the number of bases alive affiliated with the territory

      uint killedBy; //when a Territory is taken over the killer takes the taxes
    }
        function newTerritory(int x, int y, uint owner, uint taxingTerritory, uint256 colors) internal returns(uint territoryID){
          Territory memory _territory;
          _territory.ID = territories.length;
          _territory.owner = owner;
          _territory.colors = colors;
          _territory.taxingTerritory = taxingTerritory;
          _territory.killedBy = 0; //0 means it hasn't been killed
          territories.push(_territory);

          Player storage playerOwner = players[owner];
          _territory.pocketID = playerOwner.territories.length;
          playerOwner.territories.push(_territory.ID);

          uint locationID = newLocation(x, y, _territory.ID);
          territories[_territory.ID].territory.push(locationID);
          locations[locationID].territory = _territory.ID;

          uint baseID = newBase(_territory.ID, locationID);
          territories[_territory.ID].bases.push(baseID);
          _territory.basesAlive += 1;

          return _territory.ID;
        }
        function getTerritoryColors(uint[] memory _territories) public view returns(uint256[] memory territoryColors){
          uint256[] memory _territoryColors = new uint256[](_territories.length);
          for(uint T = 0; T<_territories.length; T+=1){
            _territoryColors[T] = territories[T].colors;
          }
          return _territoryColors;
        }

    struct Location {
      uint ID;
      int x;
      int y;
      uint territory;
      bool occupied;
      uint occupierID;
      bool occupierType;
    }
        function newLocation(int x,int y, uint territoryID) internal returns(uint locationID){
          Location memory _location;
          _location.ID = locations.length;
          _location.x = x;
          _location.y = y;
          _location.territory = territoryID;
          locations.push(_location);
          landMap[x][y] = _location.ID;
          return _location.ID;
        }
        function occupied(uint locationID) public view returns(bool occupi3d){
          return locations[locationID].occupied;
        }
        function occupied(int x, int y) public view returns(bool occupi3d){
          return occupied(landMap[x][y]);
        }
        function claimed(uint locationID) public view returns(bool claim3d){
          return locations[locationID].territory>0;
        }
        function claimed(int x, int y) public view returns(bool claim3d){
          return locations[landMap[x][y]].territory>0;
        }
        function getArea(int X, int Y,uint width, uint height) public view returns(uint[] memory locationTerritory, uint[] memory locationOccupierData, bool[] memory locationOccupierStat2){
          uint i;
          uint[] memory _locationTerritory = new uint[](width*height);
          uint[] memory _locationOccupierData = new uint[](width*height*4); //ID & Homeland & Birth & Damage
          bool[] memory _locationOccupierData2 = new bool[](width*height*2); //Type & isAlive
          int y;
          for(int x = X; x < X+int(width); x+=1){
            for(y = Y; y < Y+int(height); y+=1){
              if(locations[landMap[x][y]].territory>0){
                _locationTerritory[i] = locations[landMap[x][y]].territory;
                if( occupied(landMap[x][y]) ){
                  _locationOccupierData[i] = locations[landMap[x][y]].occupierID;//ID
                  if(locations[landMap[x][y]].occupierType){
                    if(!bases[locations[landMap[x][y]].occupierID].dead){
                      _locationOccupierData[width*height+i] = bases[locations[landMap[x][y]].occupierID].homeland;//Homeland
                      _locationOccupierData[width*height*2+i] = bases[locations[landMap[x][y]].occupierID].birthTime;//birthTime
                      _locationOccupierData[width*height*3+i] = bases[locations[landMap[x][y]].occupierID].damage;//damage
                      _locationOccupierData2[i] = true;//of type Base
                      _locationOccupierData2[width*height+i] = true;//alive
                    }
                  }else{
                    if(!units[locations[landMap[x][y]].occupierID].dead){
                      _locationOccupierData[width*height+i] = units[locations[landMap[x][y]].occupierID].homeland;//Homeland
                      _locationOccupierData[width*height*2+i] = units[locations[landMap[x][y]].occupierID].birthTime;//birthTime
                      _locationOccupierData[width*height*3+i] = units[locations[landMap[x][y]].occupierID].damage;//damage
                      _locationOccupierData2[i] = false;//of type Unit
                      _locationOccupierData2[width*height+i] = true;//alive
                    }
                  }
                }else{
                  _locationOccupierData2[width*height+i] = false;//unoccupied
                }
              }
              i+=1;
            }
          }
          return (_locationTerritory,_locationOccupierData,_locationOccupierData2);
        }
        function getLocationTerritory(uint locationID) public view returns(uint territoryID){
            return locations[locationID].territory;
        }
        function isAdjacent(uint location1, uint location2) public view returns(bool adjacent){
          Location storage l1 = locations[location1];
          Location storage l2 = locations[location2];
          if( (l1.x == l2.x-1 && l1.y == l2.y)
          || (l1.x == l2.x+1 && l1.y == l2.y)
          || (l1.y == l2.y-1 && l1.x == l2.x)
          || (l1.y == l2.y+1 && l1.x == l2.x) ){
            return true;
          }else{
            return false;
          }
        }
        function sameTerritory(uint location1, uint location2) public view returns(bool same){
          return locations[location1].territory == locations[location2].territory;
        }
        function cardinal(bool cardinal1, bool cardinal2) pure public returns(int x, int y){
          int offX=0;
          int offY=0;
          if(cardinal1){
            offY = cardinal2 ? int(1) : -1;
          }else{
            offX = cardinal2 ? int(1) : -1;
          }
          return (offX, offY);
        }

    struct Base{
      /*
      Spawn units & determines their base attack power.
      Unit spawn cooldown = baseTime / number of bases within territory
      Number of bases determines land claiming capacity
      */
      uint ID;
      uint homeland;
      uint location; //the square of Land the base sits on
      uint damage; //tracking the change in damage
      uint birthTime; //when the base was created, to track health growth
      uint[] units; //a list of units this base has spawned
      bool dead;
    }
        function newBase(uint territoryID, uint locationID) internal returns(uint baseID){
          Base memory _base;
          _base.ID = bases.length;
          _base.homeland = territoryID;
          _base.location = locationID;
          locations[locationID].occupied = true;
          locations[locationID].occupierID = _base.ID;
          locations[locationID].occupierType = true;
          _base.birthTime = now;
          bases.push(_base);
          return _base.ID;
        }
        function spawnUnitInTerritory(uint baseID, uint locationID) public/*internal*/{
          if( sameTerritory(bases[baseID].location,locationID) && !occupied(locationID) ){
            newUnit(baseID,locationID);
          }
        }
        function spawnUnitAdjacently(uint baseID, bool cardinal1, bool cardinal2) public/*internal*/{
          int offX;
          int offY;
          (offX,offY) = cardinal(cardinal1, cardinal2);
          Base memory base = bases[baseID];
          uint locationID;

          offX += locations[base.location].x;
          offY += locations[base.location].y;

          if( !occupied(offX, offY) ){
            locationID = locations[landMap[offX][offY]].ID;
            if( !claimed(locationID) ){
                locationID = newLocation(offX, offY, base.homeland);
            }
            newUnit(baseID,locationID);
          }
        }

    struct Unit{
      uint ID;
      uint homeID; //index in relation to homeland
      uint homeland; //damage scaling benefit when fighting from homeland territory
      uint birthTime; //when the unit was born, to track health growth
      uint base; //the base that the unit camee from. Determines attack power.
      uint damage; //tracking the change in damage
      uint location; //the square of Land the unit is at
      uint kills; //the more kills, the farther this unit can traverse territories
      bool dead;
    }
        function newUnit(uint baseID, uint locationID) internal returns(uint unitID){
          Unit memory _unit;
          _unit.ID = units.length;
          _unit.homeland = bases[baseID].homeland;
          _unit.birthTime = now;
          _unit.location = locationID;

          locations[locationID].occupied = true;
          locations[locationID].occupierType = false;
          locations[locationID].occupierID = _unit.ID;
          territories[locations[locationID].territory].population.push(_unit.ID);

          _unit.base = baseID;
          _unit.homeID = bases[baseID].units.length;
          bases[baseID].units.push(_unit.ID);

          units.push(_unit);
          return _unit.ID;
        }
        /*function fight(uint attackerID, uint defenderID) internal{
          Unit storage attacker = units[attackerID];
          Unit storage defender = units[defenderID];
          uint time = now;
          defender.damage += random(time - bases[attacker.base].birthTime);
          attacker.damage += random(time - bases[defender.base].birthTime);
        }*/
        /*function spawnTerritory(uint taxingLocation, uint taxingTerritory, bool cardinal1, bool cardinal2) public{//internal
          if(territories.length > 1){
            //if ( 0 != territories[ getLocationTerritory(taxingLocation) ].territory){
              //
            //}
          }
        }*/
        function claim(uint unitID, bool alreadyClaimed, uint locationData) public/*internal*/{
          uint toLocationID;
          if(alreadyClaimed){
            toLocationID = claim(unitID, locationData);
          }else{
            bool cardinal1;
            bool cardinal2;
            if(locationData == 0){
              cardinal1 = true; cardinal2 = true;
            }else if(locationData == 1){
              cardinal1 = false; cardinal2 = true;
            }else if(locationData == 2){
              cardinal1 = true; cardinal2 = false;
            }else if(locationData == 3){
              cardinal1 = false; cardinal2 = false;
            }
            toLocationID = claim(unitID, cardinal1, cardinal2);
          }
          changeLocation(unitID, toLocationID);
        }
        function claim(uint unitID, bool cardinal1, bool cardinal2)  internal returns (uint toLocationID){
          int offX = 0;
          int offY = 0;
          if( inHomeland(unitID) ){
            (offX,offY) = cardinal(cardinal1, cardinal2);
            uint locationID = units[unitID].location;
            offX += locations[locationID].x;
            offY += locations[locationID].y;
            if( !claimed(offX, offY) && !occupied(offX, offY) ){
              uint expandedLocationID = newLocation(offX, offY, units[unitID].homeland);
              locations[expandedLocationID].territory = units[unitID].homeland;
              return expandedLocationID;
            }
          }
          revert();
        }
        function claim(uint unitID, uint locationID)  internal returns (uint toLocationID){
          if( inHomeland(unitID) ){
            uint unitLocationID = units[unitID].location;
            if( isAdjacent(unitLocationID,locationID) && !occupied(locationID) ){
              Location storage location = locations[locationID];
              location.territory = units[unitID].homeland;
              return location.ID;
            }
          }
          revert();
        }
        function inHomeland(uint unitID) public view returns(bool home){
          uint unitLocationID = units[unitID].location;
          return units[unitID].homeland == locations[unitLocationID].territory;
        }
        function getUnitCurrentTerritory(uint unitID) public view returns(uint territoryID){
            return locations[units[unitID].location].territory;
        }
        function traverseTerritory(uint unitID, uint[] memory steps, uint destinationID) internal{
          bool routed = true;
          if( getUnitCurrentTerritory(unitID) != getLocationTerritory(destinationID) ){
            for(uint step = 0; step < steps.length; step += 2){
              if( !isAdjacent(steps[step], steps[step+1])
              || (step !=0 && locations[step-1].territory != locations[step].territory)
              || occupied(steps[step+1])/*this allows for border control*/){
                routed = false;
              }
            }
            if(routed
            && !occupied(destinationID)
            && locations[steps.length-1].territory == locations[destinationID].territory){
              changeLocation(unitID, destinationID);
            }
          }
        }
        function changeLocation(uint unitID, uint locationID) internal{
          Unit storage unit = units[unitID];
          locations[unit.location].occupied = false;
          unit.location = locationID;
          locations[unit.location].occupied = true;
          locations[unit.location].occupierID = unitID;
          locations[unit.location].occupierType = false;
        }
}
