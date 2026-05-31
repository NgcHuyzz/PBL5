import socket
import struct


def test_tcp_server(image_path):
    host = '127.0.0.1' # Gọi thẳng vào máy tính của mình (Localhost)
    port = 5000

    try:
        # 1. Đọc file ảnh dưới dạng byte
        with open(image_path, 'rb') as f:
            img_bytes = f.read()

        # 2. Gõ cửa Server
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect((host, port))
        print("🔌 Đã kết nối tới Server AI!")

        # 3. Gửi y hệt kiểu Java
        # Gửi kích thước file trước (dos.writeInt)
        sock.sendall(struct.pack('>i', len(img_bytes)))
        # Đổ toàn bộ dữ liệu ảnh sang (dos.write)
        sock.sendall(img_bytes)
        print(f"📦 Đã gửi ảnh thành công ({len(img_bytes)} bytes). Đang chờ AI phán quyết...")

        # 4. Hứng kết quả trả về từ Server
        # Hứng boolean báo thành công (dis.readBoolean)
        success = struct.unpack('>?', sock.recv(1))[0]
        if not success:
            err_len = struct.unpack('>H', sock.recv(2))[0]
            err_msg = sock.recv(err_len).decode('utf-8')
            print(f"❌ Server báo lỗi: {err_msg}")
            return

        # Hứng tên trái cây (dis.readUTF)
        str_len = struct.unpack('>H', sock.recv(2))[0]
        fruit_type = sock.recv(str_len).decode('utf-8')

        # Hứng độ tự tin (dis.readDouble)
        confidence = struct.unpack('>d', sock.recv(8))[0]

        # 5. In kết quả ra màn hình
        print("\n============================")
        print("🎯 KẾT QUẢ TỪ AI SERVER:")
        print(f"🍓 Trái cây: {fruit_type}")
        print(f"💯 Độ tự tin: {confidence * 100:.2f}%")
        print("============================\n")

    except Exception as e:
        print(f"Lỗi khi test: {e}")
    finally:
        sock.close()

# Chạy test với bức ảnh vừa chuẩn bị
test_tcp_server('2.jpg')