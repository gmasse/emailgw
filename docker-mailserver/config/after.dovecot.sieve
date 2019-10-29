# Deliver SPAM flagged email in Junk or Spam folder if they exist.
# If not, create Junk folder and deliver into. 

require ["fileinto", "mailbox"];

if header :contains "X-Spam-Flag" "YES" {
  if mailboxexists "Junk" {
    fileinto "Junk";
  } elsif mailboxexists "Spam" {
    fileinto "Spam";
  } else {
    fileinto :create "Junk";
  }
}
