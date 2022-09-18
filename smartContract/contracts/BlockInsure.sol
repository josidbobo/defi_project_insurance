 // SPDX-License-Identifier: GPL-3.0

 pragma solidity = 0.8.16;

 contract EgbonAdugbo{
     address mainAccount;
     bool locked;
     address owner;

     modifier noZeroAddress(){
         require(msg.sender != address(0), "Addresss Zero cannot call this function");
         _;
     }

     modifier noReentrancy() {
         require(locked == false, "Can't call this function because it's locked");
         locked = true;
         _;
         locked = false;
     }

     modifier onlyOwner() {
         require(msg.sender == owner, "Only owner can call this functio;n");
         _;
     }

     struct Insurance{    
         address owner;
         uint insuranceId;
         string insuranceName;
         uint amount;
         uint userInsuranceCount;
         address beneficiary;
         bytes32 passwordHash; 
         uint numberOfClaims;
         mapping(uint => Claim) claims;
        }

     struct Claim{
         address beneficiary;
         uint amount;
         string description;
         bool approved; 
     }

     mapping(address => bool) isInsured;
     mapping(uint => Insurance) portfolios;

     mapping (address => mapping(uint => Insurance)) userInsurances;
     mapping (address => uint) portfolioCountOfEachUser;
     uint public count;
     uint public userCount;
     AggregatorV3Interface internal priceFeed;

    event InsuranceMade(address indexed owner, uint _amountInsured, string typeOfInsurance, uint iD);
    event InsuranceDeposit(address indexed owner, uint _amountDeposited);
    event AuthorizedToWithdraw(address indexed owner, address indexed beneficiary, uint amountAuthorised, uint iD);
    event ClaimMade(address indexed owner, address indexed beneficiary, uint amount, uint id);

    constructor() {
        priceFeed = AggregatorV3Interface(0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada);
        mainAccount = address(this);
        owner = msg.sender;
    }
    
    /// @notice Oracle function to get latest price of ETH/USD
    function getLatestPrice() public view returns (int) {
        ( /*uint80 roundID*/,
            int ExchangePrice,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/ ) = priceFeed.latestRoundData();
        return ExchangePrice; 
    }

    /// @notice Convert dollar amount to wei
    function priceConvert(uint _price) public view returns(uint){
        uint amount = (_price * 10 ** 26) / uint(getLatestPrice());
        return amount; 

        /*  Exchangeprice =  10 ** 18wei
           __price =  x   */     
    }

     function insure(uint _amount, string memory typeOfInsurance, address _beneficiary, string memory _password) public payable noZeroAddress{
         bytes32 hashedPassword = hashPassword(_password);
         require(insuranceDeposit(_amount), "Could not send the Insured amount");

         userInsurances[msg.sender][portfolioCountOfEachUser[msg.sender]++].owner = msg.sender;
         userInsurances[msg.sender][portfolioCountOfEachUser[msg.sender]++].insuranceId = portfolioCountOfEachUser[msg.sender]++;
         userInsurances[msg.sender][portfolioCountOfEachUser[msg.sender]++].insuranceName = typeOfInsurance;
         userInsurances[msg.sender][portfolioCountOfEachUser[msg.sender]++].amount = _amount;
         userInsurances[msg.sender][portfolioCountOfEachUser[msg.sender]++].beneficiary = _beneficiary;
         userInsurances[msg.sender][portfolioCountOfEachUser[msg.sender]++].passwordHash = hashedPassword;

        count++;
        portfolios[count].owner = msg.sender;
        portfolios[count].insuranceId = count;
        portfolios[count].insuranceName = typeOfInsurance;
        portfolios[count].amount = _amount;
        portfolios[count].beneficiary= _beneficiary;
        portfolios[count].passwordHash = hashedPassword;
        portfolios[count].userInsuranceCount = portfolioCountOfEachUser[msg.sender]++;


         if(!isInsured[msg.sender]){
            userCount++;
            isInsured[msg.sender] = true;
         }

        emit InsuranceMade(msg.sender, _amount, typeOfInsurance, count);
     }

      function hashPassword (string memory a1) internal pure returns (bytes32){
        return keccak256(abi.encode(a1));
    }
 
     function stringsEqual (bytes32 _hashedPassword, string memory a2)public pure returns (bool){
        return _hashedPassword == keccak256(abi.encode(a2)) ? true : false;
    }

     function makeClaim(uint id, address _beneficiary, uint _amount, string memory _description) public returns (bool){
        require(portfolios[id].amount >= _amount, "Cannot claim above portfolio size");

        uint userPortId = portfolios[id].userInsuranceCount;

        uint existingClaims = userInsurances[msg.sender][userPortId].numberOfClaims;

        userInsurances[msg.sender][userPortId].claims[existingClaims] = Claim(_beneficiary, _amount, _description, false);
        userInsurances[msg.sender][userPortId].numberOfClaims++;

        emit ClaimMade(msg.sender, _beneficiary, _amount, id);
        return true;
    }

    function approveClaim(uint id, uint idOfClaim, bytes32 _password) public noReentrancy returns(bool){
       bytes32 _pass = userInsurances[msg.sender][id].passwordHash;
       require(_pass == _password, "Incorrect password inputed");

       Claim storage _claims = userInsurances[msg.sender][id].claims[idOfClaim];
       uint weiAmount = priceConvert(_claims.amount);
       (bool success, ) = payable(_claims.beneficiary).call{value: weiAmount }(""); 
        require(success, "Transfer Unsuccessful");
        
        userInsurances[msg.sender][id].amount -= _claims.amount;
        _claims.approved = true;
        return true;
    }

    function insuranceDeposit(uint amount) payable noZeroAddress noReentrancy public returns (bool) {
        uint newWeiAmount = priceConvert(amount);
        (bool success, ) = payable(mainAccount).call{value: newWeiAmount }(""); 
        require(success, "Transfer Unsuccessful");
        if(success){
            emit InsuranceDeposit(msg.sender, amount);
            return true;
            } 
            else{
                return false;
            }
    }

    receive() external payable {}

    function authoriseToWithdraw(string memory _password, uint amount, uint iD) payable noReentrancy noZeroAddress public {
        require(msg.sender == userInsurances[msg.sender][iD].owner, "Not Owner of the Portfolio");
        require(amount <= userInsurances[msg.sender][iD].amount, "Amount greater than porfolio size");
        bytes32 passCode = userInsurances[msg.sender][iD].passwordHash;
        require(stringsEqual(passCode, _password), "Wrong Passkeys!");

        uint convertedWeiPrice = priceConvert(amount);
        address __beneficiary = userInsurances[msg.sender][iD].beneficiary;
        (bool success, ) = payable(__beneficiary).call{value: convertedWeiPrice}("");
        require(success, "Transfer to beneficiary failed!");

        emit AuthorizedToWithdraw(msg.sender, __beneficiary, amount, iD);
    }


    function getBeneficiary(uint iD) public view returns(address){
        require(msg.sender == userInsurances[msg.sender][iD].owner, "Not Owner of the Portfolio");
        return userInsurances[msg.sender][iD].beneficiary;
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }

    function changeBeneficiary(uint iD, address _newBeneficiary) public {
        require(msg.sender == userInsurances[msg.sender][iD].owner, "Not Owner of the Portfolio");
        userInsurances[msg.sender][iD].beneficiary = _newBeneficiary;
    }

    function topUpPortfolio(uint iD, uint _amount) public payable noReentrancy noZeroAddress{
        require(msg.sender == userInsurances[msg.sender][iD].owner, "Not the owner of the portfolio");
        Insurance storage _insureMe = userInsurances[msg.sender][iD];

        uint convertedPrice = priceConvert(_amount);
        (bool success, ) = payable(mainAccount).call{value: convertedPrice}("");
        require(success, "Transfer failed!");

        _insureMe.amount += _amount;
    }

    function transferBalance(uint amount, address payee) public payable onlyOwner noZeroAddress noReentrancy{
        require(amount <= getContractBalance(), "Amount greater than contract Balance");

        (bool success, ) = payable(payee).call{value: amount}("");
        require(success, "Transfer failed");
    }


 }