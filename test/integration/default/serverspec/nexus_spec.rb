require "serverspec"

set :backend, :exec

describe service("nexus") do
  it { should be_enabled }
  it { should be_running }
end

describe port("8081") do
  it { should be_listening }
end

describe command("curl -L localhost:8081") do
  its(:stdout) { should contain('Nexus') }
end
