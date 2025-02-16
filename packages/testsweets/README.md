# Testsweets [![Pub Version](https://img.shields.io/pub/v/testsweets)](https://pub.dev/packages/testsweets)

This package is a utility and helper package to the TestSweets product. It is the package responsible for capturing your widget keys to the database which allows us to provide the auto complete functionality when you script your test cases.

## Installation

To start using the package you have to add this package to your `pubspec.yaml` file.

```yaml
dependencies:
  ...
  # Flutter driver is required as well
  flutter_driver:
    sdk: flutter
  testsweets: [latest_version]

```

and optionally if you want to add general keys to check for when a certain widget is visible like a dialog or a button
you have to add the testsweets_generator package too

```
dev_dependencies:
  testsweets_generator: [latest_version]
  build_runner: [latest_version]
```

## Setup

After the packages have been added we have to setup the code. TestSweets makes use of Flutter Driver to drive the test cases that we write. This means we have to enable flutter driver for the version of the app that we build that goes through automation. Flutter driver disables certain things like the on screen keyboard 

```dart
...
// 1. Import flutter driver extension to enable flutter driver
import 'package:flutter_driver/driver_extension.dart';

// 2. Get the FLUTTER_DRIVER from the command line environment  
  const FLUTTER_DRIVER = bool.fromEnvironment(
    'FLUTTER_DRIVER',
    defaultValue: false,
  );  
  
void main() {

  // 3. Enables flutter driver if the FLUTTER_DRIVER enviroment is True
  if (FLUTTER_DRIVER) {
    enableFlutterDriverExtension();
  }
  // 4. Load the testsweets dependency
  await setupTestSweets();
  ...
  runApp(MyApp());
}
```

in your MaterialApp

```dart
...
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
   // 5. Inside MaterialApp add TestSweetsOverlayView to the builder
   //    with the projectId you get when you created a new project in Testsweets app
      builder: (context, child) => TestSweetsOverlayView(
        projectId: '3OezzTovG9xxxxxxxxx',
        child: child!,
        captureWidgets: true,
      ),
    // 6. Finally add TestSweetsNavigatorObserver() to determine what view you are on right now
      navigatorObservers: [
        TestSweetsNavigatorObserver(),
      ],
    );
  }
}
```

#### Using the capture functionality 


<table>
  <tr align="center">
    <td>Intro screen</td>
     <td>Entered capture mode</td>
     <td>Types of widgets you can capture</td>
  </tr>
  <tr>
    <td> <img src="https://user-images.githubusercontent.com/89080323/133254053-bbcffc0b-b274-494e-a2a7-9271e05870ea.png"/></td>
    <td><img src="https://user-images.githubusercontent.com/89080323/133254068-01564574-3676-4834-915d-aba58c4d5f74.png" /></td>
    <td><img src="https://user-images.githubusercontent.com/89080323/133254040-8efcbc86-2050-438d-851b-c49a3b85f002.png"/></td>
  </tr> 
    <tr>
    <td>Choose a name for the widget</td>
     <td>Exit capture mode and go to inspect mode to see your keys</td>
  </tr>
  <tr>
    <td><img src="https://user-images.githubusercontent.com/89080323/133254072-9a3e5567-3151-4411-b578-ac6744af7ec5.png" /></td>
    <td><img src="https://user-images.githubusercontent.com/89080323/133254062-9cde8983-4a92-41d3-ab9c-a656753beef7.png"/></td>
  </tr>
 </table>

## Connecting your Project to TestSweets

To make things more convenient, the process of uploading a build also uploads your automation keys (more on that below). Therefore, before you start writing test cases for the first time you may want to upload a build so that your automation keys are available for autocomplete. To build and upload your application navigate to the folder containing your `pubspec.yaml` and create a new file called `.testsweets`.

In this file we will provide a key value pair for the following keys:

- `projectId`: Found in the project settings of your TestSweets project
- `apiKey`: Found in the project settings of your TestSweets project
- `flutterBuildCommand`: the command to pass to the `flutter build` command. Whatever you need to pass to flutter build is what you put there, and finally you should enable the flutter driver by setting the `--dart-define=FLUTTER_DRIVER=true` at the end of the flutterBuildCommand. See example below

```bat
projectId=3OezzTovG9xxxxxxxxx
apiKey=e3747a0e-xxxx-xxxx-xxxx-xxxxxxxxxxxx
flutterBuildCommand=--debug --dart-define=FLUTTER_DRIVER=true
```

Then excecute the following in the terminal:

```bat
flutter pub run testsweets buildAndUpload apk
```

This will print an output similar to the following:

```text
Running Gradle task 'assembleProfile'...                          180,4s
√ Built build\app\outputs\flutter-apk\app-profile.apk (28.1MB).
Uploading automation keys ...
Successfully uploaded automation keys!
Uploading build ...
Successfully Uploaded the build ...
Done!
```

You can also specify ipa for an ios build instead of apk. For a debug build specify `debug` instead of `profile`. Replace {projectId} and {apiKey} with the project id and api key for your project. These can be found in the settings for your Test Sweets project.

In some cases you may want to build the application yourself and just tell the testsweets package to upload it. This
can be achieved by using the `uploadApp` command instead of `buildAndUpload`. You will need to pass the path to the
build you want to upload with the `--path` or `-p` positional argument after the {apiKey}. For example:

```bat
flutter pub run testsweets uploadApp apk "path/to/build.apk"
```


If you want to upload just keys without the build you can use the `uploadKeys` command 

```bat
flutter pub run testsweets uploadKeys
```

### Multi package Key collection

If your project is split into multiple packages then most likely you'll look in the project you created and see that it only added keys from the current project into the `app_automation_keys.json` file. Fear not, there is a way to do multi package scraping. In your projects root folder add a new file called `build.yaml`. In that file you will pass in `additional_paths` to the `automation_key_generator` and give it a list of additional pats to go look in and find keys. This is how that looks.

```yaml
targets:
  $default:
    builders:
      testsweets_generator|automation_key_generator:
        options:
          # Replace the strings in he list below with additional paths to other packages you wan
          # to scrape
          additional_paths: ["../shared/example_ui"]
```

In the example above the generator will look at the current project's dart files and also in the shared folder inside the `example_ui` project and add those keys to the `app_automation_keys.json` file as well.

## Creating your Keys to Sync

Next up we'll add the automation keys that will be used during the scripting. These are normal Flutter `Key` objects where the `String` value is formatted in a certain way. Go to your first view that will be shown in the app and we'll add a few keys to walk you through the process. Before we add the keys I want to share with you the format that we use to identify keys in your code base. There are 6 different widget types at this point.

- **touchable**: This is any widget that the user can tap to interact with the application
- **scrollable**: This is any widget that the user can scroll in the application
- **text**: This is a plain text widget that the TestSweets application can read. Used to confirm certain text on screen
- **general**: This is any widget that will have to be checked for visibility or anything like that
- **view**: This should ONLY be used for widgets that take up an entire navigation entry
- **input**: This is an input field that takes user input from the keyboard

We have a specific format for each widget key that is as follows, [viewName]\_[widgetType]\_[widgetName]. For view keys the [viewName]\_[view] shortened form can be used. Lets go over those parts 1 by 1:

- **viewName**: Is the name of the view without the word view in it. So if you're on the `LoginView` you'll write this as `login`.
- **widgetType**: This is one of the 6 types of widgets as defined above.
- **widgetName**: The name as you would identify it in a readable and understandable manner.

An example of this would be for an input field on the login view. The email field Key would be `login_input_email` and the password field would be `login_input_password`. The login button will have the key `login_touchable_login`. If any of the parts of the key has multiple words we'll use camel casing for the naming, something like `specialBoarding_touchable_forgotPassword`. With that said lets assume your first view that'll be shown is the `LoginView`. We can create some keys on the view and generate the automation keys. Open up your login view file and add a key to your scaffold.

```dart
Scaffold(
  key: Key('login_view'),
  ...
);
```

Then you can go ahead and add the keys to your `TextFields`.

```dart
 InputField(
  inputFieldKey: Key('login_input_email'),
  controller: email,
  placeholder: 'Enter your Email',
),
verticalSpaceSmall,
InputField(
  inputFieldKey: Key('login_input_password'),
  controller: password,
  placeholder: 'Enter your Password',
),
```

And you can also add a key to the button the user would tap to login.

```dart
 AppButton(
  buttonKey: Key('login_touchable_signup'),
  title: 'Signup',
  busy: model.isBusy,
  onPressed: () => model.signup(
    userName: email.text,
    password: password.text,
  ),
),
```

Now that that's in the code we can generate the automation keys. Run the following flutter command.

```
flutter pub run build_runner build
```

This will generate a new file next to the _pubspec.yaml_ file in your project called `app_automation_keys.json`. If you open that file you'll see the following.

```dart
[
  "login_view",
  "login_input_email",
  "login_input_password",
  "login_touchable_signup"
]
```

Once that is in your code base you should be able to run the testsweets command to upload the automation keys. See the following section.

## Indexed keys

In some cases you will need to generate widget keys dynamically during runtime. An example of such a situation is when you have to populate a list from a data source. To make sure each list item has a unique Key you might add the index of the item to the key. For example:

```dart
final List<String> restaurantNames = getRestaurantNames();

ListView.builder(
  padding: const EdgeInsets.all(8),
  itemCount: restaurantNames.length,
  itemBuilder: (BuildContext context, int index) {
    return Container(
      key: Key('browse_general_restaurantName$index');
      height: 50,
      color: Colors.blue,
      child: Center(child: Text('Restaurant "${restaurantNames[index]}"')),
    );
  }
);
```

Here the list will have items with the dynamically generated keys `browse_general_restaurantName0`, `browse_general_restaurantName1`, `browse_general_restaurantName2`, and so on. These keys will not be included in the generated `app_automation_keys.json` file and will, therefore, not be uploaded for autocomplete.

To have dynamic keys available for autocomplete in Test Sweets, we need to tell the `testsweets` package to generate fake keys and make those fake keys available for autocomplete. To do this, add a file named `dynamic_keys.json` to the root folder of your project:

```json
[
  {
    "key": "browse_general_restaurantName{index}",
    "itemCount": 50
  },
  {
    "key": "orders_touchable_pending{index}"
  }
]
```

When uploading a build, the package will read in this file and, for the first key, generate 50 automation keys where each automation key has "{index}" replaced with a unique value in the range [0, 49]. The same thing will be done for the second key but a default itemCount of 10 will be used. Once these keys are generated, the package will upload them with the rest of your automation keys.

When viewing your automation keys in the Test Sweets app, these fake automation keys will also be listed and you should see them marked as "indexed".

## Downloading your builds from Test Sweets

Once your build has finished uploading you can open your project in Test Sweets. Click the `Select APK To Test` button and your newly uploaded build will appear in the list. Selecting it will download the build. The build is only downloaded once. The downloaded build will be used the next time you select it. Once the build has been downloaded you can then run your test cases.

## Using TestSweets builder

1. Use `TestSweets.builder()` function at the root level of your app to inspect all the supported widgets.
2. You can also use the `enabled` property to disable/enable the inspector.
