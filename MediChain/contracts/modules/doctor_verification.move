module Medichain::doctor_verification {
    use AptosFramework::Signer;
    use std::error;
    use std::string::{Self, String};

    struct Doctor has key {
        license_number: String, 
        specialization: String,
        verification_status: bool,
        // Add other relevant fields as needed (e.g., hospital affiliation, contact info)
    }

    const EDOCTOR_NOT_VERIFIED: u64 = 0; // Error code: Doctor not verified

    public entry fun register_doctor(account: &signer, license_number: String, specialization: String) {
        let doctor_addr = Signer::address_of(account);
        assert!(
            !exists<Doctor>(doctor_addr),
            error::already_exists(EDOCTOR_NOT_VERIFIED)
        );

        move_to(
            account,
            Doctor {
                license_number,
                specialization,
                verification_status: false // Initially not verified
            }
        );
    }

    // Function for an admin to verify a doctor (simplified for hackathon)
    public entry fun verify_doctor(account: &signer, doctor_addr: address) acquires Doctor {
        // In a real scenario, this would involve complex checks against a database
        // For the hackathon, assume the admin has the authority to verify directly
        let doctor = borrow_global_mut<Doctor>(doctor_addr);
        doctor.verification_status = true;
    }

    public fun is_doctor_verified(doctor_addr: address): bool acquires Doctor {
        let doctor = borrow_global<Doctor>(doctor_addr);
        doctor.verification_status
    }
}
