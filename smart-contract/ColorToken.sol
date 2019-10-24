pragma solidity ^ 0.5.12;
contract ColorToken{
	uint8 constant REDBONDS = 0;
	uint8 constant GREENBONDS = 1;
	uint8 constant BLUEBONDS = 2;
	uint8 constant REDRESOLVES = 3;
	uint8 constant GREENRESOLVES = 4;
	uint8 constant BLUERESOLVES = 5;
	uint8 constant VOTES_FOR_CR = 6;
	uint8 constant VOTING_FOR_MR = 7;
	uint8 constant COLOREDBONDS = 8;
	uint8 constant COLOREDRESOLVES = 9;
	uint8 constant POCKET = 10;
	uint8 constant UPLINE = 11;
	uint8 constant LOCKEDRESOLVES = 12;

	uint8 constant GATEWAY = 0;
	uint8 constant MINECART = 1;
	uint8 constant VOTING_FOR_CR = 2;


	address THIS = address(this);
	address constant nulf = 0x0000000000000000000000000000000000000000;

	string public name = "Color Token";
    string public symbol = "`c";
    uint8 constant public decimals = 18;
	uint _totalSupply/*===*/;


	mapping(address => address payable) proxy;
	mapping(address => address payable) proxyOwner;

	mapping(address => uint256) coloredBonds;
	mapping(address => uint256) redBonds;
	mapping(address => uint256) greenBonds;
	mapping(address => uint256) blueBonds;

	mapping(address => uint256) lockedResolves;
	mapping(address => uint256) coloredResolves;
	mapping(address => uint256) redResolves;
	mapping(address => uint256) greenResolves;
	mapping(address => uint256) blueResolves;

	mapping(address => mapping(address => uint)) approvals;

	mapping(address => address) gateway;
	mapping(address => uint256) pocket;
	mapping(address => uint256) upline;
	mapping(address => address) minecart;

	mapping(address => address) votingForCR;
	mapping(address => uint256) votesForCR;

	mapping(address => uint) votingForMR;
	mapping(uint => uint256) votesForMR;

	BondContract bondContract;
	ResolveContract resolveContract;
	ResolveNamingService RNS;
	address lastGateway;
	address communityResolve;
	uint _totalBonds;
	uint pyrColorResolves;
	uint masternodeRequirement = 0;
	uint colorFee = 10; // 10%

	constructor(address _bondContract) public{
		bondContract = BondContract( _bondContract );
		resolveContract = ResolveContract( bondContract.getResolveContract() );
		RNS = new ResolveNamingService(THIS);
		communityResolve = msg.sender;
		lastGateway = THIS;
	}

    function totalSupply() public view returns (uint256) {
        return _totalSupply/*===*/;
    }

	function fundCR() payable public {
  		pocket[THIS] += msg.value;
  	}

	function balanceOf(address addr) public view returns (uint balance) {
		if(proxyAddress(addr) == nulf)
		return 0;
        return _PyramidProxy(addr).getBalance();
    }
	/*function max1(uint x) internal pure returns (uint){
		if(x>1e12)
			return 1e12;
		else
			return x;
	}*/
	/*function proxy(address addr) returns(PyramidProxy){
		proxies[proxyID[addr]]
	}*/
	function ensureProxy(address addr) internal{
		if( proxyAddress(addr) == nulf){
			PyramidProxy prox = new PyramidProxy( this, bondContract );
			proxy[addr] = address(prox);
			proxyOwner[ address(prox) ] = address(uint160(addr));
		}
	}
  	event MinecartPush(address indexed addr, address newMinecartLocation, uint upline );
  	//event GatewaySwitch(address newGateway );
  	function pushMinecart(address addr) public {
  		if( _UINT(COLOREDRESOLVES,addr)>0 ){
	  		address gate = _ADDRESS(0,addr);
	  		if( !checkMR(gate) ){
				ADDRESS_(GATEWAY, addr, lastGateway);
				//emit GatewaySwitch(lastGateway);
			}

	  		address pushcart = _ADDRESS(MINECART,addr);
	  		address upCart = _ADDRESS(0, pushcart );
	  		address nextCartPosition = pushcart == THIS ? addr : upCart;

			ADDRESS_(MINECART, addr, nextCartPosition);
			pushcart = nextCartPosition;

			uint up = _UINT(UPLINE, pushcart );
			pocket[ pushcart ] +=  up/5;
			upline[ _ADDRESS(0, pushcart ) ] += up - up/5;
			upline[ pushcart ] = 0;
			emit MinecartPush( addr, pushcart, up );
		}

		address candidate = _ADDRESS(VOTING_FOR_CR, msg.sender);
		if( _UINT(VOTES_FOR_CR, candidate) > _UINT(VOTES_FOR_CR, communityResolve) ){
			communityResolve = candidate; 
		}
		uint MR_votingFor = _UINT(VOTING_FOR_MR, msg.sender);
		if( _votesForMR(MR_votingFor) > _votesForMR(masternodeRequirement) ){
			masternodeRequirement = MR_votingFor;
		}

  	}

	/*function getData(address A) public view returns (address,uint,uint){
		return ( gateway[A], pocket[A], upline[A] );
	}*/
	/*function getData(address A) public view returns (address,uint,uint){
		return (gateway[A], pocket[A],  upline[A] );
	}*/
	function getData(address A, int numeric) public view returns (address,address,address,uint,uint,uint){
		//address nulf = nulf;
		if(numeric < 0){
			if(A == nulf){
				return ( address(bondContract), lastGateway, communityResolve, _totalBonds, pyrColorResolves, masternodeRequirement);
			}else{
				return ( _ADDRESS(0, A ), _ADDRESS(MINECART,A), _ADDRESS(VOTING_FOR_CR,A), _UINT(POCKET,A), _UINT(UPLINE,A), _UINT(VOTING_FOR_MR,A) );
			}	
		}else{
			return ( nulf, nulf, nulf, _UINT(VOTES_FOR_CR,A), _votesForMR((uint)(numeric)), 0 );
		}
	}
	function _UINT(uint8 c, address addr) public view returns(uint){
		if(c == 0){return redBonds[addr];}
		else if(c==1){return greenBonds[addr];}
		else if(c==2){return blueBonds[addr];}
		else if(c==3){return redResolves[addr];}
		else if(c==4){return greenResolves[addr];}
		else if(c==5){return blueResolves[addr];}
		else if(c==6){return votesForCR[addr];}
		else if(c==7){return votingForMR[addr];}
		else if(c==8){return coloredBonds[addr];}
		else if(c==9){return coloredResolves[addr];}
		else if(c==10){return pocket[addr];}
		else if(c==11){return upline[addr];}
		else if(c==12){return lockedResolves[addr];}
	}
	function _ADDRESS(uint8 c, address addr) public view returns(address){
		if(c == 0){return gateway[addr];}
		else if(c==1){return minecart[addr];}
		else if(c==2){return votingForCR[addr];}
		else if(c==3){return proxyOwner[addr];}
	}
	function ADDRESS_(uint8 c, address addr, address addr2) public returns(address){
		if(c == 0){gateway[addr]=addr2;}
		else if(c==1){minecart[addr]=addr2;}
		//else if(c==2){votingForCR[addr]=addr2;}
		//else if(c==3){proxyOwner[addr]=addr2;}
	}
	/*

  	function _UINT(VOTES_FOR_CR,address addr) internal view returns(uint){return votesForCR[addr];}
  	function _UINT(VOTING_FOR_MR,address addr) internal view returns(uint){return votingForMR[addr];}
  	*/

  	event Sell( address indexed addr, uint256 bondsSold, uint256 resolves, uint red, uint green, uint blue);
  	function publix(uint8 Type, uint numeric) public{
  		if(Type == 0){
  			sell(numeric);
		}else if(Type==1){
  			stake(numeric);
		}else if(Type==2){
  			unstake(numeric);
		}else if(Type==3){
  			reinvest(numeric);
		}else if(Type==4){
  			withdraw(numeric);
		}else if(Type==5){
  			setVotingForMR(numeric);
		}else if(Type==6){
  			pullAffiliateEarningsOnly();
  		}/*else if(Type==7){
  		}*/
  	}
  	function sell(uint amountToSell) internal{
  		address sender = msg.sender;
  		uint coloredBondsBefore = _UINT(COLOREDBONDS,sender);
  		uint regularBonds = bondBalance(sender) - coloredBondsBefore;
  		//if(amountToSell>)
  		uint coloredAmountToSell = amountToSell;
  		if(regularBonds>0){
  			uint regularBondsToBeSold;
  			if(amountToSell >= regularBonds){
  				regularBondsToBeSold = regularBonds;
  				coloredAmountToSell -= regularBonds;
  			}else{
  				regularBondsToBeSold = amountToSell;
  				coloredAmountToSell = 0;
  			}
  			_PyramidProxy(sender).publix(0, regularBondsToBeSold);
  		}
  		if(coloredAmountToSell>0){
	  		(uint _red, uint _green, uint _blue) = RGB_bondRatio();
	  		(uint mintedResolves,) = _PyramidProxy(sender).publix(0,coloredAmountToSell);
	  		_totalBonds -= coloredAmountToSell;
	  		/*uint _red = redBonds[sender] / coloredBondsBefore;
	  		uint _green = greenBonds[sender] / coloredBondsBefore;
	  		uint _blue = blueBonds[sender] / coloredBondsBefore;*/
			resolvesAddColor(sender, mintedResolves, _red*1e6, _green*1e6, _blue*1e6);
	  		votesForCR[ _ADDRESS(VOTING_FOR_CR,sender) ] += mintedResolves;
	  		if(!isContract(sender)) votesForMR[ _UINT(VOTING_FOR_MR ,sender) ] += mintedResolves;
	  		_totalSupply/*===*/ += mintedResolves;
			coloredResolves[sender] += mintedResolves;
			emit Sell(sender, coloredAmountToSell, mintedResolves, _red, _green, _blue );
	  		bondsThinColor(sender, coloredBondsBefore - coloredAmountToSell, coloredBondsBefore);
	  	}

  		pushMinecart(sender);
  	}
  	function _votesForMR(uint MR) internal view returns(uint){return votesForMR[MR];}
  	function _PyramidProxy(address addr) internal view returns(PyramidProxy){return PyramidProxy( proxyAddress(addr) );}

  	function stake(uint amountToStake) internal{
  		address sender = msg.sender;
		colorShift(sender, address(bondContract), amountToStake );
		pyrColorResolves += amountToStake;
		_PyramidProxy(sender).publix(1, amountToStake );
		pushMinecart(sender);
  		//minecart[sender] = sender;
  		ADDRESS_(MINECART, sender, sender);/* a little bit of economic chaos theory going on here.
  		since most people at the edges will have most of the resolves, 
  		they will be the most likely to stake. you don't need as many
  		minecart pushers near the top of the affiliate system*/
  	}
  	function unstake(uint amountToUnstake) internal{
  		address sender = msg.sender;
		colorShift(address(bondContract), sender, amountToUnstake );//pyrColorResolves
		pyrColorResolves -= amountToUnstake;
		_PyramidProxy(sender).publix(2, amountToUnstake );
		pushMinecart(sender);
  	}/**/
  	event Reinvest( address indexed addr, uint256 affiliateEarningsSpent, uint256 bonds);
  	function reinvest(uint amount) internal{
  		address sender = msg.sender;
  		//address proxyAddr = proxyAddress( sender );
  		//uint bal = bondContract.balanceOf( proxyAddr );
  		/*uint red = redBonds[sender] / bal;
		uint green = greenBonds[sender] / bal;
		uint blue = blueBonds[sender] / bal;*/
		(uint red, uint green, uint blue) = RGB_bondRatio();

  		uint createdBonds;
  		uint dissolvedResolves;
		(createdBonds, dissolvedResolves) = _PyramidProxy(sender).publix(3,amount);
		uint pock = _UINT(POCKET,sender);
		pocket[sender] = 0;
		_totalBonds += createdBonds;
		createdBonds += buy( sender, pock, red, green, blue, false);
		coloredBonds[sender] += createdBonds;

		bondsAddColor(sender, createdBonds, red, green, blue);
		// update core contract's Resolve color
		pyrColorResolves -= dissolvedResolves;
		resolvesThinColor( address(bondContract) , pyrColorResolves, pyrColorResolves + dissolvedResolves);
		emit Reinvest( sender, pock, createdBonds);
		pushMinecart(sender);
  	}

  	function withdraw(uint amount) internal{
  		address payable sender = msg.sender;
  		(uint dissolvedResolves,) = _PyramidProxy(sender).publix(4,amount);
  		uint earned = _UINT(POCKET,sender);
  		pocket[sender] = 0;
  		// update core contract's Resolve color
		//address pyrAddr = address(bondContract);
		//uint currentResolves = resolveContract.balanceOf( pyrAddr );
		pyrColorResolves -= dissolvedResolves;
		resolvesThinColor(address(bondContract), pyrColorResolves, pyrColorResolves + dissolvedResolves);
		pushMinecart(sender);

  		sender.transfer( earned );
  	}

	function proxyAddress(address addr) public view returns(address payable addressOfProxxy){
		return proxy[addr];//address( proxies[ proxyID[addr] ]  );
	}
	function unbindResolves(uint amount) public {
  		address sender = msg.sender;
		uint totalResolves = resolveContract.balanceOf( proxyAddress(sender) );
		resolvesThinColor( sender, totalResolves - amount, totalResolves);
		_PyramidProxy(sender).transfer(sender, amount);
	}
	
	function setVotingForCR(address candidate) public {
  		address sender = msg.sender;
		//Contracts can't vote for anyone. Because then people would just evenly split the pool fund most of the time
		require( !isContract(sender) );//This could be enhanced, but this is a barebones demonstration of the powhr of resolve tokens
		uint voteWeight = _UINT(COLOREDRESOLVES,sender);//balanceOf(sender);
		votesForCR[ _ADDRESS(VOTING_FOR_CR, sender ) ] -= voteWeight;
		votingForCR[ sender ] = candidate;
		//ADDRESS_(VOTING_FOR_CR, sender, candidate);
		votesForCR[ candidate ] += voteWeight;
		//emit VoteForCandidate(msg.sender, candidate, voteWeight);
	}
	function setVotingForMR(uint MR_votingFor) internal {
  		address sender = msg.sender;
  		if(!isContract(sender)) {
			uint voteWeight = _UINT(COLOREDRESOLVES,sender);
			votesForMR[ _UINT(VOTING_FOR_MR, sender ) ] -= voteWeight;
			votingForMR[ sender ] = MR_votingFor;
			votesForMR[ MR_votingFor ] += voteWeight;
		}
		//emit VoteForMR(msg.sender, _votingForMR, voteWeight);
	}

	function pullAffiliateEarningsOnly() internal{
		if(msg.sender == communityResolve){
			pushMinecart(THIS);
			uint money_gotten = _UINT(POCKET, THIS);
			money_gotten += _UINT(POCKET, msg.sender );
			pocket[ msg.sender ] = 0;
			pocket[ THIS ] = 0;
			msg.sender.transfer(money_gotten);
		}else{
			pushMinecart(msg.sender);
			uint money_gotten = _UINT(POCKET, msg.sender );
			pocket[ msg.sender ] = 0;
			msg.sender.transfer(money_gotten);
		}
	}

	// Function that is called when a user or another contract wants to transfer funds .
	function transfer(address _to, uint _value, bytes memory _data) public returns (bool success) {
		if( balanceOf(msg.sender)-_UINT(LOCKEDRESOLVES,msg.sender) < _value ) revert();
		if( isContract(_to) ){
			return transferToContract(_to, _value, _data);
		}else{
			return transferToAddress(_to, _value, _data);
		}
	}

	// Standard function transfer similar to ERC20 transfer with no _data .
	// Added due to backwards compatibility reasons .
	function transfer(address _to, uint _value) public returns (bool success) {
		if (balanceOf(msg.sender)-_UINT(LOCKEDRESOLVES,msg.sender) < _value) revert();
		//standard function transfer similar to ERC20 transfer with no _data
		//added due to backwards compatibility reasons
		bytes memory empty;
		if(isContract(_to)){
			return transferToContract(_to, _value, empty);
		}else{
			return transferToAddress(_to, _value, empty);
		}
	}

	//assemble the given address bytecode. If bytecode exists then the _addr is a contract.
	function isContract(address _addr) internal view returns (bool is_contract) {
		uint length = 0;
		assembly {
			//retrieve the size of the code on target address, this needs assembly
			length := extcodesize(_addr)
		}
		if(length>0) {
			return true;
		}else {
			return false;
		}
	}

	//function that is called when transaction target is an address
	function transferToAddress(address _to, uint _value, bytes memory _data) private returns (bool success) {
		moveTokens(msg.sender,_to,_value);
		return true;
	}

	//function that is called when transaction target is a contract
	function transferToContract(address _to, uint _value, bytes memory _data) private returns (bool success) {
		moveTokens(msg.sender,_to,_value);
		ERC223ReceivingContract reciever = ERC223ReceivingContract(_to);
		reciever.tokenFallback(msg.sender, _value, _data);
		return true;
	}

	function moveTokens(address _from, address _to, uint _amount) internal{
		uint coloredWeight = _UINT(COLOREDRESOLVES,_from) * _amount / balanceOf(_from);

		colorShift(_from, _to, _amount);
		ensureProxy(_to);

		if(!isContract(_from)){
			votesForMR[ _UINT(VOTING_FOR_MR,_from) ] -= coloredWeight;
			votesForCR[ _ADDRESS(VOTING_FOR_CR,_from) ] -= coloredWeight;
		}

		if(!isContract(_to)){
			votesForMR[ _UINT(VOTING_FOR_MR,_to) ] += coloredWeight;
			votesForCR[ _ADDRESS(VOTING_FOR_CR,_to) ] += coloredWeight;
		}
	

		_PyramidProxy(_from ).transfer( proxyAddress(_to), _amount );
	}
	function RGB_scale(uint r, uint g, uint b, uint c, uint numerator, uint denominator) internal pure returns(uint,uint,uint,uint){
		return (r * numerator / denominator, g * numerator / denominator, b * numerator / denominator, c * numerator / denominator );
	}
	function colorShift(address _from, address _to, uint _amount) internal{
		//uint bal = proxy[_from].getBalance();
		/*uint red_ratio = redResolves[_from] * _amount / bal;
		uint green_ratio = greenResolves[_from] * _amount / bal;
		uint blue_ratio = blueResolves[_from] * _amount / bal;*/
		uint coloredResolveTotal;
		if(_from == address(bondContract) ){
			coloredResolveTotal = pyrColorResolves;
		}else{
			coloredResolveTotal = _PyramidProxy( _from ).getBalance();
		}
		(uint red_ratio, uint green_ratio, uint blue_ratio, uint color_ratio) = RGB_scale(_UINT(REDRESOLVES,_from), _UINT(GREENRESOLVES,_from), _UINT(BLUERESOLVES,_from), _UINT(COLOREDRESOLVES,_from), _amount, coloredResolveTotal );
		redResolves[_from] -= red_ratio;
		greenResolves[_from] -= green_ratio;
		blueResolves[_from] -= blue_ratio;
		coloredResolves[_from] -= color_ratio;
		redResolves[_to] += red_ratio;
		greenResolves[_to] += green_ratio;
		blueResolves[_to] += blue_ratio;/**/
		coloredResolves[_to] += color_ratio;
	}

    function allowance(address src, address guy) public view returns (uint) {
        return approvals[src][guy];
    }
    event Buy( address indexed addr, uint256 spent, uint256 bonds, uint red, uint green, uint blue);
	
	function buy(address addr, uint ETH, uint _red, uint _green, uint _blue, bool regularBuy) internal returns(uint bondsCreated){
  		//address sender = msg.sender;
		ensureProxy(addr);
		/*_red = max1(_red);
		_green = max1(_green);
		_blue = max1(_blue);*/
		if(_red>1e12) return _red = 1e12;
		if(_green>1e12) return _green = 1e12;
		if(_blue>1e12) return _blue = 1e12;

		uint fee;
		if(regularBuy){
			fee = ETH / colorFee;
		}
		uint eth4Bonds = ETH - fee;

		address payable proxyAddr = proxyAddress(addr);
		proxyAddr.transfer(eth4Bonds);
		(uint createdBonds,) = PyramidProxy( proxyAddr ).publix(5,0);/**/
		_totalBonds += createdBonds;
		bondsAddColor(addr,createdBonds, _red, _green, _blue);

		coloredBonds[addr] += createdBonds;
		pushMinecart(addr);

		if( regularBuy ){
			fee = fee/2;
			pocket[ _ADDRESS(0,addr) ] += fee;
			upline[ _ADDRESS(0,addr) ] += fee - fee/5;
			pocket[ THIS ] += fee/5;
			
			emit Buy( addr, ETH, createdBonds, _red, _green,  _blue);
		}

		if(checkMR(addr)){
			lastGateway = addr;	
		}
		return createdBonds;/**/
  	}
	function checkMR(address addr) internal view returns(bool){
  		return  addr == THIS || ( addr != nulf && addr != msg.sender && _UINT(COLOREDRESOLVES, addr) >= masternodeRequirement ) ;
  	}
	function buy(address addr, uint _red, uint _green, uint _blue, address MASTERNODE) payable public returns(uint bondsCreated){
		if( checkMR(MASTERNODE) && _ADDRESS(GATEWAY,addr) == nulf ){
			ADDRESS_(GATEWAY, msg.sender, MASTERNODE);
		}
		return buy( addr, msg.value, _red, _green, _blue, true);
	}
  	
    function transferFrom(address src, address dst, uint wad) public returns (bool){
    	address sender = msg.sender;
        require(approvals[src][sender] >=  wad);
        require(_PyramidProxy(src).getBalance() >=  wad);
        if (src != sender) {
            approvals[src][sender] -=  wad;
        }
		moveTokens(src,dst,wad);

        return true;
    }
    event Approval(address indexed src, address indexed guy, uint wad);
    function approve(address guy, uint wad) public returns (bool) {
    	address sender = msg.sender;
        approvals[sender][guy] = wad;

        emit Approval(sender, guy, wad);

        return true;
    }

  	function resolvesAddColor(address addr, uint amount , uint red, uint green, uint blue) internal{
  		redResolves[addr] += red * amount;
		greenResolves[addr] += green * amount;
		blueResolves[addr] += blue * amount;
	}
  	function bondsAddColor(address addr, uint amount , uint red, uint green, uint blue) internal{
  		redBonds[addr] += red * amount;
		greenBonds[addr] += green * amount;
		blueBonds[addr] += blue * amount;
  	}
  	function resolvesThinColor(address addr, uint newWeight, uint oldWeight) internal{
		(redResolves[addr], greenResolves[addr], blueResolves[addr], coloredResolves[addr]) = RGB_scale(_UINT(REDRESOLVES,addr), _UINT(GREENRESOLVES,addr), _UINT(BLUERESOLVES,addr), _UINT(COLOREDRESOLVES,addr), newWeight, oldWeight);
		/*redResolves[addr] = redResolves[addr] * newWeight / oldWeight;
  		greenResolves[addr] = greenResolves[addr] * newWeight / oldWeight;
  		blueResolves[addr] = blueResolves[addr] * newWeight / oldWeight;	*/
  	}
  	function bondsThinColor(address addr, uint newWeight, uint oldWeight) internal{
  		(redBonds[addr], greenBonds[addr], blueBonds[addr], coloredBonds[addr]) = RGB_scale( _UINT(REDBONDS,addr), _UINT(GREENBONDS,addr), _UINT(BLUEBONDS,addr), _UINT(COLOREDBONDS,addr), newWeight, oldWeight);
		/*redBonds[addr] = redBonds[addr] * newWeight / oldWeight;
  		greenBonds[addr] = greenBonds[addr] * newWeight / oldWeight;
  		blueBonds[addr] = blueBonds[addr] * newWeight / oldWeight;	*/
  	}
  	function RGB_bondRatio() public view returns(uint,uint,uint){
  		//uint bonds = bondBalance(msg.sender);
  		return RGB_bondRatio(msg.sender);//(redBonds[sender]/bonds, greenBonds[sender]/bonds, blueBonds[sender]/bonds);
  	}
  	function RGB_bondRatio(address addr) public view returns(uint,uint,uint){
  		uint bonds = _UINT(COLOREDBONDS,addr);
  		if (bonds==0){
  			return (0,0,0);
  		}
  		return ( _UINT(REDBONDS,addr)/bonds,  _UINT(GREENBONDS,addr)/bonds,  _UINT(BLUEBONDS,addr)/bonds);
  	}
  	function RGB_resolveRatio(address addr) public view returns(uint,uint,uint){
  		uint resolves = _UINT(COLOREDRESOLVES,addr);
  		if (resolves==0){
  			return (0,0,0);
  		}
  		return (_UINT(REDRESOLVES,addr)/resolves, _UINT(GREENRESOLVES,addr)/resolves, _UINT(BLUERESOLVES,addr)/resolves);
  	}
	function () payable external {
		if (msg.value > 0) {
			//address sender = msg.sender;
			//uint totalHoldings = bondBalance(msg.sender);
			(uint _red , uint _green, uint _blue) = RGB_bondRatio();
			buy(msg.sender, _red, _green, _blue, lastGateway);
		} else {
			withdraw( bondContract.resolveEarnings( proxyAddress(msg.sender) ) );
		}
	}/**/
	function bondBalance(address addr) public view returns(uint){
		return bondContract.balanceOf( proxyAddress(addr) );
	}
	event BondTransfer(address from, address to, uint amount, uint red, uint green, uint blue);
	function bondTransfer(address to, uint amount) public{
		address sender = msg.sender;
		uint sendersFormerTotalBonds = bondBalance(sender);
		bondsThinColor( sender, sendersFormerTotalBonds - amount, sendersFormerTotalBonds);
		(uint r, uint g, uint b) = RGB_bondRatio(sender);
		bondsAddColor( to, amount, r, g, b );
		_PyramidProxy(sender).bondTransfer( proxyAddress(to) , amount);
		emit BondTransfer(sender, to, amount, r, g, b);
	}

	//function _UINT(LOCKEDRESOLVES,address addr) internal view returns(uint){return lockedResolves[addr];}
  	function nameStake(string memory _name, bool unstake_or_stake, uint amount, address candidate) public{
  		address sender = msg.sender;
  		require( !unstake_or_stake || amount <= balanceOf(sender) - _UINT(LOCKEDRESOLVES,sender) );
  		RNS.API(sender, _name, unstake_or_stake, amount, candidate);
  		if(unstake_or_stake){
  			lockedResolves[sender] += amount;
  		}else{
  			lockedResolves[sender] -= amount;
  		}
  	}

}


contract BondContract{
	function balanceOf(address _owner) public view returns (uint256 balance);
	function sellBonds(uint amount) public returns(uint,uint);
	function getResolveContract() public view returns(address);
	function pullResolves(uint amount) public;
	function reinvestEarnings(uint amountFromEarnings) public returns(uint,uint);
	function withdraw(uint amount) public returns(uint);
	function fund() payable public returns(uint);
	function resolveEarnings(address _owner) public view returns (uint256 amount);
	function bondTransfer( address to, uint amount ) public;
}

contract ResolveContract{
	function balanceOf(address _owner) public view returns (uint256 balance);
	function transfer(address _to, uint _value) public returns (bool success);
}

contract PyramidProxy{
	ColorToken router;
	BondContract bondContract;
	ResolveContract resolveContract;
	address public THIS = address(this);

	constructor(ColorToken _router, BondContract _BondContract) public{
		router = _router;
		bondContract = _BondContract;
		resolveContract = ResolveContract( _BondContract.getResolveContract() );
	}

	modifier routerOnly{
		require(msg.sender == address(router) );
		_;
    }
	function () payable external{
		//ETH += msg.value;
	}

	function buy() internal/*___*/ returns(uint){
		//uint _ETH = ETH;
		//ETH = 0;
		return bondContract.fund.value( THIS.balance )();
	}
	function cash2Owner() internal{
		address payable owner = address(uint160( router._ADDRESS(3/*PROXY_OWNER*/, THIS ) ) );
		//uint _ETH = ETH;
		//ETH = 0;
		owner.transfer( THIS.balance );
	}
	function getBalance() external/*___*/ view returns (uint balance) {
		address bC = address(bondContract);
		if( THIS == bC ){
			return resolveContract.balanceOf( bC );
		}else{
			return resolveContract.balanceOf( THIS );	
		}
    }
    /*function resolveEarnings() internal view returns(uint){
    	return bondContract.resolveEarnings( THIS );
    }*/
    function publix(uint8 Type,uint numeric) external routerOnly() returns(uint, uint){
    	if(Type == 0){
  			return (sell(numeric),0);
		}else if(Type==1){
  			stake(numeric);
  			return (0,0);
		}else if(Type==2){
			unstake(numeric);
  			return (0,0);
		}else if(Type==3){
  			return reinvest(numeric);
		}else if(Type==4){
  			return (withdraw(numeric),0);
		}else if(Type==5){
  			return (buy(),0);
		}
    }
	function reinvest(uint amount) internal/*___*/ returns(uint,uint){
		return bondContract.reinvestEarnings( amount );
	}
	function withdraw(uint amount) internal/*___*/ returns(uint){
		uint dissolvedResolves = bondContract.withdraw( amount );
		cash2Owner();
		return dissolvedResolves;
	}
	function sell(uint amount) internal/*___*/ returns (uint){
		uint resolves;
		(,resolves) = bondContract.sellBonds(amount);
		cash2Owner();
		return resolves;
	}
	
	function stake(uint amount) internal/*___*/{
		resolveContract.transfer( address(bondContract), amount );
	}
	function transfer(address addr, uint amount) external/*___*/ routerOnly(){
		resolveContract.transfer( addr, amount );
	}
	function bondTransfer(address to, uint amount) public routerOnly(){
		bondContract.bondTransfer( to, amount );
	}
	function unstake(uint amount) internal/*___*/{
		bondContract.pullResolves( amount );
	}
}

contract ERC223ReceivingContract{
    function tokenFallback(address _from, uint _value, bytes calldata _data) external;
}

contract ResolveNamingService{
	address owner;
	mapping(uint => address) public ownerOfName;
	mapping(uint => string) public  name;
	mapping(uint => mapping(address => address)) public yourCandidateForName;
	mapping(uint => mapping(address => uint)) public votesForCandidate;
	mapping(uint => mapping(address => uint)) public candidatesWeightForName;
	mapping(address => nameList) namesInteractedWith;
	
	struct nameList{
		uint[] nameIDs;
		mapping(uint => bool) alreadyListed;
	}

	modifier ownerOnly{
		require(msg.sender == owner);
		_;
    }

	constructor(address _owner) public{
		owner = _owner;
	}
	function getNameID(string memory _name) public pure returns(uint){
		return (uint)( keccak256( abi.encodePacked( _name , "these") ) );
	}
	event Stake( address user, string _name, uint amount, address candidate );
	event Unstake( address user, string _name, uint amount );
	event NewNameOwner( uint nameID, address owner );
	function API( address user, string calldata _name, bool unstake_or_stake, uint amount, address candidate ) external ownerOnly(){
		uint nameID = getNameID(_name);
		if( unstake_or_stake ){
			//STAKE
			if(!namesInteractedWith[user].alreadyListed[nameID]){
				namesInteractedWith[user].nameIDs.push(nameID);
				namesInteractedWith[user].alreadyListed[nameID] = true;
			}
			if(!namesInteractedWith[0x0000000000000000000000000000000000000000].alreadyListed[nameID]){
				namesInteractedWith[0x0000000000000000000000000000000000000000].nameIDs.push(nameID);
				namesInteractedWith[0x0000000000000000000000000000000000000000].alreadyListed[nameID] = true;
			}
			if( bytes( name[nameID] ).length==0 ) name[nameID] = _name;
			
			uint carryOverWeight = 0;
			
			if(candidate != yourCandidateForName[nameID][user]){
				carryOverWeight = votesForCandidate[nameID][user];
				candidatesWeightForName[nameID][candidate] -= carryOverWeight;
			}
			yourCandidateForName[nameID][user] = candidate;
			votesForCandidate[nameID][user] += amount;
			candidatesWeightForName[nameID][candidate] += amount + carryOverWeight;

			if( candidatesWeightForName[nameID][candidate] > candidatesWeightForName[nameID][ ownerOfName[nameID] ] ){
				ownerOfName[nameID] = candidate;
				emit NewNameOwner( nameID, candidate );
			}
			emit Stake(user, _name, amount, candidate);
		
		}else{
			//UNSTAKE
			require( amount <= votesForCandidate[nameID][user], "Not that many resolve tokens locked into that name" );
			
			votesForCandidate[nameID][user] -= amount;
			candidatesWeightForName[nameID][ yourCandidateForName[nameID][user] ] -= amount;
			emit Unstake(user, _name, amount);
		}
	}

	function getNameList(address user) public view returns( uint[] memory,  uint[] memory, address[] memory, address[] memory ){
		uint L = namesInteractedWith[user].nameIDs.length;
		uint[] memory nameIDs = new uint[](L);
		uint[] memory yourWeights = new uint[](L);
		address[] memory yourCandidate = new address[](L);
		address[] memory currentHolder = new address[](L);
		uint nameID;
		for(uint i = 0; i < L; i+=1){
			nameID = namesInteractedWith[user].nameIDs[i];
			nameIDs[i] = nameID;
			yourWeights[i] = votesForCandidate[nameID][user];
			yourCandidate[i] = yourCandidateForName[nameID][user];
			currentHolder[i] = ownerOfName[nameID];
		}
	}
}