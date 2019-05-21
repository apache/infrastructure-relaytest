require 'spec_helper'

describe 'datadog_agent::integrations::solr' do
  let(:facts) {{
    operatingsystem: 'Ubuntu',
  }}
  let(:conf_dir) { '/etc/dd-agent/conf.d' }
  let(:dd_user) { 'dd-agent' }
  let(:dd_group) { 'root' }
  let(:dd_package) { 'datadog-agent' }
  let(:dd_service) { 'datadog-agent' }
  let(:conf_file) { "#{conf_dir}/solr.yaml" }

  it { should compile.with_all_deps }
  it { should contain_file(conf_file).with(
    owner: dd_user,
    group: dd_group,
    mode: '0600',
  )}
  it { should contain_file(conf_file).that_requires("Package[#{dd_package}]") }
  it { should contain_file(conf_file).that_notifies("Service[#{dd_service}]") }

  context 'with default parameters' do
    it { should contain_file(conf_file).with_content(%r{host: localhost}) }
    it { should contain_file(conf_file).with_content(%r{port: 7199}) }
    it { should contain_file(conf_file).without_content(%r{user:}) }
    it { should contain_file(conf_file).without_content(%r{password:}) }
    it { should contain_file(conf_file).without_content(%r{java_bin_path:}) }
    it { should contain_file(conf_file).without_content(%r{trust_store_path:}) }
    it { should contain_file(conf_file).without_content(%r{trust_store_password:}) }
  end

  context 'with parameters set' do
    let(:params) {{
      hostname: 'solr1',
      port: 867,
      username: 'userfoo',
      password: 'passbar',
      java_bin_path: '/opt/java/bin',
      trust_store_path: '/var/lib/solr/trust_store',
      trust_store_password: 'hunter2',
      tags: {
        'foo' => 'bar',
        'baz' => 'bat',
      }
    }}
    it { should contain_file(conf_file).with_content(%r{host: solr1}) }
    it { should contain_file(conf_file).with_content(%r{port: 867}) }
    it { should contain_file(conf_file).with_content(%r{user: userfoo}) }
    it { should contain_file(conf_file).with_content(%r{password: passbar}) }
    it { should contain_file(conf_file).with_content(%r{java_bin_path: /opt/java/bin}) }
    it { should contain_file(conf_file).with_content(%r{trust_store_path: /var/lib/solr/trust_store}) }
    it { should contain_file(conf_file).with_content(%r{trust_store_password: hunter2}) }
    it { should contain_file(conf_file).with_content(%r{tags:\s+foo: bar\s+baz: bat}) }
  end
end
