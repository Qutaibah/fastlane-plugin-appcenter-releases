describe Fastlane::Actions::AppcenterReleasesAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The appcenter_releases plugin is working!")

      Fastlane::Actions::AppcenterReleasesAction.run(nil)
    end
  end
end
