import os
import json

# Đường dẫn tới thư mục chứa các file JSON
json_dir = 'datatest'

# Đường dẫn tới thư mục để lưu các file .sol
sol_dir = 'sol_files_final'
os.makedirs(sol_dir, exist_ok=True)

# Duyệt qua từng file JSON trong thư mục
for json_file in os.listdir(json_dir):
    if json_file.endswith('.json'):
        json_path = os.path.join(json_dir, json_file)
        
        # Đọc nội dung file JSON
        with open(json_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Duyệt qua từng key trong dictionary
        for key, value in data.items():
            if key not in ['id', 'description']:
                # Tạo tên file .sol từ key
                sol_file_name = f"{key}"
                sol_file_path = os.path.join(sol_dir, sol_file_name)
                
                # Lưu giá trị vào file .sol mà không định dạng lại
                with open(sol_file_path, 'w', encoding='utf-8') as sol_file:
                    sol_file.write(value)