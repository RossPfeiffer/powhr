pragma solidity ^ 0.5.1;
contract Conquer3d {
    uint constant scaleFactor = 0x10000000000000000; // for mathematical precision

    Territory[] territories;
    Location[] locations;
    Player[] players;
    Unit[] workers;
    Unit[] soldiers;
    Alliance[] alliances;

    mapping(address => Player) a2p;
    mapping(int => mapping(int => Location)) landMap;

    struct Player{
      uint ID;
      uint[] territories; //all territories the player controls
      address addr;
    }
    struct Alliance{
      uint ID;
      uint[] guild; //all territories of the alliance
    }
    struct Territory{
      uint ID;
      uint owner; //the player that owns this territory
      uint taxingTerritory; //the guy that brought you in and has allowed for your safe existence
      uint alliance; //0 = no alliance. A cooperation scaling mechanic so that you don't have to be up 24/7

      uint level; //tracks the next expense for leveling up one of these "stats"
      uint homes; //for worker health
      uint tool_sheds; //for land expansion
      uint barns; //for mobility over territories
      uint archery; //for range over land blocks
      uint armor_shop; //for soldier health
      uint weapon_shop; //for soldier offense

      uint[] territory;
      uint[] population; //for the UI to be able to pull the members of the population

      uint killedBy; //when a Territory is taken over the killer takes the taxes
    }
    struct Location {
      uint ID;
      int x;
      int y;
      uint territory;
      bool initialized;
    }
    struct Unit{
      uint ID;
      uint homeland;
      uint owner; //this is different than the homeland territory's player because unit's can be purchased from other players
      Percentage health; //a percentage that will scale with leveling up (or down)
      uint location; //the square of Land the unit is at
      bool unitType;
    }
    struct Percentage{
      uint n;//numerator
      uint d;//denominator
    }

    function spawn(uint taxingLocation, uint taxingTerritory, bool cardnal1, bool cardnal2) public{
      if(territories.length > 0){
        //if (locations[taxCollector].territory.initialized){
          //
        //}
      }else{//the first player
        newTerritory(0,0,0,0);
        uint playerID = newPlayer(msg.sender);
        players[playerID].territories.push(0);
        newWorker(0,0);
      }
    }

    function expandTerritory(bool cardnal1, bool cardnal2, uint workerID) internal{
      int offX=0;
      int offY=0;
      uint locationID = getWorkerLocation(workerID);
      if(workers[workerID].homeland == locations[locationID].territory){
        if(cardnal1){
          offY = cardnal2 ? int(1) : -1;
        }else{
          offX = cardnal2 ? int(1) : -1;
        }
        int expX = offX + locations[locationID].x;
        int expY = offY + locations[locationID].y;
        if( locationExists(expX,expY) ){
          uint expandedLocation = newLocation(expX,expY);
          locations[expandedLocation].territory = workers[workerID].homeland;
        }
      }
    }
    function locationExists(int x, int y) public view returns(bool exists){
      Location storage location = landMap[x][y];
      if( location.initialized && territoryExists(location.territory) ){
        return true;
      }else{
        return false;
      }
    }
    function territoryExists(uint territoryID) public view returns(bool exists){
      if(territories[territoryID].killedBy != territoryID){
        return true;
      }else{
        return false;
      }
    }
    function newWorker(uint territoryID, uint locationID) internal returns(uint workerID){
      Unit memory _worker;
      _worker.ID = workers.length;
      _worker.unitType = false;
      _worker.homeland = territoryID;
      _worker.location = locationID;
      _worker.health.n = scaleFactor;
      _worker.health.d = scaleFactor;
      territories[territoryID].population.push(_worker.ID);
      workers.push(_worker);
      return _worker.ID;
    }
    function getWorkerLocation(uint workerID) public view returns(uint location){
        return workers[workerID].location;
    }
    function newPlayer(address addr) internal returns(uint playerID){
      Player memory _player;
      _player.addr = addr;
      _player.ID = players.length;
      players.push(_player);
      return _player.ID;
    }
    function newLocation(int x,int y) internal returns(uint locationID){
      Location memory _location;
      _location.ID = locations.length;
      _location.x = x;
      _location.y = y;
      _location.initialized = true;
      locations.push(_location);
      landMap[x][y] = _location;
      return _location.ID;
    }
    function newTerritory(int x,int y,uint owner, uint taxingTerritory) internal returns(uint territoryID){
      Territory memory _territory;
      _territory.ID = territories.length;
      _territory.owner = owner;
      _territory.taxingTerritory = taxingTerritory;
      _territory.killedBy = _territory.ID; //it's own ID means it's not dead
      territories.push(_territory);

      uint locationID = newLocation(x,y);
      territories[_territory.ID].territory.push(locationID);
      locations[locationID].territory = _territory.ID;

      return _territory.ID;
    }
    function getPopulationSize(uint territoryID) public view returns(uint populationSize){
      return territories[territoryID].population.length;
    }
}
