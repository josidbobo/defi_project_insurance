 // SPDX-License-Identifier: GPL-3.0
pragma solidity = 0.8.9;

 contract SureBlocks{

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
         require(msg.sender == owner, "Only owner can call this function");
         _;
     }

     struct Insurance{    
         address owner;
         uint insuranceId; 
         string insuranceName;
         uint amount;
         uint userInsuranceCount;
         address beneficiary;
         uint amountForBeneficiary;
         bool isApproved;
        }

     address mainAccount;
     address owner;

     bool public locked = false;

     mapping(uint => Insurance) public portfolios;
     mapping (address => mapping(uint => Insurance)) public userInsurances;
     mapping (address => uint) public portfolioCountOfEachUser;
     mapping (address => bool) public isInsuree;
     mapping (address => bytes32) public passwordHash; 

     uint public count;
     uint public userCount;

    event InsuranceMade(address indexed owner, uint _amountInsured, string typeOfInsurance, uint iD);
    event InsuranceDeposit(address indexed owner, uint _amountDeposited);
    event AuthorizedToWithdraw(address indexed owner, address indexed beneficiary, uint amountAuthorised, uint iD);
    event ClaimMade(address indexed owner, address indexed beneficiary, uint amount, uint id);

    constructor() {
        //priceFeed = AggregatorV3Interface(0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada);
        mainAccount = address(this);
        owner = msg.sender;
    }
    
    /// @notice Oracle function to get latest price of ETH/USD
    // function getLatestPrice() public view returns (int) {
    //     ( /*uint80 roundID*/,
    //         int ExchangePrice,
    //         /*uint startedAt*/,
    //         /*uint timeStamp*/,
    //         /*uint80 answeredInRound*/ ) = priceFeed.latestRoundData();
    //     return ExchangePrice; 
    // }

    /// @notice Convert dollar amount to wei
    // function priceConvert(uint _price) public view returns(uint){
    //     uint amount = (_price * 10 ** 26) / uint(getLatestPrice());
    //     return amount; 

    //     /*  Exchangeprice =  10 ** 18wei
    //        __price =  x   */     
    // }


     function insure(uint _amount, string memory typeOfInsurance, address _beneficiary, uint _maxAmountForBenef, string memory _password) public payable noZeroAddress{
         require(insuranceDeposit(_amount), "Could not send the amount to be insured");

          if(!isInsuree[msg.sender]){
              bytes32 hashedPassword = hashPassword(_password);
              passwordHash[msg.sender] = hashedPassword;
              userCount++;
              isInsuree[msg.sender] = true;
         }
         
         portfolioCountOfEachUser[msg.sender]++;
         userInsurances[msg.sender][portfolioCountOfEachUser[msg.sender]].owner = msg.sender;
         userInsurances[msg.sender][portfolioCountOfEachUser[msg.sender]].insuranceId = portfolioCountOfEachUser[msg.sender];
         userInsurances[msg.sender][portfolioCountOfEachUser[msg.sender]].insuranceName = typeOfInsurance;
         userInsurances[msg.sender][portfolioCountOfEachUser[msg.sender]].amount = _amount;
         userInsurances[msg.sender][portfolioCountOfEachUser[msg.sender]].beneficiary = _beneficiary;
         userInsurances[msg.sender][portfolioCountOfEachUser[msg.sender]].amountForBeneficiary = _maxAmountForBenef;
         
        count++;
        portfolios[count].owner = msg.sender;
        portfolios[count].insuranceId = count;
        portfolios[count].insuranceName = typeOfInsurance;
        portfolios[count].amount = _amount;
        portfolios[count].beneficiary = _beneficiary;
        portfolios[count].userInsuranceCount = portfolioCountOfEachUser[msg.sender];

        emit InsuranceMade(msg.sender, _amount, typeOfInsurance, count);
     }

      function hashPassword (string memory a1) internal pure returns (bytes32){
        return keccak256(abi.encode(a1));
    }
 
     function stringsEqual (bytes32 _hashedPassword, string memory a2) internal pure returns (bool){
        return _hashedPassword == keccak256(abi.encode(a2)) ? true : false;
    }

    function makeClaim(uint id, address _beneficiary, uint _amount) noReentrancy public returns (bool, string memory){
        uint userPortId = portfolios[id].userInsuranceCount;
        Insurance storage _port = userInsurances[msg.sender][userPortId];
        require(_amount <= _port.amount, "Cannot claim above portfolio size");

        require(_beneficiary == _port.beneficiary && _port.isApproved, "You have not been permitted to withdraw yet");
        require(_amount <= _port.amountForBeneficiary, "Amount is more than approved for beneficiary");
             (bool success, ) = payable(_beneficiary).call{value: _amount}("");
             require(success, "Transfer to beneficiary failed!");
             _port.amount -= _amount;
             if(success){
                emit ClaimMade(msg.sender, _beneficiary, _amount, id);
                return (true, "Beneficiary of Insuree paid");
        } else {
            return (false, "Transfer error!");
        }
        
    }

    // function approveClaim(uint id, uint _idOfClaim, string memory _password) public noReentrancy returns(bool){
    //    bytes32 _pass = passwordHash[msg.sender];
    //    require(stringsEqual(_pass, _password), "Incorrect password inputed");

    //    Claim storage _claims = userInsurances[msg.sender][id].claims[_idOfClaim];

    //    (bool success, ) = payable(_claims.beneficiary).call{value: _claims.amount}(""); 
    //     require(success, "Transfer Unsuccessful");
        
    //     userInsurances[msg.sender][id].amount -= _claims.amount;
    //     _claims.approved = true;

    //     emit AuthorizedToWithdraw(msg.sender, _claims.beneficiary, _claims.amount, id);
    //     return true;
    // }

    function insuranceDeposit(uint amount) payable noZeroAddress noReentrancy public returns (bool) {
        (bool success, ) = payable(mainAccount).call{value: amount }(""); 
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

    function toggleAuthorisation(string memory _password, uint iD) payable public {
        require(msg.sender == userInsurances[msg.sender][iD].owner, "Not Owner of the Portfolio");
        bytes32 passCode = passwordHash[msg.sender];
        require(stringsEqual(passCode, _password), "Wrong Password!");

        if(!userInsurances[msg.sender][iD].isApproved){
            userInsurances[msg.sender][iD].isApproved = true;
        }else{
            userInsurances[msg.sender][iD].isApproved = false;
        }
    }

    function changeBeneficiaryAmount(uint iD, uint __amount, string memory _pass) public returns(bool){
        require(msg.sender == userInsurances[msg.sender][iD].owner, "Not Owner of the Portfolio");
        require(__amount <= userInsurances[msg.sender][iD].amount);
        bytes32 passCode = passwordHash[msg.sender];
        require(stringsEqual(passCode, _pass), "Wrong Password!");

        userInsurances[msg.sender][iD].amountForBeneficiary = __amount;
        return true;
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }

    function changePassword(string memory _pass, string memory newPass) public returns (bool) {
        bytes32 passCode = passwordHash[msg.sender];
        require(stringsEqual(passCode, _pass), "Wrong Password!");
        bytes32 _newPassWord = hashPassword(newPass);
        passwordHash[msg.sender] = _newPassWord;
        return true;
    }

    function changeBeneficiary(uint iD, address _newBeneficiary, string memory _pass) public {
        bytes32 passCode = passwordHash[msg.sender];
        require(stringsEqual(passCode, _pass), "Wrong Password!");
        require(msg.sender == userInsurances[msg.sender][iD].owner, "Not Owner of the Portfolio");
        userInsurances[msg.sender][iD].beneficiary = _newBeneficiary;
    }

    function topUpPortfolio(uint iD, uint _amount) public payable noReentrancy noZeroAddress{
        require(msg.sender == userInsurances[msg.sender][iD].owner, "Not the owner of the portfolio");
        Insurance storage _insureMe = userInsurances[msg.sender][iD];

        (bool success, ) = payable(mainAccount).call{value: _amount}("");
        require(success, "Transfer failed!");

        _insureMe.amount += _amount;
    }

    function transferBalance(uint amount, address payee) public payable onlyOwner noZeroAddress noReentrancy{
        require(amount <= getContractBalance(), "Amount greater than contract Balance");

        (bool success, ) = payable(payee).call{value: amount}("");
        require(success, "Transfer failed");
    }

 }