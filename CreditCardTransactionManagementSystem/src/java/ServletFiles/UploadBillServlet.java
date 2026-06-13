//package ServletFiles;
//
//import jakarta.servlet.ServletException;
//import jakarta.servlet.annotation.MultipartConfig;
//import jakarta.servlet.annotation.WebServlet;
//import jakarta.servlet.http.*;
//import com.google.gson.Gson;
//import com.google.gson.JsonObject;
//import java.io.*;
//
//@WebServlet("/UploadBill")
//@MultipartConfig(
//    fileSizeThreshold = 1024 * 1024 * 2,
//    maxFileSize = 1024 * 1024 * 10,
//    maxRequestSize = 1024 * 1024 * 50
//)
//public class UploadBillServlet extends HttpServlet {
//
//    @Override
//    protected void doPost(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//
//        response.setContentType("application/json");
//        response.setCharacterEncoding("UTF-8");
//        PrintWriter out = null;
//        
//        try {
//            out = response.getWriter();
//            
//            System.out.println("UploadBill servlet called");
//            
//            Part filePart = request.getPart("billImage");
//            
//            if (filePart == null || filePart.getSize() == 0) {
//                System.out.println("No file uploaded");
//                sendError(out, "No file uploaded");
//                return;
//            }
//
//            System.out.println("File received: " + filePart.getSize() + " bytes");
//
//            // For testing: Return dummy data
//            JsonObject jsonResponse = new JsonObject();
//            jsonResponse.addProperty("success", true);
//            jsonResponse.addProperty("merchant", "Singara Chennai Card");
//            jsonResponse.addProperty("amount", "100.00");
//            jsonResponse.addProperty("date", "2026-02-17");
//            jsonResponse.addProperty("category", "Travel");
//
//            String jsonString = new Gson().toJson(jsonResponse);
//            System.out.println("Sending response: " + jsonString);
//            
//            out.print(jsonString);
//            out.flush();
//            
//            System.out.println("Response sent successfully");
//
//        } catch (Exception e) {
//            System.err.println("Error in UploadBill servlet:");
//            e.printStackTrace();
//            if (out != null) {
//                sendError(out, "Error: " + e.getMessage());
//            }
//        }
//    }
//
//    private void sendError(PrintWriter out, String message) {
//        JsonObject error = new JsonObject();
//        error.addProperty("success", false);
//        error.addProperty("error", message);
//        out.print(new Gson().toJson(error));
//        out.flush();
//    }
//}

// ********************* NEW CODE HERE ****************

package ServletFiles;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Base64;

@WebServlet("/UploadBill")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,
    maxFileSize = 1024 * 1024 * 10,
    maxRequestSize = 1024 * 1024 * 50
)
public class UploadBillServlet extends HttpServlet {

    private static final String GEMINI_API_KEY = "AIzaSyDO9j5DZIiCvDygZuqZcgd7F42AvTYReQA";

    // Only use the most reliable models - no waiting, fast fail
    private static final String[] GEMINI_MODELS = {
        "gemini-2.0-flash",
        "gemini-1.5-flash",
        "gemini-1.5-flash-001"
    };

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        try {
            Part filePart = request.getPart("billImage");
            if (filePart == null || filePart.getSize() == 0) {
                sendError(out, "No image file received.");
                return;
            }

            byte[] imageBytes = filePart.getInputStream().readAllBytes();
            String base64Image = Base64.getEncoder().encodeToString(imageBytes);
            String mediaType = filePart.getContentType();
            if (mediaType == null || mediaType.isBlank()) mediaType = "image/jpeg";

            System.out.println("[UploadBill] Image: " + imageBytes.length + " bytes, type: " + mediaType);

            // Try each model - NO waiting, skip immediately on failure
            for (String model : GEMINI_MODELS) {
                System.out.println("[UploadBill] Trying: " + model);
                JsonObject result = callGeminiAPI(base64Image, mediaType, model);

                if (result != null && result.has("success") && result.get("success").getAsBoolean()) {
                    System.out.println("[UploadBill] Success with: " + model);
                    out.print(new Gson().toJson(result));
                    out.flush();
                    return;
                }
                System.out.println("[UploadBill] Failed with: " + model + ", trying next...");
            }

            sendError(out, "Could not read bill image. Please enter details manually.");

        } catch (Exception e) {
            System.err.println("[UploadBill] Error: " + e.getMessage());
            e.printStackTrace();
            sendError(out, "Server error: " + e.getMessage());
        }
    }

    private JsonObject callGeminiAPI(String base64Image, String mediaType, String model) {
        try {
            String apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/"
                          + model + ":generateContent?key=" + GEMINI_API_KEY;

            String prompt =
                "Extract bill details and return ONLY this JSON, nothing else:\n" +
                "{\"success\":true,\"merchant\":\"<store name>\",\"amount\":\"<total amount e.g. 50.00>\",\"date\":\"<YYYY-MM-DD>\",\"category\":\"<Food|Travel|Entertainment|Shopping|Healthcare|Utilities|Education|Others>\"}\n" +
                "Rules: amount = final total paid. date = YYYY-MM-DD format. JSON only, no markdown.";

            JsonObject imageData = new JsonObject();
            imageData.addProperty("mimeType", mediaType);
            imageData.addProperty("data", base64Image);

            JsonObject imagePart = new JsonObject();
            imagePart.add("inlineData", imageData);

            JsonObject textPart = new JsonObject();
            textPart.addProperty("text", prompt);

            JsonArray parts = new JsonArray();
            parts.add(imagePart);
            parts.add(textPart);

            JsonObject content = new JsonObject();
            content.add("parts", parts);

            JsonArray contents = new JsonArray();
            contents.add(content);

            JsonObject generationConfig = new JsonObject();
            generationConfig.addProperty("temperature", 0.1);
            generationConfig.addProperty("maxOutputTokens", 200);

            JsonObject requestBody = new JsonObject();
            requestBody.add("contents", contents);
            requestBody.add("generationConfig", generationConfig);

            URL url = new URL(apiUrl);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);
            conn.setConnectTimeout(15000); // 15 sec connect timeout
            conn.setReadTimeout(20000);    // 20 sec read timeout

            try (OutputStream os = conn.getOutputStream()) {
                os.write(new Gson().toJson(requestBody).getBytes("UTF-8"));
            }

            int code = conn.getResponseCode();
            System.out.println("[UploadBill] " + model + " -> HTTP " + code);

            InputStream stream = (code == 200) ? conn.getInputStream() : conn.getErrorStream();
            String rawResponse = new BufferedReader(new InputStreamReader(stream, "UTF-8"))
                .lines().reduce("", String::concat);

            if (code != 200) {
                System.out.println("[UploadBill] Error response: " + rawResponse.substring(0, Math.min(200, rawResponse.length())));
                JsonObject err = new JsonObject();
                err.addProperty("success", false);
                err.addProperty("error", "HTTP " + code);
                return err;
            }

            JsonObject geminiResp = JsonParser.parseString(rawResponse).getAsJsonObject();
            JsonArray candidates = geminiResp.getAsJsonArray("candidates");

            if (candidates == null || candidates.size() == 0) {
                JsonObject err = new JsonObject();
                err.addProperty("success", false);
                err.addProperty("error", "No candidates");
                return err;
            }

            String extractedText = candidates.get(0)
                .getAsJsonObject()
                .getAsJsonObject("content")
                .getAsJsonArray("parts")
                .get(0).getAsJsonObject()
                .get("text").getAsString().trim();

            System.out.println("[UploadBill] Raw extracted: " + extractedText);

            // Clean markdown fences
            extractedText = extractedText
                .replaceAll("(?s)```json\\s*", "")
                .replaceAll("(?s)```\\s*", "")
                .trim();

            // Isolate JSON object
            int start = extractedText.indexOf('{');
            int end   = extractedText.lastIndexOf('}');
            if (start != -1 && end != -1) {
                extractedText = extractedText.substring(start, end + 1);
            }

            JsonObject extracted = JsonParser.parseString(extractedText).getAsJsonObject();
            extracted.addProperty("success", true);
            System.out.println("[UploadBill] Final result: " + extracted);
            return extracted;

        } catch (Exception e) {
            System.err.println("[UploadBill] callGeminiAPI error (" + model + "): " + e.getMessage());
            JsonObject err = new JsonObject();
            err.addProperty("success", false);
            err.addProperty("error", e.getMessage());
            return err;
        }
    }

    private void sendError(PrintWriter out, String message) {
        System.err.println("[UploadBill] Error: " + message);
        JsonObject error = new JsonObject();
        error.addProperty("success", false);
        error.addProperty("error", message);
        out.print(new Gson().toJson(error));
        out.flush();
    }
}