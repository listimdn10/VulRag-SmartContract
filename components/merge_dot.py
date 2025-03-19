import os
import glob

# Thư mục cha chứa các thư mục con
parent_dir = "dot_files"

# Duyệt qua từng thư mục con trong dot_files
for subdir in os.listdir(parent_dir):
    subdir_path = os.path.join(parent_dir, subdir)

    # Kiểm tra nếu là thư mục
    if os.path.isdir(subdir_path):
        dot_files = glob.glob(os.path.join(subdir_path, "*.dot"))  # Lấy tất cả file .dot trong thư mục con

        # Nếu thư mục có file .dot thì tiến hành hợp nhất
        if dot_files:
            merged_dot_file = os.path.join(subdir_path, f"{subdir}.dot")  # Tạo file gộp theo tên thư mục

            with open(merged_dot_file, "w") as outfile:
                outfile.write("digraph CFG {\n")  # Khởi tạo đồ thị chung

                for dot_file in dot_files:
                    with open(dot_file, "r") as infile:
                        for line in infile:
                            if not line.startswith("digraph CFG") and line.strip() != "}":
                                outfile.write(line)
                    outfile.write("}\n")
                outfile.write("}\n")  # Kết thúc đồ thị

            # Xóa các file .dot lẻ sau khi hợp nhất
            for dot_file in dot_files:
                if dot_file != merged_dot_file:  # Tránh xóa file gộp
                    os.remove(dot_file)

print("Hợp nhất hoàn tất! Mỗi thư mục con chỉ còn 1 file .dot duy nhất.")
