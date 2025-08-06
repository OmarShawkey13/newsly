# 📰 Newsly

A sleek, fast, and clean **Flutter** application that fetches and displays the latest news articles using [NewsAPI.org](https://newsapi.org/), built with **Clean Architecture**, **Bloc**, and **TDD** principles.

---

## 📱 Preview

<div align="center">
  <img src="assets/screenshots/preview.jpg" alt="Newsly Preview" width="250"/>
</div>

---

## ✨ Features

- 🔍 Search for real-time news with debounced input
- 🧠 Built using **Bloc/Cubit** for clean state management
- 💾 Caches data locally using `SharedPreferences`
- 🌙 Light/Dark theme toggle with full support
- 🧱 Uses **Clean Architecture** (domain/data/presentation separation)
- ✅ Structured with **Test-Driven Development** in mind
- 📡 Consumes data via `Dio` with proper error handling
- 🎨 Fully responsive UI with Skeleton loading placeholders

---

## 🔧 Tech Stack

| Layer            | Libraries                              |
|------------------|----------------------------------------|
| State Management | `flutter_bloc`, `bloc`                 |
| API              | `Dio`, `NewsAPI.org`                   |
| Caching          | `SharedPreferences`                    |
| Functional       | `Dartz`                                |
| UI Enhancements  | `skeletonizer`, `cupertino_icons`      |
| Testing (TDD)    | `flutter_test`, `mockito`, `bloc_test` |

---

## 🧱 Folder Structure

```
lib/
├── core/
│   ├── di/
│   ├── error/
│   ├── network/
│   ├── theme/
│   ├── utils/
├── features/
│   └── home/
│       ├── data/
│       └── presentation/
├── main.dart
```

> Follows a layered, scalable architecture separating concerns into **Core** and **Features**

---

## 🚀 Getting Started

```bash
git clone https://github.com/your-username/newsly.git
cd newsly
flutter pub get
flutter run
```

Make sure to:
- Get a free API key from [NewsAPI.org](https://newsapi.org)
- Add it to your secure config or `dio_helper.dart`

---

## 📁 Important Files

| File                              | Purpose                                   |
|-----------------------------------|-------------------------------------------|
| `injections.dart`                 | Dependency Injection setup                |
| `api_endpoints.dart`              | Base URLs and API paths                   |
| `dio_helper.dart`                 | Configured Dio instance with interceptors |
| `home_cubit.dart`                 | Business logic for news                   |
| `search_list_widget.dart`         | Builds dynamic article list               |
| `categories_list.dart`            | Custom category selector                  |
| `colors.dart`, `text_styles.dart` | Centralized theming                       |

---

## 🧪 Testing

```bash
flutter test
```

> Unit, Widget, and Cubit tests following best practices.

---

## 🏷 Package Name

```
dev.omarshawkey.newsly
```

---

## 📄 License

MIT License – feel free to use and modify.

---

## 👨‍💻 Developed by

**Omar Shawkey**  
[GitHub](https://github.com/omarshawkey) – [LinkedIn](https://www.linkedin.com/in/omarshawkey)

---

## 📌 Notes

- NewsAPI.org has **rate limits** for free usage
- This project is meant for **portfolio/CV/demo** purposes
