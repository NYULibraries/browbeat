require 'spec_helper'
require 'browbeat'

describe Browbeat do
  it "should have curl installed on host" do
    expect(`curl --help`).to be_present
  end
end
