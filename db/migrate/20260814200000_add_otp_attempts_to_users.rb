class AddOtpAttemptsToUsers < ActiveRecord::Migration[8.1]
  # Backs the brute-force guard in User#verify_otp!. The OTP is six digits and
  # lives for five minutes, and until now a wrong guess cost the attacker
  # nothing: the code stayed valid, no counter moved, and there is no rate
  # limiting in front of the endpoint — so the whole 10^6 keyspace was
  # reachable inside the window.
  def change
    add_column :users, :otp_attempts, :integer, default: 0, null: false
  end
end
