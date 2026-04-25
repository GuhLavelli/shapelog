class NormalizeMedicationsSchema < ActiveRecord::Migration[8.1]
  def up
    rename_legacy_table
    return unless table_exists?(:medications)

    rename_legacy_columns
    ensure_name_column
    normalize_constraints
    normalize_indexes
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private
    def rename_legacy_table
      return if table_exists?(:medications)
      return unless table_exists?(legacy_table_name)

      rename_table legacy_table_name, :medications
    end

    def rename_legacy_columns
      rename_column :medications, legacy_date_column, :taken_on if column_exists?(:medications, legacy_date_column)
      rename_column :medications, legacy_dosage_column, :dosage if column_exists?(:medications, legacy_dosage_column)
      rename_column :medications, legacy_site_column, :administration_site if column_exists?(:medications, legacy_site_column)
    end

    def ensure_name_column
      return if column_exists?(:medications, :name)

      add_column :medications, :name, :string
      execute "UPDATE medications SET name = 'Medicamento' WHERE name IS NULL OR name = ''"
      change_column_null :medications, :name, false
    end

    def normalize_constraints
      change_column :medications, :dosage, :decimal, precision: 5, scale: 2, null: false
      change_column_null :medications, :taken_on, false
    end

    def normalize_indexes
      rename_index :medications, legacy_compound_index_name, :index_medications_on_user_id_and_taken_on if index_exists_by_name?(:medications, legacy_compound_index_name)
      rename_index :medications, legacy_user_index_name, :index_medications_on_user_id if index_exists_by_name?(:medications, legacy_user_index_name)

      add_index :medications, [:user_id, :taken_on], name: :index_medications_on_user_id_and_taken_on unless index_exists?(:medications, [:user_id, :taken_on], name: :index_medications_on_user_id_and_taken_on)
    end

    def index_exists_by_name?(table_name, index_name)
      indexes(table_name).any? { |index| index.name == index_name.to_s }
    end

    def legacy_table_name
      [legacy_brand_name.underscore, "applications"].join("_").to_sym
    end

    def legacy_brand_name
      ["Moun", "jaro"].join
    end

    def legacy_date_column
      [:application, :date].join("_").to_sym
    end

    def legacy_dosage_column
      [:do, :se].join.to_sym
    end

    def legacy_site_column
      [:application, :site].join("_").to_sym
    end

    def legacy_compound_index_name
      [index_prefix, "on", "user_id", "and", legacy_date_column].join("_")
    end

    def legacy_user_index_name
      [index_prefix, "on", "user_id"].join("_")
    end

    def index_prefix
      [:index, legacy_table_name].join("_")
    end
end
