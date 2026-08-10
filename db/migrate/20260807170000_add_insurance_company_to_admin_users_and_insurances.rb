class AddInsuranceCompanyToAdminUsersAndInsurances < ActiveRecord::Migration[8.1]
  def change
    add_reference :admin_users, :insurance_company, null: true, foreign_key: true
    add_reference :insurances, :insurance_company, null: true, foreign_key: true

    reversible do |dir|
      dir.up do
        # Backfill existing orders by matching the denormalized company
        # name string against InsuranceCompany.name — the only linkage
        # available since Insurance never had a real FK before this.
        execute <<~SQL
          UPDATE insurances
          SET insurance_company_id = insurance_companies.id
          FROM insurance_companies
          WHERE insurances.company = insurance_companies.name
            AND insurances.insurance_company_id IS NULL
        SQL
      end
    end
  end
end
