pragma solidity ^ 0.5.1;
contract ColorToken{
	BondContract public bondContract;
	ResolveContract public resolveContract;
	address lastGateway;
	address communityResolve;

	string public name = "Color Token";
    string public symbol = "RGB";
    uint8 constant public decimals = 18;
	uint _totalSupply;
	uint masternodeFee = 10; // 10%

	mapping(address => address payable) proxy;
	mapping(address => address) proxyOwner;

	mapping(address => uint256) public redBonds;
	mapping(address => uint256) public greenBonds;
	mapping(address => uint256) public blueBonds;

	mapping(address => uint256) public redResolves;
	mapping(address => uint256) public greenResolves;
	mapping(address => uint256) public blueResolves;

	mapping(address => mapping(address => uint)) approvals;

	mapping(address => address) gateway;
	mapping(address => uint256) public pocket;
	mapping(address => uint256) public upline;
	mapping(address => address) public minecart;

	mapping(address => address) public votingFor;
	mapping(address => uint256) public votesFor;
	
	constructor(address _bondContract) public{	
		bondContract = BondContract(_bondContract);
		resolveContract = ResolveContract( bondContract.getResolveContract() );
		communityResolve = msg.sender;
		lastGateway = address(this);
	}

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
	function balanceOf(address _owner) public view returns (uint balance) {
        return PyramidProxy(proxy[_owner]).getBalance();
    }
	function max1(uint x) internal pure returns (uint){
		if(x>1e18)
			return 1e18;
		else
			return x;
	}
	function ensureProxy(address addr) internal returns(address proxyAddr){
		if( address(proxy[addr]) == 0x0000000000000000000000000000000000000000){
			PyramidProxy prox = new PyramidProxy( this, bondContract );
			proxy[addr] = address(prox);
			proxyOwner[ address( proxy[addr] ) ] = addr;
		}
		return address( proxy[addr] );
	}
	event Buy( address indexed addr, uint256 spent, uint256 bonds, uint red, uint green, uint blue);
	function buy(uint _red, uint _green, uint _blue) payable public {
		buy( msg.value, _red, _green, _blue, true);
	}
	function buy(uint ETH, uint _red, uint _green, uint _blue, bool EMIT) payable public returns(uint bondsCreated){
		address sender = msg.sender;
		ensureProxy(sender);
		_red = max1(_red);
		_green = max1(_green);
		_blue = max1(_blue);
		uint fee = ETH / masternodeFee;
		uint eth4Bonds = ETH - fee;

		address payable proxyAddr = address( proxy[sender] ); 
		proxyAddr.transfer(eth4Bonds);
		uint createdBonds = PyramidProxy(proxy[sender]).buy();
		bondsAddColor(sender,createdBonds, _red, _green, _blue);
		
		pocket[ gateway[sender] ] += fee/2;
		upline[ gateway[sender] ] += fee/2;
		pushMinecart();

		if( EMIT ){
			emit Buy( sender, ETH, createdBonds, _red, _green,  _blue);
		}

		if( bondContract.balanceOf( address(proxy[sender]) ) > 10000*1e12 ){
			lastGateway = sender;	
		}
		return createdBonds;
  	}

  	function pushMinecart() internal{
  		pushMinecart(msg.sender);
  	}

  	function pushMinecart(address addr) internal{
  		/*if(gateway[addr] == 0x0000000000000000000000000000000000000000 || bondContract.balanceOf( address(proxy[ gateway[addr] ]) ) < 10000*1e12){
			gateway[addr] = lastGateway;
		}
  		if( minecart[addr] == address(this) || minecart[addr] == 0x0000000000000000000000000000000000000000){
			minecart[addr] = addr;
		}else{
			minecart[addr] = gateway[ minecart[addr] ];	
		}
		address dropOff = minecart[addr];
		pocket[ dropOff ] += upline[ dropOff ] / 2;
		upline[ gateway[dropOff] ] += upline[ dropOff ] / 2;
		upline[ dropOff ] = 0;*/
  	}

  	event Sell( address indexed addr, uint256 bondsSold, uint256 resolves, uint red, uint green, uint blue);
  	function sell(uint amountToSell) public{
  		uint bondsBefore = bondContract.balanceOf( address(proxy[msg.sender]) );
  		uint mintedResolves = PyramidProxy(proxy[msg.sender]).sell(amountToSell);

  		uint _red = redBonds[msg.sender] / bondsBefore;
  		uint _green = greenBonds[msg.sender] / bondsBefore;
  		uint _blue = blueBonds[msg.sender] / bondsBefore;
		resolvesAddColor(msg.sender, mintedResolves, _red, _green, _blue);
  		votesFor[ votingFor[msg.sender] ] += mintedResolves;
		_totalSupply += mintedResolves;
		emit Sell(msg.sender, amountToSell, mintedResolves, _red, _green, _blue );

  		bondsThinColor(msg.sender, bondsBefore - amountToSell  , bondsBefore);
  		pushMinecart();
  	}
  	function stake(uint amountToStake) public{
		PyramidProxy(proxy[msg.sender]).stake( amountToStake );
		colorShift(msg.sender, address(bondContract), amountToStake );
		pushMinecart();
  	}
  	function unstake(uint amountToUnstake) public{
		PyramidProxy(proxy[msg.sender]).unstake( amountToUnstake );
		colorShift(address(bondContract), msg.sender, amountToUnstake );
		pushMinecart();
  	}
  	function reinvest() public{
  		address sender = msg.sender;
  		address proxyAddr = address( proxy[sender] );
  		uint red = redBonds[sender] / bondContract.balanceOf( proxyAddr );
		uint green = greenBonds[sender] / bondContract.balanceOf( proxyAddr );
		uint blue = blueBonds[sender] / bondContract.balanceOf( proxyAddr );

  		uint createdBonds;
  		uint dissolvedResolves;
		(createdBonds, dissolvedResolves) = PyramidProxy(proxy[sender]).reinvest();
		
		createdBonds += buy( pocket[sender], red, green, blue, false);
		pocket[sender] = 0;

		bondsAddColor(sender, createdBonds, red, green, blue);
		// update core contract's Resolve color
		address pyrAddr = address(bondContract);
		uint currentResolves = resolveContract.balanceOf( pyrAddr );
		resolvesThinColor(pyrAddr, currentResolves, currentResolves + dissolvedResolves);
		pushMinecart();
  	}
  	function withdraw() public{
  		uint dissolvedResolves = PyramidProxy(proxy[msg.sender]).withdraw();
  		uint earned = pocket[msg.sender];
  		pocket[msg.sender] = 0;
  		msg.sender.transfer( earned );
  		// update core contract's Resolve color
		address pyrAddr = address(bondContract);
		uint currentResolves = resolveContract.balanceOf( pyrAddr );
		resolvesThinColor(pyrAddr, currentResolves, currentResolves + dissolvedResolves);
		pushMinecart();
  	}

	function proxyAddress(address addr) public view returns(address addressOfProxxy){
		return address( proxy[addr] );
	}
	function getProxyOwner(address proxyAddr) public view returns(address ownerAddress){
		return proxyOwner[proxyAddr];
	}
	function unbindResolves(uint amount) public {
		uint totalResolves = resolveContract.balanceOf( proxyAddress(msg.sender) );
		resolvesThinColor( msg.sender, totalResolves - amount, totalResolves);
		PyramidProxy(proxy[msg.sender]).transfer(msg.sender, amount);
	}
	function setVotingFor(address candidate) public {
		//Contracts can't vote for anyone. Because then people would just evenly split the pool fund most of the time
		require( !isContract(msg.sender), "Contracts can't vote for anyone.");//This could be enhanced, but this is a barebones demonstration of the powhr of resolve tokens
		uint voteWeight = balanceOf(msg.sender);
		votesFor[ votingFor[ msg.sender ] ] -= voteWeight;
		votingFor[ msg.sender ] = candidate;
		votesFor[ candidate ] += voteWeight;
	}
	function assertNewCommunityResolve(address candidate) public {
		if( votesFor[candidate] > votesFor[communityResolve] ){
			communityResolve = candidate; 
		}
	}

	function GET_FUNDED() public{
		if(msg.sender == communityResolve){
			uint money_gotten = pocket[ address(this) ];
			pocket[ address(this) ] = 0;
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

		PyramidProxy(proxy[_from]).transfer( address(proxy[_to]), _amount );
	}
	function colorShift(address _from, address _to, uint _amount) internal{
		uint red_ratio = redResolves[_from] * _amount / PyramidProxy(proxy[_from]).getBalance();
		uint green_ratio = greenResolves[_from] * _amount / PyramidProxy(proxy[_from]).getBalance();
		uint blue_ratio = blueResolves[_from] * _amount / PyramidProxy(proxy[_from]).getBalance();
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
        require(approvals[src][msg.sender] >=  wad, "That amount is not approved");
        require(PyramidProxy( proxy[src]).getBalance() >=  wad, "That amount is not available from this wallet");
        if (src != msg.sender) {
            approvals[src][msg.sender] -=  wad;
        }
		moveTokens(src,dst,wad);

        return true;
    }
    event Approval(address indexed src, address indexed guy, uint wad);
    function approve(address guy, uint wad) public returns (bool) {
        approvals[msg.sender][guy] = wad;

        emit Approval(msg.sender, guy, wad);

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
		redResolves[addr] = redResolves[addr] * newWeight / oldWeight;
  		greenResolves[addr] = greenResolves[addr] * newWeight / oldWeight;
  		blueResolves[addr] = blueResolves[addr] * newWeight / oldWeight;	
  	}
  	function bondsThinColor(address addr, uint newWeight, uint oldWeight) internal{
		redBonds[addr] = redBonds[addr] * newWeight / oldWeight;
  		greenBonds[addr] = greenBonds[addr] * newWeight / oldWeight;
  		blueBonds[addr] = blueBonds[addr] * newWeight / oldWeight;	
  	}

	function () payable external {
		if (msg.value > 0) {
			address sender = msg.sender;
			uint totalHoldings = bondContract.balanceOf( address(proxy[sender]) );
			uint _red = redBonds[sender]/totalHoldings;
			uint _green = greenBonds[sender]/totalHoldings;
			uint _blue = blueBonds[sender]/totalHoldings;
			buy(_red, _green, _blue);
		} else {
			//withdraw();
		}
	}
	event BondTransfer(address from, address to, uint amount, uint red, uint green, uint blue);
	function bondTransfer(address to, uint amount) public{
		address sender = msg.sender;
		uint sendersFormerTotalBonds = bondBalance(sender);
		bondsThinColor( sender, sendersFormerTotalBonds - amount, sendersFormerTotalBonds);
		(uint r, uint g, uint b) = RGB_bondRatio(sender);
		bondsAddColor( to, amount, r, g, b );
		proxy[sender].bondTransfer( proxyAddress(to) , amount);
		emit BondTransfer(sender, to, amount, r, g, b);
	}
}


contract BondContract{
	function balanceOf(address _owner) public view returns (uint256 balance);
	function sellBonds(uint amount) public returns(uint,uint);
	function getResolveContract() public view returns(address);
	function pullResolves(uint amount) external;
	function reinvestEarnings(uint amountFromEarnings) public returns(uint,uint);
	function withdraw(uint amount) public returns(uint);
	function fund() payable public returns(uint);
	function resolveEarnings(address _owner) public view returns (uint256 amount);
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

	constructor(ColorToken _router, BondContract _BondContract) public{
		router = _router;
		bondContract = _BondContract;
		resolveContract = ResolveContract( _BondContract.getResolveContract() );
	}

	modifier routerOnly{
		require(msg.sender == address(router));
		_;
    }

	function () payable external routerOnly(){
		ETH += msg.value;
	}
	function getBalance() public view returns (uint balance) {
		address bC = address(bondContract);
		if( address(this) == bC ){
			return resolveContract.balanceOf( bC );
		}else{
			return resolveContract.balanceOf( address(this) );	
		}
    }
	function buy() public routerOnly() returns(uint){
		uint _ETH = ETH;
		ETH = 0;
		return bondContract.fund.value( _ETH )();
	}
	function reinvest() public routerOnly() returns(uint,uint){
		return bondContract.reinvestEarnings( bondContract.resolveEarnings( address(this) ) );
	}
	function withdraw() public routerOnly() returns(uint){
		uint dissolvedResolves = bondContract.withdraw( bondContract.resolveEarnings( address(this) ) );
		cash2Owner();
		return dissolvedResolves;
	}
	function sell(uint amount) public routerOnly() returns (uint){
		uint resolves;
		(,resolves) = bondContract.sellBonds(amount);
		cash2Owner();
		return resolves;
	}
	function cash2Owner() internal{
		address payable owner = address(uint160( router.getProxyOwner( address(this) ) ) );
		uint _ETH = ETH;
		ETH = 0;
		owner.transfer( _ETH );
	}
	function stake(uint amount) public routerOnly() returns(uint){
		resolveContract.transfer( address(bondContract), amount );
	}
	function transfer(address addr, uint amount) public routerOnly(){
		resolveContract.transfer( addr, amount );
	}
	
	function unstake(uint amount) public routerOnly(){
		bondContract.pullResolves( amount );
	}
}

contract ERC223ReceivingContract{
    function tokenFallback(address _from, uint _value, bytes calldata _data) external;
}