// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
    function transfer(address, uint256) external returns (bool);

    function approve(address, uint256) external returns (bool);

    function transferFrom(address, address, uint256) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Goldrush {
    uint internal productsLength;
    address internal cUsdTokenAddress =
        0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

    struct Product {
        address payable owner;
        string name;
        string image;
        string description;
        string location;
        uint price;
        bool sold;
    }

    event itemDeleted(uint indexed index);
    mapping(uint => Product) internal products;

    modifier onlyOwner(uint _index) {
        require(msg.sender == products[_index].owner, "not Owner");
        _;
    }

    function writeProduct(
        string memory _name,
        string memory _image,
        string memory _description,
        string memory _location,
        uint _price
    ) public {
        require(bytes(_name).length > 0, "String is invalid");
        require(bytes(_image).length > 0, "String is invalid");
        require(bytes(_description).length > 0, "String is invalid");
        require(bytes(_location).length > 0, "String is invalid");
        require(_price > 0, "Price shuld be greater than 0");
        products[productsLength] = Product(
            payable(msg.sender),
            _name,
            _image,
            _description,
            _location,
            _price,
            false
        );
        productsLength++;
    }

    function readProduct(
        uint _index
    )
        public
        view
        returns (
            address payable,
            string memory,
            string memory,
            string memory,
            string memory,
            uint,
            bool
        )
    {
        Product storage product = products[_index];
        return (
            product.owner,
            product.name,
            product.image,
            product.description,
            product.location,
            product.price,
            product.sold
        );
    }

    function buyProduct(uint _index) public {
        require(msg.sender != products[_index].owner, "owner can't buy");
        require(products[_index].sold = false, "Must not be sold already");
        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                products[_index].owner,
                products[_index].price
            ),
            "Transfer failed."
        );
        products[_index].owner = payable(msg.sender);
        products[_index].sold = true;
    }

    function sellProduct(uint _index) public onlyOwner(_index) {
        require(products[_index].sold = true, "Must be sold already");
        products[_index].sold = false;
    }

    function changePrice(uint _index, uint _price) public onlyOwner(_index) {
        require(_price > 0, "Price cannot be equal or less than 0");
        products[_index].price = _price;
    }

    function deleteProduct(uint _index) public onlyOwner(_index) {
        require(_index < productsLength, "not found.");
        delete products[_index];
        productsLength--;
        emit itemDeleted(_index);
    }

    function getProductsLength() public view returns (uint) {
        return (productsLength);
    }
}
