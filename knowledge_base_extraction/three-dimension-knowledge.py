import os
import json
import subprocess
import re
import shutil
import glob
import os
from openai import OpenAI
# Cấu hình OpenAI API Key
OPENAI_API_KEY = ""
client = OpenAI()

# Đường dẫn tới thư mục chứa các file JSON
json_dir = './datatest'  # Thư mục datatest cùng cấp với knowledge_base_extraction
sol_files_dir = 'sol_files'  # Thư mục chứa file .sol
fixed_sol_file_dir = 'fixed_sol_files'

os.makedirs(sol_files_dir, exist_ok=True)  # Tạo thư mục nếu chưa tồn tại
os.makedirs(fixed_sol_file_dir, exist_ok=True)  # Tạo thư mục nếu chưa tồn tại


# Duyệt qua từng file JSON trong thư mục
test_files = [f for f in os.listdir(json_dir) if f.endswith('.json')]

if not test_files:
    print("Không tìm thấy file JSON nào trong thư mục datatest.")
    exit()




#methods 
# Chạy Slither để phân tích file .sol
def get_solidity_version(sol_file):
    """
    Đọc file Solidity và trích xuất phiên bản Solidity từ 'pragma solidity'
    """
    with open(sol_file, "r", encoding="utf-8") as f:
        content = f.read()
    
    match = re.search(r"pragma solidity\s+([\^~]?\d+\.\d+\.\d+);", content)
    if match:
        print("done get solidity_version")
        return match.group(1).replace("^", "").replace("~", "")  # Xóa dấu ^ hoặc ~ nếu có
    return None


def install_and_use_solc(version):
    print(f"⚙️ Cài đặt và sử dụng solc {version}...")
    try:
        subprocess.run(["solc-select", "install", version], check=True)
        subprocess.run(["solc-select", "use", version], check=True)
        print(f"✅ Đã cài đặt và sử dụng solc {version}")
    except subprocess.CalledProcessError as e:
        print(f"❌ Lỗi khi cài đặt solc {version}:\n{e}")

def move_dot_files(sol_file, file_dir):
    """
    Di chuyển tất cả các file .dot vào thư mục dot_files/<tên của file sol>/
    """
    sol_base_name = os.path.splitext(os.path.basename(sol_file))[0]  # Lấy tên file không có .sol
    dot_folder = os.path.join("dot_files", sol_base_name)  # Tạo thư mục dot_files/<tên file sol>/
    os.makedirs(dot_folder, exist_ok=True)  # Tạo thư mục nếu chưa tồn tại

    for file in os.listdir(file_dir):
        if file.endswith(".dot"):
            source_path = os.path.join(file_dir, file)
            target_path = os.path.join(dot_folder, file)
            shutil.move(source_path, target_path)
            print(f"📁 Đã di chuyển {file} vào {dot_folder}/")
    merge_dot_files(sol_base_name)  # Gọi hàm hợp nhất sau khi di chuyển file .dot


def run_slither(sol_file, file_dir):
    """
    Chạy lệnh `slither file.sol --print cfg`
    """
    if not os.path.exists(sol_file):
        print(f"❌ File {sol_file} không tồn tại!")
        return
    
    cmd = ["slither", sol_file, "--print", "cfg"]

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        print("✅ Output của Slither:")
        print(result.stdout)

        with open("cfg_output.txt", "w", encoding="utf-8") as f:
            f.write(result.stdout)

        print("📁 Output đã được lưu vào cfg_output.txt")
        move_dot_files(sol_file, file_dir)  # Di chuyển file .dot vào thư mục tương ứng
    except subprocess.CalledProcessError as e:
        print(f"❌ Lỗi khi chạy Slither:\n{e.stderr}")

def merge_dot_files(sol_file_name):
    """
    Hợp nhất tất cả các file .dot trong từng thư mục con của dot_files
    """
    parent_dir = "dot_files"
    subdir_path = os.path.join(parent_dir, sol_file_name)  # Chỉ lấy thư mục dot_files/<sol_file_name>/

    
    if not os.path.exists(parent_dir):
        print(f"⚠️ Thư mục {parent_dir} không tồn tại, bỏ qua hợp nhất.")
        return
    
    # Lấy tất cả file .dot trong thư mục con dot_files/<sol_file_name>/
    dot_files = glob.glob(os.path.join(subdir_path, "*.dot"))
    
    if not dot_files:
        print(f"⚠️ Không tìm thấy file .dot nào trong {subdir_path}.")
        return

    # Tạo file .dot hợp nhất
    merged_dot_file = os.path.join(subdir_path, f"{sol_file_name}.dot")

    with open(merged_dot_file, "w") as outfile:
        outfile.write("digraph CFG {\n")  # Chỉ ghi phần mở đầu một lần

        for dot_file in dot_files:
            with open(dot_file, "r") as infile:
                for line in infile:
                    # Loại bỏ dòng bắt đầu bằng "digraph" hoặc chỉ có dấu "}"
                    if line.startswith("digraph") or line.strip() == "}":
                        continue
                    outfile.write(line)  # Ghi nội dung của các node
        
        outfile.write("}\n")  # Chỉ ghi dấu đóng một lần ở cuối

    # Xóa các file .dot cũ, chỉ giữ lại file hợp nhất
    for dot_file in dot_files:
        if dot_file != merged_dot_file:
            os.remove(dot_file)

    print(f"✅ Hợp nhất hoàn tất! Đã tạo {merged_dot_file}.")
    

import os
import re
import string

def save_analysis_result(swcid, answer, solidity_content):
    """
    Lưu kết quả phân tích vào thư mục Documents/{SWC_id}.
    Nếu SWC_id đã tồn tại, thêm hậu tố -a, -b, -c để tránh trùng lặp.
    """
    base_dir = os.path.join(os.getcwd(), "documents")  # Thư mục hiện tại/documents
    os.makedirs(base_dir, exist_ok=True)  # Tạo thư mục nếu chưa có    
    sanitized_swcid = re.sub(r'[^\w\-]', '_', swcid)  # Xóa ký tự đặc biệt

    target_file = os.path.join(base_dir, f"{sanitized_swcid}.txt")

    
    # Nếu file đã tồn tại, thêm hậu tố -a, -b, -c...
    
    suffix_index = 0
    while os.path.exists(target_file):
        suffix_index += 1
        suffix = f"-{string.ascii_lowercase[suffix_index-1]}"  # a, b, c...
        target_file = os.path.join(base_dir, f"{sanitized_swcid}{suffix}.txt")



        # Lưu nội dung file Solidity và kết quả GPT
    with open(target_file, "w", encoding="utf-8") as f:
        f.write(solidity_content)
        f.write("\n\n")  # Ngăn cách nội dung Solidity và GPT
        f.write(answer)

    
    print(f"✅ Kết quả đã được lưu tại: {target_file}")



def analyze_funtional_sematics_with_gpt(sol_file_path, swc_id):
    """Gửi nội dung file Solidity đến OpenAI GPT-3.5 để phân tích"""
    if not os.path.exists(sol_file_path):
        print(f"⚠️ Không tìm thấy file {sol_file_path}")
        return

    with open(sol_file_path, "r", encoding="utf-8") as sol_file:
        solidity_content = sol_file.read()

    prompt = f"""
        What is the purpose of the above code snippet? Please 
        summarize the answer in one sentence with the following format:
        “Abstract purpose:”. 

        Please summarize the functions of the above code snippet in the list
        format without any other explanation: “Detail Behaviors: 1. 2. 3...” 

        Here is the file content:
        {solidity_content}
                """

    try:
        completion = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {"role": "developer", "content": "You are a specialist in Smart Contract analysing, talk like an expert in Smart Contract"},
                {
                        "role": "user",
                        "content": prompt,

                }, 
            ],
        )
        answer = completion.choices[0].message.content
        print(f"\n📄 ANALYZE THE {solidity_content}:\n{answer}")
        save_analysis_result(swc_id,answer, solidity_content)

    except Exception as e:
        print(f"❌ Lỗi khi gọi OpenAI API: {e}")

def analyze_dot_file_with_gpt(dot_file_path):
        """Gửi nội dung file .dot đến OpenAI GPT-3.5 để phân tích"""
        if not os.path.exists(dot_file_path):
            print(f"⚠️ Không tìm thấy file {dot_file_path}")
            return

        with open(dot_file_path, "r", encoding="utf-8") as file:
            dot_content = file.read()
    # Khúc này dự kiến câu prompt cần có cả .dot và code solidity 
        prompt = f"""
    This is a code snippet with
    a vulnerability {SWC_id}: [Vulnerable Code] The vulnerability is
    described as follows: {SWC_description} 
    The code after modification is as follows: [Patched
    Code] Why is the above modification necessary? 


    I want you to act as a vulnerability detection expert and organize 
    vulnerability knowledge based on the above vulnerability repair information. 
    Please summarize the generalizable specific behavior of the code that leads to the 
    vulnerability and the specific solution to fix it. Format your findings in JSON.
    Here are some examples to guide you on the level of detail expected
    in your extraction: 
    [Vulnerability Causes and Fixing Solution Example 1] 
    [Vulnerability Causes and Fixing Solution Example 2]
                    """

        try:
            completion = client.chat.completions.create(
                model="gpt-4o",
                messages=[
                    {"role": "developer", "content": "You are a specialist in Smart Contract analysing, talk like an expert in Smart Contract"},
                    {
                        "role": "user",
                        "content": prompt,

                    }, 
                ],

            )
            answer = completion.choices[0].message.content
            print(f"\n📄 ANALYZE THE {dot_file_path}:\n{answer}")

        except Exception as e:
            print(f"❌ Lỗi khi gọi OpenAI API: {e}")

if __name__ == "__main__":
#main
# functional sematics analysis and vul solu
#duyệt qua từng file json trong dataset
    for json_file in test_files:
        json_path = os.path.join(json_dir, json_file)
        
        # Đọc nội dung file JSON
        with open(json_path, 'r', encoding='utf-8') as f:
            try:
                data = json.load(f)
            except json.JSONDecodeError:
                print(f"Lỗi: Không thể đọc file JSON {json_file}")
                continue
        fixed_sol_file_path = ""
        sol_file_path ="" 
        SWC_id = ""
        SWC_description = ""
        # Duyệt qua từng key trong dictionary để lấy vul.sol
        for key, value in data.items():
            if key.endswith("fixed.sol"):  # Chỉ lấy các file có chữ 'fixed'
                # Lấy thông tin id và description
                SWC_id = data.get("id", "Unknown ID")
                SWC_description = " ".join(data.get("description", []))  # Ghép list thành chuỗi
                
                # print(value)
                # print("\n" + "-"*80 + "\n")
                # Lưu code Solidity vào file .sol trong thư mục fixed_sol_files
                fixed_sol_file_path = os.path.join(fixed_sol_file_dir, f"{key}") #cái này là cái file .sol được lưu trong dir fixed_sol_files
                with open(fixed_sol_file_path, 'w', encoding='utf-8') as sol_file:
                    sol_file.write(value)

                print("============================================")
                print("Xử lý vulnerability and solution extraction")

                print(f"📁 Đã lưu code Solidity vào {fixed_sol_file_path}\n") 
                #xử lý vul and solu 
                print(f"SWC ID: {SWC_id}")
                print(f"Description: {SWC_description}\n")
                print(f"--- File: {key} ---\n")
                fixed_solc_version = get_solidity_version(fixed_sol_file_path)
                if fixed_solc_version:
                    install_and_use_solc(fixed_solc_version)
                    run_slither(fixed_sol_file_path, fixed_sol_file_dir)
                else:
                    print(f"⚠️ Không tìm thấy phiên bản Solidity trong {fixed_sol_file_path}")
                    
            #funtional sematics 
            # Bỏ qua các trường 'id' và 'description'
            if key not in ['id', 'description'] and 'fixed' not in key:
                print(f"--- File: {key} ---\n")
                # print(value)
                # print("\n" + "-"*80 + "\n")
                
                # Lưu code Solidity vào file .sol
                sol_file_path = os.path.join(sol_files_dir, f"{key}")
                with open(sol_file_path, 'w', encoding='utf-8') as sol_file:
                    sol_file.write(value)
                
                print(f"📁 Đã lưu code Solidity vào {sol_file_path}\n") #sol_file_path là file .sol 
                # xử lý funtional sematics 
                solc_version = get_solidity_version(sol_file_path)
                if solc_version:
                    install_and_use_solc(solc_version)
                    merged_dot_file = run_slither(sol_file_path, sol_files_dir)
                    # analyze_funtional_sematics_with_gpt(merged_dot_file, sol_file_path)
                    # print("đây là sol_file_path:", sol_file_path)
                    # print("đây là merge_dot_file:" , merged_dot_file)
                else:
                    print(f"⚠️ Không tìm thấy phiên bản Solidity trong {sol_file_path}")
            
        print(sol_file_path)
        # Gọi GPT-3.5 phân tích file .dot hợp nhất
        analyze_funtional_sematics_with_gpt(sol_file_path, SWC_id)
        print(fixed_sol_file_path)