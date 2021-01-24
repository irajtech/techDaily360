---
layout: post
title: Google Sheets Automation to create JSON and QRcode
date: '2021-1-24 09:41:09 +0200'
categories: Automate
permalink: /:title/post
tags: [automation, google sheets, json, qrcode]
shortPost: "true"
---

Automation helps us to make our life easier, when we are trying do the same thing again and again.

In this post, we are going to see how can we create JSON and QRCode from the cell entries using simple macros.

The use case that i'm tryin to show you is that you want to share the information via QRCode and the moment we scan the QRcode we can read the data as JSON for easier parsing. This helps when we want to distribute huge set of data to the stores for configuring systems. As QR code scanning is in-built with all the smartphones cameras which is easier to scan and configure.


To achieve this i have created a sample google sheet file  [sheets url][sheets-url].


The following steps discusses how can we generate JSON and QR Code from the cell entries 

1. Define the header for all the cell contents, as this acts as a key for the json

2. Once the entry is done, we take the data from the cells using the below formula

     >=CONCATENATE("{",""""&A$1&"""",":",""""&A2&"""",",",""""&B$1&"""",":",
     """"&B2&"""",",",""""&C$1&"""",":",""""&C2&"""",",",""""&D$1&"""",":",
     """"&D2&"""",",",""""&E$1&"""",":",""""&E2&"""","}") 

3. If we see the above formula which as **&A** and **$1**, The first one takes the header values and next one takes the values from the cell to populate the JSON (Modify the cell numbers and rows according to your entry)

4. Paste this in the formula bar to get the JSON and to get value for another cells just drag the cell which as generated JSON as this will automatically create a json


5. Now we have the json, Lets create a QR Code

6. For this we are going to use the url from google, which is a free one to create QRcode on the fly using the below formula


     >=IMAGE("https://chart.apis.google.com/chart?chs=300x300&cht=qr&chld=H%7C0&chl="&F2)


7. Like the above step, modify the cell name which is **&F2** here in this case to adapt to your needs

8. This will take the json values and pass ito the url to generate the QRCode

9. Copy the formula into the cell that you would like the results

10. As mentioned above, drag the cells to see the results of other cell entries


![Sheets](/files/images/sheets_automate.png)

[sheets-url]:  https://docs.google.com/spreadsheets/d/1C-qIzlZi9e0r-Y-MELfFua8ke5k6gzlRltaKiDbEDBU/edit?usp=sharing
