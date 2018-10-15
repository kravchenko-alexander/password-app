class EmailValidator < ActiveModel::EachValidator
  EMAIL_REGEX = /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  def validate_each(record, attribute, value)
    return if value =~ EMAIL_REGEX

    record.errors.add(attribute, I18n.t('activerecord.errors.email_format'))
  end
end
