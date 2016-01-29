require "serverspec"

set :backend, :exec

describe service("nexus") do
  it { should be_enabled }
  it { should be_running }
end

describe host("localhost") do
  it { should be_reachable.with( :port => 8081, :timeout => 10 ) }
end

describe command("curl -L localhost:8081") do
  its(:stdout) { should contain('Nexus') }
end
