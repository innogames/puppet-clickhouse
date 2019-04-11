# frozen_string_literal: true

require 'spec_helper'

describe 'clickhouse::error' do
  let(:title) { 'Error message' }
  let(:params) do
    {}
  end

  it { is_expected.to compile }
  it do
    is_expected.to contain_exec('Error message')
      .with_command('/$')
  end
end
