module ReopenIssuesByMail
  module MailHandlerPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :receive_issue_reply, :reopen_issues_by_mail
      end
    end

    module InstanceMethods
      # Adds a note to an existing issue
      def receive_issue_reply_with_reopen_issues_by_mail(issue_id, from_journal=nil)
        journal = receive_issue_reply_without_reopen_issues_by_mail(issue_id, from_journal)
        issue = Issue.find_by_id(issue_id)
        return unless issue
        if issue.closed?
          status_id = IssueStatus.default.id
          JournalDetail.create(:journal => journal, :property => "attr",
                               :prop_key => "status_id", :value => status_id,
                               :old_value => issue.status_id)
          Issue.where(:id => issue.id).update_all({:status_id => status_id})
          logger.info "MailHandler: reopening issue ##{issue.id}" if logger
        end
        journal.reload
      end
    end
  end
end
