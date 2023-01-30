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
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Goldrush {

    //variable to track all products stored.
    uint internal productsLength;

    //cUSD token contract address
    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;


    //struct to store product details
    struct Product {
        address payable owner;
        string name;
        string image;
        string description;
        string location;
        uint price;
        uint sold;
    }

    //event to show that the product has been deleted
    event itemDeleted(uint indexed index);

    //A mapping to associate ids to products
    mapping (uint => Product) internal products;

    //modifier to check if the caller is the owner of the product
    modifier onlyOwner(uint _index) {
        require(msg.sender == products[_index].owner, "not Owner");
        _;
    }
    //function to store a product in the smart contract
    function writeProduct(
        string calldata _name,
        string calldata _image,
        string calldata _description, 
        string calldata _location, 
        uint _price
    ) public {
        uint _sold;
        products[productsLength] = Product(
            payable(msg.sender),
            _name,
            _image,
            _description,
            _location,
            _price,
            _sold
        );
        productsLength++;
    }


    //function to get a product with a specific id
    function readProduct(uint _index) public view returns (
        address payable,
        string memory, 
        string memory, 
        string memory, 
        string memory, 
        uint, 
        uint
    ) {
        Product memory _product = products[_index];
        return (
            _product.owner,
           _product.name, 
            _product.image, 
            _product.description, 
            _product.location, 
            _product.price,
            _product.sold
        );
    }


    //function to buy product
    function buyProduct(uint _index) public {
        require(msg.sender != products[_index].owner, "owner can't buy");
        Product memory _product = products[_index];
        require(
          IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
            _product.owner,
            _product.price
          ),
          "Transfer failed."
        );
        products[_index].sold++;
    }
    //function to let user change the price of the product
    function changePrice(uint _index, uint _price) public onlyOwner(_index) {
        products[_index].price = _price;
    }

    //function to delete a product from the smart contract
    function deleteProduct(uint _index) public onlyOwner(_index) {
        delete products[_index]; 
        emit itemDeleted(_index); 
    }

    
    //function to get total number of products stored in the smart contract
    function getProductsLength() public view returns (uint) {
        return (productsLength);
    }
}