# Notes App

A modern, feature-rich Flutter notes application.

## Features

- **Create, edit, and delete notes**
- **Pin notes:** Keep important notes at the top
- **Password protection:** Secure individual notes with a 4-digit password
- **Colorful notes:** Choose a background color for each note
- **Search:** Quickly find notes by title or content
- **Recycle Bin:** Restore or permanently delete notes
- **Pinned Notes Screen:** View only your pinned notes
- **Dark & Light Themes:** Switch between light and dark modes
- **Multi-select:** Select multiple notes for batch actions (pin/unpin, delete)
- **Accessibility:** Semantic announcements, tooltips, large tap targets
- **Undo for delete, pull-to-refresh, and error feedback**
- **Haptic feedback and subtle animations for all key actions**

## Screenshots

<div align="center">

<table>
  <tr>
    <td align="center"><b>Home</b></td>
    <td align="center"><b>Edit Note</b></td>
    <td align="center"><b>Locked</b></td>
    <td align="center"><b>Pinned</b></td>
  </tr>
  <tr>
    <td><img src="assets/screenshots/home1.png" alt="Home 1" width="180"/></td>
    <td><img src="assets/screenshots/edit1.png" alt="Edit 1" width="180"/></td>
    <td><img src="assets/screenshots/lock1.png" alt="Lock 1" width="180"/></td>
    <td><img src="assets/screenshots/pin1.png" alt="Pin 1" width="180"/></td>
  </tr>
  <tr>
    <td><img src="assets/screenshots/home2.png" alt="Home 2" width="180"/></td>
    <td><img src="assets/screenshots/edit2.png" alt="Edit 2" width="180"/></td>
    <td><img src="assets/screenshots/lock2.png" alt="Lock 2" width="180"/></td>
    <td><img src="assets/screenshots/search1.png" alt="Search" width="180"/></td>
  </tr>
  <tr>
    <td align="center"><b>Recycle Bin</b></td>
    <td align="center"><b>Settings</b></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td><img src="assets/screenshots/bin1.png" alt="Recycle Bin" width="180"/></td>
    <td><img src="assets/screenshots/settings1.png" alt="Settings" width="180"/></td>
    <td></td>
    <td></td>
  </tr>
</table>

</div>

## APK Download

<!-- Add APK download link here -->

## Getting Started

1. **Clone the repository:**
   ```sh
   git clone https://github.com/yourusername/notes_app.git
   cd notes_app
   ```
2. **Install dependencies:**
   ```sh
   flutter pub get
   ```
3. **Run the app:**
   ```sh
   flutter run
   ```

## Folder Structure

- `lib/main.dart` - Main app logic and home screen
- `lib/note_edit_screen.dart` - Note creation and editing
- `lib/search_screen.dart` - Search notes
- `lib/recycle_bin_screen.dart` - Recycle bin for deleted notes
- `lib/pinned_notes_screen.dart` - Screen for pinned notes
- `lib/settings_screen.dart` - Theme and settings

## Password Protection

- You can set a 4-digit password for any note.
- When opening a protected note, you must enter the correct password.
- To remove or change a password, use the lock icons in the note edit screen.

## Customization

- Change note colors using the color picker in the note edit screen.
- Pin/unpin notes from the main screen or note edit screen.
- Use the side menu to access pinned notes, recycle bin, and settings.

## Members

- [Karunakar Raunak](https://github.com/LuciferBloodFalen)
- [Krish Mazumder](https://github.com/krish-mazumder)
- [Kruthika V](https://github.com/Kruthika1735)

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

---

Made with ❤️ using [Flutter](https://flutter.dev/)
