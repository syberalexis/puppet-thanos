require 'spec_helper'

describe 'Thanos::Tracing_type' do
  describe 'accepted values' do
    [
      'JAEGER',
      'STACKDRIVER',
      'ELASTIC_APM',
      'LIGHTSTEP',
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
