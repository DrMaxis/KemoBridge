import "./KemoBridgeEventBroadcaster.sol";
import "./KemoBridgeEternalStorage.sol";

contract KemoBridgeViewer is KemoBridgeEternalStorage, KemoBridgeEventBroadcaster {

    function isNativeLockableToken(address _tokenAddress) public view returns (bool) {
        return addressStorage[keccak256(abi.encodePacked('native_lockable_tokens', _tokenAddress))] == _tokenAddress;

    }

    function isRegisteredBridgeToken(address _crossChainNativeTokenAddress, address _nativeTokenAddress) public view returns (bool) {
        return addressStorage[keccak256(abi.encodePacked('bridged_token_addresses', _crossChainNativeTokenAddress))] != address(0);
    }

    function getBridgedToken(address _crossChainNativeTokenAddress) public view returns (address) {
        require(_crossChainNativeTokenAddress == address(_crossChainNativeTokenAddress), 'invalid address');
        return addressStorage[keccak256(abi.encodePacked('bridged_token_addresses', _crossChainNativeTokenAddress))];
    }


}