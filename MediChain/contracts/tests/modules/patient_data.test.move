#[test_only]
module Medichain::patient_data_tests {
    use AptosFramework::Signer;
    use AptosFramework::Timestamp;
    use Medichain::patient_data::{Self, PatientData, EHR, IMAGING};
    use std::string::{Self, String};

    #[test(patient = @0x123, doctor = @0x456)]
    fun test_create_patient_data(patient: &signer, doctor: &signer) {
        let data_hash = b"some_data_hash";
        let doctor_addr = Signer::address_of(doctor);

        let data_types = vector::empty<String>();
        vector::push_back(&mut data_types, String::utf8(b"EHR"));
        vector::push_back(&mut data_types, String::utf8(b"Imaging")); // Assuming "Imaging" is a valid data type

        patient_data::create_patient_data(patient, data_hash, doctor_addr, data_types);
        
        let patient_data = borrow_global<PatientData>(Signer::address_of(patient));
        assert!(patient_data.data_hash == data_hash, 0);
        assert!(patient_data.doctor_address == doctor_addr, 1);
        // You can add assertions for data_types and timestamp if needed
    }

    #[test(patient = @0x123, new_doctor = @0x789)]
    fun test_grant_access(patient: &signer, new_doctor: &signer) acquires PatientData {
        let data_hash = b"some_data_hash";
        let old_doctor_addr = @0x456;
        let new_doctor_addr = Signer::address_of(new_doctor);
        let data_types = vector::empty<String>();
        vector::push_back(&mut data_types, String::utf8(b"EHR"));
        patient_data::create_patient_data(patient, data_hash, old_doctor_addr, data_types);

        patient_data::grant_access(patient, new_doctor_addr);
        let patient_data = borrow_global<PatientData>(Signer::address_of(patient));
        assert!(patient_data.doctor_address == new_doctor_addr, 0);
    }

    #[test(patient = @0x123)]
    fun test_update_patient_data(patient: &signer) acquires PatientData {
        let data_hash = b"some_data_hash";
        let doctor_addr = @0x456;
        let new_data_hash = b"new_data_hash";
        let data_types = vector::empty<String>();
        vector::push_back(&mut data_types, String::utf8(b"EHR"));
        patient_data::create_patient_data(patient, data_hash, doctor_addr, data_types);
        Timestamp::set_time_has_started_for_testing(); // Start time for testing

        let patient_data_before = borrow_global<PatientData>(Signer::address_of(patient));

        Timestamp::advance_seconds(10); // Simulate time passing

        let new_data_types = vector::empty<String>();
        vector::push_back(&mut new_data_types, String::utf8(b"EHR"));
        vector::push_back(&mut new_data_types, String::utf8(b"Imaging")); 
        patient_data::update_patient_data(patient, new_data_hash, new_data_types);

        let patient_data_after = borrow_global<PatientData>(Signer::address_of(patient));

        assert!(patient_data_after.data_hash == new_data_hash, 0);
        assert!(patient_data_after.data_types != patient_data_before.data_types, 1); 
        assert!(patient_data_after.timestamp > patient_data_before.timestamp, 2);
    }
   

    // ... Add more tests for revoke_access, get_data_hash, error cases, etc.
}
