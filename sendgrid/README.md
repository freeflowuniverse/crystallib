# SendGrid Client

The SendGrid module allows you to use SendGrid services.

## About SendGrid

SendGrid is a cloud-based email delivery and communication platform that empowers businesses and developers to send transactional and marketing emails to their customers or users. It offers tools and APIs to manage email campaigns, monitor delivery, and gather analytics on recipient engagement.

## Requirements

To utilize this module, you will need:

- A SendGrid API key: Create a SendGrid account and acquire your API key [here](https://sendgrid.com/).

## Usage

To send an email using the SendGrid module, follow these steps:

### 1. Set Up a new email

In your V code, set up the email as shown below:

```v
email := sendgrid.new_email(
  ['target_email@example.com', 'target_email2@example.com'],
  'source_email@example.com',
  'Email Title', 'Email content; can include HTML')
```

### 2. Execute the program

You can execute the program using the following command:

```shell
v run sendgrid/example/main.v -t "you API token"
```

You can provide the API key using the -t command-line argument, or you can export the API key using the following command:
`export SENDGRID_AUTH_TOKEN="your api token"`

Additionally, you can enable debug mode by passing the -d flag:

```shell
v run sendgrid/example/main.v -d -t "you API token"
```

## Advanced

We provide some useful structs and methods in [email](./email) and [personalization](./personalizations.v) that you can leverage to tailor the emails according to your specific requirements.
You can check the SendGrid API reference [here](https://docs.sendgrid.com/api-reference/how-to-use-the-sendgrid-v3-api/)
