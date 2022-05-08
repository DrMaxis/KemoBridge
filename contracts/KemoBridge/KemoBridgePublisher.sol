import "./KemoBridgeEternalStorage.sol";
import "./KemoBridgeEventBroadcaster.sol";


contract KemoBridgePublisher is KemoBridgeEternalStorage, KemoBridgeEventBroadcaster {


    function updateUserLockedTokens(address _userAddress, address _tokenAddress, uint256 _newAmount) internal {
        uintStorage[keccak256(abi.encodePacked("user_token_lock_amount", _userAddress, _tokenAddress))] = _newAmount;
    }

    function updateRegisteredTokens(address _crossChainNativeTokenAddress, address _nativeTokenAddress) internal {
        addressStorage[keccak256(abi.encodePacked('bridged_token_addresses' , _crossChainNativeTokenAddress ))] = _nativeTokenAddress;
    }

    function updatedNativeLockableTokens(address _nativeTokenAddress) internal {
        addressStorage[keccak256(abi.encoded('native_lockable_tokens', _nativeTokenAddress))] = _nativeTokenAddress;
    }

}