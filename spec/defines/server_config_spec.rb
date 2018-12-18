require 'spec_helper'

describe 'clickhouse::server::config' do
  let(:title) { 'custom' }
  let(:params) { { data: { parameter: [{ subparameter: ['value'] }] } } }

  context 'without section parameter' do
    it { is_expected.to compile.and_raise_error(%r{expects a value for parameter 'section'}) }
  end

  context 'with section: invalid_value' do
    let(:params) { super().merge(section: 'invalid_value') }

    it { is_expected.to compile.and_raise_error(%r{parameter 'section' expects a match for Enum\['config', 'users'\]}) }
  end

  context 'with section: config' do
    let(:params) { super().merge(section: 'config') }

    it do
      is_expected.to contain_class('clickhouse::server').with(
        conf_d_dir: '/etc/clickhouse-server/conf.d',
        users_d_dir: '/etc/clickhouse-server/users.d',
      )
    end

    it do
      out = "\
<yandex>
  <parameter>
    <subparameter>value</subparameter>
  </parameter>
</yandex>\n"
      is_expected.to contain_file('/etc/clickhouse-server/conf.d/custom.xml') \
        .with_content(out)
    end
  end

  context 'with section: users' do
    let(:params) { super().merge(section: 'users') }

    it do
      out = "\
<yandex>
  <parameter>
    <subparameter>value</subparameter>
  </parameter>
</yandex>\n"
      is_expected.to contain_file('/etc/clickhouse-server/users.d/custom.xml') \
        .with_content(out)
    end
  end

  context 'custom server config paths' do
    let(:pre_condition) { "class { 'clickhouse::server': conf_d_dir => '/some/random/path' }" }
    let(:params) { super().merge(section: 'config') }

    it do
      out = "\
<yandex>
  <parameter>
    <subparameter>value</subparameter>
  </parameter>
</yandex>\n"
      is_expected.to contain_file('/some/random/path/custom.xml') \
        .with_content(out)
    end
    it do
      is_expected.to contain_file('/some/random/path').with(
        ensure: 'directory',
        owner: 'clickhouse',
        group: 'clickhouse',
      )
    end
  end
end
