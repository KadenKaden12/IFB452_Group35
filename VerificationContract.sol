// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VerificationContract {
    // Role enum
    enum Role { None, Manufacturer, Distributor, Hospital, Regulator }

    // Admin address
    address public admin;

    // Role mapping
    mapping(address => Role) public roles;

    // Verification structure
    struct VerificationRecord {
        string productId;
        address verifier;
        uint256 timestamp;
        string usageNote;  // Optional field like "administered to patient X"
    }

    // productId => verification records
    mapping(string => VerificationRecord[]) public verificationHistory;

    // productId => verified?
    mapping(string => bool) public isVerified;

    // Events
    event RoleAssigned(address indexed user, Role role);
    event ProductVerified(string indexed productId, address indexed verifier, string usageNote);

    constructor() {
        admin = msg.sender;
        roles[admin] = Role.Regulator;
    }

    // Modifiers
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin allowed");
        _;
    }

    modifier onlyHospitalOrPharmacy() {
        require(
            roles[msg.sender] == Role.Hospital,
            "Only hospitals or pharmacies can verify usage"
        );
        _;
    }

    // Assign a role to an address
    function assignRole(address _user, Role _role) public onlyAdmin {
        require(_user != address(0), "Invalid address");
        roles[_user] = _role;
        emit RoleAssigned(_user, _role);
    }

    // Verify a product and log usage details
    function verifyAndUseProduct(string memory _productId, string memory _usageNote) public onlyHospitalOrPharmacy {
        require(!isVerified[_productId], "Product already verified");

        VerificationRecord memory record = VerificationRecord({
            productId: _productId,
            verifier: msg.sender,
            timestamp: block.timestamp,
            usageNote: _usageNote
        });

        verificationHistory[_productId].push(record);
        isVerified[_productId] = true;

        emit ProductVerified(_productId, msg.sender, _usageNote);
    }

    // Retrieve verification records
    function getVerificationHistory(string memory _productId) public view returns (VerificationRecord[] memory) {
        return verificationHistory[_productId];
    }

    // Check if product has been verified/used
    function checkVerificationStatus(string memory _productId) public view returns (bool) {
        return isVerified[_productId];
    }
}