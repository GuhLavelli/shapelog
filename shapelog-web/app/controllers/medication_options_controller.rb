class MedicationOptionsController < ApplicationController
  def index
    options = MedicationOption.suggestions_for(user: Current.user, query: params[:q]).map do |option|
      {
        id: option.id,
        name: option.name,
        normalized_name: option.normalized_name
      }
    end

    render json: { options: options }
  end
end
