# yuleshow-cover

![Python](https://img.shields.io/badge/Python-3.x-3776AB?logo=python&logoColor=white)
![Pillow](https://img.shields.io/badge/Pillow-PIL-8C4A2F?logo=python&logoColor=white)
![OpenCC](https://img.shields.io/badge/OpenCC-繁→簡-FF6600)
![YouTube](https://img.shields.io/badge/YouTube-Thumbnails-FF0000?logo=youtube&logoColor=white)

YouTube thumbnail generator for **梅璽閣菜話** (Yule Show's Gourmet Chatting).

## Features

- Interactive CLI — prompts for episode number, series code, Chinese/English titles
- Renders **3 variants** per episode: 16:9 繁體, 16:9 簡體, 4:3 簡體
- Automatic **Traditional → Simplified** Chinese conversion via OpenCC
- Old-school Chinese numerals (廿、卅、卌)
- Dynamic font sizing to fit text within bounds
- Green border frame with layered text overlays

## Series Supported

| Code | 繁體 | 簡體 |
|------|------|------|
| 麵 | 麵和澆頭系列 | 面和浇头系列 |
| 上 | 上海老風味 | 上海老风味 |
| 西 | 家庭西餐 | 家庭西餐 |
| 異 | 異域風味 | 异域风味 |
| 瞎 | 閣主瞎燒燒 | 阁主瞎烧烧 |
| 鹹 | 鹹泡飯 | 咸泡饭 |

## Text Layers

| Layer | Content | Fill | Stroke | Font | Size |
|-------|---------|------|--------|------|------|
| L1 | Episode (總第N集) | ![](https://img.shields.io/badge/-%20-000000) Black | ![](https://img.shields.io/badge/-%20-FFFFFF) White 3px | NotoSans-Bold | 50 |
| L2 | Slogan | ![](https://img.shields.io/badge/-%20-000000) Black | ![](https://img.shields.io/badge/-%20-FFFFFF) White 2px | HermanzTitling | 61 |
| L3 | Series name | ![](https://img.shields.io/badge/-%20-FFFF00) Yellow | ![](https://img.shields.io/badge/-%20-000000) Black 10px | NotoSerif-Black | dynamic |
| L4 | Chinese title | ![](https://img.shields.io/badge/-%20-FF0000) Red | ![](https://img.shields.io/badge/-%20-FFFFFF) White 8px | NotoSans-Black | dynamic |
| L5 | English title | ![](https://img.shields.io/badge/-%20-000000) Black | ![](https://img.shields.io/badge/-%20-FFFFFF) White 3px | Sanchez | dynamic |
| L6 | TM symbol | ![](https://img.shields.io/badge/-%20-00FF00) Green | ![](https://img.shields.io/badge/-%20-000000) Black 4px | Arial Bold | 47 |
| L7 | Brand (梅璽閣菜話) | ![](https://img.shields.io/badge/-%20-00FF00) Green | ![](https://img.shields.io/badge/-%20-000000) Black 6px | SentyWen (文徵明體) | 133 |

> Canvas border: ![](https://img.shields.io/badge/-%20-00CC00) `#00CC00` (60px inset)

## Fonts Required

| Font File | Used For |
|-----------|----------|
| NotoSansTC-Bold.ttf / NotoSansSC-Bold.ttf | Episode number |
| NotoSerifTC-Black.ttf / NotoSerifSC-Black.ttf | Series name |
| NotoSansTC-Black.ttf / NotoSansSC-Black.ttf | Chinese title |
| HermanzTitling Regular.otf | English slogan |
| Sanchez Regular.otf | English title |
| Arial Bold.ttf (system) | TM symbol |
| 漢儀新蒂文徵明體.ttf | Brand 梅璽閣菜話 |

Fonts must be installed in `~/Library/Fonts/`.

## Dependencies

```bash
pip install Pillow opencc-python-reimplemented
```

## Usage

```bash
python3 yuleshow-cover.py
```

Place a `.jpg` photo in the same directory before running. The script will prompt for:
1. **總集數** — episode number (e.g. `309`)
2. **系列代碼** — series code + number (e.g. `上127`)
3. **中文主標** — Chinese title (use `\n` for line breaks)
4. **英文主標** — English title (use `\n` for line breaks)

Outputs are saved as `OUT_*.png`.
