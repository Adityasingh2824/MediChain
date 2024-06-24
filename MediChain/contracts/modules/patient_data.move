module Medichain::patient_data {
    use AptosFramework::Signer;
    use std::error;
    use std::vector;
    use std::string::{Self, String};

    struct PatientData has key {
        data_hash: vector<u8>,       // Hash of the patient's health data
        doctor_address: address,   // Address allowed to access the data
        data_types: vector<String>,  // Types of data included (e.g., "EHR", "Imaging")
        timestamp: u64,             // Timestamp of last data update
    }

    const ENO_PERMISSION: u64 = 0; // Error code: No permission to access data
    const EALREADY_EXISTS: u64 = 1;
    const EINVALID_DATA_TYPE: u64 = 2;

    // Function to create a new patient data record
    public entry fun create_patient_data(
        account: &signer,
        data_hash: vector<u8>,
        doctor_address: address,
        data_types: vector<String>
    ) {
        let patient_addr = Signer::address_of(account);

        assert!(
            !exists<PatientData>(patient_addr),
            error::already_exists(EALREADY_EXISTS)
        );

        // Basic validation for data types (you can add more rigorous checks)
        assert!(
            !vector::is_empty(&data_types),
            error::invalid_argument(EINVALID_DATA_TYPE)
        );

        move_to(
            account,
            PatientData { data_hash, doctor_address, data_types, timestamp: 0 } // Initialize timestamp
        );
    }

    // Function to update existing patient data
    public entry fun update_patient_data(
        account: &signer,
        new_data_hash: vector<u8>,
        data_types: vector<String>
    ) acquires PatientData {
        let patient_addr = Signer::address_of(account);
        let data = borrow_global_mut<PatientData>(patient_addr);

        // Basic validation for data types (you can add more rigorous checks)
        assert!(
            !vector::is_empty(&data_types),
            error::invalid_argument(EINVALID_DATA_TYPE)
        );

        data.data_hash = new_data_hash;
        data.data_types = data_types;
        data.timestamp = aptos_framework::timestamp::now_microseconds();
    }

    // Function to grant access to a new doctor
    public entry fun grant_access(account: &signer, new_doctor: address) acquires PatientData {
        let patient_addr = Signer::address_of(account);
        let data = borrow_global_mut<PatientData>(patient_addr);
        data.doctor_address = new_doctor;
    }

    // Function to revoke access from the current doctor
    public entry fun revoke_access(account: &signer) acquires PatientData {
        let patient_addr = Signer::address_of(account);
        let data = borrow_global_mut<PatientData>(patient_addr);
        data.doctor_address = @0x0; // Set to the null address to revoke access
    }
   
    // ... additional functions for querying data (similar to get_data_hash from previous example)

}
// ... (existing code) ...

    public entry fun grant_access(account: &signer, new_doctor: address) acquires PatientData {
        let patient_addr = Signer::address_of(account);
        let data = borrow_global_mut<PatientData>(patient_addr);
        assert!(doctor_verification::is_doctor_verified(new_doctor), error::invalid_argument(ENO_PERMISSION)); // Check verification
        data.doctor_address = new_doctor;
    }

// ... (rest of the code) ...
// ... (existing code) ...
    public fun is_data_sharing_allowed(patient_addr: address, requester_addr: address): bool acquires PatientData {
        // Check if the requester is the authorized doctor or if there's an active data-sharing agreement
        let data = borrow_global<PatientData>(patient_addr);
        data.doctor_address == requester_addr 
            || data_sharing::is_agreement_active(patient_addr, requester_addr)
    }
// ... (rest of the code) ...
// ... (existing code) ...
    public fun get_data_hash(patient_addr: address, requester_addr: address, data_type: u8): vector<u8> acquires PatientData {
        let data = borrow_global<PatientData>(patient_addr);
        assert!(
            access_control::has_access(patient_addr, requester_addr, data_type),
            error::permission_denied(ENO_PERMISSION)
        );
        // ... return data_hash if access is granted ...
    }
// ... (rest of the code) ...
