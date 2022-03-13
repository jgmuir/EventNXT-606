class ExpirationValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if !value.present?
    unless value > Date.today
      record.errors.add attribute, (options[:message] || "can't be in the past")
    end
  end
end