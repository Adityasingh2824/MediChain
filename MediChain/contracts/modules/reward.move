module Medichain::reward {
    use AptosFramework::Coin;
    use AptosFramework::Signer;
    use std::error;
    use Medichain::patient_data;

    struct Reward has key {
        amount: u64
    }

    const EALREADY_REWARDED: u64 = 0;
    const EINSUFFICIENT_BALANCE: u64 = 1;
    
    // Function to initialize reward for a patient
    public entry fun initialize_reward(
        account: &signer,
        amount: u64
    ) {
        let patient_addr = Signer::address_of(account);
        
        assert!(
            !exists<Reward>(patient_addr),
            error::already_exists(EALREADY_REWARDED)
        );
        
        // Check if the account that initialized the reward has enough balance
        let rewarder_addr = Signer::address_of(account);
        assert!(
            Coin::balance<CoinType>(rewarder_addr) >= amount,
            error::invalid_state(EINSUFFICIENT_BALANCE)
        );

        move_to(account, Reward { amount });
    }


    // Function for a researcher to claim the reward for a patient
    public entry fun claim_reward(
        patient: &signer,
        researcher: &signer,
        _data_hash: vector<u8>  // Placeholder for future data validation
    ) acquires Reward, patient_data::PatientData {

        let patient_addr = Signer::address_of(patient);
        let researcher_addr = Signer::address_of(researcher);

        // Check if the researcher has permission to access the patient's data
        assert!(
            patient_data::get_doctor_address(patient_addr) == researcher_addr,
            error::invalid_argument(patient_data::ENO_PERMISSION)
        );

        // Transfer the reward to the researcher
        let reward = move_from<Reward>(patient_addr);
        Coin::deposit<CoinType>(researcher_addr, Coin::withdraw<CoinType>(patient_addr, reward.amount));

        // (Optional) You can add logic to register the data sharing agreement here.
    }
}
// ... (existing code) ...
    public entry fun claim_reward(
        patient: &signer,
        researcher: &signer,
        _data_hash: vector<u8>  // Placeholder for future data validation
    ) acquires Reward, patient_data::PatientData {
        let patient_addr = Signer::address_of(patient);
        let researcher_addr = Signer::address_of(researcher);

        // Check data sharing agreement before allowing reward claim
        assert!(data_sharing::is_agreement_active(patient_addr, researcher_addr), error::permission_denied(patient_data::ENO_PERMISSION));

        // ... (rest of the claim_reward function) ...
    }
// ... (rest of the code) ...
