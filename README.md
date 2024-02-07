# Ikigai Advisor

Ikigai Advisor is a simple Flutter app providing a chatbot ikigai advisor via ChatGPT.

The word ikigai means to have a purpose in life. The reasion you wake up each working day excited to do something. When you have a purpose, you won't feel lazy or unmotivated.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

What things you need to install the software and how to install them:

- Flutter SDK
- Android Studio or Visual Studio Code with Flutter and Dart plugins
- An Android or iOS device or emulator

For detailed setup instructions, refer to the official Flutter documentation: https://flutter.dev/docs/get-started/install

### Installing

A step-by-step series of examples that tell you how to get a development environment running:

1. **Clone the repository**

```bash
git clone https://github.com/yourusername/yourappname.git
```

Below is a template for a generic `README.md` file for a Flutter app. You can customize it to fit the specifics of your project:

````markdown
# Flutter App Name

Describe your Flutter app here. Provide an overview of what it does, its features, and any unique value it offers.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

What things you need to install the software and how to install them:

- Flutter SDK
- Android Studio or Visual Studio Code with Flutter and Dart plugins
- An Android or iOS device or emulator

For detailed setup instructions, refer to the official Flutter documentation: https://flutter.dev/docs/get-started/install

### Installing

A step-by-step series of examples that tell you how to get a development environment running:

1. **Clone the repository**

```bash
git clone https://github.com/yourusername/yourappname.git
```
````

2. **Navigate to the project directory**

```bash
cd yourappname
```

3. **Add OpenAI urls and api key to a .env file**

Create a .env file in your root directory. Include the following

```
OPENAI_API_KEY=<YOUR_API_KEY>
OPENAI_COMPLETIONS_URL=<OPENAI_COMPLETIONS_URL>
```

4. **Get Flutter dependencies**

```bash
flutter pub get
```

5. **Run the app**

Connect your device or start your emulator, then execute:

```bash
flutter run
```

## Running the tests

Explain how to run the automated tests for this system, if any:

```bash
flutter test
```

## Deployment

TODO

## Built With

- [Flutter](https://flutter.dev/) - The UI toolkit used
- [Dart](https://dart.dev/) - Programming language

## Contributing

Please read [CONTRIBUTING.md](TODO) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/yourusername/yourappname/tags).

## Authors TODO

- **Your Name** - _Initial work_ - [YourUsername](https://github.com/YourUsername)

See also the list of [contributors](https://github.com/yourusername/yourappname/contributors) who participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

- Dart Models from https://github.com/redevrx/chat_gpt_sdk
