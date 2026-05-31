package com.ice.pbl5.Service;

import com.ice.pbl5.DTO.Response.AiTCPResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.time.LocalDateTime;
import java.util.Arrays;

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

    public AiTCPResponse classify(byte[] imgBytes) throws InterruptedException {
        if (imgBytes == null || imgBytes.length == 0) {
            return new AiTCPResponse(false, null, null, "MOCK_AI error: empty image");
        }

        // MOCK mode while AI service is not available.
        // Produce deterministic data based on image bytes so the same image tends to give the same result.
//        String[] mockFruits = {"CHERRY TOMATO", "STRAWBERRY", "GRAPE", "BLUEBERRY"};
//        int seed = Math.abs(Arrays.hashCode(imgBytes));
//        String fruitType = mockFruits[seed % mockFruits.length];
//
//        double rawConfidence = 0.8;
//        BigDecimal confidence = BigDecimal.valueOf(rawConfidence).setScale(2, RoundingMode.HALF_UP);
//        Thread.sleep(500);
//        System.out.println("ai thành công"+ LocalDateTime.now());
//
//        return new AiTCPResponse(true, fruitType, confidence, null);

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
                BigDecimal confidence = BigDecimal.valueOf(dis.readDouble());

                return new AiTCPResponse(true, fruitType, confidence, null);
            }
        }
        catch (Exception e) {
            return new AiTCPResponse(false, null, null, "TCP/AI error: " + e.getMessage());
        }
    }

}
