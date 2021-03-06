require "spec_helper"

describe "phone number" do
  it "should be 10 digits" do
    expect { Mblox::Sms.new("2"*9, the_message) }.to raise_error(Mblox::SmsError, "Phone number must be ten or eleven digits")
    expect { Mblox::Sms.new("2"*10, the_message) }.to_not raise_error
    expect { Mblox::Sms.new("2"*11, the_message) }.to_not raise_error
  end

  it "should not start with 0 or 1" do
    expect { Mblox::Sms.new("1"+"2"*9, the_message) }.to raise_error(Mblox::SmsError, "Phone number cannot begin with 0 or 1")
    expect { Mblox::Sms.new("0"+"2"*9, the_message) }.to raise_error(Mblox::SmsError, "Phone number cannot begin with 0 or 1")
  end

  it "should not change on send" do
    number = TEST_NUMBER.to_s
    mblox = Mblox::Sms.new(number,the_message)
    expect(mblox.phone).to eq("#{TEST_NUMBER}")
  end
end

describe "message" do
  it "cannot be blank" do
    expect { Mblox::Sms.new("2"*10, "") }.to raise_error(Mblox::SmsError, "Message cannot be blank")
  end

  it "can be 160 characters long" do
    expect { Mblox::Sms.new("2"*10, "A"*160) }.to_not raise_error
  end

  it "will be truncated when the message is longer than 160 characters if configured to do so" do
    message = "A"+"ABCDEFGHIJ"*16
    Mblox.config.on_message_too_long = :truncate
    expect { @mblox = Mblox::Sms.new("2"*10, message) }.to_not raise_error
    expect(@mblox.message).to eq(message[0,160])
  end

  it "cannot be longer than 160 characters if configured to raise error" do
    Mblox.config.on_message_too_long = :raise_error
    expect { Mblox::Sms.new("2"*10, "A"*161) }.to raise_error(Mblox::SmsError, "Message cannot be longer than 160 characters")
  end

  it "should be safe from changing" do
    msg = the_message
    mblox = Mblox::Sms.new(TEST_NUMBER,msg)
    msg[1..3] = ''
    expect(mblox.message).to eq(the_message)
  end
end

describe "SMS messages" do
  it "should be sent when the phone number is a Fixnum" do
    expect(Mblox::Sms.new(TEST_NUMBER.to_i,the_message).send).to eq(result_ok)
  end

  it "should be sent when the phone number is a String" do
    expect(Mblox::Sms.new(TEST_NUMBER.to_s,the_message).send).to eq(result_ok)
  end

  it "should allow 160-character messages" do
    expect(Mblox::Sms.new(TEST_NUMBER,"A"*160).send).to eq(result_ok)
  end

  it "should fail when sent to a landline" do
    expect(Mblox::Sms.new("34932661431",the_message).send).to eq(result_unroutable)
  end
end
