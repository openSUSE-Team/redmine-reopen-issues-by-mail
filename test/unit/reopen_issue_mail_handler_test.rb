# encoding: utf-8

require File.expand_path('../../test_helper', __FILE__)

class ReopenIssueMailHandlerTest < ActiveSupport::TestCase
  fixtures :users, :projects, :enabled_modules, :roles,
           :members, :member_roles, :users,
           :issues, :issue_statuses

  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures/mail_handler'

  def setup
    ActionMailer::Base.deliveries.clear
    Setting.notified_events = Redmine::Notifiable.all.collect(&:name)
  end

  def teardown
    Setting.clear_cache
  end

  def test_update_issue
    assert_equal true, Issue.find(8).closed?
    journal = submit_email('ticket_reply.eml')
    assert journal.is_a?(Journal)
    assert_equal User.find_by_login('jsmith'), journal.user
    assert_equal Issue.find(8), journal.journalized
    assert_match /a reopening reply/, journal.notes
    assert_equal false, Issue.find(8).closed?
    assert_equal 1, journal.details.size
    assert_equal "status_id", journal.details.first.prop_key
    assert_equal "1", journal.details.first.value
  end

  private

  def submit_email(filename, options={})
    raw = IO.read(File.join(FIXTURES_PATH, filename))
    yield raw if block_given?
    MailHandler.receive(raw, options)
  end

end
