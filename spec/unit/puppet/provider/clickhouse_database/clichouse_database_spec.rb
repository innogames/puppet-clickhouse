# frozen_string_literal: true

require 'spec_helper'

describe Puppet::Type.type(:clickhouse_database).provider(:clickhouse) do
  let(:resource) do
    Puppet::Type.type(:clickhouse_database).new(
      ensure: :present,
      name: 'test_database',
      engine: :Lazy,
      engine_settings: 60,
      provider: described_class.name,
    )
  end
  let(:provider) { resource.provider }

  before :each do
    allow(Puppet::Util).to receive(:which).with('clickhouse-client').and_return('/usr/bin/clickhouse-client')
    allow(provider.class).to receive(:execute_sql).with(
      <<-SQL
SELECT d.name,
  d.engine,
  countIf(t.name != '') AS tables
FROM system.databases AS d
FULL OUTER JOIN system.tables AS t
ON d.name = t.database
GROUP BY d.name, d.engine
      SQL
    ).and_return("system\tOrdinary\t47\nmysql\tMySQL\t3\nlazy\tLazy\t0\n")
  end

  describe 'self.instances' do
    it 'returns array of databases' do
      instances = provider.class.instances.map { |i| i.name }
      expect(instances).to eq(['system', 'mysql', 'lazy'])
    end
  end

  describe 'self.prefetch' do
    it 'fills up existing resources' do
      provider.class.instances
      provider.class.prefetch({})
    end
  end

  describe 'create' do
    it 'creates resource database' do
      allow(provider.class).to receive(:execute_sql).with(
        'CREATE DATABASE test_database ENGINE=Lazy(60)',
      )
      expect(provider.create).to be_truthy
    end

    it 'creates Lazy database' do
      provider.instance_variable_get('@resource')[:name] = 'test_lazy'
      provider.instance_variable_get('@resource')[:engine] = :Lazy
      provider.instance_variable_get('@resource')[:engine_settings] = 10
      allow(provider.class).to receive(:execute_sql).with(
        'CREATE DATABASE test_lazy ENGINE=Lazy(10)',
      )
      expect(provider.create).to be_truthy
    end

    it 'creates Mysql database' do
      provider.instance_variable_get('@resource')[:name] = 'test_mysql'
      provider.instance_variable_get('@resource')[:engine] = :MySQL
      provider.instance_variable_get('@resource')[:engine_settings] = ['host:port', 'database', 'user', 'password']
      allow(provider.class).to receive(:execute_sql).with(
        "CREATE DATABASE test_mysql ENGINE=MySQL('host:port', 'database', 'user', 'password')",
      )
      expect(provider.create).to be_truthy
    end

    it 'creates Ordinary database' do
      provider.instance_variable_get('@resource')[:name] = 'test_ordinary'
      provider.instance_variable_get('@resource')[:engine] = :Ordinary
      provider.instance_variable_get('@resource').delete(:engine_settings)
      allow(provider.class).to receive(:execute_sql).with(
        'CREATE DATABASE test_ordinary ENGINE=Ordinary',
      )
      expect(provider.create).to be_truthy
    end
  end

  describe 'destroy' do
    before :each do
      allow(provider.class).to receive(:execute_sql).with(
        "DROP DATABASE #{resource[:name]}",
      )
    end

    it 'drops an empty database' do
      provider.instance_variable_get('@property_hash')[:tables] = 0
      provider.instance_variable_get('@property_hash')[:engine] = :Ordinary
      expect(provider.destroy).to be_truthy
    end

    it 'rejects to drop a non empty database' do
      tables = 5
      provider.instance_variable_get('@property_hash')[:tables] = tables
      expect { provider.destroy }.to raise_error(
        Puppet::Error, "database with #{tables} tables won't be removed; use 'force'"
      )
    end

    it 'drops a non empty MySQL database' do
      provider.instance_variable_get('@property_hash')[:engine] = :MySQL
      provider.instance_variable_get('@property_hash')[:tables] = 1
      expect(provider.destroy).to be_truthy
    end

    it 'drops a non empty Ordinary database with force=true' do
      provider.instance_variable_get('@property_hash')[:tables] = 1
      allow(provider).to receive(:force?).and_return(true)
      expect(provider.destroy).to be_truthy
    end
  end

  describe 'delete' do
    it 'invokes destroy' do
      allow(provider).to receive(:destroy).and_return(true)
      expect(provider.delete).to be_truthy
    end
  end

  describe 'exists?' do
    it 'returns true on :present' do
      provider.instance_variable_get('@property_hash')[:ensure] = :present
      expect(provider).to be_exists
    end

    it 'returns false on :absent' do
      provider.instance_variable_get('@property_hash')[:ensure] = :absent
      expect(provider).not_to be_exists
    end
  end

  describe 'force?' do
    it 'returns true' do
      provider.instance_variable_get('@resource')[:force] = true
      expect(provider).to be_force
    end

    it 'returns false' do
      provider.instance_variable_get('@resource')[:force] = false
      expect(provider).not_to be_force
    end
  end

  describe 'engine=' do
    it 'recreate resource' do
      allow(provider).to receive(:create).and_return(true)
      allow(provider).to receive(:destroy).and_return(true)
      provider.engine = :Ordinary
    end
  end

  describe 'engine' do
    it 'returns @property_hash[:engine]' do
      provider.instance_variable_get('@property_hash')[:engine] = :Ordinary
      expect(provider.engine).to eq(:Ordinary)

      provider.instance_variable_get('@property_hash')[:engine] = :MySQL
      expect(provider.engine).to eq(:MySQL)

      provider.instance_variable_get('@property_hash')[:engine] = :Lazy
      expect(provider.engine).to eq(:Lazy)
    end
  end

  describe 'engine_string' do
    it 'returns Lazy engine' do
      provider.instance_variable_get('@resource')[:engine] = :Lazy
      provider.instance_variable_get('@resource')[:engine_settings] = 555
      expect(provider.engine_string).to eq('Lazy(555)')
    end

    it 'returns Mysql engine' do
      provider.instance_variable_get('@resource')[:engine] = :MySQL
      provider.instance_variable_get('@resource')[:engine_settings] = ['[::1]:12345', 'database', 'user', 'password']
      expect(provider.engine_string).to eq("MySQL('[::1]:12345', 'database', 'user', 'password')")
    end

    it 'returns Ordinary engine' do
      provider.instance_variable_get('@resource')[:engine] = :Ordinary
      provider.instance_variable_get('@resource').delete(:engine_settings)
      expect(provider.engine_string).to eq('Ordinary')
    end

    it 'raise error on engine and settings mismatch' do
      provider.instance_variable_get('@resource')[:engine_settings] = ['host:port', 'database', 'user', 'password']
      expect { provider.engine_string }.to raise_error(Puppet::Error, 'Wrong attribute engine_settings `["host:port", "database", "user", "password"]` for given engine `Lazy`')

      provider.instance_variable_get('@resource')[:engine] = :Ordinary
      expect { provider.engine_string }.to raise_error(Puppet::Error, 'Wrong attribute engine_settings `["host:port", "database", "user", "password"]` for given engine `Ordinary`')

      provider.instance_variable_get('@resource')[:engine] = :MySQL
      provider.instance_variable_get('@resource')[:engine_settings] = 1
      expect { provider.engine_string }.to raise_error(Puppet::Error, 'Wrong attribute engine_settings `1` for given engine `MySQL`')
    end
  end
end
