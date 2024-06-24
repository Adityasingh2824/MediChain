module Medichain::data_sharing {
    use AptosFramework::Signer;
    use Medichain::patient_data;
    use std::error;
    use std::string::{Self, String};

    struct DataSharingAgreement has key {
        patient_address: address,
        researcher_address: address,
        data_types: vector<String>,  
        start_time: u64,
        end_time: u64,
        // (Optional) Add fields for terms, conditions, payment info, etc.
    }

    const EINVALID_TIMEFRAME: u64 = 0;
    const EALREADY_SHARED: u64 = 1;
    const ENOT_AUTHORIZED: u64 = 2;

    // Function for a patient to create a data sharing agreement
    public entry fun create_agreement(
        patient: &signer,
        researcher_address: address,
        data_types: vector<String>,
        duration_days: u64
    ) acquires patient_data::PatientData {
        let patient_addr = Signer::address_of(patient);

        // Check if patient has granted access to the researcher
        assert!(
            patient_data::get_doctor_address(patient_addr) == researcher_address,
            error::permission_denied(ENOT_AUTHORIZED)
        );

        let current_time = aptos_framework::timestamp::now_seconds();
        let end_time = current_time + (duration_days * 86400); // 86400 seconds in a day

        assert!(current_time < end_time, error::invalid_argument(EINVALID_TIMEFRAME));

        // Check if an agreement already exists for this patient-researcher pair
        assert!(
            !exists<DataSharingAgreement>(patient_addr, researcher_address),
            error::already_exists(EALREADY_SHARED)
        );

        move_to(
            patient,
            DataSharingAgreement {
                patient_address: patient_addr,
                researcher_address,
                data_types,
                start_time: current_time,
                end_time
            }
        );
    }

    // Function to check if a data sharing agreement is active
    public fun is_agreement_active(patient_addr: address, researcher_addr: address): bool acquires DataSharingAgreement {
        if (exists<DataSharingAgreement>(patient_addr, researcher_addr)) {
            let agreement = borrow_global<DataSharingAgreement>(patient_addr, researcher_addr);
            let current_time = aptos_framework::timestamp::now_seconds();
            return agreement.start_time <= current_time && current_time <= agreement.end_time;
        } else {
            return false;
        }
    }
}
// ... (existing code) ...

    struct DataSharingAgreement has key {
        // ... existing fields ...
        terms: String,                  // Terms and conditions of the agreement
        payment_info: Option<String>,    // Payment details (if applicable)
    }

    // ... (existing functions) ...

    // Function for a patient to revoke an agreement
    public entry fun revoke_agreement(account: &signer, researcher_address: address) acquires DataSharingAgreement {
        let patient_addr = Signer::address_of(account);
        let DataSharingAgreement { patient_address: _, researcher_address: _, data_types: _, start_time: _, end_time: _, terms, payment_info } 
            = move_from<DataSharingAgreement>(patient_addr, researcher_address);
    }
}
// ... (existing code) ...
    public entry fun create_agreement(
        patient: &signer,
        researcher_address: address,
        data_types: vector<String>,
        duration_days: u64
    ) acquires patient_data::PatientData {
        // ...
        // Additional check:
        for data_type in data_types {
            let type_u8 = data_type_to_u8(data_type); // Convert string to u8 (implement this helper function)
            assert!(
                access_control::has_access(patient_addr, researcher_address, type_u8), 
                error::permission_denied(ENOT_AUTHORIZED)
            );
        }
        // ...
    }
// ... (rest of the code) ...
