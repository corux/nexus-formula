require "serverspec"

set :backend, :exec

describe service("nexus") do
  it { should be_enabled }
  it { should be_running }
end

describe command("sleep 20s") do
  # let service start
  its(:exit_status) { should eq 0 }
end

describe port("8081") do
  it { should be_listening }
end

describe command("curl -L localhost:8081") do
  its(:stdout) { should contain('Nexus') }
end
