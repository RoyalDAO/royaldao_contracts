// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (governance/extensions/GovernorProposalThreshold.sol)

pragma solidity ^0.8.0;

import "../ChancelorUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @dev Extension of {Governor} for proposal restriction to token holders with a minimum balance.
 *
 * _Available since v4.3._
 * _Deprecated since v4.4._
 */
abstract contract ChancelorProposalThresholdUpgradeable is
    Initializable,
    ChancelorUpgradeable
{
    function __ChancelorProposalThreshold_init() internal onlyInitializing {}

    function __ChancelorProposalThreshold_init_unchained()
        internal
        onlyInitializing
    {}

    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public virtual override returns (uint256) {
        return super.propose(targets, values, calldatas, description);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
