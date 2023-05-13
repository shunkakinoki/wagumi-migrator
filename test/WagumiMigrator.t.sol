// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {Test} from "forge-std/Test.sol";

import {IERC721} from "../src/IERC721.sol";
import {WagumiMigrator} from "../src/WagumiMigrator.sol";

contract WagumiMigratorTest is Test {
    // The contract being tested
    WagumiMigrator migrator;

    // The fork of the Ethereum mainnet
    uint256 mainnetFork;

    // The RPC URL of the Ethereum mainnet
    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    // Origin safe address
    address private constant ORIGIN_SAFE_ADDRESS = 0xDCE4694e268bD83EA41B335320Ed11A684a1d7dB;

    function setUp() public {
        // Deploy the contract being tested
        migrator = new WagumiMigrator();

        // Create a fork of the Ethereum mainnet
        mainnetFork = vm.createFork(MAINNET_RPC_URL);
    }

    // Test that the migration contract works as expected
    // by simulating a fork of the Ethereum mainnet on foundry.
    function test_fork_simulation() public {
        // Select the mainnet fork
        vm.selectFork(mainnetFork);

        // Get the before balances of the origin safe address
        uint256 beforeOriginSafeAddressBalance = (ORIGIN_SAFE_ADDRESS).balance;

        // Set the sender to the origin safe address
        vm.prank(ORIGIN_SAFE_ADDRESS);
        migrator.migrate();

        // Assert that the destination safe address has received the NFTs
        // and the contract has received the ETH
        assertEq((ORIGIN_SAFE_ADDRESS).balance, 0);
        assertEq((address(migrator)).balance, 0);
        assertEq((address(this)).balance, 0);
        assertEq(((migrator.DESTINATION_SAFE_ADDRESS.address).balance), beforeOriginSafeAddressBalance);

        // Assert that the NFTs have been transferred correctly
        for (uint256 i = 0; i < 10; i++) {
            assertEq(IERC721(migrator.NFT_CONTRACT_ADDRESS()).ownerOf(i), migrator.DESTINATION_SAFE_ADDRESS.address);
        }
    }
}
