// SPDX-License-Identifier: MIT
// RoyalDAO Contracts (last updated v1.0.0) (Governance/extensions/SenateVotesQuorumFractionUpgradeable.sol)
// Uses OpenZeppelin Contracts and Libraries

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "../SenateUpgradeable.sol";
import "../../Utils/CheckpointsUpgradeable.sol";

/**
 * @dev Extension of {SenateUpgradeable} for voting weight extraction from an {ERC721SenatorVotesUpgradeable/ERC721VotesUpgradeable} token and a quorum expressed as a
 * fraction of the total supply.
 *
 * _Available since v1.0._
 */
abstract contract SenateVotesQuorumFractionUpgradeable is
    Initializable,
    SenateUpgradeable
{
    using CheckpointsUpgradeable for CheckpointsUpgradeable.History;

    uint256 private _quorumNumerator; // DEPRECATED
    CheckpointsUpgradeable.History private _quorumNumeratorHistory;

    event QuorumNumeratorUpdated(
        uint256 oldQuorumNumerator,
        uint256 newQuorumNumerator
    );

    /**
     * @dev Initialize quorum as a fraction of the token's total supply.
     *
     * The fraction is specified as `numerator / denominator`. By default the denominator is 100, so quorum is
     * specified as a percent: a numerator of 10 corresponds to quorum being 10% of total supply. The denominator can be
     * customized by overriding {quorumDenominator}.
     */
    function __SenateVotesQuorumFraction_init(uint256 quorumNumeratorValue)
        internal
        onlyInitializing
    {
        __SenateVotesQuorumFraction_init_unchained(quorumNumeratorValue);
    }

    function __SenateVotesQuorumFraction_init_unchained(
        uint256 quorumNumeratorValue
    ) internal onlyInitializing {
        _updateQuorumNumerator(quorumNumeratorValue);
    }

    /**
     * @dev Returns the current quorum numerator. See {quorumDenominator}.
     */
    function quorumNumerator() public view virtual returns (uint256) {
        return
            _quorumNumeratorHistory._checkpoints.length == 0
                ? _quorumNumerator
                : _quorumNumeratorHistory.latest();
    }

    /**
     * @dev Returns the quorum numerator at a specific block number. See {quorumDenominator}.
     */
    function quorumNumerator(uint256 blockNumber)
        public
        view
        virtual
        returns (uint256)
    {
        // If history is empty, fallback to old storage
        uint256 length = _quorumNumeratorHistory._checkpoints.length;
        if (length == 0) {
            return _quorumNumerator;
        }

        // Optimistic search, check the latest checkpoint
        CheckpointsUpgradeable.Checkpoint
            memory latest = _quorumNumeratorHistory._checkpoints[length - 1];
        if (latest._blockNumber <= blockNumber) {
            return latest._value;
        }

        // Otherwize, do the binary search
        return _quorumNumeratorHistory.getAtBlock(blockNumber);
    }

    /**
     * @dev Returns the quorum denominator. Defaults to 100, but may be overridden.
     */
    function quorumDenominator() public view virtual returns (uint256) {
        return 100;
    }

    /**
     * @dev Returns the quorum for a block number, in terms of number of votes: `supply * numerator / denominator`.
     */
    function quorum(uint256 blockNumber)
        public
        view
        virtual
        override
        returns (uint256)
    {
        uint256 totalPastVotes;

        totalPastVotes += getPastTotalSupply(blockNumber);
        // _delegateCheckpoints[account].getAtProbablyRecentBlock(
        //   blockNumber
        //);

        return
            (totalPastVotes * quorumNumerator(blockNumber)) /
            quorumDenominator();
    }

    /**
     * @dev Changes the quorum numerator.
     *
     * Emits a {QuorumNumeratorUpdated} event.
     *
     * Requirements:
     *
     * - Must be called through a Chancellor proposal.
     * - New numerator must be smaller or equal to the denominator.
     */
    function updateQuorumNumerator(uint256 newQuorumNumerator)
        external
        virtual
        onlyChancellor
    {
        _updateQuorumNumerator(newQuorumNumerator);
    }

    /**
     * @dev Changes the quorum numerator.
     *
     * Emits a {QuorumNumeratorUpdated} event.
     *
     * Requirements:
     *
     * - New numerator must be smaller or equal to the denominator.
     */
    function _updateQuorumNumerator(uint256 newQuorumNumerator)
        internal
        virtual
    {
        require(
            newQuorumNumerator <= quorumDenominator(),
            "ChancellorVotesQuorumFraction: quorumNumerator over quorumDenominator"
        );

        uint256 oldQuorumNumerator = quorumNumerator();

        // Make sure we keep track of the original numerator in contracts upgraded from a version without checkpoints.
        if (
            oldQuorumNumerator != 0 &&
            _quorumNumeratorHistory._checkpoints.length == 0
        ) {
            _quorumNumeratorHistory._checkpoints.push(
                CheckpointsUpgradeable.Checkpoint({
                    _blockNumber: 0,
                    _value: SafeCastUpgradeable.toUint224(oldQuorumNumerator)
                })
            );
        }

        // Set new quorum for future proposals
        _quorumNumeratorHistory.push(newQuorumNumerator);

        emit QuorumNumeratorUpdated(oldQuorumNumerator, newQuorumNumerator);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[48] private __gap;
}
