module Medichain::access_control {
    use AptosFramework::Signer;
    use std::error;
    use std::vector;

    struct AccessRule has key, store {
        grantee: address,   // Address granted access
        data_types: vector<u8>,  // Bitmask representing allowed data types
        // (Optional) Add expiration timestamp for time-limited access
    }

    const ENO_PERMISSION: u64 = 0;
    const EINVALID_DATA_TYPE: u64 = 1;
    const EACCESS_ALREADY_GRANTED: u64 = 2;

    // Define constants for data types (bit positions)
    const EHR: u8 = 0x01;         
    const IMAGING: u8 = 0x02;     
    const GENOMIC: u8 = 0x04;     
    // Add more data types as needed

    // Function for a patient to grant access to specific data types
    public entry fun grant_access(
        patient: &signer,
        grantee: address,
        allowed_data_types: vector<u8>
    ) {
        let patient_addr = Signer::address_of(patient);

        // (Optional) Check if grantee is a verified doctor (using doctor_verification module)
        // ...

        // Validate data types
        assert!(
            are_valid_data_types(allowed_data_types),
            error::invalid_argument(EINVALID_DATA_TYPE)
        );

        // Check if access rule already exists for this grantee
        assert!(
            !exists<AccessRule>(patient_addr, grantee),
            error::already_exists(EACCESS_ALREADY_GRANTED)
        );

        move_to(patient, AccessRule { grantee, data_types: allowed_data_types });
    }

    // Function to check if a party has access to a specific data type
    public fun has_access(patient_addr: address, requester_addr: address, data_type: u8): bool acquires AccessRule {
        if (exists<AccessRule>(patient_addr, requester_addr)) {
            let rule = borrow_global<AccessRule>(patient_addr, requester_addr);
            return (vector::contains(&rule.data_types, &data_type));
        } else {
            return false;
        }
    }

    // Helper function to validate data types
    fun are_valid_data_types(data_types: vector<u8>): bool {
        for type in data_types {
            if !(type == EHR || type == IMAGING || type == GENOMIC) { // Add more data types as needed
                return false;
            }
        }
        return true;
    }
}
module Medichain::access_control {
    // ... existing code ...

    struct AccessRule has key, store {
        // ... existing fields ...
        expiration_time: u64 // Timestamp for expiration 
    }

    // ... existing functions ...

    // Function to revoke access
    public entry fun revoke_access(patient: &signer, grantee: address) acquires AccessRule {
        let patient_addr = Signer::address_of(patient);
        let AccessRule { grantee: _, data_types: _, expiration_time: _ } = move_from<AccessRule>(patient_addr, grantee);
    }

    // Function to modify access (e.g., change allowed data types)
    public entry fun modify_access(
        patient: &signer,
        grantee: address,
        new_allowed_data_types: vector<u8>
    ) acquires AccessRule {
        let patient_addr = Signer::address_of(patient);
        let rule = borrow_global_mut<AccessRule>(patient_addr, grantee);

        // Validate new data types
        assert!(
            are_valid_data_types(new_allowed_data_types),
            error::invalid_argument(EINVALID_DATA_TYPE)
        );

        rule.data_types = new_allowed_data_types;
        // (Optional) Update expiration_time if needed
    }
    
    // Modified has_access function to check for expiration
    public fun has_access(patient_addr: address, requester_addr: address, data_type: u8): bool acquires AccessRule {
        if (exists<AccessRule>(patient_addr, requester_addr)) {
            let rule = borrow_global<AccessRule>(patient_addr, requester_addr);
            let current_time = aptos_framework::timestamp::now_seconds();
            return (vector::contains(&rule.data_types, &data_type) && rule.expiration_time > current_time);
        } else {
            return false;
        }
    }
}
