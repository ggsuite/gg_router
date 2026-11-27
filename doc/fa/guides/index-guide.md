<!--
@license
Copyright (c) ggsuite

Use of this source code is governed by terms that can be
found in the LICENSE file in the root of this package.
-->

# راهنمای فهرست (Index)

## ساختن یک index.jsonc <a id="create-an-indexjsonc"></a>

- اگر وجود ندارد:
  - `doc/en/templates/index-template.jsonc` را به `index.jsonc` کپی کنید
- فیلدهای قالب را نگه دارید، هیچ فیلد دیگری از خودتان اضافه نکنید
- توضیحات (comments) را نگه دارید: آن‌ها می‌گویند چه چیزی در هر فیلد قرار
  می‌گیرد

## استفاده از index.jsonc برای برنامه‌ریزی <a id="use-indexjsonc-for-planning"></a>

- پیش از برنامه‌ریزی یک تیکت، فایل فهرست را بخوانید
- در صورت نیاز، فایل‌های فهرستِ همه‌ی مخزن‌های ocean را هم بخوانید
- سپس تصمیم بگیرید که تیکت شما به کدام مخزن‌ها نیاز دارد

## به‌روزرسانی index.jsonc پیش از هر انتشار <a id="update-indexjsonc-before-each-publish"></a>

- فایل فهرست را پیش از انتشار هر تیکت به‌روز کنید
- تا حد ممکن کوتاه و کم‌مصرف از نظر توکن بنویسید
- به جای جمله از کلیدواژه استفاده کنید
- فایل‌ها یا رابط‌های (interfaces) تغییرکرده را به‌روز کنید
