require 'spec_helper'

describe 'clickhouse::client::config' do
  let(:title) { 'custom' }
  let(:params) { { data: { parameter: [{ subparameter: ['value'] }] } } }

  it do
    is_expected.to contain_class('clickhouse::client').with(
      conf_d_dir: '/etc/clickhouse-client/conf.d',
    )
  end

  it { is_expected.to contain_package('clickhouse-client') }

  it do
    is_expected.to contain_file('/etc/clickhouse-client/conf.d').with(
      ensure: 'directory',
      owner: 'clickhouse',
      group: 'clickhouse',
    )
  end

  it do
    out = "\
<config>
  <parameter>
    <subparameter>value</subparameter>
  </parameter>
</config>\n"
    is_expected.to contain_file('/etc/clickhouse-client/conf.d/custom.xml') \
      .with_content(out)
  end
end
