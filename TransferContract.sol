// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract TransferContract {
    // Define roles
    enum Role { None, Manufacturer, Distributor, Hospital, Regulator }
    // Map addresses to roles
    mapping(address => Role) public roles;
    // Admin who assigns roles
    address public admin;
    // Ownership mapping
    mapping(string => address) public productOwner;
    // Transfer request structure
    struct TransferRequest {
        string productId;
        address from;
        address to;
        uint256 timestamp;
        bool accepted;
    }
    // Transfer history for each product
    mapping(string => TransferRequest[]) public transferHistory;
    // Pending transfers: productId => TransferRequest
    mapping(string => TransferRequest) public pendingTransfers;
    // Events
    event RoleAssigned(address indexed user, Role role);
    event TransferRequested(string indexed productId, address indexed from, address indexed to);
    event TransferAccepted(string indexed productId, address indexed from, address indexed to);
    constructor() {
        admin = msg.sender;
        roles[admin] = Role.Regulator; // Regulator is the highest role for oversight
    }
    // Modifier: Only admin
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }
    // Modifier: Only authorized stakeholders
    modifier onlyAuthorized() {
        require(roles[msg.sender] != Role.None && roles[msg.sender] != Role.Regulator, "Unauthorized stakeholder");
        _;
    }
    // Assign roles to addresses
    function assignRole(address _user, Role _role) public onlyAdmin {
        require(_user != address(0), "Invalid address");
        roles[_user] = _role;
        emit RoleAssigned(_user, _role);
    }
    // Set initial owner (e.g. by Manufacturer upon registration)
    function setInitialOwner(string memory _productId, address _owner) public onlyAdmin {
        require(productOwner[_productId] == address(0), "Owner already set");
        productOwner[_productId] = _owner;
    }
    // Initiate a transfer to another authorized stakeholder
    function requestTransfer(string memory _productId, address _to) public {
        require(productOwner[_productId] == msg.sender, "Only current owner can initiate transfer");
        require(_to != address(0) && _to != msg.sender, "Invalid recipient");
        require(roles[_to] != Role.None && roles[_to] != Role.Regulator, "Recipient not authorized");
        require(!pendingTransfers[_productId].accepted, "Pending transfer already exists");
        pendingTransfers[_productId] = TransferRequest({
            productId: _productId,
            from: msg.sender,
            to: _to,
            timestamp: block.timestamp,
            accepted: false
        });
        emit TransferRequested(_productId, msg.sender, _to);
    }
    // Accept a transfer
    function acceptTransfer(string memory _productId) public {
        TransferRequest storage request = pendingTransfers[_productId];
        //require(request.to == msg.sender, "Only designated recipient can accept");
        require(!request.accepted, "Transfer already accepted");
        request.accepted = true;
        productOwner[_productId] = request.to;
        transferHistory[_productId].push(request);
        delete pendingTransfers[_productId];
        emit TransferAccepted(_productId, request.from, msg.sender);
    }
    // View full transfer history of a product
    function getTransferHistory(string memory _productId) public view returns (TransferRequest[] memory) {
        return transferHistory[_productId];
    }
    // View current owner
    function getCurrentOwner(string memory _productId) public view returns (address) {
        return productOwner[_productId];
    }
}