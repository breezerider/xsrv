require ["mailbox", "fileinto", "imap4flags"];

if header :is "X-Spam" "Yes" {
  # Mark as read
  setflag "\\Seen";

  # Move into the Junk folder
  fileinto :create "Spam";

  # Stop processing here
  stop;
}
