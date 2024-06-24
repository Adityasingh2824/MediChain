#[test_only]
module Medichain::data_sharing_tests {
    use AptosFramework::Signer;
    use AptosFramework::Timestamp;
    use Medichain::data_sharing::{Self, DataSharingAgreement};
    use Medichain::patient_data;
    use std::string::{Self, String};

    #[test(patient = @0x123, researcher = @0x456)]
    fun test_create_and_check_agreement(patient: &signer, researcher: &signer) {
        Timestamp::set_time_has_started_for_testing();

        patient_data::create_patient_data(patient, b"data_hash", Signer::address_of(researcher), x""); // Grant access

        let data_types = vector::empty<String>();
        vector::push_back(&mut data_types, String::utf8(b"EHR"));

        DataSharingAgreement::create_agreement(patient, Signer::address_of(researcher), data_types, 10); 

        assert!(DataSharingAgreement::is_agreement_active(
            Signer::address_of(patient), 
            Signer::address_of(researcher)), 0
        );

        Timestamp::advance_seconds(86400 * 11); // Advance time by 11 days

        assert!(!DataSharingAgreement::is_agreement_active(
            Signer::address_of(patient), 
            Signer::address_of(researcher)), 1
        );
    }

    // Additional test cases:
    // - Test for failure when researcher does not have access
    // - Test for failure when trying to create an agreement with an invalid timeframe
    // - Test for failure when an agreement already exists for the same patient and researcher
}
