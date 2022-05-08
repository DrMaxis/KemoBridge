// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./KemoBridgeEternalStorage.sol";
import "./KemoBridgeController.sol";
import "./KemoBridgedToken.sol";

contract KemoBridge
is Initializable, PausableUpgradeable, OwnableUpgradeable, UUPSUpgradeable, KemoBridgeEternalStorage, KemoBridgeController
{

    receive() external payable {}

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function initialize() public initializer {
        __Pausable_init();
        __Ownable_init();
        __UUPSUpgradeable_init();
        setBridgeOwner(msg.sender);
    }

    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {}

    /**
     * @dev lock tokens to be minted on other chain
     * @param _nativeTokenAddress is the address of the token on the native chain of this contract
     * @param amount amount of tokens to lock
     *  @returns bool
     */
    function lockToken(address _nativeTokenAddress, uint256 _lockAmount) public returns (bool) {
        require(_recipientAddress != address(0), "recipient is a zero address");
        require(_lockAmount > 0, "Lock Amount Zero");
        require(isNativeLockableToken(_tokenAddress), "token not registered for lock");
        initTokenLock(_tokenAddress, msg.sender, _lockAmount, address(this));
        return true;
    }


    /**
     * @dev unlock tokens after burning them on other chain
     * @param _nativeTokenAddress is the native token contract address
     * @param _unlockAmount amount of unlock tokens
     * @param recipient _userAddress of the unlock tokens
     */
    function unlockToken(address _nativeTokenAddress, uint256 _unlockAmount, address _userAddress) public onlyOwner returns (bool) {
        require(_userAddress != address(0), "recipient is a zero address");
        require(_unlockAmount > 0, "Lock Amount Zero");
        require(isNativeLockableToken(_nativeTokenAddress), "token not registered for unlock");
        require(_unlockAmount <= getUserTokenLockAmount(_userAddress), "cannot unlock more than locked");
        initTokenUnlock(_tokenAddress, _unlockAmount, _userAddress, address(this));
        return true;
    }

    /**
     * @dev burns a token registered on the native chain connected by unlocking on the connected chain
     * @param _crossChainNativeTokenAddress token address
     * @param amount _burnAmount of tokens to burn
     * @param recipient user of the unlock tokens on the native chain
     */
    function burnToken(address _crossChainNativeTokenAddress, uint256 _burnAmount, address _userAddress) public returns (bool) {
        require(_crossChainNativeTokenAddress != address(0), "Token is a zero address");
        require(getBridgedToken(_crossChainNativeTokenAddress) != address(0), "");
        initTokenBurn(_crossChainNativeTokenAddress, _burnAmount, msg.sender);
        return true;
    }

    /**
     * @dev mints tokens corresponding to the tokens locked in the ethereum chain
     * @param tokenAddr is the token address for minting
     * @param amount amount of tokens for minting
     * @param recipient recipient of the minted tokens ( address)
     * @param receiptId transaction hash of the lock event on ethereum chain
     */
    function mintToken(address _crossChainNativeTokenAddress, uint256 _mintAmount, address _userAddress) public onlyOwner returns (bool) {
        require(_crossChainNativeTokenAddress != address(0), "Token is a zero address");
        require(getBridgedToken(_crossChainNativeTokenAddress) != address(0), "");
        initTokenMint(_crossChainNativeTokenAddress, _mintAmount, _userAddress, address(this));
      return true;
    }

    /**
    * @dev map ethereum token to  token and emit mintAddress
     * @param ethTokenAddr address of the ethereum token
     * @return mintAddress of the mapped token
     */
    function addToken(address _crossChainNativeTokenAddress, string memory name, string memory symbol, uint8 decimals) public onlyOwner returns (address) {
        require(_crossChainNativeTokenAddress != address(0), "Token is a zero address");
        require(getBridgedToken(_crossChainNativeTokenAddress) != address(getBridgedToken(_crossChainNativeTokenAddress)), "Token already mapped");
        KemoBridgedToken _bridgedToken = new KemoBridgedToken(_crossChainNativeTokenAddress, name, symbol, decimals, address(this));
        updateRegisteredTokens(_crossChainNativeTokenAddress, address(_bridgedToken));
        emit NativeTokenMappedToBridgedToken(nativeTokenAddress, _bridgedTokenAddress);
        return bridgedTokenAddress;
    }

    /**
     * @dev register a ccross chain nativee token to a native token address
        ex. BSCNative ->  Native: This is called from
     * @param ethTokenAddr address of the ethereum token
     * @return oneToken of the mapped  token
     */

    function registerToken(address _crossChainNativeTokenAddress, address _nativeTokenAddress) public onlyOwner returns (bool) {
        require(_crossChainNativeTokenAddress != address(0), "Token is a zero address");
        require(_nativeTokenAddress != address(0), "Token is a zero address");
        require(getBridgedToken(_crossChainNativeTokenAddress) != address(getBridgedToken(_crossChainNativeTokenAddress)), "Token already mapped");
        updateRegisteredTokens(_crossChainNativeTokenAddress, _nativeTokenAddress);
        return true;
    }

    /**
    * @dev remove an existing token mapping
     * @param ethTokenAddr address of the ethereum token
     * @param supply only allow removing mapping when supply, e.g., zero or 10**27
     */
    function removeToken(address nativeTokenAddress, uint256 supply) public auth {
        require(mappedTokens[nativeTokenAddress] != address(0), "Token mapping does not exists");
        IERC20 _bridgedToken = IERC20(tokenAddressStorage[nativeTokenAddress]);
        require(_bridgedToken.totalSupply() == supply, "remove has non-zero supply");
        delete tokenAddressStorage[nativeTokenAddress];
    }

    function pause() public onlyOwner {
        boolStorage[keccak256(abi.encodePacked("contract_paused"))] = true;
        _pause();
    }

    function transferOwnership(address _newOwner) public virtual override onlyOwner {
        require(_newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(_newOwner);
        setBridgeOwner(_newOwner);
    }

    function unpause() public onlyOwner {
        boolStorage[keccak256(abi.encodePacked("contract_paused"))] = false;
        _unpause();
    }

    function setBridgeOwner(address _newOwner) public onlyOwner returns (bool) {
        addressStorage[keccak256(abi.encodePacked("bridge_owner"))] = _newOwner;
        BridgeOwnerSet(_newOwner, block.timestamp, _newOwner);
        return true;
    }
}