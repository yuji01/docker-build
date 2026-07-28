import hashlib
import os
import uuid
from PIL import Image
import psycopg2
# 目的：兰空图床手动将图片复制到上传路径后，数据库并不会增加，需要手动插入数据，才能在网页端显示
# 适用于 postgres:15 数据库

# ================= 配置区 =================
DB_CONFIG = {
    "dbname": "lsky",
    "user": "lsky",
    "password": "vzGKLdj0tGWYrufpL",
    "host": "111.222.22.182",
    "port": "5432",
}

# 本机扫描路径
UPLOADS_ROOT = "/root/images"

STRATEGY_ID = 1  # 存储策略 ID
USER_ID = 1  # 用户 ID
GROUP_ID = 1  # 角色组 ID (1 代表 系统默认组&游客组)
PERMISSION = 0  # 权限 (0 代表 私有)
# =========================================


def get_file_hashes(file_path):
    """计算文件的 MD5 和 SHA1"""
    md5 = hashlib.md5()
    sha1 = hashlib.sha1()
    with open(file_path, "rb") as f:
        while chunk := f.read(8192):
            md5.update(chunk)
            sha1.update(chunk)
    return md5.hexdigest(), sha1.hexdigest()


def import_pictures():
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()

    count = 0
    print("🚀 开始扫描并同步本地图片到兰空图床数据库...\n")

    for root, dirs, files in os.walk(UPLOADS_ROOT):
        for file in files:
            if not file.lower().endswith(
                (".png", ".jpg", ".jpeg", ".gif", ".webp")
            ):
                continue

            full_path = os.path.join(root, file)

            # 1. 计算相对路径 (例: 2024/12/08/xxx.png)
            rel_path = os.path.relpath(full_path, UPLOADS_ROOT).replace(
                "\\", "/"
            )

            # 👉 终极修正：path 必须只保留文件夹路径 (例: 2024/12/08)，绝不能带文件名！
            storage_path = os.path.dirname(rel_path)
            if storage_path == "." or not storage_path:
                storage_path = ""

            file_size_kb = round(os.path.getsize(full_path) / 1024, 2)
            md5_val, sha1_val = get_file_hashes(full_path)

            ext = os.path.splitext(file)[1].lstrip(".").lower()
            try:
                with Image.open(full_path) as img:
                    width, height = img.size
            except Exception:
                width, height = 0, 0

            try:
                # 查重：对比 目录(path) 和 文件名(name)
                cursor.execute(
                    "SELECT id FROM images WHERE path = %s AND name = %s",
                    (storage_path, file),
                )
                if cursor.fetchone():
                    print(f"⏩ 跳过已存在图片: {storage_path}/{file}")
                    continue

                unique_key = uuid.uuid4().hex[:16]

                insert_query = """
                    INSERT INTO images (
                        key, strategy_id, user_id, group_id, name, origin_name, path, size, 
                        mimetype, extension, md5, sha1, width, height, 
                        permission, created_at, updated_at
                    ) VALUES (
                        %s, %s, %s, %s, %s, %s, %s, %s, 
                        %s, %s, %s, %s, %s, %s, 
                        %s, NOW(), NOW()
                    )
                """

                mimetype = f"image/{ext}" if ext != "jpg" else "image/jpeg"

                cursor.execute(
                    insert_query,
                    (
                        unique_key,
                        STRATEGY_ID,
                        USER_ID,
                        GROUP_ID,
                        file,  # 文件名
                        file,  # 原始文件名
                        storage_path,  # 纯文件夹目录 (例: 2024/12/08)
                        file_size_kb,
                        mimetype,
                        ext,
                        md5_val,
                        sha1_val,
                        width,
                        height,
                        PERMISSION,
                    ),
                )

                count += 1
                print(f"✅ 成功导入: {storage_path}/{file}")

            except Exception as e:
                print(f"❌ 导入失败 {rel_path}: {e}")
                conn.rollback()
                continue

    conn.commit()
    cursor.close()
    conn.close()
    print(f"\n🎉 导入完成！共同步了 {count} 张新图片。")


if __name__ == "__main__":
    import_pictures()
