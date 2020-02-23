require 'spec_helper'

describe 'Thanos::Log_level' do
  describe 'accepted values' do
    [
      'debug',
      'info',
      'warn',
      'error',
      'fatal',
    ].each do |value|
      describe value.inspect do
        it { is_expected.to allow_value(value) }
      end
    end
  end

  describe 'rejects other values' do
    [
      '',
      'test',
      '123',
      3,
    ].each do |value|
      describe value.inspect do
        it { is_expected.not_to allow_value(value) }
      end
    end
  end
end
