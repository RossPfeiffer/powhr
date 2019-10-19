pragma solidity ^ 0.5.11;
contract ColorToken{
	BondContract public bondContract;
	ResolveContract public resolveContract;
	address lastGateway;
	address communityResolve;
	address THIS = address(this);

	string public name = "Color Token";
    string public symbol = "RGB";
    uint8 constant public decimals = 18;
	uint _totalSupply;
	uint public _totalBonds;
	uint masternodeFee = 10; // 10%

	mapping(address => address payable) proxy;
	PyramidProxy[] proxies;
	mapping(address => address) proxyOwner;

	mapping(address => uint256) redBonds;
	mapping(address => uint256) greenBonds;
	mapping(address => uint256) blueBonds;

	mapping(address => uint256) redResolves;
	mapping(address => uint256) greenResolves;
	mapping(address => uint256) blueResolves;

	mapping(address => mapping(address => uint)) approvals;

	mapping(address => address) gateway;
	mapping(address => uint256) public pocket;
	mapping(address => uint256) public upline;
	mapping(address => address) public minecart;

	mapping(address => address) public votingFor;
	mapping(address => uint256) public votesFor;
	
	constructor(address _bondContract) public{
		bondContract = BondContract( _bondContract );
		resolveContract = ResolveContract( bondContract.getResolveContract() );
		communityResolve = msg.sender;
		lastGateway = THIS;
	}

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
	function balanceOf(address addr) public view returns (uint balance) {
        return PyramidProxy( proxy[addr] ).getBalance();
    }
	function max1(uint x) internal pure returns (uint){
		if(x>1e12)
			return 1e12;
		else
			return x;
	}
	/*function proxy(address addr) returns(PyramidProxy){
		proxies[proxyID[addr]]
	}*/
	function ensureProxy(address addr) internal{
		if( proxy[addr] == 0x0000000000000000000000000000000000000000){
			//PyramidProxy p = new PyramidProxy( this, bondContract );
			proxies.push( new PyramidProxy( this, bondContract ) );
			proxy[addr] = address( proxies[proxies.length-1] );
			proxyOwner[ proxy[addr] ] = addr;
		}
	}
	event Buy( address indexed addr, uint256 spent, uint256 bonds, uint red, uint green, uint blue);
	function buy(uint _red, uint _green, uint _blue) payable public returns(uint bondsCreated){
		return buy( msg.value, _red, _green, _blue, true);
	}
	function buy(uint ETH, uint _red, uint _green, uint _blue, bool EMIT) payable public returns(uint bondsCreated){
  		address sender = msg.sender;
		ensureProxy(sender);
		_red = max1(_red);
		_green = max1(_green);
		_blue = max1(_blue);
		uint fee = ETH / masternodeFee;
		uint eth4Bonds = ETH - fee;

		address payable proxyAddr = proxyAddress(sender);
		proxyAddr.transfer(eth4Bonds);
		uint createdBonds = PyramidProxy( proxyAddr ).buy();/**/
		_totalBonds += createdBonds;
		bondsAddColor(sender,createdBonds, _red, _green, _blue);

		pocket[ gateway[sender] ] += fee/2;
		upline[ gateway[sender] ] += (fee/2)-(fee/2)/5;
		pocket[ THIS ] += (fee/2)/5;
		pushMinecart();

		if( EMIT ){
			emit Buy( sender, ETH, createdBonds, _red, _green,  _blue);
		}

		if( bondBalance(sender) > 10000*1e12 ){
			lastGateway = sender;	
		}
		return createdBonds;/**/
  	}

  	function pushMinecart() public{
  		pushMinecart(msg.sender);
  	}

  	function pushMinecart(address addr) public{
  		if(gateway[addr] == 0x0000000000000000000000000000000000000000 || bondBalance( gateway[addr] ) < 10000*1e12){
			gateway[addr] = lastGateway;
		}
  		if( minecart[addr] == THIS || minecart[addr] == 0x0000000000000000000000000000000000000000){
			minecart[addr] = addr;
		}else{
			minecart[addr] = gateway[ minecart[addr] ];	
		}
		address dropOff = minecart[addr];
		uint up = upline[ dropOff ];
		pocket[ dropOff ] +=  up/5;
		upline[ gateway[dropOff] ] += up - up/5 ;
		upline[ dropOff ] = 0;/**/
  	}

  	event Sell( address indexed addr, uint256 bondsSold, uint256 resolves, uint red, uint green, uint blue);
  	function sell(uint amountToSell) public{
  		address sender = sender;
  		uint bondsBefore = bondBalance(sender);
  		(uint _red, uint _green, uint _blue) = RGB_bondRatio();
  		uint mintedResolves = PyramidProxy( proxyAddress(sender) ).sell(amountToSell);
  		_totalBonds -= amountToSell;
  		/*uint _red = redBonds[sender] / bondsBefore;
  		uint _green = greenBonds[sender] / bondsBefore;
  		uint _blue = blueBonds[sender] / bondsBefore;*/
		resolvesAddColor(sender, mintedResolves, _red, _green, _blue);
  		votesFor[ votingFor[sender] ] += mintedResolves;
		_totalSupply += mintedResolves;
		emit Sell(sender, amountToSell, mintedResolves, _red, _green, _blue );

  		bondsThinColor(msg.sender, bondsBefore - amountToSell, bondsBefore);
  		pushMinecart();
  	}
  	function stake(uint amountToStake) public{
  		address sender = msg.sender;
		PyramidProxy( proxyAddress(sender) ).stake( amountToStake );
		colorShift(sender, address(bondContract), amountToStake );
		pushMinecart();
  	}
  	function unstake(uint amountToUnstake) public{
  		address sender = msg.sender;
		PyramidProxy(proxy[sender]).unstake( amountToUnstake );
		colorShift(address(bondContract), sender, amountToUnstake );
		pushMinecart();
  	}/**/
  	function reinvest(uint amount) public{
  		address sender = msg.sender;
  		//address proxyAddr = proxyAddress( sender );
  		//uint bal = bondContract.balanceOf( proxyAddr );
  		/*uint red = redBonds[sender] / bal;
		uint green = greenBonds[sender] / bal;
		uint blue = blueBonds[sender] / bal;*/
		(uint red, uint green, uint blue) = RGB_bondRatio();

  		uint createdBonds;
  		uint dissolvedResolves;
		(createdBonds, dissolvedResolves) = PyramidProxy( proxyAddress(sender) ).reinvest(amount);
		
		createdBonds += buy( pocket[sender], red, green, blue, false);
		_totalBonds += createdBonds;
		pocket[sender] = 0;

		bondsAddColor(sender, createdBonds, red, green, blue);
		// update core contract's Resolve color
		address pyrAddr = address(bondContract);
		uint currentResolves = resolveContract.balanceOf( pyrAddr );
		resolvesThinColor(pyrAddr, currentResolves, currentResolves + dissolvedResolves);
		pushMinecart();
  	}
  	function withdraw(uint amount) public{
  		address payable sender = msg.sender;
  		uint dissolvedResolves = PyramidProxy(proxy[sender]).withdraw(amount);
  		uint earned = pocket[sender];
  		pocket[sender] = 0;
  		sender.transfer( earned );
  		// update core contract's Resolve color
		address pyrAddr = address(bondContract);
		uint currentResolves = resolveContract.balanceOf( pyrAddr );
		resolvesThinColor(pyrAddr, currentResolves, currentResolves + dissolvedResolves);
		pushMinecart();
  	}

	function proxyAddress(address addr) public view returns(address payable addressOfProxxy){
		return address(proxy[addr]);//address( proxies[ proxyID[addr] ]  );
	}
	function getProxyOwner(address proxyAddr) public view returns(address ownerAddress){
		return proxyOwner[proxyAddr];
	}
	function unbindResolves(uint amount) public {
  		address sender = msg.sender;
		uint totalResolves = resolveContract.balanceOf( proxyAddress(sender) );
		resolvesThinColor( sender, totalResolves - amount, totalResolves);
		PyramidProxy( proxyAddress(sender) ).transfer(sender, amount);
	}
	function setVotingFor(address candidate) public {
  		address sender = msg.sender;
		//Contracts can't vote for anyone. Because then people would just evenly split the pool fund most of the time
		require( !isContract(sender) );//This could be enhanced, but this is a barebones demonstration of the powhr of resolve tokens
		uint voteWeight = balanceOf(sender);
		votesFor[ votingFor[ sender ] ] -= voteWeight;
		votingFor[ sender ] = candidate;
		votesFor[ candidate ] += voteWeight;
	}
	function assertNewCommunityResolve(address candidate) public {
		if( votesFor[candidate] > votesFor[communityResolve] ){
			communityResolve = candidate; 
		}
	}

	function GET_FUNDED() public{
		if(msg.sender == communityResolve){
			uint money_gotten = pocket[ THIS ];
			pocket[ THIS ] = 0;
			msg.sender.transfer(money_gotten);
			pushMinecart();
		}
	}

	// Function that is called when a user or another contract wants to transfer funds .
	function transfer(address _to, uint _value, bytes memory _data) public returns (bool success) {
		if( balanceOf(msg.sender) < _value ) revert();
		if( isContract(_to) ){
			return transferToContract(_to, _value, _data);
		}else{
			return transferToAddress(_to, _value, _data);
		}
	}

	// Standard function transfer similar to ERC20 transfer with no _data .
	// Added due to backwards compatibility reasons .
	function transfer(address _to, uint _value) public returns (bool success) {
		if (balanceOf(msg.sender) < _value) revert();
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
	function isContract(address _addr) public view returns (bool is_contract) {
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
		colorShift(_from, _to, _amount);
		ensureProxy(_to);
		
		votesFor[ votingFor[_from] ] -= _amount;
		votesFor[ votingFor[_to] ] += _amount;

		PyramidProxy(proxy[_from]).transfer( proxyAddress(_to), _amount );
	}
	function RGB_scale(uint r, uint g, uint b, uint numerator, uint denominator) internal pure returns(uint,uint,uint){
		return (r * numerator / denominator, g * numerator / denominator, b * numerator / denominator );
	}
	function colorShift(address _from, address _to, uint _amount) internal{
		//uint bal = proxy[_from].getBalance();
		/*uint red_ratio = redResolves[_from] * _amount / bal;
		uint green_ratio = greenResolves[_from] * _amount / bal;
		uint blue_ratio = blueResolves[_from] * _amount / bal;*/
		(uint red_ratio, uint green_ratio, uint blue_ratio) = RGB_scale(redResolves[_from], greenResolves[_from], blueResolves[_from], _amount, PyramidProxy(proxy[_from]).getBalance() );
		redResolves[_from] -= red_ratio;
		greenResolves[_from] -= green_ratio;
		blueResolves[_from] -= blue_ratio;
		redResolves[_to] += red_ratio;
		greenResolves[_to] += green_ratio;
		blueResolves[_to] += blue_ratio;
	}

    function allowance(address src, address guy) public view returns (uint) {
        return approvals[src][guy];
    }

    function transferFrom(address src, address dst, uint wad) public returns (bool){
    	address sender = msg.sender;
        require(approvals[src][sender] >=  wad);
        require(PyramidProxy(proxy[src]).getBalance() >=  wad);
        if (src != sender) {
            approvals[src][sender] -=  wad;
        }
		moveTokens(src,dst,wad);

        return true;
    }
    event Approval(address indexed src, address indexed guy, uint wad);
    	address sender = msg.sender;
    function approve(address guy, uint wad) public returns (bool) {
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
		(redResolves[addr], greenResolves[addr], blueResolves[addr]) = RGB_scale(redResolves[addr], greenResolves[addr], blueResolves[addr], newWeight, oldWeight);
		/*redResolves[addr] = redResolves[addr] * newWeight / oldWeight;
  		greenResolves[addr] = greenResolves[addr] * newWeight / oldWeight;
  		blueResolves[addr] = blueResolves[addr] * newWeight / oldWeight;	*/
  	}
  	function bondsThinColor(address addr, uint newWeight, uint oldWeight) internal{
  		(redBonds[addr], greenBonds[addr], blueBonds[addr]) = RGB_scale(redBonds[addr], greenBonds[addr], blueBonds[addr], newWeight, oldWeight);
		/*redBonds[addr] = redBonds[addr] * newWeight / oldWeight;
  		greenBonds[addr] = greenBonds[addr] * newWeight / oldWeight;
  		blueBonds[addr] = blueBonds[addr] * newWeight / oldWeight;	*/
  	}
  	function RGB_bondRatio() public view returns(uint,uint,uint){
  		//uint bonds = bondBalance(msg.sender);
  		return RGB_bondRatio(msg.sender);//(redBonds[sender]/bonds, greenBonds[sender]/bonds, blueBonds[sender]/bonds);
  	}
  	function RGB_bondRatio(address addr) public view returns(uint,uint,uint){
  		uint bonds = bondBalance(addr);
  		return (redBonds[sender]/bonds, greenBonds[sender]/bonds, blueBonds[sender]/bonds);
  	}
  	function RGB_resolveRatio(address addr) public view returns(uint,uint,uint){
  		uint resolves = balanceOf(addr);
  		return (redResolves[sender]/resolves, greenResolves[sender]/resolves, blueResolves[sender]/resolves);
  	}
	function () payable external {
		if (msg.value > 0) {
			//address sender = msg.sender;
			//uint totalHoldings = bondBalance(msg.sender);
			(uint _red , uint _green, uint _blue) = RGB_bondRatio();
			/*redBonds[sender]/totalHoldings;
			 = greenBonds[sender]/totalHoldings;
			 = blueBonds[sender]/totalHoldings;*/
			buy(_red, _green, _blue);
		} else {
			withdraw( bondContract.resolveEarnings( proxyAddress(msg.sender) ) );
		}
	}

	function bondBalance(address addr) public view returns(uint){
		return bondContract.balanceOf( proxyAddress(addr) );
	}
	/*event BondTransfer(address from, address to, uint amount, uint red, uint green, uint blue);
	function bondTransfer(address to, uint amount) public{
		address sender = msg.sender;
		uint sendersFormerTotalBonds = bondBalance(sender);
		bondsThinColor( sender, sendersFormerTotalBonds - amount, sendersFormerTotalBonds);
		(uint r, uint g, uint b) = RGB_bondRatio(sender);
		bondsAddColor( to, amount, r, g, b );
		PyramidProxy(proxy[sender]).bondTransfer( proxyAddress(to) , amount);
		emit BondTransfer(sender, to, amount, r, g, b);
	}*/
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
	//function bondTransfer( address to, uint amount ) public;
}

contract ResolveContract{
	function balanceOf(address _owner) public view returns (uint256 balance);
	function transfer(address _to, uint _value) public returns (bool success);
}

contract PyramidProxy{
	ColorToken router;
	BondContract public bondContract;
	ResolveContract public resolveContract;
	uint ETH;
	address THIS = address(this);

	constructor(ColorToken _router, BondContract _BondContract) public{
		router = _router;
		bondContract = _BondContract;
		resolveContract = ResolveContract( _BondContract.getResolveContract() );
	}

	modifier routerOnly{
		require(msg.sender == address(router));
		_;
    }
	function () payable external{
		//ETH += msg.value;
	}

	function buy() public routerOnly() returns(uint){
		//uint _ETH = ETH;
		//ETH = 0;
		return bondContract.fund.value( THIS.balance )();
	}
	function cash2Owner() internal{
		address payable owner = address(uint160( router.getProxyOwner( THIS ) ) );
		//uint _ETH = ETH;
		//ETH = 0;
		owner.transfer( THIS.balance );
	}
	function getBalance() public view returns (uint balance) {
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
	function reinvest(uint amount) public routerOnly() returns(uint,uint){
		return bondContract.reinvestEarnings( amount );
	}
	function withdraw(uint amount) public routerOnly() returns(uint){
		uint dissolvedResolves = bondContract.withdraw( amount );
		cash2Owner();
		return dissolvedResolves;
	}
	function sell(uint amount) public routerOnly() returns (uint){
		uint resolves;
		(,resolves) = bondContract.sellBonds(amount);
		cash2Owner();
		return resolves;
	}
	
	function stake(uint amount) public routerOnly(){
		resolveContract.transfer( address(bondContract), amount );
	}
	function transfer(address addr, uint amount) public routerOnly(){
		resolveContract.transfer( addr, amount );
	}
	/*function bondTransfer(address to, uint amount) public routerOnly(){
		bondContract.bondTransfer( to, amount );
	}*/
	function unstake(uint amount) public routerOnly(){
		bondContract.pullResolves( amount );
	}
}

contract ERC223ReceivingContract{
    function tokenFallback(address _from, uint _value, bytes calldata _data) external;
}