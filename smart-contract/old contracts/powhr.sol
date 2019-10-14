	pragma solidity ^ 0.5.1;
	contract PoWHr{
		// scaleFactor is used to convert Ether into bonds and vice-versa: they're of different
		// orders of magnitude, hence the need to bridge between the two.
		uint256 constant scaleFactor = 0x10000000000000000;

		int constant crr_n = 1;
		int constant crr_d = 2;

		int constant public price_coeff = -0x1337FA66607BADA55;

		// Typical values that we have to declare.
		string constant public name = "Bond";
		string constant public symbol = "BOND";
		uint8 constant public decimals = 12;

		// Array between each address and their number of bonds.
		mapping(address => uint256) public holdings;
		// For calculating resolves minted
		mapping(address => uint256) public avgFactor_ethSpent;
		// For calculating hodl multiplier resolves minted
		mapping(address => uint256) public avgFactor_buyInTimeSum;
		// Array between each address and their number of resolves being staked.
		mapping(address => uint256) public resolveWeight;
		// color
		mapping(address => uint256) public red;
		mapping(address => uint256) public green;
		mapping(address => uint256) public blue;

		// Array between each address and how much Ether has been paid out to it.
		// Note that this is scaled by the scaleFactor variable.
		mapping(address => int256) public payouts;

		// Variable tracking how many bonds are in existence overall.
		uint256 public totalSupply;

		// The total number of resolve bonds being staked in this contract
		uint256 public dissolvingResolves;
		// The total volume of resolves going into the contract since t0
		uint256 public dissolved;

		// For Current contract balance
		uint public contractBalance;

		// easing: make the fee manageable as the contract is scaling to the size of the ecosystem.
		uint256 public buySum;
		uint256 public sellSum;

		// For calculating the hodl multiplier. Weighted average release time
		uint public avgFactor_releaseWeight;
		uint public avgFactor_releaseTimeSum;
		// base time on when the contract was created
		uint public genesis;

		// Aggregate sum of all payouts.
		// Note that this is scaled by the scaleFactor variable.
		int256 totalPayouts;

		// Variable tracking how much Ether each token is currently worth.
		// Note that this is scaled by the scaleFactor variable.
		uint256 earningsPerResolve;

		//The resolve token contract
		ResolveToken public resolveToken;

		constructor() public{
			genesis = now;
			resolveToken = new ResolveToken( address(this) );
		}

		// The following functions are used by the front-end for display purposes.
		// Returns the number of bonds currently held by _owner.
		function balanceOf(address _owner) public view returns (uint256 balance) {
			return holdings[_owner];
		}

		function fluxFee(uint paidAmount) public view returns (uint fee) {
			if (dissolvingResolves == 0)
				return 0;
			
			uint totalResolveSupply = resolveToken.totalSupply() - dissolved;
			return paidAmount * dissolvingResolves / totalResolveSupply * sellSum / buySum;
		}

		// Converts the Ether accrued as resolveEarnings back into bonds without having to
		// withdraw it first. Saves on gas and potential price spike loss.
		event Reinvest( address indexed addr, uint256 reinvested, uint256 dissolve, uint256 bonds, uint256 resolveTax);
		function reinvestEarnings(uint amountFromEarnings) public {
			// Retrieve the resolveEarnings associated with the address the request came from.		
			uint totalEarnings = resolveEarnings(msg.sender);
			require(amountFromEarnings <= totalEarnings, "the amount exceeds total earnings");
			uint oldWeight = resolveWeight[msg.sender];
			resolveWeight[msg.sender] = oldWeight *  (totalEarnings - amountFromEarnings) / totalEarnings;
			uint weightDiff = oldWeight - resolveWeight[msg.sender];
			dissolved += weightDiff;
			dissolvingResolves -= weightDiff;

			//something about invariance
			int resolvePayoutDiff  = (int256) (earningsPerResolve * weightDiff);

			// Update the payouts array, incrementing the request address by `balance`.
			payouts[msg.sender] += (int256) (amountFromEarnings * scaleFactor) - resolvePayoutDiff;

			// Increase the total amount that's been paid out to maintain invariance.
			totalPayouts += (int256) (amountFromEarnings * scaleFactor) - resolvePayoutDiff;

			// Assign balance to a new variable.
			uint value_ = (uint) (amountFromEarnings);

			// If your resolveEarnings are worth less than 1 szabo, or more than a million Ether
			// (in which case, why are you even here), abort.
			if (value_ < 0.000001 ether || value_ > 1000000 ether)
				revert();

			// msg.sender is the address of the caller.
			address sender = msg.sender;

			// Calculate the fee
			uint fee = fluxFee(value_);

			// The amount of Ether used to purchase new bonds for the caller
			uint numEther = value_ - fee;
			buySum += numEther;

			//resolve reward tracking stuff
			uint currentTime = NOW();
			avgFactor_ethSpent[msg.sender] += numEther;
			avgFactor_buyInTimeSum[msg.sender] += currentTime * scaleFactor * numEther;

			// The number of bonds which can be purchased for numEther.
			uint createdBonds = calculateBondsFromReinvest(numEther, amountFromEarnings);

			// Check that we have bonds in existence (this should always be true), or
			// else you're gonna have a bad time.
			uint resolveFee;
			if (totalSupply > 0 && fee > 0) {
				resolveFee = fee * scaleFactor;

				// Fee is distributed to all existing token holders before the new bonds are purchased.
				// rewardPerResolve is the amount gained per resolve token from this purchase.
				uint rewardPerResolve = resolveFee / dissolvingResolves;

				// The Ether value per token is increased proportionally.
				earningsPerResolve += rewardPerResolve;
			}

			// Add the createdBonds which were just created to the total supply.
			totalSupply += createdBonds;

			// Assign the bonds to the balance of the buyer.
			red[msg.sender] += createdBonds * red[msg.sender]/holdings[sender];
			green[msg.sender] += createdBonds * green[msg.sender]/holdings[sender];
			blue[msg.sender] += createdBonds * blue[msg.sender]/holdings[sender];
			holdings[sender] += createdBonds;

			emit Reinvest(msg.sender, value_, weightDiff, createdBonds, resolveFee);
		}

		// Sells your bonds for Ether. This Ether is assigned to the callers entry
		// in the holdings array, and therefore is shown as a dividend. A second
		// call to withdraw() must be made to invoke the transfer of Ether back to your address.
		function sellAllBonds() public {
			sell( balanceOf(msg.sender) );
		}
		function sellBonds(uint amount) public {
			uint balance = balanceOf(msg.sender);
			require(balance >= amount, "Amount is more than balance");
			sell(amount);
		}

		// The slam-the-button escape hatch. Sells the callers bonds for Ether, then immediately
		// invokes the withdraw() function, sending the resulting Ether to the callers address.
		function getMeOutOfHere() public {
			sellAllBonds();
			withdraw(resolveWeight[msg.sender]);
		}

		// Gatekeeper function to check if the amount of Ether being sent isn't either
		// too small or too large. If it passes, goes direct to buy().
		function fund() payable public {
			uint _red = red[msg.sender]/holdings[msg.sender];
			uint _green = green[msg.sender]/holdings[msg.sender];
			uint _blue = blue[msg.sender]/holdings[msg.sender];
			fund(_red,_green,_blue);
	  	}
	  	function max1(uint x) internal pure returns (uint){
	  		if(x>1e18)
	  			return 1e18;
	  		else
	  			return x;
	  	}

		function fund(uint _red, uint _green, uint _blue) payable public {
			// Don't allow for funding if the amount of Ether sent is less than 1 szabo.
			if (msg.value > 0.000001 ether) {
			  	contractBalance += msg.value;
				buy(max1(_red), max1(_green), max1(_blue));
			} else {
				revert();
			}
	  	}

	    // Function that returns the (dynamic) pricing for buys and sells. and return fee
		function pricing(uint scale) public view returns (uint buyPrice, uint sellPrice, uint fee) {
			uint buy_eth = scaleFactor * getPriceForBonds( scale, true) / ( scaleFactor - fluxFee(scaleFactor) ) ;
	        uint sell_eth = getPriceForBonds(scale, false);
	        sell_eth -= fluxFee(sell_eth);
	        //uint sell_eth = getEtherForBonds(1e18) - fluxFee( getEtherForBonds(1e18) );
	        return ( buy_eth, sell_eth, fluxFee(scale) );
	    }
	    // For calculating the price 
		function getPriceForBonds(uint256 bonds, bool upDown) public view returns (uint256 price) {
			uint reserveAmount = reserve();

			if(upDown){
				uint x = fixedExp((fixedLog(totalSupply + bonds) - price_coeff) * crr_d/crr_n);
				return x - reserveAmount;
			}else{
				uint x = fixedExp((fixedLog(totalSupply - bonds) - price_coeff) * crr_d/crr_n);
				return reserveAmount - x;
			}
		}

		// Calculate the current resolveEarnings associated with the caller address. This is the net result
		// of multiplying the number of bonds held by their current value in Ether and subtracting the
		// Ether that has already been paid out.
		function resolveEarnings(address _owner) public view returns (uint256 amount) {
			return (uint256) ((int256)(earningsPerResolve * resolveWeight[_owner]) - payouts[_owner]) / scaleFactor;
		}

		// Internal balance function, used to calculate the dynamic reserve value.
		function balance() internal view returns (uint256 amount) {
			// msg.value is the amount of Ether sent by the transaction.
			return contractBalance - msg.value;
		}
		event Buy( address indexed addr, uint256 spent, uint256 bonds, uint256 resolveTax, uint red, uint green, uint blue);
		function buy(uint _red, uint _green, uint _blue) internal {
			// Any transaction of less than 1 szabo is likely to be worth less than the gas used to send it.
			if ( msg.value < 0.000001 ether )
				revert();

			// Calculate the fee
			uint fee = fluxFee(msg.value);

			// The amount of Ether used to purchase new bonds for the caller.
			uint numEther = msg.value - fee;
			buySum += numEther;

			//resolve reward tracking stuff
			uint currentTime = NOW();
			avgFactor_ethSpent[msg.sender] += numEther;
			avgFactor_buyInTimeSum[msg.sender] += currentTime * scaleFactor * numEther;

			// The number of bonds which can be purchased for numEther.
			uint createdBonds = getBondsForEther(numEther);

			// Add the createdBonds which were just created to the total supply
			totalSupply += createdBonds;

			// Assign the bonds to the balance of the buyer.
			holdings[msg.sender] += createdBonds;
			red[msg.sender] += _red * createdBonds;
			green[msg.sender] += _green * createdBonds;
			blue[msg.sender] += _blue * createdBonds;

			// Check that we have bonds in existence (this should always be true), or
			// else you're gonna have a bad time.
			uint resolveFee;
			if (totalSupply > 0 && fee > 0) {
				resolveFee = fee * scaleFactor;

				// Fee is distributed to all existing resolve holders before the new bonds are purchased.
				// rewardPerResolve is the amount gained per resolve token from this purchase.
				uint rewardPerResolve = resolveFee / dissolvingResolves;

				// The Ether value per token is increased proportionally.
				earningsPerResolve += rewardPerResolve;
			}
			emit Buy( msg.sender, msg.value, createdBonds, resolveFee, _red, _green,  _blue);
		}
		function NOW() public view returns(uint time){
			return now - genesis;
		}
		function avgHodl() public view returns(uint hodlTime){
			return avgFactor_releaseTimeSum / avgFactor_releaseWeight / scaleFactor;
		}
		function getReturnsForBonds(address addr, uint bondsReleased) public view returns(uint etherValue, uint mintedResolves, uint new_releaseTimeSum, uint new_releaseWeight, uint initialInput_ETH){
			uint output_ETH = getEtherForBonds(bondsReleased);
			uint input_ETH = avgFactor_ethSpent[addr] * bondsReleased / holdings[addr];
			// hodl multiplier. because if you don't hodl at all, you shouldn't be rewarded resolves.
			// and the multiplier you get for hodling needs to be relative to the average hodl
			uint buyInTime = avgFactor_buyInTimeSum[addr] / avgFactor_ethSpent[addr];
			uint cashoutTime = NOW()*scaleFactor - buyInTime;
			uint releaseTimeSum = avgFactor_releaseTimeSum + cashoutTime*input_ETH/scaleFactor*buyInTime;
			uint releaseWeight = avgFactor_releaseWeight + input_ETH*buyInTime/scaleFactor;
			uint avgCashoutTime = releaseTimeSum/releaseWeight;
			return (output_ETH, input_ETH * cashoutTime / avgCashoutTime * input_ETH / output_ETH, releaseTimeSum, releaseWeight, input_ETH);
		}
		event Sell( address indexed addr, uint256 bondsSold, uint256 cashout, uint256 resolves, uint256 resolveTax, uint256 initialCash);
		function sell(uint256 amount) internal {
		  	// Calculate the amount of Ether & Resolves that the holder's bonds sell for at the current sell price.
			uint numEthersBeforeFee;
			uint resolves;
			uint releaseTimeSum;
			uint releaseWeight;
			uint initialInput_ETH;
			(numEthersBeforeFee,resolves,releaseTimeSum,releaseWeight,initialInput_ETH) = getReturnsForBonds(msg.sender, amount);

			// magic distribution
			resolveToken.mint(msg.sender, resolves, red[msg.sender]/holdings[msg.sender], green[msg.sender]/holdings[msg.sender], blue[msg.sender]/holdings[msg.sender] );

			// update weighted average cashout time
			avgFactor_releaseTimeSum = releaseTimeSum;
			avgFactor_releaseWeight = releaseWeight;

			// reduce the amount of "eth spent" based on the percentage of bonds being sold back into the contract
			avgFactor_ethSpent[msg.sender] -= initialInput_ETH;
			// reduce the "buyInTime" sum that's used for average buy in time
			avgFactor_buyInTimeSum[msg.sender] = avgFactor_buyInTimeSum[msg.sender] * ( holdings[msg.sender] - amount) / holdings[msg.sender];
			
			// calculate the fee
		    uint fee = fluxFee(numEthersBeforeFee);

			// Net Ether for the seller after the fee has been subtracted.
		    uint numEthers = numEthersBeforeFee - fee;

		    //updating the numerator of the fee-easing factor
		    sellSum += initialInput_ETH;

			// Burn the bonds which were just sold from the total supply.
			totalSupply -= amount;

		    // Remove the bonds from the balance of the buyer.
		    red[msg.sender] = red[msg.sender] * ( holdings[msg.sender] - amount) / holdings[msg.sender];
		    green[msg.sender] = green[msg.sender] * ( holdings[msg.sender] - amount) / holdings[msg.sender];
		    blue[msg.sender] = blue[msg.sender] * ( holdings[msg.sender] - amount) / holdings[msg.sender];
			holdings[msg.sender] -= amount;


			// Check that we have bonds in existence (this is a bit of an irrelevant check since we're
			// selling bonds, but it guards against division by zero).
			uint resolveFee;
			if (totalSupply > 0 && dissolvingResolves > 0){
				// Scale the Ether taken as the selling fee by the scaleFactor variable.
				resolveFee = fee * scaleFactor;

				// Fee is distributed to all remaining token holders.
				// rewardPerResolve is the amount gained per token thanks to this sell.
				uint rewardPerResolve = resolveFee / dissolvingResolves;

				// The Ether value per token is increased proportionally.
				earningsPerResolve += rewardPerResolve;
			}
			
			// Send the ethereum to the address that requested the sell.
			contractBalance -= numEthers;
			msg.sender.transfer(numEthers);
			emit Sell( msg.sender, amount, numEthers, resolves, resolveFee, initialInput_ETH);
		}

		// Dynamic value of Ether in reserve, according to the CRR requirement.
		function reserve() public view returns (uint256 amount) {
			return balance() -
				 ((uint256) ((int256) (earningsPerResolve * dissolvingResolves) - totalPayouts) / scaleFactor);
		}

		// Calculates the number of bonds that can be bought for a given amount of Ether, according to the
		// dynamic reserve and totalSupply values (derived from the buy and sell prices).
		function getBondsForEther(uint256 ethervalue) public view returns (uint256 bonds) {
			uint newTotalSupply = fixedExp( fixedLog(reserve() + ethervalue ) * crr_n/crr_d + price_coeff);
			if (newTotalSupply < totalSupply)
				return 0;
			else
				return newTotalSupply - totalSupply;
		}

		// Semantically similar to getBondsForEther, but subtracts the callers balance from the amount of Ether returned for conversion.
		function calculateBondsFromReinvest(uint256 ethervalue, uint256 subvalue) public view returns (uint256 bondTokens) {
			return fixedExp(fixedLog(reserve() - subvalue + ethervalue)*crr_n/crr_d + price_coeff)- totalSupply;
		}

		// Converts a number bonds into an Ether value.
		function getEtherForBonds(uint256 bondTokens) public view returns (uint256 ethervalue) {
			// How much reserve Ether do we have left in the contract?
			uint reserveAmount = reserve();

			// If you're the Highlander (or bagholder), you get The Prize. Everything left in the vault.
			if (bondTokens == totalSupply)
				return reserveAmount;

			// If there would be excess Ether left after the transaction this is called within, return the Ether
			// corresponding to the equation in Dr Jochen Hoenicke's original Ponzi paper, which can be found
			// at https://test.jochen-hoenicke.de/eth/ponzitoken/ in the third equation, with the CRR numerator
			// and denominator altered to 1 and 2 respectively.
			uint x = fixedExp((fixedLog(totalSupply - bondTokens) - price_coeff) * crr_d/crr_n);
			if (x > reserveAmount)
				return 0;

			return reserveAmount - x;
		}

		// You don't care about these, but if you really do they're hex values for
		// co-efficients used to simulate approximations of the log and exp functions.
			int256  constant one        = 0x10000000000000000;
			uint256 constant sqrt2      = 0x16a09e667f3bcc908;
			uint256 constant sqrtdot5   = 0x0b504f333f9de6484;
			int256  constant ln2        = 0x0b17217f7d1cf79ac;
			int256  constant ln2_64dot5 = 0x2cb53f09f05cc627c8;
			int256  constant c1         = 0x1ffffffffff9dac9b;
			int256  constant c3         = 0x0aaaaaaac16877908;
			int256  constant c5         = 0x0666664e5e9fa0c99;
			int256  constant c7         = 0x049254026a7630acf;
			int256  constant c9         = 0x038bd75ed37753d68;
			int256  constant c11        = 0x03284a0c14610924f;

		// The polynomial R = c1*x + c3*x^3 + ... + c11 * x^11
		// approximates the function log(1+x)-log(1-x)
		// Hence R(s) = log((1+s)/(1-s)) = log(a)
		function fixedLog(uint256 a) internal pure returns (int256 log) {
			int32 scale = 0;
			while (a > sqrt2) {
				a /= 2;
				scale++;
			}
			while (a <= sqrtdot5) {
				a *= 2;
				scale--;
			}
			int256 s = (((int256)(a) - one) * one) / ((int256)(a) + one);
			int z = (s*s) / one;
			return scale * ln2 +
				(s*(c1 + (z*(c3 + (z*(c5 + (z*(c7 + (z*(c9 + (z*c11/one))
					/one))/one))/one))/one))/one);
		}

		int256 constant c2 =  0x02aaaaaaaaa015db0;
		int256 constant c4 = -0x000b60b60808399d1;
		int256 constant c6 =  0x0000455956bccdd06;
		int256 constant c8 = -0x000001b893ad04b3a;

		// The polynomial R = 2 + c2*x^2 + c4*x^4 + ...
		// approximates the function x*(exp(x)+1)/(exp(x)-1)
		// Hence exp(x) = (R(x)+x)/(R(x)-x)
		function fixedExp(int256 a) internal pure returns (uint256 exp) {
			int256 scale = (a + (ln2_64dot5)) / ln2 - 64;
			a -= scale*ln2;
			int256 z = (a*a) / one;
			int256 R = ((int256)(2) * one) +
				(z*(c2 + (z*(c4 + (z*(c6 + (z*c8/one))/one))/one))/one);
			exp = (uint256) (((R + a) * one) / (R - a));
			if (scale >= 0)
				exp <<= scale;
			else
				exp >>= -scale;
			return exp;
		}

		// This allows you to buy bonds by sending Ether directly to the smart contract
		// without including any transaction data (useful for, say, mobile wallet apps).
		function () payable external {
			// msg.value is the amount of Ether sent by the transaction.
			if (msg.value > 0) {
				fund();
			} else {
				withdraw( resolveWeight[msg.sender] );
			}
		}

		// Allow contract to accept resolve tokens
		event StakeResolves( address indexed addr, uint256 amountStaked);
		function tokenFallback(address from, uint value, bytes calldata _data) external{
			if(msg.sender == address(resolveToken) ){
				resolveWeight[from] += value;
				dissolvingResolves += value;

				// Update the payout array so that the "resolve shareholder" cannot claim resolveEarnings on previous staked resolves.
				int payoutDiff  = (int256) (earningsPerResolve * value);

				// Then we update the payouts array for the "resolve shareholder" with this amount
				payouts[from] += payoutDiff;

				// And then we finally add it to the variable tracking the total amount spent to maintain invariance.
				totalPayouts += payoutDiff;
				emit StakeResolves(from, value);
			}else{
				revert("no want");
			}
		}


		// Withdraws resolveEarnings held by the caller sending the transaction, updates
		// the requisite global variables, and transfers Ether back to the caller.
		event Withdraw( address indexed addr, uint256 earnings, uint256 dissolve );
		function withdraw(uint amount) public {
			// Retrieve the resolveEarnings associated with the address the request came from.
			uint totalEarnings = resolveEarnings(msg.sender);
			require(amount <= totalEarnings, "the amount exceeds total earnings");
			uint oldWeight = resolveWeight[msg.sender];
			resolveWeight[msg.sender] = oldWeight * (totalEarnings - amount) / totalEarnings;
			uint weightDiff = oldWeight - resolveWeight[msg.sender];
			dissolved += weightDiff;
			dissolvingResolves -= weightDiff;

			//something about invariance
			int resolvePayoutDiff  = (int256) (earningsPerResolve * weightDiff);

			// Update the payouts array, incrementing the request address by `balance`.
			payouts[msg.sender] += (int256) (amount * scaleFactor) - resolvePayoutDiff;

			// Increase the total amount that's been paid out to maintain invariance.
			totalPayouts += (int256) (amount * scaleFactor) - resolvePayoutDiff;

			// Send the resolveEarnings to the address that requested the withdraw.
			contractBalance -= amount;
			msg.sender.transfer(amount);
			emit Withdraw( msg.sender, amount, weightDiff);
		}
		event PullResolves( address indexed addr, uint256 pulledResolves, uint256 forfeiture);
		function pullResolves(uint amount) external{
			require(amount <= resolveWeight[msg.sender], "that amount is too large");
			//something about invariance

			uint forfeitedEarnings  =  resolveEarnings(msg.sender)  * amount / resolveWeight[msg.sender] * scaleFactor;
			resolveWeight[msg.sender] -= amount;
			dissolvingResolves -= amount;
			// The Ether value per token is increased proportionally.
			earningsPerResolve += forfeitedEarnings / dissolvingResolves;
			resolveToken.transfer(msg.sender, amount);
			emit PullResolves( msg.sender, amount, forfeitedEarnings / scaleFactor);
		}
	}

	contract ERC223ReceivingContract{
	    function tokenFallback(address _from, uint _value, bytes calldata _data) external;
	}

	contract ResolveToken{
		address pyramid;

		constructor(address _pyramid) public{
			pyramid = _pyramid;
		}

		modifier pyramidOnly{
		  require(msg.sender == pyramid);
		  _;
	    }

		event Transfer(
			address indexed from,
			address indexed to,
			uint256 amount,
			bytes data
		);

		event Mint(
			address indexed addr,
			uint256 amount,
			uint red,
			uint green,
			uint blue
		);

		mapping(address => uint) balances;
		mapping(address => uint) red;
		mapping(address => uint) green;
		mapping(address => uint) blue;
		mapping(address => mapping(address => uint)) approvals;

		string public name = "Resolve";
	    string public symbol = "PoWHr";
	    uint8 constant public decimals = 18;
		uint256 private _totalSupply;
		uint256 private _totalDissolved;

	    function totalSupply() public view returns (uint256) {
	        return _totalSupply;
	    }
		function mint(address _address, uint _value, uint _red, uint _green, uint _blue) external pyramidOnly(){
			balances[_address] += _value;
			red[_address] += _value * _red;
			green[_address] += _value * _green;
			blue[_address] += _value * _blue;
			_totalSupply += _value;
			emit Mint(_address, _value,_red,_green,_blue);
		}

		// Function that is called when a user or another contract wants to transfer funds .
		function transfer(address _to, uint _value, bytes memory _data) public returns (bool success) {
			if (balanceOf(msg.sender) < _value) revert();
			if(isContract(_to)) {
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
			if(isContract(_to)) {
				return transferToContract(_to, _value, empty);
			}else {
				return transferToAddress(_to, _value, empty);
			}
		}

		//assemble the given address bytecode. If bytecode exists then the _addr is a contract.
		function isContract(address _addr) public view returns (bool is_contract) {
			uint length;
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
			mixColors(msg.sender,_to,_value);
			emit Transfer(msg.sender, _to, _value, _data);
			return true;
		}

		//function that is called when transaction target is a contract
		function transferToContract(address _to, uint _value, bytes memory _data) private returns (bool success) {
			mixColors(msg.sender,_to,_value);
			ERC223ReceivingContract reciever = ERC223ReceivingContract(_to);
			reciever.tokenFallback(msg.sender, _value, _data);
			emit Transfer(msg.sender, _to, _value, _data);
			return true;
		}

		function mixColors(address _from, address _to, uint _amount) private{
			uint red_ratio = red[_from] * _amount / balances[_from];
			uint green_ratio = green[_from] * _amount / balances[_from];
			uint blue_ratio = blue[_from] * _amount / balances[_from];
			balances[_from] -= _amount;
			red[_from] -= red_ratio;
			green[_from] -= green_ratio;
			blue[_from] -= blue_ratio;

			balances[_to] += _amount;
			red[_to] += red_ratio;
			green[_to] += green_ratio;
			blue[_to] += blue_ratio;
		}

	    function balanceOf(address _owner) public view returns (uint balance) {
	        return balances[_owner];
	    }

	    function allowance(address src, address guy) public view returns (uint) {
	        return approvals[src][guy];
	    }

	    function transferFrom(address src, address dst, uint wad) public returns (bool){
	        require(approvals[src][msg.sender] >=  wad, "That amount is not approved");
	        require(balances[src] >=  wad, "That amount is not available from this wallet");
	        if (src != msg.sender) {
	            approvals[src][msg.sender] -=  wad;
	        }
			mixColors(src,dst,wad);

	        bytes memory empty;
	        emit Transfer(src, dst, wad, empty);

	        return true;
	    }

	    function approve(address guy, uint wad) public returns (bool) {
	        approvals[msg.sender][guy] = wad;

	        emit Approval(msg.sender, guy, wad);

	        return true;
	    }

	    event Approval(address indexed src, address indexed guy, uint wad);
	}