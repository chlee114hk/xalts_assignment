// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/draft-ERC20PermitUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";

import "@openzeppelin/contracts-upgradeable/governance/GovernorUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorSettingsUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorCountingSimpleUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesQuorumFractionUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ShareToken is Initializable, ERC20Upgradeable, OwnableUpgradeable, ERC20PermitUpgradeable, ERC20VotesUpgradeable, ERC721Holder, GovernorUpgradeable, GovernorSettingsUpgradeable, GovernorCountingSimpleUpgradeable, GovernorVotesUpgradeable, GovernorVotesQuorumFractionUpgradeable {
//contract ShareToken is ERC20, Ownable, Governor, ERC20Permit, ERC20Votes, ERC721Holder, GovernorSettings, GovernorCountingSimple, GovernorVotes, GovernorVotesQuorumFraction {
    IERC721 public clauseNFT;
    uint256 public tokenId;
    bool public initialized = false;
    
    mapping(address => address) private _delegatee;
    mapping(address => bool) internal frozen;
    
    event AddressFrozen(address indexed _userAddress, bool indexed _isFrozen);

    modifier notRestrictedTransfer(address _from, address _to) {
        require(!frozen[_from] || _to == msg.sender);
        _;
    }

    // constructor(string memory _name, string memory _symbol)
    //     ERC20(_name, _symbol) 
    //     ERC20Permit(_name)
    //     // Governor(_name)
    //     // GovernorSettings(1 /* 1 block */, type(uint256).max /* assume no end time for vote */, 0)
    //     // GovernorVotes(IVotes(address(this)))
    //     // GovernorVotesQuorumFraction(0)
    // {}
    /// @custom:oz-upgrades-unsafe-allow constructor

    constructor() {
        _disableInitializers();
    }

    function initialize(string memory _name, string memory _symbol, address _clauseNFT, uint256 _tokenId) external onlyOwner {
        require(!initialized, "Already initialized");
        __ERC20_init(_name, _symbol);
        __Ownable_init();
        __ERC20Permit_init(_name);
        __ERC20Votes_init();
        __Governor_init(_name);
        __GovernorSettings_init(1 /* 1 block */, type(uint256).max /* assume no end time for vote */, 0);
        __GovernorCountingSimple_init();
        __GovernorVotes_init(IVotesUpgradeable(address(this)));
        __GovernorVotesQuorumFraction_init(0);

        clauseNFT = IERC721(_clauseNFT);
        clauseNFT.safeTransferFrom(msg.sender, address(this), _tokenId);
        initialized = true;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _setAddressFrozen(address _userAddress, bool _freeze) internal {
        frozen[_userAddress] = _freeze;
        emit AddressFrozen(_userAddress, _freeze);
    }

    function setAddressFrozen(address _userAddress, bool _freeze) public onlyOwner {
        _setAddressFrozen(_userAddress, _freeze);
    }

    function _delegate(address delegator, address delegatee) 
        internal
        override(ERC20VotesUpgradeable)
    {
        _delegatee[delegator] = delegator;
        super._delegate(delegator, delegatee);
    }

    function propose (
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    )
        public
        override(GovernorUpgradeable)
        onlyOwner
        returns (uint256)
    {
        return super.propose(targets, values, calldatas, description);
    }

    function updateClause(address _clauseNFT, uint256 _tokenId) public 
        onlyGovernance
    {
        clauseNFT = IERC721(_clauseNFT);
        clauseNFT.safeTransferFrom(msg.sender, address(this), _tokenId);
    }

    function proposeUpdateClause(address _clauseNFT, uint256 _tokenId) public
        onlyOwner
    {
        bytes memory callDataPayload = abi.encodeWithSignature("updateClause(address,uint256)", _clauseNFT, _tokenId);
        
        address[] memory addressList;
        uint256[] memory valueList;
        bytes[] memory calldataList;

        addressList[0] = address(this);
        valueList[0] = 0;
        calldataList[0] = callDataPayload;

        propose(addressList, valueList, calldataList, "Update Clause");
    }

    function _voteSucceeded(uint256 proposalId) 
        internal 
        view 
        override(GovernorUpgradeable, GovernorCountingSimpleUpgradeable)
    returns (bool) {
        uint256 forVotes;
        uint256 againstVotes;
        uint256 abstainVotes;
        (againstVotes, forVotes, abstainVotes) = proposalVotes(proposalId);

        return token.getPastTotalSupply(proposalSnapshot(proposalId)) <= forVotes + againstVotes + abstainVotes;
    }

    function _countVote(
        uint256 proposalId,
        address account,
        uint8 support,
        uint256 weight,
        bytes memory params// params
    ) 
        internal 
        //override(Governor, GovernorCountingSimple)
        override(GovernorUpgradeable, GovernorCountingSimpleUpgradeable)
    {
        super._countVote(proposalId, account, support, weight, params);

        address delegator = _delegatee[account];

        // freeze account if the account vote against the proposal
        if (support == uint8(VoteType.Against)) {
            _setAddressFrozen(delegator, true);
        }
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        override
        notRestrictedTransfer(from, to)
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    // The following functions are overrides required by Solidity.
    function name() public 
        view
        override(GovernorUpgradeable, ERC20Upgradeable)
        returns (string memory) 
    {
        return super.name();
    }

    function onERC721Received(address operator, address from, uint256 _tokenId, bytes calldata data ) 
        public 
        override(GovernorUpgradeable, ERC721Holder)
        returns (bytes4) 
    {
        return super.onERC721Received(operator, from, _tokenId, data);
    }

    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        if (to != address(0) && numCheckpoints(to) == 0 && delegates(to) == address(0)) {
            _delegate(to, to);
        }
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        super._burn(account, amount);
    }

    function votingDelay()
        public
        view
        override(IGovernorUpgradeable, GovernorSettingsUpgradeable)
        returns (uint256)
    {
        return super.votingDelay();
    }

    function votingPeriod()
        public
        view
        override(IGovernorUpgradeable, GovernorSettingsUpgradeable)
        returns (uint256)
    {
        return super.votingPeriod();
    }

    function quorum(uint256 blockNumber)
        public
        view
        override(IGovernorUpgradeable, GovernorVotesQuorumFractionUpgradeable)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    function proposalThreshold()
        public
        view
        override(GovernorUpgradeable, GovernorSettingsUpgradeable)
        returns (uint256)
    {
        return super.proposalThreshold();
    }
}