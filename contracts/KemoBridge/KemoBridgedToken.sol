pragma solidity 0.8.3;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract KemoBridgedToken is ERC20, ERC20Burnable, Ownable {
    address public nativeTokenAddress;
    constructor(
        address _nativeTokenAddress,
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _kemoBridgeAddress
    ) public ERC20(name, symbol, decimals) {
        nativeTokenAddress = _nativeTokenAddress;
        setKemoBridgeAddress(_bridge);
    }


    /**
      * @dev Throws if called by any account other than the bridge
     */
    modifier onlyKemoBridge() {
        require(getKemoBridgeAddress() == _msgSender(), "!the bridge");
        _;
    }

    function mint(address to, uint256 _mintAmount) public onlyKemoBridge {
        _mint(to, _mintAmount);
    }

    function burn(address _from, uint256 _burnAmount) public onlyKemoBridge {
        _burn(_from, _burnAmount);
    }

    function setKemoBridgeAddress(address _kemoBridgeAddress) internal returns (bool) {
        require(_kemoBridgeAddress == address(_kemoBridgeAddress), "UnwantedException: This is an Invalid Address");
        addressStorage[keccak256(abi.encodePacked("kemo__bridge_address"))] = _kemoBridgeAddress;
        return true;
    }

    function getKemoBridgeAddress() internal view returns (address){
        return addressStorage[keccak256(abi.encodePacked("kemo__bridge_address"))];
    }

}
