// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplyChain {
    enum Role {
        Owner,
        Manufacturer,
        Distributor,
        Retailer
    }

    struct Participant {
        address id;
        Role role;
        string name;
        VerificationStatus verificationStatus;
    }

    enum VerificationStatus {
        NotRequested,
        Pending,
        Approved,
        Rejected
    }

    enum State {
        Manufactured,
        ShippedToDistributor,
        ShippedToRetailer,
        Sold
    }

    struct Item {
        string name;
        string description;
        State state;
        Participant manufacturer;
        Participant distributor;
        Participant retailer;
        Participant customer;
        uint256 manufacturedTimestamp;
        uint256 shippedToDistributorTimestamp;
        uint256 shippedToRetailerTimestamp;
        uint256 soldTimestamp;
    }

    uint256 public itemCount;
    mapping(uint256 => Item) public items;
    mapping(address => Participant) public participants;
    address public owner;

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can perform this action."
        );
        _;
    }

    modifier onlyManufacturer(uint256 _itemId) {
        require(
            items[_itemId].manufacturer.id == msg.sender,
            "Only the manufacturer can perform this action."
        );
        _;
    }

    modifier onlyDistributor(uint256 _itemId) {
        require(
            items[_itemId].distributor.id == msg.sender,
            "Only the distributor can perform this action."
        );
        _;
    }

    modifier onlyRetailer(uint256 _itemId) {
        require(
            items[_itemId].retailer.id == msg.sender,
            "Only the retailer can perform this action."
        );
        _;
    }

    event ItemManufactured(uint256 indexed _itemId);
    event ItemShippedToDistributor(uint256 indexed _itemId);
    event ItemShippedToRetailer(uint256 indexed _itemId);
    event ItemSold(uint256 indexed _itemId);
    event VerificationApproved(address indexed _user);
    event VerificationRejected(address indexed _user);

    constructor() {
        owner = msg.sender;
        participants[owner] = Participant(
            owner,
            Role.Owner,
            "Owner",
            VerificationStatus.Approved
        );
    }

    function registerUser(Role _role, string memory _userName) public {
        require(
            participants[msg.sender].role == Role.Owner,
            "User is already registered."
        );

        participants[msg.sender] = Participant(
            msg.sender,
            _role,
            _userName,
            VerificationStatus.NotRequested
        );
    }

    function requestVerification() public {
        require(msg.sender != owner, "Owner cannot request verification.");
        require(
            participants[msg.sender].id != address(0),
            "User must be registered to request verification."
        );
        require(
            participants[msg.sender].verificationStatus ==
                VerificationStatus.NotRequested ||
                participants[msg.sender].verificationStatus ==
                VerificationStatus.Rejected,
            "Verification already requested or approved."
        );
        participants[msg.sender].verificationStatus = VerificationStatus
            .Pending;
    }

    function approveVerification(address _user) public onlyOwner {
        require(
            participants[_user].verificationStatus ==
                VerificationStatus.Pending,
            "Verification not requested or already processed."
        );
        participants[_user].verificationStatus = VerificationStatus.Approved;
        emit VerificationApproved(_user);
    }

    function rejectVerification(address _user) public onlyOwner {
        require(
            participants[_user].verificationStatus ==
                VerificationStatus.Pending,
            "Verification not requested or already processed."
        );
        participants[_user].verificationStatus = VerificationStatus.Rejected;
        emit VerificationRejected(_user);
    }

    function manufactureItem(
        string memory _itemName,
        string memory _itemDescription
    ) public {
        require(
            participants[msg.sender].role == Role.Manufacturer,
            "Only manufacturers can create items."
        );

        itemCount++;
        Item memory _newItem = Item({
            name: _itemName,
            description: _itemDescription,
            state: State.Manufactured,
            manufacturer: participants[msg.sender],
            distributor: Participant(
                address(0),
                Role.Distributor,
                "",
                VerificationStatus.NotRequested
            ),
            retailer: Participant(
                address(0),
                Role.Retailer,
                "",
                VerificationStatus.NotRequested
            ),
            customer: Participant(
                address(0),
                Role.Retailer,
                "",
                VerificationStatus.NotRequested
            ),
            manufacturedTimestamp: block.timestamp, // Store the current timestamp
            shippedToDistributorTimestamp: 0,
            shippedToRetailerTimestamp: 0,
            soldTimestamp: 0
        });
        items[itemCount] = _newItem;
        emit ItemManufactured(itemCount);
    }

    function shipItemToDistributor(uint256 _itemId, address _distributorAddress)
        public
        onlyManufacturer(_itemId)
    {
        require(
            participants[_distributorAddress].role == Role.Distributor,
            "Invalid distributor address."
        );
        require(
            items[_itemId].manufacturer.id == msg.sender,
            "Only the manufacturer that created the product can ship to the distributor."
        );
        require(
            _distributorAddress != msg.sender,
            "You cannot ship product to yourself"
        );

        items[_itemId].state = State.ShippedToDistributor;
        items[_itemId].distributor = participants[_distributorAddress];
        items[_itemId].shippedToDistributorTimestamp = block.timestamp; // Store the current timestamp
        emit ItemShippedToDistributor(_itemId);
    }

    function shipItemToRetailer(uint256 _itemId, address _retailerAddress)
        public
        onlyDistributor(_itemId)
    {
        require(
            participants[_retailerAddress].role == Role.Retailer,
            "Invalid retailer address."
        );
        require(
            items[_itemId].distributor.id == msg.sender,
            "Only the assigned distributor can ship to the retailer."
        );
        require(
            _retailerAddress != msg.sender,
            "You cannot ship product to yourself"
        );

        items[_itemId].state = State.ShippedToRetailer;
        items[_itemId].retailer = participants[_retailerAddress];
        items[_itemId].shippedToRetailerTimestamp = block.timestamp; // Store the current timestamp
        emit ItemShippedToRetailer(_itemId);
    }

    function sellItem(uint256 _itemId) public onlyRetailer(_itemId) {
        require(
            items[_itemId].retailer.id == msg.sender,
            "Only the assigned retailer can sell the item."
        );

        items[_itemId].state = State.Sold;

        items[_itemId].soldTimestamp = block.timestamp; // Store the current timestamp
        emit ItemSold(_itemId);
    }

    // function trackItem(uint256 _itemId) public view returns (Item memory) {
    //     return items[_itemId];
    // }

    // function getParticipant(address _participantAddress)
    //     public
    //     view
    //     returns (Participant memory)
    // {
    //     return participants[_participantAddress];
    // }
}
