require "application_system_test_case"

class SubmissionAdminTest < ApplicationSystemTestCase
  include ActionDispatch::TestProcess::FixtureFile

  test "sign in and view submissions" do
    Submission.create!({
      artist_name: "DRMC",
      song_title: "punk news",
      file: fixture_file_upload("wav.wav")
    })

    visit admin_url

    assert_current_path "/users/sign_in"

    fill_in "Username", with: "jos"
    fill_in "Password", with: "passw0rd!"
    click_on "Log in"

    assert_current_path "/admin"

    assert_text "Current Submissions (1)"
    assert_text %q{DRMC - "punk news"}
  end
end
