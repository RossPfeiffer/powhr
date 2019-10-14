contract E2d{
    function dfs() public {

		uint forfeitedEarnings  = resolveEarnings(msg.sender) * amount / resolveWeight[msg.sender];
		//24 = 36 * 2 / 3
		resolveWeight[msg.sender] -= amount;
		//3 - 2 = 1
		dissolvingResolves -= amount;
		//1
		earningsPerResolve += forfeitedEarnings / dissolvingResolves;
		//24/1...36
    };
}

