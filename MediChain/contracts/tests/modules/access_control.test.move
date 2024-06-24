#[test_only]
module Medichain::access_control_tests {
    use AptosFramework::Signer;
    use Medichain::access_control::{Self, EHR, IMAGING};

    #[test(patient = @0x123, doctor = @0x456)]
    fun test_grant_and_check_access(patient: &signer, doctor: &signer) {
        let allowed_types = vector::empty<u8>();
        vector::push_back(&mut allowed_types, EHR);
        vector::push_back(&mut allowed_types, IMAGING);

        access_control::grant_access(patient, Signer::address_of(doctor), allowed_types);
        assert!(access_control::has_access(Signer::address_of(patient), Signer::address_of(doctor), EHR), 0);
        assert!(access_control::has_access(Signer::address_of(patient), Signer::address_of(doctor), IMAGING), 1);
        assert!(!access_control::has_access(Signer::address_of(patient), Signer::address_of(doctor), GENOMIC), 2); 
    }

    // Additional test cases:
    // - Test for failure when granting access with invalid data types.
    // - Test for failure when checking access for a grantee who hasn't been granted access.
    // - Test for granting access twice to the same grantee (should fail).
}
