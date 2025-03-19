import subprocess
import os
import re
import shutil

def get_solidity_version(sol_file):
    """
    Đọc file Solidity và trích xuất phiên bản Solidity từ 'pragma solidity'
    """
    with open(sol_file, "r", encoding="utf-8") as f:
        content = f.read()
    
    match = re.search(r"pragma solidity\s+([\^~]?\d+\.\d+\.\d+);", content)
    if match:
        return match.group(1).replace("^", "").replace("~", "")  # Xóa dấu ^ hoặc ~ nếu có
    return None

def install_and_use_solc(version):
    """
    Cài đặt và sử dụng phiên bản solc phù hợp
    """
    print(f"⚙️ Cài đặt và sử dụng solc {version}...")

    try:
        # Cài đặt phiên bản solc
        subprocess.run(["solc-select", "install", version], check=True)
        # Chọn phiên bản solc
        subprocess.run(["solc-select", "use", version], check=True)
        print(f"✅ Đã cài đặt và sử dụng solc {version}")
    except subprocess.CalledProcessError as e:
        print(f"❌ Lỗi khi cài đặt solc {version}:\n{e}")


def move_dot_files(sol_file):
    """
    Di chuyển tất cả các file .dot vào thư mục dot_files/<tên của file sol>/
    """
    sol_base_name = os.path.splitext(os.path.basename(sol_file))[0]  # Lấy tên file không có .sol
    dot_folder = os.path.join("dot_files", sol_base_name)  # Tạo thư mục dot_files/<tên file sol>/
    os.makedirs(dot_folder, exist_ok=True)  # Tạo thư mục nếu chưa tồn tại

    for file in os.listdir(sol_files_dir):
        if file.endswith(".dot"):
            source_path = os.path.join(sol_files_dir, file)
            target_path = os.path.join(dot_folder, file)
            shutil.move(source_path, target_path)
            print(f"📁 Đã di chuyển {file} vào {dot_folder}/")




def run_slither(sol_file):
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
        move_dot_files(sol_file)  # Di chuyển file .dot vào thư mục tương ứng

    except subprocess.CalledProcessError as e:
        print(f"❌ Lỗi khi chạy Slither:\n{e.stderr}")


# ------------------- CHƯƠNG TRÌNH CHÍNH -------------------

sol_files_dir = "sol_files"

if not os.path.exists(sol_files_dir):
    print(f"❌ Thư mục {sol_files_dir} không tồn tại!")
else:
    for file_name in os.listdir(sol_files_dir):
        if file_name.endswith(".sol"):
            sol_file_path = os.path.join(sol_files_dir, file_name)
            print(f"\n🔍 Đang xử lý file: {file_name}")

            # Lấy phiên bản Solidity từ file
            solc_version = get_solidity_version(sol_file_path)
            
            if solc_version:
                print(f"📌 Phiên bản Solidity yêu cầu: {solc_version}")
                install_and_use_solc(solc_version)  # Cài đặt và sử dụng đúng phiên bản solc
                run_slither(sol_file_path)  # Chạy Slither
            else:
                print(f"⚠️ Không tìm thấy phiên bản Solidity trong {file_name}")
