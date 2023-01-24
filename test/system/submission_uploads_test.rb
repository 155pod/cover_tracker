require "application_system_test_case"

class SubmissionUploadsTest < ApplicationSystemTestCase
  test "visiting the index" do
    assert_empty Submission.all

    visit "/"

    assert_selector "h1", text: "Submit"
    fill_in "Title", with: "I hear you calling"
    fill_in "Pronouns", with: "he/him"
    fill_in "Artist name", with: "John Problems"
    fill_in "Start Time", with: "1:55"
    fill_in "Message", with: "what's up naysh"

    attach_file "WAV File", file_fixture("wav.wav")

    click_on "Send it to the Pod"

    assert_text %q{Successfully submitted John Problems – "I hear you calling".}
    assert_text %q{We got it. Thanks for submitting!}

    submission = Submission.last
    assert_equal "John Problems", submission.artist_name
    assert_equal "he/him", submission.pronouns
    assert_equal "I hear you calling", submission.song_title
    assert_equal "what's up naysh", submission.blurb
    assert_equal 115, submission.start_time_seconds
    assert_nil submission.discarded_at
    assert_predicate submission.file, :attached?
  end
end
