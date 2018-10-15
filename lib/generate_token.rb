require 'password_encoder'

module GenerateToken
  include PasswordEncoder

  def get_token(_field)
    "#{random_part}#{Time.current.to_i}#{random_part}"
  end

  private

  def random_part
    (0...8).map { (65 + rand(26)).chr }.join
  end
end
