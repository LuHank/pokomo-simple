// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract PokomoGame {
    struct Pokomo {
        string name;
        uint attack;
        uint defense;
    }

    mapping(address => Pokomo[]) public accPokomos;

    // 新增：追蹤所有擁有 Pokomo 的玩家
    address[] private players;
    mapping(address => bool) private seen;

    address public owner;

    event Log(address _player, string _newPokomo);
    event EnhanceLog(address indexed _player, string _name, string _enhanceAbility);

    constructor() {
        owner = msg.sender; // constructor 賦予值
    }

    modifier onlyOwner() {
        require(msg.sender != address(0), "invalid address");
        require(msg.sender == owner, "only owner can execute");
        _;
    }

    function createPokomo(string memory _name) public returns (uint) {
        if (!seen[msg.sender]) {
            seen[msg.sender] = true;
            players.push(msg.sender);
        }
        accPokomos[msg.sender].push(Pokomo(_name, 0, 0));

        emit Log(msg.sender, _name);

        return accPokomos[msg.sender].length - 1;
    }

    function enhanceAttack(uint _idx) public payable {
        require(msg.value >= 0.01 ether, unicode"需至少付費 0.01 ETH 才能增加攻擊能力");
        Pokomo storage _pokomo = accPokomos[msg.sender][_idx];
        _pokomo.attack += 1;

        emit EnhanceLog(msg.sender, _pokomo.name, "Attack");
    }

    function enhanceDefense(uint _idx) public payable {
        require(msg.value >= 0.001 ether, unicode"需至少付費 0.001 ETH 才能增加防禦能力");
        Pokomo storage _pokomo = accPokomos[msg.sender][_idx];
        _pokomo.defense += 1;

        emit EnhanceLog(msg.sender, _pokomo.name, "Defense");
    }

    function myPokomo() public view returns (Pokomo[] memory) {
        uint len = accPokomos[msg.sender].length;
        Pokomo[] memory list = new Pokomo[](len);
        for (uint i = 0; i < len; i++) {
            list[i] = accPokomos[msg.sender][i];
        }
        return list;
    }

    // Owner 專用：列出所有玩家的 Pokomo
    function allPokomos() external view onlyOwner returns (Pokomo[] memory, address[] memory) {
        uint total = 0;
        for (uint i = 0; i < players.length; i++) {
            total += accPokomos[players[i]].length;
        }

        Pokomo[] memory list = new Pokomo[](total);
        address[] memory owners = new address[](total);

        uint k = 0;
        for (uint i = 0; i < players.length; i++) {
            for (uint j = 0; j < accPokomos[players[i]].length; j++) {
                list[k] = accPokomos[players[i]][j];
                owners[k] = players[i]; // 對應的擁有者
                k++;
            }
        }
        return (list, owners);
    }

    // Owner 專用：查詢合約餘額
    function getBalance() external view onlyOwner returns (uint256) {
        return address(this).balance;
    }
}
