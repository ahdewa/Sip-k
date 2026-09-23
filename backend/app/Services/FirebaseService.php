<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;

class FirebaseService
{
    protected static function getAccessToken()
    {
        return Cache::remember('fcm_access_token', 3000, function () {
            $keyPath = storage_path('app/firebase/service-account.json');
            if (!file_exists($keyPath)) {
                Log::warning("Firebase service account key not found at $keyPath");
                return null;
            }

            $keyData = json_decode(file_get_contents($keyPath), true);
            $clientEmail = $keyData['client_email'] ?? '';
            $privateKey = $keyData['private_key'] ?? '';

            if (empty($clientEmail) || empty($privateKey)) {
                Log::warning("Firebase service account key invalid or missing fields");
                return null;
            }

            $b64Url = function ($data) {
                return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
            };

            $now = time();
            $header = $b64Url(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
            $claims = $b64Url(json_encode([
                'iss' => $clientEmail,
                'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
                'aud' => 'https://oauth2.googleapis.com/token',
                'exp' => $now + 3600,
                'iat' => $now,
            ]));

            $binarySignature = '';
            $signed = openssl_sign($header . '.' . $claims, $binarySignature, $privateKey, OPENSSL_ALGO_SHA256);
            if (!$signed) {
                Log::error("Failed to sign Firebase JWT");
                return null;
            }

            $jwt = $header . '.' . $claims . '.' . $b64Url($binarySignature);

            $ch = curl_init('https://oauth2.googleapis.com/token');
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query([
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion' => $jwt,
            ]));
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

            $response = curl_exec($ch);
            $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
            curl_close($ch);

            if ($httpCode === 200) {
                $resData = json_decode($response, true);
                return $resData['access_token'] ?? null;
            }

            Log::error("Firebase OAuth token exchange failed ($httpCode): $response");
            return null;
        });
    }

    public static function sendPushNotification($fcmToken, $title, $body, array $data = [])
    {
        if (empty($fcmToken)) {
            return false;
        }

        $accessToken = self::getAccessToken();
        if (!$accessToken) {
            return false;
        }

        $keyPath = storage_path('app/firebase/service-account.json');
        $keyData = json_decode(@file_get_contents($keyPath), true);
        $projectId = $keyData['project_id'] ?? 'sip-k-a136d';

        // Format data: all values must be string in FCM HTTP v1
        $stringData = [];
        foreach ($data as $k => $v) {
            $stringData[(string)$k] = (string)$v;
        }

        $message = [
            'token' => $fcmToken,
            'notification' => [
                'title' => $title,
                'body' => $body,
            ],
            'android' => [
                'priority' => 'high',
                'notification' => [
                    'sound' => 'default',
                    'channel_id' => 'sip_k_channel',
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                ],
            ],
        ];

        // Only attach 'data' if not empty (FCM v1 requires Object/Map, not empty array/list)
        if (!empty($stringData)) {
            $message['data'] = $stringData;
        }

        $payload = [
            'message' => $message,
        ];

        $url = "https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send";

        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, [
            'Authorization: Bearer ' . $accessToken,
            'Content-Type: application/json; UTF-8',
        ]);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($httpCode >= 200 && $httpCode < 300) {
            Log::info("FCM push sent successfully to token: " . substr($fcmToken, 0, 15) . "...");
            return true;
        }

        Log::warning("FCM push failed ($httpCode): $response");
        return false;
    }

    public static function sendToUser($userId, $title, $body, array $data = [])
    {
        $user = User::find($userId);
        if ($user && !empty($user->fcm_token)) {
            return self::sendPushNotification($user->fcm_token, $title, $body, $data);
        }
        return false;
    }

    public static function sendToAdmins($title, $body, array $data = [])
    {
        $admins = User::whereIn('role', ['admin', 'superadmin', 'super_admin'])
            ->whereNotNull('fcm_token')
            ->where('fcm_token', '!=', '')
            ->get();

        foreach ($admins as $admin) {
            self::sendPushNotification($admin->fcm_token, $title, $body, $data);
        }
    }
}
