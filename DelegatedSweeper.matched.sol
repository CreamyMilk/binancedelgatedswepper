// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;
/* Reconstructed source, not recovered original source.
 * Compiles byte-for-byte to the observed executable runtime of
 * 0x63e842B054Bd624a465454D533C33F573e9c6fAe at Ethereum block 26300770.
 * Build: solc 0.8.28, viaIR=true, optimizer enabled/runs=200, evmVersion=cancun.
 * Strip CBOR metadata using the final two-byte big-endian length, plus those
 * two bytes: executable runtime = 1621 bytes; original metadata trailer = 53.
 * All function, error, and event selector preimages have been identified.
 * Function names confirmed by selector hashing; database matches alone do not
 * prove original source spelling. Internal names and contract name are inferred.
 */

contract DelegatedSweeper {
    address public constant authorizedCaller = 0x7C8601d4645b93cea45F71e118A729332e6B5CA0;
    error NotAuthorized();
    error TokenTransferFailed();
    error ETHTransferFailed();
    error ExecuteCallFailed(address account, bytes reason);
    error NoCodeAtExecutor(address executor);
    event SweepItemFailed(address indexed token, uint8 reason);
    modifier onlyAuthorized() {
        if (msg.sender != authorizedCaller) revert NotAuthorized();
        _;
    }
    receive() external payable {}

    function withdrawToken(address token, address payable to, uint256 amount) external onlyAuthorized {
        _withdrawToken(token, to, amount);
    }

    function withdrawETH(address to, uint256 amount) external onlyAuthorized {
        _withdrawETH(to, amount);
    }

    function _withdrawToken(address token, address payable to, uint256 amount) internal {
        if (amount == 0) return;
        (bool ok,) = token.call(abi.encodeWithSignature("transfer(address,uint256)", to, amount));
        if (!ok) revert TokenTransferFailed();
    }

    function _withdrawETH(address to, uint256 amount) internal {
        if (amount == 0) return;
        (bool ok,) = payable(to).call{value: amount}("");
        if (!ok) revert ETHTransferFailed();
    }

    function sweep(address payable to, address[] calldata tokens) external onlyAuthorized {
        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            if (token == address(0)) {
                uint256 balance = address(this).balance;
                if (balance > 1 ether) {
                    (bool ok,) = payable(to).call{value: balance - 1 ether}("");
                    if (!ok) emit SweepItemFailed(token, 3);
                }
            } else {
                (bool ok, bytes memory ret) =
                    token.staticcall(abi.encodeWithSignature("balanceOf(address)", address(this)));
                if (!ok || ret.length < 32) {
                    emit SweepItemFailed(token, 1);
                    continue;
                }
                uint256 balance = abi.decode(ret, (uint256));
                if (balance > 0) {
                    (bool success,) =
                        token.call(abi.encodeWithSignature("transfer(address,uint256)", address(to), balance));
                    if (!success) emit SweepItemFailed(token, 2);
                }
            }
        }
    }

    function callExecute(address account, address to, uint256 value, bytes calldata data)
        external
        payable
        onlyAuthorized
        returns (bytes memory)
    {
        if (account.code.length == 0) {
            revert NoCodeAtExecutor(account);
        }
        (bool ok, bytes memory result) =
            account.call{value: msg.value}(abi.encodeWithSelector(bytes4(0xb61d27f6), to, value, data));
        if (!ok) revert ExecuteCallFailed(account, result);
        return result;
    }
}
