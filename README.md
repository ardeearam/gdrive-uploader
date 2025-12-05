This scripts moves all of your files from a certiain directory to a Google Drive folder.

# Usage

```
bundle install
bundle exec ruby main.rb /directory/to/backup GOOGLE_DIRECTORY_ID
```


# What you need

* client_secrets.json — download this from Google Cloud Console:
* Go to Google Cloud Console
* Select your project (some-project-123456-k6)
* Go to APIs & Services > Credentials
* Click Create Credentials > OAuth client ID
* Application type: Desktop app
* Click Create
* Click the download icon next to your new OAuth client ID
* Save it as client_secrets.json in your project directory

# Add yourself as a test user:

If you don't add yourself as a test user, you will encounter the following error:

```
Access blocked: klaudsol-gdrive has not completed the Google verification process

klaudsol-gdrive has not completed the Google verification process. The app is currently being tested, and can only be accessed by developer-approved testers. If you think you should have access, contact the developer.
```

Steps to add yourself as a test user:
* Go to Google Cloud Console
* Select your project: some-project-123456-k6
* Go to APIs & Services > OAuth consent screen
* Scroll to Test users
* Click + ADD USERS
* Add your email
* Click ADD
