#!/bin/bash


# 清空laravel的数据缓存
php artisan route:clear && php artisan config:clear && php artisan cache:clear


# 重启web进程
docker restart laravel_app_1 laravel_web_1
