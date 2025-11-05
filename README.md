# KOReader.patches

Some of the patches I created for the default Coverbrowser in KOReader.

All these patches are tested on KOReader 2025.10 "Ghost" and works perfectly.

## 🞂 How to install a user patch ?
Please [check the guide here.](https://koreader.rocks/user_guide/#L2-userpatches)

## Screenshot of final look

<img width="720" height="990" alt="Screenshot_20251105-093346" src="https://github.com/user-attachments/assets/54a08aaa-bddd-43a7-8e55-51e8aee456e0" />


## 🞂 2--rounded-corners.lua

<img width="720" height="325" alt="Screenshot_20251105-092651" src="https://github.com/user-attachments/assets/ec817115-4d42-404f-855e-8b342f07a989" />

This patch adds rounded corners to book covers in mosaic menu view.

Download the icons `rounded.corner.bl.svg`, `rounded.corner.tl.svg`, `rounded.corner.br.svg` and `rounded.corner.tr.svg` from my icons folder and place the icons in `koreader/icons` in your e-reader.

Currently the rounded corners make the `description hint tag` on the top right side of the book to become detached from the cover due to rounding off.

For now I uncheck the "Show hint for books with description" from ""Settings > Mosaid and detailed list settings > Display hints " so it looks clean, I may make a fix for this in the future.


## 🞂 2-faded-finished-books.lua

<img width="720" height="325" alt="Screenshot_20251105-092832" src="https://github.com/user-attachments/assets/f78b9114-cdfb-4f3d-94e3-43c433154e64" />

This adds a faded look to the finished books. Adjust the fading amount to your liking by editing the .lua file.


## 🞂 2-new-status-icons.lua

<img width="561" height="174" alt="Custom status icons in black and white" src="https://github.com/user-attachments/assets/4da6bebf-3519-4e68-890d-7590c8bce622" />

<img width="561" height="174" alt="Custom status icons in colour" src="https://github.com/user-attachments/assets/3f9bbe07-61ee-4e80-a4b9-5115948997ca" />


A set of new custom icons for displaying the status of a book (reading, abandonded, finished) in black and white and in colour.

Just copy the respective `dogear.abandoned.svg`, `dogear.reading.svg` and `dogear.complete.svg` to your e-reader's `koreader/icons` folder.


## 🞂 2-pages-badge.lua

<img width="720" height="143" alt="Screenshot_20251105-093606" src="https://github.com/user-attachments/assets/24cd6798-1615-4276-8ed6-d631f0016202" />


This patch adds the page number of a book to its cover on the bottom left as a small rounded badge. 

It parses the page number from the title of the file, in the following formats `P(123)` or `p(123)`. So make sure your book's title contains the page number in this format.

Page number's font, color, backgroud color, border thickness, rounded corner radius can be adjusted to your liking in the .lua file.


## 🞂 2-progress-badge.lua

<img width="720" height="143" alt="Screenshot_20251105-093752" src="https://github.com/user-attachments/assets/30519602-0c08-46e4-a6b0-82e21285a482" />


This patch adds the progress percentage of a book as a badge in the top right corner of the cover.

Copy the `2-progress-badge.lua` to `koreader/patches` and copy the `progress.badge.svg` to `koreader/icons` folder of your e-reader. You can choose coloured or bw icons based on your liking.
