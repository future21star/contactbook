class InvoiceMailer < ApplicationMailer

  def send_pr(sender_email, prs)
	  #debugger
	  @sender_email = sender_email
	  attachments['PRs.xlsx'] = File.read(Rails.root.join('public/prs.xlsx'))
	  #mail(to: 'invoice@bswsuperstores.com', subject: 'Purchase Receipts')
	  mail(to: 'owensmith198752@yahoo.com', subject: 'Purchase Receipts')
	end

end

