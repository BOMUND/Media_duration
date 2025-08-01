#!/bin/bash
# Инсталлятор для mdur

set -e  # Прерывать выполнение при ошибках

INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="mdur"
TEMP_FILE="/tmp/${SCRIPT_NAME}_download"

echo "Установка скрипта $SCRIPT_NAME..."

# Проверка прав суперпользователя
if [ "$EUID" -ne 0 ]; then
    echo "Ошибка: Для установки требуется root-права. Запустите с sudo."
    exit 1
fi

# URL скрипта
SCRIPT_URL="https://raw.githubusercontent.com/BOMUND/mdur/main/mdur"

# Удаление старой версии, если существует
if [ -f "$INSTALL_DIR/$SCRIPT_NAME" ]; then
    echo "Найдена старая версия. Удаляю..."
    rm -f "$INSTALL_DIR/$SCRIPT_NAME"
    echo "Старая версия удалена."
fi

# Очистка временного файла, если остался от предыдущих попыток
rm -f "$TEMP_FILE"

# Скачивание скрипта
echo "Скачиваю последнюю версию..."
if ! curl -sSL "$SCRIPT_URL" -o "$TEMP_FILE"; then
    echo "Ошибка: Не удалось скачать скрипт с $SCRIPT_URL" >&2
    rm -f "$TEMP_FILE"
    exit 1
fi

# Проверка, что файл не пустой
if [ ! -s "$TEMP_FILE" ]; then
    echo "Ошибка: Скачанный файл пустой. Возможно, проблема с подключением или URL." >&2
    rm -f "$TEMP_FILE"
    exit 1
fi

# Копирование в целевую директорию
cp "$TEMP_FILE" "$INSTALL_DIR/$SCRIPT_NAME"

# Делаем исполняемым
chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# Очистка временных файлов
rm -f "$TEMP_FILE"

# Проверка установки
if command -v "$SCRIPT_NAME" &> /dev/null; then
    echo "$SCRIPT_NAME успешно установлен в $INSTALL_DIR/$SCRIPT_NAME"
    echo "Версия: $(mdur --help | head -1)"
    echo "Установка завершена!"
else
    echo "Ошибка: Установка прошла, но скрипт не найден в PATH" >&2
    exit 1
fi