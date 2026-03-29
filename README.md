## qFlipper Unleashed Private

### Форк qFlipper - Unleashed Private
Этот форк основан на оригинальном [qFlipper](https://github.com/flipperdevices/qFlipper) и сохраняет десктопный стек для Windows, macOS и Linux, но теперь кнопка `Update`: устанавливает выбранный FUS-бинарник по адресу `0x080EC000`.

<img alt="qFlipper" width="450" src="https://cdn.flipperzero.one/qflipper_logo_with_connected_flipper.png" />


## Сборка из исходников

### Клонирование
Клонируй проект вместе с submodules:

```sh
git clone <your-fork-url> --recursive
```

### Windows

Требования:
- MS Visual Studio 2019 или новее
- Qt5 (MSVC build) >= 5.15.0 или Qt6 >= 6.3.0
- NSIS для сборки инсталлятора

Отредактируй `build_windows.bat` под своё окружение и запусти:

```cmd
build_windows.bat
```

Примечание: драйвер STM32 Bootloader в этот репозиторий не входит.

### Linux

#### Docker-сборка (AppImage, основной вариант)

Подними dev-контейнер:

```sh
docker compose up -d
```

Собери qFlipper:

```sh
docker compose exec dev ./build_linux.sh
```

#### Обычная локальная сборка

Требования:
- Qt5 >= 5.15.0 или Qt6 >= 6.3.0
- libusb >= 1.0.16
- zlib >= 1.2.0

Нужные Qt-модули:

```text
base, tools, serialport, declarative, wayland, [quickcontrols2, graphicaleffects] (для Qt5), qt5-compat (для Qt6)
```

Сборка:

```sh
mkdir build && cd build
qmake ../qFlipper.pro PREFIX=/path/to/install/dir -spec linux-g++ CONFIG+=qtquickcompiler
make qmake_all
make
make install
```

`make install` в системный prefix делать не рекомендуется. Лучше использовать установку в локальную директорию или packaging-пайплайн.

При необходимости встроенное автообновление приложения можно отключить, добавив `DEFINES+=DISABLE_APPLICATION_UPDATES` к вызову `qmake`.

### macOS

Требования:
- Xcode или command line tools
- Qt6 6.3.1 static universal из [Flipper brew tap](https://github.com/flipperdevices/homebrew-flipper)
- libusb 1.0.24 universal из [Flipper brew tap](https://github.com/flipperdevices/homebrew-flipper)
- [dmgbuild](https://pypi.org/project/dmgbuild/) >= 1.5.2

Если нужна подпись бинарников, задай нужные переменные окружения и запусти:

```sh
./build_mac.sh
```

Готовый образ появится в:

```text
build_mac/qFlipper.dmg
```

## Запуск

### Linux

```sh
./build/qFlipper-x86_64.AppImage
```

Либо просто запускай этот файл из файлового менеджера.

Для нормального доступа к устройству под обычным пользователем, скорее всего, понадобятся udev rules:

```sh
./qFlipper-x86_64.AppImage rules install [/optional/path/to/rules/dir]
```

### Поддержка пакетных менеджеров

Смотри [contrib](./contrib) для доступных вариантов.

## Структура проекта
- `application` - основное GUI-приложение, в основном на QML
- `cli` - консольный интерфейс, покрывает почти всю основную функциональность
- `backend` - backend-библиотека на C++
- `dfu` - низкоуровневая библиотека для работы с USB и DFU-устройствами
- `plugins` - поддержка protobuf-протокола
- `3rdparty` - сторонние библиотеки
- `contrib` - дополнительные скрипты и пакеты
- `driver-tool` - утилита установки DFU-драйвера для Windows
- `docker` - docker-конфигурация для сборки
- `installer-assets` - ресурсы для упаковки и дистрибуции


## Известные проблемы

* Your factory keys will be erased and the flipper will stop working.
