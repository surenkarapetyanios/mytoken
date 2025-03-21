// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title MyToken
 * @author 
 * @notice Implementation of an ERC20 token with ownership control and minting capability.
 * @dev This contract is based on the standard ERC20 implementation, enhanced with:
 *  - Owner-only minting functionality.
 *  - Built-in overflow checks (Solidity 0.8+).
 *  - Comprehensive NatSpec comments for documentation.
 *  - No external dependencies (no OpenZeppelin, implemented from scratch).
 */
contract MyToken {
    // ---------- Events ----------
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to another (`to`).
     *
     * Note that `value` may be zero, as transfers of zero are allowed.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by a call to {approve}.
     * `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Emitted when ownership of the contract is transferred from `previousOwner` to `newOwner`.
     */
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    // ---------- State Variables ----------
    /// @notice Name of the token.
    string public name;
    /// @notice Symbol of the token (usually a shorter version of the name).
    string public symbol;
    /// @notice Number of decimal places the token uses for display purposes (common is 18).
    uint8 public constant decimals = 18;
    /// @dev Total supply of tokens in circulation.
    uint256 private _totalSupply;
    /// @notice The owner of the contract (assigned as the deployer initially).
    address public owner;
    /// @dev Balances for each account.
    mapping(address => uint256) private _balances;
    /// @dev Allowances record: owner -> (spender -> amount).
    mapping(address => mapping(address => uint256)) private _allowances;

    // ---------- Modifiers ----------
    /**
     * @dev Modifier to restrict functions to contract owner.
     * Reverts if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    // ---------- Constructor ----------
    /**
     * @notice Deploy the token contract and mint the initial supply to the deployer.
     * @param _name Name of the token.
     * @param _symbol Symbol of the token.
     * @param _initialSupply Initial token supply to mint (in the smallest unit) to the deployer's address.
     * @dev The deployer address becomes the contract owner. All initial tokens are assigned to the owner.
     */
    constructor(string memory _name, string memory _symbol, uint256 _initialSupply) {
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        _mint(owner, _initialSupply);  // Mint initial supply to the contract owner
    }

    // ---------- ERC20 Standard Functions ----------

    /**
     * @notice Returns the total number of tokens in circulation.
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @notice Returns the token balance of a given account.
     * @param account The address to query for balance.
     * @return The amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    /**
     * @notice Transfers `amount` tokens from the caller's account to `recipient`.
     * @param recipient The address to receive the tokens.
     * @param amount The number of tokens to transfer.
     * @return True if the transfer succeeded, false otherwise (reverts on failure).
     *
     * Requirements:
     * - Caller must have at least `amount` tokens.
     * - `recipient` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[msg.sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        // Deduct from sender and add to recipient
        _balances[msg.sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @notice Returns the remaining number of tokens that `spender` is allowed to spend on behalf of `owner`.
     * @param owner_ The address which owns the tokens.
     * @param spender The address which will spend the tokens.
     * @return The remaining allowance for `spender` to spend from `owner_`'s balance.
     *
     * This value changes when {approve}, {increaseAllowance}, or {decreaseAllowance} are called.
     */
    function allowance(address owner_, address spender) external view returns (uint256) {
        return _allowances[owner_][spender];
    }

    /**
     * @notice Sets `amount` as the allowance of `spender` over the caller's tokens.
     * @param spender The address which is approved to spend the tokens.
     * @param amount The number of tokens to allow `spender` to spend.
     * @return True if the approval succeeded (reverts on failure).
     *
     * Requirements:
     * - `spender` cannot be the zero address.
     *
     * Emits an {Approval} event.
     *
     * IMPORTANT: To prevent double-spend issues, it is recommended to first reduce the spender's allowance to 0 
     * and then set the desired value, or use {increaseAllowance}/{decreaseAllowance} for modifying allowances.
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * @notice Transfers `amount` tokens from `sender` to `recipient` using the allowance mechanism.
     * @param sender The address to debit tokens from (must have approved the caller).
     * @param recipient The address to credit the tokens to.
     * @param amount The number of tokens to transfer.
     * @return True if the transfer succeeded (reverts on failure).
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - Caller (msg.sender) must have allowance for `sender`'s tokens of at least `amount`.
     *
     * Emits a {Transfer} event.  
     * Emits an {Approval} event to reflect the reduced allowance.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        // Reduce the allowance
        _allowances[sender][msg.sender] = currentAllowance - amount;

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        // Perform the transfer
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
        // Optional: Emit an Approval event for the updated allowance (for transparency, as in OpenZeppelin ERC20)
        emit Approval(sender, msg.sender, _allowances[sender][msg.sender]);
        return true;
    }

    // ---------- Allowance Adjustment (Optional) ----------

    /**
     * @notice Atomically increases the allowance granted to `spender` by the caller.
     * @param spender The address which will be allowed to spend the tokens.
     * @param addedValue The additional amount of tokens to allow.
     * @return True if the operation succeeded.
     *
     * Emits an {Approval} event with the updated allowance.
     */
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[msg.sender][spender] += addedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    /**
     * @notice Atomically decreases the allowance granted to `spender` by the caller.
     * @param spender The address which will have its allowance decreased.
     * @param subtractedValue The amount of tokens to subtract from the current allowance.
     * @return True if the operation succeeded.
     *
     * Requirements:
     * - Current allowance must be at least `subtractedValue`.
     *
     * Emits an {Approval} event with the updated allowance.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _allowances[msg.sender][spender] = currentAllowance - subtractedValue;
        emit Approval(msg.sender, spender, _allowances[msg.sender][spender]);
        return true;
    }

    // ---------- Owner-Only Functions ----------

    /**
     * @notice Mints `amount` new tokens to address `to`.
     * @param to The address that will receive the minted tokens.
     * @param amount The number of tokens to mint.
     *
     * Requirements:
     * - Caller must be the contract owner.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /**
     * @notice Transfers ownership of the contract to a new account (`newOwner`).
     * @param newOwner The address of the new owner.
     *
     * Requirements:
     * - Caller must be the current owner.
     * - `newOwner` cannot be the zero address.
     *
     * Emits an {OwnershipTransferred} event.
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @notice Renounces ownership of the contract. This will leave the contract without an owner.
     * **Warning:** Renouncing ownership will disable the `onlyOwner` functionality, including minting new tokens.
     *
     * Requirements:
     * - Caller must be the current owner.
     *
     * Emits an {OwnershipTransferred} event, transferring ownership to the zero address.
     */
    function renounceOwnership() external onlyOwner {
        emit OwnershipTransferred(owner, address(0));
        owner = address(0);
    }

    // ---------- Internal Functions ----------

    /**
     * @dev Internal function that creates `amount` tokens and assigns them to `account`, increasing the total supply.
     * @param account The address receiving the new tokens.
     * @param amount The number of tokens to mint.
     *
     * Requirements:
     * - `account` cannot be the zero address.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
}
