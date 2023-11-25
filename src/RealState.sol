// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

contract RealState {
    /*
        Functions
        - List a Property
        - Buy a property
        - Sell a property
     */

    /*
        Helpers Function
        - List of all listed property
        - List for property which is available for sale
        - List of all property owned by a person

    */

    // ERRORS

    error TrnsferOfEtherFailed();
    struct Property {
        address owner;
        uint256 id;
        uint256 size;
        uint256 price;
        string location;
        bool forSale;
    }
    //mappings And  Variables
    mapping(uint256 => Property) private properties;
    uint256 private propertyCount;

    //Events
    event ListProperty(
        uint256 indexed id,
        address indexed owner,
        uint256 price
    );
    event BuyProperty(
        uint256 indexed id,
        address indexed oldOwner,
        address indexed newOwner,
        uint256 price
    );
    event SellProperty(
        uint256 indexed id,
        address indexed owner,
        uint256 price
    );

    // Functions
    function listProperty(
        address _owner,
        uint256 _size,
        uint256 _price,
        string memory _location
    ) external {
        // require(_owner != address(0), "Invalid Owner Address");
        require(_size > 0, "Invalid Size");
        require(_price > 0, "Invalid Price");
        require(bytes(_location).length > 0, "Invalid Location");
        propertyCount++;
        properties[propertyCount] = Property(
            _owner,
            propertyCount,
            _size,
            _price,
            _location,
            true
        );
        emit ListProperty(propertyCount, _owner, _price);
    }

    function buyProperty(
        address _newOwner,
        uint256 _price,
        uint256 _id
    ) external payable {
        //require(_newOwner != address(0), "Invalid owner address");
        require(_price > 0, "Invalid Price");
        require(_id > 0, "Invalid Id");
        Property memory _property = properties[_id];
        address payable oldOwner = payable(_property.owner);
        require(_property.forSale == true, "Property is not for sale");
        require(_property.owner != _newOwner, "You already own this property");
        require(_property.price == _price, "Invalid Price");
        properties[_id] = _property;
        _property.owner = _newOwner;
        _property.forSale = false;
        oldOwner.transfer(msg.value);
        emit BuyProperty(_id, msg.sender, _newOwner, _price);
    }

    function updateDetail(
        address _owner,
        uint256 _id,
        uint256 _size,
        uint256 _price,
        string memory _location
    ) external returns (uint256) {
        require(_owner != address(0), "This address is not valid");
        require(_id > 0, "Invalid Id");
        require(_size > 0, "Invalid Size");
        require(_price > 0, "Invalid Price");
        require(bytes(_location).length > 0, "Invalid Location");
        Property memory _property = properties[_id];
        require(
            _property.owner == msg.sender,
            "You are not the owner of this property"
        );
        _property.size = _size;
        _property.price = _price;
        _property.location = _location;
        return _id;
    }

    //HELPERs
    function getListedProperty(
        uint256 _id
    ) external view returns (Property memory) {
        require(_id > 0, "Invalid Id");
        Property memory _property = properties[_id];
        return _property;
    }

    function getAvailableProperty(
        uint256 _id
    ) external view returns (Property memory) {
        require(_id > 0, "Invalid Id");
        Property memory _property = properties[_id];
        require(_property.forSale == false, "Property is for sale");
        return _property;
    }

    function checkContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}
