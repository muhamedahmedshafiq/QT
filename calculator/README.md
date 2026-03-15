# 🧮 QML Calculator

A sleek, dark-themed calculator built with **Qt Quick (QML)** — designed for desktop applications using the Qt framework. It features a clean expression-based input system, colorful operator buttons, and a JavaScript-powered evaluation engine.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [File Breakdown](#file-breakdown)
- [UI Architecture](#ui-architecture)
  - [Window Root](#window-root)
  - [Display Area](#display-area)
  - [Button Area & Grid](#button-area--grid)
- [Calculator Logic (JavaScript)](#calculator-logic-javascript)
  - [State Properties](#state-properties)
  - [handleInput() Function — Full Walkthrough](#handleinput-function--full-walkthrough)
  - [Expression Evaluation via eval()](#expression-evaluation-via-eval)
  - [Symbol Substitution](#symbol-substitution)
- [Button Reference Table](#button-reference-table)
- [Color Palette & Design System](#color-palette--design-system)
- [Component Deep Dive: Every Rectangle Button](#component-deep-dive-every-rectangle-button)
- [Layout & Sizing Logic](#layout--sizing-logic)
- [Known Behaviors & Edge Cases](#known-behaviors--edge-cases)
- [Requirements](#requirements)
- [How to Run](#how-to-run)
- [Possible Improvements](#possible-improvements)

---

## Overview

This is a single-file QML application (`Main.qml`) that implements a basic 4-operation calculator. It uses:

- **QtQuick** for declarative UI elements
- **QtQuick.Window** for the application window
- **Inline JavaScript** for all calculator logic
- **Grid layout** for the button matrix
- **MouseArea** components for click detection

The calculator supports addition (`+`), subtraction (`-`), multiplication (`×`), and division (`÷`), along with a clear (`C`) button and equals (`=`) evaluation. It evaluates entire expressions at once (not one operation at a time), making it expression-based rather than step-by-step.

---

## Project Structure

```
project/
└── Main.qml        ← The entire application (single file)
```

This is a self-contained single-file QML app. No external assets, no C++ backend, no `.pro` file configuration shown. It is intended to be opened directly with `qml` tool or as part of a Qt Quick project.

---

## File Breakdown

| Section | Lines (approx.) | Purpose |
|---|---|---|
| Imports | 1–2 | Load Qt modules |
| Window root + properties | 4–12 | App window config & state |
| `handleInput()` function | 14–30 | All calculator logic |
| Display Rectangle | 32–55 | Shows the current expression |
| Button Area Rectangle | 57–65 | Container for the grid |
| Grid + 16 Buttons | 67–220 | All calculator buttons |

---

## UI Architecture

### Window Root

```qml
Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("calculator")
    color: "#1a1a1a"
    ...
}
```

| Property | Value | Description |
|---|---|---|
| `width` | 640 | Window width in pixels |
| `height` | 480 | Window height in pixels |
| `visible` | true | Shows the window on launch |
| `title` | `"calculator"` | Title bar text (translated via `qsTr`) |
| `color` | `#1a1a1a` | Very dark charcoal background — near-black |

The `Window` is the root element. Everything else is a child of this element. Two custom properties (`expression` and `isCalculated`) are defined here, making them globally accessible to all child elements and functions within the file.

---

### Display Area

```qml
Rectangle {
    id: displayID
    width: parent.width * .97
    height: parent.height * .25
    anchors.top: parent.top
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.margins: 10
    radius: 20
    color: "black"
    border.color: "#333333"
    border.width: 2
    ...
}
```

| Property | Value | Notes |
|---|---|---|
| `id` | `displayID` | Can be referenced elsewhere in the file |
| `width` | 97% of parent | Nearly full window width with a small gap |
| `height` | 25% of parent | Top quarter of the screen |
| `radius` | 20 | Rounded corners |
| `color` | `"black"` | Pure black background for contrast |
| `border.color` | `#333333` | Subtle dark grey border |
| `border.width` | 2 | Thin, clean border |
| `anchors.margins` | 10 | 10px gap from window top |

The display text inside:

```qml
Text {
    id: displayText
    text: expression === "" ? "0" : expression
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    anchors.margins: 20
    color: "white"
    font.pixelSize: 60
    font.weight: Font.Light
}
```

| Property | Value | Notes |
|---|---|---|
| `text` | ternary expression | Shows `"0"` when nothing is typed, otherwise shows the live expression string |
| `anchors.right` + `anchors.bottom` | parent | Right-bottom aligned — mimics real calculator displays |
| `font.pixelSize` | 60 | Large readable font |
| `font.weight` | `Font.Light` | Thin weight, like iOS calculator |

**Key behavior:** The display is right-and-bottom aligned so that as digits are typed, they appear to "grow" from the right, just like a real calculator. The fallback to `"0"` prevents an empty display.

---

### Button Area & Grid

```qml
Rectangle {
    id: buttonArea
    width: parent.width * .9
    height: parent.height * .6
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 20
    anchors.horizontalCenter: parent.horizontalCenter
    color: "#1a1a1a"
    ...
}
```

The `buttonArea` rectangle takes up the bottom 60% of the window, centered horizontally, with a 20px bottom margin. It is the same color as the window background (`#1a1a1a`) — invisible, acting purely as a layout container.

Inside it is a `Grid`:

```qml
Grid {
    anchors.fill: parent
    columns: 4
    spacing: 10
    ...
}
```

| Property | Value | Notes |
|---|---|---|
| `anchors.fill` | `parent` | Fills the entire `buttonArea` |
| `columns` | 4 | 4 columns → 4×4 = 16 button slots |
| `spacing` | 10 | 10px gap between all buttons |

Each button is sized relative to the grid:
- `width`: `parent.width / 4 - 10` (grid width divided by 4, minus spacing)
- `height`: `parent.height / 4 - 10` (grid height divided by 4, minus spacing)

---

## Calculator Logic (JavaScript)

All logic is handled in a single JavaScript function inside the `Window` root.

### State Properties

```qml
property string expression: ""
property bool isCalculated: false
```

| Property | Type | Default | Purpose |
|---|---|---|---|
| `expression` | `string` | `""` | Stores the full expression string shown on display and evaluated on `=` |
| `isCalculated` | `bool` | `false` | Flag set to `true` after `=` is pressed, so that the next digit input starts a fresh expression instead of appending |

These are QML **property bindings** — any UI element that references them will automatically update when they change.

---

### handleInput() Function — Full Walkthrough

```javascript
function handleInput(buttonValue) {
    if (buttonValue === "C") {
        expression = "";
    } else if (buttonValue === "=") {
        try {
            let formattedExpr = expression.replace(/×/g, "*").replace(/÷/g, "/");
            expression = eval(formattedExpr).toString();
            isCalculated = true;
        } catch (e) {
            expression = "Error";
        }
    } else {
        if (isCalculated) {
            expression = buttonValue;
            isCalculated = false;
        } else {
            expression += buttonValue;
        }
    }
}
```

The function accepts a single string argument `buttonValue` — the label of the pressed button — and handles three distinct cases:

#### Case 1: Clear (`"C"`)
```javascript
expression = "";
```
Resets the expression to an empty string. The display will fall back to showing `"0"` due to the ternary in the `Text` element.  
Note: `isCalculated` is **not** reset here — this is a minor bug (see [Known Behaviors](#known-behaviors--edge-cases)).

#### Case 2: Equals (`"="`)
```javascript
try {
    let formattedExpr = expression.replace(/×/g, "*").replace(/÷/g, "/");
    expression = eval(formattedExpr).toString();
    isCalculated = true;
} catch (e) {
    expression = "Error";
}
```
1. Creates a local variable `formattedExpr` by replacing display symbols with JS-compatible operators.
2. Passes it to `eval()` for evaluation.
3. Converts the numeric result to a string and stores it back in `expression`.
4. Sets `isCalculated = true` so the next button press starts fresh.
5. On any error (e.g., `5/0` gives `Infinity`, invalid expressions throw), sets `expression = "Error"`.

#### Case 3: Any other input (digits and operators)
```javascript
if (isCalculated) {
    expression = buttonValue;
    isCalculated = false;
} else {
    expression += buttonValue;
}
```
- If the last action was a `=`, replace the expression entirely (start fresh).
- Otherwise, append the new character to the end of the expression string.

---

### Expression Evaluation via eval()

The calculator uses JavaScript's built-in `eval()` to compute expressions. This means:

- It supports standard operator precedence (e.g., `2+3×4` = `2+3*4` = `14`, not `20`)
- Multi-digit numbers work naturally (e.g., `123+456`)
- Chained operations work (e.g., `1+2+3+4`)
- Floating point is handled (e.g., `1/3` = `0.3333333333333333`)
- Division by zero returns `Infinity` (not "Error") — `eval("5/0")` = `Infinity`

**Security note:** Using `eval()` in a QML application is generally safe for a local calculator app, since all input comes from controlled button presses and no user-typed strings are passed to it. In a web context this would be dangerous.

---

### Symbol Substitution

QML displays `×` (U+00D7, Multiplication Sign) and `÷` (U+00F7, Division Sign) for readability. Before evaluation, these are replaced:

| Display Symbol | Unicode | Replaced With | JavaScript Operator |
|---|---|---|---|
| `×` | U+00D7 | `*` | Multiplication |
| `÷` | U+00F7 | `/` | Division |

The substitution uses two chained `.replace()` calls with global regex flags (`/g`) to replace all occurrences in the expression, not just the first.

---

## Button Reference Table

| Button | Label | Color | Input Sent | Row | Column |
|---|---|---|---|---|---|
| btn7 | `7` | `#333333` (grey) | `"7"` | 1 | 1 |
| btn8 | `8` | `#333333` (grey) | `"8"` | 1 | 2 |
| btn9 | `9` | `#333333` (grey) | `"9"` | 1 | 3 |
| btnDivide | `÷` | `#ff9500` (orange) | `"÷"` | 1 | 4 |
| btn4 | `4` | `#333333` (grey) | `"4"` | 2 | 1 |
| btn5 | `5` | `#333333` (grey) | `"5"` | 2 | 2 |
| btn6 | `6` | `#333333` (grey) | `"6"` | 2 | 3 |
| btnMultiply | `×` | `#ff9500` (orange) | `"×"` | 2 | 4 |
| btn1 | `1` | `#333333` (grey) | `"1"` | 3 | 1 |
| btn2 | `2` | `#333333` (grey) | `"2"` | 3 | 2 |
| btn3 | `3` | `#333333` (grey) | `"3"` | 3 | 3 |
| btnMinus | `-` | `#ff9500` (orange) | `"-"` | 3 | 4 |
| btnClear | `C` | `#ff5555` (red) | `"C"` | 4 | 1 |
| btn0 | `0` | `#333333` (grey) | `"0"` | 4 | 2 |
| equalId | `=` | `#2ecc71` (green) | `"="` | 4 | 3 |
| btnPlus | `+` | `#ff9500` (orange) | `"+"` | 4 | 4 |

**Notable absences:** There is no decimal point (`.`) button, no backspace/delete button, no negative number button, and no percentage button.

---

## Color Palette & Design System

| Color Hex | Color Name | Used For | Semantic Role |
|---|---|---|---|
| `#1a1a1a` | Dark charcoal | Window background, button area | App background |
| `"black"` | Pure black | Display background | Input display |
| `#333333` | Medium dark grey | Digit buttons (0–9) | Neutral input |
| `#ff9500` | Orange | Operator buttons (÷, ×, −, +) | Math operators |
| `#ff5555` | Coral red | Clear button (C) | Destructive action |
| `#2ecc71` | Emerald green | Equals button (=) | Confirm/execute |
| `"white"` | White | All button labels, display text | High contrast text |

The design follows the philosophy of **iOS Calculator aesthetics**: dark base, high-contrast white text, orange operators, and semantic color coding for special actions.

---

## Component Deep Dive: Every Rectangle Button

Every button follows the same structural pattern:

```qml
Rectangle {
    id: <buttonId>
    width: parent.width / 4 - 10
    height: parent.height / 4 - 10
    radius: 20
    color: "<buttonColor>"
    Text {
        text: "<label>"
        anchors.centerIn: parent
        color: "white"
        font.pixelSize: <size>
        font.bold: true
    }
    MouseArea {
        anchors.fill: parent
        onClicked: handleInput("<value>")
    }
}
```

Key design decisions:
- **`radius: 20`** — All buttons are rounded rectangles, giving a soft, modern feel.
- **`anchors.centerIn: parent`** — Text is always perfectly centered in the button.
- **`font.bold: true`** — All labels are bold for high visibility on dark backgrounds.
- **`MouseArea { anchors.fill: parent }`** — The click area covers the entire button surface, not just the text, ensuring easy tapping.
- **Font sizes vary by button type:**
  - Digits (`0–9`): `font.pixelSize: 30`
  - Large operators (`÷`, `×`, `=`, `+`): `font.pixelSize: 40–45`
  - Minus (`-`): `font.pixelSize: 45`
  - Clear (`C`): `font.pixelSize: 30`

---

## Layout & Sizing Logic

The layout uses **proportional sizing** — everything is defined as a fraction of the parent's size, making it responsive to window resizing.

```
Window (640 × 480)
├── displayID       → width = 640 × 0.97 = 620.8px
│                     height = 480 × 0.25 = 120px
└── buttonArea      → width = 640 × 0.90 = 576px
                      height = 480 × 0.60 = 288px

    Grid (fills buttonArea: 576 × 288)
    ├── Each button width  = 576/4 − 10 = 134px
    └── Each button height = 288/4 − 10 =  62px
```

**Anchoring strategy:**
- `displayID` → `anchors.top: parent.top` + `anchors.horizontalCenter: parent.horizontalCenter`
- `buttonArea` → `anchors.bottom: parent.bottom` + `anchors.horizontalCenter: parent.horizontalCenter`
- This creates a layout where the display is at the top and the buttons are at the bottom, with the dark background visible between them.

---

## Known Behaviors & Edge Cases

| Behavior | Description | Impact |
|---|---|---|
| `C` does not reset `isCalculated` | After pressing `=` then `C`, then a digit, the digit will start a fresh expression (correct behavior, but for a coincidental reason) | Low — works correctly by accident |
| Division by zero → `Infinity` | `eval("5/0")` returns `Infinity` in JavaScript, not an error. The display will show `"Infinity"` | Medium — not user-friendly |
| No decimal point button | Users cannot type decimal numbers like `3.14` | Medium — missing basic feature |
| No backspace button | Mistakes require a full `C` clear | Medium — usability gap |
| `eval()` on malformed input → `"Error"` | Typing `++5` or `5+` then pressing `=` triggers the catch block and shows `"Error"` | Low — handled gracefully |
| Operator precedence is respected | `2+3×4` evaluates as `14` (not `20`) because `eval()` respects standard math rules | Positive behavior |
| Large numbers display overflow | Very long results or expressions may overflow the display text area since there is no text scaling or scrolling | Low — edge case |
| `isCalculated` after Error | If `=` causes `"Error"`, `isCalculated` is NOT set to true. Next input appends to `"Error"` | Minor bug |

---

## Requirements

| Requirement | Version |
|---|---|
| Qt Framework | Qt 6.x (uses `import QtQuick` without version number — Qt 6 style) |
| Qt Quick module | Included with Qt 6 |
| Qt Quick Window module | Included with Qt 6 |
| Operating System | Windows / macOS / Linux (Qt is cross-platform) |
| Build tool | `qmake` or `cmake` (for full project), or `qml` CLI for quick run |

---

## How to Run

### Using the `qml` command-line tool (quickest):
```bash
qml Main.qml
```

### Using Qt Creator:
1. Open Qt Creator
2. Create a new **Qt Quick Application** project
3. Replace the generated `Main.qml` with this file's contents
4. Press **Run** (Ctrl+R)

### Using CMake:
```cmake
cmake_minimum_required(VERSION 3.16)
project(Calculator)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_add_executable(Calculator main.cpp)
qt_add_qml_module(Calculator
    URI Calculator
    VERSION 1.0
    QML_FILES Main.qml
)

target_link_libraries(Calculator PRIVATE Qt6::Quick)
```

---

## Possible Improvements

| Feature | Description |
|---|---|
| Decimal point button | Add a `.` button to enable float input |
| Backspace button | Delete the last character instead of clearing everything |
| Fix division by zero | Check for `/0` before calling `eval()` and show a friendly error |
| Operator chaining fix | Prevent double operators (e.g., `5++3`) before evaluation |
| Keyboard input support | Add `Keys.onPressed` to the window to support physical keyboard input |
| Button press animation | Add a `scale` or `opacity` animation on `MouseArea.onPressed` for tactile feedback |
| Font scaling | Use `fontSizeMode: Text.Fit` on the display text to auto-shrink long expressions |
| History panel | Store previous calculations and display them above the current expression |
| Scientific mode | Add `sin`, `cos`, `sqrt`, `%`, `^` operators |
| Accessibility | Add `Accessible.name` to each button for screen reader support |
| Hover effects | Add `MouseArea.containsMouse` hover color changes for desktop UX |
| Fix `isCalculated` after Error | Set `isCalculated = false` in the catch block to prevent appending to `"Error"` |

---

## License

This project is provided as-is for educational and personal use. No license is explicitly declared in the source file.
