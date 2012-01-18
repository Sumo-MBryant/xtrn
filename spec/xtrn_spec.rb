require 'rspec'
require 'xtrn'
describe Xtrn::Directory do

  let(:config) do
    [
      { 
        'path' => 'foo',
        'type' => 'svn',
        'url' => 'svn://svnhost/path/to/project'
      }
    ]
  end

  let(:executor) {mock('executor')}

  subject { Xtrn::Directory.new(config, executor) }

  before do
    executor.should_receive(:exec).with("svn info #{config[0]['url']}") {
      <<EOF
Ignore this one: Some value
Last Changed Rev: 12345
Some other stuff: Bobby
EOF
    }
  end

  context 'when checkout path does not exist' do

    it 'should check out the given svn directory path' do
      File.should_receive(:"directory?").with(config[0]['path']).and_return(false)
      executor.should_receive(:exec).with("svn checkout -r12345 #{config[0]['url']} #{config[0]['path']}")

      subject.update!
      
    end
  end

  context 'when checkout path already exists' do

    it 'should update the given svn directory path' do
      File.should_receive(:"directory?").with(config[0]['path']).and_return(true)
      executor.should_receive(:exec).with("svn update -r12345 #{config[0]['url']} #{config[0]['path']}")

      subject.update!

    end
  end
end