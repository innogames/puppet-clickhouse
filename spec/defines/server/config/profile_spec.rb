# frozen_string_literal: true

require 'spec_helper'

describe 'clickhouse::server::config::profile' do
  let(:title) { 'profile_name' }

  context 'with empty paramaters' do
    let(:params) { {} }

    it { is_expected.to compile.and_raise_error(%r{expects a value for parameter 'settings'}) }
  end

  context 'with settings struct' do
    settings = { 'setting1' => [123], 'constraints' => [{ 'name' => { 'min' => [12] } }] }
    let(:params) { { settings: settings } }

    it { is_expected.to compile }
    it do
      is_expected.to contain_clickhouse__server__config('profile-profile_name')
        .with_section('users')
        .with_data('profiles' => { 'profile_name' => settings })
    end

    it do
      is_expected.to contain_file('/etc/clickhouse-server/users.d/profile-profile_name.xml')
        .with_content(
          <<~CONTENT
            <yandex>
              <profiles>
                <profile_name>
                  <setting1>123</setting1>
                  <constraints>
                    <name>
                      <min>12</min>
                    </name>
                  </constraints>
                </profile_name>
              </profiles>
            </yandex>
            CONTENT
        )
    end
  end
end
