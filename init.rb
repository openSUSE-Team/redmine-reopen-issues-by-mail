require 'redmine'

Redmine::Plugin.register :reopen_issues_by_mail do
  name 'Reopen issues by mail plugin'
  author 'Ancor Gonzalez Sosa'
  description "Very simple (and a little bit hacky) plugin which adjusts the state of a closed issue after receiving an update by email"
  version '0.1.0'
end

prepare_block = Proc.new do
  MailHandler.send(:include, ReopenIssuesByMail::MailHandlerPatch)
end

if Rails.env.development?
  ActionDispatch::Reloader.to_prepare { prepare_block.call }
else
  prepare_block.call
end
