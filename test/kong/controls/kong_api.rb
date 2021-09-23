api = input('kong_admin_url')
proxy = input('kong_proxy_url')
token = input('kong_token')

require_relative '../../libraries/kong_util'

title 'Kong API'

wait("#{api}/clustering/status", 1, token)

post("#{api}/services", { 'name' => 'test', 'url' => 'http://httpbin.org' }, token)

post("#{api}/services/test/routes", { 'name' => 'testRoute', 'paths' => '/test' }, token)

members = JSON.parse(http("#{api}/clustering/status",
                          method: 'GET',
                          headers: { 'Kong-Admin-Token' => token },
                          ssl_verify: false).body)

control 'clustering-01' do
  impact 1
  title 'Clustering: Status check'
  describe members do
    it { should_not be_empty }
  end
end

control 'service-creation-01' do
  impact 1
  title 'Kong Services: Check if the test service is present'
  describe http("#{api}/services/test",
                method: 'GET', headers: { 'Kong-Admin-Token' => token },
                ssl_verify: false) do
    its('status') { should cmp 200 }
  end
end

control 'route-creation-01' do
  impact 1
  title 'Kong Routes: Check if the test route is present'
  describe http("#{api}/services/test/routes/testRoute",
                method: 'GET', headers: { 'Kong-Admin-Token' => token },
                ssl_verify: false) do
    its('status') { should cmp 200 }
  end
end

sleep(10) # wait for route to propergate

control 'consume-api-01' do
  impact 1
  title 'Data Plane: Check if the test service can be consumed'
  desc 'There is a test service hosted behind the data plance gateway, we should ensure we can connect to it'
  desc 'rationale', 'By consuming the test service we can confirm the data plane is functioning at a basic level'
  tag 'kong-data-plane'
  tag phase: 'establish'
  tag sub_phase: 'platform_delivery'
  tag asset_type: 'kubernetes'
  tag asset_subtype: 'EKS'
  tag product_name: 'kong_gateway'
  tag asset_names: 'control_plane_values,data_plane_values'
  tag asset_urls: 'https://github.com/Kong/cx-kdf/blob/main/deploy_kong_onto_infrastructure/EKS/Demo/control_plane_values.yaml,
  https://github.com/Kong/cx-kdf/blob/main/deploy_kong_onto_infrastructure/EKS/Demo/data_plane_values.yaml'
  describe http("#{proxy}/test/get",
                method: 'GET', headers: { 'Kong-Admin-Token' => token },
                ssl_verify: false) do
  its('status') { should cmp 200 }
  end
end

