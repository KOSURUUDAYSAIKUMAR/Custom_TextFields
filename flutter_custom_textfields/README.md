# 🧩 Flutter Custom TextFields

[![Pub Version](https://img.shields.io/pub/v/flutter_custom_textfields)](https://pub.dev/packages/flutter_custom_textfields)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

A Flutter package that provides customizable text fields with built-in validation for common input types. Features include email, phone number, username, full name, OTP, password, and confirm password fields, Camera Location, Date picker with configurable validation and UI options.

## ✨ Features

### 📝 TextFields with Leading Icons

- 📧 Email  
- 📱 Phone Number  
- 👤 Username  
- 🧑 Full Name  
- 🔢 OTP (4-digit)  
- 📍 Pin Code

### 🔒 Secure Input Fields

- Password – with leading and trailing icons  
- Confirm Password – with match validation

### 🔢 OTP Input

- Supports customizable lengths (4-digit and 6-digit)  
- Smooth user experience with auto-focus and segmented input

### ✅ Built-in Validation

- Regex-based input validation for:
  - Email  
  - Phone number  
  - Username  
  - Full name  
  - OTP format  
  - Pin code  
  - Password strength  
  - Password confirmation

### 📷 Camera + Location Picker

- Capture and attach current location via device camera  
- Suitable for address, delivery, and geo-tagged input use cases

### 📅 Date Picker

- ✅ **Single Date Selection** - Pick a single date
- ✅ **Multiple Date Selection** - Select multiple dates
- ✅ **Date Range Selection** - Choose a date range
- ✅ **Date Restrictions** - Past only, Future only, Current only, etc, PastCurrent, Futurecurrent.
- ✅ **Calendar Below Text Field** - Show/hide calendar inline
- ✅ **Beautiful UI Design** - Modern and user-friendly interface
- ✅ **Customizable Styling** - Colors, fonts, borders, and more
- ✅ **Form Validation** - Built-in validation support
- ✅ **Blackout Dates** - Disable specific dates
- ✅ **Special Dates** - Highlight important dates
- ✅ **Accessibility** - Full accessibility support
- ✅ **Responsive Design** - Works on all screen sizes


### 🧩 Easy Integration
- Highly customizable:
  - Icons  
  - Border styles  
  - Error messages  
  - Hint text  
  - Input formatting


## 🛠️ How to Use

You can easily use pre-built custom text fields for various input types like:

- Email  
- Username  
- Full Name  
- OTP  
- Phone Number  
- Password  
- Confirm Password  
- Pin Code  
- Camera Location  
- Date Picker Selection

To see how these fields are implemented and how they can be reused in real-time applications, explore the `example` folder — especially the following classes:

- `FormExample` – For text fields, text area, and camera location  
- `DatePickerDemoPage` – For date picker selection  
- `CustomPinCodeWidget` – For PIN code input with API validation  
- `AdvancedOTPDemoScreen` – For OTP input handling  
- `UsernameText` – For using the username input field as a separate widget

These examples demonstrate practical usage and integration in complete form setups.

## 🚀 Getting Started or Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_custom_textfields: ^ 0.0.6
```

Then run:

```bash
flutter pub get
```

## Usage

### Single Date Selection

```dart
import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';

SmartDatePickerField(
  config: DatePickerConfig(
    selectionMode: DateSelectionMode.single,
    labelText: null,
    hintText: 'Choose a date',
    onChanged: (value) {
      print('Selected: $value');
    },
  ),
)
```

### Multiple Date Selection

```dart
import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';

SmartDatePickerField(
  config: DatePickerConfig(
    selectionMode: DateSelectionMode.multiple,
    labelText: null,
    hintText: 'Choose multiple dates',
    primaryColor: Colors.green,
    onChanged: (List<DateTime>? dates) {
      print('Selected dates: $dates');
    },
  ),
)
```

### Date Range Selection

```dart
import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';

SmartDatePickerField(
  config: DatePickerConfig(
    selectionMode: DateSelectionMode.range,
    labelText: null,
    hintText: 'Choose date range',
    primaryColor: Colors.purple,
    onChanged: (List<DateTime>? range) {
      if (range != null && range.length == 2) {
        print('Start: ${range[0]}, End: ${range[1]}');
      }
    },
  ),
)
```

### Date Restrictions

```dart
import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';

// Past dates only

SmartDatePickerField(
  config: DatePickerConfig(
    selectionMode: DateSelectionMode.single,
    dateRestriction: DateRestriction.pastOnly,
    labelText: 'Past Dates Only',
  ),
)

// Future dates only
SmartDatePickerField(
  config: DatePickerConfig(
    selectionMode: DateSelectionMode.single,
    dateRestriction: DateRestriction.futureOnly,
    labelText: 'Future Dates Only',
  ),
)
```

### Calendar Below Text Field

```dart
import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';

SmartDatePickerField(
  config: DatePickerConfig(
    selectionMode: DateSelectionMode.single,
    showCalendarBelow: true,
    isCalendarHidden: true, // Initially hidden
    labelText: 'Date with Calendar Below',
  ),
)
```

### Custom Styling

```dart
import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';

SmartDatePickerField(
  config: DatePickerConfig(
    selectionMode: DateSelectionMode.single,
    labelText: 'Custom Styled Date Picker',
    primaryColor: Colors.deepPurple,
    backgroundColor: Colors.deepPurple.withOpacity(0.05),
  ),
)
```

### Email Text Field
``` dart
import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';

    EmailTextField(
      hint: "Enter your email",
      controller: _emailController,
      focusNode: _emailNode,
      iconColor: Colors.grey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      invalidEmailMessage: 'Please enter a valid email address',
      requiredEmailMessage: 'Email is required',
    ),
```

### Full Name Text Field
``` dart
import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';

    FullNameTextField(
       focusNode: _fullnameNode,
       controller: _fullnameController,
       iconColor: Theme.of(context).primaryColor,
       autovalidateMode: AutovalidateMode.onUserInteraction,
       invalidNameMessage: 'Please enter a valid name',
       requiredNameMessage: 'Full name is required',
      hint: 'Enter your full name',
    ),
```

### Phone Number Text Field
``` dart
import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';

    FlexiblePhoneField(
      leadingIcon: Icon(
            Icons.phone_android_rounded,
             color: Colors.grey,
          ),
      controller: TextEditingController(),
      focusNode: FocusNode(),
      style: PhoneFieldStyle.withIcons, // Change Styles 
    ),
```

### User Name Text Field
``` dart
import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';

    UsernameTextfield(
       hint: "Enter your username",
       validationPattern: RegExp('^[a-zA-Z0-9@_#]{3,10}\$'),
       inputFormatterPattern: RegExp('^[a-zA-Z0-9@_#]'),
       controller: widget.usernameController,
       focusNode: widget.usernameNode,
       autovalidateMode: AutovalidateMode.onUserInteraction,
       invalidUsernameMessage:
          'Username must be 3-10 characters and can only contain letters, numbers, and @, _, or #',
       preventLeadingTrailingSpaces: false,
       preventConsecutiveSpaces: false,
       useInputFormatter: true,
    );
```

### Password and Confirm Password Text Field
``` dart
import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';

// Password Text Field

    PasswordTextfield(
        controller: _passwordController,
        focusNode: _passwordNode,
        hint: "Enter password",
        validationPattern: RegExp(r'^[a-zA-Z0-9@$!%*?&]{8,20}$'),
        minPasswordLength: 8,
        maxPasswordLength: 20,
    ),

// Confirm Password Text Field

    PasswordTextfield(
        controller: _confirmPasswordController,
        focusNode: _confirmPasswordNode,
        hint: "Enter confirm password",
        compareWithController: _passwordController,
        passwordMismatchMessage:
                    'Confirm password does not match with the password.',
        validationPattern: RegExp(r'^[a-zA-Z0-9@$!%*?&]{8,20}$'),
        minPasswordLength: 8,
        maxPasswordLength: 20,
    ),
```

### Description, Notes, Summary (which belongs to Text Area)
``` dart
    import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';

    TextArea(
       hint: 'Enter a detailed description...',
       maxLength: 200,
       textInputAction: TextInputAction.next,
     ),
```           

### Camera Location Picker
``` dart
    import 'package:flutter_custom_textfields/flutter_custom_textfields.dart';

    CameraLocationPicker(
        enableLocation: true,
        enableCamera: true,
        enableWatermark: true,
        cameraMode: CameraMode.front,
        callback: (image, lat, lng, address) {
            print("Received data:");
            print("Image: ${image?.path}");
            print("Lat: $lat");
            print("Lng: $lng");
            print("Address: $address");
        },
     ),
```            

## 📸 Screenshots

Here’s a preview of how the custom input fields and UI components look in a sample form:

![Example of Flutter Custom TextFields in action](https://raw.githubusercontent.com/KOSURUUDAYSAIKUMAR/Custom_TextFields/refs/heads/main/flutter_custom_textfields/assets/appflow/IMG_1.PNG "Custom TextFields Demo")
![Example of Flutter Custom TextFields in action](https://raw.githubusercontent.com/KOSURUUDAYSAIKUMAR/Custom_TextFields/refs/heads/main/flutter_custom_textfields/assets/appflow/IMG_2.PNG "OTP, Password and Description.") 
![Example of Flutter Custom TextFields in action](https://raw.githubusercontent.com/KOSURUUDAYSAIKUMAR/Custom_TextFields/refs/heads/main/flutter_custom_textfields/assets/appflow/IMG_3.PNG "Camera location picker and Date picker selection")
![Example of Flutter Custom TextFields in action](https://raw.githubusercontent.com/KOSURUUDAYSAIKUMAR/Custom_TextFields/refs/heads/main/flutter_custom_textfields/assets/appflow/IMG_4.PNG "List of Date Pickers available.")