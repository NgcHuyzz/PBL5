package com.ice.pbl5.Service;

import com.ice.pbl5.DTO.Response.AiTCPResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.net.InetSocketAddress;
import java.net.Socket;

@Service
public class AiTCPClientService {
    @Value("${ai.tcp.host}")
    private String host;

    @Value("${ai.tcp.port}")
    private int port;

    @Value("${ai.tcp.connect-timeout-ms:3000}")
    private int connectTimeoutMs;

    @Value("${ai.tcp.read-timeout-ms:10000}")
    private int readTimeoutMs;

    public AiTCPResponse classify(byte[] imgBytes)
    {
        try (Socket soc = new Socket()) {
            soc.connect(new InetSocketAddress(host, port), connectTimeoutMs);
            soc.setSoTimeout(readTimeoutMs);

            try (
                    DataOutputStream dos = new DataOutputStream(new BufferedOutputStream(soc.getOutputStream()));
                    DataInputStream dis = new DataInputStream(new BufferedInputStream(soc.getInputStream()))
            ) {
                dos.writeInt(imgBytes.length);
                dos.write(imgBytes);
                dos.flush();

                boolean success = dis.readBoolean();
                if (!success) {
                    String errorMessage = dis.readUTF();
                    return new AiTCPResponse(false, null, null, errorMessage);
                }

                String fruitType = dis.readUTF();
                double confidence = dis.readDouble();

                return new AiTCPResponse(true, fruitType, confidence, null);
            }
        }
        catch (Exception e) {
            return new AiTCPResponse(false, null, null, "TCP/AI error: " + e.getMessage());
        }
    }

}
