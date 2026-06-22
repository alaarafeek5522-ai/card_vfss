from PIL import Image

img = Image.open("assets/images/card.jpg").convert("RGBA")
datas = img.getdata()

new_data = []
for item in datas:
    # لو البيكسل قريب من الأسود، خليه شفاف
    if item[0] < 15 and item[1] < 15 and item[2] < 15:
        new_data.append((0, 0, 0, 0))
    else:
        new_data.append(item)

img.putdata(new_data)
img.save("assets/images/card.png", "PNG")
