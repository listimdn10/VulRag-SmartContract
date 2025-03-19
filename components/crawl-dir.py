import requests
from bs4 import BeautifulSoup
import json
import os

# Danh sách các URL từ 100 đến 136
urls = [
    "https://swcregistry.io/docs/SWC-100/",
    "https://swcregistry.io/docs/SWC-101/",
    "https://swcregistry.io/docs/SWC-102/",
    "https://swcregistry.io/docs/SWC-103/",
    "https://swcregistry.io/docs/SWC-104/",
    "https://swcregistry.io/docs/SWC-105/",
    "https://swcregistry.io/docs/SWC-106/",
    "https://swcregistry.io/docs/SWC-107/",
    "https://swcregistry.io/docs/SWC-108/",
    "https://swcregistry.io/docs/SWC-109/",
    "https://swcregistry.io/docs/SWC-110/",
    "https://swcregistry.io/docs/SWC-111/",
    "https://swcregistry.io/docs/SWC-112/",
    "https://swcregistry.io/docs/SWC-113/",
    "https://swcregistry.io/docs/SWC-114/",
    "https://swcregistry.io/docs/SWC-115/",
    "https://swcregistry.io/docs/SWC-116/",
    "https://swcregistry.io/docs/SWC-117/",
    "https://swcregistry.io/docs/SWC-118/",
    "https://swcregistry.io/docs/SWC-119/",
    "https://swcregistry.io/docs/SWC-120/",
    "https://swcregistry.io/docs/SWC-121/",
    "https://swcregistry.io/docs/SWC-122/",
    "https://swcregistry.io/docs/SWC-123/",
    "https://swcregistry.io/docs/SWC-124/",
    "https://swcregistry.io/docs/SWC-125/",
    "https://swcregistry.io/docs/SWC-126/",
    "https://swcregistry.io/docs/SWC-127/",
    "https://swcregistry.io/docs/SWC-128/",
    "https://swcregistry.io/docs/SWC-129/",
    "https://swcregistry.io/docs/SWC-130/",
    "https://swcregistry.io/docs/SWC-131/",
    "https://swcregistry.io/docs/SWC-132/",
    "https://swcregistry.io/docs/SWC-133/",
    "https://swcregistry.io/docs/SWC-134/",
    "https://swcregistry.io/docs/SWC-135/",
    "https://swcregistry.io/docs/SWC-136/"
]

# Tạo thư mục 'datatest' nếu chưa tồn tại
os.makedirs('datatest', exist_ok=True)

for url in urls:
    # Gửi request đến trang web
    response = requests.get(url)
    response.raise_for_status()  # Kiểm tra lỗi HTTP

    # Phân tích HTML bằng BeautifulSoup
    soup = BeautifulSoup(response.content, "html.parser")

    # Dictionary để lưu dữ liệu
    data_dict = {}

    # Thêm trường id vào dictionary
    data_dict["id"] = url.split('/')[-2]

    # Tìm thẻ <h2> có id="description"
    description_heading = soup.find("h2", id="description")

    if description_heading:
        # Lấy tất cả thẻ <p> ngay sau thẻ <h2 id="description">
        paragraphs = []
        next_element = description_heading.find_next_sibling()
        while next_element and next_element.name == "p":
            paragraphs.append(next_element.get_text(strip=True))
            next_element = next_element.find_next_sibling()

        # Lưu vào dictionary với key "description"
        data_dict["description"] = paragraphs

    # Lấy nội dung của các thẻ <code> bên trong <pre>, với key là text của thẻ <h3> ngay phía trên
    for div in soup.find_all("div", class_="highlight"):
        # Tìm thẻ <h3> phía trên
        h3 = div.find_previous_sibling("h3")
        key_name = h3.get_text(strip=True) if h3 else "Unnamed Code Snippet"

        # Lấy nội dung của <code> bên trong <pre>
        pre = div.find("pre")
        if pre:
            code = pre.find("code")
            if code:
                # Loại bỏ các thẻ <span> có class="c1"
                for span in code.find_all("span", class_="c1"):
                    span.decompose()
                # Thêm khoảng trắng cho các thẻ <span> có class="w"
                for span in code.find_all("span", class_="w"):
                    span.replace_with(" ")
                code_text = code.get_text()
                data_dict[key_name] = code_text

    # Tạo tên file JSON từ URL
    file_name = url.split('/')[-2] + '.json'
    file_path = os.path.join('datatest', file_name)

    # Lưu dữ liệu thu thập được vào file JSON
    with open(file_path, 'w', encoding='utf-8') as json_file:
        json.dump(data_dict, json_file, ensure_ascii=False, indent=4)