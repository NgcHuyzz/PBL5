import socket
import struct
import tensorflow as tf
import numpy as np
import io
import json
import h5py
from PIL import Image


def load_model_compat(model_path):
    """Tải model .h5 với fallback tương thích InputLayer giữa các phiên bản Keras."""
    class CompatibleInputLayer(tf.keras.layers.InputLayer):
        def __init__(self, *args, batch_shape=None, optional=None, **kwargs):
            # Bỏ qua `optional` ở runtime không hỗ trợ.
            _ = optional

            if batch_shape is not None and kwargs.get("shape") is None and kwargs.get("input_shape") is None:
                if isinstance(batch_shape, (list, tuple)) and len(batch_shape) >= 2:
                    if kwargs.get("batch_size") is None:
                        kwargs["batch_size"] = batch_shape[0]
                    kwargs["shape"] = tuple(batch_shape[1:])

            super().__init__(*args, **kwargs)

    class CompatibleDense(tf.keras.layers.Dense):
        def __init__(self, *args, quantization_config=None, **kwargs):
            _ = quantization_config
            super().__init__(*args, **kwargs)

    class CompatibleConv2D(tf.keras.layers.Conv2D):
        def __init__(self, *args, quantization_config=None, **kwargs):
            _ = quantization_config
            super().__init__(*args, **kwargs)

    custom_objects = {
        "InputLayer": CompatibleInputLayer,
        "Dense": CompatibleDense,
        "Conv2D": CompatibleConv2D,
        "DTypePolicy": tf.keras.mixed_precision.Policy,
    }

    try:
        return tf.keras.models.load_model(model_path, compile=False, custom_objects=custom_objects)
    except Exception:
        # Fallback cuối: đọc JSON config trong file .h5, làm sạch key không tương thích rồi khôi phục + nạp weights.
        with h5py.File(model_path, "r") as f:
            model_config_raw = f.attrs.get("model_config")

        if model_config_raw is None:
            raise

        if isinstance(model_config_raw, bytes):
            model_config = json.loads(model_config_raw.decode("utf-8"))
        else:
            model_config = json.loads(model_config_raw)

        def _sanitize(obj):
            if isinstance(obj, dict):
                cleaned = {}
                for k, v in obj.items():
                    if k == "quantization_config":
                        continue
                    cleaned[k] = _sanitize(v)

                if cleaned.get("class_name") == "DTypePolicy":
                    cleaned["class_name"] = "Policy"

                if cleaned.get("class_name") == "InputLayer":
                    cfg = cleaned.get("config", {})
                    if isinstance(cfg, dict) and "batch_shape" in cfg and "shape" not in cfg and "input_shape" not in cfg:
                        batch_shape = cfg.get("batch_shape")
                        if isinstance(batch_shape, (list, tuple)) and len(batch_shape) >= 2:
                            cfg["shape"] = batch_shape[1:]
                            cfg["batch_size"] = batch_shape[0]
                    cleaned["config"] = cfg

                return cleaned

            if isinstance(obj, list):
                return [_sanitize(item) for item in obj]

            return obj

        sanitized_config = _sanitize(model_config)
        model = tf.keras.models.model_from_json(
            json.dumps(sanitized_config),
            custom_objects=custom_objects,
        )
        model.load_weights(model_path)
        return model


print("Đang khởi động AI...")
model = load_model_compat('fruit_classifier_best2.h5')
class_labels = ['CHERRY TOMATO', 'STRAWBERRY', 'GRAPE', 'BLUEBERRY']
print("AI đã sẵn sàng!")


def send_java_utf(sock, string):
    """Hàm đặc biệt: Đóng gói chuỗi string của Python thành chuẩn UTF của Java (dis.readUTF)"""
    encoded = string.encode('utf-8')
    sock.sendall(struct.pack('>H', len(encoded)) + encoded)


def start_tcp_server(host='0.0.0.0', port=5000):
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.bind((host, port))
    server_socket.listen(5)
    print(f"TCP Server đang lắng nghe tại {host}:{port}...")

    while True:
        client_socket, addr = server_socket.accept()
        print(f"\n[+] Có kết nối từ: {addr}")

        try:
            length_bytes = client_socket.recv(4)
            if not length_bytes:
                continue
            img_length = struct.unpack('>i', length_bytes)[0]
            img_data = b''
            while len(img_data) < img_length:
                packet = client_socket.recv(img_length - len(img_data))
                if not packet:
                    break
                img_data += packet
            try:
                img = Image.open(io.BytesIO(img_data)).convert('RGB')
                img = img.resize((128, 128))
                img_array = tf.keras.utils.img_to_array(img)
                img_array = np.expand_dims(img_array, axis=0)
                img_array /= 255.0

                predictions = model.predict(img_array)
                class_index = np.argmax(predictions[0])
                confidence = float(predictions[0][class_index])
                fruit_type = class_labels[class_index]

                print(f"Nhận diện: {fruit_type} ({confidence*100:.2f}%)")
                client_socket.sendall(struct.pack('>?', True))
                send_java_utf(client_socket, fruit_type)
                client_socket.sendall(struct.pack('>d', confidence))

            except Exception as e:
                print(f"Lỗi xử lý AI: {e}")
                client_socket.sendall(struct.pack('>?', False))
                send_java_utf(client_socket, str(e))

        except Exception as e:
            print(f"Lỗi kết nối: {e}")
        finally:
            client_socket.close()


if __name__ == "__main__":
    # Chạy server
    start_tcp_server()