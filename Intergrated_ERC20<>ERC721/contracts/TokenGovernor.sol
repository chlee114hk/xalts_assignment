// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/governance/GovernorUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorSettingsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorCountingSimpleUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesQuorumFractionUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @custom:security-contact security@plush.family
contract TokenGovernor is Initializable, GovernorUpgradeable, GovernorSettingsUpgradeable, GovernorCountingSimpleUpgradeable, GovernorVotesUpgradeable, GovernorVotesQuorumFractionUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    function __Token_Governor_init(IVotesUpgradeable _token)
    initializer public
    {
        __Governor_init("Governor");
        __GovernorSettings_init(1 /* 1 block */, type(uint256).max /* assume no end time for vote */, 0);
        __GovernorCountingSimple_init();
        __GovernorVotes_init(_token);
        __GovernorVotesQuorumFraction_init(0);
        __Ownable_init();
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    onlyOwner
    override
    {}

    // The following functions are overrides required by Solidity.

    function votingDelay()
    public
    view
    virtual
    override(IGovernorUpgradeable, GovernorSettingsUpgradeable)
    returns (uint256)
    {
        return super.votingDelay();
    }

    function votingPeriod()
    public
    view
    virtual
    override(IGovernorUpgradeable, GovernorSettingsUpgradeable)
    returns (uint256)
    {
        return super.votingPeriod();
    }

    function quorum(uint256 blockNumber)
    public
    view
    virtual
    override(IGovernorUpgradeable, GovernorVotesQuorumFractionUpgradeable)
    returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    function getVotes(address account, uint256 blockNumber)
    public
    view
    virtual
    override
    returns (uint256)
    {
        return super.getVotes(account, blockNumber);
    }

    function state(uint256 proposalId)
    public
    view
    virtual
    override(GovernorUpgradeable)
    returns (ProposalState)
    {
        return super.state(proposalId);
    }

    function proposalThreshold()
    public
    view
    virtual
    override(GovernorUpgradeable, GovernorSettingsUpgradeable)
    returns (uint256)
    {
        return super.proposalThreshold();
    }

    function _execute(uint256 proposalId, address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
    internal
    virtual
    override(GovernorUpgradeable)
    {
        super._execute(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
    internal
    virtual
    override(GovernorUpgradeable)
    returns (uint256)
    {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor()
    internal
    view
    virtual
    override(GovernorUpgradeable)
    returns (address)
    {
        return super._executor();
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(GovernorUpgradeable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _voteSucceeded(uint256 proposalId)
        internal 
        view 
        virtual
        override(GovernorCountingSimpleUpgradeable, GovernorUpgradeable)
    returns (bool) {
        return super._voteSucceeded(proposalId);
    }

    function _countVote(
        uint256 proposalId,
        address account,
        uint8 support,
        uint256 weight,
        bytes memory params// params
    ) 
        internal
        virtual 
        override(GovernorCountingSimpleUpgradeable, GovernorUpgradeable)
    {
        super._countVote(proposalId, account, support, weight, params);
    }

}