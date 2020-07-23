# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:clickhouse_database) do
  context 'base check' do
    let(:resource) do
      described_class.new(name: 'test_database', ensure: :present,
                          engine: :Lazy, engine_settings: 10, force: :true)
    end
    let(:error_msg) do
      "Parameter engine_settings failed on Clickhouse_database[#{resource[:name]}]: " \
        'parameter engine_settings not Optional[Integer[1], Array[String, 4, 4]]'
    end
    let(:wrong_engines) do
      [0, 'string', [], ['', '', ''], ['', '', '', 0]]
    end

    it 'accepts name' do
      expect(resource[:name]).to eq('test_database')
      expect { described_class.new(name: 'name with invalid chars') }.to raise_error(
        Puppet::ResourceError,
        'Parameter name failed on Clickhouse_database[name with invalid chars]: parameter name must match /\A[0-9a-zA-Z_]+\Z/',
      )
    end

    it 'accepts ensure' do
      expect(resource[:ensure]).to eq(:present)
    end

    it 'accepts engine' do
      expect(resource[:engine]).to eq(:Lazy)
    end

    it 'accepts engine_settings' do
      expect(resource[:engine_settings]).to eq(10)
    end

    it 'accepts force' do
      expect(resource[:force]).to eq(true)
    end

    it 'requires a name' do
      expect { described_class.new({}) }.to raise_error(Puppet::Error, 'Title or name must be provided')
    end

    it 'requires Optional[Integer[1], Array[String, 4, 4]] as :engine_settings' do
      wrong_engines.each do |engine|
        expect { described_class.new(name: resource[:name], engine_settings: engine) }.to raise_error(
          Puppet::ResourceError, error_msg
        )
      end
    end
  end

  context 'check Lazy engine' do
    let(:resource) do
      described_class.new(name: 'test_database', ensure: :present,
                          engine: :Lazy, engine_settings: 10)
    end
    let(:error_msg) do
      "Validation of Clickhouse_database[#{resource[:name]}] failed: Attribute `engine_settings` must be Integer[1] with engine => 'Lazy'"
    end

    it 'checks valid engine type' do
      expect(resource).to be_parameter_lazy
      expect(resource).not_to be_parameter_mysql
      expect(resource).not_to be_parameter_ordinary
    end

    it 'raises an error on wrong engine + engine_settings' do
      expect {
        described_class.new(name: resource[:name], engine: resource[:engine])
      }.to raise_error(Puppet::ResourceError, error_msg)

      expect {
        described_class.new(name: resource[:name], engine: :Lazy, engine_settings: ['', '', '', ''])
      }.to raise_error(Puppet::ResourceError, error_msg)
    end
  end

  context 'check MySQL engine' do
    let(:resource) do
      described_class.new(name: 'test_database', ensure: :present, engine: :MySQL,
                          engine_settings: ['host:port', 'database', 'user', 'password'])
    end
    let(:error_msg) do
      "Validation of Clickhouse_database[#{resource[:name]}] failed: Attribute `engine_settings` must be Array[String, 4, 4] with engine => 'MySQL'"
    end

    it 'checks valid engine type' do
      expect(resource).not_to be_parameter_lazy
      expect(resource).to be_parameter_mysql
      expect(resource).not_to be_parameter_ordinary
    end

    it 'raises an error on wrong engine + engine_settings' do
      expect {
        described_class.new(name: resource[:name], engine: resource[:engine])
      }.to raise_error(Puppet::ResourceError, error_msg)

      expect {
        described_class.new(name: resource[:name], engine: resource[:engine], engine_settings: 1)
      }.to raise_error(Puppet::ResourceError, error_msg)
    end
  end

  context 'check Ordinary engine' do
    let(:resource) do
      described_class.new(name: 'test_database', ensure: :present, engine: :Ordinary)
    end
    let(:error_msg) do
      "Validation of Clickhouse_database[#{resource[:name]}] failed: Attribute `engine_settings` must be undef with engine => 'Ordinary'"
    end

    it 'checks valid engine type' do
      expect(resource).not_to be_parameter_lazy
      expect(resource).not_to be_parameter_mysql
      expect(resource).to be_parameter_ordinary
    end

    it 'raises an error on wrong engine + engine_settings' do
      expect {
        described_class.new(name: resource[:name], engine: resource[:engine], engine_settings: ['', '', '', ''])
      }.to raise_error(Puppet::ResourceError, error_msg)

      expect {
        described_class.new(name: resource[:name], engine: resource[:engine], engine_settings: 1)
      }.to raise_error(Puppet::ResourceError, error_msg)
    end
  end
end
