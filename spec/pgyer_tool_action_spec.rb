describe Fastlane::Actions::PgyerToolAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The pgyer_tool plugin is working!")

      Fastlane::Actions::PgyerToolAction.run(nil)
    end
  end
end
