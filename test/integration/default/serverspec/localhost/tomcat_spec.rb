require 'serverspec'

describe 'Tomcat Daemon' do
  it 'is listening on port 8080' do
    expect(port(8080)).to be_listening
  end
  it 'has a running service of tomcat' do
    expect(service('tomcat7')).to be_running
  end
end

describe group('tomcat') do
  it { should exist }
end

describe user('tomcat') do
  it { should exist }
  it { should belong_to_group 'tomcat' }
end

describe file('/home/myapp/apps') do
  it { should be_directory }
end

describe file('/home/myapp/apps/tomcat/bin/catalina.sh') do
  it { should be_owned_by 'tomcat' }
  it { should be_executable.by_user('myapp') }
  it { should be_writable.by_user('myapp') }
  it { should be_readable.by_user('myapp') }
end

describe file('/home/myapp/apps/tomcat/conf/server.xml') do
  it { should be_owned_by 'myapp' }
  it { should be_writable.by_user('myapp') }
  it { should be_readable.by_user('myapp') }
end
