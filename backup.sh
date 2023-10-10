#! /bin/bash
# Manual stuff
# Install gcloud sdk: https://cloud.google.com/sdk/docs/install
# Install firebase tools: https://firebase.google.com/docs/cli#install_the_firebase_cli
# Login to firebase: firebase login
# Login to gcloud: gcloud auth login

# Global variables
DATE=$(date +%Y-%m-%d)
BACKUP_FOLDER=firebase-backup-$DATE
BACKUP_BUCKET=gs://backups-$GCLOUD_PROJECT_ID-firebase

# Function to export Firebase auth data
function export_auth_data() {
  firebase use $GCLOUD_PROJECT_ID
  mkdir $BACKUP_FOLDER || echo "Folder already exists"
  firebase auth:export $BACKUP_FOLDER/users.json --format=JSON
}

# Function to export Firestore data
function export_firestore_data() {
  gcloud config set project $GCLOUD_PROJECT_ID
  gsutil ls $BACKUP_BUCKET || gcloud storage buckets create $BACKUP_BUCKET
  gcloud beta firestore export --async $BACKUP_BUCKET

  # More manual stuff
  # Wait a few min then download the bucket, backup.sh save
}

function save_exported_firestore_data() {
  mkdir $BACKUP_FOLDER || echo "Folder already exists"
  gsutil -m cp -r $BACKUP_BUCKET $BACKUP_FOLDER
}

# Get user input for project ID
read -p "Enter your GCLOUD_PROJECT_ID: " GCLOUD_PROJECT_ID

# Check for arguments
if [ "$1" == "auth" ]; then
  export_auth_data
  echo "Exported auth data"
elif [ "$1" == "firestore" ]; then
  export_firestore_data
  echo "Data is being exported. Run ./backup.sh save to save the exported data in a few min."
elif [ "$1" == "save" ]; then
  save_exported_firestore_data
  echo "Saved exported data"
else
  echo "Invalid argument. Usage: ./auth.sh [auth/firestore/save]"
fi
