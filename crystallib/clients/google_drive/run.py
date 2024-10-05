from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from googleapiclient.http import MediaIoBaseDownload, MediaFileUpload
from typing import Tuple
import os

SERVICE_ACCOUNT_FILE = "credentials.json"
SCOPES = [
    "https://www.googleapis.com/auth/drive.readonly",
    "https://www.googleapis.com/auth/drive.file",
]

class GoogleDriveClient:
    def __init__(self) -> None:
        try:
            self.cerds, self.service = self.__init_service()
        except Exception as e:
            print(f"Unexpected error: {e}")
            return None

    def __init_service(self):
        # Load service account credentials
        creds = service_account.Credentials.from_service_account_file(
            SERVICE_ACCOUNT_FILE, scopes=SCOPES
        )

        # Build the Drive API client
        service = build("drive", "v3", credentials=creds)
        return creds, service

    def is_folder(self, mime_type: str) -> bool:
        return mime_type == 'application/vnd.google-apps.folder'

    def is_file(self, mime_type: str) -> bool:
        return not self.is_folder(mime_type)

    def __resolve_path(self, path: str) -> Tuple:
        """Recursively resolve the Google Drive path to a file or folder ID."""

        query = f"'root' in parents and trashed = false"
        response = (
                self.service.files()
                .list(
                    q=None,
                    fields="nextPageToken, files(id, name, mimeType, starred)",
                    spaces="drive",
                    includeItemsFromAllDrives=True,  # If accessing shared drives
                    supportsAllDrives=True,  # If accessing shared drives
                )
                .execute()
            )

        items = response.get('files', [])
        for item in items:
            mime_type = item['mimeType']
            _folder_name = item['name']
            _folder_id = item['id']
            starred = item['starred']

            if self.is_folder(mime_type):
                print(f"{_folder_name} - Directory: {item['name']} (ID: {item['id']}) (starred: {starred})")
            if self.is_file(mime_type):
                print(f"{_folder_name} - File: {item['name']} (ID: {item['id']}) (starred: {starred})")
        # path_parts = path.split('/')
        # print(path_parts)
        # for part in path_parts:
        #     if len(part) > 0:
                # query = f"root in parents and trashed = false and name = '{part}'"
                
        #         if not items:
        #             print(f"Error: '{part}' not found in the current directory.")
        #             return None
                
        #         # Update folder_id to the next level (either file or folder)
        #         folder_id = items[0]['id']
        
        # # Return the resolved ID and the MIME type (to determine if it's a file or folder)
        
        # folder_id
        
        # return folder_id, items[0]['mimeType']

    def upload_file_to_root(self, file_path):
        """Upload a file to the root directory of Google Drive."""
        file_metadata = {
            'name': os.path.basename(file_path),  # File name
            'parents': ['root']  # Specify the parent as the root folder
        }

        media = MediaFileUpload(file_path, resumable=True)

        # Create the file in Google Drive
        file = self.service.files().create(body=file_metadata, media_body=media, fields='id').execute()
        print(f"File ID: {file.get('id')} uploaded to root directory.")

    def list(self, path: str = "/"):
        if path == "/":
            return self.__list_root()
        return self.__resolve_path(path)

    def __list_root(self):
        results = self.service.files().list(fields="files(id, name, mimeType)").execute()
        items = results.get('files', [])
        for item in items:
            mime_type = item['mimeType']
            _folder_name = item['name']
            _folder_id = item['id']

            if self.is_folder(mime_type):
                print(f"- Directory: {_folder_name} (ID: {_folder_id})")
            if self.is_file(mime_type):
                print(f"- File: {_folder_name} (ID: {_folder_id})")

    # def __list_by_id(self, folder_id: str):
    #     print("+++++++++++++++++++")
    #     query = f"'{folder_id}' in parents and trashed = false"


    #     if not items:
    #         print("No files or directories found.")
    #         print("--------------------")
    #         return

    #     for item in items:
    #         mime_type = item['mimeType']
    #         _folder_name = item['name']
    #         _folder_id = item['id']

    #         if dir_name == 'root':
    #             pass
    #             # if self.is_folder(mime_type):
    #             #     print(f"{_folder_name} - Directory: {item['name']} (ID: {item['id']})")
    #             # if self.is_file(mime_type):
    #             #     print(f"{_folder_name} - File: {item['name']} (ID: {item['id']})")
    #         else:
    #             if self.is_folder(mime_type):
    #                 print(f"{_folder_name} - Directory: {item['name']} (ID: {item['id']})")
    #             if self.is_file(mime_type):
    #                 print(f"{_folder_name} - File: {item['name']} (ID: {item['id']})")
                
    #         if self.is_folder(mime_type):
    #             if _folder_name == dir_name:
    #                 self.list(dir_name=_folder_name, folder_id=_folder_id)
    #     print("---------------------")

    def download(self, output_dir: str, starts_with: str = "", ends_with: str = ""):
        pass
    
    
if __name__ == "__main__":
    x = GoogleDriveClient()
    x.list("/d1")
    # x.upload_file_to_root("zeko.com")
