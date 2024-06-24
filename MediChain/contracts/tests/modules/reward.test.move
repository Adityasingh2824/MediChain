#[test_only]
module Medichain::reward_tests {
    use AptosFramework::Coin;
    use AptosFramework::Signer;
    use Medichain::patient_data::{Self, PatientData};
    use Medichain::reward::{Self, Reward};

    #[test(patient = @0x123, researcher = @0x456)]
    fun test_reward_flow(patient: &signer, researcher: &signer) {
        // Initialize reward
        Coin::register<CoinType>(patient);
        Coin::register<CoinType>(researcher);
        Coin::deposit<CoinType>(patient, 100); // Give patient some coins
        reward::initialize_reward(patient, 50); // Initialize with 50 coins reward

        // Grant access to researcher
        patient_data::create_patient_data(patient, b"data_hash", Signer::address_of(researcher), x"");

        // Claim reward
        let patient_balance_before = Coin::balance<CoinType>(Signer::address_of(patient));
        let researcher_balance_before = Coin::balance<CoinType>(Signer::address_of(researcher));

        reward::claim_reward(patient, researcher, b"data_hash"); 

        let patient_balance_after = Coin::balance<CoinType>(Signer::address_of(patient));
        let researcher_balance_after = Coin::balance<CoinType>(Signer::address_of(researcher));
        assert!(patient_balance_before - patient_balance_after == 50, 0);
        assert!(researcher_balance_after - researcher_balance_before == 50, 1);
    }

    // Additional test cases:
    // - Test failure when researcher doesn't have access
    // - Test failure when reward has already been claimed
    // - Test failure when the account initializing the reward doesn't have enough balance
}
