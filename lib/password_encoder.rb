module PasswordEncoder
  def encrypt(message)
    cipher = OpenSSL::Cipher.new('aes-256-cbc')
    cipher.encrypt
    cipher.key = secret_key
    cipher.iv = secret_iv

    encrypted = cipher.update(message)
    encrypted << cipher.final

    Base64.encode64(encrypted).encode('utf-8')
  end

  def decrypt(message)
    decoded = Base64.decode64(message.encode('ascii-8bit'))

    cipher = OpenSSL::Cipher.new('aes-256-cbc')
    cipher.decrypt
    cipher.key = secret_key
    cipher.iv = secret_iv

    decrypted = cipher.update(decoded)
    decrypted << cipher.final
    decrypted
  end

  private

  def secret_key
    "\xFF\xE1\r\a\x80=\xEA\xD9\xA5kOp\xEBd\x8C\x8A~\x93\xB1\x17\x7F^\e\x12\xD2\xE3=\xE7\xFB\x97\xB2\xEE"
  end

  def secret_iv
    " \xF6\xAF_5\xCD\xF7\r\x8BbG\x10\x880x\xA3"
  end
end
