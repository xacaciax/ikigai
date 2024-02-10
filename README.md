# Ikigai Advisor

Ikigai Advisor is an iOS Flutter application using the ChatGPT api to help high school students understand themselves better and explore career options.

## Features

- Interactive surveys to understand user's interests and passions
- Personalized advice based on user's responses
- Simple chat dialogue user interface

## Installation

To install the application, follow these steps:

1. Clone the repository: `git clone https://github.com/yourusername/ikigai-advisor.git`
2. Navigate into the project directory: `cd ikigai-advisor`
3. Install the dependencies: `flutter pub get`
4. Run the application: `flutter run`

## Configure

This repo uses [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) to store environment variables. For the app to successfully connect to OpenAI, you will need create a .env file in the root directory and add your ChatGPT API key.

ikigai-advisor/.env

```

OPENAI_API_KEY=<YOUR_API_KEY_HERE>
OPENAI_COMPLETIONS_URL=https://api.openai.com/v1/chat/completions

```

## Attributions

Models from https://github.com/redevrx/chat_gpt_sdk/tree/main/lib/src/model/chat_complete

## License

This project is licensed under the terms of the [MIT License](LICENSE).
