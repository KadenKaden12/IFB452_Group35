// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RegistrationContract {
    // The admin address who has permission to register products
    address public admin;

    // Struct to define the Product structure to store product data
    struct Product {
        string productId;            // Unique identifier for the product
        string name;                 // Name of the medical product
        string manufacturer;         // Name of the manufacturing company
        string batchNumber;          // Batch or lot number
        uint256 productionDate;      // UNIX timestamp of production date
        uint256 expiryDate;          // UNIX timestamp of expiry date
        string regulatoryApproval;   // Certification or regulatory ID (e.g. TGA, FDA)
        address registeredBy;        // Address of the admin
        bool isRegistered;           // Indicate if the product is already registered
    }

    // Mapping to store Product details based on productId 
    mapping(string => Product) public products;

   // Event triggered when a product is successfully registered
    event ProductRegistered(
        string indexed productId,
        string name,
        string manufacturer,
        string batchNumber,
        uint256 productionDate,
        uint256 expiryDate,
        string regulatoryApproval,
        address registeredBy
    );

    // Constructor, executed once during deployment
    constructor() {
        // Sets the contract deployer as the admin
        admin = msg.sender;
    }

    // Modifier to restrict access to admin-only functions
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    // Modifier to prevent duplicate registrations
    modifier productNotRegistered(string memory _productId) {
        require(!products[_productId].isRegistered, "Product already registered");
        _;
    }

    // Function to registers a new medical product with all relevant metadata
    function registerProduct(
        string memory _productId, // Unique identifier for the product
        string memory _name, // Name of the product
        string memory _manufacturer, // Manufacturer name
        string memory _batchNumber, // Batch or lot number
        uint256 _productionDate, // Timestamp of the production date
        uint256 _expiryDate, // Timestamp of the expiry date
        string memory _regulatoryApproval // Certification or regulatory ID
    ) 
    
    public onlyAdmin productNotRegistered(_productId) {
        // Store product metadata in the blockchain
        products[_productId] = Product({
            productId: _productId,
            name: _name,
            manufacturer: _manufacturer,
            batchNumber: _batchNumber,
            productionDate: _productionDate,
            expiryDate: _expiryDate,
            regulatoryApproval: _regulatoryApproval,
            registeredBy: msg.sender,
            isRegistered: true
        });

        // Emit an event to signal successful registration
        emit ProductRegistered(
            _productId,
            _name,
            _manufacturer,
            _batchNumber,
            _productionDate,
            _expiryDate,
            _regulatoryApproval,
            msg.sender
        );
    }

    // Retrieves full product details for a given product ID
    function getProduct(string memory _productId) public view returns (Product memory) {
        require(products[_productId].isRegistered, "Product not found");
        // Product struct with all stored metadata
        return products[_productId];
    }
}