// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.23;


contract JointCheckContract {
    struct Check {
        uint256 amount;
        address issuer;
        address[] recipients;
        bytes32 contractHash; // IPFS hash of the associated contract
        uint256 expirationDate;
        mapping(address => bytes) signatures; // Signatures of recipients
        mapping(address => bool) isSigned;
        bool isAccepted;
        CheckState state;
        uint256 signedCount; // Count of signed recipients
    }

    enum CheckState { Created, Issued, Signed, Accepted, Rejected, Expired }
    uint256 private nextCheckId = 1;
    mapping(uint256 => Check) public checks;
    uint256 public constant MAX_RECIPIENTS = 10;

    event CheckIssued(uint256 checkId, address issuer, uint256 amount, bytes32 contractHash, uint256 expirationDate);
    event CheckSigned(uint256 checkId, address recipient);
    event CheckAccepted(uint256 checkId);
    event CheckRejected(uint256 checkId, address recipient);
    event CheckExpired(uint256 checkId);

    // Issue a new check
    function issueCheck
    (uint256 amount, address[] memory recipients, bytes32 contractHash, uint256 expirationDate) 
    public returns (uint256) {
        require(recipients.length > 0 && recipients.length <= MAX_RECIPIENTS, "Invalid number of recipients");
        Check storage newCheck = checks[nextCheckId];
        newCheck.amount = amount;
        newCheck.issuer = msg.sender;
        newCheck.recipients = recipients;
        newCheck.contractHash = contractHash;
        newCheck.expirationDate = expirationDate;
        newCheck.state = CheckState.Created;
        newCheck.signedCount = 0;

        emit 
        CheckIssued 
        (nextCheckId, msg.sender, amount, contractHash, expirationDate);
        nextCheckId++;
        return nextCheckId - 1;
    }

    // Recipients sign the check
    function signCheck(uint256 checkId, bytes memory signature) public {
        Check storage check = checks[checkId];
        require(check.state == CheckState.Issued, "Check is not issued yet");
        require(isRecipient(check, msg.sender), "Sender is not a recipient of the check");
        require(!check.isSigned[msg.sender], "Already signed");
        require(!isExpired(checkId), "Check has expired");

        check.signatures[msg.sender] = signature;
        check.isSigned[msg.sender] = true;
        check.signedCount++;
        emit 
        CheckSigned
        (checkId, msg.sender);
    }

    // Recipients reject the check
    function rejectCheck(uint256 checkId) public {
        Check storage check = checks[checkId];
        require(isRecipient(check, msg.sender), "Sender is not a recipient of the check");
        require(check.state == CheckState.Issued, "Check is not issued yet");

        check.state = CheckState.Rejected;
        emit CheckRejected
        (checkId, msg.sender);
    }

    // Check if all recipients have signed the check
    function allRecipientsSigned(uint256 checkId) public view returns (bool) {
        Check storage check = checks[checkId];
        return check.signedCount == check.recipients.length;
    }

    // Issuer accepts the check
    function acceptCheck(uint256 checkId) public {
        Check storage check = checks[checkId];
        require(msg.sender == check.issuer, "Only issuer can accept the check");
        require(allRecipientsSigned(checkId), "Not all recipients have signed the check");
        require(!isExpired(checkId), "Check has expired");

        check.state = CheckState.Accepted;
        emit CheckAccepted
        (checkId);
    }

    // Helper function to check if the check is expired
    function isExpired(uint256 checkId) public view returns (bool) {
        Check storage check = checks[checkId];
        return block.timestamp > check.expirationDate;
    }

    // Helper function to check if an address is a recipient of the check
    function isRecipient(Check storage check, address user) internal view returns (bool) {
        for (uint i = 0; i < check.recipients.length; i++) {
            if (check.recipients[i] == user) {
                return true;
            }
        }
        return false;
    }
}


