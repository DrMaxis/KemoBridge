// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./KemoBridgeEternalStorage.sol";
import "./KemoBridgePublisher.sol";
import "./KemoBridgeViewer.sol";

contract KemoBridgeController is KemoBridgeEternalStorage, KemoBridgePublisher, KemoBridgeViewer {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    function isContractPaused() internal view returns (bool) {
        return boolStorage[keccak256(abi.encodePacked("contract_paused"))] == true;
    }

    function initTokenLock(address _tokenAddress, address _userAddress, uint256 _lockAmount, address _bridgeAddress) internal
    {
        IERC20 _tokenInstance = IERC20(_tokenAddress);
        uint256 _balanceBefore = _tokenInstance.balanceOf(address(_bridgeAddress));
        tokenInstance.safeTransferFrom(_userAddress, address(_bridgeAddress), _lockAmount);
        uint256 _balanceAfter = _tokenInstance.balanceOf(address(_bridgeAddress));
        uint256 _actualAmount = _balanceAfter.sub(_balanceBefore);
        uint256 _previousLockAmount = getUserTokenLockAmount(_userAddress, _tokenAddress);
        uint256 _newAmount = _previousLockAmount.add(_actualAmount);
        updateUserLockedTokens(_userAddress, _tokenAddress,  _newAmount);
        emit LockedNativeTokens(address(_tokenInstance), _userAddress, _actualAmount);
    }

    function initTokenUnlock(address _tokenAddress, uint256 _unlockAmount, address _userAddress, address _bridgeAddress) internal {

        IERC20 tokenInstance = IERC20(_tokenAddress);
        uint256 _balanceBefore = _tokenInstance.balanceOf(address(_bridgeAddress));
        tokenInstance.safeTransfer(_userAddress, _unlockAmount);
        uint256 _balanceAfter = _tokenInstance.balanceOf(address(_bridgeAddress));
        uint256 _actualAmount = _balanceAfter.sub(_balanceBefore);
        uint256 _previousLockAmount = getUserTokenLockAmount(_userAddress, _tokenAddress);
        uint256 _newAmount = _previousLockAmount.sub(_actualAmount);
        updateUserLockedTokens(_userAddress, _tokenAddress,  _newAmount);
        emit TokenUnlocked(_tokenAddress, _unlockAmount, _recipientAddress, _receiptHash);
    }


    function initTokenBurn(address _crossChainNativeTokenAddress, uint256 _burnAmount, address _userAddress) internal {
        burnToken(_crossChainNativeTokenAddress, _userAddress, _burnAmount);
        BurningCompleted(_crossChainNativeTokenAddress, block.timestamp, _userAddress);
    }

    function initTokenMint(address _crossChainNativeTokenAddress, uint256 _mintAmount, address _userAddress) internal {
        mintToken(_crossChainNativeTokenAddress, _userAddress, _mintAmount);
        MintingCompleted(getContractCurrentNFTMintCount(), block.timestamp, _to);
    }

    function mintToken(address _nativeTokenAddress, address _to, uint256 _mintAmount) internal {
        bytes memory _requestToMint = abi.encodeWithSignature("mint(address,uint256)", _to, _mintAmount);
        (bool _success, bytes memory _returnData) = address(getBridgedToken(_nativeTokenAddress)).call(_requestToMint);
        ReceivedCallbackFromToken(_returnData, block.timestamp, _success);
        require(_success);
        MintSuccess(_userAddress, _mintAmount, block.timestamp);
    }

    function burnToken(address _crossChainNativeTokenAddress, address _from, uint256 _burnAmount) internal {
        bytes memory _requestToBurn = abi.encodeWithSignature("burn(address,uint256)", _from, _burnAmount);
        (bool _success, bytes memory _returnData) = address(getBridgedToken(_crossChainNativeTokenAddress)).call(_requestToBurn);
        ReceivedCallbackFromToken(_returnData, block.timestamp, _success);
        require(_success);
        BurnSuccess(_userAddress, _mintAmount, block.timestamp);
    }

}