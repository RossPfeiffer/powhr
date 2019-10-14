pragma solidity ^ 0.5.1;
/*
          ,/`.
        ,'/ __`.
      ,'_/__ _ _`.
    ,'__/__ _ _  _`.
  ,'_  /___ __ _ __ `.
 '-.._/___ _ __ __  __`.

Inspired by Jochen Hoenicke's Ponzitoken

Forked from EthPhoenix/EthPyramid

Econymous
*/

contract PoWHr{
	// scaleFactor is used to convert Ether into bonds and vice-versa: they're of different
	// orders of magnitude, hence the need to bridge between the two.
	uint256 constant scaleFactor = 0x10000000000000000;  // 2^64

	// CRR = 50%
	// CRR is Cash Reserve Ratio (in this case Crypto Reserve Ratio).
	// For more on this: check out https://en.wikipedia.org/wiki/Reserve_requirement
	int constant crr_n = 1; // CRR numerator
	int constant crr_d = 2; // CRR denominator

	// The price coefficient. Chosen such that at 1 token total supply
	// the amount in reserve is 0.5 ether and token price is 1 Ether.
	int constant price_coeff = 133700000000000000000;

	// Typical values that we have to declare.
	string constant public name = "Bonds";
	string constant public symbol = "Bond";
	uint8 constant public decimals = 18;

	// Array between each address and their number of bonds.
	mapping(address => uint256) public holdings;
	// For calculating resolves minted
	mapping(address => uint256) public avgFactor_ethSpent;
	// For calculating hodl multiplier resolves minted
	mapping(address => uint256) public avgFactor_buyInTimeSum;
	// Array between each address and their number of resolves being staked.
	mapping(address => uint256) public resolveWeight;

	// Array between each address and how much Ether has been paid out to it.
	// Note that this is scaled by the scaleFactor variable.
	mapping(address => int256) public payouts;

	// Variable tracking how many bonds are in existence overall.
	uint256 public totalSupply;

	// The total number of resolve bonds being staked in this contract
	uint256 public resolvePool;
	// The total volume of resolves going into the contract since t0
	uint256 public resolveVolume;


	// For calculating the hodl multiplier. Weighted average release time
	uint public avgFactor_releaseWeight;
	uint public avgFactor_releaseTimeSum;

	// Aggregate sum of all payouts.
	// Note that this is scaled by the scaleFactor variable.
	int256 totalPayouts;

	// Variable tracking how much Ether each token is currently worth.
	// Note that this is scaled by the scaleFactor variable.
	uint256 earningsPerToken;

	// Current contract balance in Ether
	uint256 public contractBalance;

	//The resolve token contract
	ResolveToken public resolveToken;

	constructor() public{
		resolveToken = new ResolveToken( address(this) );
	}

	// The following functions are used by the front-end for display purposes.

	// Returns the number of bonds currently held by _owner.
	function balanceOf(address _owner) public view returns (uint256 balance) {
		return holdings[_owner];
	}

	// Withdraws all dividends held by the caller sending the transaction, updates
	// the requisite global variables, and transfers Ether back to the caller.
	function withdraw() public {
		// Retrieve the dividends associated with the address the request came from.
		uint balance = dividends(msg.sender);

		// Update the payouts array, incrementing the request address by `balance`.
		payouts[msg.sender] += (int256) (balance * scaleFactor);

		// Increase the total amount that's been paid out to maintain invariance.
		totalPayouts += (int256) (balance * scaleFactor);

		// Send the dividends to the address that requested the withdraw.
		contractBalance = contractBalance - balance;
		msg.sender.transfer(balance);
	}

	function fluxFee(uint paidAmount) public {
		return paidAmount * resolvePool / resolveVolume;
	}

	// Converts the Ether accrued as dividends back into bonds without having to
	// withdraw it first. Saves on gas and potential price spike loss.
	function reinvestDividends() public {
		// Retrieve the dividends associated with the address the request came from.
		uint balance = dividends(msg.sender);

		// Update the payouts array, incrementing the request address by `balance`.
		// Since this is essentially a shortcut to withdrawing and reinvesting, this step still holds.
		payouts[msg.sender] += (int256) (balance * scaleFactor);

		// Increase the total amount that's been paid out to maintain invariance.
		totalPayouts += (int256) (balance * scaleFactor);

		// Assign balance to a new variable.
		uint value_ = (uint) (balance);

		// If your dividends are worth less than 1 szabo, or more than a million Ether
		// (in which case, why are you even here), abort.
		if (value_ < 0.000001 ether || value_ > 1000000 ether)
			revert();

		// msg.sender is the address of the caller.
		address sender = msg.sender;

		// A temporary reserve variable used for calculating the reward the holder gets for buying bonds.
		// (Yes, the buyer receives a part of the distribution as well!)
		uint res = reserve() - balance;

		// Calculate the fee
		uint fee = fluxFee(value_);

		// The amount of Ether used to purchase new bonds for the caller.4
		uint numEther = value_ - fee;

		// The number of bonds which can be purchased for numEther.
		uint numTokens = calculateDividendTokens(numEther, balance);

		// The buyer fee, scaled by the scaleFactor variable.
		uint buyerFee = fee * scaleFactor;

		// Check that we have bonds in existence (this should always be true), or
		// else you're gonna have a bad time.
		if (totalSupply > 0) {
			// Compute the bonus co-efficient for all existing holders and the buyer.
			// The buyer receives part of the distribution for each token bought in the
			// same way they would have if they bought each token individually.
			uint bonusCoEff =
			    (scaleFactor - (res + numEther) * numTokens * scaleFactor / (totalSupply + numTokens) / numEther)
			    * (uint)(crr_d) / (uint)(crr_d-crr_n);

			// The total reward to be distributed amongst the masses is the fee (in Ether)
			// multiplied by the bonus co-efficient.
			uint holderReward = fee * bonusCoEff;

			buyerFee -= holderReward;

			// Fee is distributed to all existing token holders before the new bonds are purchased.
			// rewardPerShare is the amount gained per token thanks to this buy-in.
			uint rewardPerShare = holderReward / totalSupply;

			// The Ether value per token is increased proportionally.
			earningsPerToken += rewardPerShare;
		}

		// Add the numTokens which were just created to the total supply. We're a crypto central bank!
		totalSupply += numTokens;

		// Assign the bonds to the balance of the buyer.
		holdings[sender] += numTokens;

		// Update the payout array so that the buyer cannot claim dividends on previous purchases.
		// Also include the fee paid for entering the scheme.
		// First we compute how much was just paid out to the buyer...
		int payoutDiff  = (int256) ((earningsPerToken * numTokens) - buyerFee);

		// Then we update the payouts array for the buyer with this amount...
		payouts[sender] += payoutDiff;

		// And then we finally add it to the variable tracking the total amount spent to maintain invariance.
		totalPayouts += payoutDiff;
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
		withdraw();
	}

	// Gatekeeper function to check if the amount of Ether being sent isn't either
	// too small or too large. If it passes, goes direct to buy().
	function fund() payable public {
		// Don't allow for funding if the amount of Ether sent is less than 1 szabo.
		if (msg.value > 0.000001 ether) {
		  contractBalance += msg.value;
			buy();
		} else {
			revert();
		}
  }

	// Function that returns the (dynamic) price of buying a finney worth of bonds.
	function buyPrice() public view returns (uint) {
		return getBondsForEther(1 finney);
	}

	// Function that returns the (dynamic) price of selling a single token.
	function sellPrice() public view returns (uint) {
        uint eth = getEtherForBonds(1 finney);
        uint fee = fluxFee(eth);//eth/ 10;
        return eth - fee;
    }

	// Calculate the current dividends associated with the caller address. This is the net result
	// of multiplying the number of bonds held by their current value in Ether and subtracting the
	// Ether that has already been paid out.
	function dividends(address _owner) public view returns (uint256 amount) {
		return (uint256) ((int256)(earningsPerToken * holdings[_owner]) - payouts[_owner]) / scaleFactor;
	}

	// Internal balance function, used to calculate the dynamic reserve value.
	function balance() internal view returns (uint256 amount) {
		// msg.value is the amount of Ether sent by the transaction.
		return contractBalance - msg.value;
	}

	function buy() internal {
		// Any transaction of less than 1 szabo is likely to be worth less than the gas used to send it.
		if (msg.value < 0.000001 ether)
			revert();

		// Calculate the fee
		uint fee = fluxFee(msg.value);

		// The amount of Ether used to purchase new bonds for the caller.
		uint numEther = msg.value - fee;

		//resolve reward tracking stuff
		avgFactor_ethSpent[msg.sender] += numEther;
		avgFactor_buyInTimeSum[msg.sender] += now * scaleFactor * numEther;

		// The number of bonds which can be purchased for numEther.
		uint numTokens = getBondsForEther(numEther);

		// The buyer fee, scaled by the scaleFactor variable.
		uint buyerFee = fee * scaleFactor;

		// Check that we have bonds in existence (this should always be true), or
		// else you're gonna have a bad time.
		if (totalSupply > 0) {
			// Compute the bonus co-efficient for all existing holders and the buyer.
			// The buyer receives part of the distribution for each token bought in the
			// same way they would have if they bought each token individually.
			uint bonusCoEff =
			    (scaleFactor - (reserve() + numEther) * numTokens * scaleFactor / (totalSupply + numTokens) / numEther)
			    * (uint)(crr_d) / (uint)(crr_d-crr_n);

			// The total reward to be distributed amongst the masses is the fee (in Ether)
			// multiplied by the bonus co-efficient.
			uint holderReward = fee * bonusCoEff;

			buyerFee -= holderReward;

			// Fee is distributed to all existing token holders before the new bonds are purchased.
			// rewardPerShare is the amount gained per token thanks to this buy-in.
			uint rewardPerShare = holderReward / totalSupply;

			// The Ether value per token is increased proportionally.
			earningsPerToken += rewardPerShare;

		}

		// Add the numTokens which were just created to the total supply. We're a crypto central bank!
		totalSupply = totalSupply+ numTokens;

		// Assign the bonds to the balance of the buyer.
		holdings[msg.sender] += numTokens;

		// Update the payout array so that the buyer cannot claim dividends on previous purchases.
		// Also include the fee paid for entering the scheme.
		// First we compute how much was just paid out to the buyer...
		int payoutDiff = (int256) ((earningsPerToken * numTokens) - buyerFee);

		// Then we update the payouts array for the buyer with this amount...
		payouts[msg.sender] += payoutDiff;

		// And then we finally add it to the variable tracking the total amount spent to maintain invariance.
		totalPayouts += payoutDiff;
	}
	function getReturnsForBonds(address addr, uint bondsReleased) public view returns(uint etherValue, uint mintedResolves, uint new_releaseTimeSum, uint new_releaseWeight){
		uint output_ETH = getEtherForBonds(bondsReleased);
		uint input_ETH = avgFactor_ethSpent[addr] * bondsReleased / holdings[addr];
		// hodl multiplier. because if you don't hodl at all, you shouldn't be rewarded resolves.
		// and the multiplier you get for hodling needs to be relative to the average hodl
		uint buyInTime = avgFactor_buyInTimeSum[addr] / avgFactor_ethSpent[addr];
		uint cashoutTime = now*scaleFactor - buyInTime;
		uint releaseTimeSum = avgFactor_releaseTimeSum + cashoutTime*input_ETH/scaleFactor*buyInTime;
		uint releaseWeight = avgFactor_releaseWeight + input_ETH*buyInTime/scaleFactor;
		uint avgCashoutTime = releaseTimeSum/releaseWeight;
		return (output_ETH, input_ETH * cashoutTime / avgCashoutTime * input_ETH / output_ETH, releaseTimeSum, releaseWeight);
	}
	function sell(uint256 amount) internal {
	  // Calculate the amount of Ether & Resolves that the holder's bonds sell for at the current sell price.
		uint numEthersBeforeFee;
		uint resolves;
		uint releaseTimeSum;
		uint releaseWeight;
		(numEthersBeforeFee,resolves,releaseTimeSum,releaseWeight) = getReturnsForBonds(msg.sender, amount);

		// magic distribution
		resolveToken.mint(msg.sender, resolves);

		// update weighted average cashout time
		avgFactor_releaseTimeSum = releaseTimeSum;
		avgFactor_releaseWeight = releaseWeight;

		// reduce the amount of "eth spent" based on the percentage of bonds being sold back into the contract
		avgFactor_ethSpent[msg.sender] = avgFactor_ethSpent[msg.sender] * ( holdings[msg.sender] - amount) / holdings[msg.sender];
		// reduce the "buyInTime" sum that's used for average buy in time
		avgFactor_buyInTimeSum[msg.sender] = avgFactor_buyInTimeSum[msg.sender] * ( holdings[msg.sender] - amount) / holdings[msg.sender];


		// calculate the fee
    uint fee = fluxFee(numEthersBeforeFee);

		// Net Ether for the seller after the fee has been subtracted.
    uint numEthers = numEthersBeforeFee - fee;

		// Burn the bonds which were just sold from the total supply.
		totalSupply -= amount;

    // Remove the bonds from the balance of the buyer.
		holdings[msg.sender] -= amount;

    // Update the payout array so that the seller cannot claim future dividends unless they buy back in.
		// First we compute how much was just paid out to the seller...
		//int payoutDiff = (int256) (earningsPerToken * amount + (numEthers * scaleFactor));

    // We reduce the amount paid out to the seller (this effectively resets their payouts value to zero,
		// since they're selling all of their bonds). This makes sure the seller isn't disadvantaged if
		// they decide to buy back in.
		//payouts[msg.sender] -= payoutDiff;

		// Decrease the total amount that's been paid out to maintain invariance.
    //totalPayouts -= payoutDiff;

		//-----------------------------------------------------------------------------------

		// Update the payouts array, incrementing the request address by `balance`.
		//payouts[msg.sender] += (int256) (balance * scaleFactor);

		// Increase the total amount that's been paid out to maintain invariance.
		//totalPayouts += (int256) (balance * scaleFactor);

		// Send the ethereum to the address that requested the sell.
		contractBalance -= numEthers;
		msg.sender.transfer(numEthers);


		// Check that we have bonds in existence (this is a bit of an irrelevant check since we're
		// selling bonds, but it guards against division by zero).
		if (totalSupply > 0) {
			// Scale the Ether taken as the selling fee by the scaleFactor variable.
			uint etherFee = fee * scaleFactor;

			// Fee is distributed to all remaining token holders.
			// rewardPerShare is the amount gained per token thanks to this sell.
			uint rewardPerShare = etherFee / totalSupply;

			// The Ether value per token is increased proportionally.
			earningsPerToken = earningsPerToken+ rewardPerShare;
		}
	}

	// Dynamic value of Ether in reserve, according to the CRR requirement.
	function reserve() public view returns (uint256 amount) {
		return balance() -
			 ((uint256) ((int256) (earningsPerToken * totalSupply) - totalPayouts) / scaleFactor);
	}

	// Calculates the number of bonds that can be bought for a given amount of Ether, according to the
	// dynamic reserve and totalSupply values (derived from the buy and sell prices).
	function getBondsForEther(uint256 ethervalue) public view returns (uint256 bonds) {
		return fixedExp(fixedLog(reserve() + ethervalue)*crr_n/crr_d + price_coeff)- totalSupply;
	}

	// Semantically similar to getBondsForEther, but subtracts the callers balance from the amount of Ether returned for conversion.
	function calculateDividendTokens(uint256 ethervalue, uint256 subvalue) public view returns (uint256 bondTokens) {
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
		return reserveAmount - fixedExp((fixedLog(totalSupply - bondTokens) - price_coeff) * crr_d/crr_n);
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
			withdraw();
		}
	}

	// Allow contract to accept resolve tokens
	function tokenFallback(address from, uint value, bytes calldata _data) external{
		if(msg.sender == address(resolveToken) ){
			resolveWeight[from] += value;
			resolvePool += value;
			resolveVolume += value;
		}else{
			revert("no want");
		}
	}

	function withdrawResolves(uint amount) external{
		uint staking = resolveWeight[msg.sender];
		require(amount <= staking, "that amount is too large")
		resolvePool -= amount;
		resolveToken.transfer(msg.sender, amount, empty);

		//pulling resolves means forfeiting dividends.
		//spread the dividends to the remaining resolve holders.

	}

}

contract ERC223ReceivingContract{
    function tokenFallback(address _from, uint _value, bytes calldata _data) external;
}

contract ResolveToken{
		address resolver;
		constructor(address _resolver) public{
			resolver = _resolver;
		}

		modifier resolverOnly{
      require(msg.sender == resolver);
      _;
    }

		event Transfer(
			address indexed from,
			address indexed to,
			uint256 bonds,
			bytes data
		);
		mapping(address => uint) balances;
		uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
		function mint(address _address, uint _value) external resolverOnly(){
			balances[_address] += _value;
			_totalSupply += _value;
		}
    function transfer(address _to, uint _value, bytes memory _data) public {
        uint codeLength;

        assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(_to)
        }

        balances[msg.sender] = balances[msg.sender] - (_value);
        balances[_to] = balances[_to] + (_value);
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        emit Transfer(msg.sender, _to, _value, _data);
    }

    function transfer(address _to, uint _value) public {
        uint codeLength;
        bytes memory empty;

        assembly {
            // Retrieve the size of the code on target address, this needs assembly .
            codeLength := extcodesize(_to)
        }

        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, empty);
        }
        emit Transfer(msg.sender, _to, _value, empty);
    }


    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }
}
