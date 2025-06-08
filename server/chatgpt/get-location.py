import openai
import re
import requests
import pandas as pd
import json
import googlemaps
gm = googlemaps.Client(key="")


headers = {'X-Api-Key' : ''}
url = 'https://newsapi.org/v2/everything'
params = {
    'qInTitle': 'homicide OR kill',
    'sortBy': 'publishedAt',
    'pageSize': 30,
    'from': '2024-07-20T00:00:00Z',
    'to': '2024-08-04T23:59:59Z'
}

# get information from news API
response = requests.get(url, headers=headers, params=params)
openai.api_key = ""

# ニュースの取得に成功した場合
if response.ok:
    data = response.json()
    articles = data['articles']
    
    # 事件情報を格納するための配列
    valid_incidents = []

    # 各記事に対して処理を行う
    for article in articles:
        file_contents = article['content']
        file_title = article['title']
        file_URL = article['url']

        # もしcontentがNoneであればスキップ
        if not file_contents:
            continue
        
        # ChatGPTにニュース内容を入力
        res = openai.ChatCompletion.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "system", "content": """Only output the incident name, detailed location address, and incident date and time if all of them can be obtained from the input text. 
The output format should be:
incident: [incident name]
place: [detailed location address]
date: [incident date and time]"
                """},
                {"role": "user", "content": file_contents}
            ],
        )

        # ChatGPTの出力を取得
        chatgpt_output = res.choices[0].message['content']

        if not chatgpt_output:
          continue

        # 正規表現を使ってplaceの値を抽出
        place_match = re.search(r'place:\s*(.*)', chatgpt_output)
        if place_match:
            place = place_match.group(1)
        else:
            place = "0"  # 住所が取得できなかった場合は0を設定

        # placeが0でなければ、詳細な住所かどうかを再確認
        if place != "0":
            res_check = openai.ChatCompletion.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": """If the address only includes the state or city level information, output 0. Otherwise, output the detailed address."""},
                    {"role": "user", "content": f"Is this address detailed enough? {place}"}
                ],
            )

            # ChatGPTの出力を取得
            chatgpt_check_output = res_check.choices[0].message['content'].strip()

            if not chatgpt_check_output:
              continue

            # 出力が0であればplaceを0に設定
            if chatgpt_check_output == "0":
                place = "0"

        # 最終的なplace変数の内容を確認し、配列に追加
        if place != "0":
            incident_info = {
                "incident": re.search(r'incident:\s*(.*)', chatgpt_output).group(1),
                "place": place,
                "date": re.search(r'date:\s*(.*)', chatgpt_output).group(1),
                "url": file_URL
            }
            valid_incidents.append(incident_info)
    
        # Google Map API
        for incident in valid_incidents:
          address = incident["place"]
          if address != "0":
            res = gm.geocode(address)
            if res:
                location = res[0]['geometry']['location']
                print(f"Address: {address}")
                print(f"Coordinates: {location}")
                print(f"Reference URL: {incident['url']}")
            else:
                print(f"Address: {address}")
                print("Coordinates: Not found")
                print(f"Reference URL: {incident['url']}")
