from google.oauth2.service_account import Credentials
from googleapiclient.discovery import build

# Define the scope for accessing Google Drive
SCOPES = ['https://www.googleapis.com/auth/drive.readonly']

# Load the service account key JSON file
SERVICE_ACCOUNT_FILE = 'mariobassem-1ca98b6dc5e3.json'

# Authenticate using the service account
creds = Credentials.from_service_account_file(SERVICE_ACCOUNT_FILE, scopes=SCOPES)

# Build the Google Drive API service
service = build('drive', 'v3', credentials=creds)

# List files in Google Drive
results = service.files().list().execute()
print(results)
items = results.get('files', [])

if not items:
    print('No files found.')
else:
    print('Files:')
    for item in items:
        print(f"{item['name']} ({item['id']})")
