title 'Kong Basics'

control 'k8s-1.0' do
  impact 1.0
  title 'Validate kong namespaces exist'
  desc 'The kong-cp and kong-dp namespaces should exist'

  describe k8sobject(api: 'v1', type: 'namespaces', name: 'kong-cp') do
    it { should exist }
  end
  describe k8sobject(api: 'v1', type: 'namespaces', name: 'kong-dp') do
    it { should exist }
  end
end

control 'k8s-1.1' do
  impact 1.0
  title 'Validate kube-proxy'
  desc 'The kong control plane and data plane pods should exist and be running'

  k8sobjects(api: 'v1', type: 'namespaces', labelSelector: 'app=kong').items.each do |namespace|
    k8sobjects(api: 'v1', type: 'pods', namespace: namespace.name, labelSelector: 'app=kong').items.each do |pod|
      next if pod.name =~ /migrations/

      describe "#{namespace.name}/#{pod.name} pod" do
        subject { k8sobject(api: 'v1', type: 'pods', namespace: namespace.name, name: pod.name) }
        it { should_not be_running }
      end
    end
  end
end

control 'k8s-1.2' do
  impact 1.0
  title 'Validate postgresql'
  desc 'The postgresql pods should exist and be running'

  k8sobjects(api: 'v1', type: 'namespaces', labelSelector: 'app=kong').items.each do |namespace|
    k8sobjects(api: 'v1', type: 'pods', namespace: namespace.name, labelSelector: 'app=postgresql').items.each do |pod|
      describe "#{namespace.name}/#{pod.name} pod" do
        subject { k8sobject(api: 'v1', type: 'pods', namespace: namespace.name, name: pod.name) }
        it { should be_running }
      end
    end
  end
end


