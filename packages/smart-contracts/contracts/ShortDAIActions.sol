// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/math/SafeMath.sol";

import "./dydx/DydxFlashloanBase.sol";
import "./dydx/IDydx.sol";

import "./maker/IDssCdpManager.sol";
import "./maker/IDssProxyActions.sol";
import "./maker/DssActionsBase.sol";

import "./OpenShortDAI.sol";
import "./CloseShortDAI.sol";
import "./VaultStats.sol";

import "./curve/ICurveFiCurve.sol";

import "./Constants.sol";

contract ShortDAIActions {
    using SafeMath for uint256;

    function _openUSDCACdp() internal returns (uint256) {
        return
            IDssCdpManager(Constants.CDP_MANAGER).open(
                bytes32("USDC-A"),
                address(this)
            );
    }

    // Entry point for proxy contracts
    function flashloanAndOpen(
        address _osd,
        address _solo,
        address _curvePool,
        uint256 _cdpId, // Set 0 for new vault
        uint256 _initialMarginUSDC, // Initial USDC margin
        uint256 _mintAmountDAI, // Amount of DAI to mint
        uint256 _flashloanAmountWETH, // Amount of WETH to flashloan
        address _vaultStats,
        uint256 _daiUsdcRatio6
    ) external payable {
        // Tries and get USDC from msg.sender to proxy
        require(
            IERC20(Constants.USDC).transferFrom(
                msg.sender,
                address(this),
                _initialMarginUSDC
            ),
            "initial-margin-transferFrom-failed"
        );

        uint256 cdpId = _cdpId;

        // Opens a new USDC vault for the user if unspecified
        if (cdpId == 0) {
            cdpId = _openUSDCACdp();
        }

        // Allows LSD contract to manage vault on behalf of user
        IDssCdpManager(Constants.CDP_MANAGER).cdpAllow(cdpId, _osd, 1);

        // Transfers the initial margin (in USDC) to lsd contract
        require(
            IERC20(Constants.USDC).transfer(_osd, _initialMarginUSDC),
            "initial-margin-transfer-failed"
        );
        // Flashloan and shorts DAI
        OpenShortDAI(_osd).flashloanAndOpen{value: msg.value}(
            msg.sender,
            _solo,
            _curvePool,
            cdpId,
            _mintAmountDAI,
            _flashloanAmountWETH
        );

        // Forbids LSD contract to manage vault on behalf of user
        IDssCdpManager(Constants.CDP_MANAGER).cdpAllow(cdpId, _osd, 0);

        // Save stats
        VaultStats(_vaultStats).setDaiUsdcRatio6(cdpId, _daiUsdcRatio6);
    }

    // function flashloanAndClose(
    //     address _csd,
    //     address _solo,
    //     address _curvePool,
    //     uint256 _cdpId
    // ) external {
    //     IDssCdpManager(Constants.CDP_MANAGER).cdpAllow(_cdpId, _csd, 1);

    //     CloseShortDAI(_csd).flashloanAndClose(
    //         msg.sender,
    //         _solo,
    //         _curvePool,
    //         _cdpId
    //     );

    //     IDssCdpManager(Constants.CDP_MANAGER).cdpAllow(_cdpId, _csd, 0);
    //     IDssCdpManager(Constants.CDP_MANAGER).give(_cdpId, address(1));
    // }
}
