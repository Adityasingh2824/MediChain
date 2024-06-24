#[test_only]
module Medichain::doctor_verification_tests {
    use AptosFramework::Signer;
    use Medichain::doctor_verification;

    #[test(doctor = @0x123)]
    fun test_register_and_verify(doctor: &signer) {
        doctor_verification::register_doctor(doctor, "LICENSE123", "Cardiologist");
        assert!(!doctor_verification::is_doctor_verified(Signer::address_of(doctor)), 1);

        doctor_verification::verify_doctor(doctor, Signer::address_of(doctor)); // Self-verification for testing
        assert!(doctor_verification::is_doctor_verified(Signer::address_of(doctor)), 0);
    }

    #[test(doctor = @0x123)]
    #[expected_failure(abort_code = 0x10006, location = Self)] // Already exists error
    fun test_register_twice(doctor: &signer) {
        doctor_verification::register_doctor(doctor, "LICENSE123", "Cardiologist");
        doctor_verification::register_doctor(doctor, "LICENSE456", "Neurologist");
    }
}
